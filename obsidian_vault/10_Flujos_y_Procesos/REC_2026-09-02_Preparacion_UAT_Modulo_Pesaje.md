---
tipo: recibo_ejecucion
fecha: 2026-09-02
spec_phase: approved
delivery_state: review
functional_validation: untested
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
---

# REC 2026-09-02 — Preparación de UAT del módulo de Pesaje

## Objetivo y alcance

- Petición: continuar el pipeline y dejar UAT de Pesaje preparada, manteniendo
  diferida la conciliación detallada de Armado.
- Fuentes implementadas: US/TS/DEV-010K3 y K4; etiquetas v5 y QR compacto.
- Incremento: guion consolidado, acta, reverificación técnica/visual, contraste
  Vault–código y refinamiento de la siguiente historia de cierre solo kg.
- Sin cambios de producto, esquema ni reglas de planta. Sin migraciones,
  reset, datos reales, impresión física, despliegue, commits o mensajes externos.
- Worktree `C:/Users/esteb/gitprojects/envaperu-workspace-2`, rama `main`, ya
  sucio, igual que sus subrepos. Se preservaron los cambios ajenos.
- Gate de entrada: pedido de preparar aceptación y continuar pipeline sobre
  alcance local existente. Gate alcanzado: guion/acta preparados, no aceptación.
- Excepción a RED: cambio documental y preparación UAT, sin nueva implementación.
  Se ejecutó reverificación del comportamiento existente. La RED de K5 queda
  propuesta, no ejecutada ni declarada verde.

## Cambios

| Archivo / componente | Motivo | Tipo |
|---|---|---|
| [[UAT_US-010K_Modulo_Pesaje_Piloto_Kg]] | 12 casos principales, 48 criterios de perfiles, datos, arranque, negativos, gates, 7 casos futuros kg y 6 brechas. | Documento |
| [[ACTA_UAT_Pesaje_Piloto_Kg]] | Preflight, resultados por modalidad, observación y firmas sin autoaceptar. | Documento |
| [[US-010K5_Cierre_Fisico_en_Kg_sin_Conteo]] | Historia vertical de cierre simple kg; BDD, dataset y decisiones pendientes. Sin TS/DEV autoaprobado. | Documento |
| [[Feedback_Pesaje_y_Cierre_Kg_sin_Conteo]], índice de historias, UAT K4 | Enlazar siguiente porción y guion, sin sustituir evidencia anterior. | Documento |
| [[UI_Pesaje_Operario]] | Recorrido K3/K4; marcar como histórica la sección offline/conteos de julio. | Documento |
| [[Etiqueta_Manga]], [[Unidad_Logistica]] | QR compacto, v5, dos copias por identidad; aclarar fuentes y brechas del tipo/aporte. | Documento |
| [[SCM_Pesaje_Mangas_y_Etiqueta_Final]] | Endpoint de control, diagnóstico aditivo, semántica y límites actuales. | Documento |
| `docs/recorrido-uat-pesaje-piezas.md` | Advertencia de que su corte K1/conteos no es el guion de estación actual; evitar seguir resets por defecto. | Documento |
| `outputs/uat-pesaje-2026-09-02/` | Nueve capturas nuevas del componente real con respuestas ficticias. | Evidencia |

## Verificaciones ejecutadas en esta pasada

| Comando / revisión | Resultado | Interpretación |
|---|---|---|
| `scripts/test.ps1 -Component pesaje` | 147 passed, 3 warnings, 42.95 s | Backend estación completo. Warnings del worker de heartbeat al consultar `station_identity` durante teardown; no ocultados. |
| Estación frontend: `npm.cmd test` | 67 passed, 11 archivos, 4.55 s | Componente, estados, navegación/impresión y regresión. |
| Estación frontend: `npm.cmd run build` | OK, 136 módulos, 2.58 s | Bundles `index-53k6lYgE.css` y `index-DAoQZ_y-.js`. Fixture QA fuera del build. |
| Central: `pytest tests/scm/test_scm_weighing_feedback.py tests/scm/test_scm_ot_service.py -q` | 51 passed, 34 warnings, 53.20 s | Motivos, controles, cierre y continuidad histórica. Warnings SQLAlchemy de fixtures/ciclo FK. No demuestra nueva continuidad kg. |
| `scripts/test-contracts.ps1` | Proveedor 1 + consumidor 2 passed | Copias/contrato legacy-v1, no una migración de contrato de inventario. |
| `scripts/test-sync-e2e.ps1` | OK, 12.5 kg en Central y acuse local | Sincronización legacy aislada; no es un E2E del cierre SCM kg ni UAT física. |
| `scripts/uat-local.ps1 Status` | Escenario piezas; tres servicios detenidos | Read-only. No arrancó ni reseteó la base UAT. |
| Browser sobre fixture local | Cerrada/sin iniciar bloqueadas; controles 7.580 → 7.980, delta 0.400; reescaneo sin aumento; QR rechazado limpia contexto; desconexión segura | Ensayo UI real con API en memoria; no stock/permisos/hardware reales. Consola sin errores. |
| Contraste de código y Vault | Identificadas y documentadas brechas GAP-01…06 | No se cambió código para hacer coincidir evidencia con el objetivo. |
| Revisión documental | 12 casos, 48 criterios y 48 filas de acta concordantes; notas nuevas sin whitespace final; enlaces nuevos resolubles | El índice conserva el placeholder histórico `CTX-...` de su plantilla, no una referencia de esta UAT. `git diff --check` sin errores, solo advertencias LF/CRLF. |

## Evidencia visual-operativa

