---
tipo: modelo_objetivo
estado: en-refinamiento
tags: [dominio, scm, operacion, transformacion, wip, armado, US-010R, US-010F]
relaciones:
  - "[[Orden_Produccion]]"
  - "[[Orden_Fabricacion]]"
  - "[[Articulo_SCM]]"
  - "[[Ruta_Produccion]]"
  - "[[Lote_WIP]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Orden_Armado]]"
  - "[[Registro_Diario]]"
  - "[[Unidad_Logistica]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-07-30_OT_Diaria_Comun_para_Fabricacion_y_Armado]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-08-09
---

# Orden de Operación

Abstracción común de una orden ejecutable que materializa una operación
congelada de [[Ruta_Produccion]]. No obliga a usar una sola tabla ni se presenta
como documento genérico al operario: se concreta como
[[Orden_Fabricacion|Orden de Fabricación]] para molde/máquina o
[[Orden_Armado|Orden de Armado]] para transformaciones de componentes.

No es sinónimo de la [[Registro_Diario|Orden de Trabajo]]. La orden de operación
conserva el objetivo completo y sus snapshots; la OT despacha una porción
diaria de una OF o una OA. Una ejecución concurrente de Armado puede conservar
además la OT de Fabricación como contexto, sin reemplazar su propia OT de
Armado.

Los nombres funcionales de los ejecutores son **Orden de Fabricación** y
**Orden de Armado**. Los valores persistidos `ORDEN_ENSAMBLE`, `OP_OT` y
`ORDEN_OPERACION` son aliases técnicos heredados y nunca se muestran al
usuario.

## Cabecera

| Campo | Regla |
|---|---|
| `id`, `codigo` | Identidad global y correlativo legible. |
| `tipo_orden` | Fabricación o Armado; el valor persistido `ENSAMBLE` es un alias técnico temporal. |
| `operacion_ruta_id` | Operación y ejecutor congelados. |
| `articulo_salida_id` | Artículo principal cuando aplica; una OF multipieza usa además líneas de salida. |
| `revision_estructura_id`, `estructura_hash` | Composición inmutable. |
| `cantidad_objetivo` | Unidades planificadas. |
| `cantidad_confirmada` | Proyección desde confirmaciones finales idempotentes. |
| `origen_demanda`, `motivo` | OP, reposición, muestra, reproceso u otra fuente gobernada. |
| `estado` | `BORRADOR`, `LIBERADA`, `PROGRAMADA`, `EN_EJECUCION`, `CERRADA` o `ANULADA`. |

La relación con [[Orden_Produccion]] es N:M mediante
`AsignacionDemandaSuministro`; no existe un `op_id` padre obligatorio.

## Orden de Trabajo diaria

Una [[Registro_Diario|OT]] organiza una porción diaria en una fecha, turno,
centro y equipo concretos. La relación técnica difiere por especialización:

| Tipo de orden | Tipo de OT | Datos específicos |
|---|---|---|
| `FABRICACION` | `OT_FABRICACION` | La cabecera define máquina/fecha/turno; cada [[Trabajo_Color]] hijo referencia una OF/corrida exacta. |
| Armado | OT de Armado | La OT referencia una OA exacta, centro/celda, responsable de Armado y equipo. |

Una OF puede repartirse entre varios Trabajos de color y OT. Una OT normalizada
de Fabricación puede contener trabajos de varias OF compatibles. Una OA puede
tener varias OT de Armado, pero cada OT de Armado pertenece exactamente a una
OA. Esta asimetría está congelada en
[[2026-08-09_Jornadas_de_Planta_y_Fechas_Proyectadas_de_OF_OA]].

## EjecucionOperacion

Permite dividir el objetivo sin cambiar la identidad del resultado:

| Campo | Regla |
|---|---|
| `orden_operacion_id` | Orden común. |
| `modo` | `CONCURRENTE_ENTRE_CICLOS` o `ESTACION_DEDICADA`. |
| `orden_trabajo_id` | OT propia que ejecuta la porción diaria. |
| `ot_contexto_fabricacion_id` | Opcional para armado concurrente entre ciclos; no reemplaza la OT propia. |
| `ubicacion_id`, `responsable_id` | Lugar y responsable reales. |
| `cantidad_objetivo`, `cantidad_confirmada` | Asignación y resultado de esa ejecución. |

## Confirmación

Cada confirmación:

1. concilia avance provisional si existe;
2. valida y consume entradas reservadas;
3. registra merma separada de lo incorporado;
4. acredita WIP o producto terminado según `articulo_salida_id`;
5. deja la manga cerrada y pendiente de pesaje;
6. conserva un único `operation_id` y efectos hijos determinísticos.

## Invariantes

- El artículo resultante y su estructura no cambian entre ejecuciones de la misma orden.
- El subtipo coincide con el ejecutor de ruta congelado; una operación de
  fabricación no se ejecuta como OA ni viceversa.
- Una ejecución concurrente no atribuye a la OT componentes fabricados previamente.
- Una salida intermedia acredita [[Lote_WIP]], nunca producto terminado.
- La suma confirmada no excede el objetivo salvo ampliación autorizada.
- Un replay exacto no duplica consumos, lote, peso o movimientos.
- La orden no cierra con reservas, bolsas o comandos pendientes.
- `OrdenFabricacion` gobierna molde, corridas y OT; `OrdenArmado` gobierna
  consumos, transformación y sus OT de Armado.
- Ninguna orden ejecutable exige una OP singular como padre.
