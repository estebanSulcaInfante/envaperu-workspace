---
tipo: decision
estado: reemplazada-parcialmente
fecha: 2026-08-04
tags: [scm, autorizacion, segregacion, superusuario, auditoria]
relaciones:
  - "[[Matriz_Roles_Capacidades_SCM_Produccion]]"
  - "[[Guia_Roles_y_Permisos_SCM_Piloto]]"
  - "[[UAT_02_Maestros_e_Imagenes]]"
---

# Gerente General no omite la segregación de funciones

> [!warning] Reemplazo parcial
> La decisión [[2026-08-04_Jefaturas_publican_estructuras_directamente]]
> reemplaza esta regla únicamente para publicar revisiones BOM. Continúa
> vigente para correcciones, aperturas y demás operaciones con control de
> cuatro ojos explícito.

## Decisión

`GERENTE_GENERAL` conserva todas las capacidades funcionales del piloto, pero
no puede aprobar una revisión que él mismo creó.

## Motivo

Una capacidad define qué clase de acción puede ejecutar una identidad. La
segregación evalúa si esa identidad puede ejecutarla sobre un registro
concreto. Permitir que el creador apruebe su propio registro eliminaría el
control de cuatro ojos y reduciría la trazabilidad a una sola decisión.

## Consecuencias

- Gerente General puede aprobar registros creados por otros participantes.
- Para una UAT que pruebe aprobaciones se necesitan dos identidades activas.
- Un rol con todas las capacidades no es una puerta trasera de integridad.
- Una contingencia futura debe ser explícita, excepcional, motivada y
  auditable; no se deriva automáticamente del rol.
- Rechazar y descartar revisiones son transiciones de estado; no implican
  eliminación física.
