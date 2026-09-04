---
tipo: recibo_ejecucion
estado: implementado-solo-local
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
fecha: 2026-09-02
---

# Recibo — Maquinista inicial tomado de la OT

## Objetivo y alcance autorizado

Petición explícita «Vale apliquemos este ajuste» durante UAT local. Bugfix/UI
acotado permitido por implement-feature.md sin un DEV nuevo. Fuentes:
[[Registro_Diario]], [[Asignacion_Trabajo_OT]], [[TS-010M3_Relevos_en_Trabajo_Color]],
[[DEV-010M3_Relevos_en_Trabajo_Color]]. No cambia reglas de relevo posteriores.
Contexto de escritorio/supervisión y perfiles ADM/CON:
[[CTX_PROTO_US-010M4_Recuperacion_OT_Vacia]]. UX provisional, solo ensayo local.

La OT-000002 tiene Jose Quispe, pero el alta de trabajo proponía Pedro Huaman
(primer registro del catálogo). El servidor ya admite heredar el predeterminado;
la UI enviaba siempre otro valor explícito. No se crean trabajos durante QA visual.

## Contrato de interacción del ajuste

- Primaria: maquinista que comenzará el trabajo, con origen explícito «Tomado de la OT».
- Predeterminado válido: resumen de nombre + botón secundario «Cambiar para este trabajo».
- Cambio explícito: selector «Maquinista inicial» con nombre accesible; volver mediante
  «Usar maquinista de la OT». No modifica la cabecera ni asignaciones existentes.
- Sin predeterminado disponible en catálogo activo: explicar y exigir elección;
  nunca seleccionar automáticamente el primer trabajador.
- Cambio de OT y alta exitosa descartan la excepción del formulario; error conserva
  la elección para reintento. No arrastrar responsable entre jornadas.
- Primaria existente «Agregar a la cola de esta OT» bloqueada sin trabajador válido
  y durante envío. Carga/error del formulario mantienen los controles existentes.
- Presentación escritorio local; no se infieren condiciones físicas de planta.

## Verificación y cierre

Workspace envaperu-workspace-2 / frontend con cambios previos, sin commit nuevo.
Sin reset, migraciones, datos de negocio, impresión ni despliegue remoto.
Gate solicitado: corrección funcional local; no aceptación humana/planta.

| Paso / comando desde frontend | Resultado |
|---|---|
| BASELINE: npm run test:run -- src/tests/OtMangasScm.spec.jsx | 21/21 verdes |
| RED: mismo comando con -t 'hereda el maquinista' | Falla: resumen heredado inexistente, selector previo con primer trabajador |
| GREEN: npm run test:run -- src/tests/OtMangasScm.spec.jsx src/tests/OtMangasDailyBoard.spec.jsx src/tests/PlantJourneysScm.spec.jsx src/tests/OtHeaderSafety.spec.jsx src/tests/scmOtApi.spec.js | 64/64 verdes, cinco archivos |
| REFACTOR visual: npm run test:run -- src/tests/OtMangasScm.spec.jsx -t 'maquinista\|elección manual' | 7 verdes, 20 omitidas por filtro |
| npm run build (antes y después del ajuste visual) | Correcto, 1312 módulos; advertencia previa de bundle grande |
| git diff --check focal | Sin errores; advertencia LF/CRLF |

El comando focal REFACTOR se ejecutó pasando el patrón literal `maquinista|elección manual`.
Cobertura: predeterminado distinto del primero del catálogo, excepción/cancelación,
envío del ID correcto, falta de predeterminado o ID fuera de catálogo, cambio de OT
y retorno sin arrastre, reset después de éxito, conservación tras error.
La fixture OT existente ahora declara explícitamente su maquinista predeterminado;
ya no se apoya accidentalmente en el primer elemento del catálogo.

## Cambios y evidencia visual

- Producto: frontend/src/components/OtMangasScm.jsx, valor derivado de la OT y
  catálogo activo; excepción local ligada a la identidad OT. Sin cambio API/backend.
- Pruebas: frontend/src/tests/OtMangasScm.spec.jsx, seis casos nuevos.
- Documentación: este recibo y adenda de [[Asignacion_Trabajo_OT]].
- Viewport observado: 1049×859, navegador local, perfil Said/Supervisor.
- Capturas finales en outputs/uat-m4-2026-09-02:
  11-maquinista-heredado-distribucion-final.png y
  12-maquinista-opcional-distribucion-final.png.
- Capturas 09/10 son previas al refactor visual. Se detectó botón de recalcular
  comprimido; se habilitó salto de línea en la fila y alineación del botón.
- Se inspeccionaron ambos estados, se abrió Cambiar y se volvió a Usar maquinista
  de la OT sin enviar. Selector con labelId/nombre accesible, botones semánticos.
- API y pantalla: OT-000002 PLANIFICADA, Jose Quispe (5), cero trabajos. El ajuste
  no creó ni alteró documentos de negocio. Formulario final vuelve a Jose heredado.

## UAT incremental propuesta / pendientes

Adaptación al contexto ADM/CON vigente; no se aprueba automáticamente:

| Perfil / caso | Acción humana | Esperado | Estado |
|---|---|---|---|
| ADM-02/03 | Abrir alta de trabajo de OT-000002 | Reconoce Jose y origen OT; no debe elegirlo de nuevo | PENDING |
| ADM-08/09 | Cambiar para este trabajo, luego Usar maquinista de la OT | Entiende alcance y puede volver; validar teclado real | PENDING |
| ADM-12 | Cambiar de OT durante planificación | No arrastra excepción de otra jornada | PENDING |
| CON-11 | Error en alta aislada | Conserva elección y mensaje para recuperación | PENDING |

Participante/RUN y aceptación de este ajuste: pendientes de registrar. No hardware,
QR, peso ni unidades en este corte; perfiles físicos no aplican.

## Comprobaciones omitidas, riesgos y cierre

- Suite completa scripts/test.ps1 no repetida: alcance frontend acotado, baseline y
  regresión focales; fallos globales preexistentes de ProductOnboarding documentados
  en M4. No se afirma workspace completo verde.
- Backend, PostgreSQL, contratos Central–pesaje y sync no repetidos: no modificados.
- Estados sin predeterminado/error/cambio de OT validados automáticamente, sin
  crear dataset de negocio en UAT para capturas. Teclado representativo y otros
  viewports pendientes. No se promete UX-READY por pruebas automáticas.
- El alta de cabecera y el formulario de relevo conservan su comportamiento previo;
  este ajuste solo evita el primer trabajador arbitrario en el alta de trabajo.
- Riesgo residual: gates UX/UAT humana pendientes; no habilitar en planta.
- Siguiente acción segura: usuario revisa Jose heredado y continúa preparando
  el trabajo de color. Observación productiva: no aplicable, solo UAT local.
