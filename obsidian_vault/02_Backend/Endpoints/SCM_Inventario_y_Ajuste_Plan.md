---
tipo: endpoint-api
estado: implementado-local
tags: [backend, api, scm, inventario, planificacion]
relaciones:
  - "[[Inventario_SCM]]"
  - "[[TS-010P_OP_Demanda_OF_OA_y_Migracion_Documental]]"
fecha_actualizacion: 2026-07-30
---

# SCM — Inventario y ajuste de plan

Base: `/api/scm/v1`. Todos los comandos exigen `X-Actor-Id`; las escrituras
exigen `Idempotency-Key`.

## Inventario

| Método | Ruta | Capacidad |
|---|---|---|
| GET | `/inventario/saldos` | `INVENTARIO_VER` |
| GET | `/inventario/movimientos?limite=100` | `INVENTARIO_VER` |
| POST | `/inventario/movimientos` | Según tipo |

La respuesta de `/inventario/saldos` separa `items` (artículos en `UN`) de
`materiales` (materias primas/recuperados en `KG`).

### Apertura controlada

| Método | Ruta | Capacidad |
|---|---|---|
| GET | `/inventario/aperturas` | `INVENTARIO_VER` |
| GET | `/inventario/aperturas/{id}` | `INVENTARIO_VER` |
| POST | `/inventario/aperturas` | `INVENTARIO_APERTURA_PREPARAR` |
| PUT | `/inventario/aperturas/{id}` | `INVENTARIO_APERTURA_PREPARAR` y ser creador |
| POST | `/inventario/aperturas/{id}/enviar` | `INVENTARIO_APERTURA_PREPARAR` y ser creador |
| POST | `/inventario/aperturas/{id}/resolver` | `INVENTARIO_APERTURA_APROBAR` y ser otro actor |

La resolución exige `version`, `decision` (`APROBAR` o `RECHAZAR`) y
`motivo_resolucion`. La aprobación crea movimientos `SALDO_INICIAL` en una sola
transacción; no hay aplicación parcial.

Tipos manuales:

- `SALDO_INICIAL` → `INVENTARIO_SALDO_INICIAL`;
- `AJUSTE_POSITIVO` / `AJUSTE_NEGATIVO` → `INVENTARIO_AJUSTAR`.

Payload:

```json
{
  "articulo_scm_id": 23,
  "cantidad": 40,
  "tipo": "SALDO_INICIAL",
  "ubicacion_codigo": "ALMACEN_GENERAL",
  "ubicacion_nombre": "Almacén general",
  "motivo": "Conteo de apertura 2026-07-30"
}
```

## Ajuste de metas

`POST /ordenes-produccion/{id}/ajustar-metas`

```json
{
  "version": 2,
  "plan_id": "uuid",
  "content_hash": "sha256",
  "motivo": "Existencia física pendiente de carga",
  "ajustes": [
    {
      "clave": "R1-O2",
      "cantidad_objetivo": 80
    }
  ]
}
```

La cantidad debe estar entre cero y el valor calculado. La respuesta contiene
una nueva revisión `CALCULADO`; la anterior queda `SUPERADO`.
