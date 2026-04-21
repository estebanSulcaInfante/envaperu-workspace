---
tipo: flujo
estado: placeholder
tags: [flujo, proceso, orden, creacion]
fecha_creacion: 2026-04-21
---

# Flujo: Creación de Orden de Producción

## Pasos del Proceso

```mermaid
sequenceDiagram
    actor U as Usuario
    participant F as Frontend
    participant B as Backend
    participant BD as Base de Datos

    U->>F: Llenar formulario OP
    F->>B: POST /api/ordenes
    B->>BD: Crear OrdenProduccion
    B->>BD: Crear snapshot_composicion_molde (congelar molde)
    B->>BD: Crear LoteColor[] con meta_kg
    B->>B: actualizar_metricas()
    B->>BD: Persistir campos calculo_*
    B-->>F: OP creada con métricas
    F-->>U: Mostrar resumen de OP
```

## Inputs Requeridos
1. **Producto (SKU)** — selección de catálogo
2. **Molde** — selección → congela en [[Snapshot_Composicion_Molde]]
3. **Máquina** — selección
4. **Fecha inicio** — fecha planificada
5. **Parámetros técnicos** — T. ciclo, horas turno, peso colada
6. **Lotes de color** — cada uno con `meta_kg`

## Reglas de Negocio
- El molde se congela al momento de crear → cambios posteriores al molde no afectan OPs existentes
- `actualizar_metricas()` se ejecuta en cascada
- La OP nace con `activa = true`
