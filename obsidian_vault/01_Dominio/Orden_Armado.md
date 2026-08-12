---
tipo: modelo_objetivo
estado: en-refinamiento
tags: [dominio, scm, armado, prearmado, wip, producto-terminado, genealogia, US-010F, US-010R]
relaciones:
  - "[[Orden_Produccion]]"
  - "[[Orden_Fabricacion]]"
  - "[[Articulo_SCM]]"
  - "[[Orden_Operacion]]"
  - "[[Lote_WIP]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Ruta_Produccion]]"
  - "[[ProductoTerminado]]"
  - "[[PiezaColor]]"
  - "[[Registro_Diario]]"
  - "[[Saldo_WIP_Salida]]"
  - "[[Unidad_Logistica]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-07-30_OT_Diaria_Comun_para_Fabricacion_y_Armado]]"
  - "[[2026-08-06_OA_como_Sigla_Orden_Armado]]"
  - "[[2026-08-09_Jornadas_de_Planta_y_Fechas_Proyectadas_de_OF_OA]]"
fecha_creacion: 2026-07-23
fecha_actualizacion: 2026-08-09
---

# Orden de Armado

Nombre funcional especializado de [[Orden_Operacion]] para prearmado o armado. Convierte cantidades identificadas de [[Articulo_SCM]] en un [[Lote_WIP]] o un lote de [[ProductoTerminado]], según la salida congelada de [[Ruta_Produccion]]. Puede ejecutarse en una zona dedicada o concurrentemente junto a una [[Registro_Diario|Orden de Trabajo]] de inyección.

La cercanía temporal o física no fusiona ambos procesos. La OT produce las piezas de su molde; la Orden de Armado consume esas piezas y otras existencias previas según una BOM congelada.

La OA se ejecuta mediante una o más [[Registro_Diario|OT de Armado]]. Cada OT
asigna una cuota diaria a una fecha operativa, turno, centro/celda y responsable
de Armado. Si el trabajo ocurre entre ciclos, la OT de Armado enlaza como
contexto el [[Trabajo_Color|Trabajo de color]] exacto que aporta la fabricación.
La OT de Fabricación padre se deriva para consulta, pero ambas ejecuciones
conservan identidad y avance propios. Cuando la OT de máquina contiene varios
colores no se permite seleccionar solamente la cabecera de OT.

Una OA puede cubrir una o varias líneas de [[Orden_Produccion]] y una línea
puede requerir varias OA. La relación usa `AsignacionDemandaSuministro`; no
existe una OP padre obligatoria. También se admite reposición gobernada de WIP o
producto terminado sin fabricar una demanda comercial ficticia.

## Cabecera objetivo

| Campo | Regla |
|---|---|
| `id`, `codigo` | Identidad global y correlativo legible. |
| `origen_demanda`, `motivo`, `autorizacion_id` | OP, reposición u excepción gobernada. |
| `articulo_salida_id` | Artículo WIP o producto resultante. |
| `operacion_ruta_id` | Operación congelada que se ejecuta. |
| `estructura_revision_id`, `estructura_snapshot_hash` | Revisión aprobada y composición inmutable congelada al crear. |
| `cantidad_objetivo` | Conjuntos planificados. |
| `cantidad_prearmada_provisional` | Proyección operativa de avances incrementales aún no acreditados como inventario. |
| `cantidad_completada` | Proyección derivada únicamente de confirmaciones finales. |
| `trabajo_color_contexto_id` | Trabajo de color exacto para ejecución concurrente; permite derivar la OT de Fabricación y no sustituye la OT propia de Armado. |
| `ot_contexto_id` | Alias/cabecera derivada de la OT de Fabricación concurrente; no identifica por sí sola el color ni atribuye componentes previos a Fabricación. |
| `ubicacion_id` | Lugar de ejecución. |
| `estado` | `CREADA`, `EN_EJECUCION`, `COMPLETADA`, `CERRADA` o `ANULADA`. |

## Contexto temporal

La OA conserva el objetivo agregado sin una fecha productiva editable. Su
consulta deriva el rango de necesidad de las líneas OP asignadas y el rango de
`fecha_operativa` de sus OT de Armado. Cada OT aporta la fecha, turno, centro y
cuota concretos. Una OA sin demanda fechada o sin OT lo declara de forma
explícita; no usa la fecha de creación como vencimiento.

## ConsumoComponenteArmado

El consumo lógico se registra por componente y por **confirmación de bolsa**, no solo contra la cabecera de la orden. Así, si una orden produce varias bolsas o lotes, se conserva qué orígenes llegaron a cada resultado.

