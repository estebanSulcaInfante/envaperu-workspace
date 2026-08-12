---
tipo: modelo_objetivo
estado: en-refinamiento
tags: [dominio, scm, unidad-logistica, bolsa, qr, US-010C, US-010D, US-010F, US-010R]
relaciones:
  - "[[Articulo_SCM]]"
  - "[[Ubicacion_Inventario]]"
  - "[[Lote_WIP]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Perfil_Empaque]]"
  - "[[Tipo_Manga]]"
  - "[[Etiqueta_Manga]]"
  - "[[Registro_Diario]]"
  - "[[Lote_Color]]"
  - "[[Orden_Armado]]"
  - "[[Orden_Operacion]]"
  - "[[Saldo_WIP_Salida]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
fecha_creacion: 2026-07-23
fecha_actualizacion: 2026-08-03
---

# Unidad Logística

Identidad física trazable para una bolsa, caja, manga, pallet u otro contenedor. El modelo común admite contenido material, salida de pieza, [[Lote_WIP]] o producto terminado.

El primer corte operativo de US-010C/D/F se restringe a la **manga** utilizada
en planta, modelada como `TipoContenedor.clase=MANGA` y administrada mediante
[[Tipo_Manga]]. El código humano usa `OF…-OT…-M…` en Fabricación y
`OA…-OT…-M…` en Armado; el objeto QR de la manga es `SCM_MANGA` y cada
impresión se identifica separadamente como `SCM_MANGA_LABEL`.

La forma física y la naturaleza del contenido son dimensiones distintas:

- `tipo_contenedor_id` identifica el soporte físico mediante [[Tipo_Manga]] y [[Perfil_Empaque]];
- `content_lot_type` identifica qué clase de lote contiene;
- el modo de interfaz se deriva del artículo y la operación.

Los valores legacy `BOLSA_SALIDA_PRODUCCION` y `BOLSA_PRODUCTO_ENSAMBLADO` se traducen durante la transición, pero no continúan como sustituto de `TipoContenedor`.

## Estados separados

```text
estado_manga:
BORRADOR -> PLANIFICADA -> PREETIQUETADA -> PESADA
                                           -> ETIQUETADA_FINAL
                                           -> PENDIENTE_RECEPCION_ALMACEN
                                           -> RECIBIDA
         \-> ANULADA
                         \-> CONCILIACION

flujo adicional WIP/PT armado:
PREETIQUETADA -> CERRADA_ARMADO_PENDIENTE_PESAJE -> PESADA

estado_inventario:
NO_INGRESADA
  -> RECIBIDA_ALMACEN
  -> DISPONIBLE | BLOQUEADA | RESERVADA | CONSUMIDA | DESPACHADA
```

[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]] reserva mangas de salida simple. [[US-010F_Prearmado_y_Armado_Concurrente_Trazable|US-010F]] reserva mangas cuyo contenido será WIP o producto terminado según la salida de [[Orden_Operacion]]. Ambas aplican una regla congelada de [[Perfil_Empaque]] y permiten imprimir la identidad antes de pesar; en esos estados el peso real es nulo y no existe inventario.

[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]] confirma la existencia física y el peso de la misma identidad, pero la deja en `PENDIENTE_RECEPCION_ALMACEN`, sin ubicación de inventario ni Kardex. [[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex|US-010I]] crea posteriormente el movimiento inicial cuando Almacén escanea y recibe el QR.

## Atributos objetivo mínimos

