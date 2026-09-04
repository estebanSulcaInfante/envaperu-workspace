---
tipo: tech-spec
estado: implementada-local-pendiente-uat
historia: "[[US-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
tags: [scm, fabricacion, pesaje-control, manga, continuidad, postgres, api, estacion, tdd]
relaciones:
  - "[[2026-08-26_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
  - "[[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final]]"
  - "[[TS-010M3_Relevos_en_Trabajo_Color]]"
  - "[[Asignacion_Trabajo_OT]]"
  - "[[DEV-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
fecha_creacion: 2026-08-26
fecha_actualizacion: 2026-08-26
---

# TS-010K1: Corte acumulado y continuidad de manga entre OT

## 1. Objetivo técnico

Agregar controles acumulados `0..N` y continuidad multi-OT a una manga simple
sin debilitar el `UNIQUE(manga_id)` del pesaje final. Central conserva la
identidad física y el origen de la manga, crea tramos auditados, enlaza el
remanente a un Trabajo destino compatible y, al final, atribuye el único total
confirmado entre todos los tramos.

## 2. Baseline y frontera

La primera RED parte de M1–M3 y D-core verdes:

- una manga preetiquetada admite un único final por F2;
- `ScmPesajeManga` acredita, genera postetiqueta y deja pendiente de Almacén;
- el cruce de OT responde hoy `MULTI_SHIFT_BAG_NOT_ENABLED`;
- el cierre final parcial supervisado continúa disponible como flujo separado.

K1 no reutiliza `scm_pesaje_manga` para controles, no agrega otro final y no
implementa reapertura, manga de Armado, offline ni meta de cambio de color.

## 3. Persistencia

### 3.1. `scm_tramo_manga_trabajo`

Historial autoritativo de los contextos que contribuyen a una manga.

| Campo | Regla |
|---|---|
| `id` | UUID público estable. |
| `manga_id`, `secuencia` | Identidad y orden del tramo; combinación única. |
| `trabajo_ot_id` | Trabajo de color efectivo; su relación deriva la OT. |
| `asignacion_personal_trabajo_id` | Responsable productivo, distinto del actor de Balanza y del supervisor. |
| `asignacion_plan_id` | Asignación de plan contra la que se atribuye el tramo. |
| `cantidad_inicio_un` | Frontera inicial; cero en el primer tramo. |
| `cantidad_fin_un` | Frontera final; nula mientras está abierto. |
| `cantidad_atribuida_un` | Cero antes del final; aporte confirmado después de reconciliar la manga. |
| `estado` | `PROGRAMADO`, `ACTIVO`, `CERRADO` o `ANULADO`. |
| `iniciada_at`, `cerrada_at`, `motivo_cierre` | Intervalo auditado y explicación. |
| `created_by_id`, `operation_id`, `created_at` | Autoridad, idempotencia y auditoría. |

Restricciones persistidas y validaciones transaccionales:

- un solo tramo `PROGRAMADO` o `ACTIVO` por manga mediante índice parcial;
- FKs independientes a manga, Trabajo, asignación personal y plan; secuencia
  única por manga y `fin > inicio` cuando existe cierre;
- bajo bloqueo de manga/tramos, el servicio valida que la asignación pertenezca
  al Trabajo, que las fronteras sean contiguas y que la suma reconcilie;
- no existe endpoint de `DELETE`; cada cierre se fija una sola vez y cualquier
  corrección futura es compensatoria, no una reescritura histórica.

K1 no promete FKs compuestas ni un trigger de contigüidad entre filas en esta
migración. Esas defensas pueden endurecerse en un enabler posterior sin cambiar
el contrato funcional.

`scm_manga.ot_id`, `trabajo_ot_id` y `asignacion_id` conservan el **origen
inmutable**. El contexto
vigente se resuelve desde el último tramo. Si una manga preexistente todavía no
tiene tramos, el primer control K1 crea de forma perezosa su tramo origen a
partir de esas relaciones inmutables; la migración no fabrica cortes
históricos.

### 3.2. `scm_control_peso_manga`

Hecho append-only separado del final.

| Campo | Regla |
|---|---|
| `id`, `public_id` | Identidades interna y pública. |
| `manga_id`, `tramo_id` | Manga y contexto resuelto por Central. |
| `operation_id`, `source_system`, `capture_id` | Únicos; soportan replay sin duplicar. |
| `station_id` | Estación autenticada que originó la captura. |
| `tipo` | Valor fijo `CORTE_TURNO`. |
| `peso_bruto_kg`, `tara_kg`, `peso_neto_kg` | Lectura acumulada estable; neto = bruto − tara. |
| `tara_fuente` | Fuente gobernada de la tara aplicada. |
| `conteo_acumulado_un` | Conteo absoluto observado; no producción acreditada. |
| `motivo` | Obligatorio; `CAMBIO_TURNO` en el camino UAT. |
| `pesado_at`, `fecha_local_pesaje`, `timezone_snapshot` | Tiempo físico y contexto local. |
| `pesado_por_id` | Actor de Balanza separado del responsable del tramo. |

