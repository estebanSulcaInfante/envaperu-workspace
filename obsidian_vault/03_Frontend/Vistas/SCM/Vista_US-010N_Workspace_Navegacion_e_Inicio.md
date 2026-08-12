---
tipo: vista_frontend
estado: desplegado-pendiente-uat
rutas: [/, shell-global]
tags: [frontend, scm, ux, navegacion, inicio, roles, capacidades]
relaciones:
  - "[[US-010N_Navegacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[TS-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
  - "[[TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[Arquitectura_Workspace_SCM_por_Areas]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# Vista US-010N: Workspace, navegación e Inicio

## Propósito

Permitir que cualquier actor encuentre su trabajo por área y reciba un Inicio
coherente con sus capacidades, sin pantallas copiadas por rol ni pestañas
horizontales extensas.

## Escritorio

```text
┌──────────────────────┬─────────────────────────────────────────────┐
│ EnvaPerú SCM         │ Trabajando como: Gerente General           │
│                      │ Entorno: UAT                                │
│ Inicio               ├─────────────────────────────────────────────┤
│ Planificación        │ Planificación / OF y OA generadas           │
│ Producción           │                                             │
│ Materiales           │ [contenido de la vista]                     │
│ Almacén e inventario │                                             │
│ Control              │                                             │
│                      │                                             │
│ Datos maestros       │                                             │
│ Administración       │                                             │
│ Guía SCM             │                                             │
└──────────────────────┴─────────────────────────────────────────────┘
```

El sidebar se puede contraer a iconos conservando tooltip y nombre accesible.
La identidad y el entorno permanecen visibles en la cabecera.

## Móvil

- menú hamburguesa abre drawer de ancho controlado;
- al elegir una función, el drawer se cierra y el foco vuelve al disparador;
- el encabezado de actor se apila sin empujar controles;
- las secciones se muestran como lista, no como tabs desbordadas;
- breadcrumbs pueden contraerse a área + vista actual.

## Inicio

```text
Hola, Esteban
Gerente General · Decisiones, excepciones y cumplimiento

Fijado para tu rol
┌─────────────────────┐ ┌─────────────────────┐
│ Revisar planificación│ │ Kardex y existencias│
└─────────────────────┘ └─────────────────────┘

Tu trabajo disponible
┌────────────┐ ┌────────────┐ ┌────────────┐
│ Producción │ │ Materiales │ │ Control    │
└────────────┘ └────────────┘ └────────────┘

Situación de planta     (solo con capacidad)
```

No se muestran números de pendientes hasta disponer de una fuente real. Una
tarjeta representa acceso de trabajo, no afirma que exista una tarea pendiente.

## Estados

### Cargando identidad

Skeleton de identidad y navegación; los comandos no se habilitan por asumir
permisos.

### Error de identidad

Alerta recuperable con **Reintentar** y sin acciones operativas.

### Sin función elegible

Mensaje de perfil de consulta/configuración incompleta y acceso a Guía. No se
inventa una tarea genérica de producción.

### Rol principal pendiente

El usuario conserva la unión de capacidades y ve un rótulo genérico. Solo un
administrador recibe el enlace para regularizar el principal.

### Función fuera del piloto

Página informativa con nombre, madurez y alternativa operativa; el componente
mock no se monta.

## Administración / Roles y capacidades

```text
Rol: Auditor de inventario          Estado: Activo
Foco: Revisar existencias y movimientos trazables

Capacidades
[x] INVENTARIO_VER
[ ] INVENTARIO_AJUSTAR

Inicio: Kardex y existencias
Prioridades: [Kardex] [Movimientos]

[Así verá este rol] [Guardar]
```

La previsualización no cambia la sesión. Si se fija una función incompatible,
la vista advierte y la excluye del resultado.

## Acciones y permisos

| Acción | Regla |
|---|---|
| Abrir función | al menos una capacidad declarada y madurez habilitada |
| Ver maestro contextual | capacidad de consulta del maestro |
| Editar rol/capacidades | `AUTORIZACION_SCM_ADMINISTRAR` |
| Definir rol principal | `AUTORIZACION_SCM_ADMINISTRAR` |
| Previsualizar | no asume identidad ni concede permisos |
| Cambiar perfil | solo `local_actor`; nunca producción Supabase |

## QoL posterior

Búsqueda global, favoritos, recientes, contadores y vistas guardadas usarán las
mismas claves de función. No forman parte del primer desarrollo N1/N2.

## Hardening UX previo a N2 — 2026-08-08

Antes de parametrizar Inicio se cerró un incremento local N1.1 para evitar que
N2 heredara problemas estructurales:

- la ruta y el breadcrumb de cada área se derivan de la primera función
  realmente visible para el actor; un perfil OA-only ya no cae en OF;
- menú, breadcrumb y rutas consumen el mismo `feature_key`, sus capacidades y
  su madurez; una vista no se monta mientras la identidad está cargando o en
  error;
- las áreas con varias funciones son grupos desplegables, no enlaces ambiguos;
- la identidad, encabezado y recorrido se compactaron para priorizar el trabajo;
- el recorrido operativo es una ayuda secundaria desplegable, estable para OF
  y OA y sin desborde horizontal;
- el drawer se usa en móvil, un rail persistente entre 900 y 1199 px y el
  sidebar expandido desde 1200 px; así se conserva descubribilidad sin comprimir
  el contenido en anchos intermedios;
- Datos maestros usa tarjetas en móvil, nombres humanos y una guía inicial
  colapsable; su acceso general abre siempre el hub `/datos-maestros`, desde el
  cual se exploran todos los catálogos permitidos para el actor;
- se agregaron salto al contenido, foco al navegar, nombres accesibles, estados
  vacíos accionables y bloqueo fail-closed de capacidades.

Validación local: 390, 768, 899, 901, 1200 y 1440 px; 44 archivos / 190 pruebas,
lint sin errores y build productivo verde. La validación remota humana continúa
en [[UAT_TS-010N1_Navegacion_Agrupada]].

Esto no implementa N2: `RoleHome` conserva temporalmente su configuración
estática hasta que la proyección, persistencia y administración de roles estén
listas en conjunto.

## Implementación N2 local — 2026-08-08

La limitación anterior quedó superada en local:

- una proyección pura y compartida gobierna Inicio, sidebar, breadcrumbs y
  redirecciones;
- el rol principal aporta foco, acceso principal y preferencias; todos los
  roles activos siguen aportando capacidades;
- el acceso principal se activa con **Abrir** y nunca redirige automáticamente;
- las funciones fijadas usan tarjetas y el resto se agrupa por área sin límite
  arbitrario;
- Administración permite crear y editar roles, capacidades, preferencias y rol
  principal, con previsualización sin suplantación;
- preferencias desconocidas o inelegibles generan advertencias y pueden
  retirarse;
- en Supabase la identidad JWT manda y `X-Actor-Id` no puede suplantarla.

Evidencia local: **50 archivos / 212 pruebas frontend**, build verde y lint sin
errores. La validación humana se ejecutará mediante
[[UAT_TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]].

Despliegue remoto: frontend `51a7785`, bundle `assets/index-DgQZMgPW.js`.
Inicio y Administración cargan con la sesión Supabase real; no existe selector
de perfil productivo. La UAT limitada/multirrol permanece abierta.
