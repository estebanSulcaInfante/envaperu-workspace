---
tipo: modelo_objetivo
estado: en-refinamiento
tags: [dominio, scm, produccion, wip, salida, armado, US-010C, US-010F, US-010R]
relaciones:
  - "[[Lote_Color]]"
  - "[[Registro_Diario]]"
  - "[[Unidad_Logistica]]"
  - "[[Orden_Armado]]"
  - "[[Orden_Operacion]]"
  - "[[Lote_WIP]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
fecha_creacion: 2026-07-23
fecha_actualizacion: 2026-07-24
---

# Saldo WIP de Salida

Proyección por `LoteSalidaPiezaColor` que explica cuántas piezas buenas ya confirmadas permanecen sueltas junto a la máquina y cuál fue su destino. Permite consumir cuerpos directamente en una [[Orden_Operacion]] sin inventar una bolsa o [[Unidad_Logistica]] intermedia.

No es un [[Lote_WIP]]: este saldo todavía representa la misma `PiezaColor`. El lote WIP nace únicamente después de una transformación confirmada que consume componentes.

No es un segundo lote ni un saldo editable. Se reconstruye desde movimientos idempotentes y complementa al total producido del lote:

```text
saldo_wip_unidades = SUM(MovimientoWIPSalida.delta_unidades)

disponible_para_asignar =
    saldo_wip_unidades
  - SUM(ReservaWIPSalida.cantidad_asignada con modo SALDO_EXISTENTE y estado ACTIVA o VENCIDA_EN_CONCILIACION)
```

Los kg atribuibles a la OT se derivan de las unidades buenas y del peso unitario congelado. El pesaje posterior de una bolsa —simple o armada— no vuelve a acreditar producción de máquina.

## MovimientoWIPSalida

| Campo | Regla |
|---|---|
| `lote_salida_pieza_color_id` | Salida exacta cuya cantidad se afecta. |
| `tipo` | Crédito/débito controlado: `SALIDA_BUENA_CONFIRMADA`, `EMBALAJE_DIRECTO`, `CONSUMO_EN_LINEA_ARMADO`, `BAJA`, `REVERSA_SALIDA_BUENA`, `REINGRESO_EMBALAJE` o `REINGRESO_ENSAMBLE`. |
| `delta_unidades` | Entero firmado: positivo para crédito/reingreso y negativo para débito/baja. La combinación tipo-signo se valida. |
| `destino_id` | Bolsa directa, [[Orden_Operacion]] o evento compensado, según corresponda. |
| `operation_id` | Identidad global del comando padre recibido por el inbox. |
| `effect_key` | Clave estable del efecto hijo; `(operation_id, effect_key)` es única y deriva su `effect_id`. |
| `movimiento_compensado_id` | Obligatorio para una reversa/reingreso; conserva el hecho original. |
| `event_time`, `record_time` | Tiempo efectivo y tiempo de registro. |
| `actor_id`, `ubicacion_id` | Quién confirmó y dónde ocurrió. |

## ReservaWIPSalida

Asignación central previa que impide entregar las mismas unidades a dos mangas.

| Campo | Regla |
|---|---|
| `id`, `version` | Identidad global y versión usada por control de concurrencia. |
| `lote_salida_pieza_color_id` | Salida exacta. |
| `destino_tipo`, `destino_id` | Bolsa simple o bolsa/Orden de Operación. |
| `modo_origen` | `SALDO_EXISTENTE` o `CREDITO_EN_LINEA_PENDIENTE`; son mutuamente excluyentes. |
| `cantidad_asignada` | Unidades autoritativas/máximas aprobadas para el destino; nunca se deriva de kg. |
| `estado` | `ACTIVA`, `APLICADA`, `ANULADA` o `VENCIDA_EN_CONCILIACION`. |
| `valid_from`, `valid_until` | Ventana autorizada de captura; `valid_until` puede ser nulo en el primer corte. |
| `station_id` | Estación autorizada para el pesaje. |
| `operation_id_creacion` | Comando idempotente que la creó. |

`SALDO_EXISTENTE` exige disponibilidad al reservar y reduce `disponible_para_asignar`, aunque todavía no debita el saldo físico. `CREDITO_EN_LINEA_PENDIENTE` autoriza que el cierre compuesto acredite y consuma cuerpos en una sola transacción; no reserva saldo existente, pero bloquea el cierre de la OT.

Al aplicar, `cantidad_contenida` no puede exceder `cantidad_asignada`. Si es menor, el comando debita/acredita solo lo confirmado y libera la diferencia como efecto hijo en la misma transacción. Un exceso pasa a conflicto/conciliación y no mueve parcialmente el saldo.

La reserva se crea en central antes de habilitar la manga. La estación no elige ni modifica `CREDITO_EN_LINEA_PENDIENTE`.

### Vigencia

- Una reserva vencida bloquea el inicio del pesaje.
- Vencer no libera ni reutiliza la cantidad automáticamente: pasa a `VENCIDA_EN_CONCILIACION` hasta renovarla o anularla con autorización.

## Reglas

- Los ciclos y cavidades generan una expectativa; solo `SALIDA_BUENA_CONFIRMADA` acredita unidades al WIP. El evento puede registrarse antes del destino o formar parte del comando compuesto de armado.
- `EMBALAJE_DIRECTO` transfiere unidades a una bolsa del mismo `LoteSalidaPiezaColor` y aplica su reserva.
- `CONSUMO_EN_LINEA_ARMADO` —nombre de compatibilidad— alimenta una [[Orden_Operacion]] sin exigir embolsado previo; la operación puede producir [[Lote_WIP]] o producto final.
- Cuando el conteo bueno se conoce recién al cerrar la bolsa armada, `CONFIRMAR_BOLSA_ENSAMBLADA` acredita y debita esas mismas unidades dentro de una transacción; el saldo neto puede permanecer en cero sin omitir el hecho producido.
- Una misma unidad no puede tener ambos destinos.
- El saldo nunca puede ser negativo.
- El flujo normal no solicita conteo en balanza: usa `cantidad_asignada` como confirmación implícita y nunca divide kg.
- Un replay exacto devuelve el mismo resultado; reutilizar `operation_id` con otro payload genera conflicto. Cada efecto hijo usa una clave determinística.
- Una corrección agrega una reversa/reingreso tipado y enlazado; no existe un genérico `BAJA_O_CORRECCION` que siempre reste ni se modifican movimientos confirmados.
- Cerrar la OT no elimina el WIP conciliado que legítimamente continuará hacia armado, pero sí exige que toda unidad buena tenga destino o saldo explícito.
- Una bolsa de armado marcada `CREDITO_EN_LINEA_PENDIENTE` bloquea el cierre de su OT hasta sincronizar o anularse; después de acreditar los buenos, el armado puede continuar con la OT cerrada.
