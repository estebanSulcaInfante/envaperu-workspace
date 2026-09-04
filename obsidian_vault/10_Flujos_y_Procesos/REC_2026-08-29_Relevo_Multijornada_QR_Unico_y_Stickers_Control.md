---
tipo: recibo_ejecucion
estado: desplegado-provisional-pendiente-uat
fecha: 2026-08-29
historia: "[[US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
dev: "[[DEV-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
spec_phase: approved
delivery_state: deployed
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
tags: [recibo, scm, pesaje, manga, relevo, impresion]
---

# REC-2026-08-29-K2: relevo multijornada, QR único y stickers de control

## Objetivo y alcance

- **Historia / DEV:** [[US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]] / [[DEV-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]].
- **Porción vertical:** control acumulado con aporte y job de impresión;
  sticker CONTROL/FINAL sin QR; relevo dentro de la misma OT conservando
  Trabajo, manga y QR; bandejas/estados y lenguaje de peso inequívoco.
- **Fuera de alcance respetado:** offline autoritativo, activación por familia
  “orrines”, conciliación automática de tara, trasvase, pesaje/impresión y UAT
  real. El despliegue técnico posterior se documenta en una adenda.
- **Branch / worktree / commit:** la implementación nació en un worktree
  compartido; el candidato aislado de estación se publicó como
  `c119e0fd643b8cfc9e41e042d941877ef93e1f19` en
  `origin/codex/pilot13-k2-f3-20260829`.
- **Gate de entrada:** DEV aprobado para implementación local, UX provisional.
- **Gate alcanzado:** despliegue técnico controlado con QA verde; no
  habilitación regular en planta.

## Cambios

| Archivo o componente | Motivo | Tipo |
|---|---|---|
| `backend/app/models/scm_ot.py` | Persistir aporte y relación auditable control–etiqueta; admitir `CONTROL_PESO`. | Producto |
| `backend/migrations/versions/f89d4f6b8c53_add_control_weight_labels_and_same_ot_relief.py` | Migración aditiva, backfill y capacidad de relevo. | Producto |
| `backend/app/services/scm_configuration.py` | Registrar/sembrar `MANGA_REASIGNAR_MAQUINISTA`. | Producto |
| `backend/app/services/scm_weighing_service.py` | Cálculo comparable, etiqueta/job atómicos y final sin QR. | Producto |
| `backend/app/services/scm_ot_service.py` | Relevo sobre manga abierta en la misma OT y bandejas de impresión. | Producto |
| `backend/tests/scm/test_scm_ot_service.py` y `test_weight_control_label_migration_sqlite.py` | ATDD de relevo, aporte, idempotencia, tara y migración. | Prueba |
| `frontend/src/components/OtMangasScm.jsx` | Acción supervisada `Registrar relevo · continúa incompleta`. | Producto |
| `frontend/src/components/PrintJobsControlScm.jsx` | Tipos legibles y exploración de CONTROL/FINAL. | Producto |
| `frontend/src/components/WarehouseReceivingScm.jsx` | Aclarar que recepción usa el QR único de preetiqueta. | Producto |
| `frontend/src/components/ProductionSupervisionScm.jsx` | Sustituir “neto físico/Kg estándar” por rótulos inequívocos. | Producto |
| `frontend/src/tests/OtMangasScm.spec.jsx` y `ProductionSupervisionScm.spec.jsx` | Cobertura de relevo y lenguaje operativo. | Prueba |
| `modulo-pesaje/backend/app/services/scm_prelabel_service.py` | Renderer 2-up sin QR, neto dominante, aporte y CRLF. | Producto |
| `modulo-pesaje/backend/app/services/scm_weighing_service.py` | Imprimir el job del control sin repetir el pesaje. | Producto |
| `modulo-pesaje/backend/app/services/portfolio_demo_service.py` | Demo de peso final alineada con plantilla sin QR. | Producto |
| Pruebas backend de estación | Contrato CONTROL/FINAL, 1–2 etiquetas, no QR, impresión y demo. | Prueba |
| `modulo-pesaje/frontend/src/components/ScmWeighing.jsx` | Control abierto, resultado de impresión y rótulos de peso claros. | Producto |
| Pruebas frontend de estación | Estados de control, impresión, final y navegación. | Prueba |
| US, TS, DEV, prototipo, casuística y guía | Trazar decisión, riesgos, contratos y gate. | Documento |
| [[UAT_US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]] | Instanciar UAT PES+LEC+ADM+IMP+CON. | Documento |
| `output/US-010K2_etiqueta_control_peso_sin_qr.svg` | Evidencia del renderer real a `109 × 50 mm`, 2-up. | Evidencia |

## Verificaciones ejecutadas — corte local previo al candidato

Esta tabla conserva el snapshot del cierre de implementación local. La adenda
posterior registra el head y las suites del candidato efectivamente desplegado.

