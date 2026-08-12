---
tipo: modelo_objetivo
estado: en-refinamiento
tags: [dominio, scm, lote, producto-terminado, genealogia, US-010R, US-010F]
relaciones:
  - "[[Articulo_SCM]]"
  - "[[ProductoTerminado]]"
  - "[[Ruta_Produccion]]"
  - "[[Orden_Operacion]]"
  - "[[Lote_WIP]]"
  - "[[Unidad_Logistica]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-07-30
---

# Lote o partida opcional de Producto Terminado

Agrupador opcional de una o más mangas comercialmente completas de un
[[ProductoTerminado]]. No es la unidad mínima de inventario ni un requisito
para ejecutar el flujo.

La granularidad primaria es:

```text
ConfirmacionBolsaOperacion
  -> UnidadLogistica (manga PT)
  -> contenido, cantidad y genealogía propios
```

Una manga PT puede planificarse, cerrarse, pesarse, recibirse, liberarse y
despacharse sin crear un lote adicional.

No es el maestro de producto ni un [[Lote_WIP]]. Un resultado intermedio sigue siendo WIP aunque esté embolsado, tenga apariencia utilizable o se haya prearmado junto a una máquina.

## Cuándo se justifica

Puede incorporarse posteriormente como `PartidaPT` cuando Calidad o negocio
necesiten agrupar varias mangas bajo una misma decisión, certificado, fecha de
caducidad o campaña. No debe obligar a los operarios a crear otra entidad para
cada bolsa.

## Atributos mínimos si se habilita

| Campo | Regla |
|---|---|
| `id`, `codigo` | Identidad global y código legible no reutilizable. |
| `articulo_producto_id`, `producto_terminado_id` | Subtipo `PRODUCTO_TERMINADO` exacto y su maestro 1:1. |
| `revision_estructura_id`, `estructura_hash` | Composición comercial congelada. |
| `revision_ruta_id`, `ruta_hash`, `operacion_ruta_id` | Ruta y operación final que autorizan el resultado. |
| `orden_operacion_id` | OF terminal u OA que lo produjo. |
| `cantidad_acreditada`, `cantidad_disponible` | Proyecciones derivadas de sus mangas; no se editan. |
| `estado_calidad` | Independiente del estado logístico. |
| `ubicacion_id` | Nula hasta la recepción de Almacén; después refleja ubicación inventariable. |
| `event_time`, `record_time`, `actor_id` | Evidencia temporal y responsable. |

## Genealogía

Cada `ConfirmacionBolsaOperacion` enlaza la manga resultante con los orígenes y
cantidades realmente consumidos. Sus entradas pueden ser [[PiezaColor]],
[[Lote_WIP]] u otros artículos permitidos por la estructura congelada y pueden
proceder de distintas OP, OT, fechas o ubicaciones.

La genealogía no se reconstruye desde el peso ni desde la cercanía temporal. El peso completo de una bolsa de producto pertenece a la [[Unidad_Logistica]]; no se atribuye íntegramente a la OT que produjo solo uno de sus componentes.

## Reglas

- Planificar o reservar una manga no acredita inventario.
- Solo la operación final de la ruta puede acreditarlo, ya sea ejecutada por
  `ORDEN_FABRICACION` o por `ORDEN_ENSAMBLE`.
- Cerrar la manga en Armado consume todas las entradas requeridas y acredita el
  resultado en una transacción idempotente.
- Si falta una operación precedente o un componente obligatorio, no existe acreditación parcial de producto terminado.
- La cantidad acreditada es discreta y positiva; el peso no determina unidades.
- El saldo nunca es negativo y se deriva de movimientos.
- Acreditar producción no crea por sí solo stock de Almacén. Una manga pesada queda pendiente de recepción hasta US-010I.
- Calidad `PENDIENTE` no equivale a disponibilidad ni permite despacho.
- Una [[Unidad_Logistica]] de producto referencia directamente el artículo PT y
  su confirmación de operación. Si existe `PartidaPT`, la relación es de
  agrupación y no reemplaza esas referencias.
- Una corrección agrega movimientos compensatorios y conserva el hecho original.
