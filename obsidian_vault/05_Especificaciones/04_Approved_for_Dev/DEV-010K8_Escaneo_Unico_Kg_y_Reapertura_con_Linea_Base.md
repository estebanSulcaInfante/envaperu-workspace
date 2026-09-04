---
tipo: approved-for-dev
estado: aprobado-por-responsable
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha_aprobacion: 2026-09-03
fecha_actualizacion: 2026-09-04
---

# DEV-010K8

Autorización: solicitud explícita del responsable el 2026-09-03 de implementar
la propuesta mediante el pipeline y corregir la semántica de reapertura.

Implementar únicamente [[TS-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]]
por escenarios K8-01..09 con BASELINE → RED → GREEN → REFACTOR. Mantener
compatibilidad de API para reaperturas anteriores, no introducir tolerancia en
gramos, no migrar todavía el Kardex integral a kg y no desplegar a planta.

Salida: regresiones y builds verdes, migración verificada, evidencia visual
local, UAT instanciada y recibo. Los gates UX/físico permanecen pendientes.
