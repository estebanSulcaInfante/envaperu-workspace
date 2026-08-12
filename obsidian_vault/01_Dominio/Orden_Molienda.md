---
tipo: modelo_dominio
estado: propuesto
tags: [scm, molienda, transformacion, orden, balance-masa]
relaciones:
  - "[[Regla_Compatibilidad_Reproceso]]"
  - "[[Lote_Material_Recuperado]]"
  - "[[Unidad_Logistica]]"
  - "[[US-010E_Molienda_y_Material_Recuperado_Trazable]]"
fecha_creacion: 2026-08-02
fecha_actualizacion: 2026-08-03
---

# Orden de Molienda

Documento de transformación que selecciona merma recuperable, evalúa su mezcla
y genera una o varias bolsas de material recuperado.

## Cabecera

- correlativo central autogenerado;
- especificación objetivo: familia de material, proceso destino y color;
- color nominal objetivo/dominante y regla de compatibilidad de color;
- estado y versión;
- molino/recurso, fecha operativa y responsables;
- kg planificados, kg reales de entrada, kg recuperados y pérdida;
- condición `NORMAL` o `MEZCLA_EXCEPCIONAL`.

## Aportes

Cada línea conserva unidad/lote de origen, artículo o material de procedencia,
familia de materia prima, proceso de origen, color, condición, kg planificados,
kg reales y regla de compatibilidad congelada.

La unidad recuperable posee un peso de almacenamiento que acredita su saldo.
Antes de entrar al molino se registra el peso de consumo. Este último gobierna
la cantidad debitada; ambos se enlazan para medir diferencias de custodia y no
se suman como entradas independientes.

El color dominante pertenece al plan de la orden. La composición real de salida
conserva kg y porcentaje de cada familia/color aportante; el sistema no cambia
silenciosamente el objetivo porque otro aporte terminó siendo mayor.

Una unidad puede aportarse parcialmente. Su saldo nunca queda negativo y el
consumo se confirma en la misma transacción que acredita la salida.

## Estados mínimos

`BORRADOR -> VALIDADA -> EN_EJECUCION -> CERRADA`

Estados terminales o laterales: `ANULADA`, `BLOQUEADA_COMPATIBILIDAD`. Después
de iniciar no se sustituyen aportes silenciosamente; cualquier cambio exige una
nueva revisión o una operación compensatoria según el momento.

## Balance

```text
kg_entrada_real = kg_salida_recuperada + kg_perdida_molienda
```

La tolerancia de cierre es configurable. Una diferencia fuera de tolerancia
requiere motivo y autorización; nunca se corrige alterando un pesaje histórico.
