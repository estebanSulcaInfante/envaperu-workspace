---
tipo: approved-for-dev
estado: desplegado-pendiente-uat
tags: [scm, frontend, backend, roles, capacidades, workspace, tdd]
relaciones:
  - "[[US-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[Preferencia_Workspace_Rol]]"
  - "[[Catalogo_Roles_Capacidades_Workspace]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# DEV-010N2: Inicio parametrizado por rol y capacidades

## Resultado implementado

N2 reemplaza la portada estática por una proyección única del workspace y
agrega administración gobernada de roles, capacidades, rol principal y
preferencias de Inicio. Las preferencias ordenan y presentan accesos; nunca
conceden una capacidad ni sustituyen la autorización del backend.

## Backend

- persistencia versionada del foco, acceso principal y preferencias del rol;
- un rol principal explícito por trabajador, sin alterar la unión de
  capacidades de sus demás roles activos;
- backfill no ambiguo: se asigna principal solo cuando existe exactamente un
  rol activo;
- API transaccional y auditada para capacidades, roles y rol principal;
- código de rol inmutable, referencias `RESTRICT`, control optimista de versión
  y errores estructurados;
- autorización administrativa tanto en `local_actor` como en Supabase; en
  Supabase se ignora `X-Actor-Id` y manda la identidad JWT;
- RLS habilitado y privilegios de `anon`/`authenticated` revocados en las cinco
  tablas de autorización protegidas.

## Frontend

- `buildActorWorkspace()` es la proyección pura compartida;
- Inicio, sidebar, breadcrumb y redirecciones consumen la misma proyección;
- `task` es opt-in y `home.workspace` nunca se propone a sí mismo;
- Inicio muestra acceso principal, funciones fijadas y el resto agrupado por
  área, sin truncar la lista;
- el acceso principal es un CTA y no una redirección automática;
- administración real de roles/capacidades con búsqueda, agrupación humana,
  previsualización sin suplantación y saneamiento de preferencias retiradas;
- carga y error de identidad permanecen fail-closed.

## Invariantes verificadas

1. Todos los roles activos aportan capacidades.
2. Solo el rol principal aporta foco, acceso principal y preferencias.
3. Una función inelegible o desconocida se excluye y genera advertencia.
4. La Guía SCM es el fallback; Inicio nunca es su propio destino.
5. Una preferencia no amplía `requiredAny` ni la madurez de una función.
6. La previsualización no cambia sesión, actor ni permisos.
7. Crear o editar roles exige `AUTORIZACION_SCM_ADMINISTRAR`.

## Evidencia automática local

- backend: **324 pruebas aprobadas**, una omitida y cero fallos;
- frontend: **50 archivos / 212 pruebas verdes**;
- build productivo verde (`assets/index-BBiW6qUL.js`);
- lint con cero errores y una advertencia preexistente en
  `ProductionPlanningScm.jsx:178`;
- PostgreSQL real: migración, backfill, unicidad parcial, FK/índices, RLS/ACL,
  concurrencia optimista, downgrade fail-closed y re-upgrade cubiertos;
- autenticación Supabase focal: prefijos administrativos protegidos y cabecera
  local incapaz de suplantar al actor JWT.

La evidencia humana y el despliegue se controlan en
[[UAT_TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]].

## Despliegue Render / Supabase — 2026-08-08

- backend N2 `8d1318b`, deploy `dep-d9rrt2tbedkc73ccnobg`;
- migración `f79b8c4d0e31` aplicada antes de iniciar Gunicorn;
- corrección de textos heredados `6f5f488`, migración `f80c9d5e1a42`, deploy
  `dep-d9rs11dbedkc73ccusu0`;
- frontend `51a7785`, deploy `dep-d9rru2tbedkc73ccpgq0`, bundle remoto
  `assets/index-DgQZMgPW.js`;
- `/api/health`: base disponible y estado `ok`;
- `/api/catalogo/capacidades` sin identidad: `401`;
- smoke autenticado: `/auth/me`, Inicio, catálogo de roles/capacidades y preview
  cargan sin selector de perfil productivo.

La migración `f80` repara únicamente etiquetas con mojibake en
`rol_operativo.nombre` y `scm_capacidad.nombre`; no cambia códigos, permisos,
asignaciones ni preferencias.
