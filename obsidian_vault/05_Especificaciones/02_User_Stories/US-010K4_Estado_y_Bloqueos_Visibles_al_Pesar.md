---
tipo: user-story
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
fecha: 2026-09-02
---

# US-010K4 — Estado y bloqueos visibles al pesar

Como trabajador de Pesaje quiero conocer el estado de la manga y el motivo
concreto por el que F2 está bloqueado, con una recuperación comprensible,
para no confundir un control, un cierre o una OT aún no iniciada.

Origen: [[Feedback_Pesaje_y_Cierre_Kg_sin_Conteo]]. Dependencia implementada
local: [[US-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]].
La petición explícita autoriza este incremento local, no aceptación UX ni planta.

## Aceptación

- K4-01: manga cerrada/anulada, etiqueta no utilizable, continuidad pendiente
  y Trabajo no iniciado tienen motivo específico, estado y recuperación.
- K4-02: el bloqueo procede de las capacidades de Central; no se habilita
  por suponer que la OT o la manga están activas. Trabajo PAUSADO conserva
  su semántica vigente; no se añade una prohibición nueva.
- K4-03: un botón `Pesar manga (F2)`; checkbox `Control de peso — la manga
  continuará abierta`. Control no produce relevo ni solicita conteo.
- K4-04: mismo o menor neto que el último control permanece bloqueado,
  incluso al reescanear o cambiar el checkbox. No perder el dato persistido.
- K4-05: distinguir espera, listo, registro en curso, error y éxito. QR
  rechazado limpia el contexto anterior; F2 no opera sobre la manga anterior.
- K4-06: UAT instanciada con datos/roles/evidencias y pendientes explícitos.

No incluye cambiar el libro de inventario, estimar UN, migrar cortes históricos,
autorizar cierre parcial desde Central ni desplegar. Ver dependencia del draft.

## Contexto y validación

[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]], perfiles
PES + LEC + CON + IMP. Pantalla/periféricos/postura reales pendientes.
Prototipo: [[PROTO_US-010K4_Estado_y_Accion_Pesaje]].
TS/DEV/UAT: [[TS-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]],
[[DEV-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]],
[[UAT_US-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]].
