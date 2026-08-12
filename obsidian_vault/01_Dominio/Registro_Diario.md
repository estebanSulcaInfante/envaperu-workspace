---
tipo: modelo_transicion
tabla: registro_diario_produccion
estado: activo
tags: [dominio, core, orden-trabajo, turno, fabricacion, armado]
relaciones_padre:
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Armado]]"
relaciones_hijos:
  - "[[Detalle_Produccion_Hora]]"
  - "[[Control_Peso]]"
  - "[[Saldo_WIP_Salida]]"
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-08-09
relaciones_objetivo:
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[2026-07-23_Autoridad_Central_OT_e_Impresion_Local]]"
  - "[[2026-07-23_Separacion_Peso_Fisico_Produccion_y_Armado]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-07-30_OT_Diaria_Comun_para_Fabricacion_y_Armado]]"
  - "[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]]"
  - "[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]"
  - "[[Trabajo_OT]]"
---

# Orden de Trabajo diaria

Representa la jornada ejecutable por fecha operativa, turno, centro y equipo.
En Fabricación conserva el significado vigente de **Hoja de Producción diaria,
Registro Diario de Producción y Orden de Trabajo**. El modelo objetivo extiende
el mismo documento a Armado, sin convertir máquina o molde en datos
obligatorios para ese proceso.

La tabla y clase actuales `registro_diario_produccion` /
`RegistroDiarioProduccion` conservan la cabecera física y el nombre de dominio
**OT de Fabricación** durante expand/cutover. La decisión US-010M sustituye el
objetivo anterior de crear una tabla `scm_orden_trabajo`: no se crea una
cabecera paralela. Armado conserva su adaptador vigente.

## Modelo común objetivo

```text
registro_diario_produccion (OT_FABRICACION de máquina/turno)
└─ scm_trabajo_ot (tipo COLOR)
   ├─ scm_trabajo_color
   ├─ scm_asignacion_personal_trabajo_ot
   └─ scm_manga

scm_ot_armado (adaptador vigente; fuera del refactor M)
```

### Cabecera física `registro_diario_produccion`

| Campo | Regla |
|---|---|
| `id`, `codigo_ot` | Identidad/correlativo global `OT-######`. |
| `tipo_ot` | `FABRICACION` o `ENSAMBLE`. |
| `orden_operacion_id` | Nulo en OT nueva normalizada de Fabricación; los trabajos identifican sus operaciones. Se conserva en adaptadores legacy/Armado. |
| `fecha_operativa` | Día autoritativo de producción. |
| `turno_id` | Turno gobernado. |
| `centro_trabajo_id` | Máquina/celda/área compatible con el subtipo. |
| `responsable_id` | Predeterminado opcional; la ejecución usa [[Asignacion_Trabajo_OT]]. |
| `cantidad_objetivo` | Proyección agregada desde trabajos. |
| `cantidad_confirmada` | Proyección agregada desde hechos de trabajos. |
| `estado` | `PLANIFICADA`, `INICIADA`, `PAUSADA`, `CERRADA` o `ANULADA`. |
| `version`, timestamps, actores | Concurrencia y auditoría. |

### OT de Fabricación normalizada

- referencia máquina, fecha, turno y proceso;
- contiene una cola de [[Trabajo_Color|Trabajos de color]] que identifican OF,
  corrida, molde, color, cuota y snapshots;
- el responsable predeterminado no reemplaza asignaciones por intervalo;
- varias OT monocolor legacy coincidentes permanecen consultables y cada una
  obtiene un trabajo hijo; no se fusionan ni bloquean el upgrade.

El detalle horario se interpreta como `CorteHorarioOT`: conserva contador,
estado, incidencias, muestra de proceso y señales provisionales. No es una
segunda declaración de producción ni autoridad de Kardex. Las unidades buenas
se confirman por cierre de manga y el peso mediante un único pesaje final.

### Especialización `OT_ENSAMBLE`

- referencia una sola OA;
- centro/celda y responsable de Armado obligatorios;
- equipo participante opcional N:M;
- en modo concurrente enlaza un [[Trabajo_Color|Trabajo de color]] exacto y
  deriva su OT de Fabricación padre como contexto consultable;
- recibe una cuota diaria y genera únicamente sus mangas WIP/PT;
- no contiene corrida, molde ni contadores de máquina.

