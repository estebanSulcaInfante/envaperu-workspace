---
tipo: modelo_bd
tabla: snapshot_composicion_molde
estado: activo
tags: [dominio, snapshot, molde, multipieza]
relaciones:
  - padre: [[Orden_Produccion]]
fecha_creacion: 2026-04-21
---

# Snapshot de Composición del Molde

Tabla `snapshot_composicion_molde`. Congela la configuración de piezas del molde **al momento de crear la OP**. Reemplaza los anteriores campos escalares `snapshot_cavidades` y `snapshot_peso_neto_gr` de la cabecera.

## Motivación
Un molde puede producir distintos tipos de piezas simultáneamente (molde multi-pieza). Esta estructura permite registrar cada tipo de pieza con sus propias cavidades y peso unitario.

## Campos de la Tabla

| Atributo | Tipo | Descripción |
| :--- | :--- | :--- |
| **id** | Auto (BD) | Primary Key. |
| **orden_id** | FK | Referencia al `numero_op` de la [[Orden_Produccion]] padre. |
| **pieza_sku** | FK (nullable) | Referencia a `Pieza`. Nullable para override manual sin pieza en catálogo. |
| **cavidades** | Input | Número de cavidades para este tipo de pieza en el golpe. |
| **peso_unit_gr** | Input | Peso de una unidad de esta pieza (gramos). |
| **peso_subtotal_gr** | Calculado | `cavidades × peso_unit_gr` |

## Relaciones
- **Padre:** [[Orden_Produccion]] (N:1)
- **FK opcional:** `Pieza` (catálogo de piezas)
