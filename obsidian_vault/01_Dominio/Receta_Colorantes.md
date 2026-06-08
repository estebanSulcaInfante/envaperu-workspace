---
tipo: modelo_bd
tabla: se_colorea
estado: activo
tags: [dominio, colorantes, pigmentos, receta]
relaciones_padre: "[[Lote_Color]]"
fecha_creacion: 2026-04-21
---

# Receta de Colorantes (Lista Dinámica)

Define la lista de pigmentos necesarios para el color. Tabla `se_colorea`.

## Campos de la Tabla

| Atributo | Origen | Descripción | Lógica |
| :--- | :--- | :--- | :--- |
| **Pigmento** | Input (Select) | FK a `Colorante`. | - |
| **Dosis (gramos)** | Input (Manual) | Gramos por bolsa (dosis). | - |

## Relaciones
- **Padre:** [[Lote_Color]] (N:1)
- **FK:** `Colorante`
