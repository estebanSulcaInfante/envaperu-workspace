---
tipo: tech-spec
estado: desplegada-pendiente-uat
tags: [scm, frontend, backend, roles, capacidades, workspace, postgresql, tdd]
relaciones:
  - "[[US-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[TS-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
  - "[[2026-08-08_Arquitectura_de_Informacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[Autenticacion_Supabase_y_Experiencia_por_Rol]]"
  - "[[Baseline_TS-010N_2026-08-08]]"
  - "[[DEV-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[UAT_TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# TS-010N2: Inicio parametrizado por rol y capacidades

## 1. Objetivo técnico

Derivar la experiencia completa desde `WorkspaceFeature` y las capacidades
efectivas del actor, incorporando preferencias gobernadas por rol y rol
principal explícito. Eliminar las constantes frontend `ROLE_EXPERIENCE`,
`ROLE_PRIORITY`, `TASKS` y el truncamiento `slice(0, 6)`.

N2 depende de que N1 haya congelado claves estables de función.

## 2. Baseline de ingreso

Antes del primer RED:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test.ps1 -Component backend
cd .\frontend
npm test -- --run
npm run lint
npm run build
```

Las pruebas de migración se ejecutan adicionalmente contra PostgreSQL real.
El frontend de ingreso ya quedó verde con 38 archivos/168 pruebas, lint sin
errores y build exitoso en [[Baseline_TS-010N_2026-08-08]]. La suite backend y
PostgreSQL debe repetirse inmediatamente antes del RED de N2.

Hardening N1.1 posterior al baseline: 44 archivos / 190 pruebas verdes, lint
sin errores y build productivo verde. Incluye guarda unificada por
`feature_key`, rutas de área por capacidad, carga de identidad fail-closed,
navegación responsive y accesibilidad base. Este hardening es prerrequisito
funcional de N2 y no sustituye sus escenarios N2-01…N2-09.

### 2.1 Decisiones UX congeladas para N2

- `workspace_start_feature` define el acceso principal mostrado en Inicio; no
  redirige automáticamente después del login ni impide abrir Inicio.
- Una función solo es una tarea de Inicio cuando declara `task: true` de forma
  explícita. El valor por defecto es `false`; `home.workspace` nunca se proyecta
  como tarea para evitar autorreferencia.
- Inicio muestra un bloque breve de funciones fijadas/prioritarias y agrupa el
  resto por área en una lista compacta. No recorta ni oculta funciones elegibles.
- Título, descripción y CTA deben ser neutrales respecto a consultar o editar,
  salvo que exista metadata específica compatible con las capacidades reales.
- Las advertencias de principal ausente, clave retirada o preferencia inelegible
  son datos estructurados de la proyección, no textos inferidos en `RoleHome`.
- El sidebar, los breadcrumbs, las guardas y el Inicio consumen el mismo registro
  de funciones; N2 no introduce un segundo catálogo de rutas.

## 3. Persistencia

### `rol_operativo`

Agregar:

| Campo | Tipo | Regla |
|---|---|---|
| `workspace_focus` | `TEXT NULL` | descripción breve para Inicio |
| `workspace_start_feature` | `VARCHAR(80) NULL` | clave estable; no URL |
| `version` | `INTEGER NOT NULL DEFAULT 1` | concurrencia optimista |

`workspace_start_feature` no tiene FK porque el registro vive en frontend. Una
clave desconocida es dato tolerable y se ignora al proyectar.

### `trabajador_rol`

Agregar `es_principal BOOLEAN NOT NULL DEFAULT FALSE` y un índice único parcial
por `trabajador_id WHERE es_principal`. La misma asociación N:M conserva todos
los roles que aportan capacidades.

Backfill:

- trabajador con exactamente un rol activo: ese rol queda principal;
- trabajador con cero o varios roles: queda sin principal y se marca pendiente;
- no se elige por ID, nombre o jerarquía hardcodeada.

### `scm_rol_workspace_preferencia`

| Campo | Regla |
|---|---|
| `rol_operativo_id` | FK `RESTRICT`, parte de PK |
| `feature_key` | `VARCHAR(80)`, parte de PK |
| `prioridad` | `SMALLINT NOT NULL`, `0..999` |
| `fijada` | booleano no nulo |
| auditoría | creación, actualización y actor |

La tabla ordena funciones elegibles. No puede hacer visible una función sin
capacidad.

Las tablas no se exponen al cliente mediante acceso directo Supabase. Todas las
escrituras pasan por API y `AUTORIZACION_SCM_ADMINISTRAR`.

## 4. Modelo de proyección frontend

Crear `frontend/src/services/workspaceProjection.js`:

```js
buildActorWorkspace({ registry, actor, runtimeFlags }) => {
  primaryRole,
  experience,
  areas,
  features,
  homeFeatures,
  startFeature,
  configurationWarnings,
}
```

Algoritmo:

1. partir de `capacidades_efectivas` del actor activo;
2. filtrar funciones por `requiredAny` y madurez;
3. resolver rol principal activo;
4. intersectar preferencias con funciones elegibles;
5. ordenar fijada, prioridad de rol, prioridad predeterminada y título;
6. aceptar `workspace_start_feature` solo si queda elegible;
7. usar la primera función elegible o Guía como fallback;
8. emitir advertencia si falta principal o hay claves desconocidas.

Las advertencias estructuradas usan los códigos estables:

- `PRIMARY_ROLE_MISSING`;
- `START_FEATURE_UNKNOWN`;
- `START_FEATURE_INELIGIBLE`;
- `PREFERENCE_UNKNOWN`;
- `PREFERENCE_INELIGIBLE`.

El fallback elige primero una `homeFeature` elegible. Si no existe trabajo
elegible usa `guide.scm`; nunca propone `home.workspace` como acceso de sí mismo.

No se recorta la lista. La UI puede mostrar un bloque principal y una sección
**Más funciones**, pero todas permanecen accesibles.

## 5. Contratos de API

### Capacidades

`GET /api/catalogo/capacidades`

Respuesta:

```json
[
  {
    "id": 1,
    "codigo": "INVENTARIO_VER",
    "nombre": "Consultar inventario SCM",
    "descripcion": null,
    "activo": true
  }
]
```

Requiere `AUTORIZACION_SCM_ADMINISTRAR` en producción.

### Crear/actualizar rol

`POST /api/catalogo/roles-operativos`  
`PUT /api/catalogo/roles-operativos/{id}`

```json
{
  "codigo": "AUDITOR_INVENTARIO",
  "nombre": "Auditor de inventario",
  "activo": true,
  "capacidad_codigos": ["INVENTARIO_VER"],
  "workspace_focus": "Revisar existencias y movimientos trazables.",
  "workspace_start_feature": "warehouse.kardex",
  "workspace_preferencias": [
    {
      "feature_key": "warehouse.kardex",
      "prioridad": 10,
      "fijada": true
    }
  ],
  "expected_version": 1
}
```

Crear no exige `expected_version`. Actualizar devuelve `409 VERSION_CONFLICT`
si no coincide. Códigos de capacidad inexistentes/inactivos devuelven
`400 INVALID_CAPABILITY`. Una clave UI desconocida puede conservarse con
advertencia, pero no otorga acceso.

El `codigo` estable del rol es inmutable después de crearlo. La actualización
de capacidades, preferencias y versión ocurre en una sola transacción; una
preferencia repetida se rechaza sin escritura parcial.

### Definir rol principal

`PATCH /api/catalogo/trabajadores/{id}/rol-principal`

```json
{
  "rol_operativo_id": 7
}
```

El rol debe estar activo y asignado al trabajador. Si se quita ese rol mediante
la actualización ordinaria del trabajador, el principal se limpia en la misma
transacción.

### Identidad actual

`GET /api/auth/me` conserva sus campos y agrega:

```json
{
  "rol_principal": {
    "id": 7,
    "codigo": "AUDITOR_INVENTARIO",
    "nombre": "Auditor de inventario",
    "workspace_focus": "Revisar existencias y movimientos trazables.",
    "workspace_start_feature": "warehouse.kardex",
    "workspace_preferencias": []
  },
  "rol_principal_pendiente": false
}
```

`Cache-Control: private, no-store` permanece vigente. La respuesta no contiene
menús ni URLs; frontend conserva la autoridad de composición visual y backend
la de capacidades.

## 6. Administración UI

Crear una superficie real en **Administración / Roles y capacidades**:

- lista de roles y estado;
- capacidades agrupadas y buscables;
- foco del rol;
- función inicial seleccionada entre las compatibles;
- funciones fijadas y prioridad;
- previsualización **Así verá este rol**;
- advertencia si una preferencia carece de capacidad;
- listado de personas multirrol sin principal.

La previsualización llama a la misma función pura con capacidades candidatas.
No cambia sesión, no usa `Cambiar perfil` y no ejecuta comandos del rol.

La agrupación de capacidades es presentacional y determinista: usa las áreas
humanas del registro del workspace y **Otras capacidades** para códigos nuevos
sin clasificación. Nunca filtra ni autoriza.

Datos maestros / Trabajadores conserva identidad personal y asignación de
roles. Administración gobierna el catálogo de roles/capacidades y su
experiencia.

## 7. Inicio

`RoleHome` consume la proyección:

- saludo e identidad;
- rótulo y foco del rol principal;
- funciones fijadas/prioritarias;
- todas las demás funciones elegibles;
- situación de planta únicamente si sus capacidades la permiten;
- estado genérico de consulta sin tareas ficticias;
- advertencia administrativa no intrusiva cuando falta principal.

N2 no introduce contadores vivos. Las tarjetas describen accesos de trabajo,
no afirman cantidades pendientes.

## 8. Seguridad y auditoría

- toda administración exige `AUTORIZACION_SCM_ADMINISTRAR`;
- la actualización de rol registra antes/después de capacidades y preferencias;
- definir principal registra trabajador, rol anterior/nuevo y actor;
- logs no incluyen JWT ni datos personales innecesarios;
- frontend vuelve a filtrar al refrescar `/api/auth/me`;
- una función visible no implica permiso de comando interno: cada botón conserva
  su capacidad específica.

## 9. Migración y compatibilidad

1. Expandir columnas y tabla de preferencias.
2. Backfill solo para trabajador con un rol activo.
3. Enriquecer serialización conservando campos anteriores.
4. Migrar frontend a la proyección nueva.
5. Retirar `ROLE_EXPERIENCE`, `ROLE_PRIORITY` y `TASKS` después de comparar
   workspaces de roles existentes.
6. No borrar roles, capacidades ni asociaciones históricas.

El modo local de UAT conserva selector de actor; cambia la identidad, no la
lógica de proyección. Producción Supabase sigue sin selector.

## 10. Mapa ATDD a pruebas

| Escenario | Evidencia automática |
|---|---|
| N2-00 | UI/routing: N1.1 permanece fail-closed y cada ruta consume madurez/capacidades por `feature_key` |
| N2-01 | backend + UI: rol nuevo/capacidad produce Kardex sin constante de rol |
| N2-02 | unit + route: preferencia sin capacidad se ignora y no autoriza |
| N2-03 | PostgreSQL/API/UI: multirrol, principal y unión de capacidades |
| N2-04 | migración/UI: varios roles sin principal usan fallback genérico |
| N2-05 | UI: más de seis funciones permanecen accesibles y ordenadas |
| N2-06 | UI: preview usa proyección sin cambiar sesión |
| N2-07 | servicio/API: inactivo deja de aportar capacidad/preferencia |
| N2-08 | UI: fallo de identidad no habilita comandos |
| N2-09 | unit: clave retirada se ignora sin romper Inicio |

Primera prueba RED: N2-01 en `RoleHome.spec.jsx`, creando
`AUDITOR_INVENTARIO`. Debe fallar hoy porque el frontend depende de
`ROLE_EXPERIENCE`, `ROLE_PRIORITY` y `TASKS` estáticos.

Pruebas PostgreSQL obligatorias:

- índice parcial de un principal por trabajador;
- backfill uno/varios roles;
- actualización concurrente de versión del rol;
- retirar el rol principal limpia la marca sin perder otras asociaciones.

## 11. Archivos previstos

Backend:

- `backend/app/models/trabajador.py`;
- migración Alembic nueva;
- `backend/app/api/rutas_trabajadores.py`;
- `backend/app/api/rutas_auth.py`;
- servicio específico de autorización/configuración de workspace;
- pruebas de API, servicio y PostgreSQL.

Frontend:

- `frontend/src/context/ScmActorContext.jsx`;
- `frontend/src/components/RoleHome.jsx`;
- `frontend/src/services/workspaceProjection.js`;
- `frontend/src/services/api.js`;
- vista Administración / Roles y capacidades;
- pruebas de proyección, Inicio, administración y regresión auth.

## 12. Definition of Done

- [x] N2-01…N2-09 verdes.
- [x] Migración upgrade/downgrade/fresh y `flask db check` verdes.
- [x] Ninguna lista hardcodeada decide experiencia o prioridad de rol.
- [x] Ninguna ruta duplica `requiredAny` fuera del registro de funciones.
- [x] Rol nuevo con capacidades funciona sin cambio de frontend.
- [x] Preferencias inválidas no conceden acceso ni rompen Inicio.
- [x] Multirrol conserva unión de capacidades y principal explícito.
- [x] Más de seis funciones siguen accesibles.
- [x] `workspace_start_feature` se muestra como acceso principal sin redirección automática.
- [x] `task` es opt-in y `home.workspace` no aparece como tarea de sí mismo.
- [x] Las funciones no fijadas se agrupan por área sin truncamiento.
- [x] Producción no recupera selector local de identidad.
- [x] Matriz de permisos y Guía actualizadas.
