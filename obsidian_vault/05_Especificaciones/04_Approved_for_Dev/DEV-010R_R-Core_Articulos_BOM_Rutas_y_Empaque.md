---
tipo: approved-for-dev
estado: implementado-local
tags: [scm, articulos, bom, rutas, wip, empaque, roles, tdd, postgresql]
user_story: "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
tech_spec: "[[TS-010R_Articulos_BOM_Rutas_WIP_y_Perfiles_Empaque]]"
fecha_aprobacion: 2026-07-24
---

# DEV-010R: R-core de Artículos, BOM, Rutas y Empaque

## 1. Decisión de aprobación

El 2026-07-24 el usuario responsable aprobó expresamente continuar con el corte `R-core` de [[TS-010R_Articulos_BOM_Rutas_WIP_y_Perfiles_Empaque]]. La autorización cubre cambios locales en migraciones, modelos, servicios, API, frontend, pruebas y documentación. No autoriza escribir en la base desplegada ni habilitar funciones productivas.

R-runtime, confirmaciones reales de WIP y ejecución de prearmado siguen sujetos a US-010F y a sus validaciones pendientes.

## 2. Alcance autorizado

- [x] Identidad común `scm_articulo` y subtipos 1:1 para PiezaColor, WIP y ProductoTerminado.
- [x] Backfill reproducible de PiezaColor y ProductoTerminado.
- [x] BOM multinivel revisionada, aprobación segregada y rechazo de ciclos.
- [x] Rutas revisionadas, precedencias y una sola autoridad ejecutora.
- [x] Tipos de contenedor, perfiles y reglas de empaque revisionadas.
- [x] CRUD/API/frontend completo de maestros R-core: WIP, borradores BOM/ruta/regla,
  centros de trabajo, tipos de contenedor y perfiles empacables.
- [x] Retiro completo de `KIT`: altas, lecturas, modelo ORM, tabla y columna legacy.
- [x] Roles, capacidades y asociaciones semilla idempotentes.
- [x] Pruebas SQLite, PostgreSQL y frontend según escenarios RWE.

## 3. Roles y permisos

Se aplica [[Matriz_Roles_Capacidades_SCM_Produccion]].

Las migraciones y seeds:

1. crean capacidades faltantes;
2. crean roles semilla faltantes;
3. agregan asociaciones rol-capacidad faltantes;
4. no eliminan configuración existente;
5. no escriben `trabajador_rol`.

La asignación de personas se realiza al final del desarrollo durante UAT. Hasta entonces las pruebas usan actores controlados y autorización server-side.

## 4. Secuencia TDD

### Incremento R1 — identidad y autorización

- [x] RED de subtipos incompatibles, unicidad 1:1 y seed repetible.
- [x] Migración expand aditiva y backfill.
- [x] Modelos y servicio transaccional de artículos.
- [x] PostgreSQL sin drift y sin asignar trabajadores.

### Incremento R2 — BOM

- [x] RED de ciclo directo e indirecto.
- [x] CRUD de borradores y aprobación serializada.
- [x] Hash, snapshots, segregación creador/aprobador e inmutabilidad.

### Incremento R3 — rutas

- [x] RED de DAG, terminal incompatible y autoridad ambigua.
- [x] CRUD y aprobación de rutas/operaciones/precedencias.

### Incremento R4 — empaque

- [x] RED Decimal de regla inviable y override expansivo.
- [x] Maestros, revisiones, calculadora y aprobación.

### Incremento R5 — frontend y retiro de KIT

- [x] Vistas de artículos, estructuras, rutas, perfiles y aprobaciones.
- [x] Reemplazar fixtures KIT por WIP/BOM.
- [x] Ejecutar precondición expand/contract sin aplicar contract destructivo en datos reales.
- [x] Conciliar y eliminar los fixtures KIT locales autorizados hasta obtener evidencia cero.
- [x] Aplicar el contract destructivo protegido en la base local.

### Incremento R6 — gobierno de rechazo y descarte BOM

- [x] Rechazo de revisión pendiente por aprobador distinto, con motivo y
  auditoría.
