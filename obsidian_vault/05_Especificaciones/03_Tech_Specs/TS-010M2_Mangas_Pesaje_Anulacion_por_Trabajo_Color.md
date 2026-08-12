---
tipo: tech-spec
estado: implementada-local-pendiente-uat
tags: [scm, trabajo-color, manga, qr, pesaje, anulacion, kardex, tdd]
relaciones:
  - "[[US-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color]]"
  - "[[DEV-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color]]"
  - "[[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[Baseline_TS-010R_C_D_2026-07-24]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# TS-010M2: Mangas, pesaje y anulación por Trabajo de color

## 1. Objetivo técnico

Cambiar el padre atómico de planificación y ejecución desde OT a Trabajo de
color sin modificar la identidad física de manga ni duplicar pesajes,
recepciones o movimientos compensatorios.

## 2. Baseline

Hereda la baseline verde de [[Baseline_TS-010R_C_D_2026-07-24]] y exige
reejecutar central, PostgreSQL, frontend, estación y E2E con los comandos de
TS-010M1 antes del primer RED. M2 no comienza si M1 no está verde.

## 3. Persistencia y contratos

- La tabla física actual `scm_manga` añade `trabajo_ot_id` obligatorio para
  mangas SCM nuevas de Fabricación. La API visible serializa ese hijo
  especializado como `trabajo_color_id`. Conceptualmente continúa siendo una
  [[Unidad_Logistica]], pero esta TS no inventa una tabla
  `scm_unidad_logistica`.
- asignación de plan, saldo/cupo y solicitud extra usan físicamente
  `trabajo_ot_id` y una salida exacta; la API los presenta como contexto de
  Trabajo de color;
- pesaje, etiqueta final, recepción y movimiento conservan el trabajo derivado
  de la manga como referencia inmutable o snapshot auditable;
- `ot_id` permanece como contexto agregado y compatibilidad, nunca como origen
  suficiente para determinar color o corrida;
- índices evitan doble cupo, doble pesaje vigente y más de una compensación por
  la misma operación.

El QR conserva `manga_id` y `label_id`; añade versión de contrato y contexto de
Trabajo de color firmado por central. El código humano puede seguir
`OF…-OT…-M…`; no se parsea para reconstruir relaciones.

## 4. API

Salvo las rutas de estación que muestran el prefijo completo, las rutas de
negocio usan base `/api/scm/v1` y adaptan contratos ya existentes:

| Método | Ruta | Regla |
|---|---|---|
| GET | `/ordenes-fabricacion/{of}/plan-mangas` | Consulta el plan agregado vigente. |
| POST | `/ordenes-fabricacion/{of}/plan-mangas/recalcular` | Recalcula revisión del plan agregado. |
| POST | `/trabajos-color/{id}/mangas` | Materializa manga normal para salida exacta. |
| POST | `/ots/{id}/mangas-extra/solicitudes` | Fachada vigente de solicitud extra; el servicio exige Trabajo de color/salida. |
| POST | `/mangas/{id}/etiquetas-prepesaje` | Genera etiqueta para el mismo trabajo. |
| GET | `/api/integration/v1/manga-labels/{label_id}/resolve` | Estación autenticada resuelve contexto de solo lectura. |
| POST | `/api/integration/v1/manga-weighings` | Estación confirma el pesaje idempotente actual. |
| POST | `/pesajes/{id}/anular` | `ANULAR_PESAJE` compensatorio. |
| POST | `/recepcion-mangas/{existence_id}/reversiones` | Solicita/ejecuta la reversa previa gobernada. |

`GET /ots` incluye `trabajos_color[]`, saldos y mangas resumidas. La fachada
legacy `/ordenes-fabricacion/{of}/ots` permanece. Los `DELETE` directos responden `405` o `DIRECT_DELETE_FORBIDDEN` para todos los
perfiles. La autorización nunca depende de ocultar el botón.

## 5. Transacción de anulación

Con locks sobre manga, pesaje vigente, asignación de cupo, recepción y trabajo:

1. validar idempotencia, actor, motivo y versión;
2. rechazar con `RECEIPT_REVERSAL_REQUIRED` si existe recepción vigente;
3. conservar pesaje original y registrar compensación;
4. invalidar etiquetas/QR vigentes correspondientes;
5. marcar la manga anulada;
6. devolver exactamente una vez cantidad y cupo al Trabajo de color;
7. recalcular proyección de trabajo y OT;
8. permitir una nueva manga normal desde el saldo liberado.

Una respuesta perdida devuelve el mismo resultado. Ningún paso se publica de
forma parcial.

## 6. Estación, etiqueta y recepción

Al escanear, central devuelve OT, Trabajo de color, OF/corrida, máquina,
PiezaColor/salida, color, cantidad, tipo y responsable vigente como solo
lectura. F2 nunca acepta reemplazar esos IDs. La postetiqueta conserva el mismo
`manga_id`.

La elegibilidad depende del estado de la manga y sus identidades, no de que el
trabajo continúe activo en máquina. `PAUSADO` acepta pesaje final de mangas ya
cerradas; `COMPLETADO` solo se alcanza después de resolver sus mangas.

Recepción y Kardex nacen después del pesaje, como hoy, pero la genealogía
incluye Trabajo de color. Calidad no altera su atribución productiva.

## 7. Material ordinario

Requerimientos, reservas y emisiones existentes siguen planificados por
OF/corrida. El Trabajo de color resuelve ese contexto mediante
`corrida_fabricacion_id`; esta TS no agrega `trabajo_color_id` a emisiones ni
crea un nuevo hecho de consumo. A → B → A no regenera requerimientos.

Quedan prohibidos: lote preparado almacenable, aporte experimental,
generaciones R1…Rn y otra balanza.

## 8. Migración

Backfill enlaza `scm_manga.trabajo_ot_id`, asignación de cupo, solicitud extra
y snapshot de pesaje al único `scm_trabajo_ot` tipo `COLOR` creado para su OT
histórica por M1. La API serializa `trabajo_color_id`; no existe una segunda FK
física con ese nombre. Si una relación es ambigua, la migración falla con
reporte; no elige por texto. Se preservan stickers 11213–11216, UUID, códigos y
`payload_json`.

## 9. Mapa ATDD → pruebas

| Escenario | Nivel y evidencia |
|---|---|
| M2-01 | contrato estación + UI: QR resuelve trabajo exacto |
| M2-02 | integración/idempotencia: un pesaje y una postetiqueta |
| M2-03 | PostgreSQL: salida multipieza y cupos separados |
| M2-04 | integración transaccional: anulación y reemplazo normal |
| M2-05 | integración recepción: reversa obligatoria |
| M2-06 | autorización/API/UI: eliminación bloqueada para todos |
| M2-07 | regresión US-010B: vínculo por corrida y cero requerimientos duplicados |
| M2-08 | migración/contrato: stickers e IDs históricos preservados |
| M2-09 | integración central-estación: trabajo pausado elegible mientras otro está activo |

Primera prueba RED: `M2-01`, porque la manga vigente deriva corrida/color
directamente desde `manga.ot`.

## 10. Definition of Done

- [ ] Baseline M1 y C/D/I verde.
- [ ] M2-01…M2-09 automatizados.
- [ ] Fallos/reintentos no duplican pesaje, cupo ni movimiento.
- [ ] Estación no introduce campos manuales de contexto.
- [ ] Anulación antes/después de Almacén probada en PostgreSQL.
- [ ] IDs 11213–11216 conciliados sin reasignación heurística.
- [ ] Sin implementación de US-010K o US-010L.
