---
tipo: modelo_bd
tabla: se_colorea
estado: activo
tags: [dominio, colorantes, pigmentos, receta]
relaciones_padre: "[[Lote_Color]]"
relaciones:
  - "[[US-006_Normalizar_Composicion_Color_Familia]]"
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
fecha_creacion: 2026-04-21
---

# Receta de Colorantes (Lista Dinámica)

Define la lista de pigmentos necesarios para el color. La tabla actual es `se_colorea`; US-010B normaliza la semántica de dosificación para que pueda reservarse y trazarse inventario.

## Campos de la Tabla

| Atributo | Origen | Descripción | Lógica |
| :--- | :--- | :--- | :--- |
| **Pigmento** | Input (Select) | FK a `Colorante`. | - |
| **Dosis legacy (`gramos`)** | Input (Manual) | Campo actual ambiguo. No distingue dosis de cantidad absoluta. | Debe migrarse o interpretarse solo con una base explícita. |
| **Dosis objetivo** | Input (Manual) | Gramos de colorante por cada `25 kg` de material virgen. | Semántica conceptual: `dosis_g_por_25kg_virgen`. |

## Regla de Dosificación Validada

Decisión de negocio del 2026-07-15:

`colorante_plan_kg = (kg_virgen_base / 25.000) × (dosis_g_por_25kg_virgen / 1000)`

- La base incluye únicamente las líneas de material virgen declaradas por la receta.
- El material de segunda, tanto recuperado internamente como comprado, no aumenta la dosis.
- Si existen varias líneas vírgenes, la receta debe identificar cuáles forman la base; no se infiere por nombre libre.
- Las bolsas parciales escalan proporcionalmente.

Ejemplo: `70.000 kg` de virgen y `500 g/25 kg virgen` requieren `1.400 kg` de colorante, aunque la mezcla también contenga `28.000 kg` de material recuperado.

## Cantidades que no deben confundirse

1. Dosis maestra: gramos por `25 kg` de virgen.
2. Cantidad planificada: kg absolutos calculados para el lote de producción.
3. Cantidad emitida: kg físicos entregados desde un lote de inventario.
4. Cantidad incorporada: kg realmente consumidos al confirmar la premezcla.

`RecetaColorNormalizada.gr_por_kg` y el cálculo actual basado en `meta_kg` contradicen esta regla y quedan como deuda de refactor de [[US-010B_Reserva_Emision_Materiales_OP]].

## Relaciones
- **Padre:** [[Lote_Color]] (N:1)
- **FK:** `Colorante`
