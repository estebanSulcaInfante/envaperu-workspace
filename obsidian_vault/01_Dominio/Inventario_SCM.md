---
tipo: modelo_objetivo
estado: implementado-piloto-local
tags: [dominio, inventario, kardex, planificacion, reservas]
relaciones:
  - "[[Articulo_SCM]]"
  - "[[Ubicacion_Inventario]]"
  - "[[Orden_Produccion]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
  - "[[US-013_Kardex_MultiAlmacen_Custodia_y_Operaciones_QR]]"
  - "[[Almacen_SCM]]"
  - "[[Transferencia_Inventario]]"
  - "[[2026-08-03_Alcance_Piloto_Apertura_Inicial_sin_Recepcion_Compras]]"
fecha_creacion: 2026-07-30
fecha_actualizacion: 2026-08-11
---

# Inventario SCM

Libro normalizado y único de existencias por [[Articulo_SCM]] y ubicación. No
existe un Kardex digital legacy por migrar: las existencias anteriores viven
solo en conteos físicos y papel, y entran al SCM exclusivamente mediante la
apertura inicial controlada. Los pesajes históricos se preservan en su registro
propio, pero no se interpretan como saldos de inventario.

## Magnitudes

```text
saldo libre = existencia física - cantidad reservada - cantidad no disponible
```

- **existencia física:** cantidad recibida o cargada mediante un movimiento;
- **reservada:** cantidad comprometida por planes confirmados;
- **no disponible:** existencia pendiente, bloqueada o rechazada por Calidad;
- **libre:** única cantidad que puede reducir nuevas propuestas.

## MovimientoInventario

Hecho append-only con tipo, variación, saldo resultante, motivo, actor, fecha e
idempotencia. El arranque usa `SALDO_INICIAL` sin inventar mangas. Las
correcciones usan ajustes auditados; nunca se edita o elimina un movimiento.

## Apertura inicial controlada

El corte inicial se prepara como un lote versionado, no como movimientos
individuales ejecutados durante el conteo. Sus estados son `BORRADOR`,
`PENDIENTE_APROBACION`, `APLICADO` y `RECHAZADO`.

- Almacén prepara o importa las líneas y las envía.
- Otro actor con rol Jefe de Producción revisa y resuelve; el creador no puede
  autoaprobarse aunque acumule ambas capacidades.
- Aprobar aplica todas las líneas en una sola transacción; rechazar no modifica
  saldos.
- Cada artículo/material y ubicación solo admite una apertura aplicada y debe
  tener saldo previo cero.
- Una línea `PENDIENTE` suma existencia física, pero toda su cantidad queda no
  disponible hasta una resolución posterior.

El sublibro de artículos usa `UN`. Materia prima y material recuperado conservan
su identidad `ScmMaterial` y un sublibro en `KG`; no se los fuerza a convertirse
en `ArticuloSCM` para iniciar el piloto.

## ReservaInventario

Compromiso entre un saldo, una línea OP y un plan confirmado. Estados:
`RESERVADA`, `CONSUMIDA` o `LIBERADA`.

Reservar no mueve el Kardex. Consumir requiere un hecho operativo posterior.

## Abastecimiento interno

Una manga recibida y liberada puede reservarse para una OT de Armado mediante
[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas|US-010H]].
Reserva, picking, despacho, recepción en Armado, consumo y retorno permanecen
separados:

- reservar reduce saldo libre, pero no mueve existencia;
- despachar y recibir transfieren ubicación/custodia en dos pasos;
- solo `CERRAR_MANGA_ARMADO` consume la cantidad incorporada;
- un remanente conserva saldo e identidad hasta consumirse o retornar;
- toda división física crea una unidad hija y conserva genealogía.

## Frontera con mangas

Una manga pesada no ingresa automáticamente. US-010I mantiene la recepción QR
de Almacén como autoridad para crear el movimiento de ingreso.

La recepción crea una existencia 1:1 con Calidad `PENDIENTE` y movimiento
`INGRESO_PRODUCCION`. Un rechazo antes de
aceptar custodia no crea inventario; un bloqueo o rechazo posterior conserva
existencia y genealogía, pero retira disponibilidad.

Una corrección autorizada posterior al ingreso crea un ajuste compensatorio
enlazado y actualiza la proyección de la misma existencia; no borra el pesaje,
la recepción ni el movimiento inicial.

## Merma recuperable

La merma recuperable almacenada es existencia física en kg, pero posee
disponibilidad exclusiva `DISPONIBLE_MOLIENDA`. No cubre demanda de
`PiezaColor`, WIP, producto terminado ni material de segunda.

El peso al almacenar acredita el saldo de la bolsa. La [[Orden_Molienda]] lo
reserva y el peso inmediatamente anterior al molino determina el débito real.
La diferencia de custodia se registra sin sumar los dos pesajes ni reescribir el
movimiento original.

## Evolución multi-almacén propuesta

[[US-013_Kardex_MultiAlmacen_Custodia_y_Operaciones_QR|US-013]] conserva este
libro único y añade [[Almacen_SCM]], scope por trabajador y
[[Transferencia_Inventario]]. En tránsito continúa dentro del físico global,
queda fuera del saldo libre y conserva origen, destino y custodio. Las vistas
de MP, Piezas/WIP y PT son proyecciones del mismo ledger, no Kardex separados.

Hasta aprobar TS-018, los códigos técnicos de US-010H siguen siendo la
implementación vigente; esta sección no cambia contratos ni autoriza migración.
