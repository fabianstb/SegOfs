# 🛡️ Offensive Security: Reconocimiento Pasivo

> Bienvenido a la sección de **Reconocimiento Pasivo**. Esta fase es crítica y se enfoca en recolectar la mayor cantidad de información posible sobre el objetivo **sin interactuar directamente** con sus sistemas principales, evadiendo así la detección temprana por parte de los Blue Teams (IDS/IPS/SIEM).

---

> ⚠️ **Aviso Legal y Ético:** Todas las herramientas y comandos documentados en este repositorio deben ser utilizados única y exclusivamente en entornos donde poseas **autorización explícita por escrito** (Reglas de Enfrentamiento / RoE).

---

## 📋 Resumen de Herramientas

| Herramienta  | Categoría Principal       | Enfoque                                                  |
|--------------|---------------------------|----------------------------------------------------------|
| DNSRecon     | Enumeración DNS            | Multipropósito (Registros, AXFR, Brute-force)            |
| Amass        | OSINT / Descubrimiento     | Mapeo profundo de activos y subdominios                  |
| Subfinder    | OSINT / Descubrimiento     | Alta velocidad, fuentes pasivas múltiples                |
| dnsx         | Resolución Masiva          | Filtrado, verificación y enrutamiento DNS rápido         |
| BBOT         | OSINT / Automatización     | Enumeración modular con agregación de ASNs               |
| massdns      | DNS Brute-Force            | Resolución masiva de alta velocidad                      |
| shuffledns   | DNS Brute-Force            | Wrapper de massdns con soporte wildcard                  |
| ffuf         | Virtual Hosts / CORS       | Fuzzing de Host headers y detección de VHosts            |
| PowerShell   | Nativo (Windows)           | Consultas Living off the Land (LotL)                     |

---


### 1. DNSRecon: La Navaja Suiza del DNS

Herramienta escrita en Python, indispensable para la enumeración de registros, transferencias de zona y recolección de información del espacio de nombres.

#### Enumeración Estándar (Registros SRV, SOA, NS, MX, A, AAAA)

```bash
dnsrecon -d example.com
```

#### Intento de Transferencia de Zona (AXFR)

Solicita una copia completa de la zona DNS. Si está mal configurado, revelará **toda la infraestructura**.

```bash
dnsrecon -d example.com -t axfr
```

#### Fuerza Bruta de Subdominios

Utiliza un diccionario personalizado para descubrir hosts no listados públicamente.

```bash
dnsrecon -d example.com -D /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t brt
```

#### Búsqueda Inversa por Rango (Reverse Lookup)

Mapea un bloque CIDR para ver qué dominios resuelven a esas IPs.

```bash
dnsrecon -r 192.168.1.0/24
```

#### Expansión de TLD (Top Level Domain)

Busca el mismo nombre de dominio a través de diferentes terminaciones geográficas o comerciales (ej. `.net`, `.org`, `.co.uk`).

```bash
dnsrecon -d example -t tld
```

#### Caminata de Zona DNSSEC (Zone Walk)

Extrae registros de una zona asegurada con DNSSEC explotando registros NSEC.

```bash
dnsrecon -d example.com -z
```

#### Salida Estructurada (JSON/SQLite)

Ideal para integrar los resultados en otras herramientas automatizadas o bases de datos.

```bash
dnsrecon -d example.com -j resultados_dnsrecon.json
```

---

### 2. OWASP Amass: Inteligencia de Activos Profunda

Amass es el rey del descubrimiento pasivo profundo. Utiliza técnicas de scraping, APIs y bases de datos WHOIS históricas.

#### Descubrimiento Pasivo Total

Busca subdominios utilizando todas las fuentes pasivas disponibles **sin enviar tráfico al objetivo**.

```bash
amass enum -passive -d example.com
```

#### Inteligencia Inversa (WHOIS)

Encuentra otros dominios raíz que pertenezcan a la misma organización basándose en los datos de registro.

```bash
amass intel -d example.com -whois
```

#### Descubrimiento de ASN (Autonomous System Number)

Identifica el bloque de red y el ISP que aloja la infraestructura del objetivo.

```bash
amass intel -org "Nombre de la Empresa"
```

---

### 3. Subfinder & Sublist3r: Velocidad y Multi-motor

Herramientas diseñadas para consultar decenas de motores de búsqueda, repositorios de GitHub y bases de datos públicas en segundos.

#### Ejecución Silenciosa y Limpia (Subfinder)

Extrae subdominios y muestra únicamente los resultados, ideal para encadenar comandos (Piping).

```bash
subfinder -d example.com -silent
```

#### Consultas a Motores Específicos (Sublist3r)

Limita la búsqueda a motores particulares y aumenta los hilos para mayor velocidad.

