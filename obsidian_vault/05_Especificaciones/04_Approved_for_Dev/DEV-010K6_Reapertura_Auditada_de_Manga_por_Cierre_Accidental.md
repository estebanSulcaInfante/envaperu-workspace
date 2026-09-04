---
tipo: approved-for-dev
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha: 2026-09-03
---

# DEV-010K6 — Reapertura auditada de manga por cierre accidental

Autoridad: solicitud explícita de implementación local del responsable
funcional después del cierre accidental real de M001 en UAT.
[[TS-010K6_Reapertura_Auditada_de_Manga_por_Cierre_Accidental]].

- [x] BASELINE backend: 515 verdes; fallo preexistente
  `OPENING_LINES_REQUIRED` en portfolio demo.
- [x] RED K6-01/02/03: compensación, mismo QR y nuevo final.
- [x] RED K6-04/05: permisos, versión, recepción, alcance e idempotencia.
- [x] GREEN dominio/API/migración.
- [x] GREEN UI Central diferenciada de anulación.
- [x] REFACTOR consultas de final vigente y proyección histórica.
- [x] Regresión: frontend 511, estación 147, contratos 3 y sync verdes;
  backend 517 verdes con el único fallo preexistente de Portfolio Demo.
- [x] QA visual administrativa y UAT K6 preparada; validación humana/física pendiente.

No modificar el flujo de anulación definitiva, inferir unidades desde kg ni
habilitar cierres parciales/Armado. M001 se conserva como evidencia para la UAT
local y no se toca mediante scripts de datos ad hoc.
