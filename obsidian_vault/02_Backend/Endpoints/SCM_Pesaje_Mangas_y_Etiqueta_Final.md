---
tipo: documentacion_backend
estado: implementado-local-pendiente-uat
tags: [scm, pesaje, mangas, integracion, etiquetas]
fecha_actualizacion: 2026-07-28
---

# SCM: pesaje de mangas y etiqueta final

## Contratos centrales de estación

| Método | Ruta | Resultado |
|---|---|---|
| `GET` | `/api/integration/v1/manga-labels/{label_id}/resolve` | Contexto autoritativo solo lectura y `can_weigh`. |
| `POST` | `/api/integration/v1/manga-weighings` | Pesaje idempotente y trabajo `POSTPESAJE`. |
| `GET` | `/api/integration/v1/operations/{operation_id}` | Recuperación del acuse central. |
| `GET` | `/api/integration/v1/labels/{label_id}/print-payload` | Payload inmutable de una etiqueta. |

La confirmación requiere token de estación, `Idempotency-Key`, actor central
configurado, `capture_id`, lectura estable, bruto, tara y timestamp con zona.
Central confirma la cantidad asignada; nunca deriva unidades desde kg.

## Flujo local

| Método | Ruta local | Uso |
|---|---|---|
| `POST` | `/api/local/v1/scm/weighing/resolve` | Parsea QR versionado y consulta central. |
| `POST` | `/api/local/v1/scm/weighing/confirm` | Toma el último ticket NET, confirma central e imprime. |
| `GET` | `/api/local/v1/scm/weighing/operations/{id}` | Recupera una operación anterior. |

El frontend no envía el peso visual como autoridad. El backend local toma el
último valor entregado por la balanza y aplica la tara congelada recibida de
central. Si central no responde, no se crea un `Pesaje` SCM local.

## Etiqueta

`POSTPESAJE_TSPL_1` conserva el formato 2-up de 109 × 50 mm. El QR toma como
referencia el sticker productivo anterior:

- nivel de corrección `L`;
- módulo TSPL `4`;
- posición horizontal `X + 120`;
- representación de preview `120 × 120 dots`.

El payload continúa siendo `SCM_MANGA_LABEL`; no se reutiliza el QR legacy
separado por `;`.

## Consulta y corrección humana

| Método | Ruta central | Uso |
|---|---|---|
| `GET` | `/api/scm/v1/mangas/{manga_id}/pesaje` | Devuelve captura original, proyección vigente, etiquetas finales e historial. |
| `POST` | `/api/scm/v1/pesajes/{pesaje_id}/correcciones` | Registra valores propuestos y motivo sin editar el pesaje. |
| `POST` | `/api/scm/v1/correcciones-pesaje/{correccion_id}/aprobar` | Aplica cuatro ojos, invalida la etiqueta anterior y genera una nueva. |

La aprobación actualiza la proyección de la manga, pero mantiene intacta la
fila original de `scm_pesaje_manga`. Mientras US-010I no reciba la manga,
`estado_inventario` sigue siendo `NO_INGRESADA` y no existe movimiento Kardex.
