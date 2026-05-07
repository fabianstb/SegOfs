<div align="center">

# 🧃 OWASP Juice Shop
### Informe de Pentesting — Hallazgos Verificados

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-OWASP%20Juice%20Shop-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Scope](https://img.shields.io/badge/Scope-localhost%3A3000-00ff88?style=for-the-badge)

</div>

---

> **Objetivo:** documentación de hallazgos de seguridad identificados y verificados en instancia local de OWASP Juice Shop. Cada hallazgo incluye descripción técnica, evidencia de reproducción, impacto y remediación.

> [!WARNING]
> **Aviso Legal y Ético:** Todos los hallazgos fueron obtenidos en instancia propia y controlada de OWASP Juice Shop (`http://localhost:3000`). Uso exclusivo en laboratorio. Reproducción únicamente en entornos con **autorización explícita**.

---

## 📋 Resumen Ejecutivo

| Campo | Detalle |
|-------|---------|
| **Aplicación** | OWASP Juice Shop |
| **Versión objetivo** | `localhost:3000` |
| **Metodología** | Manual + PoC con `curl`, `python3/requests`, Caido |
| **Total hallazgos** | 6 verificados |
| **Hallazgos críticos** | 1 |
| **Hallazgos altos** | 2 |
| **Hallazgos medios** | 3 |

---

## 🗂️ Hallazgos Verificados

| # | Vulnerabilidad | Endpoint | Severidad | Writeup |
|---|---------------|----------|-----------|---------|
| 01 | SQL Injection — Login Bypass | `POST /rest/user/login` | ![](https://img.shields.io/badge/-Crítica-d32f2f?style=flat-square) | [SQLi_Login_Admin.md](SQLi_Login_Admin.md) |
| 02 | DOM XSS — Búsqueda | `GET /#/search?q=` | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) | [DOM_XSS.md](DOM_XSS.md) |
| 03 | SSRF — Imagen de Perfil | `POST /profile/image/url` | ![](https://img.shields.io/badge/-Alta-ff6b00?style=flat-square) | [SSRF_Profile_Image_URL.md](SSRF_Profile_Image_URL.md) |
| 04 | CSRF — Cambio de Perfil | `POST /profile` | ![](https://img.shields.io/badge/-Media-ffb300?style=flat-square) | [CSRF_Profile.md](CSRF_Profile.md) |
| 05 | File Upload — Bypass Tipo y Tamaño | `POST /file-upload` | ![](https://img.shields.io/badge/-Media-ffb300?style=flat-square) | [File_Upload_Bypass.md](File_Upload_Bypass.md) |
| 06 | Poison Null Byte — Path Traversal | `GET /ftp/<file>%2500.md` | ![](https://img.shields.io/badge/-Media-ffb300?style=flat-square) | [Poison_Null_Byte.md](Poison_Null_Byte.md) |

---

## 🟡 Pendiente / No Cerrado

| Tema | Nota |
|------|------|
| **Reflected XSS** | Sink identificado en `track-result`, no reproducido end-to-end |
| **Local File Read** | Challenge existe, PoC estable no obtenida en esta fase |
| **Command Injection** | Sin vector equivalente encontrado en esta instancia |

---

## 📊 Distribución de Severidad

```
Crítica  ██░░░░░░░░  1  (SQLi Login Bypass)
Alta     ████░░░░░░  2  (DOM XSS, SSRF)
Media    ██████░░░░  3  (CSRF, File Upload, Null Byte)
Baja     ░░░░░░░░░░  0
```

---

## 🔗 Relación con Temario

| Módulo | Hallazgo en Juice Shop |
|--------|------------------------|
| `SQLi` | Login bypass vía `' or 1=1--` |
| `XSS` | DOM XSS en parámetro `q` de búsqueda |
| `CSRF` | Cambio de username en `/profile` sin token |
| `SSRF` | Fetch server-side de `imageUrl` interna |
| `File Upload` | Bypass de tipo y tamaño en `/file-upload` |
| `Path Traversal` | Lectura de backups vía null byte `%2500` |

---

## 🔗 Referencias

- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/)
- [Juice Shop Challenge Solutions](https://pwning.owasp-juice.shop/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
