---
tipo: modelo_bd
tabla: receta_color_maestra
estado: activo
tags: [dominio, maestro, receta, color, TS-016]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# RecetaColorMaestra

Fórmula versionada y gobernada para producir un [[Color_Produccion|ColorProduccion]]. Puede ser general o específica para un [[ProductoTerminado]].

## Cabecera

| Campo | Regla |
| :--- | :--- |
| `color_produccion_id` | Color resultante obligatorio. |
| `producto_terminado_id` | Alcance opcional; vacío significa receta general. |
| `revision` | Versión funcional de la fórmula. |
| `estado` | `BORRADOR`, `APROBADA` o `INACTIVA`. |
| `base_virgen_kg` | Base de referencia para interpretar todas las dosis por kg virgen. |
| `es_predeterminada` | Solo una por alcance puede ser predeterminada. |
| `notas`, `origen`, `version` | Auditoría y concurrencia. |

## Componentes: RecetaColorLinea

Cada línea referencia un [[MaterialSCM]] y declara un rol:

- `MATERIA_PRIMA`: fracción `0..1` de la base; la suma de fracciones debe ser `1`.
- `COLORANTE` o `ADITIVO`: dosis en gramos asociada a la base virgen indicada. La razón normalizada es `dosis_g / base_virgen_kg`.

`base_virgen_kg` no agrega material por sí sola. Es el denominador común que permite escalar la receta sin ambigüedad; las líneas de materia prima indican de qué materiales se compone esa base.

## Gobierno

- Solo una receta completa y válida puede aprobarse.
- La OP conserva la receta/revisión aplicada y sus cantidades calculadas.
- [[Receta_Colorantes]] representa la aplicación en la OP; `RecetaColorNormalizada` es evidencia histórica/analítica, no reemplaza este maestro.
