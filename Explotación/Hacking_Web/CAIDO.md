<div align="center">

# 🧪 Caido
### Flujo Base para Labs de Hacking Web

</div>

---

> **Idea:** usar `Caido` como herramienta principal. Todo request pasa por proxy, luego análisis manual en `HTTP History`, `Replay` y `Automate`.

---

## 🗂️ Componentes Clave

| Función | Uso práctico |
|---------|--------------|
| **Scopes** | Limitar tráfico a DVWA, Juice Shop o lab PortSwigger |
| **Intercept** | Detener requests y modificar parámetros/cookies/headers |
| **HTTP History** | Ver todo request/response proxied |
| **Replay** | Reenviar y mutar requests uno a uno |
| **Automate** | Fuzzing, wordlists, placeholders, brute-force controlado |
| **Match & Replace** | Reglas automáticas para headers, cookies, encode |
| **Search / HTTPQL** | Filtrar por método, path, status, tamaño, host |
| **Assistant** | Explicar requests y generar CSRF PoC si tienes plan compatible |

---

## 🚀 Setup Mínimo

1. Crear proyecto nuevo.
2. Importar certificado CA de Caido en navegador de laboratorio.
3. Definir scope por host:
   - `dvwa.local`
   - `demo.owasp-juice.shop` o instancia local
   - subdominio/lab de PortSwigger
4. Navegar app desde navegador proxied.

---

## 🔁 Workflow Corto

### `[01]` Captura

- Abrir lab.
- Ejecutar acción vulnerable.
- Ver request en `HTTP History`.

### `[02]` Aislar

- Filtrar por:
  - método `POST`
  - status `200/302/500`
  - endpoints tipo `login`, `search`, `comment`, `upload`, `stock`, `api`

### `[03]` Repetir

- `Send to Replay`
- cambiar 1 cosa por vez:
  - parámetro
  - header
  - cookie
  - método HTTP
  - content-type

### `[04]` Escalar

- Si ya hay vector:
  - `Send to Automate`
  - meter placeholder
  - cargar wordlist o lista manual

---

## 🧵 Casos de Uso por Feature

### HTTP History

- Encontrar:
  - parámetros repetidos
  - responses largas/cortas
  - errores `500`
  - redirecciones raras

### Replay

- Ideal para:
  - SQLi manual
  - XSS reflejado
  - CSRF token testing
  - path traversal
  - SSRF puntual

### Automate

- Ideal para:
  - columnas SQLi con `ORDER BY`
  - wordlists XSS
  - usernames/IDs
  - fuzz de rutas y parámetros
  - bypass de filtros con variantes encoding

### Match & Replace

- Ideal para:
  - añadir header fijo
  - sustituir cookie
  - reescribir host
  - URL-encode automático

---

## 🔍 Queries Útiles

```text
method:POST
status_code:500
host:dvwa
path:/login
content_type:json
```

Usar combinaciones:

```text
method:POST AND status_code:200
host:juice-shop AND path:/rest
```

---

## 🧰 Wordlists / Payload Sets

Preparar archivos para `Automate`:

- `sqli-basic.txt`
- `xss-basic.txt`
- `traversal.txt`
- `cmdi-basic.txt`
- `ssrf-hosts.txt`

Payloads chicos primero. Luego variantes encoded.

---

## 🧪 Atajos de Laboratorio

| Hallazgo | Siguiente paso en Caido |
|----------|-------------------------|
| Parámetro refleja input | `Replay` con payload XSS |
| Error SQL o cambio lógico | `Replay` + `Automate` |
| Recurso carga URL externa | `Replay` con payload SSRF |
| File path controlado | `Replay` con traversal list |
| Acción sensible POST | revisar token, origin, referer, SameSite |

---

## 📝 Evidencia Mínima

Guardar por cada hallazgo:

1. Request original.
2. Request modificado.
3. Response clave.
4. Payload exitoso.
5. Impacto.
6. Lab donde se reprodujo.

---

## 🔗 Referencias

- Caido docs: `HTTP History`, `Replay`, `Automate`, `Match & Replace`, `Scopes`
- Caido docs: `Assistant` y `Generating CSRF PoCs`
