---
tipo: recibo_ejecucion
estado: desplegado-provisional-pendiente-uat
fecha: 2026-08-29
spec_phase: approved
delivery_state: deployed
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
tags: [recibo, despliegue, scm, wip, oa-excepcional, pesaje, pilot-13]
historias:
  - "[[../05_Especificaciones/02_User_Stories/US-010F3_Ruta_WIP_OA_Excepcional_y_Consumo_en_Linea]]"
  - "[[../05_Especificaciones/02_User_Stories/US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
uats:
  - "[[UAT_TS-010F3_OP0288_Tapa_Pico_Concurrente]]"
  - "[[UAT_US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
---

# REC-2026-08-29: despliegue F3 + K2 en Central y estación `pilot.13`

## Objetivo y alcance

- **Historia / DEV:** [[../05_Especificaciones/02_User_Stories/US-010F3_Ruta_WIP_OA_Excepcional_y_Consumo_en_Linea|US-010F3]] / [[../05_Especificaciones/04_Approved_for_Dev/DEV-010F3_Ruta_WIP_OA_Excepcional_y_Consumo_en_Linea|DEV-010F3]] y [[../05_Especificaciones/02_User_Stories/US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control|US-010K2]] / [[../05_Especificaciones/04_Approved_for_Dev/DEV-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control|DEV-010K2]].
- **Porción vertical ejecutada:** publicación técnica conjunta en Central y actualización controlada de `PESAJE-PLANTA-01` a `1.2.0-pilot.13`, con F3 y K2, manteniendo la restricción operativa.
- **Fuera de alcance respetado:** no se creó una OA/OF/OP productiva, no se pesó, no se imprimió, no se simuló hardware, no se reinició la PC y no se declaró aprobada la UAT humana o física.
- **Branch / worktree / commit:** backend `.codex-tmp/release-k2-f3-backend-20260829`, commit `d66fba0d50e818d261d0b78c64c9c960aa3921c6` en `origin/codex/render-provisional-dashboard`; frontend `.codex-tmp/release-k2-f3-frontend-20260829`, commit `c9e4ccb35ea534babb9ecef8796011ff166b5501`; estación `.codex-tmp/release-pilot13-k2-f3`, commit `c119e0fd643b8cfc9e41e042d941877ef93e1f19` en `origin/codex/pilot13-k2-f3-20260829`.
- **Gate de entrada:** QA automática verde, despliegue autorizado por el usuario y UAT física todavía pendiente.
- **Gate solicitado:** desplegar F3+K2 en Central y estación, permitiendo OA excepcionales con la misma autoridad que OF excepcionales, sin declarar UAT ni habilitación regular.
- **Gate alcanzado:** `delivery_state: deployed` para validación controlada; no habilitación regular en planta.

## Cambios desplegados

| Componente | Cambio | Evidencia de versión | Tipo: producto, prueba, documento |
|---|---|---|---|
| API Central | F3 + K2 y migraciones hasta `f92c7d9e1f86`. | Commit `d66fba0d50e818d261d0b78c64c9c960aa3921c6`; Render `dep-da9m182jnfac73e8n4j0`. | Producto |
| Frontend Central | Ruta WIP/PT, OA excepcional gobernada y UI K2. | Commit `c9e4ccb35ea534babb9ecef8796011ff166b5501`; Render `dep-da9m31hf2nfc73fv1eug`. | Producto |
| PostgreSQL/Supabase | Tablas de saldo, reserva y movimiento WIP; columnas/constraints K2; RLS y ACL backend-only. | Head `f92c7d9e1f86`; tres tablas F3 con RLS/FORCE, sin filas ni grants `anon`/`authenticated`. | Producto |
| Autorización | `OA_EXCEPCIONAL_CREAR` replica exactamente los roles de `OF_EXCEPCIONAL_CREAR`. | Producción: `GERENTE_GENERAL` y `JEFE_PRODUCCION`; el rol `PLANIFICACION` no tiene ninguna de las dos capacidades. | Producto |
| Estación de Pesaje | F3 + K2, QR único de preetiqueta y stickers CONTROL/FINAL sin QR. | `1.2.0-pilot.13`; source `c119e0f`; paquete SHA-256 `a8bc517e13539587f109cae33cd5efd48b9bfd71f11aa8d89b2abffc4c9f813e`. | Producto |
| Configuración de estación | Se preservaron estación, operador Renato, puertos reales y simulaciones desactivadas. | `PESAJE-PLANTA-01`; balanza `COM4/9600`; impresora TSPL `COM3`; health READY. | Producto |

