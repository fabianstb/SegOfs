<div align="center">

# 🌐 Offensive Security
### Hacking Web — Roadmap de Explotación en Laboratorios Controlados

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Web%20Exploitation-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Main%20Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **Objetivo:** guía práctica de hacking web basada en entornos controlados. Temario alineado con laboratorios de **DVWA**, **OWASP Juice Shop** y **PortSwigger Web Security Academy**.

> [!WARNING]
> **Uso exclusivo en laboratorio.** Todo contenido de esta carpeta asume práctica en entornos propios, deliberadamente vulnerables o con autorización explícita.

---

## 📑 Tabla de Contenidos

| # | Tema | Archivo |
|---|------|---------|
| 01 | Flujo base con Caido | [CAIDO.md](CAIDO.md) |
| 02 | SQL Injection | [SQLi.md](SQLi.md) |
| 03 | Cross-site Scripting | [XSS.md](XSS.md) |
| 04 | Cross-site Request Forgery | [CSRF.md](CSRF.md) |
| 05 | Server-side Request Forgery | [SSRF.md](SSRF.md) |
| 06 | Path Traversal | [Path_Traversal.md](Path_Traversal.md) |
| 07 | Command Injection | [Command_Injection.md](Command_Injection.md) |
| 08 | File Upload | [File_Upload.md](File_Upload.md) |

---

## 🧪 Entornos de Práctica

| Entorno | Uso | Notas |
|---------|-----|-------|
| **DVWA** | Vulnerabilidades clásicas web | Ideal para SQLi, XSS, CSRF, command injection, file upload |
| **OWASP Juice Shop** | App moderna SPA/API | Ideal para XSS, auth, access control, SSRF, API abuse |
| **PortSwigger Web Security Academy** | Labs guiados por vulnerabilidad | Ideal para profundizar técnica y variantes reales |

---

## 🛠️ Stack de Herramientas

### Principal

| Herramienta | Uso |
|-------------|-----|
| **Caido** | Proxy, intercept, replay, fuzzing, filtros, match/replace, análisis HTTP |

### Complementarias

| Herramienta | Uso |
|-------------|-----|
| **Firefox + DevTools** | DOM, CSP, storage, JS, eventos |
| **ffuf** | Descubrimiento de rutas, parámetros y vhosts |
| **sqlmap** | Confirmación y automatización de SQLi en labs |
| **dalfox** | Apoyo para XSS reflejado/DOM |
| **interactsh-client** | OAST para SSRF ciego y callbacks |
| **jq** | Parseo de JSON/API responses |
| **curl** | Reproducción rápida fuera de proxy |

---

## 🎯 Flujo Recomendado

1. Definir alcance en Caido con `Scopes`.
2. Navegar app y capturar tráfico en `HTTP History`.
3. Mandar requests útiles a `Replay`.
4. Probar variaciones manuales.
5. Escalar a `Automate` si hace falta fuzzing o wordlists.
6. Documentar payload válido, precondiciones, respuesta esperada e impacto.
7. Repetir solo en labs controlados.

---

## 🧭 Mapa de Temas vs Labs

| Tema | DVWA | Juice Shop | PortSwigger |
|------|------|------------|-------------|
| **SQLi** | SQL Injection, SQL Injection (Blind) | Login Admin / retos Injection | SQL injection |
| **XSS** | Reflected, Stored, DOM | DOM XSS, Bonus Payload, Reflected XSS | Cross-site scripting |
| **CSRF** | CSRF | Flujos autenticados y cambios de perfil | Cross-site request forgery |
| **SSRF** | — | SSRF challenge | SSRF |
| **Path Traversal** | File Inclusion | Local File Read | Path traversal |
| **Command Injection** | Command Injection | Casos específicos de input server-side | OS command injection |
| **File Upload** | File Upload | Upload Type / Upload Size | File upload vulnerabilities |

---

## 🧱 Orden Sugerido

1. `SQLi.md`
2. `XSS.md`
3. `CSRF.md`
4. `Path_Traversal.md`
5. `Command_Injection.md`
6. `File_Upload.md`
7. `SSRF.md`

---

## 🔗 Referencias

- Hack4u, curso **Hacking Web**
- PortSwigger Web Security Academy
- Caido Documentation
- OWASP Juice Shop
