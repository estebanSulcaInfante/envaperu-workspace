---
tipo: modelo_bd
uso: modelo_bd
tags: [dominio, color, produccion, TS-008, US-010R]
relaciones:
  - "[[PiezaColor]]"
  - "[[Articulo_SCM]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
fecha_actualizacion: 2026-07-24
---

# ColorProduccion

## Metadata
- **Tabla BD:** `color_produccion`
- **Estado:** activo
- **Fecha creación:** 2026-07-12

## Descripción
Catálogo maestro de colores estandarizados para uso en la producción (ej. Rojo 10, Azul 20). Introduce la normalización dictada en TS-008 para desacoplar el color intrínseco de los productos y piezas, evitando texto libre o duplicación.

## Campos de la Tabla

| Atributo | Tipo / Origen | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **id** | Integer | PK auto-incremental | - |
| **codigo** | Integer | Código numérico del color | - |
| **nombre** | String | Nombre del color (ej. ROJO) | - |
| **familia_id** | Integer | FK a `FamiliaColor` | - |
| **base_id** | Integer | FK a `ColorBase` (Opcional) | - |
| **activo** | Boolean | Si el color está disponible para ser usado | - |

## Validaciones
- La combinación de `codigo` y `nombre` permite definir un catálogo estandarizado (ej. 10 - ROJO).

## Relaciones
- **Padres:** [[FamiliaColor]] y [[ColorBase]].
- **Hijos:** [[PiezaColor]] y [[RecetaColorMaestra]].
- **No es hijo directo:** [[ProductoTerminado]] obtiene sus colores recorriendo la estructura de [[Articulo_SCM]] hasta sus hojas [[PiezaColor]]; un WIP WIP no crea otro dominio de color.