```bash
sublist3r -d example.com -e google,yahoo,virustotal -t 10
```

---

### 4. dnsx: Resolución Masiva y Filtrado

Desarrollada por [ProjectDiscovery](https://github.com/projectdiscovery/dnsx), `dnsx` es un toolkit DNS rápido y multipropósito diseñado para manejar listas inmensas de subdominios.

#### Verificación de Subdominios Vivos

Toma una lista de subdominios descubiertos pasivamente y verifica cuáles resuelven actualmente a una IP.

```bash
cat subdominios_crudos.txt | dnsx -a -resp
```

#### Extracción de CNAME (Subdomain Takeover Recon)

Identifica registros CNAME apuntando a servicios de terceros (AWS, GitHub Pages, Azure) que podrían ser vulnerables a **secuestro de subdominio**.

```bash
cat subdominios_crudos.txt | dnsx -cname -resp
```

---

### 5. Técnicas Nativas (PowerShell / Living off the Land)

Para pentesting en entornos Windows (**Assumed Breach / Internal Recon**) donde no puedes instalar herramientas de terceros.

#### Enumeración de Servicios Internos (SRV)

Descubre controladores de dominio, servidores de catálogo global o servicios LDAP.

```powershell
Resolve-DnsName -Name _ldap._tcp.dc._msdcs.dominio.local -Type SRV
```

#### Resolución Básica y MX

```powershell
Resolve-DnsName -Name example.com -Type MX
```

---

## 🌐 ASNs: Mapeo de Rangos IP de la Organización

Un **Autonomous System Number (ASN)** es un identificador único asignado por la IANA a un sistema autónomo que administra bloques de IPs con una política de enrutamiento definida. Identificar los ASNs del objetivo permite mapear toda su superficie de red.

### Recursos Online para búsqueda de ASNs

| Plataforma | URL | Notas |
|------------|-----|-------|
| Hurricane Electric BGP | https://bgp.he.net/ | Completo, con Whois e IP ranges |
| BGPView | https://bgpview.io/ | API gratuita disponible |
| IPInfo | https://ipinfo.io/ | Información de ASN por IP |
| ASN Lookup | http://asnlookup.com/ | API gratuita |
| IPv4Info | http://ipv4info.com/ | IP y ASN por dominio |

> **Registros regionales:** AFRINIC (África), ARIN (América del Norte), APNIC (Asia), LACNIC (América Latina), RIPE NCC (Europa).

### Búsqueda con Amass

```bash
# Por nombre de organización
amass intel -org tesla

# Por ASNs específicos
amass intel -asn 8911,50313,394161
```

### Enumeración Automática con BBOT

BBOT agrega y resume ASNs automáticamente al final del escaneo:

```bash
bbot -t tesla.com -f subdomain-enum
```

Ejemplo de salida:

```
[INFO] bbot.modules.asn: | AS394161 | 8.244.131.0/24  | 5 | TESLA     | Tesla Motors, Inc.  | US |
[INFO] bbot.modules.asn: | AS16509  | 54.148.0.0/15   | 4 | AMAZON-02 | Amazon.com, Inc.    | US |
[INFO] bbot.modules.asn: | AS394161 | 8.45.124.0/24   | 3 | TESLA     | Tesla Motors, Inc.  | US |
```

---

## 🔍 Descubrimiento de Dominios

### Reverse DNS

Con los rangos IP identificados, se pueden realizar lookups inversos para encontrar más dominios asociados.

```bash
# Rango completo con servidor DNS específico
dnsrecon -r <DNS_Range> -n <IP_DNS>

# Usando el DNS de Facebook como referencia
dnsrecon -d facebook.com -r 157.240.221.35/24

# Usando Cloudflare como resolver
dnsrecon -r 157.240.221.35/24 -n 1.1.1.1

# Usando Google como resolver
dnsrecon -r 157.240.221.35/24 -n 8.8.8.8
```

> **Nota:** El administrador debe haber habilitado manualmente el registro PTR para que funcione. También se puede usar [ptrarchive.com](http://ptrarchive.com/) como recurso online. Para rangos grandes, `massdns` y `dnsx` son ideales para automatizar.

### Reverse Whois (Loop)

Los registros WHOIS contienen campos como organización, dirección, emails y teléfonos. Realizar búsquedas inversas por esos campos permite descubrir más activos relacionados.

**Herramientas online (gratuitas):**
- https://viewdns.info/reversewhois/
- https://domaineye.com/reverse-whois
- https://www.reversewhois.io/
- https://www.whoxy.com/

**Herramientas online (de pago):**
- https://securitytrails.com/
- https://drs.whoisxmlapi.com/reverse-whois-search
- https://whoisfreaks.com/

```bash
# Automatización con Amass
amass intel -d tesla.com -whois
```

> 💡 **Tip:** Se puede usar DomLink (requiere API key de Whoxy) para automatizar el proceso de reverse whois en bucle.

### Trackers (Analytics & Ads IDs)

Si dos páginas comparten el mismo ID de Google Analytics o Adsense, probablemente son administradas por el mismo equipo. Herramientas útiles:

- [BuiltWith](https://builtwith.com/)
- [Publicwww](https://publicwww.com/)
- [SpyOnWeb](https://spyonweb.com/)
- [Webscout](https://webscout.io/)

### Favicon Hash

Buscar dominios relacionados a través del hash del ícono favicon:

```bash
# Generar lista de targets
cat my_targets.txt | xargs -I %% bash -c 'echo "http://%%/favicon.ico"' > targets.txt

# Usar favihash
python3 favihash.py -f https://target/favicon.ico -t targets.txt -s

# Obtener hashes a escala con httpx
httpx -l targets.txt -favicon

# Pivotear en Shodan con el hash
shodan search org:"Target" http.favicon.hash:116323821 --fields ip_str,port --separator " " | awk '{print $1":"$2}'
```

Script Python para calcular el hash de un favicon:

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

### Certificados de Transparencia (Certificate Transparency)

Los logs de CT registran todos los certificados emitidos y son una fuente excelente para descubrir dominios y subdominios:

```bash
# API de crt.sh
crt(){
  curl -s "https://crt.sh/?q=%25.$1" \
    | grep -oE "[\.a-zA-Z0-9-]+\.$1" \
    | sort -u
}
crt tesla.com
```

**Recursos online:**
- https://crt.sh/
- https://certspotter.com/
- https://search.censys.io/
- https://chaos.projectdiscovery.io/

### Copyright / Strings Únicas

Buscar cadenas de texto únicas (como el copyright) que aparezcan en múltiples propiedades de la misma organización:

```bash
# En Shodan
shodan search http.html:"Copyright string"
```

### Mail DMARC

Usar registros DMARC para descubrir dominios y subdominios relacionados:

- Online: https://dmarc.live/info/google.com
- Herramientas: `spoofcheck`, `dmarcian`, [dmarc-subdomains](https://github.com/Tedixx/dmarc-subdomains)

---

## 🗺️ Descubrimiento de Subdominios

### DNS - Zone Transfer

```bash
dnsrecon -a -d tesla.com
```

### OSINT - Herramientas Principales

#### BBOT

```bash
# Enumeración completa de subdominios
bbot -t tesla.com -f subdomain-enum

# Solo fuentes pasivas
bbot -t tesla.com -f subdomain-enum -rf passive

# Subdominios + port scan + screenshots
bbot -t tesla.com -f subdomain-enum -m naabu gowitness -n my_scan -o .
```

#### Amass

```bash
amass enum [-active] [-ip] -d tesla.com
amass enum -d tesla.com | grep tesla.com
```

#### Subfinder

```bash
./subfinder-linux-amd64 -d tesla.com [-silent]
```

#### Findomain

```bash
./findomain-linux -t tesla.com [--quiet]
```

#### OneForAll

```bash
python3 oneforall.py --target tesla.com [--dns False] [--req False] [--brute False] run
```

#### theHarvester

```bash
theHarvester -d tesla.com -b "anubis, baidu, bing, binaryedge, bingapi, bufferoverun, censys, certspotter, crtsh, dnsdumpster, duckduckgo, fullhunt, github-code, google, hackertarget, hunter, intelx, linkedin, linkedin_links, n45ht, omnisint, otx, pentesttools, projectdiscovery, qwant, rapiddns, rocketreach, securityTrails, sublist3r, threatcrowd, threatminer, trello, twitter, urlscan, virustotal, yahoo, zoomeye"
```

### APIs Gratuitas para Subdominios

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

**Wordlists recomendadas:**
- https://gist.github.com/jhaddix/86a06c5dc309d08580a018c66354a056
- https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt
- https://github.com/danielmiessler/SecLists/tree/master/Discovery/DNS

**Resolvers confiables:**
- https://public-dns.info/nameservers-all.txt (filtrar con `dnsvalidator`)
- https://raw.githubusercontent.com/trickest/resolvers/main/resolvers-trusted.txt

#### massdns

```bash
sed 's/$/.domain.com/' subdomains.txt > bf-subdomains.txt
./massdns -r resolvers.txt -w /tmp/results.txt bf-subdomains.txt
grep -E "tesla.com. [0-9]+ IN A .+" /tmp/results.txt
```

#### gobuster

```bash
gobuster dns -d mysite.com -t 50 -w subdomains.txt
```

#### shuffledns

```bash
shuffledns -d example.com -list example-subdomains.txt -r resolvers.txt
```

#### puredns

```bash
puredns bruteforce all.txt domain.com
```

#### aiodnsbrute

```bash
aiodnsbrute -r resolvers -w wordlist.txt -vv -t 1024 domain.com
```

### Segunda Ronda: Permutaciones de Subdominios

Después del brute-force inicial, se generan permutaciones para descubrir aún más subdominios:

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

Si una IP aloja múltiples subdominios, se pueden descubrir más mediante fuzzing del header `Host`:

### Fuzzing con ffuf

```bash
# Auto-calibración para destacar respuestas distintas al vhost por defecto
ffuf -u http://10.10.10.10 -H "Host: FUZZ.example.com" \
  -w /opt/SecLists/Discovery/DNS/subdomains-top1million-20000.txt -ac

ffuf -c -w /path/to/wordlist -u http://victim.com -H "Host: FUZZ.victim.com"
```

### Otras herramientas para VHosts

```bash
gobuster vhost -u https://mysite.com -t 50 -w subdomains.txt

wfuzz -c -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-20000.txt \
  --hc 400,404,403 -H "Host: FUZZ.example.com" -u http://example.com -t 100

VHostScan -t example.com
```

### CORS Brute Force

Detectar subdominios válidos abusando del header `Access-Control-Allow-Origin`:

```bash
ffuf -w subdomains-top1million-5000.txt -u http://10.10.10.208 \
  -H 'Origin: http://FUZZ.crossfit.htb' -mr "Access-Control-Allow-Origin" -ignore-body
```

---

## 🔗 Búsqueda de Credenciales y Secretos Filtrados

### Credential Leaks

```
https://leak-lookup.com
https://www.dehashed.com/
```

### GitHub Leaks

```bash
# Usar Leakos para escanear repos públicos de una organización con gitleaks
leakos -org <organization>
```

**GitHub Dorks útiles:** buscar combinaciones de `org:empresa password`, `org:empresa api_key`, `org:empresa secret`, etc.

### Pastes Leaks

Usar [Pastos](https://github.com/carlospolop/Pastos) para buscar simultáneamente en más de 80 sitios de paste.

### Google Dorks

Usar [Gorks](https://github.com/carlospolop/Gorks) para automatizar búsquedas de la [Google Hacking Database](https://www.exploit-db.com/google-hacking-database).

---

## 🌩️ Cloud Assets Públicos

Buscar buckets y recursos cloud expuestos usando keywords de la empresa:

```bash
# Herramientas recomendadas
cloud_enum -k empresa -k empresa.com
CloudScraper
S3Scanner
```

**Wordlists para buckets:**
- https://raw.githubusercontent.com/cujanovic/goaltdns/master/words.txt
- https://raw.githubusercontent.com/jordanpotti/AWSBucketDump/master/BucketNames.txt

---

## 🕸️ Web Servers Hunting

Descubrir servidores web activos dentro del scope:

```bash
# httprobe: prueba puertos 80 y 443
cat /tmp/domains.txt | httprobe

# Con puertos adicionales
cat /tmp/domains.txt | httprobe -p http:8080 -p https:8443
```

### Screenshots Masivos

Tomar capturas de pantalla de todos los servidores web para identificar endpoints interesantes:

```bash
gowitness file -f domains.txt
eyewitness --web -f domains.txt
```

---

## ✉️ Búsqueda de Emails

```bash
# theHarvester con APIs
theHarvester -d tesla.com -b linkedin,google,hunter

# APIs con plan gratuito
# https://hunter.io/
# https://app.snov.io/
# https://minelead.io/
```

---

## 📊 Recapitulación del Proceso

Al finalizar esta fase, deberías haber cubierto:

- ✅ Todas las empresas dentro del scope
- ✅ Activos de red (rangos IP, ASNs)
- ✅ Dominios raíz y subdominios (con análisis de subdomain takeover)
- ✅ IPs dentro y fuera de CDNs
- ✅ Servidores web identificados y con screenshots
- ✅ Cloud assets públicos (buckets S3, Azure Blobs, etc.)
- ✅ Emails, credenciales y secretos filtrados

---

## 🤖 Herramientas de Reconocimiento Automatizado (Full Recon)

| Herramienta | URL |
|-------------|-----|
| ReNgine | https://github.com/yogeshojha/rengine |
| Osmedeus | https://github.com/j3ssie/Osmedeus |
| reconFTW | https://github.com/six2dez/reconftw |
| EchoPwn | https://github.com/hackerspider1/EchoPwn |

---

*Documentación generada para uso en entornos de auditoría autorizados.*
