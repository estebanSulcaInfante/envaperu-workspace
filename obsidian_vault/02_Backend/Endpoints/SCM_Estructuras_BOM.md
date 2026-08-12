---
tipo: endpoint-api
estado: implementacion-local
tags: [backend, api, scm, bom, estructuras, autorizacion, postgresql]
relaciones:
  - "[[Articulo_SCM]]"
  - "[[Matriz_Roles_Capacidades_SCM_Produccion]]"
  - "[[TS-010R_Articulos_BOM_Rutas_WIP_y_Perfiles_Empaque]]"
  - "[[DEV-010R_R-Core_Articulos_BOM_Rutas_y_Empaque]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-08-04
---

# API SCM de Estructuras/BOM

Base: `/api/scm/v1`.

## Endpoints

| Método y ruta | Capacidad | Uso |
|---|---|---|
| `GET /articulos/{id}/estructuras` | `ESTRUCTURA_VER` | Listar revisiones del artículo. |
| `POST /articulos/{id}/estructuras` | `ESTRUCTURA_ADMINISTRAR` | Crear un borrador con componentes. |
| `GET /estructuras/{id}` | `ESTRUCTURA_VER` | Consultar revisión, líneas y hash. |
| `PUT /estructuras/{id}` | `ESTRUCTURA_ADMINISTRAR` | Reemplazar el contenido de un borrador usando `version`. |
| `POST /estructuras/{id}/enviar` | `ESTRUCTURA_ADMINISTRAR` | Enviar a aprobación; exige `Idempotency-Key`. |
| `POST /estructuras/{id}/aprobar` | `ESTRUCTURA_APROBAR` | Aprobar con actor distinto; exige `Idempotency-Key`. |
| `POST /estructuras/{id}/publicar` | `ESTRUCTURA_PUBLICAR_DIRECTO` | Publicar directamente un borrador como jefatura o Gerencia; exige `Idempotency-Key`. |
| `POST /estructuras/{id}/rechazar` | `ESTRUCTURA_APROBAR` | Rechazar con actor distinto y motivo obligatorio; exige `Idempotency-Key`. |
| `POST /estructuras/{id}/descartar` | `ESTRUCTURA_ADMINISTRAR` | Descartar el borrador propio con motivo, sin borrado físico; exige `Idempotency-Key`. |
| `POST /estructuras/{id}/retirar` | `ESTRUCTURA_APROBAR` | Retirar una revisión aprobada; exige `Idempotency-Key`. |

## Continuación UAT implementada — 2026-08-04

La revisión `f64b3d9e5a81` cerró la brecha entre los estados declarados y las
transiciones expuestas. Rechazar y descartar son comandos idempotentes,
auditados y terminales; no eliminan filas.

Contratos implementados:

| Método y ruta | Capacidad | Uso |
|---|---|---|
| `POST /estructuras/{id}/rechazar` | `ESTRUCTURA_APROBAR` | Rechazar una revisión pendiente con motivo obligatorio y actor distinto del creador. |
| `POST /estructuras/{id}/descartar` | `ESTRUCTURA_ADMINISTRAR` | Descartar un borrador propio con motivo, sin borrado físico. |

La API debe además impedir que un artículo clase `PIEZA_COLOR` sea resultado
de una estructura. Para el piloto, los resultados válidos son
`SUBENSAMBLE_WIP` y `PRODUCTO_TERMINADO`; los componentes válidos son
`PIEZA_COLOR` y `SUBENSAMBLE_WIP`.

Todos exigen `X-Actor-Id`; el servidor deriva capacidades desde [[Trabajador]] y [[RolOperativo]].

## Borrador

```json
{
  "notas": "Estructura estándar",
  "componentes": [
    {
      "secuencia": 1,
      "articulo_id": 25,
      "cantidad": "2",
      "unidad": "UN",
      "merma_tecnica_pct": "1.2500"
    }
  ]
}
```

`cantidad` se persiste como `Numeric(15,6)`. En R2 la unidad es exclusivamente `UN`, por lo que la cantidad debe ser entera.

## Estados

```text
BORRADOR -> PENDIENTE_APROBACION -> APROBADA -> RETIRADA
    |                             \-> RECHAZADA
    |-> APROBADA  (publicación directa de jefatura)
    \-> DESCARTADA
```

- Solo `BORRADOR` admite edición.
- Una nueva revisión aprobada retira la aprobación vigente anterior.
- La respuesta aprobada incluye `content_hash`.
- Componentes y contenido aprobado son inmutables también ante SQL directo en PostgreSQL.

## Errores estables

| Código | Significado |
|---|---|
| `STRUCTURE_CYCLE` | La candidata introduce un ciclo directo o indirecto. |
| `CREATOR_CANNOT_APPROVE` | El creador intentó aprobar su propia revisión. |
| `STRUCTURE_NOT_EDITABLE` | Se intentó editar una revisión no borrador. |
| `STRUCTURE_NOT_APPROVABLE` | Transición de aprobación inválida. |
| `STRUCTURE_NOT_PUBLISHABLE` | La publicación directa no recibió un borrador. |
| `DISCRETE_QUANTITY_REQUIRED` | Una cantidad `UN` posee fracción. |
| `STALE_VERSION` | Conflicto de versión optimista. |
| `IDEMPOTENCY_CONFLICT` | La clave fue reutilizada con otro comando. |

## Concurrencia

PostgreSQL serializa aprobaciones mediante `pg_advisory_xact_lock` y ejecuta un CTE recursivo sobre revisiones aprobadas más la candidata. Dos revisiones concurrentes que juntas formarían un ciclo no pueden publicarse ambas.