| Campo | Regla |
|---|---|
| `id` | Identificador global UUID/ULID, estable e inmutable; la Tech Spec fijará el formato exacto. |
| `codigo` | Código legible `OF000042-OT000123-M001` o `OA000025-OT000141-M001`, no reutilizable. |
| `tipo_contenedor_id` | Tipo físico de contenedor; obligatorio al planificar. |
| `regla_empaque_revision_id` | Regla aprobada congelada; puede ser nula solo en contingencia autorizada y explícita. |
| `ot_contexto_id` | OT que produjo el contenido directo o durante la cual ocurrió el armado; no redefine genealogía. |
| `content_lot_type` | `LOTE_MATERIAL`, `LOTE_MERMA_RECUPERABLE`, `LOTE_SALIDA_PIEZA_COLOR`, `LOTE_WIP` o `LOTE_PRODUCTO_TERMINADO`. |
| `lote_material_id` | Obligatorio solo cuando `content_lot_type=LOTE_MATERIAL`. |
| `lote_merma_recuperable_id` | Obligatorio solo para `LOTE_MERMA_RECUPERABLE`; su saldo únicamente puede reservarse/consumirse para molienda. |
| `lote_salida_pieza_color_id` | Obligatorio para salida simple; nulo para WIP o producto armado. |
| `lote_wip_id` | Obligatorio cuando el contenido es un WIP intermedio. |
| `lote_producto_terminado_id` | Opcional; solo agrupa la manga en una futura [[Lote_Producto_Terminado|partida PT]]. |
| `orden_operacion_id` | Obligatorio cuando el contenido procede de una transformación intermedia o final. |
| `secuencia_ot` | Orden visible dentro de la OT. |
| `tipo_plan` | `NORMAL` o `EXTRA`; `EXTRA` exige motivo y aprobación del Jefe de Producción. |
| `motivo_extra`, `extra_aprobada_por_id`, `extra_aprobada_at` | Evidencia obligatoria cuando excede el plan activo. |
| `trabajador_asignado_id` | Responsable previsto, opcional. |
| `trabajador_pesaje_id` | Actor real de la captura. |
| `peso_bruto_kg`, `tara_kg`, `peso_neto_kg` | `Decimal`, tres decimales; nulos antes del pesaje. |
| `kg_produccion_ot` | Masa estándar atribuible a la transformación de la OT, separada del neto físico cuando incorpora componentes previos. |
| `cantidad_planificada` | Cantidad prevista, opcional; no crea ni reserva saldo. |
| `cantidad_asignada` | Cantidad autoritativa de una `ReservaWIPSalida`, nula hasta asignar; permite pesar una salida simple sin recontarla. |
| `cantidad_confirmada` | En salida simple puede derivarse del plan al pesar; en WIP/PT la confirma Armado antes del pesaje. |
| `cantidad_contenida` | Cantidad autoritativa: confirmada si existe, en otro caso asignada. Siempre requerida cuando se debita WIP. |
| `fuente_cantidad` | `PLAN_CONFIRMADO_POR_PESAJE`, `RESPONSABLE_ARMADO`, `CORRECCION_AUTORIZADA` o `ASIGNACION_WIP_PREVIA`; nunca `INFERIDA_DESDE_PESO`. |
| `cantidad_confirmada_por_id` | Actor que confirmó la cantidad y su diferencia frente al plan. |
| `diferencia_cantidad`, `motivo_diferencia` | Se conservan cuando lo confirmado no coincide con el plan; el motivo puede ser obligatorio por tolerancia. |
| `estado_manga` | Ciclo desde borrador hasta pendiente de recepción; no se mezcla con inventario. |
| `estado_inventario` | `NO_INGRESADA` hasta el escaneo de Almacén. |
| `estado_calidad` | Nulo o preliminar antes de recepción; no se infiere de la ubicación. |
| `ubicacion_id` | Nula hasta la recepción de Almacén. |
| `fecha_operativa_ot` | Snapshot de la fecha productiva; el avance siempre se atribuye a ella. |
| `pesada_at` | Tiempo físico real de balanza, independiente de la fecha operativa. |
| `desfase_pesaje_dias`, `alerta_desfase`, `motivo_desfase` | Diferencia calendario local; exige alerta/motivo cuando supera un día. |
| `qr_object_type` | Constante `SCM_MANGA`; la impresión concreta usa [[Etiqueta_Manga]]. |

## Identificación

El QR de cada [[Etiqueta_Manga]] contiene versión, `manga_id`, `label_id`, tipo y versión de etiqueta. Los nombres de OP, OT, artículo, pieza, color y maquinista se imprimen como ayudas/snapshots, pero se resuelven mediante relaciones estables. `tipo_contenedor_id` clasifica el soporte físico, `content_lot_type` clasifica su lote y `ui_mode` se deriva como `SALIDA_SIMPLE`, `WIP_TRANSFORMADO` o `PRODUCTO_TERMINADO`; no son enums intercambiables.

