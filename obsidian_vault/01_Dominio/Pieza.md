---
tipo: modelo_bd
tabla: pieza
estado: activo
tags: [dominio, maestro, pieza, TS-012]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# Pieza

Definición abstracta y reutilizable de una pieza, independiente del molde y del color con que se produce.

| Campo | Regla |
| :--- | :--- |
| `id`, `codigo` | Código `PZ-######` autogenerado e inmutable. |
| `nombre` | Identificación funcional de la pieza. |
| `linea_id`, `familia_id` | Clasificación válida según [[LineaFamilia]]. |
| `peso_nominal_gr` | Referencia de catálogo; no reemplaza el peso operativo del molde. |
| `activo`, `version` | Baja lógica y concurrencia optimista. |

## Relaciones

- **N:M con [[Molde]]:** mediante [[MoldePieza]].
- **1:N con [[PiezaColor]]:** una salida física por combinación pieza/color.

Las cavidades no son atributo de Pieza: cambian según el molde que la produce.
