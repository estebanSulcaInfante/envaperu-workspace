---
tipo: recibo-ejecucion
estado: implementado-local-pendiente-uat-humana
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
fecha: 2026-09-02
---

# Recibo M4 — Recuperación de creación accidental de OT

## Alcance y autorización

[[DEV-010M4_Anulacion_OT_Vacia]] / [[TS-010M4_Anulacion_OT_Vacia]]. Usuario
aprobó explícitamente alcance, permisos y excepción UX solo local.
Workspace envaperu-workspace-2, sin commit ni deploy remoto, cambios previos
preservados. Entrada Approved for Dev equivalente; salida QA focal y revisión
local, no aceptación humana ni CI global verde.

## Cambios

| Componente | Entrega |
|---|---|
| scm_ot_service.py / rutas_scm.py | POST anular, bloqueo versión/fila/estado y FK operativas; evento auditado, lectura de evidencia |
| scm_configuration.py | OT_ANULAR para Supervisor, JP y GG; no otros roles |
| scripts/uat_enable_ot_annulment.py | Grant acotado a base exacta local, sin reseed de documentos |
| scmOtApi.js | Anulación y clave estable de creación/reintento |
| OtHeaderSafety.jsx / OtMangasScm.jsx | Revisar creación; motivo/confirmación anular; bloqueo/contexto/recuperación; no agregar trabajo a terminal |
| Tests backend/frontend | API, roles, historial, replay, versión, FK, PostgreSQL race y componentes |
| qa/ot-header-safety.* | Fixture visual ficticia de componentes, no forma parte del bundle de producción |
| Vault | Draft/story/contexto, TS/DEV, ADR, dominio, matriz de roles, UAT ADM/CON y recibos |

## BASELINE → RED → GREEN → REFACTOR

| Verificación | Resultado / interpretación |
|---|---|
| scripts/test.ps1 -Component backend | 503 passed, 1 failed preexistente test_scm_portfolio_demo…rebuilds_a_cross_module_scenario; no suite global verde |
| scripts/test.ps1 -Component frontend | Interrumpida tras errores previos de ProductOnboardingTechnicalSteps; además el runner alcanzó la prueba de revisión nueva durante RED. No baseline global inmutable ni pase completo |
| Baseline focal test_scm_ot_service.py | 39 passed, 34 warnings previos |
| Baseline focal OtMangasScm + scmOtApi | 28 passed antes de implementación |
| RED API nueva | 404 en POST /ots/{id}/anular, fallo esperado |
| RED UI creación | Primer clic enviaba la creación antes de revisión, fallo esperado |
| GREEN servicio OT + M4 inicial | 49 passed, 44 warnings; cubre anulación, rollback, autorización, motivo, identidad, replay, estados y registro horario |
| Regresión permisos/catálogo/observabilidad | 25 passed, 25 warnings |
| PostgreSQL test_scm_empty_ot_postgres.py | 1 passed: carrera anular/iniciar, un ganador y un 409; schema efímero en envaperu_test, nunca UAT |
| GREEN frontend cinco archivos focales | 56 passed; incluye seguridad, integración OT, tablero, jornadas y adaptador API |
| REFACTOR | Componentes separados; guard para doble clic durante cierre de diálogo; estados inciertos sin falso éxito; extracción import ruta |
| Build frontend | 1312 módulos; éxito, advertencia de chunk grande preexistente |
| Verificación final ampliada M4 | 11 passed, incluyendo trabajo PLANIFICADO y ANULADO; build final BGmlc3zf exitoso y prueba integrada de creación 1 passed |
| git diff --check | Sin errores de espacios; advertencias LF/CRLF del workspace |

Un ensayo intermedio detectó doble clic tras cerrar el diálogo (review nulo);
se corrigió y se repitieron las pruebas. Otro test esperaba agregar trabajo a
una OT cerrada: se actualizó al bloqueo terminal incorporado, preservando la
consulta histórica. No se ocultaron fallos de la regresión general.

## Aplicación local y preservación

- Aplicado solo OT_ANULAR a los tres roles aprobados mediante helper con guard
  host loopback y base enva_uat_recorrido. Sin columnas/migraciones nuevas.
- Stop/Start del lanzador, NO Reset ni Update/reseed general. Base y scenario
  conservados. API 5100, UI 5174 y estación 5051 volvieron LISTO.
- OT-000001 / 3cb13d93-36eb-4293-8bf5-ca3d7047ec26 continúa PLANIFICADA,
  cero trabajos. OF-000001 sigue disponible. Diálogo real abierto y cerrado
  con Volver, sin confirmar; no se anuló documento de la UAT.
- GET final de la API: OT-000001, versión 1, PLANIFICADA, 0 trabajos,
  anulacion null; evidencia independiente del estado del navegador.
- Sin impresiones, balanza, inventario, OP/OF ni pesajes modificados.

## Evidencia visual

Browser, viewport real técnico 1163×654. Carpeta outputs/uat-m4-2026-09-02:

1. 01-estados.png: bloqueada y anulada simuladas, página completa.
2. 02-revision-creacion.png: resumen y Volver como foco inicial.
3. 03-creacion-incierta.png: ausencia de acuse simulada.
4. 04-anular-motivo-vacio.png: foco motivo y confirmación deshabilitada.
5. 05-anular-listo.png: motivo y acción habilitada, sin envío.
6. 06-ot-original-intacta.png: integración en OT válida de usuario.
7. 07-dialogo-integrado-sin-confirmar.png: diálogo real, salido con Volver.

Los diálogos caben en el viewport revisado. Capturas ficticias de estado
ANULADA no constituyen evidencia de un documento real anulado; las garantías
de persistencia las comprueban tests API y PostgreSQL.

## Omitido, riesgos y siguiente gate

- Falta UAT humana funcional/operativa ADM/CON, preparada en
  [[UAT_US-010M4_OT_Vacia]]. No se atribuye UX-READY a la revisión del agente.
- Viewport 1440×900, lector de pantalla y observación de puesto real pendientes;
  solo se verificó visualmente el viewport disponible y foco/teclado básico.
- Carrera real anular/agregar trabajo no ejecutada separadamente en esta
  pasada; ambos comandos bloquean la misma OT y validan estado. Se ensayó
  carrera real anular/iniciar y rechazo API de nuevos trabajos en ANULADA.
- No se hizo prueba de todas las FK con fixtures individuales; consulta
  defensiva recorre todas las FK entrantes, se probó trabajo y registro horario.
- Contrato estación/sync no cambiado; no se repitieron sus suites en M4.
- Aplicación de capability a otros entornos exige autorización/grants explícitos.
- Rollback: retirar acceso antes de revertir código; conservar OT/eventos.
  No borrar historial ni resetear el entorno como recuperación.
- Siguiente acción: UAT guiada sobre una OT desechable elegida por el usuario,
  distinta de OT-000001. La UAT de pesaje puede retomarse desde la OT intacta.

Las buenas prácticas de PostgreSQL guiaron transacción corta y bloqueo de fila;
no hubo conexión ni modificación de Supabase/Render.
