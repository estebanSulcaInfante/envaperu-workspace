---
tipo: modelo_bd
tabla: pieza_color
estado: activo
tags: [dominio, maestro, SKU, color, TS-007, TS-008, US-010R]
relaciones:
  - "[[Articulo_SCM]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-08-10
---

# PiezaColor

SKU físico producible: combinación de una [[Pieza]] con un [[Color_Produccion|ColorProduccion]]. Es la salida que participa en la BOM de [[ProductoTerminado]] y en los objetivos físicos de [[Lote_Color]].

## Campos relevantes

| Campo | Regla |
| :--- | :--- |
| `sku` | Código físico `PC-######`, autogenerado e inmutable. |
| `pieza_id` | Forma abstracta que materializa. |
| `color_produccion_id` | Color físico de la variante. |
| `imagen_mime` | Tipo de imagen admitido: `image/jpeg`, `image/png` o `image/webp`; nullable. |
| `imagen_data` | Contenido binario de la imagen; nullable y máximo 2 MB por contrato HTTP. |
| `estado_revision` | Estado de revisión progresiva del SKU. |

## Reglas

- La combinación `pieza_id + color_produccion_id` es única.
- El código es correlativo y autogenerado.
- Representa exclusivamente una pieza física coloreada producible; ya no posee
  atributo `tipo`.
- Línea y familia duplicadas en filas migradas son compatibilidad legacy; no se escriben como autoridad comercial en altas nuevas y su ausencia no bloquea la variante.
- El atributo legacy `cavidad` no es fuente operativa. Las cavidades pertenecen a [[MoldePieza]].
- Una fila sin `pieza_id` solo se tolera durante reconciliación legacy.
- La imagen identifica esta variante física, no la [[Pieza]] abstracta. `imagen_url` es un campo derivado del API y no una columna adicional.
- El color no se habilita como disponibilidad aislada cuando la pieza comparte tiro con otras salidas. Debe aplicarse al [[Molde]] completo mediante el comando documentado en [[Catalogo_Piezas_SKU_e_Imagenes]].

## Relaciones

- **Padres:** [[Pieza]] y [[Color_Produccion|ColorProduccion]].
- **N:M con [[ProductoTerminado]]:** mediante `ProductoPieza`.
- **Salida objetivo:** [[Lote_Color]].
- **Identidad SCM:** subtipo 1:1 `PIEZA_COLOR` de [[Articulo_SCM]].

La composición recursiva que antes intentó modelarse mediante `PiezaComponente`
se trasladó a las estructuras revisionadas de [[Articulo_SCM]]. La revisión
contract `a61c8d2f4e90`, aplicada localmente el 2026-07-25 con evidencia cero,
eliminó la tabla `pieza_componente` y la columna `pieza_color.tipo`.

La revisión `f63a2c8d4e70` trasladó la persistencia de imágenes desde `pieza` hacia `pieza_color`. No se copiaron imágenes legacy automáticamente porque una forma puede tener varios colores y no existe una asignación física inequívoca.
