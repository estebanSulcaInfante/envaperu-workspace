---
tipo: tech-spec
estado: implementada-local-pendiente-uat
tags: [scm, ot, trabajo-color, postgresql, api, ui, tdd]
relaciones:
  - "[[US-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[DEV-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[Baseline_TS-010R_C_D_2026-07-24]]"
  - "[[Trabajo_OT]]"
  - "[[Trabajo_Color]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-09
---

# TS-010M1: OT de máquina y cola de Trabajos de color

## 1. Objetivo técnico

Separar la envolvente diaria de máquina de la ejecución atómica de una
OF/corrida mediante los hijos físicos `scm_trabajo_ot` y
`scm_trabajo_color`, preservando `RegistroDiarioProduccion` como cabecera OT y
el contrato histórico durante una migración expandible.

## 2. Baseline de ingreso

La última línea base integral registrada está **verde** en
[[Baseline_TS-010R_C_D_2026-07-24]]: backend central, PostgreSQL, frontend,
backend/frontend de estación, builds y E2E. Antes del primer RED se deben
repetir los comandos canónicos:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test.ps1 -Component backend
powershell -ExecutionPolicy Bypass -File .\scripts\test.ps1 -Component pesaje
powershell -ExecutionPolicy Bypass -File .\scripts\test.ps1 -Component frontend
cd .\modulo-pesaje\frontend
npm test -- --run
npm run build
```

Si la reejecución no queda verde, se registra una nueva baseline y se detiene el
RED. No se normaliza un fallo preexistente como parte de M1.

## 3. Persistencia objetivo

### Cabecera física `RegistroDiarioProduccion`

Conserva la identidad de dominio **OT**, `codigo_ot`, máquina/centro, fecha operativa, turno,
proceso, responsable predeterminado opcional, estado agregado, versión y
auditoría. Una restricción parcial evita más de una OT vigente por
`(maquina_id, fecha_operativa, turno, proceso)` únicamente para cabeceras
nuevas normalizadas sin `orden_id`/OF/corrida directos. Las cabeceras legacy
quedan excluidas de esa unicidad.

Durante expand/cutover no se crea `scm_orden_trabajo`: se evoluciona la tabla
física legacy `registro_diario_produccion` mediante campos compatibles y
relaciones hijas. El contrato expone OT, nunca “Registro Diario” como otro
agregado.

### `scm_trabajo_ot`

| Campo | Regla |
|---|---|
| `id` | UUID estable; la API visible lo serializa como `trabajo_color_id`. |
| `ot_id` | FK obligatoria a la envolvente. |
| `tipo` | En este incremento solo `COLOR`. |
| `secuencia` | Única dentro de OT y asignada incrementalmente; append-only en el piloto. |
| `estado` | Persistidos: `PLANIFICADO`, `EN_EJECUCION`, `PAUSADO`, `COMPLETADO`, `ANULADO`. |
| `orden_operacion_id` | Operación técnica liberada. |
| `cantidad_objetivo_un`, `cantidad_confirmada_un` | Objetivo propio y proyección desde hechos. |
| `version` | Control optimista. |
| tiempos/auditoría | creación, inicio, pausa, finalización y actor. |

La tabla enlaza directamente `registro_diario_produccion.id`. No sustituye ni
duplica la cabecera OT.

### `scm_trabajo_color`

Especialización 1:1 cuyo PK/FK es `trabajo_ot_id`. Conserva la corrida; la OF se
resuelve por la orden operativa/corrida, junto con snapshots técnicos, molde,
ruta, color/receta derivados y límite de Calidad. Un constraint o validación
transaccional confirma que la corrida pertenece a la OF. `LISTO` y `BLOQUEADO`
son proyecciones de condiciones, no estados persistidos.

### Cambio de configuración

El cambio A → B se conserva mediante los eventos auditados de pausa, inicio y
reanudación, con motivo y timestamps. La merma de purga utiliza el registro de
merma recuperable vigente cuando corresponda. Esta TS no crea una tabla nueva
de cambio de configuración ni material preparado.

## 4. Concurrencia y estados

- Iniciar toma lock de máquina y OT en PostgreSQL.
- Un índice/guardia transaccional impide dos trabajos activos en la máquina.
- Esa exclusión no se reutiliza como guardia de Balanza: el pesaje de una manga
  cerrada puede pertenecer a un trabajo `PAUSADO` mientras otro está activo.
- Todos los comandos aceptan `Idempotency-Key` y `expected_version`.
- La OT recalcula su estado dentro de la misma transacción; sus métricas no
  admiten `PUT` directo.
- `COMPLETADO` no se reabre silenciosamente. Una compensación crea evento y,
  cuando corresponda, un trabajo continuación.

## 5. API central

Base `/api/scm/v1`:

| Método | Ruta | Resultado |
|---|---|---|
| POST | `/ots/fabricacion` | Crear/obtener OT idempotente por clave operativa. |
| GET | `/ots?fecha=&maquina=&turno=` | Cabecera OT con `trabajos_color[]`. |
| POST | `/ots/{ot_id}/trabajos-color` | Agregar corrida compatible y su secuencia. |
| POST | `/trabajos-color/{id}/iniciar` | Activar con exclusión de máquina. |
| POST | `/trabajos-color/{id}/pausar` | Cerrar intervalo con motivo. |
| POST | `/trabajos-color/{id}/reanudar` | Continuar si el contexto sigue vigente. |
| POST | `/trabajos-color/{id}/completar` | Resolver saldo y finalizar. |
| POST | `/trabajos-color/{id}/anular` | Anulación auditada sin borrado. |

La fachada histórica `POST /ordenes-fabricacion/{of}/ots` permanece durante el
cutover y crea/usa la misma cabecera y el mismo trabajo; nunca crea dos
agregados. Una continuación se crea mediante
`POST /ots/{ot_id}/trabajos-color` indicando `continua_de_id`.

La proyección de una configuración de OF entrega `color_identidad` como
`{id, nombre, base:{id,nombre}, familia:{id,nombre}, hex}` y mantiene los
aliases aditivos `color`, `color_nombre` y `color_hex`. El `codigo` técnico
de `ScmCorridaFabricacion` permanece en el contrato para trazabilidad y
compatibilidad, pero no es el rótulo principal de la UI. `GET /ots` conserva
trabajos, asignación vigente y mangas para derivar progreso; el tablero combina
esa respuesta con el catálogo de máquinas activas y no persiste tarjetas vacías.

## 6. UI

La vista muestra primero un tablero para la fecha y turno consultados, con una
tarjeta por máquina activa. Una tarjeta con OT presenta código/estado,
responsable, Trabajo de color activo, artículo/OF, mangas cerradas/con sticker/
pendientes, siguiente trabajo y alertas; una tarjeta sin OT presenta el estado
vacío accionable. Seleccionarla abre el detalle y la cola existentes. Si el
backfill encuentra más de una OT legacy para la misma máquina/fecha/turno, la
tarjeta no descarta ninguna: muestra el conflicto, permite escoger la OT y lo
trata como condición de conciliación; la unicidad continúa rigiendo las
cabeceras normalizadas nuevas.
Las máquinas inactivas no se ofrecen para crear una jornada nueva. Si una OT
consultada ya referencia una máquina que fue desactivada, su tarjeta permanece
visible con alerta para no ocultar historia ni trabajo pendiente.

Los conteos de manga de la tarjeta pertenecen únicamente al Trabajo de color
actual/pausado que la tarjeta nombra. No mezclan mangas de colores completados
ni del siguiente trabajo; los totales de toda la OT quedan en el detalle.

La proyección no inventa un estado físico: `PREETIQUETADA` se rotula **Con
sticker**, no **Abierta**. **En llenado** se utiliza únicamente cuando exista un
estado explícito `ABIERTA`, `INCOMPLETA` o `PESAJE_PARCIAL`; mientras
[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]] permanezca
fuera del corte, el tablero separa **Cerradas**, **Con sticker** y **Pendientes**.
Del mismo modo, **Produciendo/En ejecución** se muestra solo si existe un
Trabajo de color hijo `EN_EJECUCION`; el estado agregado de la cabecera OT no
basta para afirmar actividad actual de la máquina.

En el formulario, una única configuración liberada se presenta como **Color a
fabricar** de solo lectura. Con varias se utiliza un selector por nombre humano.
El helper explica si el color proviene de la PiezaColor o de la configuración
de la OF; nunca usa “corrida” ni `C01` como vocabulario requerido. Las acciones
se habilitan por capacidad y estado. Carga, vacío, error de versión, conflicto
de máquina e idempotencia poseen estados visibles. El maquinista no usa esta
vista.

## 7. Migración

1. Expandir `registro_diario_produccion`, tablas hijas y FK sin eliminar campos
   vigentes ni crear una cabecera paralela.
2. Backfill de exactamente un trabajo por OT de Fabricación histórica, aunque
   varias compartan máquina, fecha y turno.
3. Copiar configuración técnica y proyecciones verificando conteos antes/después.
4. Habilitar doble lectura comparada y escritura única al nuevo agregado.
5. Cortar frontend/servicios.
6. Contraer columnas duplicadas solo en otra migración aprobada.

No se fusionan OT históricas por máquina/fecha/turno ni se obliga a corregirlas
para completar el upgrade. Cada una conserva cabecera/código y recibe su hijo.

## 8. Mapa ATDD → pruebas

| Escenario | Nivel y evidencia |
|---|---|
| M1-01 | integración API + UI: una OT, dos trabajos con contextos distintos |
| M1-02 | PostgreSQL concurrente: exclusión de máquina |
| M1-03 | servicio/estado: pausa y reanudación idempotentes |
| M1-04 | integración: A→B→A reanuda identidad compatible |
| M1-05 | integración: contexto incompatible crea continuación |
| M1-06 | integración: cierre agregado y lista de pendientes |
| M1-07 | migración PostgreSQL: backfill, conteos e IDs inmutables |
| M1-08 | integración C/D: pesaje diferido de trabajo pausado sin reactivarlo |
| M1-09 | UI: todas las máquinas por fecha/turno, incluida “Sin OT”, y selección de tarjeta |
| M1-10 | contrato + UI: color estructurado, único read-only y múltiples opciones humanas |

Primera prueba RED: `M1-01`, porque el modelo vigente solo permite una
corrida/color directamente en la OT.

## 9. Observabilidad y seguridad

Eventos: `OT_MACHINE_CREATED`, `COLOR_WORK_ADDED`, `COLOR_WORK_STARTED`,
`COLOR_WORK_PAUSED`, `COLOR_WORK_RESUMED`, `COLOR_WORK_COMPLETED`,
`COLOR_WORK_CONTINUED`. Logs no incluyen QR completos,
tokens ni datos personales innecesarios.

Capacidades implementadas en el piloto:

- `OT_CREAR`: crear cabecera, agregar Trabajo de color, asignar/relevar y
  administrar mangas permitidas;
- `OT_INICIAR`: iniciar, pausar y reanudar un Trabajo de color;
- `OT_CERRAR`: completar/anular un Trabajo de color y cerrar la OT;
- `PLAN_MANGA_ADMINISTRAR` y capacidades `MANGA_*`: plan, etiquetas, extras y
  excepciones según cada comando.

Una granularidad futura `TRABAJO_COLOR_*` requerirá una decisión/migración de
roles independiente; no se declara como autorización disponible en este corte.
El reordenamiento persistente también queda en backlog: no existe endpoint ni
comando de arrastre en M1. La secuencia creada no se sobrescribe.

## 10. Definition of Done

- [x] Baseline reejecutada verde antes del RED.
- [x] M1-01…M1-10 automatizados y verdes.
- [x] Migración repetible en PostgreSQL vacío y con datos legacy.
- [x] Adaptador histórico sin doble escritura autoritativa.
- [x] UI con permisos, errores y concurrencia visibles.
- [x] Sin tablas o contratos de material preparado ni TrabajoArmado.
