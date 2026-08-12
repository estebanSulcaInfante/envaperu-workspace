---
tipo: modelo_objetivo
estado: implementado-r-core
tags: [dominio, scm, ruta, operaciones, manufactura, wip, US-010R]
relaciones:
  - "[[Articulo_SCM]]"
  - "[[ProductoTerminado]]"
  - "[[Orden_Produccion]]"
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Armado]]"
  - "[[Lote_WIP]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-08-06
---

# Ruta de Producción

Definición revisionada de las operaciones necesarias para convertir componentes y salidas intermedias en un artículo objetivo. Complementa la BOM de [[Articulo_SCM]]: la BOM define composición; la ruta define secuencia, recursos, entradas y salidas por operación.

El modelo maestro revisionado, sus validaciones DAG y la API local se implementaron en el incremento R3 de [[DEV-010R_R-Core_Articulos_BOM_Rutas_y_Empaque]]. La ejecución y genealogía siguen perteneciendo a US-010F/R-runtime.

## RevisionRutaProducto

| Campo | Regla |
|---|---|
| `producto_terminado_id` | Producto cuya fabricación organiza. |
| `numero_revision` | Correlativo por producto. |
| `estado` | `BORRADOR`, `APROBADA` o `RETIRADA`. |
| `content_hash` | Huella de operaciones, precedencias, entradas y salidas. |
| `vigente_desde`, `vigente_hasta` | Vigencia auditable. |
| `aprobada_por_id`, `aprobada_at` | Autoridad y fecha. |

## OperacionRuta

Cada operación conserva:

- código, nombre y secuencia visible;
- tipo: inyección, prearmado, armado, acabado o empaque;
- autoridad de ejecución: **Orden de Fabricación** para una corrida gobernada
  por OF/OT u **Orden de Armado** para una transformación intermedia/final;
  `ORDEN_ENSAMBLE`, `OP_OT` y `ORDEN_OPERACION` son aliases técnicos heredados;
- centro/módulo de trabajo esperado;
- artículo de salida principal;
- revisión de estructura obligatoria para una Orden de Armado; en
  `ORDEN_FABRICACION` puede ser nula cuando molde, receta y requerimientos de
  material gobiernan la salida y se congelan en la OF;
- entradas de artículos derivadas de la estructura cuando aplica, consultables en la ruta pero sin una segunda cantidad editable;
- precedencias explícitas;
- permiso de ejecución concurrente;
- parámetros de tiempo o capacidad cuando estén gobernados.

La secuencia visible no sustituye el grafo de precedencias. No se permiten
ciclos. La ruta puede agregar recursos, tiempos, centro y modo de ejecución,
pero la cantidad por componente de WIP/PT pertenece exclusivamente a
`RevisionEstructuraArticulo`; resina, colorante y aditivos de una corrida
`ORDEN_FABRICACION` continúan gobernados por la receta congelada de la OF.

## Plan y ejecución

La OP congela la revisión de ruta. La autoridad ejecutora queda fijada por operación:

- `ORDEN_FABRICACION`: la necesidad se convierte en propuesta de OF; la OT/RDP
  ejecuta ciclos de máquina y acredita la salida congelada. Normalmente será
  `LoteSalidaPiezaColor`, pero una operación terminal puede producir
  directamente [[Lote_Producto_Terminado]]. No crea una OA paralela.
- **Orden de Armado**: la necesidad se convierte en [[Orden_Armado]] y acredita
  [[Lote_WIP]] o producto terminado. No acredita ciclos ni kg de máquina.

Una misma operación de prearmado con `executor_kind=ORDEN_OPERACION` puede tener varias ejecuciones:

```text
Objetivo: prearmar 1,000 unidades
├── 400 entre ciclos de inyección
└── 600 en el módulo posterior
```

Ambas ejecuciones consumen la misma estructura aprobada y generan el mismo tipo de [[Lote_WIP]]. La ubicación o el momento no crean otro SKU ni otra BOM.

`modo_ejecucion` diferencia:

- `CONCURRENTE_ENTRE_CICLOS`;
- `ESTACION_DEDICADA`;
- `MIXTA`, solo como proyección del plan; cada confirmación conserva su modo real.

Una Orden de Trabajo/RDP puede ser contexto de una ejecución concurrente, pero no absorbe los consumos previos ni acredita como inyección el peso completo del WIP.

## Invariantes

- Solo una revisión aprobada puede congelarse en una nueva planificación.
- Aprobar una ruta exige que todas sus estructuras y artículos referenciados sean resolubles.
- Una operación ejecutada mediante Orden de Armado referencia una revisión de estructura compatible con su artículo de salida; no mantiene una BOM paralela.
- Una operación `ORDEN_FABRICACION` no inventa una estructura de artículos para la resina: usa composición de molde y receta congeladas por la OF.
- Cada operación declara exactamente una autoridad de ejecución.
  `ORDEN_FABRICACION` puede producir `PIEZA_COLOR`, `SUBENSAMBLE_WIP` o
  `PRODUCTO_TERMINADO`; la Orden de Armado ejecuta una transformación separada.
- Una misma operación nunca se materializa simultáneamente como OT y `OrdenOperacion`.
- Toda operación inventariable posee al menos una salida identificada.
- Una operación intermedia acredita WIP, no producto terminado.
- La suma de ejecuciones confirmadas no excede el objetivo sin una ampliación autorizada.
- La ejecución concurrente es una decisión de planificación/operación; no modifica composición, genealogía ni identidad de salida.
- Una OP histórica conserva revisión, hash y snapshot aunque cambie el maestro.
