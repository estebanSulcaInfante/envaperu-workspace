---
tipo: modelo_bd
tabla: pieza
estado: activo
tags: [dominio, maestro, pieza, TS-012]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-08-10
---

# Pieza

Definición abstracta y reutilizable de una pieza, independiente del molde y del color con que se produce.

| Campo | Regla |
| :--- | :--- |
| `id`, `codigo` | Código `PZ-######` autogenerado e inmutable. |
| `nombre` | Identificación funcional de la pieza. |
| `linea_id`, `familia_id` | Clasificación técnica opcional; si se informa, el par debe ser válido según [[LineaFamilia]]. |
| `peso_nominal_gr` | Referencia de catálogo; no reemplaza el peso operativo del molde. |
| `activo`, `version` | Baja lógica y concurrencia optimista. |

## Relaciones

- **N:M con [[Molde]]:** mediante [[MoldePieza]].
- **1:N con [[PiezaColor]]:** una salida física por combinación pieza/color.

Las cavidades no son atributo de Pieza: cambian según el molde que la produce.

La clasificación comercial pertenece a [[ProductoTerminado]]. Crear una Pieza desde el alta de un PT no copia Línea/Familia silenciosamente; la reutilización comercial se resuelve mediante BOM.

## Imagen y color

`Pieza` es una forma abstracta y, por tanto, **no almacena imagen ni color**. Una fotografía identifica una presentación física concreta y pertenece a [[PiezaColor]]. La revisión `f63a2c8d4e70` eliminó de `pieza` las columnas legacy `imagen_mime` e `imagen_data`.