| Comando / revisión | Resultado | Interpretación |
|---|---|---|
| Prueba focalizada Central `tests/scm/test_scm_ot_service.py` | `37 passed` | K1/K2, control, relevo, final y recepción sin regresión. |
| Migraciones K1+K2 SQLite | `2 passed`; K2 aislada `1 passed` | Upgrade/downgrade, constraint, backfill y permisos. |
| `flask --app run:app db heads` | `f89d4f6b8c53 (head)` | Una sola cabeza Alembic en ese corte local previo. |
| Frontend Central focalizado | `4 files / 43 tests passed` | Relevo, supervisión, impresión y recepción. |
| `./scripts/test-contracts.ps1` | Provider `1 passed`; consumer `2 passed` | Copias y contrato legacy-v1 permanecen compatibles. |
| `./scripts/test.ps1 -Component pesaje` | `139 passed` | Regresión completa backend de estación. |
| Frontend estación `npm test` | `10 files / 42 tests passed` | UI control/final y utilidades verdes. |
| Frontend Central completo | `78 files / 461 tests passed` | Regresión completa de interfaz verde. |
| Builds Central y estación | Ambos Vite builds exitosos | Bundles compilables; Central conserva warning preexistente de chunk grande. |
| Suite backend Central completa | `470 passed`, `1 skipped`, `1 failed`, `24 deselected` | Snapshot local histórico: el único fallo estaba fuera de K2; el candidato aislado posterior quedó verde según la adenda. |
| TSPL de 1 y 2 etiquetas | Prueba verde; termina `PRINT 1,1\r\n` | Conserva el salto de línea físico solicitado. |
| Inspección SVG real | Neto `8.950` dominante; aporte `+4.150`; dos copias; sin QR/siglas | Jerarquía visual provisional validada técnicamente. |

## Evidencia UX y operativa

- **Dispositivo / viewport:** evidencia de etiqueta `872 × 400 px`, equivalente
  al `viewBox` 2-up `109 × 50 mm`; pantalla Central/estación cubierta por
  pruebas DOM, sin captura en el hardware/viewport final.
- **Estados cubiertos automáticamente:** listo, guardando, control guardado,
  impresión realizada/fallida, final, relevo y errores contractuales.
- **Comparación con wireflow:** conserva un QR; control imprime; mismo-OT abre
  tramo; final acredita una vez.
- **Accesibilidad básica:** nombres de acciones y rótulos explícitos; pruebas
  DOM. Navegación por teclado/lector de pantalla pendiente en UAT.
- **Validación humana realizada:** no.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Capturas visuales completas de Central/estación en viewport objetivo | No se dispone todavía del contexto físico/resolución final ni dataset aislado navegable. | Densidad, scroll o foco no observados. | UX/QA con UAT preparada. |
| Impresión TSPL en impresora real | El despliegue técnico no autorizó crear hechos ni imprimir durante la ventana. | Márgenes, DPI, spooler y acentos físicos. | Operador de Pesaje + soporte. |
| Superposición y lectura del QR original | Requiere manga, adhesivo y lector reales. | Cubrir/dañar la única identidad. | Operador + maquinistas. |
| Relevo observado con dos trabajadores | No se ejecutó operación productiva. | Contexto anterior, comprensión o casi-error. | Supervisor + maquinistas. |
| Caídas y emisión incierta físicas | Requieren ventana controlada y procedimiento de staging. | Duplicado o objeto mezclado. | QA operativo/soporte. |

## Adenda de despliegue — 2026-08-29

- Central se publicó con backend `d66fba0d50e818d261d0b78c64c9c960aa3921c6`, frontend `c9e4ccb35ea534babb9ecef8796011ff166b5501` y migraciones productivas hasta `f92c7d9e1f86`.
- El candidato de release corrigió el fallo global ajeno observado durante la implementación: backend `468 passed`, `2 skipped`, `26 deselected`; estación backend `182 passed`, frontend `40 passed`; ambos builds verdes.
- `PESAJE-PLANTA-01` se actualizó de `pilot.12` a `1.2.0-pilot.13`; quedó LIVE/READY, Central ONLINE, `issues=[]`, un único listener de la versión nueva y cola física vacía.
- Se conservaron backup preactualización, baseline prevalidación y el release `pilot.12` como recuperación. El primer intento se detuvo de forma segura por un proceso hijo obsoleto en el puerto 5050 y no activó ni migró nada; el reintento controlado terminó correctamente.
- No se ejecutó pesaje, relevo ni impresión física. La UAT continúa pendiente.
- Recibo técnico consolidado: [[REC_2026-08-29_Despliegue_F3_K2_Central_y_Estacion_Pilot13]].

## Resultado

```yaml
spec_phase: approved
delivery_state: deployed
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** impresión/superposición real, contexto compartido entre
  trabajadores, reinicio en frío de la estación y conector legacy local
  desconectado.
- **Decisión humana pendiente:** aceptar comprensión, ergonomía, legibilidad,
  política física de copia y procedimiento de emisión incierta.
- **Observación productiva / marcha blanca:** despliegue técnico realizado;
  marcha blanca operativa todavía no iniciada ni aprobada.
- **Rollback:** `pilot.12` y el backup preactualización están disponibles antes
  de introducir hechos nuevos. Después de crear controles, etiquetas o tramos,
  corresponde forward fix: un rollback de app no borra datos y la migración no
  se revierte para “limpiar” hechos productivos.
- **Siguiente acción segura:** ejecutar la UAT física preparada con cola,
  impresora, balanza y lector verificados; solo después decidir la liberación.
