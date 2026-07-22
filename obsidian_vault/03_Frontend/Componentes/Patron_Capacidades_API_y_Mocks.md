---
tipo: patron-ui
estado: activo
tags: [frontend, componentes, mocks, api, permisos, estados]
relaciones:
  - "[[Vista_US-010B_Preparacion_Materiales]]"
  - "[[Vista_US-010A_Recepcion_Materiales]]"
fecha_creacion: 2026-07-15
---

# Patrón — Capacidades, API y Datos Mock

## Objetivo

Permitir que el frontend avance antes que todas las APIs sin comunicar acciones falsas ni confundir limitaciones técnicas con permisos de usuario o reglas de negocio.

## Dos Dimensiones Independientes

La fuente de lectura y la capacidad de ejecutar un comando no son el mismo dato:

| Dimensión | Valores mínimos | Ejemplo |
| :--- | :--- | :--- |
| Fuente de datos | `MOCK`, `API`, `MIXTA` | La bandeja se alimenta con fixtures. |
| Disponibilidad del comando | API disponible, actor autorizado y estado válido | Reservar requiere las tres condiciones. |

Un badge `MOCK` informa de dónde provienen los datos. El candado informa que un comando todavía no posee API. Ninguno sustituye al otro.

## Semántica Visual

| Condición | Presentación | Mensaje accesible |
| :--- | :--- | :--- |
| API del comando pendiente | Botón deshabilitado con icono de candado | `<acción> (API pendiente)` |
| API disponible, actor sin permiso | Botón deshabilitado con icono de protección o acceso | `No tienes permiso para <acción>` |
| Estado de negocio incompatible | Botón deshabilitado sin candado técnico | Motivo concreto, por ejemplo `El lote está bloqueado por Calidad` |
| Solicitud en curso | Progreso y prevención de doble envío | `Procesando <acción>` |
| Datos mock | Indicador visible en la vista | `Datos de demostración` |

No debe usarse el candado de API pendiente para representar un lote bloqueado por Calidad, falta de permiso o formulario inválido.

## Regla de Escritura

Mientras una capacidad tenga `apiReady = false`:

1. El control permanece deshabilitado.
2. No se modifica el fixture para aparentar persistencia.
3. No se muestra una confirmación de éxito.
4. La pantalla puede enseñar el resultado esperado como un estado de lectura previamente preparado.

El componente actual `frontend/src/components/ApiPendingButton.jsx` implementa el caso de API pendiente para el mock de US-010B.

## Promoción a API Real

Una capacidad puede marcarse disponible cuando existen:

- contrato y errores funcionales definidos;
- autenticación y autorización aplicadas;
- validación del estado de negocio vigente;
- protección de idempotencia cuando corresponda;
- manejo visible de carga, conflicto y fallo;
- prueba de integración que demuestre el cambio persistido.

La disponibilidad debe derivarse al menos de `apiReady`, permiso del actor y validez del estado. Evitar un único booleano ambiguo que mezcle estas causas.

