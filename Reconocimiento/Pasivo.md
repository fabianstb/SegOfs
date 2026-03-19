<div align="center">

# 🛡️ Offensive Security
### Passive Reconnaissance

![Status](https://img.shields.io/badge/Status-Active-00d4ff?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-Passive%20Recon-00ff88?style=for-the-badge&logo=hackthebox&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-ff3c6e?style=for-the-badge&logo=linux&logoColor=white)

</div>

---

> **¿Qué es el Reconocimiento Pasivo?**
> Esta fase se enfoca en recolectar la mayor cantidad de información posible sobre el objetivo **sin interactuar directamente** con sus sistemas principales, evadiendo la detección temprana por parte de los Blue Teams (IDS/IPS/SIEM).

> [!WARNING]
> **Aviso Legal y Ético:** Todas las herramientas y comandos documentados en este repositorio deben ser utilizados única y exclusivamente en entornos donde se posea **autorización explícita por escrito (Reglas de Enfrentamiento / RoE).**

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🗂️ Resumen de Herramientas](#️-resumen-de-herramientas) |
| 02 | [🔬 DNSRecon](#-dnsrecon--la-navaja-suiza-del-dns) |
| 03 | [🌐 OWASP Amass](#-owasp-amass--inteligencia-de-activos) |
| 04 | [⚡ Subfinder & Sublist3r](#-subfinder--sublist3r) |
| 05 | [🔀 dnsx](#-dnsx--resolución-masiva-y-filtrado) |
| 06 | [💻 PowerShell / LotL](#-powershell--living-off-the-land) |
| 07 | [🗺️ ASNs](#️-asns--mapeo-de-rangos-ip) |
| 08 | [🔍 Descubrimiento de Dominios](#-descubrimiento-de-dominios) |
| 09 | [🗂️ Descubrimiento de Subdominios](#️-descubrimiento-de-subdominios) |
| 10 | [🖥️ Virtual Hosts (VHosts)](#️-virtual-hosts-vhosts) |
| 11 | [🔑 Credenciales & Secretos](#-credenciales--secretos-filtrados) |
| 12 | [☁️ Cloud Assets](#️-cloud-assets-públicos) |
| 13 | [📊 Recapitulación](#-recapitulación-del-proceso) |

---

## 🗂️ Resumen de Herramientas

| Herramienta | Categoría | Enfoque | Badge |
|-------------|-----------|---------|-------|
| **DNSRecon** | Enumeración DNS | Registros, AXFR, Brute-force, DNSSEC walk | ![](https://img.shields.io/badge/-DNS-00d4ff?style=flat-square) |
| **OWASP Amass** | OSINT / Descubrimiento | Mapeo profundo de activos, subdominios y ASNs | ![](https://img.shields.io/badge/-OSINT-00ff88?style=flat-square) |
| **Subfinder** | OSINT / Descubrimiento | Alta velocidad, fuentes pasivas múltiples | ![](https://img.shields.io/badge/-OSINT-00ff88?style=flat-square) |
| **dnsx** | Resolución Masiva | Filtrado, verificación y enrutamiento DNS rápido | ![](https://img.shields.io/badge/-DNS-00d4ff?style=flat-square) |
| **BBOT** | OSINT / Automatización | Enumeración modular con agregación de ASNs | ![](https://img.shields.io/badge/-AUTO-ffb300?style=flat-square) |
| **massdns** | DNS Brute-Force | Resolución masiva de alta velocidad | ![](https://img.shields.io/badge/-BRUTE-ff3c6e?style=flat-square) |
| **shuffledns** | DNS Brute-Force | Wrapper de massdns con soporte wildcard | ![](https://img.shields.io/badge/-BRUTE-ff3c6e?style=flat-square) |
| **ffuf** | Virtual Hosts / CORS | Fuzzing de Host headers y detección de VHosts | ![](https://img.shields.io/badge/-FUZZ-a855f7?style=flat-square) |
| **PowerShell** | Nativo Windows | Living off the Land para internal recon | ![](https://img.shields.io/badge/-LotL-5865f2?style=flat-square) |

---

## 🔬 DNSRecon — La Navaja Suiza del DNS

![Tool](https://img.shields.io/badge/Tool-DNSRecon-00d4ff?style=flat-square&logo=python&logoColor=white)
![Lang](https://img.shields.io/badge/Language-Python-3776ab?style=flat-square&logo=python&logoColor=white)

Herramienta escrita en Python, indispensable para la enumeración de registros, transferencias de zona y recolección de información del espacio de nombres.

### `[01]` Enumeración Estándar

Registros SRV, SOA, NS, MX, A, AAAA del dominio objetivo.

```bash
dnsrecon -d example.com
```

### `[02]` Transferencia de Zona (AXFR)

> [!IMPORTANT]
> Si está mal configurado, revelará **toda la infraestructura** del objetivo. Siempre reportar si es vulnerable.

```bash
dnsrecon -d example.com -t axfr
```

### `[03]` Fuerza Bruta de Subdominios

Diccionario personalizado para descubrir hosts no listados públicamente.

```bash
dnsrecon -d example.com \
  -D /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  -t brt
```

### `[04]` Búsqueda Inversa por Rango (Reverse Lookup)

Mapea un bloque CIDR para ver qué dominios resuelven a esas IPs.

```bash
dnsrecon -r 192.168.1.0/24
```

### `[05]` Expansión de TLD

Busca el mismo dominio a través de diferentes terminaciones (`.net`, `.org`, `.co.uk`).

```bash
dnsrecon -d example -t tld
```

### `[06]` Caminata de Zona DNSSEC (Zone Walk)

Extrae registros de una zona asegurada con DNSSEC explotando registros NSEC.

```bash
dnsrecon -d example.com -z
```

### `[07]` Salida Estructurada JSON

Ideal para integrar resultados en pipelines automatizados o bases de datos.

```bash
dnsrecon -d example.com -j resultados_dnsrecon.json
```

---

## 🌐 OWASP Amass — Inteligencia de Activos

![Tool](https://img.shields.io/badge/Tool-Amass-00ff88?style=flat-square&logo=owasp&logoColor=white)

El rey del descubrimiento pasivo profundo. Utiliza técnicas de scraping, APIs y bases de datos WHOIS históricas.

### `[01]` Descubrimiento Pasivo Total

Busca subdominios usando todas las fuentes pasivas disponibles **sin enviar tráfico al objetivo**.

```bash
amass enum -passive -d example.com
```

### `[02]` Inteligencia Inversa (WHOIS)

Encuentra dominios raíz adicionales que pertenezcan a la misma organización.

```bash
amass intel -d example.com -whois
```

### `[03]` Descubrimiento de ASN

```bash
# Por nombre de organización
amass intel -org tesla

# Por ASNs específicos
amass intel -asn 8911,50313,394161
```

---

## ⚡ Subfinder & Sublist3r

![Tool](https://img.shields.io/badge/Tool-Subfinder-00ff88?style=flat-square&logo=go&logoColor=white)
![Tool](https://img.shields.io/badge/Tool-Sublist3r-00ff88?style=flat-square&logo=python&logoColor=white)

Herramientas diseñadas para consultar decenas de motores de búsqueda y bases de datos públicas en segundos.

### `[01]` Ejecución Silenciosa — Subfinder

Extrae subdominios mostrando únicamente los resultados. Ideal para encadenar con otros comandos (piping).

```bash
subfinder -d example.com -silent
```

### `[02]` Motores Específicos — Sublist3r

```bash
sublist3r -d example.com -e google,yahoo,virustotal -t 10
```

---

## 🔀 dnsx — Resolución Masiva y Filtrado

![Tool](https://img.shields.io/badge/Tool-dnsx-00d4ff?style=flat-square&logo=go&logoColor=white)
![Author](https://img.shields.io/badge/By-ProjectDiscovery-ff3c6e?style=flat-square)

Toolkit DNS rápido y multipropósito diseñado para manejar listas inmensas de subdominios.

### `[01]` Verificación de Subdominios Vivos

Verifica cuáles subdominios resuelven actualmente a una IP real.

```bash
cat subdominios_crudos.txt | dnsx -a -resp
```

### `[02]` Extracción de CNAME — Subdomain Takeover Recon

Identifica registros CNAME apuntando a servicios de terceros (AWS, GitHub Pages, Azure) potencialmente vulnerables.

```bash
cat subdominios_crudos.txt | dnsx -cname -resp
```

---

## 💻 PowerShell — Living off the Land

![Platform](https://img.shields.io/badge/Platform-Windows-0078d4?style=flat-square&logo=windows&logoColor=white)
![Technique](https://img.shields.io/badge/Technique-LotL-5865f2?style=flat-square)

Para pentesting en entornos Windows (**Assumed Breach / Internal Recon**) sin instalar herramientas de terceros.

### `[01]` Enumeración de Servicios Internos (SRV)

Descubre controladores de dominio, servidores de catálogo global o servicios LDAP.

```powershell
Resolve-DnsName -Name _ldap._tcp.dc._msdcs.dominio.local -Type SRV
```

### `[02]` Resolución Básica y MX

```powershell
Resolve-DnsName -Name example.com -Type MX
```

---

## 🗺️ ASNs — Mapeo de Rangos IP

Un **Autonomous System Number (ASN)** es un identificador único asignado por la IANA a un sistema autónomo que administra bloques de IPs. Mapear los ASNs del objetivo permite descubrir **toda su superficie de red**.

### Recursos Online

| Plataforma | URL | API | Región |
|------------|-----|-----|--------|
| Hurricane Electric BGP | [bgp.he.net](https://bgp.he.net/) | ✅ Free | Global |
| BGPView | [bgpview.io](https://bgpview.io/) | ✅ Free | Global |
| IPInfo | [ipinfo.io](https://ipinfo.io/) | ✅ Free | Global |
| ASN Lookup | [asnlookup.com](http://asnlookup.com/) | ✅ Free | Global |
| IPv4Info | [ipv4info.com](http://ipv4info.com/) | ❌ | Global |
| AFRINIC | [afrinic.net](https://www.afrinic.net/) | — | África |
| ARIN | [arin.net](https://www.arin.net/) | — | Norte América |
| APNIC | [apnic.net](https://www.apnic.net/) | — | Asia |
| LACNIC | [lacnic.net](https://www.lacnic.net/) | — | Latinoamérica |
| RIPE NCC | [ripe.net](https://www.ripe.net/) | — | Europa |

### BBOT — Output Automático de ASNs

```bash
bbot -t tesla.com -f subdomain-enum
```

```
[INFO] bbot.modules.asn: | AS394161 | 8.244.131.0/24  | 5 | TESLA     | Tesla Motors, Inc.  | US |
[INFO] bbot.modules.asn: | AS16509  | 54.148.0.0/15   | 4 | AMAZON-02 | Amazon.com, Inc.    | US |
[INFO] bbot.modules.asn: | AS394161 | 8.45.124.0/24   | 3 | TESLA     | Tesla Motors, Inc.  | US |
[INFO] bbot.modules.asn: | AS3356   | 8.32.0.0/12     | 1 | LEVEL3    | Level 3 Parent, LLC | US |
```

---

## 🔍 Descubrimiento de Dominios

### Reverse DNS

Con los rangos IP identificados, realizar lookups inversos para encontrar más dominios.

```bash
# Rango completo con servidor DNS específico
dnsrecon -r <DNS_Range> -n <IP_DNS>

# Usando Cloudflare como resolver
dnsrecon -r 157.240.221.35/24 -n 1.1.1.1

# Usando Google como resolver
dnsrecon -r 157.240.221.35/24 -n 8.8.8.8
```

> [!NOTE]
> El administrador debe haber habilitado manualmente el registro PTR. Para rangos grandes, `massdns` y `dnsx` son ideales para automatizar. También se puede usar [ptrarchive.com](http://ptrarchive.com/).

### Reverse Whois (Loop)

Los registros WHOIS contienen organización, dirección, emails y teléfonos. Las búsquedas inversas por esos campos revelan más activos relacionados.

**Herramientas gratuitas:**

| Herramienta | URL |
|-------------|-----|
| ViewDNS | [viewdns.info/reversewhois](https://viewdns.info/reversewhois/) |
| DomainEye | [domaineye.com/reverse-whois](https://domaineye.com/reverse-whois) |
| ReverseWhois | [reversewhois.io](https://www.reversewhois.io/) |
| Whoxy | [whoxy.com](https://www.whoxy.com/) |

**Herramientas de pago:**

| Herramienta | URL |
|-------------|-----|
| SecurityTrails | [securitytrails.com](https://securitytrails.com/) |
| WhoisXML API | [drs.whoisxmlapi.com](https://drs.whoisxmlapi.com/reverse-whois-search) |
| WhoisFreaks | [whoisfreaks.com](https://whoisfreaks.com/) |

```bash
# Automatización con Amass
amass intel -d tesla.com -whois
```

### Certificate Transparency Logs

```bash
# crt.sh — función bash
crt(){
  curl -s "https://crt.sh/?q=%25.$1" \
    | grep -oE "[\.a-zA-Z0-9-]+\.$1" \
    | sort -u
}
crt tesla.com
```

**Recursos CT:**

| Recurso | URL |
|---------|-----|
| crt.sh | [crt.sh](https://crt.sh/) |
| CertSpotter | [certspotter.com](https://certspotter.com/) |
| Censys | [search.censys.io](https://search.censys.io/) |
| Chaos | [chaos.projectdiscovery.io](https://chaos.projectdiscovery.io/) |

### Favicon Hash

```bash
# Generar lista de targets
cat my_targets.txt | xargs -I %% bash -c 'echo "http://%%/favicon.ico"' > targets.txt
python3 favihash.py -f https://target/favicon.ico -t targets.txt -s

# Escala con httpx
httpx -l targets.txt -favicon

# Pivot en Shodan
shodan search org:"Target" http.favicon.hash:116323821 \
  --fields ip_str,port --separator " " | awk '{print $1":"$2}'
```

Script Python para calcular el hash:

```python
import mmh3
import requests
import codecs

def fav_hash(url):
    response = requests.get(url)
    favicon = codecs.encode(response.content, "base64")
    fhash = mmh3.hash(favicon)
    print(f"{url} : {fhash}")
    return fhash
```

---

## 🗂️ Descubrimiento de Subdominios

### BBOT — Suite Completa

```bash
# Enumeración completa
bbot -t tesla.com -f subdomain-enum

# Solo fuentes pasivas
bbot -t tesla.com -f subdomain-enum -rf passive

# Subdominios + port scan + screenshots
bbot -t tesla.com -f subdomain-enum -m naabu gowitness -n my_scan -o .
```

### Suite OSINT Principal

```bash
# Amass
amass enum [-active] [-ip] -d tesla.com
amass enum -d tesla.com | grep tesla.com

# Subfinder
./subfinder-linux-amd64 -d tesla.com -silent

# Findomain
./findomain-linux -t tesla.com --quiet

# OneForAll
python3 oneforall.py --target tesla.com run

# assetfinder
assetfinder --subs-only tesla.com

# vita
vita -d tesla.com
```

### theHarvester — Multi-motor

```bash
theHarvester -d tesla.com -b "anubis, baidu, bing, binaryedge, bingapi, \
bufferoverun, censys, certspotter, crtsh, dnsdumpster, duckduckgo, fullhunt, \
github-code, google, hackertarget, hunter, intelx, linkedin, omnisint, otx, \
pentesttools, projectdiscovery, qwant, rapiddns, rocketreach, securityTrails, \
sublist3r, threatcrowd, threatminer, trello, urlscan, virustotal, yahoo, zoomeye"
```

### APIs Gratuitas

```bash
# Sonar / Crobat
curl https://sonar.omnisint.io/subdomains/tesla.com | jq -r ".[]"

# JLDC API
curl https://jldc.me/anubis/subdomains/tesla.com | jq -r ".[]"

# RapidDNS
rapiddns(){
  curl -s "https://rapiddns.io/subdomain/$1?full=1" \
    | grep -oE "[\.a-zA-Z0-9-]+\.$1" \
    | sort -u
}
rapiddns tesla.com

# GAU (AlienVault OTX + Wayback Machine + Common Crawl)
gau --subs tesla.com | cut -d "/" -f 3 | sort -u

# SubDomainizer (extrae subdominios de archivos JS)
python3 SubDomainizer.py -u https://tesla.com | grep tesla.com

# Shodan
shodan domain <domain>
shodan search "http.html:help.domain.com"

# Censys
export CENSYS_API_ID=...
export CENSYS_API_SECRET=...
python3 censys-subdomain-finder.py tesla.com
```

### DNS Brute-Force

> [!TIP]
> **Wordlists recomendadas:**
> - [jhaddix — all.txt](https://gist.github.com/jhaddix/86a06c5dc309d08580a018c66354a056)
> - [Assetnote — best-dns-wordlist.txt](https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt)
> - [SecLists — Discovery/DNS](https://github.com/danielmiessler/SecLists/tree/master/Discovery/DNS)
>
> **Resolvers confiables:** [trickest/resolvers](https://raw.githubusercontent.com/trickest/resolvers/main/resolvers-trusted.txt)

```bash
# massdns — muy rápido
sed 's/$/.domain.com/' subdomains.txt > bf-subdomains.txt
./massdns -r resolvers.txt -w /tmp/results.txt bf-subdomains.txt
grep -E "tesla.com. [0-9]+ IN A .+" /tmp/results.txt

# gobuster
gobuster dns -d mysite.com -t 50 -w subdomains.txt

# shuffledns (massdns wrapper + wildcard support)
shuffledns -d example.com -list example-subdomains.txt -r resolvers.txt

# puredns
puredns bruteforce all.txt domain.com

# aiodnsbrute (async)
aiodnsbrute -r resolvers -w wordlist.txt -vv -t 1024 domain.com
```

### Segunda Ronda — Permutaciones

```bash
# dnsgen
cat subdomains.txt | dnsgen -

# gotator
gotator -sub subdomains.txt -silent [-perm /tmp/words-permutations.txt]

# alterx
alterx -d tesla.com

# dmut
cat subdomains.txt | dmut -d /tmp/words-permutations.txt -w 100 \
    --dns-errorLimit 10 --use-pb --verbose -s /tmp/resolvers-trusted.txt

# subzuf
echo www | subzuf facebook.com
```

---

## 🖥️ Virtual Hosts (VHosts)

### Fuzzing con ffuf

```bash
# Auto-calibración — destaca respuestas distintas al vhost por defecto
ffuf -u http://10.10.10.10 -H "Host: FUZZ.example.com" \
  -w /opt/SecLists/Discovery/DNS/subdomains-top1million-20000.txt -ac

ffuf -c -w /path/to/wordlist -u http://victim.com -H "Host: FUZZ.victim.com"
```

### Otras Herramientas

```bash
# gobuster vhost
gobuster vhost -u https://mysite.com -t 50 -w subdomains.txt

# wfuzz
wfuzz -c -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-20000.txt \
  --hc 400,404,403 -H "Host: FUZZ.example.com" -u http://example.com -t 100

# VHostScan
VHostScan -t example.com
```

### CORS Brute Force

Detectar subdominios válidos abusando del header `Access-Control-Allow-Origin`:

```bash
ffuf -w subdomains-top1million-5000.txt -u http://10.10.10.208 \
  -H 'Origin: http://FUZZ.crossfit.htb' \
  -mr "Access-Control-Allow-Origin" -ignore-body
```

> [!TIP]
> Con estas técnicas es posible acceder a **endpoints internos/ocultos** no expuestos públicamente.

---

## 🔑 Credenciales & Secretos Filtrados

### Credential Leaks

| Plataforma | URL | Notas |
|------------|-----|-------|
| Leak Lookup | [leak-lookup.com](https://leak-lookup.com) | Gratuito |
| DeHashed | [dehashed.com](https://www.dehashed.com/) | De pago |

### GitHub Leaks

```bash
# Leakos + gitleaks sobre repos públicos de una organización
leakos -org <organization>
```

**GitHub Dorks útiles:**

```
org:empresa password
org:empresa api_key
org:empresa secret
org:empresa token
org:empresa private_key
```

### Google Dorks & Pastes

```bash
# Google Dorks automatizados (Google Hacking Database)
gorks -d empresa.com

# Pastes en 80+ sitios simultáneos
pastos -d empresa.com

# Shodan — copyright string
shodan search http.html:"Copyright empresa"
```

---

## ☁️ Cloud Assets Públicos

```bash
# cloud_enum
cloud_enum -k empresa -k empresa.com

# S3Scanner
S3Scanner scan --buckets-file wordlist.txt

# CloudScraper
CloudScraper -d empresa.com
```

**Wordlists para buckets:**
- [cujanovic/goaltdns — words.txt](https://raw.githubusercontent.com/cujanovic/goaltdns/master/words.txt)
- [jordanpotti/AWSBucketDump — BucketNames.txt](https://raw.githubusercontent.com/jordanpotti/AWSBucketDump/master/BucketNames.txt)

> [!NOTE]
> Buscar más allá de S3: **Azure Blobs, GCP Storage, Firebase** y otros servicios cloud son igualmente relevantes.

### Web Servers Hunting

```bash
# httprobe — prueba puertos 80 y 443
cat /tmp/domains.txt | httprobe

# Con puertos adicionales
cat /tmp/domains.txt | httprobe -p http:8080 -p https:8443

# Screenshots masivos
gowitness file -f domains.txt
eyewitness --web -f domains.txt
```

### Búsqueda de Emails

```bash
# theHarvester con APIs
theHarvester -d tesla.com -b linkedin,google,hunter
```

| API | URL | Plan |
|-----|-----|------|
| Hunter.io | [hunter.io](https://hunter.io/) | Free tier |
| Snov.io | [app.snov.io](https://app.snov.io/) | Free tier |
| Minelead | [minelead.io](https://minelead.io/) | Free tier |

---

## 📊 Recapitulación del Proceso

Al finalizar esta fase, deberías haber cubierto:

- ✅ Todas las empresas dentro del scope
- ✅ Activos de red: rangos IP y ASNs
- ✅ Dominios raíz y subdominios
- ✅ Análisis de Subdomain Takeover
- ✅ IPs dentro y fuera de CDNs
- ✅ Web servers identificados y con screenshots
- ✅ Cloud assets públicos (S3, Azure Blobs, GCP, etc.)
- ✅ Emails, credenciales y secretos filtrados

### 🤖 Herramientas de Full Recon Automatizado

| Herramienta | Repositorio | Estado |
|-------------|-------------|--------|
| **ReNgine** | [yogeshojha/rengine](https://github.com/yogeshojha/rengine) | ![](https://img.shields.io/badge/-Activo-00ff88?style=flat-square) |
| **Osmedeus** | [j3ssie/Osmedeus](https://github.com/j3ssie/Osmedeus) | ![](https://img.shields.io/badge/-Activo-00ff88?style=flat-square) |
| **reconFTW** | [six2dez/reconftw](https://github.com/six2dez/reconftw) | ![](https://img.shields.io/badge/-Activo-00ff88?style=flat-square) |
| **EchoPwn** | [hackerspider1/EchoPwn](https://github.com/hackerspider1/EchoPwn) | ![](https://img.shields.io/badge/-Legacy-ffb300?style=flat-square) |

---

<div align="center">

![](https://img.shields.io/badge/Uso-Solo%20en%20entornos%20autorizados-ff3c6e?style=for-the-badge)

*Documentación generada para uso en entornos de auditoría autorizados · Offensive Security Arsenal*

</div>
