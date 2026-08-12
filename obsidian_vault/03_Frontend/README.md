---
tipo: modulo
estado: activo
tags: [frontend, ui, ux, arquitectura]
fecha_creacion: 2026-07-15
---

# Frontend

Este módulo mantiene el mapa de la experiencia de usuario que ya existe, la que se encuentra en mock y la que todavía depende de contratos o APIs. Su objetivo es evitar que el crecimiento del frontend quede repartido únicamente entre historias de usuario y código.

## Regla de Autoridad

La documentación de este directorio **no redefine reglas de negocio**. La autoridad se conserva en este orden:

1. Las decisiones validadas y escenarios de las historias de usuario.
2. Los contratos, permisos y transacciones de las Tech Specs.
3. Las fichas de vistas y patrones de este módulo, que reflejan las dos capas anteriores.
4. La implementación del frontend.

Si una ficha visual contradice una US o una TS aprobada, se corrige la ficha visual. No se toma el mock como fuente de verdad del dominio.

## Estados de Madurez

| Estado | Significado |
| :--- | :--- |
| `concepto` | Se conoce el flujo y su arquitectura de información, pero aún no existe una pantalla funcional. |
| `mock` | La vista funciona con fixtures; las escrituras sin API permanecen bloqueadas. |
| `api-parcial` | Parte de las consultas o comandos usa contratos reales y el resto se identifica explícitamente. |
| `integrado` | La vista usa APIs reales, permisos y manejo de errores definidos por su TS. |
| `legacy` | Existe, pero todavía no se ha alineado con el modelo objetivo. |

Estos estados describen la madurez de una vista, no el estado de aprobación de su historia de usuario.

## Estructura

- [[03_Frontend/Vistas/_index|Vistas]]: pantallas, rutas, actores, estados, comandos y cobertura.
- [[03_Frontend/Componentes/_index|Componentes]]: patrones reutilizables y convenciones de interacción.
- [[Arquitectura_Workspace_SCM_por_Areas]]: arquitectura vigente por áreas,
  madurez, workspace por capacidades y compatibilidad de rutas.
- [[Arquitectura_Navegacion_Por_Procesos]]: antecedente histórico supersedido.
- [[Arquitectura_Guia_SCM_Markdown]]: fuente Markdown, estados del piloto y sincronización entre UAT y guía de usuario.
- [[Autenticacion_Supabase_y_Experiencia_por_Rol]]: inicio y cierre de sesión, identidad productiva y modo UAT local.
- [[SCM_Frontend_Overview_US-010]]: mapa visual del flujo SCM iniciado por US-010.
- [[Patron_Capacidades_API_y_Mocks]]: significado de mock, candado, permiso y disponibilidad por estado.
- [[Patron_Tablas_Filtros_y_Omnibusqueda]]: barra común, filtros y reglas para datos locales o paginados.

## Actualización Mínima

Cada vista nueva o reformulada debe registrar:

- historia y Tech Spec relacionadas;
- rutas y actores;
- fuente de datos (`MOCK`, `API` o mixta);
- estados visibles, incluido vacío, carga y error;
- comandos habilitados, bloqueados por API o restringidos por permiso;
- escenarios ATDD/BDD representados;
- lagunas conocidas sin inventar decisiones de negocio.
