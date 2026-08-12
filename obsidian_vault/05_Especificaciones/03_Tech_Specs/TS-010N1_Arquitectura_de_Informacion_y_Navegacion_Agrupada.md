---
tipo: tech-spec
estado: aprobada-para-desarrollo
tags: [scm, frontend, ux, navegacion, responsive, tdd]
relaciones:
  - "[[US-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
  - "[[2026-08-08_Arquitectura_de_Informacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[Arquitectura_Navegacion_Por_Procesos]]"
  - "[[Vista_US-010N_Workspace_Navegacion_e_Inicio]]"
  - "[[Baseline_TS-010N_2026-08-08]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# TS-010N1: Arquitectura de información y navegación agrupada

## 1. Objetivo técnico

Sustituir la configuración duplicada de navegación por un registro único de
funciones que pueda proyectar áreas, secciones, tareas y estado activo por ruta
sin depender del prefijo `/produccion`. Implementar un shell responsive sin
cambiar contratos de dominio ni rutas físicas durante el piloto.

## 2. Baseline de ingreso

Antes del primer RED:

```powershell
cd .\frontend
npm test -- --run
npm run lint
npm run build
```

La implementación no comienza si la línea base falla. Cualquier advertencia
preexistente se registra con archivo y regla; no se normaliza como parte de N1.

La ejecución del 2026-08-08 quedó verde: 38 archivos/168 pruebas, lint sin
errores y build exitoso. Las advertencias aceptadas están en
[[Baseline_TS-010N_2026-08-08]].

## 3. Registro único de funciones

Crear `frontend/src/config/workspaceRegistry.js`. `navigation.js` pasa a ser un
adaptador temporal o se retira cuando todos sus consumidores migren.

### Contrato `WorkspaceFeature`

```js
{
  key: 'warehouse.kardex',
  areaKey: 'warehouse',
  sectionKey: 'inventory',
  label: 'Kardex y existencias',
  description: 'Consulta saldos y movimientos trazables.',
  path: '/produccion/kardex',
  matches: ['/produccion/kardex'],
  aliases: [],
  requiredAny: ['INVENTARIO_VER'],
  maturity: 'PILOTO',
  task: true,
  defaultPriority: 40,
  keywords: ['inventario', 'existencias', 'movimientos'],
}
```

Reglas:

- `key`, `areaKey`, `sectionKey` y `path` son estables y únicos;
- `matches` usa patrones declarativos con segmentos `:param`;
- gana la coincidencia más específica, nunca el orden accidental del arreglo;
- `requiredAny` solo filtra experiencia; `CapabilityRoute` y la API continúan
  protegiendo la operación;
- `task` indica elegibilidad para Inicio, no una tarea pendiente real;
- `keywords` prepara búsqueda futura sin implementar omnibúsqueda en N1.

### Catálogos estáticos del registro

`WORKSPACE_AREAS`:

| Clave | Rótulo | Orden | Soporte |
|---|---|---:|---|
| `home` | Inicio | 0 | no |
| `planning` | Planificación | 10 | no |
| `production` | Producción | 20 | no |
| `materials` | Materiales | 30 | no |
| `warehouse` | Almacén e inventario | 40 | no |
| `control` | Control | 50 | no |
| `masters` | Datos maestros | 100 | sí |
| `admin` | Administración | 110 | sí |
| `guide` | Guía SCM | 120 | sí |

Madurez permitida:

`PILOTO | DISPONIBLE | LEGACY_MARCHA_BLANCA | PROTOTIPO | FUERA_PILOTO`.

## 4. Mapeo mínimo de rutas existentes

| Clave | Ruta física vigente | Área/sección |
|---|---|---|
| `planning.demand` | `/planificacion` | Planificación / Demanda, OP y plan |
| `planning.detailLegacy` | `/planificacion/:solicitudId` | Planificación / detalle contextual |
| `planning.exceptionalOp` | `/produccion/ordenes/nueva-excepcional` | Planificación / acción contextual |
| `production.fabrication` | `/produccion/ordenes-fabricacion` | Producción / Fabricación |
| `production.machineWork` | `/produccion/ots-mangas` | Producción / Jornadas y Trabajos de color |
| `production.assembly` | `/produccion/ordenes-armado` | Producción / Armado |
| `materials.preparation` | `/materiales/preparaciones` | Materiales / Preparación |
| `materials.internalSupply` | `/produccion/abastecimiento` | Materiales / Abastecimiento interno |
| `materials.reprocessing` | `/produccion/reproceso` | Materiales / Reproceso |
| `warehouse.receiving` | `/produccion/recepcion-mangas` | Almacén / Recepción y Calidad |
| `warehouse.kardex` | `/produccion/kardex` | Almacén / Kardex y existencias |
| `control.progress` | `/produccion/avance` | Control / Avance de planta |
| `control.alerts` | `/produccion/alertas` | Control / Alertas |
| `control.weighings` | `/produccion/pesajes` | Control / Pesajes y correcciones |
| `control.legacyOrders` | `/produccion/ordenes` | Control / Marcha blanca |
| `control.dailyRecords` | `/produccion/registros` | Control / Marcha blanca |
| `control.talonarios` | `/produccion/talonarios` | Control / Marcha blanca |
| `masters.hub` | `/datos-maestros` | Datos maestros / Resumen |
| `admin.settings` | `/configuracion` | Administración / Configuración |
| `guide.scm` | `/guia/scm` | Guía SCM |

Las subrutas de maestros se registran individualmente, pero no se muestran como
trece pestañas globales. `MasterDataHub` las presenta por grupos.

Compras, recepción ordinaria de material, Calidad de proveedor, documentos y
configuración prototipo conservan sus rutas con madurez `FUERA_PILOTO` o
`PROTOTIPO`. No aparecen en producción y una guarda de disponibilidad evita
montar comandos mock mediante URL directa.

