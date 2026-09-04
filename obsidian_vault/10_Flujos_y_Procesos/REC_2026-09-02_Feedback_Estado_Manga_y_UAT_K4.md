---
tipo: recibo_ejecucion
fecha: 2026-09-02
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
---

# REC 2026-09-02 — Feedback de estado de manga y UAT K4

## Objetivo y alcance

- Historia/DEV: [[US-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]] /
  [[DEV-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]].
- Porción: motivos autoritativos de bloqueo, recuperación visible, estado de
  manga, un botón/F2, nombre explícito del checkbox, persistencia de referencia
  del último control y pruebas/UAT.
- Fuera de alcance: política de unidades, cambios de inventario, migración
  integral de relevo/cierre solo kg, cambios en Central administrativa,
  datos productivos, despliegue e impresión física.
- Worktree: `C:/Users/esteb/gitprojects/envaperu-workspace-2`, sucio antes de
  comenzar, subrepos también sucios. Sin commit ni reversión de cambios ajenos.
- Gate de entrada: solicitud explícita de implementación local, sobre K3.
  Excepción local de UI provisional; no autorización UX/planta inferida.
- Gate solicitado: revisión local + guion UAT preparado, no LISTO_PARA_PLANTA.

## Cambios

| Componente | Motivo | Tipo |
|---|---|---|
| Central `scm_weighing_service` | `bloqueos_pesaje` aditivo por acción; estado OT contextual. Capacidades/escrituras sin cambio. | Producto |
| UI `ScmWeighing`, `scmWeighingState`, estilos | Estado/causa/recuperación, diferencia seleccionado/abierto, control no relevo, último control persistido, feedback de espera/error/éxito, una sola habilitación. | Producto |
| Pruebas Central/estación/UI | Matriz de causas, inicio de Trabajo, passthrough, F2 doble, reintento, referencia al reescanear, fallo QR. | Prueba |
| `modulo-pesaje/frontend/qa/k4.html` y `k4.jsx` | Componente real con respuestas en memoria, solo desarrollo loopback; no build de producción. | Evidencia |
| Draft, US, prototipo, TS, DEV, contexto/dominio/decisión y UAT | Pipeline trazable y separación del flujo futuro no implementado. | Documento |

## BASELINE → RED → GREEN → REFACTOR

Baseline UI 11, backend estación focal 34, Central OT 38.
RED observado: UI 4 fallos nuevos, Central 13 fallos nuevos (faltaba diagnóstico
y no se conservaba referencia al reescanear). GREEN implementa el diagnóstico
y estado compartido; REFACTOR evita contradicción mensaje/botón, conserva
intención/clave tras error y evita doble envío antes de rerender.

## Verificaciones

| Comando / revisión | Resultado | Interpretación |
|---|---|---|
| Central: `pytest tests/scm/test_scm_weighing_feedback.py tests/scm/test_scm_ot_service.py -q` | 51 passed, 34 warnings | Incluye control ordinario, continuidad histórica, Trabajo pausado y nuevos motivos. Advertencias SQLAlchemy registradas. |
| `scripts/test.ps1 -Component pesaje` | 147 passed, 3 warnings | Backend estación completo; warnings del heartbeat durante teardown (`station_identity` ausente). No ocultados ni corregidos fuera del incremento. |
| Estación frontend: `npm.cmd test -- --run` | 67 passed, 11 archivos | 17 del componente + 17 de estado y resto de regresión. |
| Estación frontend: `npm.cmd run build` | OK, 136 módulos | Build posterior al ajuste visual; fixture QA no incluido. |
| `scripts/test-contracts.ps1` | 3 passed | Contrato legacy y copias consistentes. Diagnóstico aditivo tiene pruebas propias. |
| `scripts/test-sync-e2e.ps1` | OK, 12.5 kg y acuse local | Recorrido aislado de sincronización; no es UAT física de K4. |
| `scripts/test.ps1 -Component all` | 503 passed, 1 failed, 1 skipped, 28 deselected (backend); se detiene allí | No declarar regresión global verde. OCR omitido por dependencia; PostgreSQL/e2e excluidos por configuración. |
| Reproducción `tests/scm/test_scm_portfolio_demo.py` | 1 failed, 2 passed | `test_portfolio_seed_rebuilds_a_cross_module_scenario`: `OPENING_LINES_REQUIRED`, apertura sin líneas en seed de demo. Ruta de fallo ajena a los cambios K4. No había baseline de esta suite completa para atribuir antigüedad. |
| `scripts/test.ps1 -Component frontend` (Central administrativa, sin cambios K4) | Ejecución incompleta, interrumpida tras dos fallos y >3 min en `ProductOnboardingTechnicalSteps.spec.jsx` | Fallan reanudación PARTIAL y montaje de fases técnicas; warnings MUI/timeout. No se presenta esta suite como verde ni se modifica onboarding fuera de alcance. |
| Revisión `git diff --check` archivos de producto tocados | Sin errores de whitespace | Advertencia normal LF/CRLF; sin reset de worktree. |

