<div align="center">

# 🔴 Offensive Security
### Pentesting Reference — Guía de Fases

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Type](https://img.shields.io/badge/Type-Cheatsheet-00d4ff?style=for-the-badge&logo=hackthebox&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-00ff88?style=for-the-badge&logo=linux&logoColor=white)

</div>

---

> **¿Qué es este repositorio?**
> Colección de cheatsheets, comandos y técnicas organizadas por fase del ciclo de pentesting. Diseñado como referencia rápida para profesionales y estudiantes de seguridad ofensiva.

> [!WARNING]
> **Aviso Legal y Ético:** Todas las herramientas y comandos documentados en este repositorio deben ser utilizados única y exclusivamente en entornos donde se posea **autorización explícita por escrito (Reglas de Enfrentamiento / RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Fase | Descripción |
|---|------|-------------|
| 01 | [🕵️ Reconocimiento Pasivo](#️-fase-1--reconocimiento-pasivo) | OSINT sin interacción directa con el objetivo |
| 02 | [🔴 Reconocimiento Activo](#-fase-2--reconocimiento-activo) | Escaneo, enumeración e interacción directa |
| 03 | [💥 Explotación](#-fase-3--explotación) | Aprovechamiento de vulnerabilidades identificadas |
| 04 | [⬆️ Post-Explotación](#️-fase-4--post-explotación) | Escalamiento, persistencia y movimiento lateral |

---

## 🔄 Metodología General

```
┌─────────────────────────────────────────────────────────────────┐
│                    CICLO DE PENTESTING                          │
│                                                                 │
│   🕵️ RECON        🔭 ESCANEO      💥 EXPLOTACIÓN               │
│   PASIVO    ──►   ACTIVO    ──►   & ACCESO      ──►  ...       │
│   (OSINT)         (Nmap/CME)      (Metasploit)                  │
│                                                                 │
│   ⬆️ ESCALAMIENTO  ↔️ MOV. LATERAL   🔒 PERSISTENCIA            │
│   ... ──►  PRIVESC   ──►  PTH/PTT   ──►  BACKDOOR              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🕵️ Fase 1 — Reconocimiento Pasivo

![Category](https://img.shields.io/badge/Category-Passive%20Recon-00ff88?style=flat-square&logo=hackthebox&logoColor=white)
![Risk](https://img.shields.io/badge/Detección-Muy%20Baja-00ff88?style=flat-square)

> Recopilación de información **sin interactuar directamente** con los sistemas del objetivo. Sin tráfico hacia el target.

📄 **[→ Ver Reconocimiento Pasivo](Reconocimiento/Pasivo.md)**

| Herramienta | Enfoque | Badge |
|-------------|---------|-------|
| **DNSRecon** | Enumeración DNS pasiva, registros, AXFR | ![](https://img.shields.io/badge/-DNS-00d4ff?style=flat-square) |
| **OWASP Amass** | Mapeo profundo de activos y subdominios | ![](https://img.shields.io/badge/-OSINT-00ff88?style=flat-square) |
| **Subfinder / Sublist3r** | Descubrimiento de subdominios vía fuentes pasivas | ![](https://img.shields.io/badge/-OSINT-00ff88?style=flat-square) |
| **dnsx** | Resolución masiva y filtrado DNS | ![](https://img.shields.io/badge/-DNS-00d4ff?style=flat-square) |
| **PowerShell / LotL** | Recon interno Living off the Land | ![](https://img.shields.io/badge/-LotL-5865f2?style=flat-square) |
| **Shodan / Censys** | Descubrimiento de activos expuestos en internet | ![](https://img.shields.io/badge/-OSINT-00ff88?style=flat-square) |

---

## 🔴 Fase 2 — Reconocimiento Activo

![Category](https://img.shields.io/badge/Category-Active%20Recon-ff3c6e?style=flat-square&logo=hackthebox&logoColor=white)
![Risk](https://img.shields.io/badge/Detección-Alta-ff3c6e?style=flat-square)

> Interacción **directa** con los sistemas objetivo. Genera tráfico detectable en IDS/IPS, firewalls y logs.

📄 **[→ Ver Reconocimiento Activo](Reconocimiento/Activo.md)**

| Herramienta | Enfoque | Badge |
|-------------|---------|-------|
| **Nmap** | Escaneo de puertos, versiones, OS, NSE scripts | ![](https://img.shields.io/badge/-SCAN-ff3c6e?style=flat-square) |
| **enum4linux** | Enumeración SMB, NetBIOS, usuarios, shares | ![](https://img.shields.io/badge/-SMB-ff6b00?style=flat-square) |
| **NetExec / CrackMapExec** | Enumeración y ataques en entornos AD | ![](https://img.shields.io/badge/-AD-a855f7?style=flat-square) |
| **FFUF** | Web fuzzing — directorios, parámetros, VHosts | ![](https://img.shields.io/badge/-FUZZ-00d4ff?style=flat-square) |
| **Gobuster** | Brute-force web, DNS y virtual hosts | ![](https://img.shields.io/badge/-BRUTE-00ff88?style=flat-square) |
| **smtp-user-enum** | Enumeración de usuarios vía SMTP | ![](https://img.shields.io/badge/-SMTP-ffb300?style=flat-square) |
| **wafw00f / curl** | Detección WAF e inspección HTTP | ![](https://img.shields.io/badge/-HTTP-5865f2?style=flat-square) |

---

## 💥 Fase 3 — Explotación

![Category](https://img.shields.io/badge/Category-Exploitation-ff6b00?style=flat-square&logo=hackthebox&logoColor=white)
![Status](https://img.shields.io/badge/Status-Próximamente-555555?style=flat-square)

> Aprovechamiento de vulnerabilidades identificadas en las fases anteriores para obtener acceso al sistema objetivo.

| Herramienta / Técnica | Enfoque | Badge |
|-----------------------|---------|-------|
| **Metasploit Framework** | Explotación automatizada, payloads, msfvenom | ![](https://img.shields.io/badge/-MSF-ff6b00?style=flat-square) |
| **Exploits manuales** | Buffer overflow, RCE, SQLi, LFI/RFI | ![](https://img.shields.io/badge/-MANUAL-ff3c6e?style=flat-square) |
| **SQLmap** | Inyección SQL automatizada | ![](https://img.shields.io/badge/-SQLi-ffb300?style=flat-square) |
| **Hydra / Medusa** | Ataques de fuerza bruta a servicios | ![](https://img.shields.io/badge/-BRUTE-ff3c6e?style=flat-square) |
| **Burp Suite** | Interceptación y explotación web | ![](https://img.shields.io/badge/-WEB-00d4ff?style=flat-square) |

> [!NOTE]
> Contenido en desarrollo. Próximamente disponible.

---

## ⬆️ Fase 4 — Post-Explotación

![Category](https://img.shields.io/badge/Category-Post--Exploitation-a855f7?style=flat-square&logo=hackthebox&logoColor=white)
![Status](https://img.shields.io/badge/Status-Próximamente-555555?style=flat-square)

> Acciones tras el acceso inicial: escalamiento de privilegios, movimiento lateral, persistencia y exfiltración.

| Técnica | Herramientas | Badge |
|---------|-------------|-------|
| **Escalamiento de Privilegios Linux** | LinPEAS, sudo -l, SUID, cron abuse | ![](https://img.shields.io/badge/-PRIVESC-a855f7?style=flat-square) |
| **Escalamiento de Privilegios Windows** | WinPEAS, token impersonation, UAC bypass | ![](https://img.shields.io/badge/-PRIVESC-a855f7?style=flat-square) |
| **Movimiento Lateral** | Pass-the-Hash, Pass-the-Ticket, PsExec | ![](https://img.shields.io/badge/-LATERAL-ff3c6e?style=flat-square) |
| **Persistencia** | Backdoors, cronjobs, tareas programadas | ![](https://img.shields.io/badge/-PERSIST-ff6b00?style=flat-square) |
| **Exfiltración** | Transferencia de archivos, canales encubiertos | ![](https://img.shields.io/badge/-EXFIL-ffb300?style=flat-square) |
| **Pivoting** | Proxychains, chisel, SSH tunneling | ![](https://img.shields.io/badge/-PIVOT-00d4ff?style=flat-square) |

> [!NOTE]
> Contenido en desarrollo. Próximamente disponible.

---

## 🗂️ Resumen de Archivos

| Archivo | Fase | Estado |
|---------|------|--------|
| [Reconocimiento/Pasivo.md](Reconocimiento/Pasivo.md) | Recon Pasivo | ![](https://img.shields.io/badge/-Disponible-00ff88?style=flat-square) |
| [Reconocimiento/Activo.md](Reconocimiento/Activo.md) | Recon Activo / Escaneo | ![](https://img.shields.io/badge/-Disponible-00ff88?style=flat-square) |
| Explotacion/ | Explotación | ![](https://img.shields.io/badge/-En%20desarrollo-ffb300?style=flat-square) |
| Post-Explotacion/ | Post-Explotación | ![](https://img.shields.io/badge/-En%20desarrollo-ffb300?style=flat-square) |

---

## 🏋️ Desafíos — Labs Prácticos

> Escenarios vulnerables para practicar las técnicas documentadas en cada fase.

| Lab | Temática | Servicios | Nivel | Estado |
|-----|----------|-----------|-------|--------|
| [⚡ Planta Energía Vulnerable](Desafíos/Planta_Energia/README.md) | ICS / SCADA | FTP, SMB, Web, SSH, TELNET, SMTP | ![](https://img.shields.io/badge/-Intermedio-ffb300?style=flat-square) | ![](https://img.shields.io/badge/-Disponible-00ff88?style=flat-square) |

---

## 📂 Estructura del Repositorio

```
Seg-Ofs/
├── 📄 README.md
├── 📁 Reconocimiento/
│   ├── 🕵️  Pasivo.md              # OSINT y recon sin interacción directa
│   └── 🔴  Activo.md              # Nmap, enum4linux, NetExec, FFUF, SMTP
├── 📁 Desafíos/
│   └── ⚡  Planta_Energia/        # Lab SCADA — FTP, SMB, Web, SSH, TELNET, SMTP
├── 📁 Explotacion/                # (próximamente)
└── 📁 Post-Explotacion/           # (próximamente)
```