- [x] Descarte del borrador propio como estado terminal, sin borrado físico.
- [x] PiezaColor excluida como resultado de BOM en frontend y backend.
- [x] ProductoTerminado excluido como componente dentro del alcance piloto.
- [x] Migración `f64b3d9e5a81` aplicada en `envaperu_test`.
- [x] Pruebas focalizadas backend/frontend y build Vite aprobados.

## 5. Gates

- [x] Baseline [[Baseline_TS-010R_C_D_2026-07-24]] verde.
- [x] Ninguna cantidad persistente de R1 usa `Float`.
- [x] Ninguna autorización de R1 depende del frontend.
- [x] Ninguna migración asigna roles a trabajadores.
- [x] PostgreSQL valida FKs, triggers, CTE, locks y ausencia de drift para R1/R2/R3.
- [x] El contract aborta ante cualquier KIT o componente legacy inesperado.
- [x] La base desplegada permanece intacta.

## 6. Registro de ejecución

### 2026-07-24 — Incremento R1: identidad y autorización

- El RED inicial falló con `ModuleNotFoundError: app.models.scm_articulos`.
- La revisión expand `c91d4e7a2b60` crea `scm_articulo` y sus tres subtipos 1:1, agrega el correlativo `SUBENSAMBLE_WIP -> WIP-*` y hace backfill de PiezaColor/ProductoTerminado.
- PostgreSQL usa triggers diferidos para exigir exactamente un subtipo compatible al confirmar la transacción y bloquea cambios de código, clase o unidad.
- Las altas legacy de PiezaColor y ProductoTerminado hacen dual-write mediante listeners SQLAlchemy en la misma transacción; el sincronizador queda como reparación idempotente.
- Se habilitaron `GET /articulos`, `GET /articulos/{id}` y `POST /articulos/wip`; el alta WIP exige `ARTICULO_ADMINISTRAR` y registra `ARTICLE_CREATED`.
- El seed crea las capacidades R/C/D y completa asociaciones faltantes incluso cuando el rol ya existía. No reactiva catálogos, no cambia nombres configurados y no escribe `trabajador_rol`.
- Backend rápido final: `217 passed`, `1 skipped`, `12 deselected`.
- PostgreSQL: `10 passed`, `1 skipped`; incluye instalación nueva, ausencia de drift, backfill, subtipo diferido, identidad inmutable y downgrade seguro sin WIP nuevo.
- No se consultó ni modificó la base desplegada.

Pendientes transversales identificados después de R4 y ya resueltos:

1. edición y baja lógica del WIP con versión optimista e idempotencia;
2. retirar completamente `KIT` después de reemplazar fixtures de demostración.

### 2026-07-24 — Incremento R2: BOM revisionada

- El RED inicial falló con `ModuleNotFoundError: app.models.scm_estructuras`.
- La revisión `d21f8c3b4a70` crea `scm_estructura_revision` y `scm_estructura_componente`, cantidades `Numeric(15,6)`, índice parcial de aprobación vigente y triggers de inmutabilidad.
- Solo `BORRADOR` admite reemplazo de líneas. Enviar, aprobar y retirar usan `Idempotency-Key`; editar usa `version`.
- La aprobación exige `ESTRUCTURA_APROBAR` y un actor distinto del creador.
- PostgreSQL toma `pg_advisory_xact_lock`, incorpora la candidata a un CTE recursivo y rechaza ciclos con `STRUCTURE_CYCLE`.
- La prueba concurrente lanzó dos aprobaciones que juntas formarían un ciclo: una quedó aprobada y la otra fue rechazada. SQL directo no pudo modificar las líneas publicadas.
- Una nueva revisión aprobada retira la aprobación anterior sin reabrirla ni mutar sus componentes.
- Backend rápido: `221 passed`, `1 skipped`, `13 deselected`.
- PostgreSQL: `11 passed`, `1 skipped`; `flask db check` sin drift.
- Se documentó el contrato en [[SCM_Estructuras_BOM]].
- No se consultó ni modificó la base desplegada, y ninguna migración escribió `trabajador_rol`.

### 2026-07-24 — Incremento R3: rutas revisionadas

