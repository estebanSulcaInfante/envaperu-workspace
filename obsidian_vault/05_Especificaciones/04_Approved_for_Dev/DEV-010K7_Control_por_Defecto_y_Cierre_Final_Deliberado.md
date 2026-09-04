---
tipo: approved-for-dev
estado: implementado-en-review
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
historia: "[[US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
tech_spec: "[[TS-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
fecha_aprobacion: 2026-09-03
fecha_actualizacion: 2026-09-03
tags: [dev, scm, pesaje, cierre-seguro, f2]
---

# DEV-010K7: control por defecto y cierre final deliberado

## Autoridad y porción vertical

El responsable funcional aprobó explícitamente aplicar el ajuste mediante el
pipeline el 2026-09-03. Se autoriza cambiar la interacción local de Pesaje,
pruebas, documentación y UAT. No se autoriza despliegue productivo ni aprobar
UX/UAT física por inferencia.

## BASELINE → RED → GREEN → REFACTOR

1. BASELINE focal: 36 pruebas verdes antes del cambio.
2. RED K7-01: F2 sin tocar selector debe llamar control, no final.
3. GREEN: estado `closeManga=false`, copy y ruta segura.
4. RED K7-02..05: cierre abre diálogo, cancelar/F2 repetido no mutan y confirmar
   llama final una sola vez.
5. GREEN/REFACTOR: diálogo accesible, foco seguro, Escape, parcial subordinado.
6. RED/GREEN K7-06: solo final disponible exige selección explícita.
7. Regresión, build, QA visual, UAT instanciada y recibo.

## Guardas y salida

- Conservar un solo botón principal y Enter solo lectura.
- No cambiar API/backend, tara, monotonicidad, conteo ni etiquetas.
- No perder reintento idempotente tras respuesta incierta.
- No confirmar diálogo mediante F2 repetido.
- No sobrescribir cambios ajenos del worktree.
- `functional_validation: qa_green` solo después de pruebas y evidencia.
- `ux_validation` permanece provisional hasta la repetición humana sin ayuda;
  `physical_uat` permanece pendiente y no se habilita planta.

## Salida de implementación 2026-09-03

- BASELINE: 36 pruebas focales verdes.
- RED K7-01: el estado previo mostraba cierre/listo y no llamaba al control.
- GREEN K7-01: F2 usa `AVANCE_KG` por defecto.
- RED/GREEN K7-02..06: diálogo sin mutación, Escape/cancelación, tecla repetida
  y contexto solo-final protegidos.
- REFACTOR: una fuente de estado para botón/F2 y presentación textual además de
  color; cierre parcial subordinado.
- Regresión: 41 focales, 74 frontend estación, build y 3 contratos verdes.
- Evidencia/UAT: [[UAT_US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]
  y [[REC_2026-09-03_Control_por_Defecto_y_Cierre_Deliberado]].

No se eleva `ux_validation` ni `physical_uat`; el siguiente gate es humano.
