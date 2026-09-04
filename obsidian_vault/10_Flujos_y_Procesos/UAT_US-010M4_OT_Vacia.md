---
tipo: uat
uat_id: UAT-M4
estado: preparada-pendiente-ejecucion-humana
modalidades_uat: [funcional, operativa]
historia: "[[US-010M4_Creacion_Revisada_y_Anulacion_OT_Vacia]]"
tech_spec: "[[TS-010M4_Anulacion_OT_Vacia]]"
dev: "[[DEV-010M4_Anulacion_OT_Vacia]]"
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
ux_risk: high
contexto_operativo: "[[CTX_PROTO_US-010M4_Recuperacion_OT_Vacia]]"
perfiles_uat: [ADM-v1, CON-v1]
fecha: 2026-09-02
---

# UAT M4 — Revisar creación y anular OT vacía

## Identidad y preparación

RUN humano: pendiente; responsable funcional, operador representativo y
observador: por registrar antes de ejecutar. Entorno exclusivamente local:
Central 127.0.0.1:5174 / API 5100, workspace con cambios sin commit.
Versión/evidencia técnica: [[REC_2026-09-02_Implementacion_OT_Vacia_M4]].
El ensayo guiado previo identifica una necesidad; no acepta esta solución.

Objeto: cabecera digital. Sin bolsa, QR, peso, impresión, stock ni hardware;
physical_uat not_required para M4, sin alterar el pending de la UAT de pesaje.
Pantalla observada técnica 1163×654; participante registra equipo, zoom y método
de entrada real. Condiciones de planta no medidas. Perfiles ADM y CON v1.
Modo CON bloqueo-seguro: sin acuse no afirmar creación/anulación; sin offline.

Preservar OP/OF/OT-000001 del recorrido de pesaje. Para casos que mutan, elegir
con el usuario una jornada libre de prueba distinta; no usar la OT válida
como sacrificable. Registrar IDs/estado antes y después. Repetir con nuevos
códigos; no Reset. Si no existe dataset negativo, prepararlo en base de prueba
aislada; no fabricar ni imprimir para crear el caso negativo.

## Guion por escenario

Todos los resultados humanos siguientes comienzan PENDING.

| BDD | Preparación y acción | Resultado observable / evidencia |
|---|---|---|
| M4-01 | Said, jornada libre: Crear OT, revisar, Volver | Ninguna OT creada; formulario conserva datos; captura revisión |
| M4-02 | Reabrir revisión y confirmar | Una OT, código nuevo, datos coinciden; registrar ID |
| M4-04/10 | Abrir Anular OT; motivo vacío; Volver | Confirmación deshabilitada, OT intacta y foco retorna |
| M4-03 | OT de prueba vacía; motivo «UAT M4: creación accidental»; confirmar | ANULADA, mismo código, actor/motivo/fecha visibles; evento único |
| M4-09 | Consultar anulada y crear otra misma jornada | Anterior consultable sin agregar trabajo; nueva identidad y código; una anulada + una planificada no activa el aviso de coincidencia |
| M4-05 | Ximena/Planificación sin OT_ANULAR | No ofrece acción; llamada no autorizada rechazada en ensayo técnico |
| M4-06 | OT aislada con trabajo, incluso anulado; otra iniciada | Bloqueo explicado, ningún hijo ni peso alterado |
| M4-07 | Abrir confirmación y cambiar OT desde otra sesión | Conflicto, sin anulación, Consultar estado permite revisar |
| M4-08 | Ensayo aislado con pérdida de respuesta y reintento | No anuncia éxito sin acuse; misma clave produce un evento |

Detener si apunta a otra base, se alteran documentos fuera del caso, se
ofrece anular una utilizada o aparece éxito durante incertidumbre.

## Preguntas ADM v1 instanciadas

Preparación común: escritorio, actores y dataset anteriores. En cada fila
registrar PASS/FAIL/PENDING, captura/ID, ayuda requerida y hallazgo.

