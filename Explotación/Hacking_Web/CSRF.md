<div align="center">

# 🔁 CSRF
### Cross-Site Request Forgery — Forzado de Acciones Autenticadas

![Status](https://img.shields.io/badge/Status-Active-ff3c6e?style=for-the-badge&logo=statuspage&logoColor=white)
![Category](https://img.shields.io/badge/Category-CSRF-00d4ff?style=for-the-badge&logo=owasp&logoColor=white)
![Tool](https://img.shields.io/badge/Main%20Tool-Caido-00ff88?style=for-the-badge)

</div>

---

> **CSRF:** forzar al navegador autenticado de una víctima a ejecutar acciones no intencionadas en una aplicación donde está autenticada, sin su conocimiento.

> [!WARNING]
> **Aviso Legal y Ético:** Uso exclusivo en entornos con **autorización explícita por escrito (RoE).** El uso no autorizado constituye un delito penal.

---

## 📑 Tabla de Contenidos

| # | Sección |
|---|---------|
| 01 | [🎯 Labs Objetivo](#-labs-objetivo) |
| 02 | [🛠️ Herramientas](#️-herramientas) |
| 03 | [🔍 Qué Buscar](#-qué-buscar) |
| 04 | [🔁 Flujo con Caido](#-flujo-con-caido) |
| 05 | [🧪 PoC HTML](#-poc-html) |
| 06 | [🧠 Casos Típicos](#-casos-típicos) |
| 07 | [🧭 Ruta de Práctica](#-ruta-de-práctica) |
| 08 | [📝 Checklist](#-checklist) |

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
> Caido Assistant puede generar PoC HTML automáticamente desde `HTTP History` si tienes plan compatible. Usarlo como punto de partida antes de editar manualmente.

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
> La ausencia de un campo `csrf=...` en el body o header es el primer indicador. Confirmar intentando repetir el request desde otra sesión.

---

## 🔁 Flujo con Caido

![Tool](https://img.shields.io/badge/Tool-Caido-00ff88?style=flat-square)

### `[01]` Capturar request sensible

En `HTTP History`, localizar:

- cambio de email
- cambio de password
- update de perfil
- cualquier acción que modifique estado del usuario

### `[02]` Revisar defensas

Buscar en request/response:

- `csrf=...` en body o header
- header `Origin`
- header `Referer`
- atributo `SameSite` en Set-Cookie

### `[03]` Replay de prueba

En `Replay`, probar:

- quitar token CSRF del body
- cambiar método de `POST` a `GET`
- repetir token desde otra sesión
- enviar solo parámetros esenciales sin token

### `[04]` Construir PoC

Crear HTML mínimo con form. Abrir en navegador con sesión activa de víctima en lab.

> [!IMPORTANT]
> Probar PoC en navegador separado o perfil diferente donde la sesión de víctima esté activa. No usar la misma sesión del atacante.

---

## 🧪 PoC HTML

![Context](https://img.shields.io/badge/PoC-HTML-a855f7?style=flat-square)

### `[01]` POST básico — auto-submit

```html
<html>
  <body onload="document.forms[0].submit()">
    <form action="http://lab.local/change-email" method="POST">
      <input type="hidden" name="email" value="attacker@example.local">
    </form>
  </body>
</html>
```

### `[02]` Variante GET

```html
<img src="http://lab.local/change-email?email=attacker@example.local">
```

---

## 🧠 Casos Típicos

| Caso | Qué probar |
|------|------------|
| **Sin token** | PoC directo sin modificaciones |
| **Token opcional** | omitir parámetro del body |
| **Token no ligado a sesión** | reutilizar token desde otra cuenta |
| **Token duplicado cookie/body** | manipular doble envío |
| **SameSite Lax** | navegación top-level GET |
| **Validación Referer débil** | header ausente o bypass parcial |

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
