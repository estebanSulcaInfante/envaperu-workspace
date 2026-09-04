---
tipo: decision
estado: aprobada-solo-uat-local
fecha: 2026-09-02
ux_validation: provisional
release_constraint: no_habilitar_en_planta
relaciones:
  - "[[US-010M4_Creacion_Revisada_y_Anulacion_OT_Vacia]]"
  - "[[Registro_Diario]]"
---

# Decisión M4 — Recuperación de creación accidental de OT

El usuario aprobó explícitamente alcance, roles y excepción UX para implementar
y evaluar solo en UAT local. La OT-000001 del recorrido fue creada correctamente
y no es objetivo de anulación.

- Revisar datos antes de confirmar la creación de cabecera.
- OT_ANULAR para Supervisor, Jefe de Producción y Gerente General; no exige
  ser creador ni segunda aprobación en este corte.
- Solo FABRICACION normalizada, PLANIFICADA y nunca iniciada/cerrada, sin
  trabajos ni vinculaciones operativas, incluso hijos ya anulados.
- Motivo obligatorio, versionado, idempotencia y auditoría; no borrar ni
  reciclar código, ni anular hijos o compensar hechos automáticamente.
- ANULADA conserva consulta y permite otra OT de la misma máquina/fecha/turno
  con código nuevo; no acepta nuevos trabajos/inicio.
- OT utilizadas, legacy y Armado quedan fuera del corte.

La excepción permite implementar sin UX-READY previo, pero no aprueba UX,
UAT humana ni despliegue/uso en planta. La habilitación local de capacidad es
aditiva y específica; no se aplicaron migraciones/grants a otra base.
