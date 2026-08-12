---
tipo: endpoint-api
estado: implementado-local-pendiente-uat
tags: [scm, api, materiales, us-010b]
fecha_creacion: 2026-08-03
---

# SCM — Materiales de OF, reserva, emisión y premezcla

Todos los comandos requieren `X-Actor-Id`; los `POST` requieren además
`Idempotency-Key`.

| Método y ruta | Resultado |
|---|---|
| `GET /api/scm/v1/materiales-ejecucion` | Corridas, requerimientos, reservas, emisiones y premezclas. |
| `POST /api/scm/v1/ordenes-fabricacion/{id}/requerimientos-material/generar` | Congela cantidades absolutas desde receta y corrida. |
| `POST /api/scm/v1/corridas-fabricacion/{id}/materiales/reservar` | Reserva todos los componentes atómicamente. |
| `POST /api/scm/v1/reservas-material/{id}/emitir` | Traslada una cantidad reservada a Preparación. |
| `POST /api/scm/v1/emisiones-material/{id}/devolver` | Devuelve cantidad todavía separable. |
| `POST /api/scm/v1/corridas-fabricacion/{id}/premezclas` | Consume emisiones proporcionales y crea WIP genealógico. |

## Payloads mutadores

- emitir/devolver: `cantidad_kg`, `motivo`;
- premezcla: `motivo`, `genealogia_tipo` obligatorio (`EXACTA` o
  `CONJUNTO_CANDIDATOS`) y `ubicacion_codigo` opcional.

Los errores usan el contrato SCM `{ error: { code, message, details } }`. Los
casos de falta de stock, sobreemisión, sobredevolución, receta incompleta o
proporciones incompatibles retornan conflicto y no dejan cambios parciales.