- El RED inicial falló con `ModuleNotFoundError: app.services.scm_route_service`.
- La revisión `e38a6d4f2c91` crea centros de trabajo, revisiones de ruta, operaciones y precedencias con FKs compuestas que impiden aristas entre rutas.
- Las operaciones declaran exactamente un `executor_kind`: `OP_OT` sin estructura paralela u `ORDEN_OPERACION` con estructura aprobada compatible.
- La aprobación exige un actor distinto del creador, toma un lock asesor, valida el DAG mediante CTE recursivo y exige un único terminal cuyo resultado sea el producto objetivo.
- Una operación intermedia no puede acreditar producto terminado. Una operación terminal `OP_OT` sí puede producirlo directamente.
- Operaciones, aristas y revisiones aprobadas quedan congeladas mediante triggers PostgreSQL; una nueva aprobación retira la revisión vigente anterior.
- Se expusieron CRUD de centros, borradores de ruta, consulta, aprobación y retiro bajo capacidades `RUTA_*`; no se asignaron personas reales.
- Backend rápido: `227 passed`, `1 skipped`, `14 deselected`.
- PostgreSQL: `11 passed` en migraciones y `1 passed` en el arnés; `flask db check` sin drift.
- Se documentó el contrato en [[SCM_Rutas_Produccion]].
- No se consultó ni modificó la base desplegada.

### 2026-07-24 — Incremento R4: perfiles y reglas de empaque

- El RED inicial falló con `ModuleNotFoundError: app.services.scm_packaging_service`.
- La revisión `f49b7e5a3d02` crea tipos de contenedor, perfiles empacables, asociaciones por artículo y reglas revisionadas; agrega correlativos `TMG`, `TCO` y `PEM`.
- Tara, tolerancias, márgenes y límites se persisten como `Numeric`; la función pura de capacidad exige objetos `Decimal`.
- Una aprobación exige evidencia física, maestros activos, objetivo no mayor al máximo probado y límite neto positivo.
- La revisión aprobada congela tara nominal, tolerancia y bruto máximo. Cambiar después el tipo de manga no altera su cálculo histórico.
- Un override puede reducir la capacidad o declarar tara real con motivo y permiso; nunca amplía el máximo aprobado.
- La calculadora distribuye unidades y peso neto teórico, admite última manga parcial y no crea inventario ni identidades de manga.
- PostgreSQL bloquea SQL directo sobre reglas publicadas y garantiza una sola aprobación vigente por combinación.
- Backend rápido: `233 passed`, `1 skipped`, `15 deselected`.
- PostgreSQL: `12 passed` en migraciones y `1 passed` en el arnés; `flask db check` sin drift.
- Se documentó el contrato en [[SCM_Perfiles_y_Reglas_Empaque]].
- No se consultó ni modificó la base desplegada, y no se asignaron personas reales.

### 2026-07-24 — Incremento R5: frontend y retiro funcional de KIT

- Se agregó **Ingeniería SCM** en Datos maestros con cinco áreas conectadas a la API: Artículos, Estructuras BOM, Rutas, Empaque y Aprobaciones.
- La vista permite alta WIP, creación de revisiones BOM, envío/aprobación/retiro, centros y rutas, tipos de contenedor, perfiles y reglas de empaque.
- El actor local de prueba es configurable para validar segregación; el servidor continúa siendo la autoridad de permisos y no se asignaron roles a trabajadores reales.
- La carga es tolerante a permisos parciales: un `403` de Rutas o Empaque no oculta catálogos autorizados de otro dominio.
- `PiezaDialog` ya no ofrece `KIT`; la configuración guiada explica el flujo WIP/BOM y siempre envía `kit: null`.
- `POST/PUT /piezas-color` y `POST /configurar-producto` rechazan nuevas composiciones legacy con `LEGACY_KIT_NOT_SUPPORTED`; `GET /piezas-color/{sku}` mantiene lectura histórica.
- `backend/seed.py` y el escenario de molde heterogéneo dejaron de fabricar KIT/componentes. El molde conserva piezas físicas y la composición se expresa en BOM.
- La auditoría reproducible `check_legacy_kit_precondition.py` es read-only, devuelve conteos/muestra y aborta con `LEGACY_KIT_PRECONDITION_FAILED`.
- La ejecución local sobre `enva_test` encontró `2` KIT y `4` componentes: `BALDE-KIT-C1` y `JARRA-REGADERA-KIT-C5`. Por ello **no se aplicó ningún contract destructivo** ni se borraron datos.
- Backend final: `238 passed`, `1 skipped`, `15 deselected` después de sumar la precondición; frontend: `92 passed` con un worker, build y lint verdes.
- Revisión visual local confirmó navegación, formulario WIP, empaque, errores estructurados y retiro de la opción KIT.
- No se consultó ni modificó la base desplegada.

