<div align="center">

# 📤 File Upload
### Subida de Archivos y Bypass de Validaciones

</div>

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | File Upload |
| **Juice Shop** | Upload Type, Upload Size |
| **PortSwigger** | File upload vulnerabilities |

---

## 🛠️ Herramientas

- **Caido**: `HTTP History`, `Replay`
- `curl`
- `ffuf`
- `exiftool` si pruebas metadata

---

## 🔍 Qué Revisar

- extensión permitida
- `Content-Type`
- nombre archivo
- ruta final de acceso
- validación server-side vs client-side
- tamaño máximo

---

## 🧪 Casos de Prueba

### Extensiones

```text
shell.php
shell.php.jpg
shell.phtml
shell.php%00.jpg
```

### MIME

```text
Content-Type: image/jpeg
Content-Type: application/octet-stream
```

### Nombres

```text
test.php
test.php.jpg
test.PHP
test..php
```

---

## 🔁 Flujo con Caido

1. Subir archivo legítimo.
2. Capturar request multipart.
3. En `Replay`, cambiar:
   - filename
   - `Content-Type`
   - contenido
4. Reenviar.
5. Ver:
   - respuesta
   - ruta pública
   - si archivo ejecuta o solo almacena

---

## ⚙️ Comandos Útiles

```bash
curl -i -X POST http://target/upload \
  -F "file=@test.php.jpg;type=image/jpeg"
```

---

## 🧠 Bypass Típico en Labs

| Control | Qué probar |
|---------|------------|
| solo extensión | doble extensión / case |
| solo MIME | falsificar `Content-Type` |
| validación JS | enviar request directo |
| blacklist | variantes `.phtml`, `.php5` |
| ruta accesible | pedir archivo subido directo |

---

## 🧭 Ruta de Práctica

1. DVWA File Upload
2. PortSwigger: unrestricted upload
3. PortSwigger: Content-Type bypass
4. PortSwigger: blacklist bypass
5. Juice Shop: Upload Type / Upload Size

---

## 📝 Checklist

- request multipart guardado
- validación identificada
- bypass reproducido
- ruta de acceso confirmada en lab
