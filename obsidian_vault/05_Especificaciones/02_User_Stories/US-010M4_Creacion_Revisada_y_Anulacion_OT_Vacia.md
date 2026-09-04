---
tipo: user-story
subtipo: historia-hija
estado: aprobada-exploracion-local
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
ux_risk: high
contexto_operativo: "[[CTX_PROTO_US-010M4_Recuperacion_OT_Vacia]]"
uat_profiles: [ADM, CON]
fecha_creacion: 2026-09-02
relaciones:
  - "[[Creacion_Accidental_y_Anulacion_OT_Vacia]]"
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[Registro_Diario]]"
  - "[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]"
  - "[[Matriz_Roles_Capacidades_SCM_Produccion]]"
---

# US-010M4 — Creación revisada y anulación de OT vacía

## Decisión humana 2026-09-02

El usuario respondió «Si» a la confirmación conjunta de alcance Q2, permisos
Q1 y excepción Q3: implementación exclusivamente en UAT local, UX provisional
y no_habilitar_en_planta. Quedan aprobados los criterios propuestos siguientes
para ese entorno; las preguntas/checklists al final conservan el contexto de
refinamiento anterior. No se aprueba anular OT-000001 ni reiniciar sus datos.
Contrato y ejecución: [[TS-010M4_Anulacion_OT_Vacia]] y [[DEV-010M4_Anulacion_OT_Vacia]].

## Necesidad

Como coordinador autorizado de jornadas, quiero revisar los datos antes de
crear una OT y recuperar una creación accidental sin borrar el historial,
para no dejar jornadas erróneas bloqueando máquina, fecha y turno.

## Evidencia y límites de autoridad

Fuente: conversación de UAT local del 2026-09-02 y Draft enlazado.
Se consultaron Registro_Diario, decisión OT/Trabajo del 2026-08-08, matriz de
roles, `OtMangasScm.jsx`, `scm_ot_service.py` y rutas SCM.
La decisión de cancelación OP del 2026-08-28 es un antecedente de auditoría,
no autorización para trasladar sus permisos o estados a OT.

No se encontró una política de permisos para anular una cabecera OT. Por ello
los criterios siguientes son una propuesta pendiente de validación humana;
no constituyen reglas nuevas aprobadas de planta.

## Primera porción vertical propuesta

1. Revisar máquina, fecha, turno y maquinista predeterminado antes de crear.
2. Acción explícita «Anular OT» con motivo obligatorio y confirmación.
3. Admitir únicamente OT FABRICACION normalizada, PLANIFICADA, nunca iniciada,
   sin trabajos (ni siquiera anulados), mangas, pesajes u otras vinculaciones
   operativas. Conservar actor/evento de creación no impide anular.
4. Conservar ID, código, datos originales y evidencia de anulación: motivo,
   actor, fecha, estado previo/nuevo y versión. Sin borrado ni reapertura.
5. Permitir crear una nueva OT para la combinación liberada; nuevo código,
   nunca reciclaje del anterior. La anulada sigue consultable y no ejecutable.
6. Propuesta de capacidad separada OT_ANULAR: Supervisor, Jefe de Producción
   y Gerente General, sin restricción al creador y sin segunda aprobación en
   este corte vacío. Requiere decisión explícita Q1.

Fuera de alcance: anular OT utilizadas, anulación en cascada, editar cabecera,
compensar inventario, mangas/QR, OT legacy, Armado, cambios de permisos ajenos,
reiniciar la base UAT, actuar sobre la OT válida actual o desplegar a planta.

## Escenarios propuestos para aprobación

| ID | Dado / Cuando / Entonces |
|---|---|
| M4-01 | Datos válidos / pulsar crear / abrir revisión sin crear aún; volver conserva los datos. |
| M4-02 | Revisión correcta / confirmar / crear una sola OT y mostrar su código; doble envío no duplica. |
| M4-03 | OT vacía elegible y actor autorizado / confirmar motivo / ANULADA con auditoría, sin modificar OP/OF. |
| M4-04 | Motivo vacío / intentar confirmar / impedir envío y explicar el dato faltante. |
| M4-05 | Perfil sin permiso / intentar UI o API / no permitir anulación, sin mutación. |
| M4-06 | OT iniciada, utilizada o no normalizada / intentar anular / bloquear con motivo y conservar historia. |
| M4-07 | Trabajo agregado o versión cambiada durante confirmación / enviar / conflicto sin anulación; actualizar y revisar. |
| M4-08 | Respuesta perdida / reintentar misma operación / un solo evento, sin éxito anticipado. |
| M4-09 | OT anulada / crear nueva para misma jornada / código nuevo, antigua consultable, sin admitir trabajos en la anulada. |
| M4-10 | Formulario de anulación / volver sin confirmar / OT intacta y foco recuperado. |

Inventariar todas las referencias y proteger concurrencia entre anulación,
creación de trabajo e inicio es requisito previo a cerrar la Tech Spec.

## Operabilidad y UAT propuesta

Contexto y wireflow en [[CTX_PROTO_US-010M4_Recuperacion_OT_Vacia]].
Riesgo high por acción difícil de revertir; no se declara UX-READY.
Perfiles ADM v1 y CON v1. Modalidad funcional/operativa local, sin impresora,
balanza ni objeto físico en este incremento vacío. La UAT de pesaje mantiene
sus propios gates físicos pendientes.

Dataset futuro aislado: una OT vacía, una con trabajo, una iniciada y un
usuario sin permiso; no utilizar OT-000001 como objetivo de anulación.
Pruebas futuras: backend de estados/permisos/auditoría; concurrencia real en
PostgreSQL; componentes UI, revisión visual y sesión humana. BASELINE/RED
todavía no ejecutados: no existe autorización consolidada para desarrollo.

## Preguntas y gates (registro histórico del refinamiento)

- Q1: ¿Se aprueban los roles propuestos y anulación directa de OT vacía,
  sin limitar al creador ni exigir un segundo aprobador?
- Q2: ¿Se aprueba limitar el primer corte a OT nunca utilizadas, y la revisión
  previa a la creación, dejando las utilizadas fuera de alcance?
- Q3: Falta UX-READY. ¿Se autoriza expresamente una implementación exploratoria
  solo local para evaluarla en UAT, manteniendo UX provisional y prohibición
  de habilitación en planta? Alternativa: validar primero el prototipo.

- [x] Necesidad, evidencia y propuesta trazables.
- [x] Fuera de alcance y protección de la UAT actual explícitos.
- [ ] READY-FOR-DESIGN: resolver Q1/Q2.
- [ ] UX-READY o excepción humana local explícita Q3.
- [ ] Tech Spec con contratos, pruebas, baseline y primera RED.
- [ ] Approved for Dev; luego BASELINE → RED → GREEN → REFACTOR.
- [ ] UAT ejecutable con preguntas ADM/CON expandidas, QA y recibo.

## Estado al entregar el incremento local

Q1/Q2/Q3 aprobadas explícitamente por el usuario. TS y DEV consolidados;
implementación y QA focal ejecutadas. UAT humana preparada en
[[UAT_US-010M4_OT_Vacia]], sin resultados humanos aún.
Recibo: [[REC_2026-09-02_Implementacion_OT_Vacia_M4]].
El checklist anterior no representa el estado actual; conserva la secuencia
de decisiones. UX permanece provisional por excepción y sin habilitar planta.
