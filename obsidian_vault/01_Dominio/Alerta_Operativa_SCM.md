---
tipo: modelo_dominio
estado: propuesto
tags: [scm, alerta, inconsistencia, auditoria, supervision]
relaciones:
  - "[[US-010J_Alertas_Operativas_e_Inconsistencias]]"
  - "[[Unidad_Logistica]]"
  - "[[Control_Peso]]"
  - "[[Transferencia_Inventario]]"
  - "[[US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
fecha_creacion: 2026-08-02
fecha_actualizacion: 2026-08-11
---

# Alerta Operativa SCM

Proyección auditable que señala una condición inusual sin modificar ni borrar
el hecho que la originó. Una alerta no reemplaza la autorización de la acción y
no bloquea por sí sola, salvo que una política independiente lo establezca.

## Identidad

- tipo y severidad;
- objeto y eventos origen;
- regla/versión y umbral usados;
- valores observados;
- fecha de detección y última evaluación;
- estado, responsable y alcance organizacional;
- reconocimiento, resolución o descarte con actor y motivo;
- huella idempotente para no duplicar la misma condición.

## Estados

`ABIERTA -> RECONOCIDA -> RESUELTA`

`DESCARTADA` exige motivo. Si la condición reaparece después de resolverse se
crea una nueva ocurrencia enlazada, no se altera el histórico.

## Reglas configurables iniciales

- `PESAJE_TARDIO_DESDE_FECHA_OPERATIVA`;
- `PESAJE_TARDIO_DESDE_PREETIQUETA`;
- `ANULACION_PESAJE_TARDIA`;
- `DIFERENCIA_CUSTODIA_MERMA`.
- `MANGA_PESADA_SIN_RECEPCION`;
- `TRANSFERENCIA_DIFERENCIA`.

Cada regla define referencia temporal, unidad (`HORAS` o `DIAS_CALENDARIO`),
umbral, comparación inclusiva/exclusiva, severidad, destinatarios y vigencia.
Para preetiqueta-pesaje y pesaje-anulación el valor inicial validado es más de
`24 horas` transcurridas.

`DIFERENCIA_CUSTODIA_MERMA` compara el peso almacenado con el peso previo al
molino. Su umbral inicial es `1.000 kg` de diferencia absoluta, configurable.

`MANGA_PESADA_SIN_RECEPCION` se evalúa desde el pesaje final vigente mientras
la manga continúe pendiente de recepción. Su valor inicial es más de 24 horas.
`TRANSFERENCIA_DIFERENCIA` nace inmediatamente al confirmar faltante o
sobrante. Ninguna de las dos recibe, ajusta o mueve inventario.