## 5. Selectores y proyecciones

Funciones puras:

```js
resolveFeature(pathname)
visibleFeatures({ capabilities, runtimeFlags })
buildAreaNavigation({ capabilities, runtimeFlags })
buildSectionNavigation({ areaKey, capabilities, runtimeFlags })
featureIsAvailable({ feature, runtimeFlags })
```

`resolveFeature` normaliza `/` final y query string. Debe resolver
`/produccion/kardex` como `warehouse.kardex`, aunque su prefijo físico siga
siendo Producción.

## 6. Shell y componentes

### `AppShell`

- escritorio: sidebar plegable persistente;
- móvil/tablet: drawer temporal con foco y cierre accesibles;
- accesos de soporte separados al pie;
- cabecera conserva identidad, entorno y cierre de sesión;
- breadcrumbs proceden del registro.

### Nuevos componentes

- `WorkspaceSidebar`;
- `WorkspaceSectionNav`;
- `WorkspaceBreadcrumbs`;
- `FeatureAvailabilityRoute`;
- `WorkspaceLanding` reutilizable.

`ModuleTabs` se conserva solo dentro de una vista cuando sus pestañas son
estados o subprocesos del mismo agregado. No vuelve a usarse como listado plano
de áreas heterogéneas.

### Datos maestros

`MasterDataHub` agrupa tarjetas en Producto e ingeniería, Materiales y
proveedores, Planta y logística, Organización y Gobierno de datos. Las rutas y
CRUD actuales se conservan. Los estados de madurez usan el mismo enum del
registro.

El área `masters` conserva siempre `/datos-maestros` como entrada canónica. Las
preferencias del rol pueden ordenar las funciones internas o fijar un acceso
principal en Inicio, pero no deben sustituir el hub por Productos u otro
catálogo particular.

## 7. Guardas de madurez

| Madurez | Navegación productiva | URL directa productiva |
|---|---|---|
| `PILOTO` / `DISPONIBLE` | visible con capacidad | monta la vista con capacidad |
| `LEGACY_MARCHA_BLANCA` | solo con flag y capacidad | bloquea sin flag |
| `PROTOTIPO` / `FUERA_PILOTO` | oculta | muestra frontera informativa sin montar CRUD |

Flag de transición: `VITE_SCM_SHOW_LEGACY`. No autoriza; únicamente hace
descubrible una función ya protegida.

## 8. Planificación y enlaces contextuales

`ProductionPlanningScm` conserva su ruta. Las OF/OA generadas muestran estado
resumido y enlaces a:

- `/produccion/ordenes-fabricacion` con identificador de OF;
- `/produccion/ordenes-armado` con identificador de OA.

No se copian formularios de ejecución en Planificación. Materiales, Kardex y
maestros exponen enlaces contextuales mediante claves del registro, no strings
de ruta repetidos en componentes.

## 9. Accesibilidad y responsive

- navegación completa por teclado;
- `aria-current="page"` en una sola función;
- nombre accesible para expandir/contraer áreas;
- foco vuelve al disparador al cerrar drawer;
- ancho objetivo `390`, `768` y `1440` px;
- ningún acceso esencial requiere scroll horizontal;
- el contenido puede conservar tablas con scroll propio sin desplazar el shell.

## 10. Mapa ATDD a pruebas

| Escenario | Evidencia automática |
|---|---|
| N1-01 | unit/UI: registro produce las cinco áreas y ubica Preparación/Kardex/OF |
| N1-02 | UI: Planificación muestra OF/OA y enlaces sin controles de ejecución |
| N1-03 | UI: enlace contextual abre el mismo maestro canónico |
| N1-04 | UI responsive: sidebar/drawer sin pestañas globales desbordadas |
| N1-05 | routing: rutas físicas antiguas resuelven área nueva correcta |
| N1-06 | route guard: prototipo/fuera piloto no monta componente |
| N1-07 | unit/UI: legacy depende de flag y capacidad |
| N1-08 | route/API regression: acceso sin capacidad bloqueado |
| N1-09 | unit: solo warehouse activo para `/produccion/kardex` |

Primera prueba RED: N1-09 en `navigation.spec.js`, porque la implementación
vigente clasifica Kardex por el prefijo `/produccion`.

Fixtures: capacidades de Gerencia, Gestor de maestros y actor sin inventario;
rutas de la tabla anterior; runtime productivo con legacy apagado y entorno
UAT con legacy encendido.

## 11. Archivos previstos

- `frontend/src/config/workspaceRegistry.js`;
- `frontend/src/config/navigation.js` como adaptador temporal;
- `frontend/src/components/layout/AppShell.jsx`;
- `frontend/src/components/Sidebar.jsx`;
- `frontend/src/components/ui/ModuleTabs.jsx`;
- `frontend/src/components/MasterDataHub.jsx`;
- `frontend/src/components/ProductionPlanningScm.jsx`;
- `frontend/src/App.jsx`;
- pruebas nuevas/focales de registro, shell, routing, maestros y planificación.

## 12. Definition of Done

- [ ] N1-01…N1-09 verdes.
- [ ] Registro sin claves/rutas primarias duplicadas.
- [ ] Todas las rutas actuales clasificadas o declaradas alias.
- [ ] Producción no muestra Kardex, recepción, reproceso, alertas ni legacy.
- [ ] Maestros agrupados sin duplicar CRUD.
- [ ] Prototipos bloqueados por disponibilidad en producción.
- [ ] Viewports objetivo verificados automáticamente y con smoke manual.
- [ ] Guía y documentación frontend actualizadas.
- [ ] Sin cambios de endpoints ni reglas de dominio.
