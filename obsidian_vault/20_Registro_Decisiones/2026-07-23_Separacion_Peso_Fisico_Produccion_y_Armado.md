---
tipo: decision-dominio
estado: propuesta
tags: [scm, produccion, pesaje, armado, metricas, trazabilidad]
fecha_decision: 2026-07-23
relaciones:
  - "[[2026-07-24_Prearmado_Parcial_como_WIP_y_Empaque_Normalizado]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[Registro_Diario]]"
  - "[[Unidad_Logistica]]"
  - "[[Orden_Armado]]"
  - "[[Saldo_WIP_Salida]]"
---

# Separación entre peso físico, producción de máquina y armado

> [!IMPORTANT] Decisión posterior
> [[2026-07-24_Prearmado_Parcial_como_WIP_y_Empaque_Normalizado]] conserva la separación de pesos y genealogía, pero sustituye el supuesto de que todo balde + asa genera producto terminado: cuando faltan operaciones, la salida es `LoteWIP`.

## Contexto

Durante ciclos lentos, EnvaPerú puede prearmar el producto junto a la máquina. Ejemplo: la OT actual inyecta cuerpos de balde, trabajadores incorporan asas ya fabricadas —incluso de otro molde u otra OT— y pesan baldes con asas dentro de la misma bolsa.

El piloto suma el peso de la bolsa a `total_kg_real` de la OT. Atribuir el neto completo a la máquina infla su producción. Descontar un porcentaje para representar el asa oculta inventario consumido, origen y armado realizado.

## Decisión propuesta

1. Separar tres hechos: producción de inyección, ejecución de armado y embalaje físico.
2. La OT acredita ciclos, unidades buenas y kg estándar de sus propios `LoteSalidaPiezaColor`.
3. US-010F congela BOM, consume cuerpos actuales y componentes previos, y crea `LoteProductoTerminado`.
4. US-010D conserva bruto, tara y neto de la bolsa completa.
5. La contribución de cada componente se deriva de cantidad y peso unitario congelado; no se presenta como medición individual.
6. Una bolsa de producto armado referencia el lote de producto. Su genealogía N:M conduce a piezas de cualquier molde, OP u OT.
7. Un origen no conocido se declara `CONJUNTO_CANDIDATOS` o `LEGACY_SIN_ORIGEN`; nunca se inventa.
8. El dashboard presenta por separado avance de máquina, unidades armadas, componentes previos, kg físicos y residual.
9. Las piezas buenas sueltas se mantienen en `SaldoWIPSalida`: embalaje directo o armado en línea las debita una sola vez.
10. El avance manual durante el llenado es provisional y visible en tiempo real, pero no mueve inventario.
11. F2 envía un único `CONFIRMAR_BOLSA_ENSAMBLADA`; central confirma peso/cantidad, consume componentes, acredita producto y materializa la unidad en una transacción idempotente.
12. Una OT no cierra con bolsas directas ni créditos de cuerpos en línea pendientes. Una vez acreditados y conciliados, la Orden de Armado se gobierna por separado y puede continuar después de cerrar su OT de contexto.
13. Offline requiere una `ReservaWIPSalida` central previa con modo, cantidad, estación y vigencia. Una captura local queda pendiente/aislada hasta el acuse.
14. Candidatos y legacy consumen un pool o apertura contada; degradar genealogía nunca autoriza saldo negativo.
15. El avance provisional se liquida por bolsa/corte y no se suma nuevamente al confirmado.
16. El inbox deduplica el comando padre; movimientos y consumos hijos reciben IDs determinísticos.

## Consecuencias

- `total_kg_real = SUM(ControlPeso)` permanece únicamente como legado.
- La cantidad dentro de una bolsa armada pasa a ser obligatoria.
- La bolsa directa y la bolsa de producto armado usan tipos de contenido distintos.
- D-core entrega primero el pesaje de bolsa simple; F-inline y el adaptador D/F reutilizan esas primitivas para cubrir la bolsa armada sin dependencia circular.
- La corrección y el replay deben compensar o deduplicar pesaje, producción, consumo y armado como una unidad lógica.
- Cantidad planificada, avance provisional y cantidad confirmada se conservan como valores distintos.
- Una salida simple sin conteo manual usa cantidad WIP asignada; nunca infiere unidades desde kg.

## Alternativas descartadas

### Atribuir todo el neto a la OT actual

Descartada porque convierte inventario anterior en producción de la máquina.

### Restar un porcentaje de asa

Descartada como contrato SCM porque solo ajusta una cifra y pierde cantidad, lote, responsable y genealogía.

### Exigir que todos los componentes procedan del mismo molde u OT

Descartada porque la BOM de ProductoTerminado combina `PiezaColor` y la operación real reutiliza componentes fabricados previamente.
