---
tipo: tech-spec
estado: aprobada-para-desarrollo
us: "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, planificacion, orden-produccion, orden-fabricacion, orden-armado, orden-trabajo, migracion, api, frontend, atdd, tdd]
relaciones:
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-07-30_OT_Diaria_Comun_para_Fabricacion_y_Armado]]"
  - "[[Orden_Produccion]]"
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Operacion]]"
  - "[[Orden_Armado]]"
  - "[[Registro_Diario]]"
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
fecha_creacion: 2026-07-29
fecha_actualizacion: 2026-08-09
fecha_aprobacion: 2026-07-29
---

# TS-010P: OP de demanda, OF/OA ejecutables y migración documental

## 1. Objetivo

Implementar la separación:

```text
OrdenProduccion (demanda de ProductoTerminado)
  -> AsignacionDemandaSuministro N:M
  -> OrdenFabricacion / OrdenArmado
  -> OrdenTrabajo
  -> Manga
  -> Pesaje
```

La especificación sustituye el significado actual de `OrdenProduccion` como
orden de molde y preserva:

- IDs y códigos históricos;
- snapshots técnicos;
- OT/RDP;
- mangas y etiquetas ya emitidas;
- pesajes centrales;
- pesajes autónomos legacy del módulo de balanza.

No autoriza escritura sobre una base desplegada. El desarrollo, migraciones y
UAT comienzan en bases locales restaurables.

## 2. Inventario actual verificado

| Actual | Responsabilidad real | Destino |
|---|---|---|
| `orden_produccion` / `OrdenProduccion` | Configuración técnica por molde | OF |
| `lote_color` / `LoteColor` | Corrida por color | `CorridaFabricacion` |
| `lote_salida_pieza_color` | Salida física esperada por lote–pieza | Salida OF compatible |
| `snapshot_composicion_molde` | Fotografía técnica | Snapshot OF |
| `registro_diario_produccion` | Hoja diaria/RDP | OT |
| `scm_plan_manga_op` | Plan de mangas técnico | Plan de mangas OF |
| `scm_manga` | Identidad logística de ejecución | Se conserva |
| `scm_pesaje_manga` | Captura física | Se conserva |
| Mock `SolicitudProduccion` | Demanda de PT | Nueva OP |

Las FKs actuales usan `orden_produccion.numero_op`, incluyendo snapshots, OT y
plan de mangas. El servicio de US-010C compone el código de manga con
`orden_id + codigo_ot + secuencia`; la plantilla de prepesaje actual expone
`op_ot`.

## 3. Principios de implementación

1. El dominio nuevo no reutiliza `producto_sku` de la OF como salida singular.
2. La demanda y el suministro se relacionan N:M y con cantidades.
3. Toda orden ejecutable se identifica mediante UUID y código humano separado.
4. Los códigos impresos nunca son la única FK.
5. Los documentos liberados son inmutables salvo revisión/compensación.
6. La migración es expandir → backfill → validar → cambiar contratos → retirar
   aliases.
7. Ningún paso infiere una OP de demanda para datos legacy.
8. Los pesajes históricos se preservan como hechos, aunque su genealogía sea
   `LEGACY_SIN_ORIGEN`.
9. Estados de orden, Calidad, inventario, impresión y sincronización son
   ortogonales.
10. Los permisos se validan mediante capacidades.

## 4. Modelo objetivo

### 4.1. `scm_orden_produccion`

| Columna | Tipo | Regla |
|---|---|---|
| `id` | UUID PK | Generado por central. |
| `codigo` | varchar(32) unique | `OP-######`. |
| `origen` | varchar(32) | Catálogo gobernado. |
| `referencia_origen` | varchar(100) null | Pedido/referencia. |
| `fecha_necesidad` | date | Obligatoria al aprobar. |
| `prioridad` | varchar(24) | Política configurable. |
| `estado` | varchar(24) | Flujo OP. |
| `version` | int | `> 0`, optimistic locking. |
| `created_by_id`, `approved_by_id` | FK trabajador | Segregación. |
| timestamps | timestamptz | UTC. |

Checks:

- estado en `BORRADOR`, `APROBADA`, `PLANIFICADA`, `EN_COBERTURA`,
  `COMPLETADA`, `CANCELADA`;
- al aprobar existen líneas y snapshots válidos;
- código no cambia.

