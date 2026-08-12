---
tipo: endpoint-api
estado: implementacion-local
tags: [backend, api, scm, rutas, operaciones, dag, autorizacion, postgresql]
relaciones:
  - "[[Ruta_Produccion]]"
  - "[[Articulo_SCM]]"
  - "[[SCM_Estructuras_BOM]]"
  - "[[Matriz_Roles_Capacidades_SCM_Produccion]]"
  - "[[TS-010R_Articulos_BOM_Rutas_WIP_y_Perfiles_Empaque]]"
  - "[[DEV-010R_R-Core_Articulos_BOM_Rutas_y_Empaque]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-07-24
---

# API SCM de Rutas de Producción

Base: `/api/scm/v1`.

## Centros de trabajo

| Método y ruta | Capacidad | Uso |
|---|---|---|
| `GET /centros-trabajo` | `RUTA_VER` | Listar centros, opcionalmente con `?activo=true|false`. |
| `POST /centros-trabajo` | `RUTA_ADMINISTRAR` | Crear un centro; el código se genera automáticamente. |
| `PATCH /centros-trabajo/{id}` | `RUTA_ADMINISTRAR` | Editar nombre, tipo o estado con `version`. |

Los tipos vigentes son `INYECCION`, `PREARMADO`, `ENSAMBLE`, `ACABADO` y `EMPAQUE`.

El alta recibe únicamente `nombre` y `tipo`. El código se reserva dentro de la
transacción mediante `correlativo_catalogo`, clave `CENTRO_TRABAJO`, con formato
`CT-######`. No se admite un código enviado por el cliente; las ediciones
posteriores mantienen la identidad inmutable.

## Revisiones de ruta

| Método y ruta | Capacidad | Uso |
|---|---|---|
| `GET /productos/{sku}/rutas` | `RUTA_VER` | Listar revisiones del producto terminado. |
| `POST /productos/{sku}/rutas` | `RUTA_ADMINISTRAR` | Crear la siguiente revisión en borrador. |
| `GET /rutas/{id}` | `RUTA_VER` | Consultar operaciones, aristas y hash. |
| `PUT /rutas/{id}` | `RUTA_ADMINISTRAR` | Reemplazar operaciones y precedencias usando `version`. |
| `POST /rutas/{id}/aprobar` | `RUTA_APROBAR` | Publicar; exige `Idempotency-Key`. |
| `POST /rutas/{id}/retirar` | `RUTA_APROBAR` | Retirar una aprobación; exige `Idempotency-Key`. |

Todos los endpoints exigen `X-Actor-Id`. Las capacidades se resuelven en el servidor.

## Borrador

```json
{
  "notas": "Ruta estándar",
  "operaciones": [
    {
      "clave": "INYECTAR",
      "secuencia_visible": 10,
      "nombre": "Inyección",
      "tipo": "INYECCION",
      "executor_kind": "OP_OT",
      "centro_trabajo_id": 1,
      "articulo_salida_id": 25,
      "permite_concurrente": false
    },
    {
      "clave": "PREARMAR",
      "secuencia_visible": 20,
      "nombre": "Prearmado",
      "tipo": "PREARMADO",
      "executor_kind": "ORDEN_OPERACION",
      "centro_trabajo_id": 2,
      "articulo_salida_id": 31,
      "estructura_revision_id": 8,
      "permite_concurrente": true
    }
  ],
  "precedencias": [
    {
      "anterior_clave": "INYECTAR",
      "siguiente_clave": "PREARMAR"
    }
  ]
}
```

La ruta no recibe cantidades de componentes. La composición pertenece a [[SCM_Estructuras_BOM]].

## Reglas de aprobación

- Las precedencias forman un DAG; `secuencia_visible` solo ordena la interfaz.
- Debe existir un único nodo terminal y su salida debe ser el artículo del producto objetivo.
- Una operación intermedia no puede producir `PRODUCTO_TERMINADO`.
- `OP_OT` no referencia una estructura paralela.
- `ORDEN_OPERACION` exige una estructura aprobada cuyo resultado coincida con la salida.
- El creador no puede aprobar su propia revisión.
- Una nueva aprobación retira la aprobación vigente anterior.
- Operaciones y aristas publicadas son inmutables, incluso ante SQL directo en PostgreSQL.

## Errores estables

| Código | Significado |
|---|---|
| `ROUTE_CYCLE` | Las aristas forman un ciclo. |
| `EXECUTOR_KIND_INCOMPATIBLE` | La autoridad o estructura de una operación es ambigua/incompatible. |
| `OUTPUT_ARTICLE_INCOMPATIBLE` | El terminal o una salida intermedia incumple el tipo esperado. |
| `ROUTE_NOT_EDITABLE` | Se intentó editar una revisión publicada. |
| `ROUTE_NOT_APPROVABLE` | La transición de aprobación no es válida. |
| `CREATOR_CANNOT_APPROVE` | El creador intentó aprobar su propia revisión. |
| `STALE_VERSION` | Conflicto de versión optimista. |

## PostgreSQL

La aprobación toma `pg_advisory_xact_lock(hashtext('scm_route_approval'))`, ejecuta un CTE recursivo de alcanzabilidad y publica el `content_hash` canónico de operaciones y aristas.