Existe como máximo un corte de turno por tramo; una manga puede acumular varios
controles a través de tramos sucesivos. Un control no tiene FK de postetiqueta,
existencia o movimiento y no modifica
`cantidad_confirmada_un`. El servicio expone explícitamente
`produccion_confirmada_un: "0"`, `inventario_creado: false` y
`print_job_id: null`.

### 3.3. Estado y final

El corte cierra el tramo vigente y lleva la manga a
`CONTINUIDAD_PENDIENTE`; sigue físicamente abierta, pero no admite otra
ejecución hasta que el supervisor seleccione un destino. La vinculación crea el
siguiente tramo `PROGRAMADO` y deja la manga `EN_LLENADO`. La misma
preetiqueta y QR siguen vigentes.

El control tipo `CORTE_TURNO` pausa en la misma transacción el Trabajo origen y
cierra su asignación personal activa. Al vincular el destino, el origen queda
resuelto y puede completarse/cerrarse. Iniciar el Trabajo destino cambia su
tramo de `PROGRAMADO` a `ACTIVO` y conserva la exclusividad por máquina.

`scm_pesaje_manga` continúa siendo el único hecho final y conserva su
restricción única por manga. Al confirmar F2, Central bloquea manga y tramo
abierto, cierra el tramo en la cantidad total final y valida:

```text
aporte_tramo_un = cantidad_fin_un - cantidad_inicio_un
SUM(aporte_tramo_un) = cantidad_confirmada_final_un
```

El neto final también debe ser acumulado y superar el último control. La misma
guarda se reaplica al aprobar una corrección de bruto/tara para impedir que el
delta del último turno sustituya al peso total físico.

En el dataset K1 los aportes son `20` y `30`; no se suma además `50` al Trabajo
de origen. La cantidad final es el único crédito de producción. Las
proyecciones por OT/Trabajo/trabajador agregan los aportes de tramo, mientras la
proyección de manga conserva un solo total físico de `50 UN` y un solo peso
final. La respuesta de F2 expone el desglose en `atribucion_turnos`.

## 4. Contratos de estación

### 4.1. Acción local

`POST /api/local/v1/scm/weighing/controls`

Requiere `Idempotency-Key` UUID. La estación usa la misma UUID como
`capture_id`, exige balanza estable y envía a Central:

```json
{
  "label_id": "<UUID_PREPESAJE>",
  "capture_id": "<UUID_OPERACION>",
  "peso_bruto_kg": "4.830",
  "tara_kg": "0.030",
  "tara_fuente": "TIPO_MANGA",
  "pesada_at": "2026-08-26T14:00:00-05:00",
  "pesado_por_id": 3,
  "reading_stable": true,
  "conteo_acumulado_un": "20",
  "motivo": "CAMBIO_TURNO"
}
```

La estación no envía `tramo_id`: Central resuelve el tramo vigente a partir de
la etiqueta y el agregado bloqueado.

Respuesta mínima local:

```json
{
  "operation_id": "<UUID_OPERACION>",
  "control": {},
  "manga": {},
  "produccion_confirmada_un": "0",
  "inventario_creado": false,
  "print_job_id": null,
  "qr_preservado": true,
  "continuidad_estado": "PENDIENTE_VINCULO",
  "idempotent_replay": false
}
```

Errores previos a Central: `INVALID_UUID`, `CONTROL_COUNT_REQUIRED`,
`MANGA_NOT_READY` y `SCALE_READING_UNSTABLE`.

### 4.2. Integración central

`POST /integration/v1/manga-weighing-controls`

Usa autenticación de estación e idempotencia central. Bajo lock valida etiqueta
PREPESAJE vigente, manga abierta, ausencia de final, tramo abierto, pesos y
conteo monotónico. Inserta un solo control, cierra el tramo de frontera, pausa
el Trabajo/asignación origen y responde sin trabajo de impresión.

Repetir la misma clave y payload devuelve el mismo control. La misma clave con
otro contenido produce conflicto. Central caída bloquea la acción; K1 no guarda
un control SCM offline.

F2 conserva `POST /integration/v1/manga-weighings` como contrato exclusivo del
final. Resolver el QR después de un control devuelve el último control y el
contexto del tramo vigente, pero no altera el payload físico del QR.

