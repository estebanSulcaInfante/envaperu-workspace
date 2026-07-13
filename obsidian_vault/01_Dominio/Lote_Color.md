---
tipo: modelo_bd
tabla: lote_color
estado: activo
tags:
  - dominio
  - core
  - lote
  - color
  - produccion
relaciones_padre:
  - "[[Orden_Produccion]]"
relaciones_hijos:
  - "[[Composicion_Materiales]]"
  - "[[Receta_Colorantes]]"
fecha_creacion: 2026-04-21
---

# Lote de Color

Entidad hija (`LoteColor`). Cada lote representa un color de producción. Recibe `meta_kg` como **único input** de producción, eliminando el polimorfismo por estrategia.

## Campos de la Tabla

| Atributo                 | Tipo                   | Descripción                                                               | Fórmula / Lógica                                    |
| :----------------------- | :--------------------- | :------------------------------------------------------------------------ | :-------------------------------------------------- |
| **Color**                | Input (FK)             | Referencia a `ColorProduccion` (normalizado en TS-008). | -                                                   |
| **Producto SKU Output**  | Input (FK, nullable)   | Referencia al SKU de `ProductoTerminado` que produce este lote.           | -                                                   |
| **meta_kg**              | **Input directo**      | Kilos objetivo para este color. Es el único input de producción del lote. | Usuario ingresa directamente                        |
| **Personas**             | Input                  | Operarios asignados a la mezcla. Default: 1.                              | -                                                   |
| **calculo_coladas**      | Calculado (persistido) | Golpes necesarios para cumplir la meta. Float exacto, sin redondeo.       | `(meta_kg × 1000) / peso_neto_golpe_gr`             |
| **calculo_kg_real**      | Calculado (persistido) | Kg reales que produce la máquina exactamente.                             | `calculo_coladas × peso_neto_golpe_gr / 1000`       |
| **calculo_horas_hombre** | Calculado (persistido) | Horas-Hombre proporcionales al tiempo total de la orden.                  | `(dias_orden × horas_turno × personas) / n_colores` |

> **Nota sobre `calculo_coladas`:** Es Float exacto sin `math.ceil`. Si se requiere un entero para planificación física, se aplica ceil en la capa de presentación.

## Estructura JSON (dentro de la respuesta de [[Orden_Produccion]])

```json
{
  "id": 1,
  "Color": "Amarillo",
  "meta_kg": 175.0,
  "kg_real": 174.993,
  "coladas": 1006.8390,
  "materiales": [ ... ],
  "pigmentos": [ ... ],
  "mano_obra": { "personas": 1, "horas_hombre": 18.3 }
}
```

## Relaciones
- **Padre:** [[Orden_Produccion]] (N:1)
- **Hijos:** [[Composicion_Materiales]] (1:N), [[Receta_Colorantes]] (1:N)
