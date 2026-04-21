---
tipo: meta
estado: activo
tags: [convenciones, codigo, estilo]
fecha_creacion: 2026-04-21
---

# Convenciones de Código

## Naming

| Contexto | Convención | Ejemplo |
| :--- | :--- | :--- |
| Modelos / Tablas BD | `PascalCase` | `OrdenProduccion`, `LoteColor` |
| Campos BD | `snake_case` | `meta_kg`, `calculo_coladas` |
| Campos calculados | Prefijo `calculo_` | `calculo_peso_neto_golpe` |
| Campos snapshot | Prefijo `snapshot_` | `snapshot_peso_colada_gr` |
| Endpoints API | `/api/<recurso>/<id>` | `/api/ordenes/OP-1322` |

## Unidades Estándar

| Magnitud | Unidad en BD | Notas |
| :--- | :--- | :--- |
| Peso unitario de pieza | Gramos (g) | `peso_unit_gr` |
| Peso total producción | Kilogramos (kg) | `meta_kg`, `calculo_peso_produccion` |
| Tiempo de ciclo | Segundos (s) | `tiempo_ciclo_seg` |
| Horas laborales | Horas (h) | `horas_turno`, `calculo_horas` |
| Fracciones de mezcla | Decimal 0.0 - 1.0 | `fraccion` en `se_compone` |

## Reglas de Cálculo
- Los campos `calculo_*` se **persisten** en BD y se recalculan via `actualizar_metricas()`
- `calculo_coladas` es Float exacto, sin `math.ceil`. Redondeo solo en presentación.
- La merma (`calculo_merma_pct`) es **solo** merma física de colada (runner)