## 5. Continuidad en Central

### 5.1. Consulta de candidatas

`GET /scm/v1/ots/{ot_id}/continuidades-pendientes?corrida_fabricacion_id=...`

`ot_id` es la OT **destino**. La consulta devuelve solo mangas abiertas de la
corrida exacta que pueden continuar allí e incluye manga/QR, origen, tramo
vigente, último control, conteo de frontera, responsable actual y saldo.

El último control válido es la autoridad de frontera. La UI no pide volver a
escribir `20`; el POST vuelve a resolverlo y rechaza una candidata si otro
control o transición la dejó obsoleta.

La compatibilidad exige simultáneamente:

- misma `corrida_fabricacion_id` y, por ella, misma OF exacta;
- misma máquina;
- la propia identidad, salida, artículo/PiezaColor, color, perfil de empaque,
  tipo y tara congelados de la manga;
- OT destino distinta y estrictamente posterior por fecha/secuencia de turno;
- destino `PLANIFICADA` o `EN_EJECUCION`.

Una manga ya iniciada hereda la línea de plan y los snapshots físicos con los
que nació. Si el plan activo se recalcula después con otra regla de empaque, no
se reescribe ni se migra esa manga a la regla nueva: el vínculo mueve su
remanente sobre la línea histórica. La nueva regla rige mangas creadas después.

### 5.2. Creación atómica del Trabajo destino

No se crea un endpoint de transferencia por manga en K1. El camino autoritativo
es el contrato existente ampliado:

`POST /scm/v1/ots/{ot_id}/trabajos-color`

```json
{
  "corrida_fabricacion_id": "<UUID_CORRIDA>",
  "maquinista_id": 5,
  "asignaciones": [],
  "continuidad_manga_ids": ["<UUID_MANGA_ABIERTA>"]
}
```

`asignaciones` puede ser `[]` cuando `continuidad_manga_ids` contiene por lo
menos una manga válida. En una sola transacción el servicio:

1. bloquea OT destino, corrida, plan, manga y tramo vigente;
2. vuelve a validar compatibilidad y orden temporal, sin confiar en el GET;
3. crea el Trabajo destino y su asignación personal para Pedro;
4. cierra el tramo origen en `20 UN` y abre el destino desde `20 UN`;
5. mueve el remanente objetivo de `30 UN` desde la asignación del plan origen a
   la asignación del Trabajo destino;
6. conserva manga, QR y campos de origen inmutables;
7. deja el origen resoluble para completar/cerrar;
8. crea cero mangas y cero trabajos de impresión.

`mangas_asignadas` cuenta la identidad una sola vez en origen; la OT destino la
muestra como continuidad, no como otra manga planificada. El tramo destino
guarda la asignación de plan que recibió el saldo.

La autorización del supervisor con `MANGA_TRANSFERIR_OT` es suficiente. Pedro
es responsable del nuevo tramo, no aprobador de la operación, y no existe
endpoint ni estado `ACEPTACION_PENDIENTE`.

El vínculo no omite la exclusividad de máquina. El Trabajo origen se pausa al
terminar el turno y el destino debe iniciarse antes de continuar; nunca quedan
dos Trabajos `EN_EJECUCION` en `INY-01`.

## 6. Concurrencia, errores y atomicidad

| Error | Condición |
|---|---|
| `CONTROL_COUNT_REQUIRED` | La estación no recibió conteo acumulado. |
| `MANGA_NOT_READY` | QR/manga no admite el corte o final solicitado. |
| `MANGA_ALREADY_WEIGHED` | Ya existe el final único. |
| `MANGA_CONTINUITY_NOT_ACTIVE` | Se intenta otro corte sin vincular/iniciar el tramo siguiente. |
| `COLOR_WORK_NOT_WEIGHABLE` | El Trabajo vigente no está ejecutándose ni pausado. |
| `INVALID_SHIFT_BOUNDARY_COUNT` | El conteo no avanza o ya alcanza/supera el final. |
| `CONTROL_WEIGHT_NOT_MONOTONIC` | El neto acumulado no supera el control anterior. |
| `FINAL_WEIGHT_NOT_CUMULATIVE` | El final o su corrección no supera el último control acumulado. |
| `MANGA_CONTINUITY_NOT_PENDING` | No existe un tramo cerrado con control vigente. |
| `CONTINUITY_TARGET_SAME_OT` | Destino y origen pertenecen a la misma OT. |
| `CONTINUITY_TARGET_PRECEDES_SOURCE` | La OT destino no es posterior por fecha/turno. |
| `CONTINUITY_MACHINE_MISMATCH` | La máquina destino no coincide. |
| `CONTINUITY_CONTEXT_MISMATCH` | Difieren OF/corrida, color, receta, salida o snapshots. |
| `DUPLICATE_CONTINUITY_MANGA` | El payload repite la misma manga. |
| `MANGA_ALREADY_COMPLETE` | El control de frontera ya alcanzó el objetivo. |
| `PLAN_ASSIGNMENT_INCONSISTENT` | El origen no posee el remanente que se pretende mover. |
| `REQUIRED_FIELD` | No se asignó plan nuevo ni se eligió continuidad. |
| `CONTINUITY_SEGMENTS_INCONSISTENT` | Los tramos no forman fronteras contiguas. |
| `CONTINUITY_ATTRIBUTION_MISMATCH` | La suma por tramos no coincide con el final único. |

