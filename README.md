# Taller de Seguridad Ofensiva

> Material de referencia para las fases del proceso de pentesting. Cada sección contiene comandos, técnicas y cheatsheets organizados por fase.

---

## Fases del Pentesting

```
Reconocimiento  →  Escaneo  →  Explotación  →  Post-Explotación
```

---

## 1. Reconocimiento

> Recopilación de información sobre el objetivo antes de interactuar directamente con los sistemas.

| Tipo | Descripción | Link |
|------|-------------|------|
| **Pasivo** | OSINT, Shodan, WHOIS, DNS pasivo, Google Dorks, redes sociales | [Reconocimiento/Pasivo.md](Reconocimiento/Pasivo.md) |
| **Activo** | Nmap, DNS activo, SMB/enum4linux, NetExec/CrackMapExec, SMTP enum, Web fuzzing | [Reconocimiento/Activo.md](Reconocimiento/Activo.md) |

---

## 2. Escaneo & Enumeracion

> Identificación detallada de servicios, versiones, vulnerabilidades y superficies de ataque.

| Herramienta / Técnica | Descripción | Link |
|-----------------------|-------------|------|
| **Escaneo de puertos** | TCP/UDP, detección de versiones y OS | *(próximamente)* |
| **Vulnerability Scanning** | NSE scripts, Nikto, OpenVAS | *(próximamente)* |
| **Enumeración de servicios** | FTP, SSH, HTTP, SMB, LDAP, RDP | *(próximamente)* |

---

## 3. Explotación

> Aprovechamiento de vulnerabilidades identificadas para ganar acceso al sistema objetivo.

| Herramienta / Técnica | Descripción | Link |
|-----------------------|-------------|------|
| **Metasploit** | Framework de explotación, módulos, msfvenom | *(próximamente)* |
| **Exploits manuales** | Buffer overflow, SQLi, XSS, RCE | *(próximamente)* |
| **Password Attacks** | Hydra, Medusa, CrackMapExec spraying | *(próximamente)* |
| **Web Exploitation** | OWASP Top 10, SQLmap, Burp Suite | *(próximamente)* |

---

## 4. Post-Explotación

> Acciones posteriores al acceso inicial: escalamiento de privilegios, movimiento lateral y persistencia.

| Herramienta / Técnica | Descripción | Link |
|-----------------------|-------------|------|
| **Escalamiento de Privilegios** | Linux privesc, Windows privesc, sudo abuse | *(próximamente)* |
| **Movimiento Lateral** | Pass-the-Hash, Pass-the-Ticket, PsExec | *(próximamente)* |
| **Persistencia** | Backdoors, cronjobs, tareas programadas | *(próximamente)* |
| **Exfiltración** | Transferencia de datos, canales encubiertos | *(próximamente)* |
| **Pivoting** | Túneles, proxychains, port forwarding | *(próximamente)* |

---

## Herramientas de Referencia Rápida

| Herramienta | Categoría | Documentada en |
|-------------|-----------|----------------|
| Nmap | Escaneo / Enumeración | [Activo.md](Reconocimiento/Activo.md#nmap) |
| enum4linux | Enumeración SMB | [Activo.md](Reconocimiento/Activo.md#enum4linux--smb--netbios) |
| NetExec / CrackMapExec | AD / Lateral Movement | [Activo.md](Reconocimiento/Activo.md#netexeccrackmapexec) |
| FFUF | Web Fuzzing | [Activo.md](Reconocimiento/Activo.md#ffuf) |
| Gobuster | Web / DNS Fuzzing | [Activo.md](Reconocimiento/Activo.md#gobuster) |
| theHarvester | OSINT | [Pasivo.md](Reconocimiento/Pasivo.md) |
| Shodan | OSINT | [Pasivo.md](Reconocimiento/Pasivo.md) |

---

## Estructura del Repositorio

```
Seg-Ofs/
├── README.md
├── Reconocimiento/
│   ├── Pasivo.md          # OSINT y recon pasivo
│   └── Activo.md          # Escaneo activo y enumeración
├── Escaneo/               # (próximamente)
├── Explotacion/           # (próximamente)
└── Post-Explotacion/      # (próximamente)
```

---

> **Uso educativo y en entornos autorizados únicamente.**