| Campo | Regla |
|---|---|
| `confirmacion_bolsa_id`, `lote_resultado_id` | Resultado WIP o producto concreto al que quedó incorporado. |
| `articulo_componente_id` | Componente exacto de la estructura congelada. |
| `cantidad_incorporada` | Unidades físicamente contenidas en ese resultado; positiva. |
| `procedencia` | `PRODUCIDO_OT_ACTUAL` o `CONSUMIDO_STOCK_PREVIO`. |
| `nivel_genealogia` | `EXACTA`, `CONJUNTO_CANDIDATOS` o `LEGACY_SIN_ORIGEN`. |
| `base_peso_tipo` | `BOM_SNAPSHOT` o `PROMEDIO_LOTE_GOBERNADO`. |
| `peso_unitario_base_gr` | Valor congelado para atribución estándar; no finge medición individual. |
| `base_peso_referencia_id`, `base_peso_version`, `base_peso_congelada_at` | Fuente auditable del valor. |
| `operation_id`, `line_key`, `effect_id` | Comando padre, clave estable de línea e ID hijo determinístico. `(operation_id, line_key)` es único. |

La invariante cuantitativa por bolsa y componente es:

```text
cantidad_incorporada = cantidad_resultado_confirmada * cantidad_componente_estructura_snapshot
```

Una sustitución solo es válida si la revisión/política la autoriza y queda explícita. Componentes rotos, rechazados o usados fuera de la bolsa se registran como `MermaComponenteArmado`; consumen saldo, pero no aumentan `cantidad_incorporada` ni el peso esperado de la bolsa.

### Genealogía exacta

`AsignacionOrigenExacta` relaciona un consumo con uno o varios saldos de origen y su cantidad. La suma de asignaciones es igual a `cantidad_incorporada`. El origen puede ser [[Saldo_WIP_Salida]], lote o unidad logística liberada; no depende de compartir molde, OP, OT o fecha.

### Conjunto de candidatos

Cuando varias fuentes se mezclaron sin reparto conocible, el saldo consumible es una unidad/pool contado con genealogía `CONJUNTO_CANDIDATOS`. `GrupoOrigenCandidato` enlaza N:M ese pool con todos los lotes plausibles **sin cantidades por candidato**. El consumo debita la cantidad total del pool, no cada candidato, y toda consulta de impacto incluye a todos.

Si todavía existen bolsas identificadas por separado, primero se registra la consolidación/mezcla que crea el pool candidato; no se pierde granularidad solo por conveniencia.

### Legacy sin origen

`LEGACY_SIN_ORIGEN` consume una unidad o apertura de stock legacy previamente contada, con cantidad, Calidad, actor y motivo. La genealogía pobre nunca autoriza saldo negativo ni inventario infinito.

Para pesos derivados, `PROMEDIO_LOTE_GOBERNADO` solo se permite con asignación `EXACTA` a ese lote. `CONJUNTO_CANDIDATOS` y `LEGACY_SIN_ORIGEN` usan `BOM_SNAPSHOT` o un rango explícito gobernado, porque no existe un lote único cuyo promedio pueda atribuirse.

## Resultado

La ejecución acredita el resultado por **confirmación de manga**:

- una manga de [[Lote_WIP|WIP]] cuando todavía faltan operaciones de la ruta;
- una manga de `ProductoTerminado` cuando la operación completa la estructura
  comercial.

La confirmación conserva:

- artículo y revisión de estructura;
- cantidades objetivo, armadas, rechazadas y liberadas;
- consumos componentes y su nivel de genealogía;
- eventos, responsables, ubicación y fechas;
- la [[Unidad_Logistica]] de salida;
- estado de Calidad separado del estado logístico.

La identidad de la manga se reserva como `PLANIFICADA` antes de imprimir. En
ese estado no tiene cantidad real, peso ni saldo. Para producto terminado, la
manga y su `ConfirmacionBolsaOperacion` son la granularidad primaria de
trazabilidad. [[Lote_Producto_Terminado]] queda como agrupador opcional futuro y
no como requisito operativo.

Un resultado parcial solo puede persistir cuando existe un artículo WIP y una estructura gobernados. Nunca se degrada silenciosamente un producto incompleto a WIP genérico.

## Avance provisional, cierre de Armado y pesaje

Durante el llenado de una manga se pueden registrar avances idempotentes, por
ejemplo `+1` o `+10` conjuntos. El identificador persistido
`AVANCE_ENSAMBLE` se conserva únicamente como alias técnico heredado. Cada
evento contiene `manga_id`, secuencia, delta, actor y `operation_id`; la
secuencia es única por manga. Actualizan una proyección operativa inmediata,
pero no consumen inventario ni acreditan WIP/producto.

El cierre incluye `provisional_cutoff_seq`. Una
`ConciliacionAvanceArmado` enlaza todos los eventos con secuencia menor o
igual al corte y conserva `cantidad_provisional_al_corte`,
`cantidad_real_confirmada`, diferencia y responsable.

El responsable de Armado cuenta y confirma la cantidad desde su propio módulo.
El comando idempotente `CERRAR_MANGA_ARMADO`:

1. concilia los avances provisionales;
2. confirma la cantidad real;
3. acredita los cuerpos buenos en línea si todavía no fueron confirmados;
4. aplica reservas y consume cuerpos y componentes;
5. valida la BOM y separa la merma;
6. acredita el resultado productivo de esa manga;
7. deja la manga `CERRADA_ARMADO_PENDIENTE_PESAJE`.

