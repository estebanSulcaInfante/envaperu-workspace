---
tipo: modelo_bd
tabla: molde
estado: activo
tags: [dominio, maestro, molde, TS-012]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-08-04
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

El peso neto, peso de ramal, cavidades totales y porcentaje de merma se calculan desde las asociaciones activas de [[MoldePieza]]. La [[Orden_Fabricacion]] toma una fotografía de estos valores para no mutar históricamente.

## Relaciones

- **N:M con [[Pieza]]:** mediante [[MoldePieza]].
- **Consumidor:** [[Orden_Fabricacion]] y [[Snapshot_Composicion_Molde]].

## Colores habilitados

La habilitación de un [[Color_Produccion|ColorProduccion]] se ejecuta sobre todas las asociaciones activas de [[MoldePieza]] en una sola transacción. Para cada salida se crea o reutiliza su [[PiezaColor]]. Repetir el comando es idempotente y no duplica SKU.

No se requiere una tabla `MoldeColor`: la cobertura se deriva comprobando que todas las piezas activas del molde posean la variante del color solicitado. Una cobertura parcial no representa un color disponible para el tiro.
