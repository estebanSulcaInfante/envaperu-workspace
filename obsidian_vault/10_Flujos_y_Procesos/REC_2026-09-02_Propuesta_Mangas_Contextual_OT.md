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

# Recibo — Preparación contextual de mangas al agregar trabajo

## Alcance y autorización

Usuario autoriza «vale hagamos estos ajustes» después del hallazgo de un botón
«Recalcular plan de la OF» sin propuesta visible. Bugfix/UI acotado dentro de
la UAT local existente; no se recalcula ni se crea trabajo real por el agente.
Fuentes: [[TS-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje]],
[[Perfil_Empaque]], [[Registro_Diario]]. Contexto de supervisión escritorio y
perfiles ADM/CON: [[CTX_PROTO_US-010M4_Recuperacion_OT_Vacia]].
Workspace envaperu-workspace-2 / frontend sucio previo, sin commit nuevo.

## Contratos del ajuste

- Primaria: propuesta de mangas para el color de la OF seleccionada; unidades
  son planificación, no conteo físico confirmado ni inventario.
- Sin plan: aviso explícito y «Calcular propuesta de mangas» con permiso existente.
- Con plan: pieza/color, pendiente de asignar, capacidad por manga, propuesta
  total de la OF y cantidad a asignar al trabajo. No confundir propuesta total
  de OF con mangas nuevas del trabajo parcial.
- «Ver OF» enlaza al detalle identificado en otra pestaña, conservando formulario.
- Recalcular es secundario y explica: nueva revisión a partir de configuración
  liberada y reglas de empaque aprobadas; no crea mangas ni modifica la OF.
- Carga/consulta fallida no equivalen a ausencia de plan. Mostrar espera/error
  y reintento; bloquear alta sin plan vigente, trabajador, color o asignación
  válida. Continuidad compatible seleccionada sigue permitiendo cero saldo nuevo.
- Cambio de OF retira propuesta previa; respuestas tardías no mezclan planes.
- Sin permiso de cálculo: explicar que requiere responsable autorizado.
- No cambia backend/API, capacidades, reglas de empaque, relevos ni inventario.

## Verificación

| Paso / comando (desde frontend) | Resultado |
|---|---|
| BASELINE: npm run test:run -- src/tests/OtMangasScm.spec.jsx | 27/27 verdes |
| RED: mismo comando con -t 'ausencia de plan' | Dos fallos esperados: no existe mensaje inicial y consulta fallida se confunde con plan inexistente |
| GREEN focal: patrón ausencia de plan, cantidad inválida, maestro de empaque y manga abierta | 8 verdes, 25 excluidos por filtro |
| Regresión: npm run test:run -- src/tests/OtMangasScm.spec.jsx src/tests/OtMangasDailyBoard.spec.jsx src/tests/PlantJourneysScm.spec.jsx src/tests/OtHeaderSafety.spec.jsx src/tests/scmOtApi.spec.js | 72/72 verdes, cinco archivos |
| npm run build | Correcto, 1312 módulos, advertencia de bundle grande preexistente |
| git diff --check focal | Sin errores; avisos LF/CRLF |

REFACTOR: condición común de habilitación para botón y envío; generación de
consulta evita respuestas obsoletas; refresco de propuesta después de agregar
trabajo para no reutilizar saldos anteriores. Sin extracción innecesaria.
Ocho casos nuevos cubren ausencia/cálculo, consulta fallida/reintento,
0/negativo/exceso/fracción, permisos y respuesta tardía al cambiar de OF.
El caso existente de continuidad con saldo cero permanece verde.

## Archivos y evidencia UX

- Producto: frontend/src/components/OtMangasScm.jsx.
- Pruebas: frontend/src/tests/OtMangasScm.spec.jsx; cambio de nombre en caso
  previo de bloqueo por empaque y nuevos escenarios.
- Documentos: este recibo y adenda en TS-010C.
- Evidencia visual mediante habilidad de navegador: viewport 1049×859, Said,
  OT-000002 / OF-000001. Captura revisada:
  outputs/uat-m4-2026-09-02/13-propuesta-mangas-sin-plan.png.
- UI sin plan, aviso con motivo, cálculo disponible y agregar deshabilitado.
  Jose Quispe heredado y acceso a la OF exacta. No se pulsó calcular/agregar.
- «Ver OF» usa ruta existente /produccion/ordenes-fabricacion?of={id} y abre
  otra pestaña; selector de OF y cantidades conservan nombres accesibles.
- Revisión funcional de tabla y estados alternos automatizada. No se inventó
  un plan persistente en la UAT solo para capturarlos.

## UAT incremental pendiente

Adaptación a perfiles ADM/CON del contexto enlazado; aceptación humana pendiente:

| Caso | Acción / esperado | Estado |
|---|---|---|
| ADM-02/03 | Distingue OF elegida, propuesta inexistente y primer cálculo | PENDING |
| ADM-04 | Tras calcular revisa pieza/color, capacidad, pendiente y mangas totales en su viewport | PENDING |
| ADM-07 | Sin permiso solicita responsable autorizado, no intenta agregar a ciegas | PENDING |
| ADM-08/12 | Ver OF conserva formulario; comprende recálculo vs primer cálculo | PENDING |
| CON-02/11 | Consulta fallida no afirma ausencia; reintento recupera propuesta | PENDING |

RUN, participantes/equipo y aceptación no autoaprobados. No modifica gates de
la UAT de pesaje; este corte digital no requiere hardware propio.

## Omisiones y riesgos

- No se repitió scripts/test.ps1 completo; baseline/regresión focal proporcional.
  Fallos globales anteriores de ProductOnboarding siguen fuera del alcance.
- Backend, contratos Central–pesaje, sync, PostgreSQL omitidos: sin cambios.
- Capturas de tabla con plan, error, sin permiso y otros viewports pendientes
  del recorrido humano; comportamiento cubierto por componentes. No se declara
  UX-READY ni aceptación representativa por esa evidencia automática.
- Sin cálculo automático al liberar OF: se conserva generación explícita existente.
- Propuesta total de mangas es la del plan de OF por salida; no se afirma que
  sea la cantidad de mangas de una asignación parcial. Unidades son planificadas.

## Resultado y siguiente paso

Corrección funcional local qa_green; usuario calcula la propuesta como siguiente
paso UAT y revisa cantidades antes de agregar. Sin hechos de negocio creados por
el agente, sin reset ni despliegue remoto. Marcha blanca productiva no aplica.
Restricción: solo local; no reset, Supabase, Render ni hardware. Aceptación humana
pendiente; no se declara listo para planta.
