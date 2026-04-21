---
tipo: adr
estado: aceptado
tags: [decision, refactoring, meta-kg, arquitectura]
fecha: 2026-04-21
---

# ADR: Eliminación de `tipo_orden` — Estrategia directa `meta_kg`

## Contexto
El sistema original usaba un campo `tipo_orden` con tres estrategias polimórficas:
- **Por Peso:** Input directo en Kg
- **Por Cantidad:** Cálculo indirecto desde unidades
- **Stock:** Basado en inventario existente

Esto generaba complejidad en la lógica de cálculo y en el frontend (formularios condicionales).

## Decisión
Se eliminó `tipo_orden` completamente. Cada [[Lote_Color]] ahora recibe un `meta_kg` directo como único input de producción.

## Cambios Realizados

| Aspecto | Antes | Después |
| :--- | :--- | :--- |
| **Estrategia de meta** | `tipo_orden`: Por Peso / Por Cantidad / Stock | Eliminado. `meta_kg` directo por lote |
| **Input de LoteColor** | Campo polimórfico según `tipo_orden` | `meta_kg` único campo de input |
| **Snapshot molde** | Campos escalares en `OrdenProduccion` | Tabla [[Snapshot_Composicion_Molde]] (soporta multi-pieza) |
| **Cálculo coladas** | Con `math.ceil` (entero) | Float exacto sin redondeo |
| **calculo_kg_real** | Aproximación por ceil | `coladas_float × peso_neto_golpe / 1000` (exacto) |
| **Merma** | Configurable / múltiples fuentes | Solo merma física de colada (runner) |
| **Campos eliminados** | `Extra (Kg)`, `TOTAL + EXTRA`, `%EXTRA` | Todos eliminados |

## Consecuencias
- ✅ Simplicidad radical en backend y frontend
- ✅ Un solo camino de cálculo (elimina bugs de estrategia)
- ✅ Soporte nativo de moldes multi-pieza
- ⚠️ Si se necesita calcular desde cantidades, se hace antes de ingresar el `meta_kg`