## Campos legacy de OT de Fabricación

| Atributo / Campo | Origen de Dato | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **ID Registro** | Auto (BD) | Identificador único del registro diario. | `AUTOINCREMENT` |
| **OF ID (FK)** | Selección | Referencia a la [[Orden_Fabricacion]] y corrida ejecutadas. Durante la transición usa la FK `orden_id` legacy. | - |
| **Máquina ID (FK)** | Selección | Máquina donde se ejecutó la producción. | - |
| **Fecha** | Input (Manual) | Fecha del turno de producción. | - |
| **Turno** | Input (Select) | DIURNO, NOCTURNO, o EXTRA. | - |
| **Hora Inicio** | Input (Manual) | Hora de arranque (ej. 07:00). | - |
| **Colada Inicial** | Input (Manual) | Contador de la máquina al inicio del turno. | - |
| **Colada Final** | Input (Manual) | Contador de la máquina al final del turno. | - |
| **Tiempo Ciclo Reportado** | Input (Manual) | T/C observado en el panel (segundos). | - |
| **Tiempo Enfriamiento** | Input (Manual) | Tiempo de enfriamiento observado (seg). | - |

## Evolución canónica US-010C

El modelo canónico implementado añade `public_id` UUID, `codigo_ot`
`OT-######`, `codigo_ot_sintetico`, estado, `created_by_id`, maquinista
previsto, zona horaria, timestamps, versión y secuencia de manga por OT.
Central crea la OT; la estación solo obtiene trabajos de impresión y conserva
evidencia técnica local.

El correlativo del talonario legacy no sustituye el ID interno. Un pesaje tampoco puede crear o seleccionar una OT mediante la coincidencia `OP + máquina + fecha + turno`.

Las filas antiguas se conservan sin reinterpretarlas: reciben identidad UUID
determinística, código `OT-LEGACY-{id}`, bandera sintética y estado
`MIGRADA_PENDIENTE_CLASIFICACION`. Si no existe hora histórica de creación,
`created_at` queda nulo con fuente `LEGACY_NO_DISPONIBLE`. Ningún pesaje legacy
se modifica ni se convierte automáticamente en manga SCM.

### Tiempo operativo y tiempo de sistema

El campo legacy `fecha` pasa a denominarse conceptualmente `fecha_operativa`: identifica el día productivo al que pertenece la OT. No equivale al momento de creación del registro.

| Campo objetivo | Regla |
|---|---|
| `fecha_operativa` | Día de producción autoritativo para avance, incluso si la OT cruza medianoche. |
| `created_at` | Timestamp UTC asignado por central al crear la OT. |
| `iniciada_at`, `cerrada_at` | Timestamps reales de ejecución; no sustituyen la fecha operativa. |
| `timezone_snapshot` | Para el piloto, `America/Lima`; permite evaluar días calendario sin usar UTC directamente. |

Una manga pesada durante la mañana siguiente continúa acreditando su avance a `fecha_operativa`. El dashboard puede recibir el evento posteriormente, pero recalcula el día de la OT y conserva `pesada_at` como tiempo físico real.

Regla temporal del piloto:

- misma fecha local que la OT: normal;
- día calendario siguiente: permitido;
- más de un día calendario después: permitido con alerta y motivo;
- fecha de pesaje anterior a la fecha operativa: inconsistencia bloqueante salvo corrección autorizada.

## Snapshots del Registro (Captura al Crear)

Se copian de la [[Orden_Fabricacion]] y su corrida al momento de crear el registro para mantener consistencia histórica.

| Atributo | Origen | Descripción |
| :--- | :--- | :--- |
| **snapshot_cavidades** | Orden | Total de cavidades del golpe al crear el registro. |
| **snapshot_peso_neto_gr** | Orden | Peso neto total del golpe (todas las piezas, gramos). |
| **snapshot_peso_colada_gr** | Orden | Peso del ramal/colada (gramos). |
| **maquina_codigo_snapshot** | Maquina | Código de la máquina en el momento (TS-009). |
| **maquina_nombre_snapshot** | Maquina | Nombre de la máquina en el momento (TS-009). |

## Totalizadores (Calculados)

