---
tipo: decision_negocio
estado: aceptada
tags: [scm, empaque, permisos, jefaturas, auditoria]
fecha: 2026-08-05
---

# Jefaturas publican reglas de empaque directamente

## Decisión

Los roles `JEFE_*`, `GERENCIA` y `GERENTE_GENERAL` pueden publicar directamente
un borrador propio de regla de empaque mediante `EMPAQUE_PUBLICAR_DIRECTO`.
Esto alinea el gobierno de empaque con estructuras BOM y rutas.

## Guardas conservadas

- la revisión debe permanecer en `BORRADOR` y con versión vigente;
- perfil y contenedor deben estar activos;
- el acomodo máximo debe declararse validado mediante prueba física;
- objetivo, máximo por acomodo, tara, margen y límites de peso deben ser viables;
- la publicación congela valores físicos, genera hash y evento auditable;
- una publicación nueva retira la revisión aprobada anterior.

Los perfiles sin esta capacidad mantienen aprobación por una identidad distinta.
