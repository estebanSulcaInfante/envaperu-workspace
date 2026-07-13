---
tipo: modelo_bd
uso: modelo_bd
tags: [dominio, color, base, TS-008]
---

# ColorBase

## Metadata
- **Tabla BD:** `color_base`
- **Estado:** activo
- **Fecha creación:** 2026-07-12

## Descripción
Representa el pigmento puro o el color conceptual independiente de su acabado (familia). Ejemplo: "ROJO", "AZUL". Normalizado en TS-008.

## Campos de la Tabla

| Atributo | Tipo / Origen | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **id** | Integer | PK auto-incremental | - |
| **nombre** | String | Nombre del color base (ej. ROJO) | - |

## Validaciones
- `nombre` debe ser único y no nulo.

## Relaciones
- **Padre:** N/A
- **Hijos:** `ColorProduccion`
