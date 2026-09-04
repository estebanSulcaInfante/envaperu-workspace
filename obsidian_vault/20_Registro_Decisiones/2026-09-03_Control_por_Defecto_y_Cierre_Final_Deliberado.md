---
tipo: decision
estado: implementada-pendiente-uat
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
fecha_creacion: 2026-09-03
fecha_actualizacion: 2026-09-03
tags: [scm, pesaje, control-kg, cierre-final, seguridad-ux, f2]
relaciones:
  - "[[2026-08-31_Control_Avance_en_Kg_sin_Conteo_y_Accion_Unica_Pesaje]]"
  - "[[US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
  - "[[UAT_US-010K3_Control_Avance_Kg_y_Contexto_Visible]]"
  - "[[UAT_US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
---

# Control por defecto y cierre final deliberado

## Evidencia

Durante la UAT local de `OF000001-OT002-M001`, el usuario omitió dos veces la
casilla **Control de peso**. Como el estado apagado significaba cierre, F2 creó
dos cierres finales accidentales: NET `8.950 kg` y, después de una reapertura
auditada, NET `4.970 kg`. El backend ejecutó correctamente la intención enviada;
la interacción falló al convertir una omisión fácil en una acción de alto
impacto.

El responsable funcional autorizó el 2026-09-03 aplicar la corrección mediante
el pipeline y conservar una sola acción principal de pesaje.

## Decisión

1. Cuando Central autoriza `AVANCE_KG`, el estado inicial y el estado posterior
   a resolver otro QR son **Control de peso**.
2. F2 o el único botón `Pesar manga (F2)` registran el control en ese estado.
3. El operador debe seleccionar explícitamente
   **Cerrar manga en este pesaje** para cambiar la intención.
4. F2 con cierre seleccionado abre una confirmación; todavía no llama a Central.
5. La confirmación muestra código de manga, NET y efecto irreversible. El foco
   inicial es la cancelación segura y F2 repetido no confirma el diálogo.
6. Cancelar devuelve al modo Control y no crea pesaje, etiqueta ni operación.
7. Confirmar explícitamente ejecuta el cierre final existente con su misma
   idempotencia. El backend y sus contratos no cambian.
8. Cuando una manga no admite controles pero sí cierre, la acción permanece
   bloqueada hasta seleccionar cierre y confirmarlo; no existe final silencioso.
9. El cierre parcial solo aparece dentro de la intención de cierre.

## Sustitución

Esta decisión sustituye únicamente la sección **Una acción física de pesaje**
de [[2026-08-31_Control_Avance_en_Kg_sin_Conteo_y_Accion_Unica_Pesaje]] en lo
relativo al valor por defecto del selector. Conserva el botón único, F2,
`AVANCE_KG`, tara, monotonicidad, QR, impresión e idempotencia.

## Restricción

La autorización permite especificación, implementación y QA local. No equivale
a `ux_ready`, UAT física ni habilitación en planta. El recorrido debe repetirse
sin guía crítica antes de retirar `no_habilitar_en_planta`.

Implementación local verificada el 2026-09-03: 41 pruebas focales, 74 pruebas
del frontend de estación, build y contrato Central–Pesaje verdes. M001 fue
reabierta por segunda vez mediante auditoría y quedó disponible para repetir la
UAT con el nuevo flujo. La aceptación humana continúa pendiente.
