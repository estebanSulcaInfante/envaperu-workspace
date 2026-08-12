---
tipo: endpoint-api
estado: implementado-local-pendiente-uat
tags: [backend, api, scm, ot, trabajo-color, manga, etiqueta, US-010C, US-010M]
fecha_creacion: 2026-07-28
fecha_actualizacion: 2026-08-09
relaciones:
  - "[[TS-010P_OP_Demanda_OF_OA_y_Migracion_Documental]]"
  - "[[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[TS-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color]]"
  - "[[TS-010M3_Relevos_en_Trabajo_Color]]"
  - "[[Orden_Fabricacion]]"
---

# API SCM: OT, mangas y preetiquetas

Implementación local de [[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]].
Central es autoridad; la estación solo consulta, imprime y acusa.

> [!IMPORTANT] Contrato vigente del piloto
> La OT es la cabecera de máquina/fecha/turno. Cada configuración homogénea de
> OF y color se agrega como Trabajo de color; mangas, cupo, personal y pesaje se
> atribuyen al trabajo exacto. `corrida_fabricacion_id` permanece como identidad
> técnica interna y no es vocabulario requerido en la UI de Planta.

## API humana central

Base: `/api/scm/v1`. El actor se resuelve del contexto SCM y toda mutación
requiere `Idempotency-Key`.

| Método | Ruta | Finalidad |
|---|---|---|
| GET | `/ordenes-fabricacion/{of}/plan-mangas` | Consultar plan y saldo. |
| POST | `/ordenes-fabricacion/{of}/plan-mangas/recalcular` | Crear nueva revisión del plan. |
| POST | `/ots/fabricacion` | Crear/obtener cabecera OT por máquina, fecha y turno. |
| POST | `/ots/{ot_id}/trabajos-color` | Agregar una configuración liberada de OF/color a la cola. |
| POST | `/trabajos-color/{id}/{acción}` | Iniciar, pausar, reanudar, completar o anular el trabajo. |
| POST | `/trabajos-color/{id}/asignaciones` | Asignar o relevar personal y subconjuntos de mangas. |
| POST | `/trabajos-color/{id}/mangas` | Consumir cupo normal del trabajo. |
| GET | `/ots?tipo_ot=FABRICACION&fecha_operativa={fecha}&turno={turno}` | Listar todas las OT del tablero diario. |
| GET | `/ots/{public_id}` | Leer OT, trabajos, asignaciones y mangas. |
| POST | `/ots/{public_id}/iniciar` | Iniciar OT con versión. |
| POST | `/ots/{public_id}/cerrar` | Cerrar si no quedan mangas pendientes. |
| POST | `/ordenes-fabricacion/{of}/ots` | Fachada legacy compatible; crea/usa la misma OT y trabajo. |
| POST | `/ots/{public_id}/mangas-extra/solicitudes` | Solicitar manga extra con motivo. |
| GET | `/mangas-extra/solicitudes?orden_fabricacion_id={of}&estado=PENDIENTE` | Bandeja de autorizaciones. |
| POST | `/mangas-extra/solicitudes/{id}/aprobar` | Aprobación JP y creación extra. |
| POST | `/mangas/{id}/etiquetas-prepesaje` | Generar trabajo de 1–2 etiquetas. |
| POST | `/mangas/{id}/anular` | Anulación lógica autorizada por JP. |
| POST | `/etiquetas/{id}/reemplazos` | Invalidar y crear nueva versión autorizada. |
| GET/POST/PUT/DELETE | `/tipos-manga` | Maestro filtrado `clase=MANGA`. |

Las configuraciones de OF y los Trabajos de color exponen:

- `color` y `color_nombre`: rótulo humano compatible;
- `color_hex`: referencia visual opcional;
- `color_identidad`: `{id,nombre,base,familia,hex}`;
- `asignacion_vigente`: asignación `ACTIVA` o `PREVISTA` del Trabajo de color.

El tablero combina este `GET /ots` con el catálogo de máquinas activas. Una
máquina sin OT es una proyección de consulta: no se persiste ni se crea una OT
implícitamente. `PREETIQUETADA` significa **Con sticker**, no acredita una
manga físicamente abierta o incompleta.

## API técnica central

Base: `/api/integration/v1`; autenticación con token de estación.

| Método | Ruta | Finalidad |
|---|---|---|
| GET | `/stations/{station_id}/print-jobs/{job_id}` | Obtener payload inmutable y hashes. |
| PUT | `/stations/{station_id}/print-jobs/{job_id}/result` | Acusar resultado por etiqueta. |

Estados de acuse: `IMPRESA`, `FALLIDA_SIN_EMISION` y `EMISION_INCIERTA`.
Un fallo sin emisión puede avanzar luego a `IMPRESA`; una impresión o emisión
incierta es terminal y requiere reemplazo autorizado.

## API local de estación

Base: `/api/local/v1`; nunca crea OT, manga ni pesaje.

| Método | Ruta | Finalidad |
|---|---|---|
| GET | `/scm/print-jobs/{job_id}` | Previsualizar payload y TSPL. |
| POST | `/scm/print-jobs/{job_id}/print` | Imprimir, registrar intento local y acusar central. |

La bitácora `scm_label_print_attempt` es append-only e independiente de
`pesajes`. Conserva el hash central y el hash del TSPL exacto; este último
incluye la fecha/hora real de impresión en `America/Lima`. La plantilla vigente
es `PREPESAJE_TSPL_1`.

## Compatibilidad

- Las OF/órdenes técnicas legacy sin molde/snapshots canónicos devuelven `OF_NOT_EXECUTABLE`.
- No se crean asociaciones heurísticas entre pesajes antiguos y mangas.
- La migración conserva todas las filas de pesaje y OT anteriores.
