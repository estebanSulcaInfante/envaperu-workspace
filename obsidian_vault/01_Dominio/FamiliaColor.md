---
tipo: modelo_bd
uso: modelo_bd
tags: [dominio, color, familia, TS-008]
---

# FamiliaColor

## Metadata
- **Tabla BD:** `familia_color`
- **Estado:** activo
- **Fecha creación:** 2026-07-12

## Descripción
Catálogo de familias o acabados de colores (ej. SÓLIDO, CARAMELO, NEÓN). Normalizado en TS-008.

## Campos de la Tabla

| Atributo | Tipo / Origen | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **id** | Integer | PK auto-incremental | - |
| **nombre** | String | Nombre de la familia (ej. SOLIDO) | - |

## Validaciones
- `nombre` debe ser único y no nulo.

## Relaciones
- **Padre:** N/A
- **Hijos:** `ColorProduccion`