### 2026-07-25 — Conciliación local y endurecimiento CRUD

- El usuario confirmó que `BALDE-KIT-C1` y `JARRA-REGADERA-KIT-C5` eran mocks
  descartables y autorizó eliminarlos de `enva_test`.
- La transacción local eliminó exactamente `2` filas KIT, `4` componentes y `1`
  asociación incompleta de `producto_pieza`; no existían salidas físicas asociadas.
- `check_legacy_kit_precondition.py` quedó verde con `kit_count=0` y
  `component_count=0`. No se consultó ni modificó la base desplegada.
- Se agregó edición e inactivación/reactivación de WIP con `version` optimista y
  eventos auditables.
- Los borradores BOM, ruta y regla pueden reabrirse y editarse. Centros, tipos de
  contenedor y perfiles permiten editar e inactivar/reactivar desde la vista.
- La base local se actualizó desde `b7e9f1a4d510` hasta `f49b7e5a3d02`.
  El backfill ahora rescata códigos legacy vacíos con una identidad SCM estable;
  el producto legado sin SKU permanece visible, pero no se ofrece como destino
  de ruta hasta sanear su clave legacy.
- Backend final: `239 passed`, `1 skipped`, `15 deselected`. La regresión de
  backfill sin código pasó en PostgreSQL aislado.
- Frontend completo: `93 passed`; prueba dirigida posterior `3 passed`, build y
  lint verdes. La revisión visual confirmó las cinco áreas, el modal WIP y la
  eliminación del `404` causado por el SKU legacy vacío.

### 2026-07-25 — Contract KIT aplicado

- La autorización del usuario “retíralas” habilitó el retiro del esquema legacy
  únicamente en la base local.
- La revisión `a61c8d2f4e90` aborta con
  `LEGACY_KIT_PRECONDITION_FAILED` si encuentra una variante
  `KIT`/`COMPONENTE` o cualquier fila en `pieza_componente`.
- Con evidencia cero eliminó `pieza_componente` y `pieza_color.tipo` en
  `enva_test`. La auditoría posterior devuelve `contract_applied=true`.
- Se retiraron `PiezaComponente`, los accesos ORM, la serialización
  `tipo/componentes`, las altas internas `tipo='SIMPLE'` y el selector estático
  “Tipo” del formulario PiezaColor.
- El downgrade recrea la columna con `SIMPLE` para filas existentes y una tabla
  de componentes vacía; nunca reconstruye composiciones eliminadas.
- PostgreSQL contract: `3 passed` en los escenarios dirigidos. Backend completo:
  `239 passed`, `1 skipped`, `16 deselected`. Frontend: `93 passed`, build y
  lint verdes.
- La base desplegada permaneció intacta y no se asignaron roles a trabajadores.

Deuda externa al contract:

1. repetir la precondición y aplicar la revisión mediante el proceso aprobado en
   cada ambiente futuro; el resultado local no prueba el estado de otra base;
2. resolver separadamente el drift histórico que `flask db check` reporta para
   el piloto de estación y normalizaciones previas.

### 2026-08-04 — UX de retiro e historial BOM

- `RETIRADA` conserva el significado de publicación retirada y no admite una
  transición de reactivación.
- La reutilización se modela creando una nueva revisión en `BORRADOR` con los
  mismos componentes, manteniendo intacto el historial anterior.
- La pantalla dejó de preseleccionar el primer WIP/PT, separó el historial de
  las revisiones operativas y añadió confirmación explícita para el retiro.
- La copia desde historial queda deshabilitada si existe un `BORRADOR` o
  `PENDIENTE_APROBACION` para el mismo resultado.
- Validación dirigida: 8 pruebas frontend y build Vite aprobados.
