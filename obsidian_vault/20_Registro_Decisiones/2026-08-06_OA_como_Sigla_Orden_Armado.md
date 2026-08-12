---
tipo: decision_arquitectura
estado: aprobada
fecha: 2026-08-06
tags: [scm, lenguaje-ubicuo, armado, oa, migracion]
relacionados:
  - "[[2026-08-06_Armado_como_Terminologia_Canonica]]"
  - "[[Orden_Armado]]"
  - "[[Matriz_Roles_Capacidades_SCM_Produccion]]"
---

# OA como sigla de Orden de Armado

## Decision

La sigla canonica de **Orden de Armado** es **OA**. Se utiliza en toda
superficie funcional y tecnica nueva: interfaz, API, permisos, errores,
auditoria, codigos de documentos, etiquetas, pruebas y documentacion.

Los documentos nuevos usan el formato `OA-000001`. Cuando una OA se ejecuta
mediante una OT, las etiquetas muestran la relacion `OA - OT` y emplean el
campo `oa_ot`.

## Migracion

La migracion versionada:

- renombra las capacidades a `OA_VER`, `OA_LIBERAR`, `OA_EJECUTAR` y
  `OA_ANULAR`, conservando sus asignaciones por rol;
- cambia el correlativo a `ORDEN_ARMADO` con prefijo `OA` sin reiniciar su
  siguiente valor;
- actualiza los codigos de las ordenes de armado y sus mangas existentes;
- normaliza los tipos de evento de auditoria asociados.

Las migraciones Alembic anteriores conservan su contenido original porque
son el historial reproducible de versiones ya desplegadas. La nueva migracion
es la unica responsable de llevar cualquier base existente al contrato OA.

## Criterios de aceptacion

1. Ninguna pantalla o guia vigente muestra la sigla anterior.
2. El backend autoriza las ordenes de armado exclusivamente con capacidades
   `OA_*`.
3. Toda orden de armado creada despues del cambio recibe un codigo `OA-*`.
4. Una base actualizada conserva roles, correlativos y relaciones existentes.
5. Las pruebas de frontend, backend y migraciones validan el contrato OA.
