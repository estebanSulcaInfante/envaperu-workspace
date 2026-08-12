---
tipo: endpoints
estado: implementado-local
tags: [scm, almacen, mangas, qr, kardex, calidad]
tech_spec: "[[TS-010I_Recepcion_Mangas_y_Nacimiento_Kardex]]"
fecha_creacion: 2026-08-03
fecha_actualizacion: 2026-08-03
---

# SCM — Recepción de Mangas y Kardex

Base: `/api/scm/v1`.

| Método | Ruta | Resultado |
|---|---|---|
| `GET` | `/recepcion-mangas` | pendientes, recibidas, rechazos y ubicaciones |
| `GET` | `/recepcion-mangas/resolver-etiqueta/{label_id}` | contexto productivo no editable |
| `GET` | `/recepcion-mangas/resolver-codigo/{codigo}` | resolución manual autorizada |
| `POST` | `/recepcion-mangas/sesiones` | abre agrupador operativo |
| `POST` | `/recepcion-mangas/sesiones/{id}/cerrar` | cierra sesión propia |
| `POST` | `/recepcion-mangas/confirmar` | existencia + movimiento + Calidad pendiente |
| `POST` | `/recepcion-mangas/rechazar` | evidencia sin crear inventario |
| `POST` | `/recepcion-mangas/{existencia_id}/calidad` | libera, bloquea o rechaza |

Todos los comandos usan `X-Actor-Id` e `Idempotency-Key`. La confirmación
requiere los tres checks físicos y una ubicación compatible. Calidad modifica
disponibilidad, no existencia física.

