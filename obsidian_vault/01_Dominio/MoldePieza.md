---
tipo: modelo_bd
tabla: molde_pieza
estado: activo
tags: [dominio, asociacion, molde, pieza, cavidades, TS-012]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# MoldePieza

Entidad asociativa que normaliza la relación N:M entre [[Molde]] y [[Pieza]]. Describe cómo un molde específico produce una pieza específica.

| Campo | Regla |
| :--- | :--- |
| `molde_id`, `pieza_id` | Pareja única. |
| `cavidades` | Número entero positivo de cavidades de esa pieza en ese molde. |
| `peso_unit_gr` | Peso operativo de la pieza para esa combinación. |
| `activo`, `version` | Vigencia lógica y concurrencia optimista. |

`peso_subtotal_gr = cavidades × peso_unit_gr`.

Esta es la fuente canónica de cavidades. Los campos legacy con nombres semejantes en SKU o importaciones no deben alimentar cálculos nuevos.
