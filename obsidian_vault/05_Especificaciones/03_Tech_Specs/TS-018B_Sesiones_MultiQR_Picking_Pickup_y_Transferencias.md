---
tipo: tech-spec
estado: aprobada-para-desarrollo-local
user_story: "[[US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
tags: [scm, qr, picking, pickup, transferencia, custodia, kardex, idempotencia]
relaciones:
  - "[[Transferencia_Inventario]]"
  - "[[TS-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
  - "[[SCM_Operaciones_Almacen_y_Transferencias]]"
  - "[[UAT_TS-018_Kardex_MultiAlmacen_Pickup_y_Custodia]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# TS-018B: sesiones multi-QR, picking, pickup y transferencias

## 1. Objetivo

Unificar la mecánica de entrada, salida, transferencia y retorno sin reemplazar
los documentos causales de recepción, abastecimiento o producción.

## 2. Modelo

### `scm_sesion_operacion_almacen`

Cabecera temporal por actor: tipo, modalidad, almacén/ubicación origen/destino,
estado `ABIERTA | LISTA | CONFIRMADA | CANCELADA | EXPIRADA`, versión y contexto.

### `scm_sesion_operacion_item`

Unidad candidata: identidad QR, manga/lote, artículo/material, cantidad snapshot,
estado de validación y orden de escaneo. Unique por sesión+unidad.

### `scm_transferencia_inventario`

Documento durable: origen/destino, estado, modalidad, documento causal,
preparador/despachador/receptor/custodio, timestamps, incidencia y versión.

### `scm_transferencia_item`

Referencia unidad/cantidad y movimientos de salida, tránsito, entrada,
consumo/retorno aplicables.

## 3. Estados

```text
BORRADOR -> EN_PICKING -> LISTA_PARA_ENTREGA
  -> EN_TRANSITO -> RECIBIDA -> CERRADA

LISTA_PARA_ENTREGA -> PICKUP_CONFIRMADO -> EN_TRANSITO/RECIBIDA

RECIBIDA -> PENDIENTE_RETORNO -> EN_TRANSITO_RETORNO
  -> RETORNADA -> CERRADA
```

`PICKUP_CONFIRMADO` registra el handoff. En el piloto, el solicitante de Armado
recoge en el almacén y acepta custodia para `MESA_ARMADO`: salida de origen y
entrada a Mesa ocurren en un comando atómico, pero se persisten como dos eventos
distinguibles con el mismo `operation_id` raíz. No existe estado de tránsito
entre ambos. La modalidad `ENTREGA` sí conserva tránsito y recepción separados.

## 4. Ledger

En despacho:

```text
origen:   cantidad_fisica -= q; cantidad_reservada -= q
transito: cantidad_fisica += q; cantidad_no_disponible += q
```

En recepción:

```text
transito: cantidad_fisica -= q; cantidad_no_disponible -= q
destino:  cantidad_fisica += q; disposición según destino/calidad
```

En pickup directo:

```text
origen: cantidad_fisica -= q; cantidad_reservada -= q
mesa:   cantidad_fisica += q; mantiene reserva/asignación para Armado
```

Cada frontera crea movimientos append-only enlazados. La suma física global se
mantiene. Reservar/picking no ejecuta estas ecuaciones.

## 5. API

| Método | Ruta | Uso |
|---|---|---|
| POST | `/operaciones-almacen/sesiones` | abrir con tipo/origen/destino/modalidad |
| GET | `/operaciones-almacen/sesiones/{id}` | estado y candidatas |
| POST | `/operaciones-almacen/sesiones/{id}/escanear` | resolver y añadir QR |
| DELETE | `/operaciones-almacen/sesiones/{id}/items/{item_id}` | retirar antes de confirmar |
| POST | `/operaciones-almacen/sesiones/{id}/confirmar` | materializar entrada/transferencia |
| POST | `/transferencias/{id}/marcar-lista` | terminar picking |
| POST | `/transferencias/{id}/despachar` | origen a tránsito |
| POST | `/transferencias/{id}/pickup` | handoff al receptor |
| POST | `/transferencias/{id}/recibir` | tránsito a destino, admite diferencias |
| POST | `/transferencias/{id}/retorno` | iniciar flujo inverso |
| GET | `/transferencias` y `/{id}` | bandeja/detalle scoped |

Todos los comandos exigen scope, `Idempotency-Key` UUID y `expected_version`.

## 6. Confirmación multi-QR

- límite 100;
- el escaneo es read/validate, no movimiento;
- una candidata inválida no se persiste como válida;
- al confirmar se bloquean sesión, unidades y saldos en orden estable;
- cualquier conflicto revierte el lote completo y devuelve items accionables;
- replay devuelve exactamente la transferencia creada;
- una segunda sesión pierde por exclusividad, no duplica saldo.

## 7. Integración con US-010H/US-010I

- US-010I puede abrir sesión `ENTRADA` y mantener las verificaciones físicas y
  Calidad por unidad.
- US-010H aporta solicitud/BOM/reserva y adopta la transferencia para el
  recorrido Almacén→Armado→retorno.
- Estados/códigos técnicos actuales siguen como alias de proyección durante
  expand; no se doble-escriben movimientos.

## 8. Diferencias e incidencias

Recepción parcial mantiene unidades no escaneadas `EN_TRANSITO` y crea
incidencia. No se distribuyen diferencias por cantidad. Resolver exige hallar,
retornar, compensar con aprobación o registrar pérdida/merma mediante historia
separada.

La evaluación de alertas añade:

- `TRANSFERENCIA_DIFERENCIA`: inmediata al confirmar faltante/sobrante;
- `MANGA_PESADA_SIN_RECEPCION`: pesaje final vigente con manga pendiente de
  recepción durante más de 24 horas, umbral versionado/configurable.

Ambas usan huella idempotente y son visibles en Control/Alertas. Evaluar,
reconocer o resolver no ejecuta movimientos.

## 9. Pruebas

| ATDD | Nivel |
|---|---|
| B01/B02/B10 | UI + contrato |
| B03/B04/B05/B07 | integración ledger |
| B06/B09 | dominio/alertas/read model |
| B08 | PostgreSQL concurrente |
| B11 | regla de alerta + reloj controlado |

Primera RED: despachar una manga debe crear transferencia/origen→tránsito sin
cambiar el físico global y sin depender del string `TRANSITO_PRODUCCION` como
única explicación.

## 10. Puertas

- [x] pickup habitual: solicitante de Armado confirma al recoger en Almacén y
  acredita directamente `MESA_ARMADO`;
- [ ] configurar en cada almacén el punto visible de pickup;
- [ ] lector real y lote de 20 mangas;
- [ ] UAT diferencia 10→9;
- [ ] comparación US-010H antigua/nueva sin diferencias de saldo;
- [ ] alertas de tránsito configuradas, sin SLA inventado en código.
