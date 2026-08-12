---
tipo: decision
estado: aceptada
tags: [scm, rutas, autorizacion, jefaturas, ux]
fecha_creacion: 2026-08-04
fecha_actualizacion: 2026-08-04
---

# Jefaturas publican rutas directamente

## Decisión

Los perfiles `JEFE_*`, `GERENCIA` y `GERENTE_GENERAL` pueden administrar y
publicar directamente una ruta en borrador mediante
`RUTA_PUBLICAR_DIRECTO`. La publicación valida el grafo, el terminal único,
centros activos, salidas y compatibilidad con las estructuras aprobadas;
retira la revisión anterior y conserva el evento auditable.

Los demás perfiles mantienen la aprobación por un actor distinto del creador.
La excepción no se extiende a correcciones u otros flujos con segregación
obligatoria.

La clave estable de una operación pertenece a la implementación del grafo. Se
genera automáticamente, permanece estable durante la edición y no se solicita
al usuario.