| Atributo | Descripción | Fórmula | Prioridad |
| :--- | :--- | :--- | :--- |
| **total_coladas_calculada** | Ciclos realizados en el turno. | `colada_final - colada_inicial` | Contadores > Suma detalles |
| **total_piezas_buenas** | Estimación legacy de piezas por ciclos; el nombre no demuestra Calidad. | `total_coladas_calculada × snapshot_cavidades` | Sustituir por salidas confirmadas |
| **total_kg_real** | Agregado legacy de kg embolsados. | `SUM(ControlPeso.peso_real_kg)` | No usar como producción exclusiva de máquina |

> **Nota sobre `total_kg_real`:** la implementación actual prioriza la suma de pesajes físicos y usa como fallback `total_coladas × (peso_neto_gr + peso_colada_gr) / 1000`. Ambas magnitudes son distintas y el nombre es ambiguo. Una bolsa con componentes previamente fabricados infla el valor si se interpreta como producción de la OT.

### Proyección objetivo de avance

| Métrica | Significado |
|---|---|
| `ciclos_confirmados` | Ciclos efectivos de la máquina. |
| `unidades_teoricas_ot` | Ciclos por cavidades efectivas; no equivale todavía a unidades buenas. |
| `unidades_buenas_ot` | Piezas buenas producidas por cada `LoteSalidaPiezaColor` de la OT. |
| `kg_estandar_salida_ot` | `unidades_buenas_ot × peso_unitario_snapshot_gr / 1000`; derivado, no peso físico aislado. |
| `saldo_wip_salida_unidades` | Piezas buenas confirmadas aún no destinadas a bolsa directa o armado. |
| `unidades_prearmadas_provisionales_abiertas_contexto` | Avance manual visible aún no conciliado por cierre de bolsa; sin efecto de inventario. |
| `unidades_armadas_confirmadas_contexto` | Productos acreditados por cierres de bolsa de [[Orden_Armado]]. |
| `kg_componentes_previos_contexto` | Aporte estándar de inventario anterior incorporado en esos armados. |
| `kg_fisico_embalado_contexto` | Suma del neto medido de bolsas simples y armadas, sin atribuir todo a la máquina. |
| `desviacion_armado_contexto` | Residual entre peso físico y peso esperado de la BOM ejecutada. |

El dashboard debe presentar estas métricas por separado. `kg_fisico_embalado_contexto` sirve para flujo físico; `kg_estandar_salida_ot` sirve para avance atribuible a la transformación actual.

## Estructura JSON (Referencia API)

Endpoint objetivo: `GET /api/scm/ordenes-fabricacion/<of>/ordenes-trabajo`

```json
{
  "id": 1,
  "fecha": "2023-11-21",
  "turno": "DIURNO",
  "maquina": "INY-05",
  "orden_fabricacion": "OF-000042",
  "codigo_legacy_op": "OP-1322",
  "contadores": { "inicial": 1000, "final": 1500, "total": 500 },
  "parametros": { "ciclo": 30.0, "enfriamiento": 5.0 },
  "totales_estimados": { "piezas": 1000, "kg_total": 88.0 },
  "detalles": [ ... ]
}
```

## Relaciones
- **Fabricación normalizada:** la OT no tiene una OF padre singular; contiene
  N [[Trabajo_Color|Trabajos de color]] y cada trabajo referencia una OF/corrida
  exacta. Por ello puede agregar varias OF compatibles en la jornada.
- **Armado:** la OT referencia exactamente una [[Orden_Armado|OA]]; una OA
  puede distribuirse en N OT de Armado.
- **Hijos comunes:** mangas, eventos, participantes y confirmaciones de jornada.
- **Hijos de Fabricación:** [[Detalle_Produccion_Hora]] (1:N), [[Control_Peso]] (1:N).
- **Hijos de Armado:** mangas WIP/PT, avances y cierres de Armado.
- **Evolución:** mangas planificadas y salidas físicas de [[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]], pesadas por [[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]] y recibidas posteriormente por [[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex|US-010I]].

La fecha de necesidad permanece en OP. OF/OA no añaden una fecha productiva
editable: proyectan la necesidad asignada y el rango de fechas operativas de
sus OT según
[[2026-08-09_Jornadas_de_Planta_y_Fechas_Proyectadas_de_OF_OA]].
