---
tipo: frontend-view
estado: aprobada-pendiente-implementacion
tags: [frontend, scm, almacen, kardex, qr, picking, pickup, control]
relaciones:
  - "[[US-013_Kardex_MultiAlmacen_Custodia_y_Operaciones_QR]]"
  - "[[TS-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
  - "[[TS-018C_Vistas_Especializadas_y_Control_de_Kardex]]"
  - "[[UAT_TS-018_Kardex_MultiAlmacen_Pickup_y_Custodia]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# Vista US-013: Kardex y operaciones de almacén

## Principio de navegación

`Almacén e inventario` es el espacio de ejecución. `Control` es observación
transversal. La pantalla no pregunta al usuario qué rol pretende ser; deriva
sus almacenes y clases del scope vigente.

Si no existe configuración, se muestra un setup de almacén/ubicaciones en lugar
de asumir códigos. Solo el administrador autorizado puede completarlo.

## Inicio operativo

Encabezado persistente:

```text
Almacén activo | tipo de inventario | ubicación | operación | actor/custodia
```

Acciones principales:

- Recibir;
- Preparar picking;
- Entregar / Pickup;
- Transferir;
- Recibir retorno;
- Consultar Kardex.

Una operación abre un workspace separado del dashboard y fija origen/destino
antes del primer QR.

## Workspace de escaneo

```text
┌ Contexto fijo: Transferencia · ALM-PIEZAS → MESA ARMADO ┐
│ [ Escanee QR _________________________________________ ] │
│ Válidas 12 · Rechazadas 1 · Duplicadas 0                │
│ Lista de unidades y motivo accionable                    │
│ Efecto: origen → tránsito; no consume piezas             │
│                         [Revisar y confirmar 12]          │
└───────────────────────────────────────────────────────────┘
```

- Enter procesa y devuelve foco;
- éxito/error no dependen solo de color;
- puede retirar una candidata antes de confirmar;
- el lote no se confirma si el scope/origen/saldo cambió;
- cancelar no mueve Kardex.

## Bandeja de transferencias

Columnas/tarjetas:

- código y documento causal;
- origen → destino;
- preparación/pickup/despacho/recepción;
- unidades y diferencias;
- custodio actual;
- antigüedad y siguiente acción.

Quick filters: `Por preparar`, `Lista para pickup`, `En tránsito`, `Por recibir`,
`Con diferencia`, `Retornos`.

En el piloto, `Pickup` se dirige a la persona solicitante de Armado. La pantalla
muestra antes de confirmar: “Aceptas custodia y acreditas estas mangas en Mesa
de Armado; todavía no las consumes”.

## Vistas por especialidad

### Piezas y WIP

Entrada desde Fabricación, Calidad, existencias por pieza-color, solicitudes de
Armado, picking, mesa y retornos.

### Materias primas

Lotes/kg, Calidad/documentos, reserva/emisión/devolución a Fabricación,
premezclas y recuperado.

### Producto terminado

Entrada desde Armado, Calidad, ubicación, stock disponible y futura preparación
de despacho.

## Control de inventario

Ruta propuesta `/control/inventario`. Muestra resumen por almacén y unidad,
posiciones, movimientos, transferencias e incidencias. Es read-only por defecto;
las acciones son deep links a la operación si el actor tiene capacidad/scope.

Alertas visibles: diferencias inmediatas y mangas pesadas que llevan más de
24 horas sin recepción. El contador enlaza a la misma alerta de US-010J.

## Estado vacío y bloqueos

- sin almacén asignado: explicar quién debe asignarlo;
- capacidad faltante: mostrar consulta o handoff, no botón muerto;
- sin transferencias: indicar cómo nace una solicitud;
- snapshot viejo: mostrar `as_of` y error de refresh;
- unidad fuera de scope: no revelar existencia.

## Responsive y accesibilidad

- 1440: tabla densa + panel de detalle;
- 768: tabla simplificada/drawer;
- 390: tarjetas y acción primaria sticky sin cubrir contenido;
- orden Tab lógico, foco visible, lector Enter, live region moderada;
- cantidades siempre incluyen unidad y estados incluyen texto/icono.

## Diferencia con las vistas actuales

`/produccion/recepcion-mangas` y `/produccion/kardex` continúan durante expand.
La vista nueva no debe redirigirlas hasta demostrar equivalencia de recepción,
Calidad, reversa, saldos y permisos.
