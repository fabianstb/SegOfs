<div align="center">

# 🔁 CSRF
### Forzado de Acciones en Sesión de Víctima

</div>

---

## 🎯 Labs Objetivo

| Plataforma | Labs recomendados |
|-----------|-------------------|
| **DVWA** | CSRF |
| **Juice Shop** | acciones autenticadas y cambios de perfil según reto |
| **PortSwigger** | Cross-site request forgery |

---

## 🛠️ Herramientas

- **Caido**: `HTTP History`, `Replay`
- navegador
- Assistant de Caido para generar PoC HTML si disponible

---

## 🔍 Qué Buscar

- acción sensible autenticada
- `POST` sin token
- token reusable
- token no ligado a sesión
- método alternativo `GET`
- validación débil de `Origin` / `Referer`
- comportamiento `SameSite`

---

## 🔁 Flujo con Caido

### `[01]` Capturar request sensible

Ejemplos:

- cambio de email
- cambio de password
- añadir usuario
- update profile

### `[02]` Revisar defensas

Buscar:

- `csrf=...`
- `Origin`
- `Referer`
- cookie `SameSite`

### `[03]` Replay

Probar:

- quitar token
- cambiar método
- repetir token desde otra sesión
- mandar solo request esencial

---

## 🧪 PoC HTML Base

```html
<html>
  <body onload="document.forms[0].submit()">
    <form action="http://lab.local/change-email" method="POST">
      <input type="hidden" name="email" value="lab@example.local">
    </form>
  </body>
</html>
```

### Variante GET

```html
<img src="http://lab.local/change-email?email=lab@example.local">
```

---

## 🧠 Casos Típicos

| Caso | Qué probar |
|------|------------|
| **Sin token** | PoC directo |
| **Token opcional** | omitir parámetro |
| **Token no ligado a sesión** | reutilizar desde otra cuenta |
| **Token duplicado cookie/body** | manipular doble envío |
| **SameSite Lax** | navegación top-level / GET |
| **Validación Referer débil** | header ausente o bypass parcial |

---

## 🧭 Ruta de Práctica

1. DVWA CSRF
2. PortSwigger: no defense
3. PortSwigger: token optional
4. PortSwigger: token not tied to session
5. PortSwigger: SameSite bypass
6. PortSwigger: Referer-based defense

---

## 📝 Checklist

- request sensible aislado
- dependencias mínimas identificadas
- token analizado
- cookie policy revisada
- PoC reproducible en lab
