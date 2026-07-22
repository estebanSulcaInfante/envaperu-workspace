---
tipo: modelo_bd
tabla: scm_material
estado: activo
tags: [dominio, maestro, SCM, material, US-010A]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# MaterialSCM

Catálogo único de materiales recibibles y consumibles. Su clase distingue `MATERIA_PRIMA` de `COLORANTE`; el rol concreto dentro de una fórmula se define en [[RecetaColorMaestra]].

| Campo | Regla |
| :--- | :--- |
| `codigo` | Prefijo correlativo autogenerado (`MP-…` o `COL-…`). |
| `nombre` | Denominación única visible. |
| `clase_material` | `MATERIA_PRIMA` o `COLORANTE`. |
| `categoria_recepcion_id` | FK a [[CategoriaRecepcionSCM]]. |
| `unidad_base` | `KG`, unidad canónica de inventario. |
| `activo`, `version` | Baja lógica y concurrencia optimista. |

## Unidades

Los colorantes se dosifican operativamente en gramos. La receta y la UI admiten gramos, mientras inventario/API normalizan a kilogramos (`1000 g = 1 kg`). La unidad base fija evita saldos incompatibles; no obliga al usuario a dosificar en kg.

Puede existir un puente 1:1 hacia catálogos legacy de materia prima o colorante durante la migración.