### 4.2. `scm_orden_produccion_linea`

| Columna | Tipo | Regla |
|---|---|---|
| `id` | UUID PK | Identidad de demanda. |
| `orden_produccion_id` | UUID FK | Cabecera. |
| `producto_terminado_id` | FK | PT activo. |
| `cantidad_solicitada` | numeric(15,3) | Entero positivo validado por dominio. |
| `fecha_necesidad` | date null | Hereda cabecera. |
| `estructura_revision_id` | FK | Obligatoria al aprobar. |
| `estructura_hash` | char(64) | Snapshot. |
| `ruta_revision_id`, `ruta_hash` | FK/hash | Snapshot. |
| `estado` | varchar(24) | Activa/cancelada/satisfecha. |
| `version` | int | Concurrencia. |

Los totales de cobertura son proyecciones; no se duplican como valores editables.

### 4.3. `scm_orden_operacion`

Cabecera técnica común para referencias y salidas:

| Columna | Tipo | Regla |
|---|---|---|
| `id` | UUID PK | Identidad canónica. |
| `codigo` | varchar(32) unique | Secuencia por subtipo. |
| `tipo` | varchar(20) | `FABRICACION` o `ENSAMBLE`. |
| `origen_demanda` | varchar(32) | OP, stock, muestra, reproceso, prueba. |
| `motivo` | text null | Obligatorio en excepción. |
| `estado` | varchar(24) | Flujo ejecutable. |
| `operacion_ruta_revision_id/hash` | FK/hash | Ejecutor congelado. |
| `version` | int | Concurrencia. |
| actores/timestamps | FK/timestamptz | Auditoría. |

Estados: `BORRADOR`, `LIBERADA`, `PROGRAMADA`, `EN_EJECUCION`, `CERRADA`,
`ANULADA`.

### 4.4. `scm_orden_fabricacion`

Extensión 1:1 de `scm_orden_operacion`:

| Columna | Regla |
|---|---|
| `orden_operacion_id` | UUID PK/FK; `tipo=FABRICACION`. |
| `molde_id` | Obligatorio al liberar. |
| `maquina_prevista_id` | Opcional hasta programar. |
| `snapshot_tiempo_ciclo_seg` | `> 0` al liberar. |
| `snapshot_horas_turno` | `> 0`. |
| `snapshot_peso_colada_gr` | `>= 0`. |
| `codigo_legacy_op` | Código técnico anterior, unique nullable. |
| caches/calculos | Compatibilidad; no autoridad de demanda. |

Los snapshots de molde se enlazan a `orden_operacion_id` en contrato nuevo.

### 4.5. `scm_corrida_fabricacion`

Evolución de `LoteColor`:

| Columna | Regla |
|---|---|
| `id` | UUID PK. |
| `orden_fabricacion_id` | UUID FK. |
| `codigo` | Secuencia estable en OF. |
| `secuencia` | Entero positivo. |
| `color_produccion_id` | Exactamente uno. |
| `receta_revision_id/hash` | Obligatoria según política. |
| `ciclos_objetivo` | Entero positivo al liberar. |
| `estado` | Borrador/liberada/en ejecución/completada/anulada. |
| `lote_color_legacy_id` | Unique nullable para reconciliación. |

`meta_kg` queda como snapshot legacy. Las órdenes nuevas derivan kg desde ciclos
y salidas.

### 4.6. `scm_orden_operacion_salida`

| Columna | Regla |
|---|---|
| `id` | UUID PK. |
| `orden_operacion_id` | UUID FK. |
| `corrida_fabricacion_id` | Obligatoria para OF; null para OA. |
| `articulo_scm_id` | PiezaColor, WIP o PT. |
| `cantidad_por_ciclo_snapshot` | OF; null para OA. |
| `peso_unitario_snapshot_g` | Positivo cuando aplique. |
| `cantidad_objetivo` | Positiva. |
| `kg_estandar_objetivo` | Derivada. |
| `excedente_objetivo` | `>= 0`. |
| `lote_salida_legacy_id` | Unique nullable. |

Unique por `(orden_operacion_id, corrida_fabricacion_id, articulo_scm_id)`.

### 4.7. `scm_asignacion_demanda_suministro`