## Verificaciones ejecutadas

| Comando / revisión | Resultado | Evidencia | Interpretación |
|---|---|---|---|
| Backend candidato | `468 passed`, `2 skipped`, `26 deselected`; focales F3 `28 + 8 + 8`, OT `41`; PostgreSQL concurrente `4 passed`. | Worktree aislado de release. | Contratos y concurrencia del incremento verdes. |
| Contrato canónico aislado | `1 passed`. | La búsqueda inicial en worktree limpio tropezó con una copia temporal obsoleta en `.codex-tmp/contracts`; se ejecutó el contrato canónico explícito. | No es una regresión de producto. |
| Frontend Central | `410 passed`; lint y build verdes. | Worktree aislado de release. | Candidato compilable y sin regresión focal observada. |
| Estación | Backend `182 passed`; frontend `40 passed`; focal backend `33 passed`; build verde. | Candidato `pilot.13`. | Contrato, renderer y UI del candidato verdes. |
| Render API | Deploy `live`; `/api/health` HTTP 200, aproximadamente 496 ms. | Servicio `srv-d9drl9jbc2fs73eo3a80`. | API nueva disponible. |
| Render dashboard | Deploy `live`. | Servicio `srv-d9drm9l7vvec73ej5e2g`. | Frontend nuevo publicado. |
| Smoke autenticado | Vista de OA cargó y mostró `Nueva OA de reposición WIP`; diálogo abrió selector WIP, cantidad y motivo; 0 errores de consola. Se canceló sin crear datos. | Navegador sobre producción con Gerente General. | UI y capacidad server-side accesibles para el rol autorizado. |
| Supabase productivo | Head `f92`; tres tablas F3 vacías; RLS/FORCE; sin ACL cliente; constraints K2 presentes. | Proyecto `swsovpdcbomvfhomplnc`. | Migración aditiva aplicada y superficie nueva protegida. |
| Simetría de permisos | OF excepcional y OA excepcional: Gerente General + Jefe de Producción. | Consulta read-only de capacidades/roles. | La OA excepcional no amplía autoridad respecto de la OF. |
| Instalador estación | `UPDATE_COMPLETE version=1.2.0-pilot.13`. | Log de soporte y manifiesto activo. | Activación completada con rollback local conservado. |
| Health estación | `/live` = LIVE; `/ready` = READY; Central ONLINE; `issues=[]`; un único listener apuntando a `pilot.13`. | Diagnóstico posterior. | Servicio local estable después de actualizar. |
| SQLite estación | `PRAGMA quick_check = ok`; 20 intentos históricos/preexistentes de etiqueta `IMPRESA`; 0 blockers de impresión; 0 jobs físicos; 0 trabajos Central pendientes con evidencia local. | Consulta read-only. | No se creó, mezcló ni reemitió una impresión durante el despliegue. |
| TSPL candidato | Preetiqueta conserva QR; CONTROL/FINAL no crean otro QR; `PRINT 1,1\r\n`. | Pruebas de renderer y artefacto `pilot.13`. | Se conserva el terminador físico solicitado. |

## Incidencia controlada durante la actualización

El primer intento del actualizador se detuvo de forma segura antes de backup,
migración o activación porque un proceso hijo de `pilot.12` mantenía ocupado el
puerto 5050. Se validaron PID, padre y línea de comando exactos; se terminaron
únicamente esos dos procesos de `pilot.12`, se confirmó el puerto libre y se
repitió el actualizador. `active-release.json` permaneció en `pilot.12` durante
el intento fallido y cambió a `pilot.13` solo al completar el segundo intento.

- Backup preactualización: `C:\ProgramData\EnvaPeru\Pesaje\backups\pesajes_PESAJE-PLANTA-01_schema-v10_20260829T230638.607929Z_pre-update-1.2.0-pilot.13.db`.
- Baseline prevalidación: `C:\ProgramData\EnvaPeru\Pesaje\backups\pesajes_PESAJE-PLANTA-01_schema-v10_20260829T230643.157406Z_pre-validation-1.2.0-pilot.13.db`.
- Release anterior conservado: `1.2.0-pilot.12`.
- Kit y diagnósticos: `C:\Soporte\EnvaPeru-Piloto-1.2.0-pilot.13-20260829`.

