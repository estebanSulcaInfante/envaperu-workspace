---
tipo: modelo_bd
tabla: pieza_color
estado: activo
tags: [dominio, maestro, SKU, color, TS-007, TS-008]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# PiezaColor

SKU físico producible: combinación de una [[Pieza]] con un [[Color_Produccion|ColorProduccion]]. Es la salida que participa en la BOM de [[ProductoTerminado]] y en los objetivos físicos de [[Lote_Color]].

## Reglas

- La combinación `pieza_id + color_produccion_id` es única.
- El código es correlativo y autogenerado.
- Línea y familia duplicadas en filas migradas son compatibilidad legacy; para altas nuevas se derivan de Pieza.
- El atributo legacy `cavidad` no es fuente operativa. Las cavidades pertenecen a [[MoldePieza]].
- Una fila sin `pieza_id` solo se tolera durante reconciliación legacy.

## Relaciones

- **Padres:** [[Pieza]] y [[Color_Produccion|ColorProduccion]].
- **N:M con [[ProductoTerminado]]:** mediante `ProductoPieza`.
- **Salida objetivo:** [[Lote_Color]].
