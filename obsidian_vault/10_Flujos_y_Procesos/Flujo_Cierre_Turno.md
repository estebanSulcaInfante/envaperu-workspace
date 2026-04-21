---
tipo: flujo
estado: placeholder
tags: [flujo, proceso, turno, cierre, registro]
fecha_creacion: 2026-04-21
---

# Flujo: Cierre de Turno de Producción

## Pasos del Proceso

```mermaid
sequenceDiagram
    actor M as Maquinista
    actor S as Supervisor
    participant F as Frontend
    participant B as Backend
    participant P as Módulo Pesaje

    M->>F: Registrar colada inicial/final
    M->>F: Llenar detalle hora x hora
    S->>P: Pesar bultos en balanza
    P->>B: Registrar Control_Peso[]
    M->>F: Guardar Registro Diario
    F->>B: POST /api/ordenes/<op>/registros
    B->>B: Calcular totalizadores
    B->>B: Validar peso (pesaje vs teórico)
    B-->>F: Registro guardado + validación
```

## Validación al Cierre
- `total_coladas_calculada = colada_final - colada_inicial`
- `total_kg_real` prioriza pesajes sobre cálculos
- Discrepancia > 5 Kg genera alerta de revisión
