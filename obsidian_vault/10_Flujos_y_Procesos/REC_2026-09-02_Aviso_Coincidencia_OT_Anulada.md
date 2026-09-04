---
tipo: recibo_ejecucion
estado: corregido-solo-local
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
fecha: 2026-09-02
---

# Recibo — Aviso de coincidencia incluye OT anulada

## Objetivo y alcance

- Bugfix explícitamente autorizado por el usuario: «ajustemos el aviso».
- Historia/DEV: [[US-010M4_Creacion_Revisada_y_Anulacion_OT_Vacia]],
  [[DEV-010M4_Anulacion_OT_Vacia]], [[TS-010M4_Anulacion_OT_Vacia]].
- Conteo del aviso excluye ANULADA; historial y selección se conservan.
- No altera CERRADA/legacy, resumen total de jornadas, permisos, API, pesaje,
  datos, inventario, sincronización ni hardware. Sin reset ni despliegue remoto.
- Workspace envaperu-workspace-2 y submódulo frontend con cambios previos;
  no commit nuevo, preservados cambios ajenos. Excepción UX solo UAT local vigente.

## Cambios

| Archivo | Tipo y motivo |
|---|---|
| frontend/src/components/OtMangasScm.jsx | Producto: filtrar ANULADA solo al calcular concurrentOtCount |
| frontend/src/tests/OtMangasDailyBoard.spec.jsx | Pruebas: falsa alerta, consulta histórica y mezcla de dos no anuladas + anulada |
| TS-010M4 / UAT_US-010M4 | Documento: contrato del aviso, caso M4-09 y hallazgo del usuario |

## Verificaciones

Comandos ejecutados desde frontend:

| Paso | Comando / revisión | Resultado |
|---|---|---|
| BASELINE | npm run test:run -- src/tests/OtMangasDailyBoard.spec.jsx | 15/15 verdes |
| RED | npm run test:run -- src/tests/OtMangasDailyBoard.spec.jsx -t 'excluye la OT anulada' | Falla por presencia del aviso «2 OT coinciden» |
| RED adicional | Prueba de dos no anuladas + una anulada | Falla: aviso cuenta tres |
| GREEN / revisión | npm run test:run -- src/tests/OtMangasDailyBoard.spec.jsx src/tests/OtMangasScm.spec.jsx src/tests/OtHeaderSafety.spec.jsx src/tests/PlantJourneysScm.spec.jsx src/tests/scmOtApi.spec.js | 58/58 verdes, cinco archivos |
| Build | npm run build | Correcto, 1312 módulos; advertencia de bundle grande |
| Visual | Recargar UAT local, leer DOM y revisar captura | OT-000002 PLANIFICADA / Jose Quispe, sin aviso falso |

Prueba inicial ajustada antes del RED válido para seleccionar la OT de reemplazo:
la selección automática usa el primer elemento recibido y no forma parte del fix.
Refactor: no extracción adicional; filtro local evita retirar el historial de la UI.

## Evidencia UX y operativa

- Contexto: [[CTX_PROTO_US-010M4_Recuperacion_OT_Vacia]], perfiles ADM/CON.
- Viewport observado en esta sesión: 1049×859, no dispositivo físico de planta.
- Captura completa: outputs/uat-m4-2026-09-02/08-tablero-sin-falsa-coincidencia.png.
- Primaria: código/estado/máquina; acción primaria existente: Ver detalle y gestionar.
- Estado listo sin falso aviso; alerta de dos no anuladas cubierta en componente.
- No nuevos controles, estados de carga/error ni cambios de foco. La prueba abre
  el selector y consulta la anulada mediante controles con nombre accesible.
- El total «Jornadas 2» sigue contando registros históricos; no es alerta de conflicto.
- Validación humana del ajuste pendiente. No se ejecutaron acciones de negocio.

## Comprobaciones omitidas y riesgos

- No se repitió scripts/test.ps1 -Component frontend completo: baseline focal
  proporcional a este filtro; la ejecución M4 anterior reportó fallos preexistentes
  de ProductOnboardingTechnicalSteps. No se afirma regresión global verde.
- Backend, contratos Central–pesaje, sync y PostgreSQL omitidos: no cambia su código
  ni contratos. Captura con dos OTs no anuladas sustituida por prueba de componente
  para no crear documentos artificiales en el recorrido del usuario.
- Viewports 1440×900/1163×654 y teclado físico no repetidos; no hay cambios de layout
  ni controles. UX permanece provisional hasta revisión humana correspondiente.

## Resultado y siguiente paso

Corrección funcional local verificada; no habilitada en planta. Datos UAT intactos.
Usuario revisa ausencia del aviso y continúa OT-000002. Aceptación funcional/UX
humana pendiente; marcha blanca productiva no aplicable a este ensayo local.
