---
tipo: draft
estado: en-refinamiento
spec_phase: draft
delivery_state: not_started
functional_validation: untested
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
fecha_creacion: 2026-09-02
relaciones:
  - "[[US-010M4_Creacion_Revisada_y_Anulacion_OT_Vacia]]"
---

# Creación accidental y anulación de OT vacía

## Evidencia de la UAT guiada local

El usuario creó correctamente OT-000001 y aclaró que no se equivocó. Señaló
que es fácil crear una OT con un botón y preguntó por la recuperación ante
una creación accidental. Solicitó implementar la brecha siguiendo el pipeline
antes de continuar el ensayo de pesaje.

OT de referencia, no objetivo de anulación:
`3cb13d93-36eb-4293-8bf5-ca3d7047ec26`, INY-01, 2026-09-02, DIA,
PLANIFICADA, cero trabajos en la última consulta de la UI.

## Hechos y propuesta

- La UI actual crea la cabecera directamente y no ofrece anularla.
- El dominio contempla ANULADA; no hay comando de anulación de cabecera SCM.
- `transition_ot` no permite cerrar directamente una cabecera vacía PLANIFICADA.
- La creación ya excluye ANULADA al comprobar duplicidad máquina/fecha/turno.
- Anular un Trabajo de color no equivale a anular su OT.

Propuesta, no decisión aprobada: revisión antes de crear; anulación auditada
solamente de cabeceras normalizadas vacías, no iniciadas y sin vinculaciones
operativas. Conservar toda OT utilizada. No iniciar/cerrar ficticiamente ni
eliminar registros. Alcance y permisos por validar en la historia M4.

La petición no autoriza anular OT-000001, reiniciar la UAT ni cambiar producción.
