<div align="center">

# 🔴 Offensive Security
### Active Reconnaissance — Scanning & Enumeration

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Active%20Recon-ff6b00?style=for-the-badge&logo=hackthebox&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-00d4ff?style=for-the-badge&logo=linux&logoColor=white)

</div>

---

> **¿Qué es el Reconocimiento Activo?**
> Esta fase implica **interactuar directamente** con los sistemas objetivo para obtener respuestas técnicas. A diferencia del reconocimiento pasivo, aquí se envían paquetes y solicitudes reales al objetivo. **Genera tráfico detectable** en logs, IDS/IPS y firewalls.

> [!WARNING]
> **Aviso Legal y Ético:** Todas las herramientas y comandos documentados en este repositorio deben ser utilizados única y exclusivamente en entornos donde se posea **autorización explícita por escrito (Reglas de Enfrentamiento / RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🗂️ Resumen de Herramientas](#️-resumen-de-herramientas) |
| 02 | [🔭 Nmap — Escaneo de Red y Puertos](#-nmap--escaneo-de-red-y-puertos) |
| 03 | [🌐 DNS Activo](#-dns-activo) |
| 04 | [🖧 SMB / NetBIOS — Enum4linux](#-smb--netbios--enum4linux) |
| 05 | [⚡ NetExec / CrackMapExec](#-netexec--crackmapexec) |
| 06 | [📧 SMTP Enumeration](#-smtp-enumeration) |
| 07 | [🕸️ Web Enumeration — FFUF](#️-web-enumeration--ffuf) |
| 08 | [🗂️ Web Enumeration — Gobuster](#️-web-enumeration--gobuster) |
| 09 | [🌍 Web Reconnaissance — Curl & WAF](#-web-reconnaissance--curl--waf) |
| 10 | [🕷️ Web Crawling & Spidering](#️-web-crawling--spidering) |
| 11 | [📊 Recapitulación del Proceso](#-recapitulación-del-proceso) |

---

## 🗂️ Resumen de Herramientas

| Herramienta | Categoría | Protocolo / Enfoque | Badge |
|-------------|-----------|---------------------|-------|
| **Nmap** | Escaneo / Discovery | TCP, UDP, ICMP — Todos los servicios IP | ![](https://img.shields.io/badge/-SCAN-ff3c6e?style=flat-square) |
| **enum4linux** | Enumeración SMB | SMB, NetBIOS, MSRPC, SAMR, LSA | ![](https://img.shields.io/badge/-SMB-ff6b00?style=flat-square) |
| **NetExec** | Post-explotación / Enum | SMB, LDAP, MSSQL, FTP, SSH | ![](https://img.shields.io/badge/-AD-a855f7?style=flat-square) |
| **CrackMapExec** | Credential Testing | SMB, WMI, LDAP, MSSQL, RDP | ![](https://img.shields.io/badge/-CRED-a855f7?style=flat-square) |
| **FFUF** | Web Fuzzing | HTTP — Directorios, extensiones, VHosts, parámetros | ![](https://img.shields.io/badge/-FUZZ-00d4ff?style=flat-square) |
| **Gobuster** | Web / DNS Brute-Force | HTTP, DNS, VHosts | ![](https://img.shields.io/badge/-BRUTE-00ff88?style=flat-square) |
| **smtp-user-enum** | Enumeración SMTP | SMTP (25, 465, 587) | ![](https://img.shields.io/badge/-SMTP-ffb300?style=flat-square) |
| **curl** | Inspección HTTP | HTTP/HTTPS — Headers, Auth, API | ![](https://img.shields.io/badge/-HTTP-5865f2?style=flat-square) |
| **wafw00f** | Detección WAF | HTTP — Identificación de firewall web | ![](https://img.shields.io/badge/-WAF-00d4ff?style=flat-square) |
| **ReconSpider** | Web Crawling | HTTP — Extracción de endpoints y metadatos | ![](https://img.shields.io/badge/-CRAWL-00ff88?style=flat-square) |

---

## 🔭 Nmap — Escaneo de Red y Puertos

![Tool](https://img.shields.io/badge/Tool-Nmap-ff3c6e?style=flat-square&logo=linux&logoColor=white)
![Lang](https://img.shields.io/badge/Lenguaje-C%2FC%2B%2B-00599c?style=flat-square)

Nmap (**Network Mapper**) es el estándar de facto para el descubrimiento de hosts, escaneo de puertos, detección de servicios, identificación de SO y auditoría de seguridad mediante scripts NSE.

---

### `[01]` Tipos de Escaneo

| Flag | Tipo | Descripción |
|------|------|-------------|
| `-sT` | TCP Connect | Handshake completo (3-way). Detectable, no requiere privilegios. |
| `-sS` | SYN Stealth | Envía RST tras recibir SYN-ACK. Rápido y menos registrado. **Requiere root.** |
| `-sU` | UDP | Detecta servicios UDP (DNS, SNMP, DHCP). Lento por naturaleza. |
| `-sA` | TCP ACK | Mapea reglas de firewall (filtrado vs. no-filtrado). |
| `-sW` | TCP Window | Similar a ACK pero examina el campo Window. |
| `-sN` | TCP Null | Sin flags. Sistemas UNIX reportan cerrado o filtrado. |
| `-sF` | FIN | Solo flag FIN. Útil contra algunos firewalls. |
| `-sX` | Xmas | Flags FIN+PSH+URG. Combinación "árbol de navidad". |
| `-sn` | Ping Sweep | Solo descubrimiento de hosts, sin escaneo de puertos. |
| `-sL` | List Scan | Lista targets sin enviar paquetes. |

---

### `[02]` Descubrimiento de Hosts

```bash
# Ping sweep de subred
nmap -sn 192.168.1.0/24

# TCP SYN discovery (host activo si responde)
nmap -PS 192.168.1.1

# TCP ACK discovery (evita SYN filtering)
nmap -PA 192.168.1.1

# UDP discovery
nmap -PU 192.168.1.1

# Saltar descubrimiento — escanear directamente
nmap -Pn 192.168.1.1

# Desactivar resolución DNS (más rápido)
nmap -n 192.168.1.0/24
```

---

### `[03]` Especificación de Puertos

```bash
# Puerto específico
nmap -p 80 target

# Lista de puertos
nmap -p 22,80,443,3306,3389 target

# Rango de puertos
nmap -p 1-1000 target

# Todos los puertos (65535)
nmap -p- target

# Top 100 puertos (modo rápido)
nmap -F target

# Top N puertos
nmap --top-ports 500 target

# Excluir puertos
nmap --exclude-ports 80,443 target
```

---

### `[04]` Detección de Versiones y SO

```bash
# Detección de versión de servicios
nmap -sV target

# Intensidad de detección (0-9, default 7)
nmap -sV --version-intensity 9 target

# Detección de sistema operativo
nmap -O target

# OS con suposición agresiva
nmap -O --osscan-guess target

# Detección completa: OS + versiones + scripts + traceroute
nmap -A target
```

---

### `[05]` Plantillas de Tiempo (Timing)

| Flag | Perfil | Velocidad | Uso Recomendado |
|------|--------|-----------|-----------------|
| `-T0` | Paranoid | Muy lento | Evasión máxima de IDS |
| `-T1` | Sneaky | Lento | Evasión de IDS |
| `-T2` | Polite | Moderado | Minimizar impacto en red |
| `-T3` | Normal | Default | Uso general |
| `-T4` | Aggressive | Rápido | Redes confiables/locales |
| `-T5` | Insane | Máximo | CTF / redes muy rápidas |

```bash
# Escaneo rápido en red local
nmap -T4 -p- 192.168.1.0/24

# Evasión lenta con tiempos amplios
nmap -T1 --scan-delay 1s target
```

---

### `[06]` Formatos de Salida

```bash
# Texto normal legible
nmap -oN scan_result.txt target

# Formato XML (para importar en tools)
nmap -oX scan_result.xml target

# Formato grepable
nmap -oG scan_result.gnmap target

# Todos los formatos a la vez
nmap -oA scan_results target

# Agregar a archivo existente
nmap -oA results --append-output target
```

---

### `[07]` Evasión de Firewalls / IDS

```bash
# Desactivar ping (bypass ICMP filtering)
nmap -Pn target

# Desactivar resolución DNS
nmap -n target

# Desactivar ARP ping
nmap --disable-arp-ping target

# 5 IPs señuelo aleatorias (decoys)
nmap -D RND:5 target

# Decoys específicos
nmap -D 10.10.10.5,10.10.10.6,ME target

# Fragmentación de paquetes (evita DPI)
nmap -f target

# Spoofear dirección MAC
nmap --spoof-mac 0 target

# Ver paquetes enviados/recibidos
nmap --packet-trace target
```

---

### `[08]` NSE — Nmap Scripting Engine

```bash
# Ejecutar script específico
nmap --script=http-title target

# Categoría completa de scripts
nmap --script=vuln target
nmap --script=auth target
nmap --script=discovery target
nmap --script=safe target

# Múltiples scripts
nmap --script=http-headers,http-methods target

# Scripts de enumeración DNS
nmap -Pn --script=dns-brute domain.com

# Scripts de enumeración SMB
nmap -p 445 --script=smb-enum-shares,smb-enum-users target
nmap -p 445 --script=smb-vuln-ms17-010 target

# Scripts HTTP
nmap -p 80 --script=http-sql-injection target
nmap -p 80 --script=http-unsafe-output-escaping target
nmap -Pn --script=http-sitemap-generator scanme.nmap.org

# Scripts SMTP
nmap -p 25 --script=smtp-enum-users --script-args smtp-enum-users.methods={VRFY,EXPN,RCPT} target
nmap -p 25 --script=smtp-open-relay target
```

> [!TIP]
> Los scripts NSE están ubicados en `/usr/share/nmap/scripts/`. Usar `nmap --script-help <script>` para ver documentación.

---

### `[09]` Comandos Combinados — Flujos de Trabajo

```bash
# Descubrimiento rápido de hosts vivos
nmap -sn 10.10.10.0/24 -oG hosts_vivos.gnmap
grep "Up" hosts_vivos.gnmap | awk '{print $2}' > targets.txt

# Escaneo completo + scripts de vulnerabilidades
nmap -sS -sV -O -A -p- -T4 --script=vuln -oA full_scan target

# Solo puertos abiertos — exportar para análisis
nmap -p- --open -T4 target -oG open_ports.gnmap
grep "open" open_ports.gnmap

# Escaneo UDP de servicios críticos
nmap -sU -p 53,67,68,69,111,123,137,138,161,162,514 target

# Leer targets desde archivo
nmap -iL targets.txt -sV -oA batch_scan
```

---

## 🌐 DNS Activo

![Tool](https://img.shields.io/badge/Tool-nslookup%20%7C%20dig%20%7C%20dnsrecon-00d4ff?style=flat-square)

A diferencia del DNS pasivo, aquí se interactúa directamente con los servidores DNS del objetivo para forzar respuestas.

---

### `[01]` nslookup — Consultas Interactivas

```bash
# Modo interactivo
nslookup
> server 8.8.8.8       # Usar servidor DNS específico
> set type=MX          # Buscar servidores de correo
> set type=SOA         # Start of Authority
> set type=PTR         # Resolución inversa (IP → nombre)
> set type=NS          # Servidores de nombres
> set type=TXT         # Registros TXT (SPF, DKIM, verificaciones)
> set type=AAAA        # Registros IPv6
> example.com

# Modo directo
nslookup -type=MX example.com
nslookup -type=NS example.com 1.1.1.1
```

---

### `[02]` dig — Consultas Detalladas

```bash
# Registro A
dig example.com A

# Registro MX
dig example.com MX

# Todos los registros
dig example.com ANY

# Intento de transferencia de zona (AXFR)
dig axfr example.com @ns1.example.com

# Resolución inversa
dig -x 192.168.1.1

# Consulta sin información extra
dig +short example.com

# Traza completa del camino DNS
dig +trace example.com
```

---

### `[03]` dnsrecon — Enumeración y Fuerza Bruta DNS

```bash
# Enumeración estándar (A, AAAA, MX, NS, SOA, SRV)
dnsrecon -d example.com

# Transferencia de zona (AXFR)
dnsrecon -d example.com -t axfr

# Fuerza bruta de subdominios
dnsrecon -d example.com \
  -D /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  -t brt

# Resolución inversa por rango
dnsrecon -r 162.241.216.0-162.241.216.255

# Resolución inversa CIDR
dnsrecon -r 192.168.1.0/24

# Caminata de zona DNSSEC (NSEC records)
dnsrecon -d example.com -z

# Expansión de TLD
dnsrecon -d example -t tld

# Guardar resultados en JSON
dnsrecon -d example.com -j resultados_dnsrecon.json
```

---

### `[04]` Gobuster — Fuerza Bruta de VHosts y DNS

```bash
# Fuerza bruta de subdominios DNS
gobuster dns -d example.com \
  -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  -t 50

# Virtual Hosts (VHosts) con append-domain
gobuster vhost -u http://192.168.1.1 \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  --append-domain

# Ejemplo real HTB
gobuster vhost -u http://inlanefreight.htb:81 \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  --append-domain
```

---

## 🖧 SMB / NetBIOS — Enum4linux

![Tool](https://img.shields.io/badge/Tool-enum4linux-ff6b00?style=flat-square&logo=linux&logoColor=white)
![Protocol](https://img.shields.io/badge/Protocol-SMB%20%7C%20NetBIOS%20%7C%20MSRPC-a855f7?style=flat-square)

**enum4linux** es un wrapper alrededor de las herramientas Samba (`smbclient`, `rpcclient`, `net`, `nmblookup`) para enumerar sistemas Windows y Samba a través de SMB/RPC.

---

### `[01]` Flags Principales

| Flag | Descripción |
|------|-------------|
| `-a` | **Ejecutar todas las opciones de enumeración** (recomendado) |
| `-U` | Listar usuarios del dominio/sistema |
| `-G` | Listar grupos y membresías |
| `-S` | Enumerar shares SMB |
| `-P` | Obtener política de contraseñas |
| `-o` | Mostrar información del SO |
| `-i` | Información de impresoras |
| `-r` | RID cycling (rango default: 500-550, 1000-1050) |
| `-R <range>` | RID cycling con rango personalizado |
| `-d` | Información de dominio/workgroup |
| `-w` | Detección de workgroup |
| `-u <user>` | Usuario para autenticación |
| `-p <pass>` | Contraseña para autenticación |
| `-s <file>` | Ataque de diccionario en shares |
| `-v` | Modo verbose (muestra comandos subyacentes) |

---

### `[02]` Comandos de Uso

```bash
# Enumeración completa (recomendado como punto de partida)
enum4linux -a 192.168.1.10

# Listar usuarios
enum4linux -U 192.168.1.10

# Listar grupos
enum4linux -G 192.168.1.10

# Listar shares SMB
enum4linux -S 192.168.1.10

# Obtener política de contraseñas
enum4linux -P 192.168.1.10

# RID cycling (enumeración de usuarios por RID)
enum4linux -r 192.168.1.10

# RID cycling con rango ampliado
enum4linux -R 500-1200 192.168.1.10

# Autenticado con credenciales
enum4linux -u administrator -p 'Password123' -a 192.168.1.10

# Escaneo de subred completa
enum4linux -a 192.168.1.0/24

# Información del SO
enum4linux -o 192.168.1.10

# Verbose — ver qué comandos ejecuta internamente
enum4linux -v -a 192.168.1.10
```

> [!IMPORTANT]
> La enumeración de usuarios con `-U` requiere que `RestrictAnonymous = 0` en el objetivo. Si está restringido, usar `-u` y `-p` para autenticación.

---

### `[03]` Interpretación de Resultados

```bash
# Shares típicos en entornos Windows
# ADMIN$   → Recurso administrativo (requiere privilegios)
# C$       → Unidad C por defecto (requiere privilegios)
# IPC$     → Comunicación entre procesos (acceso anónimo frecuente)
# SYSVOL   → Políticas de grupo (DC de AD)
# NETLOGON → Scripts de inicio de sesión (DC de AD)

# RIDs comunes
# 500 → Administrador local (built-in)
# 501 → Guest
# 502 → krbtgt (solo en DC)
# 512 → Domain Admins
# 513 → Domain Users
```

---

## ⚡ NetExec / CrackMapExec

![Tool](https://img.shields.io/badge/Tool-NetExec-a855f7?style=flat-square&logo=github&logoColor=white)
![Tool](https://img.shields.io/badge/Tool-CrackMapExec-a855f7?style=flat-square)
![Protocol](https://img.shields.io/badge/Protocol-SMB%20%7C%20LDAP%20%7C%20MSSQL%20%7C%20FTP-ff3c6e?style=flat-square)

**NetExec** (`nxc`) es el sucesor de CrackMapExec. Framework para pentesting en infraestructura Windows/AD: enumeración, prueba de credenciales, volcado de secretos y ejecución remota.

```bash
# Instalación NetExec
sudo apt install pipx git
pipx ensurepath
pipx install git+https://github.com/Pennyw0rth/NetExec

# Sintaxis base
netexec <protocolo> <target> -u <usuario> -p <contraseña> [opciones]
# Alias corto
nxc smb target -u user -p pass
```

---

### `[01]` Autenticación

```bash
# Sesión nula (null session)
netexec smb target -u '' -p ''

# Sesión guest
netexec smb target -u 'guest' -p ''

# Autenticación local (no de dominio)
netexec smb target -u administrator -p 'Password1' --local-auth

# Kerberos
netexec smb target -u user -p pass -k

# Pass-the-Hash (PTH)
netexec smb target -u administrator -H 'NTHASH_AQUI'

# Kerberos cache (ccache)
netexec ldap target --use-kcache
```

---

### `[02]` Enumeración SMB

```bash
# Información básica del host (OS, hostname, dominio, SMB version)
netexec smb 192.168.1.0/24

# Listar shares
netexec smb target -u user -p pass --shares

# Listar usuarios (null session)
netexec smb target -u '' -p '' --users

# Listar grupos
netexec smb target -u user -p pass --groups

# Grupos locales
netexec smb target -u user -p pass --local-groups

# Usuarios logueados
netexec smb target -u user -p pass --loggedon-users

# Sesiones activas
netexec smb target -u user -p pass --sessions

# Política de contraseñas
netexec smb target -u user -p pass --pass-pol

# RID brute force (enumerar usuarios por RID)
netexec smb target -u '' -p '' --rid-brute

# Enumeración completa
netexec smb target -u user -p pass \
  --groups --local-groups --loggedon-users \
  --rid-brute --sessions --users --shares --pass-pol
```

---

### `[03]` Enumeración LDAP (Active Directory)

```bash
# Usuarios de AD
netexec ldap target -u user -p pass --users

# Kerberoasting — obtener hashes de cuentas con SPN
netexec ldap target -u user -p pass --kerberoasting hashes_kerb.txt

# ASREPRoasting — cuentas sin pre-autenticación Kerberos
netexec ldap target -u user -p pass --asreproast hashes_asrep.txt

# BloodHound — recolección completa de AD
netexec ldap target -u user -p pass \
  --bloodhound --dns-server <ip_dns> --dns-tcp -c all

# GMSA passwords
netexec ldap target -u user -p pass --gmsa

# Delegaciones
netexec ldap target -u user -p pass --find-delegation

# ADCS (Certificate Services)
netexec ldap target -u user -p pass -M adcs

# MAQ (Machine Account Quota)
netexec ldap target -u user -p pass -M maq

# Pre-Windows 2000 accounts
netexec ldap target -u user -p pass -M pre2k

# Verificar firma LDAP
netexec ldap target -u user -p pass -M ldap-checker
```

---

### `[04]` Volcado de Credenciales

```bash
# LSA secrets (credenciales del sistema)
netexec smb target -u user -p pass --lsa

# SAM database (hashes locales)
netexec smb target -u user -p pass --sam

# NTDS.dit (base de datos de AD — solo en DC)
netexec smb target -u user -p pass --ntds

# DPAPI secrets
netexec smb target -u user -p pass --dpapi

# LAPS passwords
netexec smb target -u user -p pass --laps
```

---

### `[05]` Módulos Útiles

```bash
# Spider de shares (mapeo de archivos)
netexec smb target -u user -p pass -M spider_plus
netexec smb target -u user -p pass -M spider_plus -o READ_ONLY=false

# GPP Passwords (Group Policy Preferences)
netexec smb target -u user -p pass -M gpp_password

# Dump de LSASS (requiere privilegios)
netexec smb target -u user -p pass -M lsassy

# WebDAV detection
netexec smb target -u user -p pass -M webdav

# Check SMB signing (para relay attacks)
netexec smb 192.168.1.0/24 --gen-relay-list relay_targets.txt

# Vulnerabilidades conocidas
netexec smb target -u user -p pass -M zerologon
netexec smb target -u user -p pass -M petitpotam
netexec smb target -u user -p pass -M nopac
```

---

### `[06]` Password Spraying

```bash
# Un password contra lista de usuarios
netexec smb 192.168.1.0/24 -u users.txt -p 'Password2024!' --continue-on-success

# Lista de usuarios vs lista de passwords (sin bruteforce — 1:1)
netexec smb target -u users.txt -p passwords.txt \
  --no-bruteforce --continue-on-success

# Targets múltiples
netexec smb targets.txt -u administrator -p 'Password1' --local-auth
```

> [!CAUTION]
> El spraying puede **bloquear cuentas** si la política de contraseñas tiene lockout. Siempre verificar la política antes con `--pass-pol`.

---

### `[07]` Ejecución Remota de Comandos

```bash
# CMD en target
netexec smb target -u admin -p 'Pass123' -x 'whoami'

# PowerShell en target
netexec smb target -u admin -p 'Pass123' -X 'Get-Process'

# MSSQL — ejecutar comando OS
netexec mssql target -u sa -p 'Password' -x 'whoami'

# MSSQL — descargar archivo
netexec mssql target -u sa -p 'Password' \
  --get-file C:\Windows\win.ini output.txt
```

---

## 📧 SMTP Enumeration

![Tool](https://img.shields.io/badge/Tool-smtp--user--enum%20%7C%20Nmap%20NSE-ffb300?style=flat-square)
![Protocol](https://img.shields.io/badge/Protocol-SMTP%2025%20%7C%20465%20%7C%20587-ff3c6e?style=flat-square)

SMTP puede revelar usuarios válidos mediante los comandos `VRFY`, `EXPN` y `RCPT TO`. Esta información es valiosa para ataques de fuerza bruta y phishing dirigido.

---

### `[01]` Comandos SMTP Manuales

```bash
# Conectar manualmente al servidor SMTP
nc -nv target 25
telnet target 25

# Dentro de la sesión SMTP:
HELO attacker.com
EHLO attacker.com          # Extended HELO — lista capabilities

# VRFY — verificar si un usuario existe
VRFY root
VRFY admin
VRFY info

# EXPN — expandir lista de correo (revela miembros)
EXPN administrators
EXPN postmaster

# RCPT TO — probar destinatarios
MAIL FROM:<test@test.com>
RCPT TO:<admin@target.com>
```

---

### `[02]` smtp-user-enum

```bash
# Enumeración con método VRFY
smtp-user-enum -M VRFY -U /usr/share/wordlists/metasploit/unix_users.txt \
  -t 192.168.1.10

# Enumeración con método EXPN
smtp-user-enum -M EXPN -U users.txt -t 192.168.1.10

# Enumeración con método RCPT
smtp-user-enum -M RCPT -U users.txt -D target.com -t 192.168.1.10

# Múltiples targets
smtp-user-enum -M VRFY -U users.txt -T targets.txt

# Un solo usuario
smtp-user-enum -M VRFY -u root -t 192.168.1.10

# Puerto no estándar
smtp-user-enum -M VRFY -U users.txt -t 192.168.1.10 -p 587
```

---

### `[03]` Nmap NSE — Scripts SMTP

```bash
# Enumeración de usuarios con todos los métodos
nmap -p 25 --script=smtp-enum-users \
  --script-args smtp-enum-users.methods={VRFY,EXPN,RCPT} \
  target

# Verificar si el servidor es open relay
nmap -p 25 --script=smtp-open-relay target

# Obtener comandos soportados (EHLO)
nmap -p 25 --script=smtp-commands target

# Verificar vulnerabilidades conocidas
nmap -p 25 --script=smtp-vuln-cve2010-4344 target
```

---

### `[04]` Metasploit — SMTP

```bash
# Módulo de enumeración SMTP en Metasploit
use auxiliary/scanner/smtp/smtp_enum
set RHOSTS 192.168.1.10
set USER_FILE /usr/share/wordlists/metasploit/unix_users.txt
run
```

---

## 🕸️ Web Enumeration — FFUF

![Tool](https://img.shields.io/badge/Tool-FFUF-00d4ff?style=flat-square&logo=go&logoColor=white)
![Protocol](https://img.shields.io/badge/Protocol-HTTP%20%7C%20HTTPS-5865f2?style=flat-square)

**FFUF** (Fuzz Faster U Fool) es un web fuzzer escrito en Go. Altamente configurable para descubrir directorios, archivos, parámetros, VHosts y subdominios.

---

### `[01]` Fuzzing de Directorios

```bash
# Fuzzing básico de directorios
ffuf -w /opt/useful/seclists/Discovery/Web-Content/directory-list-2.3-small.txt:FUZZ \
  -u http://SERVER_IP:PORT/FUZZ

# Con extensión específica
ffuf -w wordlist.txt:FUZZ \
  -u http://target/FUZZ.php

# Con múltiples extensiones
ffuf -w wordlist.txt:FUZZ \
  -u http://target/FUZZ \
  -e .php,.html,.txt,.bak,.old

# Fuzzing recursivo (profundidad 1)
ffuf -w /opt/useful/seclists/Discovery/Web-Content/directory-list-2.3-small.txt:FUZZ \
  -u http://SERVER_IP:PORT/FUZZ \
  -recursion -recursion-depth 1 -e .php -v
```

---

### `[02]` Fuzzing de Extensiones

```bash
# Descubrir extensiones en un archivo conocido
ffuf -w /opt/useful/seclists/Discovery/Web-Content/web-extensions.txt:FUZZ \
  -u http://target/indexFUZZ

# Fuzzing de extensiones en directorio
ffuf -w wordlist.txt:FUZZ \
  -u http://target/admin/FUZZ \
  -e .php,.asp,.aspx,.jsp,.txt,.config
```

---

### `[03]` Fuzzing de Páginas Específicas

```bash
# Descubrir archivos PHP
ffuf -w /opt/useful/seclists/Discovery/Web-Content/directory-list-2.3-small.txt:FUZZ \
  -u http://target/FUZZ.php

# Descubrir archivos de backup / configuración
ffuf -w wordlist.txt:FUZZ \
  -u http://target/FUZZ \
  -e .bak,.old,.orig,.backup,.swp,.tmp
```

---

### `[04]` Fuzzing de Subdominios y VHosts

```bash
# Subdominios DNS (registro A)
ffuf -w /opt/useful/seclists/Discovery/DNS/subdomains-top1million-5000.txt:FUZZ \
  -u http://academy.htb:PORT/ \
  -H 'Host: FUZZ.academy.htb'

# Virtual Hosts — auto-calibración
ffuf -u http://10.10.10.10 \
  -H "Host: FUZZ.example.com" \
  -w /opt/SecLists/Discovery/DNS/subdomains-top1million-20000.txt \
  -ac

# VHosts con filtrado manual
ffuf -c \
  -w /path/to/wordlist \
  -u http://victim.com \
  -H "Host: FUZZ.victim.com"

# CORS Abuse para descubrir subdominios válidos
ffuf -w subdomains-top1million-5000.txt \
  -u http://10.10.10.208 \
  -H 'Origin: http://FUZZ.crossfit.htb' \
  -mr "Access-Control-Allow-Origin" \
  -ignore-body
```

---

### `[05]` Fuzzing de Parámetros y Valores

```bash
# Fuzzing de parámetro GET
ffuf -w /opt/useful/seclists/Discovery/Web-Content/burp-parameter-names.txt:FUZZ \
  -u 'http://target/page.php?FUZZ=value'

# Fuzzing de valor de parámetro GET
ffuf -w /opt/useful/seclists/Fuzzing/LFI/LFI-Jhaddix.txt:FUZZ \
  -u 'http://target/page.php?param=FUZZ'

# Fuzzing POST — body
ffuf -w wordlist.txt:FUZZ \
  -u http://target/login.php \
  -X POST \
  -d 'username=FUZZ&password=test'

# Fuzzing POST con JSON
ffuf -w wordlist.txt:FUZZ \
  -u http://target/api/login \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username":"FUZZ","password":"test"}'
```

---

### `[06]` Filtrado de Resultados

```bash
# Filtrar por código HTTP (ocultar 404)
ffuf -w wordlist.txt:FUZZ -u http://target/FUZZ -fc 404

# Filtrar por tamaño de respuesta
ffuf -w wordlist.txt:FUZZ -u http://target/FUZZ -fs 0

# Filtrar por número de palabras
ffuf -w wordlist.txt:FUZZ -u http://target/FUZZ -fw 10

# Filtrar por número de líneas
ffuf -w wordlist.txt:FUZZ -u http://target/FUZZ -fl 5

# Mostrar solo ciertos códigos HTTP
ffuf -w wordlist.txt:FUZZ -u http://target/FUZZ -mc 200,301,302,403

# Filtrar por regex en respuesta
ffuf -w wordlist.txt:FUZZ -u http://target/FUZZ -mr "admin|dashboard"

# Auto-calibración (detecta y filtra respuestas genéricas)
ffuf -w wordlist.txt:FUZZ -u http://target/FUZZ -ac
```

---

### `[07]` Flags Útiles

| Flag | Descripción |
|------|-------------|
| `-t` | Threads (default: 40) |
| `-rate` | Requests por segundo |
| `-timeout` | Timeout en segundos |
| `-v` | Verbose output |
| `-c` | Colorear output |
| `-s` | Silent mode (solo resultados) |
| `-o` | Guardar resultado en archivo |
| `-of` | Formato de salida (json, csv, html, md) |
| `-H` | Header personalizado |
| `-b` | Cookies |
| `-r` | Seguir redirects |
| `-recursion` | Modo recursivo |
| `-recursion-depth` | Profundidad máxima de recursión |

```bash
# Ejemplo completo con flags
ffuf -w /usr/share/wordlists/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt:FUZZ \
  -u http://target/FUZZ \
  -t 100 -rate 500 \
  -c -v \
  -fc 404,403 \
  -o results.json -of json
```

---

## 🗂️ Web Enumeration — Gobuster

![Tool](https://img.shields.io/badge/Tool-Gobuster-00ff88?style=flat-square&logo=go&logoColor=white)

**Gobuster** ofrece tres modos principales: `dir` (directorios), `dns` (subdominios) y `vhost` (virtual hosts).

---

### `[01]` Modo dir — Directorios y Archivos

```bash
# Fuzzing básico de directorios
gobuster dir -u http://target \
  -w /usr/share/wordlists/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt

# Con extensiones
gobuster dir -u http://target \
  -w wordlist.txt \
  -x php,html,txt,bak

# Con autenticación básica
gobuster dir -u http://target \
  -w wordlist.txt \
  -U admin -P password

# Con threads y timeout
gobuster dir -u http://target \
  -w wordlist.txt \
  -t 50 --timeout 10s

# Seguir redirects
gobuster dir -u http://target \
  -w wordlist.txt \
  -r

# Con cookie de sesión
gobuster dir -u http://target \
  -w wordlist.txt \
  -c 'PHPSESSID=abc123'

# Ignorar TLS inválido
gobuster dir -u https://target \
  -w wordlist.txt \
  -k

# Guardar output
gobuster dir -u http://target \
  -w wordlist.txt \
  -o gobuster_results.txt
```

---

### `[02]` Modo dns — Subdominios

```bash
# Fuerza bruta DNS
gobuster dns -d example.com \
  -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  -t 50

# Mostrar IPs de subdominios encontrados
gobuster dns -d example.com \
  -w wordlist.txt \
  --show-ips

# Resolver con servidor DNS específico
gobuster dns -d example.com \
  -w wordlist.txt \
  -r 8.8.8.8
```

---

### `[03]` Modo vhost — Virtual Hosts

```bash
# Descubrimiento de VHosts
gobuster vhost -u http://192.168.1.100 \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  --append-domain

# Con dominio base conocido
gobuster vhost -u http://inlanefreight.htb:81 \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  --append-domain

# Filtrar por código de respuesta
gobuster vhost -u http://target \
  -w wordlist.txt \
  --exclude-length 280
```

---

## 🌍 Web Reconnaissance — Curl & WAF

![Tool](https://img.shields.io/badge/Tool-curl-5865f2?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-wafw00f-00d4ff?style=flat-square)

---

### `[01]` Curl — Inspección HTTP

```bash
# GET básico
curl http://target

# Solo headers de respuesta
curl -I http://target

# Headers + body
curl -iv http://target

# Header personalizado
curl -H "X-Forwarded-For: 127.0.0.1" http://target

# User-Agent personalizado
curl -A "Mozilla/5.0 (compatible; Googlebot/2.1)" http://target

# POST con datos
curl -X POST http://target/login \
  -d 'username=admin&password=test'

# POST JSON
curl -X POST http://target/api \
  -H 'Content-Type: application/json' \
  -d '{"user":"admin","pass":"test"}'

# Autenticación HTTP Basic
curl -u admin:password http://target/protected

# Autenticación con cookie
curl -b 'PHPSESSID=abc123' http://target/dashboard

# Seguir redirects
curl -L http://target

# Ignorar SSL inválido
curl -k https://target

# Guardar respuesta
curl -o response.html http://target

# Verboso completo
curl -v http://target
```

---

### `[02]` Encabezados HTTP Relevantes

```bash
# Ver encabezados de entidad (Content-Type, Content-Length, etc.)
curl -I http://target | grep -iE "content-type|content-length|server|x-powered-by"

# Encabezados de seguridad importantes
# Strict-Transport-Security → HSTS habilitado
# X-Frame-Options          → Protección contra clickjacking
# X-XSS-Protection         → Filtro XSS del browser
# Content-Security-Policy  → Restricción de recursos
# X-Content-Type-Options   → Previene MIME sniffing

# Ver todos los headers de respuesta
curl -sI http://target
```

---

### `[03]` Interacción con APIs

```bash
# GET a endpoint API
curl http://target/api/v1/users

# POST crear recurso
curl -X POST http://target/api/v1/users \
  -H 'Content-Type: application/json' \
  -d '{"name":"test","email":"test@test.com"}'

# PUT actualizar recurso
curl -X PUT http://target/api/v1/users/1 \
  -H 'Content-Type: application/json' \
  -d '{"name":"updated"}'

# DELETE
curl -X DELETE http://target/api/v1/users/1

# Con token Bearer (JWT)
curl -H "Authorization: Bearer eyJhbGc..." http://target/api/v1/profile
```

---

### `[04]` wafw00f — Detección de WAF

**wafw00f** identifica si el objetivo está protegido por un Web Application Firewall y determina el producto específico.

```bash
# Instalación
pip3 install git+https://github.com/EnableSecurity/wafw00f

# Detección básica
wafw00f http://target.com

# Modo agresivo (más requests, mejor detección)
wafw00f -a http://target.com

# Escaneo de múltiples targets
wafw00f -i targets.txt

# Output en formato JSON
wafw00f http://target.com -o results.json -f json

# Listar WAFs que puede detectar
wafw00f -l
```

> [!NOTE]
> Si se detecta un WAF, ajustar las técnicas de fuzzing: usar `-rate` limitado en FFUF, encoding de payloads, y considerar evasión de WAF antes de continuar.

---

### `[05]` robots.txt y sitemap.xml

```bash
# Leer robots.txt (revela rutas prohibidas = rutas interesantes)
curl http://target/robots.txt

# Leer sitemap
curl http://target/sitemap.xml

# Extraer URLs del sitemap
curl -s http://target/sitemap.xml | grep -oP '(?<=<loc>)[^<]+'

# robots.txt — directivas clave:
# User-agent: *      → Aplica a todos los bots
# Disallow: /admin   → Ruta prohibida (¡OBJETIVO!)
# Disallow: /backup  → Ruta prohibida
# Allow: /           → Permite acceso
# Sitemap: /sitemap.xml → Ubicación del sitemap
```

---

## 🕷️ Web Crawling & Spidering

![Tool](https://img.shields.io/badge/Tool-ReconSpider%20%7C%20FinalRecon-00ff88?style=flat-square)

---

### `[01]` ReconSpider

```bash
# Instalación
wget -O ReconSpider.zip https://academy.hackthebox.com/storage/modules/144/ReconSpider.v1.2.zip
unzip ReconSpider.zip

# Uso básico
python3 ReconSpider.py http://inlanefreight.com

# Resultados se guardan en results.json
# Contiene: emails, links, subdominios, formularios
```

---

### `[02]` FinalRecon

Suite de reconocimiento web con módulos para headers, WHOIS, GeoIP, SSL, crawling y más.

```bash
# Instalación
git clone https://github.com/thewhiteh4t/FinalRecon.git
cd FinalRecon
pip3 install -r requirements.txt
chmod +x ./finalrecon.py

# Reconocimiento completo
python3 finalrecon.py --full https://target.com

# Módulos individuales
python3 finalrecon.py --headers https://target.com      # Headers HTTP
python3 finalrecon.py --sslinfo https://target.com      # Certificado SSL
python3 finalrecon.py --whois https://target.com        # WHOIS
python3 finalrecon.py --crawl https://target.com        # Crawling
python3 finalrecon.py --dns https://target.com          # DNS
python3 finalrecon.py --sub https://target.com          # Subdominios
python3 finalrecon.py --ps https://target.com           # Port scan
```

---

### `[03]` Herramientas Complementarias de Web Enum

```bash
# WhatWeb — fingerprinting de tecnologías
whatweb http://target
whatweb -a 3 http://target     # Agresividad nivel 3

# Nikto — scanner de vulnerabilidades web
nikto -h http://target
nikto -h http://target -p 8080 -o nikto_report.txt

# dirb — brute force de directorios
dirb http://target /usr/share/wordlists/dirb/common.txt

# wfuzz — fuzzing avanzado
wfuzz -c \
  -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-20000.txt \
  --hc 400,404,403 \
  -H "Host: FUZZ.example.com" \
  -u http://example.com \
  -t 100
```

---

## 📊 Recapitulación del Proceso

### Flujo de Reconocimiento Activo

```
[1] ESCANEO DE RED
    └── nmap -sn <subred>           → Hosts activos
        └── nmap -sS -sV -O -A      → Puertos / Servicios / SO

[2] ENUMERACIÓN DNS
    └── dnsrecon / dig / nslookup   → Registros, AXFR, brute-force
        └── gobuster dns / vhost    → Subdominios y VHosts

[3] SERVICIOS DESCUBIERTOS
    ├── Puerto 445/SMB
    │   └── enum4linux -a           → Usuarios, shares, políticas
    │   └── netexec smb             → Autenticación, enum AD
    │
    ├── Puerto 25/SMTP
    │   └── smtp-user-enum          → Enumeración de usuarios
    │   └── nmap --script smtp-*    → VRFY, EXPN, relay check
    │
    └── Puerto 80/443/HTTP
        ├── wafw00f                 → Detección de WAF
        ├── curl -I                 → Headers y tecnologías
        ├── robots.txt / sitemap    → Rutas interesantes
        ├── ffuf / gobuster dir     → Directorios y archivos
        ├── ReconSpider             → Crawling y extracción
        └── whatweb / nikto         → Fingerprinting / vulns

[4] DOCUMENTAR
    └── nmap -oA / ffuf -of json / netexec --export
```

---

### Resumen de Wordlists Recomendadas

| Propósito | Wordlist |
|-----------|----------|
| Directorios web | `/usr/share/wordlists/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt` |
| Extensiones | `/usr/share/wordlists/seclists/Discovery/Web-Content/web-extensions.txt` |
| Subdominios DNS | `/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt` |
| Parámetros | `/usr/share/wordlists/seclists/Discovery/Web-Content/burp-parameter-names.txt` |
| Usuarios UNIX | `/usr/share/wordlists/metasploit/unix_users.txt` |
| LFI payloads | `/usr/share/wordlists/seclists/Fuzzing/LFI/LFI-Jhaddix.txt` |

---

### Puertos Clave por Protocolo

| Puerto | Protocolo | Herramienta Recomendada |
|--------|-----------|------------------------|
| 21 | FTP | `nmap -sV -p 21`, `netexec ftp` |
| 22 | SSH | `nmap --script ssh-*` |
| 25 | SMTP | `smtp-user-enum`, `nmap --script smtp-*` |
| 53 | DNS | `dnsrecon`, `dig`, `gobuster dns` |
| 80/443 | HTTP/HTTPS | `ffuf`, `gobuster dir`, `nikto`, `wafw00f` |
| 139/445 | SMB | `enum4linux`, `netexec smb`, `nmap --script smb-*` |
| 389/636 | LDAP | `netexec ldap`, `nmap --script ldap-*` |
| 1433 | MSSQL | `netexec mssql`, `nmap --script ms-sql-*` |
| 3306 | MySQL | `nmap --script mysql-*` |
| 3389 | RDP | `nmap --script rdp-*`, `netexec rdp` |
| 5985/5986 | WinRM | `netexec winrm`, `evil-winrm` |

> [!NOTE]
> Toda la información recolectada en esta fase debe documentarse en el informe de pentesting. Los hallazgos de enumeración son la base para las fases de **explotación** y **post-explotación**.