## Evidencia UX

- Navegador local con componente real y datos sintéticos en memoria; sin backend
  productivo, sin impresión. Skill Browser utilizada para inspección visual y
  pruebas interactivas, no para sustituir validación humana.
- Viewport por defecto aprox. 1150×647; overrides de QA 1366×768 y 768×1024.
  El zoom existente produjo área CSS aprox. 1242×698 y 698×931. No son medidas
  del monitor de planta; override restablecido al terminar.
- Evidencia en `outputs/uat-k4/`: `cerrada.png`, `ot-sin-iniciar.png`,
  `ot-sin-iniciar-vista.png`, `control-listo.png`, `control-registrado.png`,
  `reescaneo-sin-aumento.png`, `qr-rechazado.png`, `continuidad-pendiente.png`,
  `continuidad-768.png`, `central-desconectada.png`, `cierre-registrado.png`.
- Confirmado visual/interactivamente: causa/recuperación, F2 bloqueado en cierre
  y Trabajo no iniciado, control abierto, reescaneo sin aumento, QR rechazado,
  desconexión y cierre; consola sin errores en el fixture.
- Corrección derivada de revisión visual: separar líneas del resultado de
  control para evitar texto concatenado.
- Accesibilidad básica: motivo asociado al botón con `aria-describedby`,
  anuncio de cambio de manga, errores `role=alert`, estados textuales,
  checkbox con nombre inequívoco y foco al lector.
- Hallazgo: en viewport estrecho los detalles apilan y la acción necesita
  scroll; NO se declara interfaz lista para tablet. La jerarquía bruta/NET
  preexistente requiere observación PES-01.
- Validación humana: ninguna. UAT física no realizada.

## Comprobaciones omitidas y riesgos

| Comprobación | Motivo / riesgo | Próximo responsable |
|---|---|---|
| Balanza, lector y TSC/papel reales | Modelos/postura/estabilidad y procedimiento físico aún pendientes. | Operador + supervisor |
| Nueva política kg→UN y relevo sin conteo | Falta decidir uso de estimaciones en inventario/consumos; modelo K1/K2 aún depende de unidades. | Responsable funcional |
| Aceptación ergonómica y contingencia larga | Sin trabajador ni definición de custodia; no inventar reglas. | Responsable UAT |
| PostgreSQL/concurrencia productiva | Sin cambio de esquema/capacidades; pruebas focales SQLite, no equivalen a carga/concurrencia real. | QA de integración |
| Reparar seed demo | Fuera de incremento y worktree sucio; fallo registrado, no modificado. | Responsable de demo |
| Completar regresión UI de Central | Se detuvo tras fallos de onboarding; falta investigar/repetir en incremento propio. | Responsable de onboarding/QA |

## Resultado y siguiente acción

`spec_phase: approved`, `delivery_state: review`, `functional_validation: qa_green`
solo para K4; `ux_validation: provisional`, `physical_uat: pending`,
`release_constraint: no_habilitar_en_planta`.

UAT preparada: [[UAT_US-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]]. Próximo
paso seguro: revisión humana de alcance y completar hardware/participantes
para ensayo aislado. Marcha blanca pendiente. Sin despliegue, migración ni
impresión real. Rollback: retirar únicamente los hunks/archivos K4; contrato
aditivo compatible con estaciones anteriores, sin rollback de base de datos.
