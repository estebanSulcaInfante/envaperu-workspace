---
tipo: endpoints
estado: contrato-aprobado-pendiente-implementacion
tags: [scm, almacen, kardex, qr, picking, pickup, transferencia]
relaciones:
  - "[[TS-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos]]"
  - "[[TS-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
  - "[[TS-018C_Vistas_Especializadas_y_Control_de_Kardex]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# SCM — operaciones de almacén y transferencias

Base propuesta: `/api/scm/v1`.

## Configuración y alcance

| Método | Ruta | Resultado |
|---|---|---|
| GET/POST | `/almacenes` | lista scoped / alta administrada |
| GET/PUT | `/almacenes/{id}` | detalle / cambio versionado |
| GET/POST | `/almacenes/{id}/ubicaciones` | jerarquía y compatibilidad |
| GET/POST | `/almacenes/{id}/trabajadores` | alcances vigentes |
| DELETE | `/almacenes/{id}/trabajadores/{trabajador_id}` | revocación auditada |
| GET | `/mi-alcance-almacen` | almacenes, clases y acciones del actor |

Una instalación nueva comienza sin almacenes. El alta configura códigos,
jerarquía, compatibilidades y punto de pickup; ningún código de ejemplo es
obligatorio.

## Sesión QR y transferencias

| Método | Ruta | Resultado |
|---|---|---|
| POST | `/operaciones-almacen/sesiones` | sesión con tipo/modalidad/origen/destino |
| GET | `/operaciones-almacen/sesiones/{id}` | candidatas y validaciones |
| POST | `/operaciones-almacen/sesiones/{id}/escanear` | añade una identidad validada |
| DELETE | `/operaciones-almacen/sesiones/{id}/items/{item_id}` | retira candidata |
| POST | `/operaciones-almacen/sesiones/{id}/confirmar` | crea operación/transferencia idempotente |
| GET | `/transferencias` | bandeja scoped y cursor |
| GET | `/transferencias/{id}` | detalle/custodia/línea de tiempo |
| POST | `/transferencias/{id}/marcar-lista` | termina picking |
| POST | `/transferencias/{id}/despachar` | origen → tránsito |
| POST | `/transferencias/{id}/pickup` | handoff en staging |
| POST | `/transferencias/{id}/recibir` | tránsito → destino; diferencias explícitas |
| POST | `/transferencias/{id}/retorno` | flujo inverso |

## Read model

| Método | Ruta | Resultado |
|---|---|---|
| GET | `/inventario/resumen` | métricas por scope/unidad y `as_of` |
| GET | `/inventario/posiciones` | saldos paginados y filtros |
| GET | `/inventario/movimientos` | ledger append-only |
| GET | `/unidades-logisticas/{codigo}/trazabilidad` | ubicación, custodia y eventos autorizados |

## Convenciones

- `X-Actor-Id` durante el adaptador de autenticación vigente;
- comandos con `Idempotency-Key: UUID` y `expected_version`;
- listas con cursor opaco ligado a filtros/scope/`as_of`;
- ID fuera de scope responde 404;
- los comandos incluyen `operation_id`, eventos y movimiento resultante;
- los endpoints actuales US-010H/US-010I permanecen durante expand.

Para modalidad `PICKUP`, el solicitante de Armado confirma en el punto del
almacén: el comando mueve origen→`MESA_ARMADO` y transfiere custodia de forma
atómica. Para `ENTREGA`, despacho y recepción continúan separados por tránsito.

## Sesión QR — request inicial

```json
{
  "tipo": "TRANSFERENCIA",
  "modalidad": "PICKUP",
  "almacen_origen_id": "uuid",
  "ubicacion_origen_id": "uuid",
  "ubicacion_destino_id": "uuid",
  "referencia_tipo": "SOLICITUD_ABASTECIMIENTO",
  "referencia_id": "uuid"
}
```

Escanear envía solo identidad (`label_id` o `codigo`). El servidor devuelve la
unidad resuelta; el cliente no dicta artículo, cantidad, calidad o saldo.

## Integración de alertas

- diferencia declarada en transferencia: evaluación inmediata;
- manga con pesaje final pendiente de recepción: evaluación al superar 24 h;
- ambas crean/actualizan US-010J mediante huella idempotente;
- no existe endpoint de alerta que reciba o mueva inventario.
