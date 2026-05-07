<div align="center">

# 📤 File Upload
### Bypass de Validaciones y Subida de Archivos Maliciosos

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-File%20Upload-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **File Upload:** explotación de funcionalidades de carga de archivos con validaciones débiles para subir código ejecutable al servidor.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Qué Revisar](#-qué-revisar) |
| 04 | [🧪 Casos de Prueba](#-casos-de-prueba) |
| 05 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 06 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 07 | [🧠 Bypass Típico en Labs](#-bypass-típico-en-labs) |
| 08 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 09 | [📝 Checklist](#-checklist) |

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | File Upload |
| **Juice Shop** | Upload Type, Upload Size |
| **PortSwigger** | File upload vulnerabilities |

---

## 🛠️ Herramientas

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-ffuf-ff6b00?style=flat-square)

| Herramienta | Uso |
|-------------|-----|
| **Caido** | `HTTP History`, `Replay` — interceptar y modificar multipart |
| **curl** | Subida directa con MIME falsificado |
| **ffuf** | Fuzzing de extensiones aceptadas |
| **exiftool** | Insertar payload en metadata de imagen si aplica |

---

## 🔍 Qué Revisar

![Context](https://img.shields.io/badge/Análisis-Validaciones-ff6b00?style=flat-square)

### `[01]` Controles a identificar

- extensión permitida (whitelist / blacklist)
- `Content-Type` validado server-side
- nombre de archivo sanitizado
- ruta final de acceso al archivo subido
- validación client-side vs server-side
- tamaño máximo permitido

### `[02]` Diferencia clave

> [!IMPORTANT]
> Validación client-side (JavaScript) es bypasseable enviando el request directamente con Caido o curl. Validación server-side requiere bypass de extensión o MIME.

---

## 🧪 Casos de Prueba

![Context](https://img.shields.io/badge/Payload-Extensiones%20y%20MIME-a855f7?style=flat-square)

### `[01]` Extensiones

```text
shell.php
shell.php.jpg
shell.phtml
shell.php%00.jpg
shell.PHP
shell..php
```

### `[02]` MIME type

```text
Content-Type: image/jpeg
Content-Type: application/octet-stream
```

> [!NOTE]
> Probar primero extensión directa `.php`. Si bloqueada, probar doble extensión, null byte y variantes de case antes de cambiar MIME.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Subir archivo legítimo

Subir imagen válida. Verificar que la app acepta y devuelve ruta.

### `[02]` Capturar request multipart

Localizar en `HTTP History`. Mandar a `Replay`.

### `[03]` Modificar en Replay

Cambiar:

- `filename` en Content-Disposition
- `Content-Type` del part
- contenido del archivo

### `[04]` Reenviar y verificar

Buscar en response:

- ruta de acceso al archivo subido
- si archivo ejecuta o solo almacena
- mensaje de error del servidor

### `[05]` Acceder al archivo subido

Si hay ruta pública, hacer GET al archivo para confirmar ejecución.

> [!TIP]
> Si la app no devuelve la ruta, usar `Automate` o `ffuf` para fuzzing de paths predecibles: `/uploads/`, `/files/`, `/media/`.

---

## ⚙️ Comandos Útiles

![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

```bash
# Subir con MIME falsificado
curl -i -X POST http://target/upload \
  -F "file=@test.php.jpg;type=image/jpeg"
```

---

## 🧠 Bypass Típico en Labs

| Control | Qué probar |
|---------|------------|
| Solo extensión | doble extensión / case (`shell.php.jpg`, `shell.PHP`) |
| Solo MIME | falsificar `Content-Type: image/jpeg` |
| Validación JavaScript | enviar request directo via Caido/curl |
| Blacklist de extensiones | variantes `.phtml`, `.php5`, `.php7` |
| Ruta de archivo accesible | GET directo a la ruta devuelta |

---

## 🧭 Ruta de Práctica

1. DVWA File Upload
2. PortSwigger: unrestricted file upload
3. PortSwigger: Content-Type bypass
4. PortSwigger: blacklist bypass
5. Juice Shop: Upload Type / Upload Size

---

## 📝 Checklist

- [ ] request multipart guardado en Caido
- [ ] validación identificada (client-side / server-side)
- [ ] bypass reproducido
- [ ] ruta de acceso al archivo confirmada en lab
