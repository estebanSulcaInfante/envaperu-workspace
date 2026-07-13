---
tipo: adr
estado: aceptada
fecha: 2026-07-11
tags: [arquitectura, color, familia-color, receta, normalizacion]
relaciones:
  - "[[US-001_Creacion_Agil_Molde_Producto_Pieza]]"
  - "[[US-006_Normalizar_Composicion_Color_Familia]]"
supersede: null
---

# ADR: Revalorización de FamiliaColor como Clave de Receta de Composición

## Contexto

En la US-001 (Creación Ágil Molde-Producto-Pieza) se estableció que `FamiliaColor` era un campo **meramente descriptivo/clasificatorio** del catálogo comercial de `ProductoTerminado`. Se definió que no debía participar en lógica de generación de SKU, conteos de producción ni validaciones del wizard.

## Decisión

A partir de la US-006 (Normalizar Composición del Color-Familia), `FamiliaColor` adquiere un **rol funcional nuevo**: es parte de la clave compuesta `(color_id, familia_color_id, variante)` que identifica una **receta estándar de composición** (materias primas + colorantes + aditivos por cada 25kg).

### Alcance del cambio

| Contexto | Rol de FamiliaColor | Cambio |
|:---|:---|:---|
| Wizard de Creación en Cascada (SKU) | ❌ No participa | Sin cambio |
| Validación de OP (`validar-orden-prereq`) | ❌ No participa | Sin cambio |
| Generación de SKU | ❌ No participa | Sin cambio |
| **Receta de Composición (US-006)** | ✅ **Clave compuesta** | **Nuevo rol** |
| Cache en `Orden_Produccion.calculo_familia_color` | ℹ️ Informativo | Sin cambio |

### Motivación

La misma pieza (ej. "Balde") en color "Rojo" puede requerir recetas de materiales distintas según la familia de acabado:
- **Rojo SOLIDO:** PP Clarif. 3/6 + PP Molido 3/6 + Rojo R120 80g
- **Rojo TRANSPARENTE:** PP Transp. 5/6 + PP Molido 1/6 + Rojo R120 40g

Sin `FamiliaColor` como discriminador, sería imposible tener recetas diferentes para el mismo color con acabados distintos.

## Consecuencias

1. **`FamiliaColor` ya no es eliminable.** No se puede deprecar ni eliminar la tabla `familia_color` ni el campo `familia_color_id` de `ProductoTerminado`.
2. **Documentación actualizada.** Se actualizaron las referencias en US-001, US-001b y TS-001 para reflejar este doble rol (no-SKU + sí-receta).
3. **Modelo `ColorProducto` necesita asegurar FK a `FamiliaColor`.** Ya existe en el modelo actual (`familia_id` → `familia_color.id`).

## Documentos Afectados

- [US-001](obsidian_vault/05_Especificaciones/02_User_Stories/US-001_Creacion_Agil_Molde_Producto_Pieza.md): Punto 2 de problemas, US-001b, tabla de lagunas fila 3.
- [TS-001](obsidian_vault/05_Especificaciones/03_Tech_Specs/TS-001_Creacion_Agil_Molde_Producto_Pieza.md): Sección 4.4 y Plan de Fases (Fase 5).
- [US-006](obsidian_vault/05_Especificaciones/02_User_Stories/US-006_Normalizar_Composicion_Color_Familia.md): Define el nuevo rol funcional.
