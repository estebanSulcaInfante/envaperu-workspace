---
tipo: modelo_bd
tabla: molde
estado: activo
tags: [dominio, maestro, molde, TS-012]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# Molde

Maestro del herramental de inyección. Conserva los parámetros globales del tiro y obtiene su composición de [[MoldePieza]].

| Campo | Regla |
| :--- | :--- |
| `codigo`, `nombre` | Identidad del molde. |
| `peso_tiro_gr` | Peso total de referencia del tiro. |
| `tiempo_ciclo_std` | Ciclo estándar en segundos. |
| `activo`, `notas` | Disponibilidad y observaciones. |

## Derivados

El peso neto, peso de ramal, cavidades totales y porcentaje de merma se calculan desde las asociaciones activas de [[MoldePieza]]. La [[Orden_Produccion]] toma una fotografía de estos valores para no mutar históricamente.

## Relaciones

- **N:M con [[Pieza]]:** mediante [[MoldePieza]].
- **Consumidor:** [[Orden_Produccion]] y [[Snapshot_Composicion_Molde]].