| Columna | Regla |
|---|---|
| `id` | UUID PK. |
| `orden_produccion_linea_id` | UUID FK. |
| `fuente_tipo` | `STOCK` o `SALIDA_ORDEN`. |
| `orden_operacion_salida_id` | Exactamente uno con `lote_articulo_id`. |
| `lote_articulo_id` | Fuente física de stock. |
| `cantidad_planificada` | `>= 0`. |
| `cantidad_comprometida` | `>= 0`. |
| `cantidad_satisfecha` | `>= 0`. |
| `estado` | Planificada/comprometida/satisfecha/cancelada. |
| `operation_id` | Comando idempotente. |
| `version`, timestamps | Concurrencia/auditoría. |

Check de exclusividad de fuente. La suma activa no supera la cantidad elegible
de la fuente. La confirmación usa locks consistentes o control optimista y
restricción transaccional.

### 4.8. Adaptación de OT

> [!important] Adenda de cardinalidad 2026-08-09
> El diseño de OT por una sola corrida/color descrito en esta sección fue
> sustituido para Fabricación por
> [[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]. La OT normalizada
> es cabecera de máquina/fecha/turno y contiene N Trabajos de color; cada trabajo
> referencia su OF/corrida. La OT de Armado continúa referenciando una sola OA.

Se introduce `scm_orden_trabajo` como cabecera diaria común:

- `id`, `codigo_ot`, `tipo_ot`;
- `orden_operacion_id`;
- fecha operativa, turno y centro;
- responsable, cantidad objetivo y proyección confirmada;
- estado, versión, actores y timestamps.

`tipo_ot` es `FABRICACION` o `ENSAMBLE` y debe coincidir con la especialización
de `scm_orden_operacion`.

`registro_diario_produccion` conserva tabla/IDs como subtipo/adaptador de
Fabricación durante US-010C:

- añade `orden_trabajo_id UUID` unique FK obligatoria para OT nuevas;
- añade `corrida_fabricacion_id UUID` FK obligatoria para OT nuevas;
- conserva `orden_id` como alias legacy hasta la fase contract;
- valida que la cabecera sea `tipo_ot=FABRICACION`;
- regla histórica sustituida: la OT de Fabricación ya no referencia una sola
  corrida/color; esa identidad pertenece al Trabajo de color;
- relevos se registran en detalles/eventos, no cambiando corrida.

`scm_ot_armado` es extensión 1:1 de la cabecera:

- `orden_trabajo_id` PK/FK;
- `orden_armado_id`;
- `modo_ejecucion`;
- `ot_fabricacion_contexto_id` nullable;
- equipo participante N:M.

Filas `MIGRADA_PENDIENTE_CLASIFICACION` pueden conservar
`orden_trabajo_id` nulo hasta su backfill. La migración no inventa OA.

### 4.9. Adaptación del plan de mangas

`scm_plan_manga_op` evoluciona a `scm_plan_manga_of`:

- FK a `orden_operacion_id`;
- líneas referencian `scm_orden_operacion_salida.id`;
- asignaciones siguen referenciando OT;
- `scm_manga`, etiquetas y pesajes conservan IDs;
- manga de Fabricación usa `OF{n}-OT{n}-M{n}`;
- manga de Armado usa `OA{n}-OT{n}-M{n}`;
- código ya impreso no cambia.

## 5. Estados y transiciones

### 5.1. OP

| Desde | Comando | Hacia |
|---|---|---|
| BORRADOR | aprobar | APROBADA |
| APROBADA | calcular/confirmar plan | PLANIFICADA |
| PLANIFICADA | comprometer/satisfacer | EN_COBERTURA |
| EN_COBERTURA | satisfacer total | COMPLETADA |
| permitido | cancelar con motivo | CANCELADA |

### 5.2. OF/OA

| Desde | Comando | Hacia |
|---|---|---|
| BORRADOR | liberar | LIBERADA |
| LIBERADA | programar | PROGRAMADA |
| LIBERADA/PROGRAMADA | iniciar | EN_EJECUCION |
| EN_EJECUCION | cerrar conciliado | CERRADA |
| permitido | anular con motivo | ANULADA |

No se puede anular con ejecución física sin flujo de compensación.

## 6. Servicios

### 6.1. Planificación

Servicios puros:

- `explode_product_structure`;
- `calculate_multilevel_coverage`;
- `group_fabrication_requirements`;
- `calculate_integer_cycles_and_outputs`;
- `propose_assembly_orders`;
- `validate_supply_allocations`.

Todas las cantidades usan `Decimal`. Los ciclos usan entero.

### 6.2. Comandos idempotentes

Cada escritura acepta `X-Operation-Id` UUID y registra `scm_operacion`:

- crear/aprobar/cancelar OP;
- calcular plan con hash de inputs;
- confirmar propuestas;
- liberar/anular OF/OA;
- crear OF excepcional;
- recalcular plan de mangas;
- adaptar OT.

Mismo ID + mismo hash retorna replay; mismo ID + otro hash retorna
`IDEMPOTENCY_CONFLICT`.

### 6.3. Snapshots

Al aprobar OP:

- BOM/ruta de cada línea.

Al liberar OF:

- molde/composición;
- proceso requerido de la operación de ruta y máquina operativa compatible;
- rutas;
- receta/material por corrida;
- ciclos/salidas;
- parámetros técnicos.

Al crear mangas:

- empaque, contenedor, cantidades, pesos y textos impresos.

## 7. API v2

### 7.1. OP

```text
POST   /api/scm/ordenes-produccion
GET    /api/scm/ordenes-produccion
GET    /api/scm/ordenes-produccion/{id}
PATCH  /api/scm/ordenes-produccion/{id}
POST   /api/scm/ordenes-produccion/{id}/aprobar
POST   /api/scm/ordenes-produccion/{id}/calcular-plan
POST   /api/scm/ordenes-produccion/{id}/confirmar-plan
POST   /api/scm/ordenes-produccion/{id}/cancelar
```

### 7.2. OF

```text
POST   /api/scm/ordenes-fabricacion/excepcionales
GET    /api/scm/ordenes-fabricacion
GET    /api/scm/ordenes-fabricacion/{id}
PATCH  /api/scm/ordenes-fabricacion/{id}
POST   /api/scm/ordenes-fabricacion/{id}/liberar
POST   /api/scm/ordenes-fabricacion/{id}/anular
POST   /api/scm/ordenes-fabricacion/{id}/plan-mangas/recalcular
GET    /api/scm/ordenes-fabricacion/{id}/impresion
```

### 7.3. OA

```text
GET    /api/scm/ordenes-armado
GET    /api/scm/ordenes-armado/{id}
PATCH  /api/scm/ordenes-armado/{id}
POST   /api/scm/ordenes-armado/{id}/liberar
POST   /api/scm/ordenes-armado/{id}/anular
```

### 7.4. OT

El contrato común crea la cabecera con:

```json
{
  "tipo_ot": "FABRICACION",
  "orden_operacion_id": "uuid",
  "fecha_operativa": "2026-07-29",
  "turno_id": "uuid",
  "centro_trabajo_id": "uuid",
  "responsable_id": 10,
  "cantidad_objetivo": "1000"
}
```

La extensión de Fabricación sustituye:

```json
{
  "orden_id": "OP-0084"
}
```

por:

```json
{
  "orden_fabricacion_id": "uuid",
  "corrida_fabricacion_id": "uuid",
  "fecha_operativa": "2026-07-29",
  "maquina_id": 1,
  "maquinista_previsto_id": 10
}
```

Durante transición, respuestas incluyen:

```json
{
  "orden_fabricacion": {
    "id": "uuid",
    "codigo": "OF-000042",
    "codigo_legacy_op": "OP-0084"
  }
}
```

`orden_id` legacy se devuelve solamente en `compat` y no se acepta para crear OT
nuevas una vez activado el contrato v2.

Para Armado:

```json
{
  "orden_armado_id": "uuid",
  "modo_ejecucion": "ESTACION_DEDICADA",
  "ot_fabricacion_contexto_id": null,
  "participantes": [11, 12]
}
```

## 8. Frontend

### 8.1. Navegación

```text
Planificación
  ├── Órdenes de producción
  └── Nueva OP

Producción
  ├── Órdenes de fabricación
  ├── OF excepcional
  ├── Órdenes de trabajo
  └── Pesajes/avance

Armado
  └── Órdenes de armado
```

### 8.2. Asistente

```text
OP y líneas
  -> Cobertura
  -> Propuestas OF/OA
  -> Configuración
  -> Liberación
```

Las vistas muestran explícitamente:

- demanda frente a suministro;
- asignaciones N:M;
- excedente técnico;
- fuente y recencia de inventario;
- bloqueos de maestro/Calidad;
- si una OF es excepcional.

### 8.3. Impresión

- impresión actual OP se mueve a detalle OF;
- nueva OP usa cabecera ejecutiva;
- OF puede listar varias referencias OP sin elegir una falsa principal;
- OT/manga muestra OF–OT;
- los PDFs y etiquetas ya emitidos no se regeneran.

## 9. Etiquetas y estación

### 9.1. Prepesaje v2

La plantilla `PREPESAJE_TSPL_2` cambia:

```text
op_ot       -> of_ot
OP-0084     -> OF-000042
código      -> OF000042-OT123-M003
```

El QR `SCM_MANGA_LABEL v=1` ya usa `manga_id` y `label_id`, por lo que puede
seguir decodificándose. La versión de plantilla cambia; no es necesario romper
el tipo QR mientras no cambie su identidad.

### 9.2. Compatibilidad

- etiquetas v1 siguen resolviendo por `manga_id`;
- reimpresión continúa prohibida; reemplazo crea otra etiqueta;
- el reemplazo de una etiqueta v1 conserva el código humano de manga original;
- solo mangas nuevas adoptan código OF;
- la estación no parsea OF/OT para buscar contexto.

## 10. Autorización

Capacidades:

```text
OP_CREAR
OP_APROBAR
PLANIFICACION_CALCULAR
PLANIFICACION_CONFIRMAR
OF_EDITAR_BORRADOR
OF_EXCEPCIONAL_CREAR
OF_LIBERAR
OF_ANULAR
OA_LIBERAR
OA_ANULAR
OT_CREAR
PLAN_MANGA_ADMINISTRAR
```

Asignación inicial sugerida:

| Rol | Capacidades |
|---|---|
| Planificación | OP y plan |
| Jefe de Producción | liberar/anular OF/OA, excepciones |
| Supervisor | programar OT de Fabricación o Armado |
| Maquinista | consultar OT/manga |
| Operador de balanza | escanear/pesar |

Una persona puede tener varias capacidades. La UI no sustituye autorización de
API.

## 11. Migración de datos

### 11.1. Preflight obligatorio

Registrar en artefacto:

- revisión Alembic;
- conteos por tabla;
- PK/FK huérfanas;
- códigos duplicados;
- hashes de pesajes centrales;
- conteo/hashes de la SQLite autónoma;
- filas de orden técnica, lote color, salidas, OT, mangas, etiquetas y pesajes;
- OP técnicas sin molde/snapshot;
- OT sin orden o sin corrida resoluble.

La migración aborta ante una FK inesperada o duplicados no clasificados.

### 11.2. Fase expand

1. Crear tablas OP, orden de operación, salidas y asignaciones.
2. Añadir columnas canónicas nullables a OT y planes.
3. Crear secuencias independientes OP/OF/OA.
4. Añadir campos de alias legacy.
5. Desplegar lectores duales y telemetría de fallback.

### 11.3. Backfill OF

Por cada `orden_produccion` técnica:

1. crear `scm_orden_operacion(tipo=FABRICACION)`;
2. preservar `numero_op` en `codigo_legacy_op`;
3. asignar UUID determinístico y `codigo` técnico estable;
4. copiar configuración a extensión OF;
5. convertir `LoteColor` en corrida;
6. convertir cada `LoteSalidaPiezaColor` en salida genérica;
7. enlazar snapshot, OT y plan de mangas;
8. clasificar filas no resolubles como legacy, sin inventar OP de demanda.

Las OP/OF normalizadas inexistentes no se fabrican desde pesajes históricos.

### 11.4. OP nueva

No se crea OP a partir del `producto_sku` opcional de una orden técnica. La
nueva tabla comienza vacía salvo fixtures/UAT explícitos.

### 11.5. Pesajes legacy

- no se borran ni actualizan valores físicos;
- no se asigna PT, OF u OP inventada;
- conservan código original y `LEGACY_SIN_ORIGEN` cuando no exista genealogía;
- la consulta puede agrupar por referencia legacy;
- checksum y conteo deben ser idénticos antes/después;
- la SQLite de estación se migra solo mediante su flujo versionado de
  backup/restore ya existente.

### 11.6. Cutover

1. Bloquear brevemente escrituras técnicas locales.
2. Ejecutar backup verificado.
3. Aplicar backfill.
4. Ejecutar invariantes.
5. Activar API v2 y frontend nuevo.
6. Habilitar estación compatible.
7. Ejecutar smoke OP→OF→OT→manga→pesaje.
8. Reabrir operación.

### 11.7. Contract

Después de una ventana UAT:

- renombrar tablas/constraints legacy cuando no rompa rollback;
- retirar escrituras `/api/ordenes` antiguas;
- retirar `orden_id` de creación OT;
- mantener lectura histórica por alias;
- no eliminar columnas hasta verificar cero uso por telemetría.

## 12. Rollback

- rollback de aplicación usa lectores duales;
- rollback de DB no borra tablas nuevas con hechos;
- antes del primer hecho v2, puede revertirse el esquema con backup;
- después de producir hechos v2, se desactiva escritura nueva y se restaura
  servicio mediante forward-fix; no se hace downgrade destructivo;
- cualquier diferencia de conteos/hashes de pesaje bloquea el despliegue.

## 13. Errores de negocio

| Código | Significado |
|---|---|
| `OP_LINE_REQUIRED` | OP sin líneas. |
| `COVERAGE_NOT_CALCULABLE` | Inventario no confiable. |
| `STRUCTURE_REVISION_INVALID` | BOM/ruta inválida. |
| `SUPPLY_OVERALLOCATED` | Fuente comprometida en exceso. |
| `OF_NOT_RELEASABLE` | Configuración técnica incompleta. |
| `OF_EXCEPTION_REASON_REQUIRED` | Excepción sin motivo. |
| `OF_CORRIDA_REQUIRED` | OT sin corrida. |
| `MOLD_OUTPUT_INCOMPATIBLE` | El molde no contiene una PiezaColor de salida de la OF. |
| `MACHINE_NOT_AVAILABLE` | La máquina no está `OPERATIVA`. |
| `MACHINE_PROCESS_INCOMPATIBLE` | El tipo de máquina no soporta el proceso de la operación de ruta. |
| `EXECUTOR_KIND_MISMATCH` | Ruta y subtipo no coinciden. |
| `LEGACY_REFERENCE_READ_ONLY` | Intento de escribir mediante alias histórico. |
| `IDEMPOTENCY_CONFLICT` | Mismo operation ID con otro payload. |

## 14. Pruebas

### 14.1. Modelo

- constraints, estados, UUID/códigos;
- una OP con N líneas;
- OF multipieza/multisalida;
- una OT por corrida;
- OA con WIP/PT;
- asignación N:M y concurrencia.

### 14.2. Servicios

- cobertura completa;
- cobertura multinivel;
- ciclos enteros;
- excedentes;
- OF terminal de PT;
- OF excepcional;
- replay/conflicto;
- cancelación y liberación de compromisos.

### 14.3. Migración

- base vacía;
- fixtures actuales;
- orden legacy sin producto;
- orden con varios colores;
- OT legacy sin corrida resoluble;
- mangas/etiquetas/pesajes existentes;
- igualdad de hashes y conteos;
- upgrade desde revisión anterior y nueva instalación.

### 14.4. Contrato/E2E

```text
OP -> plan -> OF -> liberar -> materiales -> OT -> manga -> pesaje
OP -> plan -> OF + OA -> WIP/PT
OF excepcional -> OT -> manga
QR etiqueta v1 -> consulta compatible
QR etiqueta v2 -> pesaje
```

### 14.5. Frontend/impresión

- rótulos OP/OF/OA/OT;
- no mostrar molde en creación OP;
- OF técnica conserva A4;
- asignaciones N:M;
- código OF–OT de manga;
- etiqueta 2-up;
- permisos y estados.

## 15. UAT mínima

1. Crear OP de un PT con BOM normalizada.
2. Confirmar cobertura cero.
3. Generar OF multipieza y OA.
4. Revisar excedentes.
5. Liberar OF.
6. Preparar materiales.
7. Crear OT con una corrida/color.
8. Generar dos mangas y etiquetas v2.
9. Pesar una manga.
10. Consultar avance OF y cobertura OP.
11. Crear OF excepcional autorizada.
12. Abrir un pesaje legacy y confirmar que no cambió.

## 16. Observabilidad

Métricas:

- fallbacks a `orden_id` legacy;
- OP/OF/OA creadas/liberadas;
- asignaciones activas/sobreasignaciones bloqueadas;
- OT sin corrida;
- etiquetas v1/v2;
- QR legacy resueltos;
- errores de migración;
- diferencia de conteos/hashes de pesaje;
- latencia de cálculo de cobertura.

Logs incluyen IDs/códigos, no recetas completas ni datos sensibles.

## 17. Definition of Done

1. ADR y dominio aprobados.
2. Migración expand/backfill/validación reversible probada.
3. OP, líneas y asignaciones implementadas.
4. Orden técnica expuesta como OF.
5. OF/OA comparten salidas canónicas.
6. OT referencia OF/corrida.
7. US-010B/C/D/F consumen contratos actualizados.
8. Frontend y documentos usan el nuevo lenguaje.
9. Etiquetas nuevas usan OF–OT y QR estable.
10. Permisos/capacidades aplicados en API.
11. Pesajes históricos conservan conteos y hashes.
12. Suite y UAT local verdes.
13. No se toca la base desplegada durante desarrollo/UAT.

## 18. Fuera de alcance

- planificación finita automática por capacidad;
- MRP completo de compras;
- ingreso de mangas a Kardex, US-010I;
- despacho y cliente;
- operación offline nueva;
- conversión automática de pesajes legacy en OP/OF normalizadas;
- eliminación inmediata de endpoints/columnas legacy.

## 19. Puntos a aprobar antes de Dev

1. Esquema común `scm_orden_operacion` + extensiones OF/OA.
2. Sustituido para Fabricación: una OT nueva contiene N Trabajos de color y
   cada trabajo ejecuta una corrida/color exacta. Armado conserva una OA por OT.
3. Códigos nuevos `OP-######`, `OF-######`, `OA-######`, `OT-######`.
4. Mangas nuevas usan `OF…-OT…-M…` o `OA…-OT…-M…`; etiquetas existentes no cambian.
5. `ProductoTerminado` directo desde molde se acredita mediante OF terminal.
6. OF excepcional exige origen/motivo y autorización JP.
7. Migración no crea OP de demanda a partir de datos técnicos legacy.
8. Desarrollo y UAT permanecen locales hasta autorización de despliegue.

## 20. Adenda implementada 2026-07-30

### 20.1. Revisión de metas

Los totales de cobertura siguen siendo proyecciones no editables. Las metas de
documentos sí son revisables:

| Campo de propuesta | Regla |
|---|---|
| `cantidad_calculada` | Resultado original de demanda, BOM y saldo libre. |
| `cantidad_objetivo` | Meta confirmable de OF/OA, entre cero y `cantidad_calculada`. |
| `ajuste_manual` | Cantidad anterior, motivo, actor y fecha. |

`POST /api/scm/v1/ordenes-produccion/{id}/ajustar-metas` recibe `plan_id`,
`content_hash`, `version`, `motivo` y las metas modificadas. No muta la
revisión activa: crea la siguiente y marca la anterior `SUPERADO`.

### 20.2. Kardex normalizado mínimo

| Tabla | Responsabilidad |
|---|---|
| `scm_ubicacion_inventario` | Ubicación estable de custodia. |
| `scm_saldo_inventario` | Existencia física y reservada por artículo/ubicación. |
| `scm_movimiento_inventario` | Libro append-only de saldos iniciales y ajustes. |
| `scm_reserva_inventario` | Compromiso de stock por plan y línea OP. |

```text
cantidad_libre = cantidad_fisica - cantidad_reservada
```

API:

```text
GET  /api/scm/v1/inventario/saldos
GET  /api/scm/v1/inventario/movimientos
POST /api/scm/v1/inventario/movimientos
```

Los movimientos manuales permitidos son `SALDO_INICIAL`,
`AJUSTE_POSITIVO` y `AJUSTE_NEGATIVO`, todos con motivo e idempotencia.
Confirmar un plan bloquea/revalida saldos y crea reservas; no crea consumo.

### 20.3. Frontend y UAT

- Planificación muestra valor sugerido y meta confirmable.
- El motivo se habilita cuando existe una diferencia.
- `Producción > Kardex SCM` muestra existencia física, reservada y libre.
- Almacén carga saldos iniciales; Planificación consulta; JP registra ajustes.
- La UAT debe probar stock parcial, ajuste de metas, revisión y conflicto por
  saldo ya reservado.

La recepción QR de mangas continúa en [[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]];
este corte no convierte pesajes legacy ni mangas pendientes en inventario.
