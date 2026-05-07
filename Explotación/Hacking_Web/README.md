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
> **Aviso Legal y Ético:** Todo contenido de esta carpeta asume práctica en entornos propios, deliberadamente vulnerables o con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

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
| **DVWA** | Vulnerabilidades clásicas web | Ideal para SQLi, XSS, CSRF, Command Injection, File Upload |
| **OWASP Juice Shop** | App moderna SPA/API | Ideal para XSS, auth, access control, SSRF, API abuse |
| **PortSwigger Web Security Academy** | Labs guiados por vulnerabilidad | Ideal para profundizar técnica y variantes reales |

---

## 🛠️ Stack de Herramientas

### Principal

| Herramienta | Uso | Badge |
|-------------|-----|-------|
| **Caido** | Proxy, intercept, replay, fuzzing, filtros, match/replace, análisis HTTP | ![](https://img.shields.io/badge/-Proxy-00ff88?style=flat-square) |

### Complementarias

| Herramienta | Uso | Badge |
|-------------|-----|-------|
| **Firefox + DevTools** | DOM, CSP, storage, JS, eventos | ![](https://img.shields.io/badge/-Browser-5865f2?style=flat-square) |
| **ffuf** | Descubrimiento de rutas, parámetros y vhosts | ![](https://img.shields.io/badge/-Fuzz-ff6b00?style=flat-square) |
| **sqlmap** | Confirmación y automatización de SQLi en labs | ![](https://img.shields.io/badge/-SQLi-ff3c6e?style=flat-square) |
| **dalfox** | Apoyo para XSS reflejado/DOM | ![](https://img.shields.io/badge/-XSS-00d4ff?style=flat-square) |
| **interactsh-client** | OAST para SSRF ciego y callbacks | ![](https://img.shields.io/badge/-OAST-a855f7?style=flat-square) |
| **jq** | Parseo de JSON/API responses | ![](https://img.shields.io/badge/-JSON-ffb300?style=flat-square) |
| **curl** | Reproducción rápida fuera de proxy | ![](https://img.shields.io/badge/-HTTP-00d4ff?style=flat-square) |

---

## 🎯 Flujo Recomendado

### `[01]` Reconocimiento

1. Definir alcance en Caido con `Scopes`.
2. Navegar app y capturar tráfico en `HTTP History`.

### `[02]` Identificación

3. Localizar parámetros controlados, acciones sensibles y sinks.
4. Mandar requests útiles a `Replay`.

### `[03]` Explotación

5. Probar variaciones manuales por contexto.
6. Escalar a `Automate` si hace falta fuzzing o wordlists.

### `[04]` Documentación

7. Guardar: payload válido, precondiciones, respuesta esperada e impacto.

> [!IMPORTANT]
> Repetir solo en labs controlados. Cada técnica tiene archivo propio con payloads, flujo y checklist.

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

1. `CAIDO.md` — setup y flujo base
2. `SQLi.md`
3. `XSS.md`
4. `CSRF.md`
5. `Path_Traversal.md`
6. `Command_Injection.md`
7. `File_Upload.md`
8. `SSRF.md`

---

## 🔗 Referencias

- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/)
- [DVWA](https://github.com/digininja/DVWA)
- [Caido Documentation](https://docs.caido.io)