## Evidencia UX y operativa

- **Dispositivo / viewport:** dashboard productivo en navegador de escritorio; estación verificada por API/servicio, no mediante operación física.
- **Estados observados:** API live, dashboard live, OA excepcional visible para rol autorizado, diálogo vacío/cancelable, estación LIVE/READY y Central ONLINE.
- **Comparación con wireflow:** el acceso gobernado y el diálogo OA WIP coinciden con el prototipo provisional; el recorrido físico K2 y la selección WIP completa quedan para las UAT enlazadas.
- **Accesibilidad básica:** cubierta por pruebas de componente; no sustituye observación de trabajador.
- **Validación humana realizada:** no. El usuario autorizó el despliegue técnico; comprensión, ergonomía, impresión, lectura QR y recorrido de pesaje no fueron validados.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Creación y recorrido real de OA excepcional OP-0288 | Faltan datos físicos/validaciones de la UAT; crear hechos en producción no formaba parte del smoke. | Selección o consumo equivocado en un caso real. | Planificador, Armado y QA en [[UAT_TS-010F3_OP0288_Tapa_Pico_Concurrente]]. |
| Impresión física CONTROL/FINAL y preetiqueta | El usuario autorizó desplegar, no fabricar hechos ni imprimir durante la ventana. | Márgenes, DPI, acentos, spooler o QR ilegible. | Renato/operador y soporte en [[UAT_US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]. |
| Pesaje y relevo con balanza/lector reales | Requiere manga, trabajadores y equipos reales. | Lectura, foco, comprensión o atribución incorrecta. | Supervisor y trabajadores en UAT física. |
| Reinicio en frío de la PC | Evitado para no ampliar la interrupción. | Persistencia de la tarea programada aún no demostrada tras reboot. | Soporte en ventana controlada. |
| UAT UX representativa | No hubo observación con postura, distancia, EPP y presión real. | Interfaz técnicamente correcta pero no usable en planta. | Responsable UX/operación. |

## Hallazgo de retrocompatibilidad legacy

La base local legacy se conservó y respaldó, pero su conector histórico apunta a
`http://localhost:5000/api` y permanece desconectado. El endpoint legacy reportó
`16,340` pendientes y la consulta SQLite mostró `16,568` filas `pesajes` sin
sincronizar; son métricas de universos/criterios distintos. El canal SCM nuevo
sí quedó `ONLINE`. Este hallazgo es preexistente, no bloqueó la actualización y
significa que la base local/backup no debe confundirse con un respaldo cloud.

## Compatibilidad, rollback y recuperación

1. `pilot.12`, el backup preactualización y el manifiesto anterior quedan disponibles para rollback antes de introducir hechos nuevos.
2. Si ya existen controles, tramos, OA, reservas, movimientos o consumos nuevos, se aplica forward fix; no se borran datos ni se ejecuta downgrade destructivo para “volver”.
3. Un rollback de aplicación Central no revierte automáticamente PostgreSQL; las migraciones aditivas permanecen para que las versiones anteriores ignoren los objetos nuevos.
4. Para detener OA excepcionales sin borrar hechos, se puede retirar `OA_EXCEPCIONAL_CREAR` de los mismos roles de forma controlada y ocultar la acción.
5. Cualquier rollback de estación debe validar primero cola física, jobs Central, intentos locales y sincronización; no se reimprime ni repesa como mecanismo de recuperación.

## Resultado

```yaml
spec_phase: approved
delivery_state: deployed
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** UAT física F3/K2, reinicio en frío y acumulación legacy sin sincronización cloud.
- **Decisión humana pendiente:** aceptar o rechazar comprensión, ergonomía, impresión/lectura y recorrido físico; completar datos `PF-01..08` de OP-0288.
- **Observación productiva / marcha blanca:** despliegue técnico completado; marcha blanca operativa todavía no iniciada ni aprobada.
- **Siguiente acción segura:** ejecutar las dos UAT en ventana controlada, comenzando sin hechos productivos irreversibles y con verificación de cola, impresora, balanza y lector.
