---
tipo: decision-dominio
estado: aceptada
tags: [scm, prearmado, wip, rutas, bom, empaque, bolsas]
fecha_decision: 2026-07-24
relaciones:
  - "[[2026-07-23_Separacion_Peso_Fisico_Produccion_y_Armado]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[Articulo_SCM]]"
  - "[[Lote_WIP]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Perfil_Empaque]]"
---

# Prearmado parcial como WIP y empaque normalizado

## Contexto

EnvaPerú conoce antes de producir qué referencias permiten adelantar una parte del armado entre ciclos lentos. Esa actividad aprovecha tiempo del personal y reduce trabajo en un módulo posterior, pero el resultado no necesariamente completa el producto comercial.

Existió una implementación `PiezaColor.tipo=KIT` con autorrelación `PiezaComponente`. Nunca se utilizó con datos operativos y duplicaba responsabilidades de composición.

Las bolsas pueden contener una `PiezaColor` suelta o un WIP físicamente distinto, por ejemplo balde con asa prearmada. El estado físico cambia el acomodo y la cantidad que cabe en el mismo contenedor.

## Decisión

1. Se conserva la optimización de prearmado entre ciclos como operación planificada de ruta.
2. Una operación parcial acredita `LoteWIP`; solo la operación final acredita `ProductoTerminado`.
3. La composición recursiva se modela mediante BOM multinivel de `ArticuloSCM`, no mediante `PiezaColor.tipo=KIT`.
4. BOM y ruta son conceptos separados: composición frente a precedencia/ejecución.
5. Una misma operación puede ejecutarse parcialmente entre ciclos y parcialmente en estación dedicada sin cambiar artículo ni BOM.
6. `SaldoWIPSalida` representa piezas buenas sueltas; `LoteWIP` representa una transformación intermedia confirmada.
7. `UnidadLogistica` admite `LOTE_WIP` y separa tipo físico de contenedor del tipo de contenido.
8. El empaque se gobierna mediante `TipoContenedor`, `PerfilEmpacable` y `ReglaEmpaqueRevision`.
9. Para artículos discretos, la capacidad primaria se valida en unidades y se restringe por peso/seguridad. Los kg teóricos se derivan.
10. Planificar bolsas o imprimir stickers no crea inventario.
11. La cantidad real se cuenta o asigna; nunca se infiere dividiendo el peso.
12. El soporte KIT se retira solo después de comprobar cero filas. Cualquier dato inesperado aborta la migración.
13. Cada operación de ruta declara una sola autoridad: `OP_OT` para corrida de máquina o `ORDEN_OPERACION` para transformación WIP/final.
14. US-010P congela estructura y ruta; la regla de empaque exacta se congela al crear cada `PlanBolsa`. Su capacidad usa el menor límite neto entre operación y peso bruto descontando tara superior/margen.

## Relación con la decisión anterior

Se mantienen todas las reglas de separación entre:

- producción atribuible a la máquina;
- transformación/prearmado;
- peso físico completo de la bolsa.

Esta decisión sustituye únicamente el supuesto de que balde + asa siempre crea `LoteProductoTerminado`. El tipo de lote depende de la salida congelada de la ruta: WIP si faltan operaciones, producto terminado si la estructura comercial quedó completa.

## Consecuencias

- Se crea US-010R como fundamento anterior a P/C/F.
- US-010P netea inventario WIP antes de explotar componentes.
- US-010F generaliza `OrdenArmado` a `OrdenOperacion`.
- US-010D pesa bolsas de pieza, WIP o producto con el mismo contrato de unidad logística.
- El maestro de bolsa no se relaciona directamente con `PiezaColor`; usa un perfil del estado físico.
- No se necesita backfill de kits legacy, pero sí un preflight defensivo reproducible.

## Alternativas descartadas

### Eliminar el prearmado entre ciclos

Descartada como decisión inicial porque elimina una práctica que aprovecha capacidad ociosa. Su conveniencia se medirá por referencia/máquina mediante ciclos perdidos, defectos y tiempo posterior ahorrado.

### Revivir `PiezaColor.tipo=KIT`

Descartada porque una pieza producible por molde no debe representar simultáneamente un WIP o producto.

### Definir capacidad únicamente en kg

Descartada porque forma, volumen, anidamiento y estado de prearmado pueden llenar el contenedor antes del límite de peso.
