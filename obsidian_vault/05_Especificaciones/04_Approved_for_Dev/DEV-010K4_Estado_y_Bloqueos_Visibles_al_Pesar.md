---
tipo: approved-for-dev
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha: 2026-09-02
---

# DEV-010K4 — Estado y bloqueos visibles al pesar

Autoridad: solicitud explícita de implementación local del responsable
funcional. No autoriza despliegue, UAT aprobada ni política de inventario.
[[TS-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]].

- [x] BASELINE: UI 11; estación backend 34; Central OT 38.
- [x] RED: 13 fallos esperados Central y 4 UI por funcionalidad ausente.
- [x] GREEN: diagnóstico aditivo, checkbox y estado junto a acción única.
- [x] REFACTOR: mensaje/habilitación centralizados, protección ante F2 repetido.
- [x] Regresión proporcional, build y evidencia visual; suite global no verde.
- [x] UAT preparada y recibo con omisiones/riesgos.

Dependencias fuera de alcance registradas en
[[Feedback_Pesaje_y_Cierre_Kg_sin_Conteo]]. No modificar cambios ajenos.

Resultado: [[REC_2026-09-02_Feedback_Estado_Manga_y_UAT_K4]]. UAT preparada,
no ejecutada físicamente. La suite global detectó fallo en preparación de
inventario de demo; no se declara `ci_green` ni se despliega.
