<div align="center">

# 💥 Offensive Security
### Cracking de Contraseñas — Hashcat & John the Ripper

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Password%20Cracking-a855f7?style=for-the-badge&logo=hackthebox&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-00d4ff?style=for-the-badge&logo=linux&logoColor=white)

</div>

---

> **Password Cracking:** proceso de recuperar contraseñas a partir de hashes capturados. Hashcat usa **GPU** para máxima velocidad. John the Ripper usa **CPU** y es ideal para formatos especiales y archivos cifrados.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🔍 Identificar el Tipo de Hash](#-identificar-el-tipo-de-hash) |
| 02 | [⚡ Hashcat — Referencia de Modos de Ataque](#-hashcat--referencia-de-modos-de-ataque) |
| 03 | [⚡ Hashcat — Tipos de Hash](#-hashcat--tipos-de-hash) |
| 04 | [⚡ Hashcat — Máscaras & Charsets](#-hashcat--máscaras--charsets) |
| 05 | [⚡ Hashcat — Ejemplos por Escenario](#-hashcat--ejemplos-por-escenario) |
| 06 | [🔨 John the Ripper — Modos de Ataque](#-john-the-ripper--modos-de-ataque) |
| 07 | [🔨 John the Ripper — Utilidades 2john](#-john-the-ripper--utilidades-2john) |
| 08 | [🔨 John the Ripper — Ejemplos por Escenario](#-john-the-ripper--ejemplos-por-escenario) |
| 09 | [📊 Hashcat vs John — Comparativa](#-hashcat-vs-john--comparativa) |

---

## 🔍 Identificar el Tipo de Hash

```bash
# Con hashid
hashid '<hash>'
hashid -m '<hash>'          # Con número de modo Hashcat

# Con hash-identifier
hash-identifier '<hash>'

# Con name-that-hash
nth --text '<hash>'

# Online
# https://hashes.com/en/tools/hash_identifier
```

**Ejemplos de hashes comunes:**

| Hash | Ejemplo | Herramienta |
|------|---------|-------------|
| MD5 | `5f4dcc3b5aa765d61d8327deb882cf99` | `hashid`, `name-that-hash` |
| SHA1 | `5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8` | — |
| NTLM | `8846f7eaee8fb117ad06bdd830b7586c` | Kali: `python3 /usr/share/doc/python3-impacket/examples/secretsdump.py` |
| bcrypt | `$2a$12$...` | — |
| SHA-256 | `5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8` | — |

---

## ⚡ Hashcat — Referencia de Modos de Ataque

![Tool](https://img.shields.io/badge/Tool-Hashcat-ff6b00?style=flat-square&logo=linux&logoColor=white)
![Accel](https://img.shields.io/badge/GPU-Accelerated-00ff88?style=flat-square)

**Sintaxis:**
```bash
hashcat -a <modo> -m <tipo_hash> <archivo_hash> [wordlist/máscara]
```

| Flag `-a` | Modo | Descripción |
|-----------|------|-------------|
| `0` | Dictionary | Wordlist directa |
| `1` | Combination | Combina 2 wordlists |
| `3` | Brute-Force / Mask | Genera contraseñas por patrón |
| `6` | Hybrid wordlist+mask | Wordlist + sufijo de máscara |
| `7` | Hybrid mask+wordlist | Prefijo de máscara + wordlist |

### Flags Principales

| Flag | Descripción |
|------|-------------|
| `-m <N>` | Tipo de hash |
| `-a <N>` | Modo de ataque |
| `-o <file>` | Guardar resultados |
| `--show` | Mostrar hashes ya crackeados |
| `-r <rules>` | Aplicar archivo de reglas |
| `-O` | Kernel optimizado (más rápido) |
| `-w <1-4>` | Perfil de carga GPU (1=bajo, 4=máximo) |
| `--session <name>` | Nombrar sesión |
| `--restore` | Reanudar sesión |
| `--increment` | Modo incremental de máscara |
| `--username` | Archivo con formato `usuario:hash` |
| `--status` | Mostrar estado durante ataque |
| `--force` | Ignorar warnings de GPU |

---

## ⚡ Hashcat — Tipos de Hash

| Modo `-m` | Hash Type | Ejemplo de uso |
|-----------|-----------|----------------|
| `0` | MD5 | Contraseñas web, bases de datos |
| `100` | SHA1 | Contraseñas legadas |
| `1000` | NTLM | Hashes Windows (SAM, NTDS) |
| `1400` | SHA2-256 | Contraseñas modernas |
| `1700` | SHA2-512 | Linux `/etc/shadow` (sha512) |
| `1800` | `sha512crypt` | Linux `/etc/shadow` |
| `3000` | LM | Hashes Windows legados |
| `3200` | bcrypt | Contraseñas web modernas |
| `5500` | NetNTLMv1 | Captura MITM |
| `5600` | NetNTLMv2 | Captura Responder |
| `13100` | Kerberoast (TGS) | Kerberoasting AD |
| `18200` | AS-REP Roast | AS-REP Roasting AD |
| `22000` | WPA2 | Handshakes WiFi |
| `13600` | ZIP | Archivos ZIP cifrados |
| `9600` | MS Office 2013 | Documentos cifrados |
| `16500` | JWT | JSON Web Tokens |

---

## ⚡ Hashcat — Máscaras & Charsets

### Charsets Integrados

| Símbolo | Charset |
|---------|---------|
| `?l` | `abcdefghijklmnopqrstuvwxyz` |
| `?u` | `ABCDEFGHIJKLMNOPQRSTUVWXYZ` |
| `?d` | `0123456789` |
| `?s` | `!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~` |
| `?a` | `?l?u?d?s` (todos) |
| `?h` | `0123456789abcdef` |
| `?H` | `0123456789ABCDEF` |

### Ejemplos de Máscaras

```bash
?u?l?l?l?l?d?d           # Capital + 4 minúsculas + 2 dígitos → "Admin12"
?d?d?d?d?d?d?d?d          # 8 dígitos → "12345678"
?u?l?l?l?l?l?l?l?d        # 1 mayúscula + 7 minúsculas + 1 dígito
Password?d?d?d?d           # Literal + 4 dígitos → "Password2024"
```

---

## ⚡ Hashcat — Ejemplos por Escenario

### `[01]` Ataque de Diccionario (modo 0)

```bash
# NTLM con rockyou
hashcat -a 0 -m 1000 hashes.txt /usr/share/wordlists/rockyou.txt

# MD5 con reglas best64
hashcat -a 0 -m 0 hashes.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule

# SHA-256 con múltiples wordlists
hashcat -a 0 -m 1400 hashes.txt wordlist1.txt wordlist2.txt

# Archivo usuario:hash
hashcat -a 0 -m 1000 --username hashes.txt /usr/share/wordlists/rockyou.txt
```

### `[02]` Ataque de Máscara / Brute-Force (modo 3)

```bash
# 8 caracteres alfanuméricos
hashcat -a 3 -m 1000 hashes.txt ?a?a?a?a?a?a?a?a

# Patrón específico
hashcat -a 3 -m 1000 hashes.txt ?u?l?l?l?l?l?l?l?d

# Charset personalizado (-1)
hashcat -a 3 -m 1000 hashes.txt -1 ?d?s ?u?l?l?l?l?l?l?l?1

# Incremental (3 a 8 chars)
hashcat -a 3 -m 1000 hashes.txt ?a?a?a?a --increment --increment-min 3
```

### `[03]` Ataque Combinado (modo 1)

```bash
hashcat -a 1 -m 1000 hashes.txt wordlist1.txt wordlist2.txt
```

### `[04]` Hybrid — Wordlist + Máscara (modo 6)

```bash
# Palabra + 4 dígitos al final
hashcat -a 6 -m 1000 hashes.txt wordlist.txt ?d?d?d?d

# Palabra + 2 dígitos + símbolo
hashcat -a 6 -m 1000 hashes.txt wordlist.txt ?d?d?s
```

### `[05]` Escenarios AD / Windows

```bash
# NTLM (SAM dump)
hashcat -a 0 -m 1000 ntlm.txt /usr/share/wordlists/rockyou.txt

# NetNTLMv2 (Responder capture)
hashcat -a 0 -m 5600 netntlmv2.txt /usr/share/wordlists/rockyou.txt

# Kerberoasting
hashcat -a 0 -m 13100 kerberoast.txt /usr/share/wordlists/rockyou.txt

# AS-REP Roasting
hashcat -a 0 -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt
```

### `[06]` Archivos Cifrados

```bash
# ZIP
hashcat -a 0 -m 13600 hash_zip.txt /usr/share/wordlists/rockyou.txt

# WPA2 (cap file → hccapx primero)
hashcat -a 0 -m 22000 handshake.hc22000 /usr/share/wordlists/rockyou.txt
```

### `[07]` Gestión de Sesiones

```bash
# Crear sesión nombrada
hashcat -a 0 -m 1000 hashes.txt rockyou.txt --session crack_ntlm

# Pausar: CTRL+C
# Reanudar
hashcat --restore --session crack_ntlm

# Ver resultados ya crackeados
hashcat -m 1000 hashes.txt --show
```

---

## 🔨 John the Ripper — Modos de Ataque

![Tool](https://img.shields.io/badge/Tool-John%20the%20Ripper-5865f2?style=flat-square&logo=linux&logoColor=white)

**Sintaxis:**
```bash
john [opciones] <archivo_hash>
```

### Flags Principales

| Flag | Descripción |
|------|-------------|
| `--wordlist=<file>` | Modo diccionario |
| `--rules` | Aplicar reglas de mutación |
| `--rules=all` | Todas las reglas |
| `--format=<fmt>` | Formato de hash explícito |
| `--list=formats` | Listar todos los formatos soportados |
| `--incremental` | Brute force incremental |
| `--mask=<patrón>` | Ataque por máscara |
| `--show` | Mostrar passwords crackeados |
| `--fork=<N>` | Usar N procesos CPU |
| `--session=<name>` | Nombrar sesión |
| `--restore=<name>` | Reanudar sesión |
| `--pot=<file>` | Archivo potfile alternativo |

### Modos de Ataque

```bash
# Single crack (más rápido — usa variaciones del nombre)
john --single hash.txt

# Diccionario
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt

# Diccionario + mutaciones
john --wordlist=/usr/share/wordlists/rockyou.txt --rules hash.txt

# Brute force incremental
john --incremental hash.txt

# Formato específico
john --wordlist=/usr/share/wordlists/rockyou.txt --format=NT hash.txt

# Mostrar crackeados
john --show hash.txt
john --show --format=NT hash.txt

# Multi-core
john --wordlist=rockyou.txt hash.txt --fork=4
```

---

## 🔨 John the Ripper — Utilidades 2john

### Linux — `/etc/shadow`

```bash
# Combinar passwd y shadow
unshadow /etc/passwd /etc/shadow > combined.txt
john --wordlist=/usr/share/wordlists/rockyou.txt combined.txt
```

### Windows — SAM

```bash
# Extraer hashes SAM (desde sistema live con privilegios o desde imagen)
samdump2 SYSTEM SAM > sam_hashes.txt
john --format=NT sam_hashes.txt --wordlist=rockyou.txt
```

### Archivos ZIP

```bash
zip2john archivo.zip > hash_zip.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash_zip.txt
```

### Archivos RAR

```bash
rar2john archivo.rar > hash_rar.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash_rar.txt
```

### PDF

```bash
pdf2john encrypted.pdf > hash_pdf.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash_pdf.txt
```

### 7-Zip

```bash
7z2john archivo.7z > hash_7z.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash_7z.txt
```

### SSH Private Keys

```bash
ssh2john id_rsa > hash_ssh.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash_ssh.txt
```

### KeePass

```bash
keepass2john database.kdbx > hash_keepass.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash_keepass.txt
```

### PGP / GPG

```bash
gpg2john private.key > hash_gpg.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash_gpg.txt
```

---

## 🔨 John the Ripper — Ejemplos por Escenario

### `[01]` NTLM Windows

```bash
john --format=NT --wordlist=/usr/share/wordlists/rockyou.txt ntlm_hashes.txt
john --format=NT --show ntlm_hashes.txt
```

### `[02]` Linux SHA-512 (`/etc/shadow`)

```bash
unshadow /etc/passwd /etc/shadow > shadow_combined.txt
john --wordlist=/usr/share/wordlists/rockyou.txt shadow_combined.txt
```

### `[03]` Kerberoasting

```bash
john --format=krb5tgs --wordlist=/usr/share/wordlists/rockyou.txt kerberoast_hashes.txt
```

### `[04]` Mutaciones de Palabras

```bash
# Generar lista mutada para usar en otros tools
john --wordlist=words.txt --rules --stdout > mutated.txt
john --wordlist=words.txt --rules=all --stdout > mutated_all.txt
```

### `[05]` Gestión de Sesiones

```bash
# Crear sesión
john --session=crack_linux --wordlist=rockyou.txt shadow.txt

# Reanudar
john --restore=crack_linux
```

---

## 📊 Hashcat vs John — Comparativa

| Criterio | ⚡ Hashcat | 🔨 John |
|----------|-----------|---------|
| **Velocidad** | Muy alta (GPU) | Moderada (CPU) |
| **GPU** | ✅ Nativo | ⚠️ Limitado |
| **Formatos** | 350+ tipos de hash | 400+ formatos |
| **Archivos cifrados** | ZIP, Office, WPA | ZIP, RAR, PDF, SSH, KeePass |
| **2john utilities** | ❌ No | ✅ Sí |
| **Reglas** | ✅ Sí (`-r`) | ✅ Sí (`--rules`) |
| **Mejor para** | NTLM, NetNTLM, WPA, AD | SSH keys, archivos, Linux shadow |

> [!TIP]
> **Workflow recomendado:**
> 1. `hashid` / `name-that-hash` → identificar hash
> 2. Ataque diccionario con `rockyou.txt`
> 3. Diccionario + reglas (`best64.rule`)
> 4. Máscara basada en política de contraseñas conocida
> 5. Brute force incremental (último recurso)

---

> [!TIP]
> **Wordlists & Reglas:**
> - `/usr/share/wordlists/rockyou.txt`
> - `/usr/share/seclists/Passwords/`
> - Reglas hashcat: `/usr/share/hashcat/rules/best64.rule`
> - Reglas hashcat: `/usr/share/hashcat/rules/d3ad0ne.rule`
> - Reglas john: `/etc/john/john.conf`