Se usó la habilidad Browser para recorrer la UI y guardar evidencia, no para
validar planta. Viewport CSS 1163 × 654, DPR aproximado 1.65, sin cambiar viewport.
Archivos en `outputs/uat-pesaje-2026-09-02/`:

1. `01-manga-cerrada.png`
2. `02-trabajo-sin-iniciar.png`
3. `03-control-listo.png`
4. `04-control-registrado.png`
5. `05-reescaneo-sin-aumento.png`
6. `06-segundo-control.png`
7. `07-qr-rechazado.png`
8. `08-central-desconectada.png`
9. `09-control-vista-completa.png`

Se inspeccionaron visualmente las capturas de manga cerrada y segundo control,
y se cotejaron estados/foco con la vista accesible. El segundo control usó F2;
el primero, botón. El foco volvió al QR. La captura completa permite revisar
contenido por debajo del viewport; **la acción no cabe íntegra en la altura
ensayada**, además de predominar el bruto sobre NET. No afirmar PES-01/03 PASS.
Conservar comparación con prototipos K3/K4 y ensayar en pantalla real.

Validación humana: ninguna. Balanza/lector/TSC físicos: no probados.
Tab de QA cerrado y servidor temporal 5186 detenido al terminar. No quedaron
servicios iniciados por esta pasada; la evidencia y datos existentes se conservan.

## Identidad de la revisión

Los HEAD no representan por sí solos el código probado, porque hay cambios
locales. No son release IDs ni prueba de lo desplegado:

| Repo | HEAD |
|---|---|
| Workspace | `b61aec8759faf42682d7e2e80010fcecfe389cf8` |
| Backend Central | `c6e19fa91face0e1fda2f763c959b6363a74a9b6` |
| Módulo Pesaje | `46e0a6f181acbfe3d8aaf419da267c247f0d7705` |
| Frontend Central | `0964c3df5db7a18db3dae4626186397919b92ab0` |

Huellas SHA-256 de archivos críticos del alcance revisado (no manifiesto completo
de release):

| Archivo | SHA-256 |
|---|---|
| `backend/app/services/scm_weighing_service.py` | `DE8C2DF349DEFDFE851DFD5943C2DDA9137C42DAF3A1FBD8456515CB47AB8114` |
| `backend/app/services/scm_ot_service.py` | `FB432811BADE971C2452B8074138C37C9080FDA79CACA52A97C944BAB9B48778` |
| `modulo-pesaje/frontend/src/components/ScmWeighing.jsx` | `FBF0A9CCCEB61EFBED0423816BA9A57168A6398A2B103942AF46AFD80250768D` |
| `modulo-pesaje/frontend/src/utils/scmWeighingState.js` | `352F9184A1790839EE35E3F5A7F743544E1D3E3BF46E9421F166334CBD0E6704` |
| `modulo-pesaje/backend/app/services/scm_prelabel_service.py` | `E4DC099E97F8B1377AC2968451230047ACC8A52732FA21D55298B8099F06FF31` |
| `modulo-pesaje/frontend/qa/k4.jsx` | `29E5D3649A0245D025DB80E20FBC72489A94B086FB8639174392080FC6B34A56` |

## Omisiones y riesgo restante

| Comprobación | Motivo / riesgo | Siguiente responsable |
|---|---|---|
| Repetir `test.ps1 -Component all` | Sin cambios de producto en esta pasada. Última ejecución K4: backend 503 passed/1 failed; seed demo `OPENING_LINES_REQUIRED`. UI administrativa incompleta con fallos onboarding. No se afirma CI global verde. | QA de integración / responsables de esos incrementos |
| E2E nuevo de UI→estación→Central con DB persistente | Solo fixture UI y suites aisladas, sin reset del escenario existente. Dataset P/R/W por preparar. | Responsable UAT / QA |
| Hardware, ergonomía y recorrido físico | Sin trabajador/equipo real ni autorización de impresión. Scroll y jerarquía siguen provisionales. | Operador + supervisor |
| Nuevo cierre/relevo/inventario/retorno solo kg | Modelo UN aún vigente; falta diseño/gates. No autoaprobar TS o fabricar unidades. | Responsable funcional + ingeniería |
| Semántica de tipo/aporte del sticker | Tipo usa NORMAL/EXTRA y aporte final es delta desde control, no tramo completo. Hallazgos, no corregidos desde workflow UAT. | Responsable funcional / siguiente incremento |
| PostgreSQL/concurrencia de nuevos contratos | No se modificaron esquema/contratos productivos. SQLite y sync legacy no prueban locks kg futuros. | QA técnico tras TS aprobada |

## Resultado

Paquete de módulo: `spec_phase: approved` para alcance A/B heredado,
`delivery_state: review`, `functional_validation: untested` para aceptación del
módulo ampliado, `ux_validation: provisional`, `physical_uat: pending`,
`release_constraint: no_habilitar_en_planta`.

K3/K4 conservan su `qa_green` técnico, no se convierten en UAT aceptada. K5:
`spec_phase: story`, `delivery_state: not_started`, `functional_validation:
untested`, `ux_validation: needs_context`; sin TS/DEV porque faltan decisiones
operativas y validación/excepción UX. Se respetó el gate de generate-tech-spec.

Siguiente acción segura: revisar guion/acta y resolver Q1…Q4 de K5 para diseñar
el flujo kg. Se puede ensayar el bloque A actual con datos aislados sin esperar
la conciliación de Armado, que continúa diferida. Marcha blanca y liberación:
pendientes, sin nueva aprobación ni certificación integral de inventario.