Dos controles concurrentes se serializan por manga/tramo y conservan una
secuencia única. Transferencia y F2 concurrentes solo pueden dejar uno de estos
resultados completos: manga todavía abierta en el tramo destino o manga
finalizada en el tramo origen. Nunca persisten medio traslado, dos finales o
dos créditos.

## 7. UI

### Estación

- F2 mantiene el texto y comportamiento de cierre final con impresión.
- Acción separada, sin atajo F2: `Registrar corte de turno — continúa abierta`.
- Exige conteo acumulado y motivo; usa la lectura estable visible.
- Éxito: `CORTE GUARDADO · CONTINÚA ABIERTA · USE EL MISMO QR`.
- No muestra preview ni cola de impresión después del control.

### Central

- al agregar el mismo color en una OT posterior, consulta continuidades
  pendientes y permite seleccionar la manga abierta;
- muestra que el control pausó automáticamente el Trabajo origen;
- diferencia `Asignar mangas nuevas` de `Continuar manga existente`;
- permite `asignaciones: []` cuando solo se continúa una manga;
- muestra origen, último corte, saldo `30 UN`, destino y responsable Pedro;
- después del POST informa que no requiere aceptación ni nueva etiqueta;
- permite completar/cerrar el origen, e iniciar después el destino para activar
  el tramo de Pedro;
- al final muestra el único total `50 UN` y desglose Jose `20` / Pedro `30`.

## 8. Mapa ATDD a pruebas

| Escenario | Nivel obligatorio |
|---|---|
| K1-01 | integración central + contrato estación: control, cero efectos laterales |
| K1-02 | unidad/proyección: último acumulado, nunca suma histórica |
| K1-03 | integración: GET candidata + POST Trabajo atómico, sin aceptación |
| K1-04 | matriz de contrato: corrida/máquina/snapshot/orden temporal incompatibles |
| K1-05 | integración PostgreSQL: final único y atribución `20/30` |
| K1-06 | idempotencia y concurrencia: replay de control, traslado y final |
| K1-07 | contrato Almacén: manga abierta (`CONTINUIDAD_PENDIENTE`/`EN_LLENADO`) no recepcionable |
| K1-08 | integración Kardex: un ingreso de `50 UN` después del final |

Primera RED: K1-01 debe demostrar que el contrato actual solo acepta un final,
por lo que no puede guardar el corte de `20 UN` sin acreditar ni imprimir.

## 9. Migración y compatibilidad

1. Crear tablas, constraints e índices sin cambiar finales históricos.
2. Crear el tramo origen al primer control para una manga elegible sin tramo;
   una manga `PESADA`, `RECIBIDA` o `ANULADA` no se vuelve a abrir.
3. Desplegar Central antes de la estación que expone la nueva acción.
4. Mantener F2 y postetiquetas compatibles con D-core.
5. Exponer controles/tramos en detalle y observabilidad sin sumarlos a métricas
   confirmadas.

Rollback de aplicación deja de ofrecer controles nuevos, pero conserva y puede
leer los hechos ya creados. No se borran tablas ni se degrada una manga abierta
silenciosamente a `PREETIQUETADA`.

## 10. Definition of Done

- [ ] K1-01…K1-08 verdes en sus niveles asignados.
- [ ] Migración y carreras validadas en PostgreSQL real.
- [x] `scm_pesaje_manga` conserva un final máximo por manga.
- [x] Control responde cero crédito, cero impresión y cero inventario.
- [x] GET y POST validan compatibilidad; el POST es la autoridad atómica.
- [x] `asignaciones: []` con continuidad no crea una manga nueva.
- [x] Pedro continúa sin aceptación y sin cambio de QR.
- [x] Final `50` produce exactamente atribuciones `20/30`.
- [ ] UAT remota de piezas registra evidencias antes y después del final.
