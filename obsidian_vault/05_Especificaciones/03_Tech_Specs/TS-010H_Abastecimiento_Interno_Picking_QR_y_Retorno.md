---
tipo: tech-spec
estado: aprobada-desarrollo-local
us: "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, abastecimiento, picking, qr, ot-armado, kardex, retorno, api, frontend, atdd]
fecha_creacion: 2026-08-03
fecha_actualizacion: 2026-08-03
---

# TS-010H: Abastecimiento interno, picking QR y retorno

## 1. Objetivo y corte implementable

Conectar una OA liberada con su ejecución diaria y con las mangas físicas que
Almacén entrega a la mesa de Armado:

```text
OA liberada
  -> OT ENSAMBLE por fecha, turno, mesa, responsable y cuota
  -> solicitud derivada de BOM × cuota
  -> reserva exacta de mangas liberadas por Calidad
  -> picking
  -> despacho de Almacén
  -> recepción en MESA_ARMADO
  -> consumo al cerrar manga de salida (TS-010F)
  -> retorno trazable del remanente
```

Esta TS implementa la OT común, la solicitud, reserva, picking, despacho,
recepción y retorno. El débito por consumo y su genealogía exacta se ejecutan
atómicamente desde `CERRAR_MANGA_ARMADO`, contrato dueño de TS-010F; H no
ofrece un botón independiente que pueda inventar consumo.

Cuando una OA ya tiene al menos una OT de Armado, su cierre heredado queda
bloqueado con `OA_TRACEABLE_CLOSE_REQUIRED`. Desde ese punto la acreditación
solo puede continuar por mangas, consumo trazable y el cierre atómico de
[[TS-010F]].

## 2. Invariantes

1. Una OT de Armado pertenece a una sola OA y conserva una cuota positiva.
2. La suma de cuotas OT activas no excede el objetivo de la OA.
3. La necesidad se deriva de la BOM congelada de la OA y la cuota de la OT.
4. Reservar no mueve existencia física.
5. En el piloto solo se reserva la manga completa y totalmente libre.
6. Solo una existencia `LIBERADA` y `RECIBIDA_ALMACEN` puede reservarse.
7. Despacho y recepción son eventos separados, aunque los ejecute una misma persona.
8. En tránsito, la existencia no permanece disponible en origen ni aparece aún en destino.
9. La ubicación de staging es `MESA_ARMADO`.
10. El retorno conserva identidad, artículo, Calidad y saldo remanente.
11. El retorno libera la reserva solo al ser recibido nuevamente por Almacén.
12. Todo comando mutante es idempotente y toda transición deja evento auditable.

## 3. Extensión de OT común

`registro_diario_produccion` incorpora:

| Campo | Regla |
|---|---|
| `tipo_ot` | `FABRICACION` o `ENSAMBLE`. |
| `orden_operacion_id` | OA exacta para `ENSAMBLE`. |
| `centro_trabajo_id` | Mesa/centro de Armado; sustituye máquina en OT de Armado. |
| `responsable_id` | Responsable de Armado. |
| `cantidad_objetivo` | Cuota diaria. |
| `cantidad_confirmada` | Proyección posterior desde cierres TS-010F. |

Una OT de Fabricación exige `maquina_id`; una OT de Armado exige
`centro_trabajo_id`. No se crea otro documento paralelo.

## 4. Modelo de abastecimiento

### `scm_solicitud_abastecimiento`

Una por OT de Armado. Estados:

```text
SOLICITADA -> EN_PREPARACION -> LISTA -> DESPACHADA -> RECIBIDA -> CERRADA
                                   \-> INCIDENCIA
                         cualquier estado permitido -> CANCELADA
```

### `scm_solicitud_abastecimiento_linea`

Una por componente BOM; conserva artículo, requerido, cantidad por salida y
merma técnica congelada.

### `scm_asignacion_abastecimiento`

Relaciona línea y `scm_existencia_manga`. Conserva cantidad asignada,
consumida, retornada y saldo. Estados:

```text
RESERVADA -> EN_PICKING -> EN_TRANSITO_PRODUCCION -> EN_STAGING_ARMADO
  -> ABIERTA_EN_CONSUMO -> CONSUMIDA
  -> PENDIENTE_RETORNO -> EN_TRANSITO_ALMACEN -> RETORNADA
```

## 5. Kardex y ubicación

Los traslados generan pares append-only de movimientos de salida/entrada y
actualizan el saldo agregado de origen/destino en una sola transacción:

- `TRASLADO_SALIDA` / `TRASLADO_ENTRADA`;
- `RETORNO_SALIDA` / `RETORNO_ENTRADA`.

Ubicaciones técnicas: `TRANSITO_PRODUCCION`, `MESA_ARMADO` y
`TRANSITO_ALMACEN`. La existencia 1:1 de la manga cambia de ubicación sin
cambiar de identidad.

## 6. API

| Método y ruta | Capacidad |
|---|---|
| `GET/POST /ordenes-armado/{id}/ots` | `OT_VER` / `OT_CREAR` |
| `POST /ots/{id}/abastecimiento` | `ABASTECIMIENTO_SOLICITAR` |
| `GET /abastecimiento[/{id}]` | `ABASTECIMIENTO_VER` |
| `POST /abastecimiento/{id}/mangas` | `PICKING_PREPARAR` |
| `POST /abastecimiento/{id}/lista` | `PICKING_PREPARAR` |
| `POST /abastecimiento/{id}/despachar` | `PICKING_DESPACHAR` |
| `POST /abastecimiento/{id}/recibir` | `ABASTECIMIENTO_RECIBIR` |
| `POST /abastecimiento/asignaciones/{id}/retorno` | `ABASTECIMIENTO_DEVOLVER` |
| `POST /abastecimiento/asignaciones/{id}/despachar-retorno` | `ABASTECIMIENTO_DEVOLVER` |
| `POST /abastecimiento/asignaciones/{id}/recibir-retorno` | `RETORNO_RECIBIR` |

## 7. UX por actor

- Jefe/Responsable de Armado: crear OT, solicitar, verificar entrega y devolver remanente.
- Almacén: cola priorizada, escaneo QR, cobertura visible, marcar lista y despachar.
- Recepción de Armado: confirmar el lote físico recibido, sin editar lo preparado.
- Jefe de Producción: visión completa y capacidades de excepción futuras.
- Consulta/Gerencia: solo lectura y trazabilidad de actores/horas.

Cada vista debe mostrar “qué sigue”, progreso por componente y una explicación
directa cuando una acción está bloqueada.

## 8. Estrategia de pruebas

- modelo: recurso exclusivo de OT, estados y cantidades;
- servicio: cuota OA, BOM × cuota, Calidad, doble reserva y cobertura completa;
- integración: reserva sin movimiento; despacho/recepción con pares de Kardex;
- retorno: no libera al solicitar/despachar y sí al recibir;
- contrato: permisos, idempotencia y `VERSION_CONFLICT`;
- UI: estados vacío/carga/error/éxito y acciones según capacidades;
- PostgreSQL: migración, checks, FKs y bloqueo concurrente.

La UAT con actores de Envaperú sigue siendo condición para desplegar, no para
continuar el desarrollo local ya autorizado.