Después, `CONFIRMAR_PESAJE_MANGA` registra únicamente bruto, tara, neto,
balanza, operador y tiempos. No vuelve a consumir ni acreditar y deja la manga
`PENDIENTE_RECEPCION_ALMACEN`.

Cada comando tiene su propio `operation_id`, hash e inbox idempotente. Sus
efectos hijos reciben IDs determinísticos. Un error de pesaje no revierte un
armado ya confirmado; deja la manga pendiente de repesaje o conciliación.

La manga y su `ReservaWIPSalida` —incluido `modo_origen`, cantidad máxima, estación y vigencia— existen en central antes de pesar. Si central no está disponible, el piloto no inicia la captura.

## Relación con el peso

La balanza mide una [[Unidad_Logistica]] de artículo armado completa, aunque este todavía sea WIP. El peso real del cuerpo y del asa no puede aislarse a partir de esa única lectura. La atribución usa cantidades y pesos unitarios congelados y siempre se etiqueta `ESTANDAR_DERIVADO`.

```text
peso_fisico_neto_kg = peso_bruto_kg - tara_kg
peso_esperado_bom_kg = SUM(cantidad_incorporada * peso_unitario_base_gr) / 1000
desviacion_armado_kg = peso_fisico_neto_kg - peso_esperado_bom_kg
```

Solo `cantidad_incorporada` participa en `peso_esperado_bom_kg`; la merma de armado queda fuera porque no está dentro de la bolsa.

## Correcciones

- `CORRECCION_PESO` compensa o reemplaza la lectura bajo un flujo de repesaje; no cambia cantidades ni consumos por sí sola.
- `CORRECCION_CANTIDAD_BOM` compensa resultado, WIP y componentes; conserva el peso físico original y recalcula el residual si la bolsa no fue modificada.
- `REAPERTURA_FISICA` exige autorización, ubicación controlada, nueva versión de empaque y, si corresponde, nuevo pesaje. No sobrescribe la captura anterior.

## Calidad

Los componentes retirados de stock deben estar `LIBERADO`. Para cuerpos
transferidos directamente desde la OT, el modelo admite una futura política
aprobada `USO_EN_PROCESO`; hasta que Planta la valide, no se asume autorización
implícita.

La manga resultante pasa por pesaje y luego por recepción de Almacén. El
movimiento inicial la registra con Calidad `PENDIENTE`. Calidad decide
`LIBERADA`, `BLOQUEADA` o `RECHAZADA` después de la recepción. Solo
`LIBERADA` queda disponible para reserva, consumo o despacho.

## Abastecimiento desde Almacén

La cuota de cada OT de Armado genera una necesidad de abastecimiento basada
en su BOM congelada. [[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas|US-010H]]
reserva artículos, selecciona mangas concretas por QR y registra despacho y
recepción de custodia. Ninguno de esos hechos consume componentes.

`CERRAR_MANGA_ARMADO` es la única autoridad para convertir el saldo entregado
en consumo genealógico de una salida. Los remanentes se devuelven identificados
o se concilian mediante una corrección compensatoria.

## Invariantes

- Confirmar un armado consume sus entradas y acredita el resultado una sola vez.
- La cantidad real la confirma el responsable de Armado; Balanza nunca la
  infiere ni la modifica.
- Toda manga de producto terminado debe tener un pesaje confirmado antes de
  ingresar a Almacén.
- Un replay exacto devuelve el mismo resultado.
- Una corrección agrega compensaciones enlazadas.
- El peso físico total no se acredita íntegramente a la OT de contexto.
- `CONJUNTO_CANDIDATOS` y `LEGACY_SIN_ORIGEN` nunca se muestran como genealogía exacta.
- Una bolsa armada contiene un solo lote/artículo principal WIP o producto; sus múltiples componentes se consultan mediante genealogía.
- Los avances provisionales no alteran saldos y siempre se distinguen de conjuntos confirmados.
- Al confirmar una bolsa se liquidan sus avances hasta un corte; nunca se suman provisional y confirmado como si fueran dos producciones.
- Cada consumo se enlaza a la confirmación/lote de salida concreto y cumple la cantidad de la BOM; scrap o rechazo se registra aparte.
- Una Orden de Armado no cierra mientras tenga bolsas planificadas o comandos de estación sin resolver.
- El cierre de su OT de contexto no invalida el armado cuando los cuerpos buenos de esa OT ya fueron acreditados. Una bolsa con `CREDITO_EN_LINEA_PENDIENTE` sí bloquea ese cierre hasta sincronizar o anularse.
- Una OA no depende de una OP singular ni utiliza `op_id` como vínculo de
  cobertura; toda adjudicación a demanda es N:M y cuantificada.
- Una OA puede ejecutarse en varias OT de Armado. Cada manga pertenece a una
  sola OT y su cantidad se acredita tanto a esa jornada como al total de la OA.
- Una manga PT no requiere un lote PT adicional. Si se crea una partida futura,
  solo agrupa mangas y no sustituye su identidad ni genealogía.
