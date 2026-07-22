---
tipo: modelo_bd
tabla: producto_terminado
estado: activo
tags: [dominio, maestro, producto, BOM, TS-007]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# ProductoTerminado

Maestro del SKU comercial que se planifica en una [[Orden_Produccion]]. Se clasifica por [[Linea]] y [[Familia]], pero no posee un color único: sus salidas físicas se definen mediante la BOM.

## Campos esenciales

| Campo | Regla |
| :--- | :--- |
| `id`, `codigo` | Identidad técnica y código correlativo autogenerado. |
| `nombre` | Nombre comercial del producto. |
| `linea_id`, `familia_id` | La combinación debe estar habilitada en [[LineaFamilia]]. |
| `activo`, `version` | Baja lógica y concurrencia optimista. |

## BOM: ProductoPieza

`ProductoPieza` relaciona N:M el producto con [[PiezaColor]] e incorpora `cantidad`. Cada fila significa cuántas unidades de ese SKU físico forman una unidad vendible del producto.

Restricciones:

- la pareja `producto_id + pieza_color_id` es única;
- `cantidad` debe ser positiva;
- no se infiere el color desde el producto;
- `PiezaComponente` queda como compatibilidad legacy y no es la BOM canónica.

## Relaciones

- **N:M:** [[PiezaColor]] mediante `ProductoPieza`.
- **Clasificación:** [[Linea]] y [[Familia]].
- **Consumidor:** [[Orden_Produccion]].