En formato 2-up, una impresión normal coloca dos mangas distintas por fila. Una etiqueta emitida no se reimprime de forma indistinguible: el reemplazo requiere autorización del Jefe de Producción, invalida la versión anterior y crea otro `label_id`.

La solicitud de preetiqueta de WIP/PT nace en el módulo de Armado. La ejecución
física se modela como `TrabajoImpresion` direccionado a una estación/impresora.
Mientras Armado no tenga impresora propia, el destino configurado es la
impresora del módulo de pesaje. Esto no convierte a Balanza en autoridad de la
planificación ni del conteo.

## Contenido y genealogía

Una unidad contiene un solo artículo principal y una sola confirmación de
salida. Una bolsa de baldes con asas ya unidas contiene WIP si todavía falta
otra operación, o `ProductoTerminado` si completó la estructura comercial. Los
cuerpos y asas se recorren mediante [[Orden_Operacion]] y sus consumos N:M.
[[Lote_Producto_Terminado]] es un agrupador opcional, no una FK obligatoria.

Si las piezas solo comparten bolsa pero no están armadas, la unidad es una agregación y cada contenido conserva su unidad hija. No se convierte en producto terminado por estar físicamente junto.

El peso bruto/tara/neto pertenece a la unidad completa. Las atribuciones por componente son valores derivados en el armado, no mediciones adicionales de la balanza.

## Custodia y consumo interno

Una unidad inventariada conserva la misma identidad cuando sale de Almacén
hacia Armado. La entrega no equivale a consumo:

```text
ALMACEN -> EN_TRANSITO_PRODUCCION -> STAGING_ARMADO
```

El consumo puede ser parcial y se acredita por cada salida de Armado. Si el
remanente sigue en el mismo envase conserva QR y saldo; si se reenvasó, nace
una unidad hija con QR propio. Las unidades mezcladas sin atribución exacta se
vinculan mediante un pool de procedencia candidata contado.

## Invariantes

- Planificar o imprimir no crea saldo.
- Una manga puede editarse mientras no tenga una etiqueta `PREPESAJE` físicamente emitida.
- La primera impresión exitosa consume un cupo normal y congela OP, OT, contenido, cantidad, tipo de manga, color y maquinista previstos.
- Una manga anulada antes del pesaje libera su cupo; una etiqueta reemplazada no lo libera.
- Crear una manga sobre el número planificado exige `tipo_plan=EXTRA`, motivo y aprobación del Jefe de Producción.
- Una bolsa solo posee un pesaje inicial vigente.
- Reemplazar una etiqueta no cambia la identidad de manga ni consume un cupo extra.
- Una corrección agrega un evento compensatorio; no sobrescribe el pesaje original.
- Una manga anulada no puede pesarse ni recibirse por el flujo normal.
- La misma identidad se conserva antes y después del peso.
- El artículo y la confirmación de salida identifican siempre el contenido
  principal. Las FKs de lote son opcionales según el subtipo y nunca sustituyen
  la identidad de manga.
- El peso de una unidad armada no se acredita íntegramente a su `ot_contexto_id`.
- `PENDIENTE_RECEPCION_ALMACEN` no es inventario, aunque la manga y el pesaje ya existan centralmente.
- Pesar nunca crea ubicación, disponibilidad ni movimiento de Kardex.
- Solo la recepción QR de Almacén puede crear el movimiento inicial y asignar ubicación.
- La cantidad planificada nunca se sobrescribe con la confirmada; ambas y su diferencia quedan consultables.
- Si no existe cantidad asignada, una manga que requiere débito WIP no puede pesarse.
- Cambiar [[Tipo_Manga]], `TipoContenedor` o `ReglaEmpaqueRevision` no modifica una manga planificada o pesada.
- Toda manga PT se pesa; su cantidad ya fue confirmada por Armado antes de
  presentarse en Balanza.
- Una bolsa de merma recuperable se pesa al almacenarse para crear saldo en kg.
  Su pesaje previo al molino confirma consumo y nunca crea una segunda
  existencia.
- Recibirla en Almacén crea existencia con Calidad `PENDIENTE`; solo una
  decisión posterior de Calidad puede dejarla disponible.
