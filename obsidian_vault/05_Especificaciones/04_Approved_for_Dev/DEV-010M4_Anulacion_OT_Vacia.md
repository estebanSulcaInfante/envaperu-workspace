---
tipo: dev
estado: aprobado-solo-local
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
fecha: 2026-09-02
---

# DEV-010M4 — OT vacía

Autorización equivalente explícita: usuario «Si», 2026-09-02, a alcance,
permisos y excepción UX solo UAT local. No representa UX-READY.
Implementar [[TS-010M4_Anulacion_OT_Vacia]], escenarios M4-01…10 de
[[US-010M4_Creacion_Revisada_y_Anulacion_OT_Vacia]], con wireflow
[[CTX_PROTO_US-010M4_Recuperacion_OT_Vacia]].

Secuencia: BASELINE → prueba RED ruta/UI → GREEN servicio/permisos/API/UI →
REFACTOR → regresión, build, evidencia visual y UAT ADM/CON instanciada.
Cambios permitidos: servicio OT, ruta API, seed de capacidades, adaptador API
frontend, componente OT/pruebas y documentación del incremento.
Conservar cambios previos. No reset, no anular OT-000001, no producción,
no impresiones reales ni alteraciones de inventario/pesajes.
Aplicar localmente solo grant nuevo y build/reinicio necesarios sin pérdida
del recorrido actual. Reportar fallos previos y verificaciones omitidas.
