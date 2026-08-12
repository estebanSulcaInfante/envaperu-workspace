---
tipo: tech-spec
estado: aprobada-para-desarrollo-local
user_story: "[[US-013A_Almacenes_Ubicaciones_y_Alcance_por_Trabajador]]"
tags: [scm, almacen, ubicacion, permisos, scope, postgres, migracion]
relaciones:
  - "[[2026-08-11_Almacenes_Custodia_Transferencias_y_Kardex_Unico]]"
  - "[[Almacen_SCM]]"
  - "[[SCM_Operaciones_Almacen_y_Transferencias]]"
  - "[[UAT_TS-018_Kardex_MultiAlmacen_Pickup_y_Custodia]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# TS-018A: almacenes, ubicaciones y alcance de datos

## 1. Objetivo

Introducir el almacén como autoridad organizacional sin reemplazar el Kardex ni
romper los movimientos/IDs existentes. La autorización pasa de capacidad
global a `capacidad + scope`.

## 2. Modelo aditivo

### `scm_almacen`

`id UUID`, `codigo VARCHAR(40) UNIQUE`, `nombre`, `tipo`, `activo`,
`version`, timestamps y configuración JSON validada. Tipos iniciales:
`MATERIAS_PRIMAS`, `PIEZAS_WIP`, `PRODUCTO_TERMINADO`,
`GENERAL_CONTINGENCIA`.

No se insertan almacenes físicos por migración. La API/UI de setup debe crear
la primera jerarquía y bloquear operaciones hasta que exista una configuración
activa y compatible.

### `scm_almacen_trabajador`

Vincula `almacen_id`, `trabajador_id`, clases permitidas, vigencia, estado,
actor que asignó y versión. No reemplaza roles/capacidades.

### `scm_ubicacion_inventario`

Añade de forma nullable durante expand:

- `almacen_id`;
- `tipo`: `RECEPCION | CUARENTENA | ZONA | POSICION | STAGING | PUNTO_PRODUCCION | TRANSITO`;
- `parent_id`;
- `permite_saldo_libre`;
- `version`.

`TRANSITO` no pertenece a un almacén disponible y `permite_saldo_libre=false`.

## 3. Adopción de ubicaciones técnicas existentes

| Código actual | Tratamiento durante expand |
|---|---|
| `RECEPCION_PIEZAS_WIP` | ubicación técnica pendiente de asignación administrativa |
| `RECEPCION_PT` | ubicación técnica pendiente de asignación administrativa |
| `ALMACEN_GENERAL` | ubicación legacy pendiente de clasificación, nunca almacén real automático |
| `MESA_ARMADO` | punto productivo/staging configurable, no almacén libre |
| `TRANSITO_PRODUCCION` | ubicación técnica `TRANSITO`, sin almacén |
| `TRANSITO_ALMACEN` | ubicación técnica `TRANSITO`, sin almacén |

La migración preserva PK/FK y marca las ubicaciones pendientes de clasificar.
El administrador las vincula o retira mediante un setup versionado. Contract
solo vuelve obligatorios los campos cuando no quedan pendientes y la comparación
de saldos sea verde.

## 4. Autorización

Servicio central:

```text
authorize_inventory(actor, capability, warehouse_id, article_class)
```

1. carga actor activo y capacidad;
2. verifica scope vigente;
3. verifica clase;
4. filtra la consulta desde SQL;
5. para ID extranjero devuelve 404 sin side-channel;
6. revalida scope/version antes del commit.

Capacidades nuevas propuestas:

- `ALMACEN_CONFIG_ADMINISTRAR`;
- `ALMACEN_SCOPE_ADMINISTRAR`;
- `INVENTARIO_MOVILIZAR`;
- `INVENTARIO_CONTROL_TRANSVERSAL`.

Las capacidades actuales continúan durante expand y se mapean explícitamente;
no se amplían por nombre de rol.

## 5. API

Base `/api/scm/v1`:

| Método | Ruta | Capacidad |
|---|---|---|
| GET/POST | `/almacenes` | ver / administrar configuración |
| GET/PUT | `/almacenes/{id}` | ver / administrar configuración |
| GET/POST | `/almacenes/{id}/ubicaciones` | ver / administrar configuración |
| GET/POST | `/almacenes/{id}/trabajadores` | scope administrar |
| DELETE | `/almacenes/{id}/trabajadores/{trabajador_id}` | scope administrar |
| GET | `/mi-alcance-almacen` | actor autenticado |

Los comandos usan `Idempotency-Key`, `expected_version`, evento before/after y
transacción única.

## 6. Compatibilidad

US-010H/US-010I siguen leyendo códigos mientras se añade el scope. Durante
expand, la respuesta conserva `ubicacion` y agrega `almacen`. Ningún cliente
antiguo obtiene más datos que antes; el cutover de autorización se activa por
feature flag después del backfill y pruebas por rol.

## 7. Pruebas

| ATDD | Nivel |
|---|---|
| A01/A05/A06 | migración PostgreSQL + integración |
| A02/A03/A04 | autorización/API |
| A07 | servicio/evento/concurrencia |

Primera RED: actor con `INVENTARIO_VER` sin scope consulta saldos globales. Debe
fallar antes de implementar el filtro autoritativo.

## 8. Puertas

- [ ] setup permite crear códigos, jerarquía y punto de pickup sin despliegue;
- [ ] matriz de usuarios/almacenes validada;
- [ ] migración PG real en schema aislado;
- [ ] comparación exacta de saldos antes/después;
- [ ] rollback conserva modelo vigente.
