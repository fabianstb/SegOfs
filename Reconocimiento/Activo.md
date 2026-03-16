# Fase 1: Reconocimiento Activo (Active Reconnaissance)

El reconocimiento activo implica interactuar directamente con el sistema objetivo para obtener respuestas técnicas. **Nota:** Esta actividad deja huellas en los logs del servidor/firewall.

---

## 🌐 Enumeración DNS Avanzada
Identificación de registros, servidores de correo y posibles transferencias de zona.

### nslookup (Herramienta Nativa)
Permite realizar consultas manuales a servidores DNS.
* `set type=mx` : Busca servidores de correo.
* `set type=soa` : Busca la autoridad del dominio (Start of Authority).
* `set type=ptr` : Resolución inversa (IP a nombre).

### dnsrecon
Herramienta potente para auditoría DNS y fuerza bruta.
* **Resolución inversa por rango:**
  ```bash
  dnsrecon -r 162.241.216.0-162.241.216.255