| Fuente | Pregunta / criterio concreto | Evidencia y esperado | Estado |
|---|---|---|---|
| ADM-01 | ¿Encuentra la revisión y Anular OT sin URL dictada? | Recorrido sin ayuda crítica | PENDING |
| ADM-02 | ¿Reconoce máquina/fecha/turno/código antes de actuar? | Captura y explicación correcta | PENDING |
| ADM-03 | ¿La acción de anular queda separada de agregar trabajo? | No confunde ambas tareas | PENDING |
| ADM-04 | ¿Diálogos y botones caben en su viewport sin overflow global? | Captura equipo/zoom reales | PENDING |
| ADM-05 | ¿Distingue jornada sin OT de una OT ANULADA histórica? | Consulta ambas; estado explicado | PENDING |
| ADM-06 | ¿Reconoce que actualizar no confirma una anulación incierta? | Captura estado/API coherentes | PENDING |
| ADM-07 | ¿Said tiene acción y Ximena no, manteniendo consulta autorizada? | Comparación de perfiles | PENDING |
| ADM-08 | ¿Entiende alcance, permanencia del historial y motivo obligatorio? | Volver sin efecto y confirmar caso aislado | PENDING |
| ADM-09 | ¿Tab/Shift+Tab y foco permiten volver y confirmar conscientemente? | Registrar teclado/foco y nombre accesible | PENDING |
| ADM-10 | ¿Conflicto conserva contexto y lleva a revisar antes de otra decisión? | Dos sesiones; ningún efecto obsoleto | PENDING |
| ADM-11 | ¿Distingue PLANIFICADA, ANULADA y envío en curso? | Explicación del usuario y captura | PENDING |
| ADM-12 | ¿Detalle/volver conserva fecha, turno e identidad histórica? | Ruta/filtros y OT consultada | PENDING |

## Preguntas CON v1 instanciadas

Fallas se provocan en ensayo aislado, nunca deteniendo la UAT de otra persona.

| Fuente | Pregunta / criterio concreto | Evidencia y esperado | Estado |
|---|---|---|---|
| CON-01 | ¿Aplica bloqueo-seguro, sin hechos offline? | Explicación conforme a TS M4 | PENDING |
| CON-02 | ¿Sin Central antes de cargar muestra error y no contexto ficticio? | Captura y cero mutación | PENDING |
| CON-03 | ¿Caída antes de confirmar impide afirmar anulación? | Estado/diálogo sin éxito | PENDING |
| CON-04 | ¿Respuesta perdida mantiene incertidumbre e intención de reintento? | Clave y evento, un solo efecto | PENDING |
| CON-05 | ¿Recargar consulta estado remoto sin reenviar automáticamente? | Antes/después de recarga | PENDING |
| CON-07 | ¿Doble envío/reintento conserva un único evento/código? | ID operación, conteo de eventos | PENDING |
| CON-08 | ¿Versión nueva bloquea la decisión vieja y no libera otra jornada? | Conflicto/reconsulta | PENDING |
| CON-09 | ¿Solo se muestra ANULADA tras confirmación/lectura autoritativa? | Capturas incertidumbre/éxito | PENDING |
| CON-10 | ¿No informa producción/stock disponible al anular? | Mensaje solo afecta cabecera, sin impresión | PENDING |
| CON-11 | ¿El mensaje permite reintentar o consultar sin adivinar? | Observar recuperación sin ayuda crítica | PENDING |
| CON-12 | ¿La evidencia permite soporte sin secretos? | Código, versión y error saneados | PENDING |

CON-06 descartado: no objeto físico ni custodia en este incremento. ADM-12
exportación descartada (no hay exportación nueva); sí se prueba detalle/filtros.
PES, LEC, MQR e IMP descartados: no medición, dispositivo compartido confirmado,
multi-QR ni emisión. BASE preguntas físicas 3/4/7 no aplican; sí se registran
actor/lugar, primaria, acción, efecto, recuperación y asistencia por caso.

## Aceptación humana

### Hallazgo del recorrido guiado — 2026-09-02

El usuario anuló OT-000001 (motivo «Prueba UAT») y creó OT-000002 para la misma
máquina/fecha/turno. Son acciones del usuario posteriores a la preparación que
pedía preservar la OT original. La API confirmó ANULADA v2 y PLANIFICADA v1,
respectivamente. Reportó aviso falso «2 OT coinciden»; autorizó corregirlo.
Se excluyó solo ANULADA del aviso, manteniendo historial y ambas identidades.
Revisión técnica local sin falsa alerta y 58 pruebas focales verdes:
[[REC_2026-09-02_Aviso_Coincidencia_OT_Anulada]]. No implica aceptación humana
del ajuste ni completa los perfiles ADM/CON. Continuar el recorrido con OT-000002.

Registrar participante/rol, fecha, equipo, RUN, ayuda, dudas y evidencia por fila.
Aceptar funcionalidad y operabilidad por separado. Ningún PASS automático del
recibo completa esta tabla. Riesgos residuales/casos no ejecutados conservan
PENDING. M4 no autoriza planta; sigue la excepción local aprobada.
