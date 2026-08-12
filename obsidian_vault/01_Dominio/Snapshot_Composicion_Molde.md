---
tipo: modelo_bd
tabla: snapshot_composicion_molde
estado: activo
tags: [dominio, snapshot, molde, multipieza]
relaciones_padre:
  - "[[Orden_Fabricacion]]"
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-07-22
---

# Snapshot de Composición del Molde

Tabla `snapshot_composicion_molde`. Congela la configuración de piezas del molde **al momento de crear la OP**. Reemplaza los anteriores campos escalares `snapshot_cavidades` y `snapshot_peso_neto_gr` de la cabecera y referencia la `Pieza` abstracta, no una variante coloreada.

## Motivación
Un molde puede producir distintos tipos de piezas simultáneamente (molde multi-pieza). Esta estructura permite registrar cada tipo de pieza con sus propias cavidades y peso unitario.

## Campos de la Tabla

| Atributo | Tipo | Descripción |
| :--- | :--- | :--- |
| **id** | Auto (BD) | Primary Key. |
| **orden_id** | FK legacy | Referencia al código técnico migrado a [[Orden_Fabricacion]]; el contrato objetivo usa `orden_operacion_id`. |
| **pieza_id** | FK a `Pieza` (nullable transitorio) | Identidad canónica de la forma abstracta. Las OP nuevas deben informarla; la nulabilidad existe solo para importar y diagnosticar snapshots legacy aún no conciliados. |
| **pieza_codigo_snapshot** | Snapshot | Código de la pieza congelado al crear o reconciliar la OP. No cambia si después se edita el catálogo. |
| **pieza_nombre_snapshot** | Snapshot | Nombre legible de la pieza congelado para conservar la historia. |
| **pieza_sku_legacy** | Texto nullable, sin FK | Evidencia del antiguo `pieza_sku`. Solo puede provenir de importación/reconciliación; una OP nueva lo deja en `NULL`. |
| **cavidades** | Input | Número de cavidades para este tipo de pieza en el golpe. |
| **peso_unit_gr** | Input | Peso de una unidad de esta pieza (gramos). |
| **peso_subtotal_gr** | Calculado | `cavidades × peso_unit_gr` |

## Estado de migración

La migración estructural está realizada: se eliminó la relación referencial incorrecta entre el snapshot y `PiezaColor`, se añadió `pieza_id` y se preservó el valor anterior bajo el nombre explícito `pieza_sku_legacy`.

No existen todavía OP reales creadas con la estructura anterior. La revisión `d7e9a4c2f105` sí ejecutó el backfill técnico sobre `enva_test`: encontró cinco snapshots de demostración, resolvió cuatro por la cadena exacta `pieza_sku_legacy -> PiezaColor -> Pieza` y dejó uno sin `pieza_id` porque su `PiezaColor` no estaba vinculada a una `Pieza` abstracta. Esos datos locales no certifican una reconciliación de negocio ni sustituyen la prueba con una OP legacy real.

La primera OP legacy real o su restore anonimizado debe seguir el checklist de [[../05_Especificaciones/02_User_Stories/US-007_Normalizar_ProductoTerminado_PiezaColor_Salidas_OP#12.1. Pendiente condicionado: backfill de la primera OP legacy|US-007 §12.1]]. Hasta aprobar esa prueba:

- `pieza_id` continúa nullable por compatibilidad de importación;
- `pieza_sku_legacy` no participa en cálculos ni resolución de color;
- una fila legacy ambigua permanece sin conciliar y se reporta;
- las escrituras nuevas usan exclusivamente los campos canónicos.

## Ejemplo canónico

```json
{
  "pieza_id": 17,
  "pieza_codigo_snapshot": "PZ-000017",
  "pieza_nombre_snapshot": "Tapa regadera",
  "pieza_sku_legacy": null,
  "cavidades": 2,
  "peso_unit_gr": 30.0,
  "peso_subtotal_gr": 60.0
}
```

## Relaciones
- **Padre:** [[Orden_Fabricacion]] (N:1)
- **FK canónica:** `Pieza` (catálogo de formas abstractas; nullable solo durante la transición legacy)
