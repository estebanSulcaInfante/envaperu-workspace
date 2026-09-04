---
tipo: contexto-y-wireflow
estado: propuesta-pendiente-validacion
spec_phase: story
delivery_state: not_started
functional_validation: untested
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
ux_risk: high
uat_profiles: [ADM, CON]
fecha_creacion: 2026-09-02
relaciones:
  - "[[US-010M4_Creacion_Revisada_y_Anulacion_OT_Vacia]]"
---

# Contexto y wireflow propuesto — Recuperación de OT vacía

Actualización 2026-09-02: usuario autorizó excepción de implementación solo
local sin UX-READY. Se ejecutó revisión técnica en viewport 1163×654, con
capturas en outputs/uat-m4-2026-09-02. No equivale a sesión humana
representativa. [[REC_2026-09-02_Implementacion_OT_Vacia_M4]].

Basado en TPL_Contexto_Operativo_UI y TPL_Prototipo_Operativo_UI.

## Evidencia, persona y entorno

Observación de la UAT guiada local: usuario opera Central en navegador de
escritorio bajo perfil Said/Supervisor. Reporta facilidad de creación
accidental, no un error real en la OT actual. El DOM confirmó creación
directa y ausencia de recuperación de cabecera.

Lugar físico, frecuencia real, experiencia digital, interrupciones, EPP,
ruido, iluminación, distancia, tamaño de monitor, zoom y método de entrada
efectivo: no medidos. No se atribuyen al puesto real de Said por usar su perfil.
Viewport final y participantes representativos: pendientes. Propuesta de QA
local escritorio 1440×900 y 1163×654, no medidas de planta confirmadas.
Sin objeto físico ni periféricos en este corte. Red: Central local, no offline.

Error principal a evitar: anular una jornada equivocada o que ya tenga hechos.
Objetivo: revisar identidad y recuperar creación accidental sin borrar historia.

## Jerarquía propuesta

- Primaria: código OT, máquina, fecha, turno, estado y elegibilidad.
- Crear: botón abre revisión; confirmar es la única acción que crea.
- Anular: acción secundaria separada de «Agregar Trabajo de color»; abre
  confirmación con motivo, no ejecuta inmediatamente.
- Secundaria: maquinista predeterminado, aclarando que no fija todos los trabajos.
- Diagnóstico: referencias bloqueantes, detalle y versión sin competir con tarea.
- Éxito: «OT-… anulada. Su historial se conserva» y nueva creación disponible.
- Recuperación: volver sin efectos; conflicto obliga actualizar; incertidumbre
  no se presenta como éxito ni crea automáticamente una OT de reemplazo.

## Wireflow propuesto (no UI implementada)

| Estado | Información y acciones | Recuperación |
|---|---|---|
| Inicial | Formulario máquina/fecha/turno/persona, revisar creación | Editar datos |
| Revisión de creación | Resumen exacto; Volver / Confirmar creación | Volver conserva formulario |
| Creando | Envío en curso, sin doble envío | Resolver respuesta incierta |
| OT vacía lista | Datos OT; agregar trabajo como primaria, anular como secundaria | Volver al tablero |
| Confirmación de anulación | Identidad, «se conserva el historial», motivo; Volver / Anular OT | Foco al motivo; sin envío si vacío |
| Anulando | Acción en curso, controles protegidos | Reintento idempotente según contrato futuro |
| Anulada | Estado visible y motivo/actor/fecha; no agregar ni iniciar | Crear nueva OT con otro código |
| Bloqueada | Razón concreta: trabajos/hechos/estado o falta de permiso | Consultar vínculos; no ofrecer borrado en cascada |
| Conflicto | OT cambió desde la revisión | Actualizar y volver a decidir |
| Desconectada/incierta | Sin confirmación autoritativa; no afirmar anulación | Consultar estado al reconectar, sin duplicar |

Variantes: nombres largos, motivo vacío, volver, teclado, sin permiso,
trabajo agregado concurrentemente, respuesta perdida y OT anulada histórica.
Sesión temprana representativa: pendiente. No se ha aprobado este wireflow.
Perfiles propuestos: ADM-01…12 y CON-01…12; su selección no constituye aún
una UAT instanciada. CON no autoriza captura offline ni cambios de custodia.

## Siguiente gate

Validar alcance/permisos y luego prototipo con usuario representativo, o
registrar excepción humana explícita para implementación exploratoria local.
Mantener no_habilitar_en_planta en ambos casos hasta aceptación correspondiente.
