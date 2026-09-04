---
tipo: recibo_ejecucion
estado: implementado-local-qa-green-pendiente-uat
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
fecha_creacion: 2026-09-03
relaciones:
  - "[[DEV-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[CTX_PROTO_Jerarquia_Trabajo_OT_2026-09-03]]"
  - "[[UAT_Jerarquia_Trabajo_OT_2026-09-03]]"
---

# Recibo — Jerarquía de trabajos de color y alta separada

## Objetivo y alcance

- Story/TS/DEV: M1, adenda de refactor de UI autorizada en conversación.
- Entrada: petición explícita del usuario durante UAT local, conforme al
  playbook implement-feature para refactor acotado. Sin nuevo flujo de negocio.
- Gate solicitado: corrección funcional/revisión local, no UX-READY ni planta.
- Worktree: envaperu-workspace-2, rama raíz main; frontend HEAD 0964c3d con
  cambios previos extensos. No commit, reset, seed, migración ni despliegue.
- Fuera de alcance: kg de cola/inventario, reglas de pesaje, QR, permisos,
  emisión física y datos de la UAT vigente.

## Cambios

| Archivo/componente | Motivo | Tipo |
|---|---|---|
| frontend/src/components/OtMangasScm.jsx | Cola adyacente y sticky, tarjeta Consultando/aria-pressed, región de detalle con código; alta en diálogo; destino explícito; errores dentro; volver conserva borrador, envío protegido y éxito consulta hijo devuelto | Producto |
| frontend/src/tests/OtMangasScm.spec.jsx | Cinco escenarios de jerarquía; adaptación al alta explícita; regresión de kg, persona, plan, errores, relevo y etiquetas | Prueba |
| frontend/src/tests/OtMangasDailyBoard.spec.jsx | Abrir diálogo en tres pruebas existentes de color del alta | Prueba |
| Vista_US-010M, TS-010M1 y DEV-010M1 | Adenda y trazabilidad de la interacción implementada | Documento |
| CTX_PROTO_Jerarquia_Trabajo_OT_2026-09-03 | Contexto observado, contratos, estados, autorización y límites | Documento |
| UAT_Jerarquia_Trabajo_OT_2026-09-03 | Guion con ADM/CON v1 expandidos y aceptación humana pendiente | Documento |

## Verificaciones

| Comando/revisión | Resultado | Evidencia / interpretación |
|---|---|---|
| BASELINE focal: npm run test:run -- src/tests/OtMangasScm.spec.jsx --maxWorkers=1 | 36/36 aprobadas, antes de cambios de producto | 89.62 s; estado previo caracterizado |
| scripts/test.ps1 -Component frontend, primer intento | 505 aprobadas / 2 fallidas | outputs/uat-hierarchy-baseline-2026-09-03.log; ejecución larga alcanzó las dos nuevas RED mientras se editaba: NO es baseline completa inmutable ni un fallo ajeno al incremento |
| RED: OtMangasScm -t jerarquía | Dos fallos esperados | Formulario visible en consulta y ausencia de aria-pressed |
| GREEN inicial: mismo comando | 2 aprobadas / 36 omitidas por filtro | Separación y navegación verificadas |
| Regresión intermedia OT/tablero | 54 aprobadas / 1 fallo | El test de cambio de OT consultaba la página antes de acabar la transición de salida del diálogo; se corrigió espera observable, sin omitir prueba |
| Ampliación focal de escenarios | 5 aprobadas / 1 fallo inicial | Mismo problema de sincronización de transición en nuevo test; corregido waitFor de cierre |
| Regresión final completa: scripts/test.ps1 -Component frontend | 81 archivos / 510 pruebas aprobadas, 0 fallos | outputs/uat-hierarchy-regression-2026-09-03.log; 407.89 s |
| Rechequeo final focal: jerarquía, cambio de OT y error de alta | 7 aprobadas / 34 omitidas por filtro | 20.57 s; confirma correcciones de espera de transición |
| npm run build | Aprobado | 1314 módulos; index-DTdNZAyz.js; warning de tamaño de bundle existente |
| git -C frontend diff --check (tres archivos del incremento) | Aprobado | Sin errores whitespace |
| npx eslint (tres archivos) | No verde: 1 error / 1 warning previos | OtMangasDailyBoard:457 user sin uso, OtMangasScm:1206 dependencia reliefWorkers. Líneas fuera del refactor; no ocultados ni corregidos fuera de alcance |

## Evidencia UX-operativa

Carpeta `outputs/uat-hierarchy-2026-09-03`:

- `01-contexto-trabajo-1049.png`: consulta y código de trabajo explícitos.
- `02-alta-separada-1049.png`: diálogo de alta con OT destino y acciones fijas.
- `03-mangas-navegacion-visible-1049.png`: navegación visible mientras se ven las
  dos mangas; top DOM 0, sin overflow global (ancho documento 1041/viewport 1049).
- `04-escritorio-viewport-solicitado-1440.png`: viewport solicitado 1440×900;
  medida CSS real devuelta por el navegador 1309×818. Se registra ambas medidas,
  sin atribuir zoom físico; override retirado y viewport restaurado a 1049×859.

Wireflow aplicado: lista horizontal compacta adyacente al detalle, no panel lateral
permanente. Es una navegación sticky con scroll horizontal local para conservar
ancho de tabla. El formulario independiente no ocupa espacio en la consulta.
Se revisaron las capturas; ninguna demuestra por sí sola aceptación de planta.

Teclado/semántica: nombres de diálogo/región, aria-pressed, pruebas de Escape
durante envío, volver/cierre y controles deshabilitados. Recorrido humano
representativo de Tab y lector de pantalla: pendiente en ADM-09.

La verificación en la OT vigente solo abrió/cerró el formulario, consultó el
trabajo ya seleccionado y desplazó la vista; nunca envió alta, pesaje, relevo ni
impresión. No se reseteó el escenario. Validación humana: no ejecutada aún.

## Comprobaciones omitidas y riesgos

| Comprobación | Motivo / riesgo | Siguiente responsable |
|---|---|---|
| Backend, contratos central-estación, sync E2E | Sin cambios de backend, API, payload o sincronización | Reejecutar si un incremento cambia esos contratos |
| Recorrido físico/hardware | No aplica al refactor de consulta; sigue pendiente en UAT integral de pesaje | Responsable piloto |
| Capturas multicolor y vacío con datos reales | OT vigente tiene un color; no se crean datos artificiales allí. Variantes cubiertas por fixtures automáticos, visual representativa pendiente | Supervisor UAT, OT de prueba separada |
| Contingencia real/respuesta POST perdida | UI de error cubierta en mocks; no se derriba Central compartida. Idempotencia servidor no se amplía | Responsable UAT aislada |
| Lector de pantalla, zoom y puesto real | No disponibles como evidencia representativa | Participante ADM |

Persistencia de borrador solo en memoria de la misma OT; no sobrevive a recargar.
Las métricas de cola permanecen en unidades; no se confunden aquí con kg reales.
No se declara listo para planta. Siguiente gate: ejecutar guion humano y registrar
resultado funcional/UX por separado. Marcha blanca productiva: no realizada.
