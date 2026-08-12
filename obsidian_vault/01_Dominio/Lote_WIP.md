---
tipo: modelo_objetivo
estado: en-refinamiento
tags: [dominio, scm, lote, wip, WIP, genealogia, US-010R]
relaciones:
  - "[[Articulo_SCM]]"
  - "[[Ruta_Produccion]]"
  - "[[Saldo_WIP_Salida]]"
  - "[[Unidad_Logistica]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Orden_Armado]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-07-24
---

# Lote WIP

Resultado confirmado de una operación intermedia. Posee identidad, cantidad y genealogía; puede colocarse en una manga y posteriormente recibirse, almacenarse y consumirse sin presentarse como [[ProductoTerminado]].

Ejemplo: `balde con asa prearmada` que todavía debe pasar por acabado o armado final.

## Diferencia frente a SaldoWIPSalida

[[Saldo_WIP_Salida]] es una proyección de piezas buenas `PiezaColor` recién producidas y todavía sueltas. No representa una transformación adicional.

`LoteWIP` nace cuando una operación consume artículos —por ejemplo cuerpo + asa— y acredita un WIP físicamente distinto:

```text
SaldoWIPSalida de cuerpos + stock de asas
    -> confirmación de prearmado
        -> LoteWIP de baldes con asa
```

## Atributos mínimos

| Campo | Regla |
|---|---|
| `id`, `codigo` | Identidad global y código legible no reutilizable. |
| `articulo_wip_id` | Artículo `SUBENSAMBLE_WIP` exacto. |
| `revision_estructura_id`, `estructura_hash` | Composición congelada. |
| `operacion_ruta_id`, `orden_operacion_id` | Operación planificada y ejecución que lo produjo. |
| `cantidad_acreditada`, `cantidad_disponible` | Unidades confirmadas y saldo derivado. |
| `estado_calidad` | Independiente del estado logístico. |
| `ubicacion_id` | Nula hasta la recepción de Almacén; después refleja ubicación inventariable. |
| `event_time`, `record_time`, `actor_id` | Evidencia temporal y actor. |

Los consumos se enlazan por confirmación/lote de resultado. La genealogía puede incluir `PiezaColor` y otros `LoteWIP` de diferentes OP, OT, fechas o ubicaciones.

## Reglas

- Planificar un lote no acredita saldo.
- Confirmar una operación consume entradas y acredita el lote en una sola transacción idempotente.
- La cantidad incorporada por componente cumple la estructura congelada; merma o rotura se consume aparte.
- El saldo nunca es negativo.
- Un lote WIP no incrementa cobertura de producto terminado.
- Calidad `PENDIENTE` no equivale a inventario disponible.
- Una [[Unidad_Logistica]] de prearmado referencia `LOTE_WIP` como contenido principal; los componentes se consultan por genealogía.
- El peso físico de la bolsa completa no se atribuye íntegramente a la OT que produjo uno de sus componentes.
- Una corrección agrega movimientos compensatorios; no sobrescribe consumos o acreditaciones confirmadas.
