---
tipo: decision
estado: aceptada
fecha: 2026-08-04
tags: [scm, estructuras, bom, jefaturas, gerencia, auditoria]
relaciones:
  - "[[Matriz_Roles_Capacidades_SCM_Produccion]]"
  - "[[Guia_Roles_y_Permisos_SCM_Piloto]]"
  - "[[UAT_02_Maestros_e_Imagenes]]"
---

# Jefaturas publican estructuras directamente

## Decisión

Los perfiles `JEFE_*`, `GERENCIA` y `GERENTE_GENERAL` pueden administrar un
borrador BOM y publicarlo directamente mediante
`ESTRUCTURA_PUBLICAR_DIRECTO`, sin enviarlo a una aprobación separada.

Los demás perfiles con `ESTRUCTURA_ADMINISTRAR` conservan el flujo **Enviar a
aprobación** y requieren un actor distinto con `ESTRUCTURA_APROBAR`.

## Controles conservados

- control de versión;
- componentes obligatorios, activos y de clases válidas;
- prevención de ciclos;
- evento `STRUCTURE_PUBLISHED_DIRECTLY`;
- creador, publicador y fechas auditables;
- retiro automático de la revisión aprobada anterior;
- historial inmutable y eliminación física bloqueada.

## Alcance

Esta decisión aplica a estructuras BOM. No elimina la segregación requerida
por correcciones, aperturas de inventario, excepciones de pesaje u otros flujos
que declaren solicitante y aprobador distintos.
