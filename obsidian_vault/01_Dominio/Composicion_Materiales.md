---
tipo: modelo_bd
tabla: se_compone
estado: activo
tags: [dominio, materiales, mezcla, materia-prima]
relaciones:
  - padre: [[Lote_Color]]
fecha_creacion: 2026-04-21
---

# Composición de Materiales (Lista Dinámica)

Define la mezcla de materia prima para cada [[Lote_Color]]. Tabla `se_compone`.

## Campos de la Tabla

| Atributo | Origen | Descripción | Lógica |
| :--- | :--- | :--- | :--- |
| **Material** | Input (Select) | FK a `MateriaPrima`. | - |
| **Tipo** | Automático | Clasificación (Virgen, Segunda) traída del Material. | - |
| **Fracción** | Input (Manual) | Porcentaje de participación en la mezcla (0.0 a 1.0). | - |
| **calculo_peso_kg** | Calculado (persistido) | Kilos de material requeridos para este lote, incluyendo merma de colada. | `meta_kg × (1 + merma_pct) × fraccion` |

## Validación
> La suma de las fracciones de la lista `materiales` debe ser **1.0**.

## Relaciones
- **Padre:** [[Lote_Color]] (N:1)
- **FK:** `MateriaPrima`
