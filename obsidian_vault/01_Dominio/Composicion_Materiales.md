---
tipo: modelo_bd
tabla: se_compone
estado: activo
tags: [dominio, materiales, mezcla, materia-prima]
relaciones_padre:
  - "[[Lote_Color]]"
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-07-21
---

# Composición de Materiales (Lista Dinámica)

Define la mezcla de materia prima para cada [[Lote_Color]]. Tabla `se_compone`.

## Campos de la Tabla

| Atributo            | Origen                 | Descripción                                                              | Lógica                                 |
| :------------------ | :--------------------- | :----------------------------------------------------------------------- | :------------------------------------- |
| **Material**        | Input (Select)         | FK a `MateriaPrima`.                                                     | -                                      |
| **Tipo**            | Automático             | Clasificación (Virgen, Segunda) traída del Material.                     | -                                      |
| **Fracción**        | Input (Manual)         | Porcentaje de participación en la mezcla (0.0 a 1.0).                    | -                                      |
| **calculo_peso_kg** | Calculado (persistido) | Kilos de material requeridos para este lote, incluyendo merma de colada. | `meta_kg × (1 + merma_pct) × fraccion` |

## Validación
> La suma de las fracciones de la lista `materiales` debe ser **1.0**.

## Base para Dosificar Colorantes

La fracción de una materia prima determina su participación en la mezcla, pero no convierte todo el peso de la mezcla en base de colorante.

**Decisión de negocio del 2026-07-15:** los colorantes se dosifican en gramos por cada `25 kg` de material virgen. Por tanto:

- `kg_virgen_base` se obtiene únicamente de las líneas vírgenes que la revisión de receta declare como base;
- las líneas `SEGUNDA`, tanto recuperadas internamente como compradas, no incrementan el colorante;
- `meta_kg` y la suma total de la mezcla no sustituyen a `kg_virgen_base`;
- cuando existan varias materias primas vírgenes, la receta debe preservar explícitamente cuáles participan en la base.

La representación física de esta regla se definirá en `TS-010B`; no debe inferirse mediante nombres o descripciones de materiales.

## Frontera de Premezcla

La premezcla operacional junta las materias primas indicadas por la receta —virgen y/o segunda— con colorante y aditivos aplicables. El `LoteMezclaPreparada` representa el material homogenizado que sale de la tolva listo para alimentar la máquina.

Cuando se registran lotes y cantidades efectivamente incorporados, su procedencia es `EXACTA`. Si se combinan bolsas de distintos proveedores sin conservar esa asignación, la mezcla usa `CONJUNTO_CANDIDATOS`: mantiene todas las recepciones/proveedores plausibles y no inventa cantidades ni porcentajes por origen.

## Relaciones
- **Padre:** [[Lote_Color]] (N:1)
- **FK:** `MateriaPrima`
