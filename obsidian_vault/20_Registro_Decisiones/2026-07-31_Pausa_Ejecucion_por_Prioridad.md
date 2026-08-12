---
tipo: decision
estado: aceptada-para-especificacion
fecha: 2026-07-31
tags: [scm, produccion, prioridad, ot, of, oa, kardex, trazabilidad]
relaciones:
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Armado]]"
  - "[[Registro_Diario]]"
  - "[[Unidad_Logistica]]"
---

# Pausa de ejecución por cambio de prioridad

## Contexto

Durante la operación, Producción puede detener temporalmente una fabricación o
un armado para atender otra orden prioritaria. Esto no cancela la demanda ni
borra lo ejecutado; solo suspende la ejecución pendiente y debe permitir
reanudarla conservando sus saldos, reservas y trazabilidad.

## Decisión

El estado operativo se denomina `PAUSADA`. No se usará `CONGELADA`, porque ese
concepto queda reservado para indicar que una configuración ya no es editable.

La pausa se aplica primero a la `OT`, que es la unidad diaria de ejecución:

```text
PLANIFICADA -> EMITIDA -> EN_CURSO -> PAUSADA -> EN_CURSO
                                      -> FINALIZADA -> CERRADA
```

También puede pausarse una OT antes de iniciar cuando ya fue emitida. Una OT
`CERRADA` no se reabre por este mecanismo. La pausa exige motivo, actor,
fecha/hora y, cuando corresponda, referencia a la orden que tomó prioridad.

## Alcance en OF y OA

Una `OF` u `OA` no se pausa automáticamente por una sola OT detenida. Su estado
agregado se muestra como `PAUSADA` únicamente cuando todas sus corridas/OT
ejecutables pendientes están pausadas. Si otra corrida o OT continúa, la OF/OA
permanece `EN_EJECUCION`.

La pausa no modifica la configuración liberada de la OF/OA ni sus metas
históricas. Al reanudar, se continúa con el saldo pendiente y no se vuelven a
crear mangas ni se repiten consumos ya confirmados.

La OP no se pausa por una detención de planta. Permanece `APROBADA` o
`PLANIFICADA`. Solo una decisión de negocio que postergue toda la demanda podría
usar posteriormente un estado distinto, como `SUSPENDIDA`.

## Efectos sobre inventario y mangas

Pausar no revierte:

- producción buena ya confirmada;
- consumos de componentes;
- mangas pesadas o cerradas;
- reservas ya comprometidas;
- resultados WIP o ProductoTerminado acreditados.

Mientras la OT está pausada:

1. no se inicia una nueva ejecución de su alcance sin autorización;
2. una manga abierta con contenido debe terminarse, cerrarse y luego pesarse;
   si no puede cerrarse, se reconcilia su contenido y se anula antes de dejar
   la estación;
3. una manga ya preetiquetada conserva su identidad y no se reutiliza;
4. las reservas permanecen retenidas por defecto;
5. liberar una reserva requiere una acción explícita de descompromiso, actor,
   motivo y nueva evaluación de cobertura.

El sistema nunca reasigna automáticamente una reserva pausada a la orden
prioritaria. Si se libera, la nueva orden debe reservarla mediante su propio
plan y asignación.

## Diferencias semánticas

| Estado | Significado |
|---|---|
| `PAUSADA` | Detención temporal por decisión operativa; se espera reanudar. |
| `BLOQUEADA` | No puede continuar por material, calidad o problema técnico. |
| `ANULADA` | No continuará; conserva la historia y exige motivo. |
| `CERRADA` | Ejecución terminada y saldos pendientes resueltos. |

## Permisos mínimos

- `OT_PAUSAR_PRIORIDAD`
- `OT_REANUDAR`
- `OT_DESCOMPROMETER_RESERVA`

La política debe asignar estas capacidades al supervisor o Jefe de Producción.
La estación de pesaje y el maquinista no pueden pausar ni reanudar una OT desde
el flujo reducido de escaneo.

## Auditoría y reanudación

Cada pausa conserva:

- OT, corrida y OF/OA afectadas;
- motivo y comentario;
- actor y momento;
- prioridad sustituta, si existe;
- reservas conservadas o liberadas;
- estado anterior;
- actor y momento de reanudación.

La reanudación devuelve la OT a `EN_CURSO` si ya había iniciado o a `EMITIDA` si
estaba emitida pero aún no comenzaba. El avance se calcula desde los hechos
confirmados y el saldo pendiente, no desde una nueva meta.

## Criterios de aceptación

### PAU-01 — Pausa de una OT sin afectar otra

**Dado** una OF con dos OT y una prioridad nueva  
**Cuando** se pausa solo la OT actual  
**Entonces** la otra OT continúa disponible  
**Y** la OF no se muestra pausada mientras exista ejecución activa.

### PAU-02 — No doble conteo al reanudar

**Dado** una OT con mangas y consumos confirmados antes de pausarla  
**Cuando** se reanuda  
**Entonces** conserva el saldo pendiente  
**Y** no crea mangas ni consumos duplicados.

### PAU-03 — Reserva retenida

**Dado** una OT pausada con material reservado  
**Cuando** otra OP solicita el mismo material  
**Entonces** la cobertura no puede usarlo como saldo libre  
**Y** solo una acción autorizada puede liberar la reserva.

### PAU-04 — Manga abierta

**Dado** una manga preetiquetada de una OT que se pausa  
**Cuando** el operador abandona la estación  
**Entonces** la manga debe cerrarse y después pesarse, o reconciliarse y anularse  
**Y** no puede reutilizarse para otra OT.

### PAU-05 — Reanudación auditada

**Dado** una OT pausada por cambio de prioridad  
**Cuando** un actor autorizado la reanuda  
**Entonces** vuelve al estado operativo anterior correspondiente  
**Y** se conserva el motivo, actor y duración de la pausa.

## Pendientes de implementación

- armonizar los estados detallados de OT de US-010P con el flujo operativo de
  US-010C;
- agregar la pausa agregada derivada para OF/OA;
- definir la política final de retención de reservas de materia prima y WIP;
- incorporar acciones y filtros de pausa/reanudación en las vistas de planta;
- ejecutar una UAT de cambio de prioridad con dos OT concurrentes.
