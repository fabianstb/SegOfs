# Fase 1: Reconocimiento Pasivo (Footprinting)

El reconocimiento pasivo consiste en recolectar toda la información pública disponible sobre el objetivo sin interactuar directamente con su infraestructura.

## 🔍 Google Hacking (Dorking)
Uso de operadores avanzados para encontrar información sensible indexada.

* `cache:url` : Ver la versión en caché de Google (evita visitar el sitio real).
* `link:url` : Sitios que enlazan al objetivo.
* `related:url` : Sitios con contenido similar.
* `site:dominio` : Filtra resultados solo para ese dominio.
    * *Ejemplo:* `site:certifiedhacker.com ext:pdf docx xls txt` (Busca archivos específicos).
* `allintitle:` : Busca palabras específicas en el título de la web.
* `allinurl:` : Busca subdominios o rutas específicas en la URL.

> **Tip:** Puedes consultar [Exploit-DB (GHDB)](https://www.exploit-db.com/google-hacking-database) para dorks actualizados.

---

## 🖼️ Búsqueda Inversa de Imágenes
Útil para verificar perfiles, encontrar fugas de información o geolocalización.
* Google Images
* [TinEye](https://tineye.com/)
* Yandex Images

---

## 🌐 Enumeración de Subdominios y OSINT
Herramientas y plataformas para descubrir la superficie de ataque:

| Herramienta | Descripción |
| :--- | :--- |
| **Netcraft** | Análisis de infraestructura y tecnologías web. |
| **Sublist3r** | Enumeración de subdominios usando múltiples fuentes. |
| **Shodan / Censys** | Buscadores de dispositivos conectados a internet. |
| **TheHarvester** | Recolecta correos, nombres, subdominios e IPs (ej: `theHarvester -d microsoft -l 200 -b linkedin`). |

### Comandos Shodan
* `port:21` (Filtra por puerto)
* `net:1.2.3.4/24` (Filtra por segmento de red)
* `country:CL` (Filtra por país)

---

## 📧 Email & Personas
* **Tracking:** Obtención de cabeceras, SO del servidor de correo y rutas de envío.
* **Búsqueda de personas:** Intelius (EEUU), Pipl (Latam), PeekYou.
* **Metadata:** [Metashield Clean-up](https://metashieldclean-up.elevenpaths.com/) para analizar o limpiar documentos.

---

## 🛠️ Herramientas de Automatización OSINT
* **Recon-ng:** Framework modular para reconocimiento.
* **BillCipher / Recon-Dog / Th3Inspector:** Scripts de automatización para recopilación rápida.
* **HTTrack:** Crea un *mirror* (copia exacta) de un sitio web para análisis offline.