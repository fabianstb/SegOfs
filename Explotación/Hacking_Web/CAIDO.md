<div align="center">

# 🧪 Caido
### Proxy Principal — Flujo Base para Labs de Hacking Web

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Web%20Proxy-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **Objetivo:** usar Caido como proxy principal en todos los labs. Todo request pasa por proxy, luego análisis manual en `HTTP History`, `Replay` y `Automate`.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🗂️ Componentes Clave](#️-componentes-clave) |
| 02 | [🚀 Setup Mínimo](#-setup-mínimo) |
| 03 | [🔁 Workflow](#-workflow) |
| 04 | [🧵 Casos de Uso por Feature](#-casos-de-uso-por-feature) |
| 05 | [🔍 Queries HTTPQL](#-queries-httpql) |
| 06 | [🧰 Wordlists](#-wordlists) |
| 07 | [🧪 Atajos de Laboratorio](#-atajos-de-laboratorio) |
| 08 | [📝 Evidencia Mínima](#-evidencia-mínima) |

---

## 🗂️ Componentes Clave

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

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

![Tool](https://img.shields.io/badge/Setup-Inicial-00d4ff?style=flat-square)

### `[01]` Configuración inicial

1. Crear proyecto nuevo en Caido.
2. Importar certificado CA de Caido en navegador de laboratorio.
3. Definir scope por host:
   - `dvwa.local`
   - `demo.owasp-juice.shop` o instancia local
   - subdominio/lab de PortSwigger
4. Navegar app desde navegador proxied.

> [!TIP]
> Configurar scope desde el inicio. Sin scope, `HTTP History` se llena de tráfico irrelevante y dificulta el análisis.

---

## 🔁 Workflow

![Tool](https://img.shields.io/badge/Workflow-Estándar-ff6b00?style=flat-square)

### `[01]` Captura

- Abrir lab.
- Ejecutar acción vulnerable.
- Ver request en `HTTP History`.

### `[02]` Aislar

Filtrar por:

- método `POST`
- status `200/302/500`
- endpoints tipo `login`, `search`, `comment`, `upload`, `stock`, `api`

### `[03]` Repetir

`Send to Replay`, cambiar 1 cosa por vez:

- parámetro
- header
- cookie
- método HTTP
- content-type

### `[04]` Escalar

Si ya hay vector confirmado:

- `Send to Automate`
- meter placeholder en el parámetro
- cargar wordlist o lista manual

> [!IMPORTANT]
> Cambiar una variable por vez. Cambiar múltiples simultáneamente oscurece cuál fue efectiva.

---

## 🧵 Casos de Uso por Feature

![Tool](https://img.shields.io/badge/Feature-Reference-a855f7?style=flat-square)

### HTTP History

Buscar:

- parámetros repetidos
- responses largas/cortas
- errores `500`
- redirecciones raras

### Replay

Ideal para:

- SQLi manual
- XSS reflejado
- CSRF token testing
- path traversal
- SSRF puntual

### Automate

Ideal para:

- columnas SQLi con `ORDER BY`
- wordlists XSS
- usernames/IDs
- fuzz de rutas y parámetros
- bypass de filtros con variantes encoding

### Match & Replace

Ideal para:

- añadir header fijo a todos los requests
- sustituir cookie automáticamente
- reescribir host
- URL-encode automático

---

## 🔍 Queries HTTPQL

![Tool](https://img.shields.io/badge/HTTPQL-Query%20Language-00d4ff?style=flat-square)

```text
method:POST
status_code:500
host:dvwa
path:/login
content_type:json
```

Combinaciones:

```text
method:POST AND status_code:200
host:juice-shop AND path:/rest
```

> [!TIP]
> Guardar queries frecuentes como favoritos en Caido para reutilizarlos entre labs.

---

## 🧰 Wordlists

![Tool](https://img.shields.io/badge/Automate-Wordlists-ff3c6e?style=flat-square)

Preparar archivos para `Automate`:

| Archivo | Uso |
|---------|-----|
| `sqli-basic.txt` | Payloads SQLi mínimos |
| `xss-basic.txt` | Payloads XSS por contexto |
| `traversal.txt` | Secuencias path traversal |
| `cmdi-basic.txt` | Separadores command injection |
| `ssrf-hosts.txt` | Hosts internos / loopback |

> [!NOTE]
> Usar listas pequeñas primero. Variantes encoded como segunda pasada.

---

## 🧪 Atajos de Laboratorio

| Hallazgo | Siguiente paso en Caido |
|----------|-------------------------|
| Parámetro refleja input | `Replay` con payload XSS |
| Error SQL o cambio lógico | `Replay` → `Automate` |
| Recurso carga URL externa | `Replay` con payload SSRF |
| File path controlado | `Replay` con traversal list |
| Acción sensible POST sin token | revisar `Origin`, `Referer`, `SameSite` |

---

## 📝 Evidencia Mínima

Por cada hallazgo guardar en Caido:

1. Request original.
2. Request modificado.
3. Response clave.
4. Payload exitoso.
5. Impacto.
6. Lab donde se reprodujo.

---

## 🔗 Referencias

- [Caido Documentation](https://docs.caido.io)
- Caido features: `HTTP History`, `Replay`, `Automate`, `Match & Replace`, `Scopes`
- Caido features: `Assistant` y `Generating CSRF PoCs`
