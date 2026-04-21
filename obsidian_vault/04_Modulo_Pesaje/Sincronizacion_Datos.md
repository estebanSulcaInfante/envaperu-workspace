---
tipo: modulo
estado: placeholder
tags: [pesaje, sincronizacion, datos, control-peso]
fecha_creacion: 2026-04-21
---

# Sincronización de Datos — Pesaje

Documenta cómo se cruzan los datos del módulo de pesaje con el resto del sistema.

## Flujo de Datos

```mermaid
graph TD
    A[Balanza Física] -->|lectura| B[Módulo Pesaje]
    B -->|registro| C[Control_Peso]
    C -->|SUM peso_real_kg| D[Registro_Diario.total_kg_real]
    D -->|comparación| E[Validación Cruzada]
    E -->|ABS diff < 5Kg| F[✅ Coincide]
    E -->|ABS diff >= 5Kg| G[⚠️ Discrepancia]
```

## Regla de Prioridad
`total_kg_real` del [[Registro_Diario]] se calcula así:
1. **Prioridad 1:** `SUM(ControlPeso.peso_real_kg)` — pesajes físicos reales
2. **Prioridad 2 (fallback):** `total_coladas × (peso_neto_gr + peso_colada_gr) / 1000`

> **TODO:** Definir comportamiento offline y sincronización batch.
