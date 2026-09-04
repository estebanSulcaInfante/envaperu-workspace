---
tipo: draft
estado: alcance-basico-en-definicion
spec_phase: draft
fecha: 2026-09-02
---

# Feedback al pesar y cierre exclusivamente en kg

Fuente: solicitud del responsable funcional en esta conversación, 2026-09-02.
El trabajador necesita reconocer la manga, por qué no puede pesarla y quién
resuelve el bloqueo. Se conserva un botón y un checkbox de control ordinario.

## Porción ejecutable

[[US-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]]: explicación de capacidades
existentes, acción única, referencia persistida del último control y UAT.
Implementación local expresamente solicitada; UX provisional, sin publicación.

## Flujo objetivo y dependencia funcional abierta

1. Control ordinario en kg: no cambia maquinista, OT, turno ni tramo.
2. Relevo en la misma OT: Central registra quién entrega/recibe y el momento;
   debe asociar un pesaje real de frontera, no reutilizar arbitrariamente un
   control anterior. Misma manga y QR.
3. Continuidad en otra OT compatible: vínculo explícito y auditado en Central,
   conservando origen, sucesión de trabajos y QR. No crear otra manga física.
4. Cierre físico final desde el mismo botón; cierre anticipado autorizado por
   Central. Sin conteo humano, las unidades no son un conteo confirmado.

El código vigente de relevo/continuidad requiere una frontera en unidades y
redistribuye asignaciones del plan en UN. El cierre normal aún copia el plan;
el parcial solicita unidades. NO están migrados a un flujo integral solo kg.
La dirección funcional conversada posteriormente es inventario de piezas/WIP
en kg netos, con unidades estimadas solo como referencia. El sublibro vigente
sigue en UN; falta diseñar e implementar la migración y sus efectos en reservas,
consumos y cierres. La conversación no convierte este draft en Approved for Dev.
Los kg acumulados nunca se suman entre controles; un delta entre controles no
equivale al aporte completo del trabajador si hubo varios controles por tramo.

La UAT K4 separa casos ejecutables de esos escenarios condicionados. No debe
certificarse la continuidad multijornada solo kg antes de resolver e implementar
esa dependencia.

## Alcance actualizado — 2026-09-02

El responsable pidió continuar sin el control detallado de conciliación de
consumo, merma, remanente en Armado y diferencias. Queda explícitamente
[[Conciliacion_Consumo_Armado_en_Kg_Pendiente|pendiente para otro incremento]].
Se mantiene en el flujo objetivo el repesaje de devolución y el sticker del
remanente. No atribuir automáticamente todo kg no retornado a consumo real ni
eliminar registros de custodia/retorno; no certificar balance global conciliado.
El diferimiento no cambia la implementación actual, no autoriza despliegue y
no exige completar ese control detallado para continuar con el desarrollo básico.

## Continuación del pipeline — preparación UAT 2026-09-02

Guion consolidado y acta: [[UAT_US-010K_Modulo_Pesaje_Piloto_Kg]] y
[[ACTA_UAT_Pesaje_Piloto_Kg]]. Separan ensayo del alcance K3/K4 implementado,
regresión de cierre/etiquetas actuales y casos solo kg todavía bloqueados.

Primera historia extraída: [[US-010K5_Cierre_Fisico_en_Kg_sin_Conteo]], en
refinamiento, sin TS/DEV autoaprobado. Debe resolver cierre normal vs anticipado,
igualdad con último control, presentación de estimaciones y efecto sobre el plan.
No volver a pedir decidir kg vs UN como si no se hubiera expresado la dirección.

Porciones separadas pendientes: contrato de inventario/reservas de piezas/WIP
en kg y transición de consumidores; fronteras auditadas kg de relevo/vínculo;
retorno repesado con recepción y sticker. Orden de liberación condicionado a
compatibilidad de esos contratos, no a terminar la conciliación detallada diferida.
Evidencia y límites: [[REC_2026-09-02_Preparacion_UAT_Modulo_Pesaje]].
