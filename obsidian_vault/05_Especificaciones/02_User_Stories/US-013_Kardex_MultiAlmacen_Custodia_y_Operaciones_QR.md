---
tipo: user-story
subtipo: epic
estado: aprobada-dividida
tags: [scm, kardex, multi-almacen, custodia, qr, picking, pickup]
relaciones:
  - "[[US-013A_Almacenes_Ubicaciones_y_Alcance_por_Trabajador]]"
  - "[[US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
  - "[[US-013C_Vistas_Especializadas_y_Control_de_Kardex]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[2026-08-11_Almacenes_Custodia_Transferencias_y_Kardex_Unico]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# US-013: Kardex multi-almacén, custodia y operaciones QR

## Propósito

**Como** equipo de Almacén, Producción y Control  
**Quiero** operar y supervisar un único Kardex con almacenes, ubicaciones,
custodia, sesiones QR y transferencias explícitas  
**Para** conocer saldo y responsable en todo momento, incluso mientras una
manga viaja entre Almacén y Producción.

## Resultado de la épica

El sistema responderá sin inferencias por nombre:

- en qué almacén, ubicación, staging o transferencia está una unidad;
- quién la prepara, entrega, transporta o recibe;
- qué saldo está físico, libre, reservado, en picking, en tránsito, bloqueado o
  consumido;
- qué almacenes/clases puede operar cada trabajador;
- qué acciones faltan y cuánto tiempo lleva una transferencia abierta.

## División vertical

| Historia | Resultado observable |
|---|---|
| [[US-013A_Almacenes_Ubicaciones_y_Alcance_por_Trabajador|US-013A]] | Almacenes y ubicaciones gobernadas; cada actor ve/usa solo su alcance |
| [[US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias|US-013B]] | Un lote QR recorre picking, pickup/despacho, tránsito, recepción y retorno sin desaparecer del Kardex |
| [[US-013C_Vistas_Especializadas_y_Control_de_Kardex|US-013C]] | Piezas/WIP, MP y PT tienen espacios especializados sobre el mismo libro; Control ve el consolidado |

La épica no se implementa directamente ni produce una TS monolítica.

## Invariantes transversales

1. Un traslado nunca crea ni destruye cantidad.
2. En tránsito sigue siendo físico de EnvaPerú y no es saldo libre.
3. Ubicación, Calidad, disposición logística y custodia son dimensiones
   separadas.
4. Capacidad y alcance de datos se validan en backend.
5. El QR identifica; cantidades, estado y compatibilidad se resuelven en
   central.
6. Los movimientos confirmados son append-only e idempotentes.
7. Las tres experiencias especializadas leen el mismo ledger.
8. Pickup/despacho no equivale a consumo.

## Dependencias

- US-010I para nacimiento de existencia;
- US-010H para abastecimiento de piezas/WIP y retorno;
- US-010B para emisión de materias primas;
- roles/capacidades y trabajadores normalizados;
- catálogo de artículos, materiales y unidades logísticas.

## Fuera de alcance inicial

- despacho comercial a clientes y documentos fiscales;
- optimización automática de rutas físicas;
- RFID, GPS o localización en tiempo real;
- conformidad/exportación EPCIS formal;
- contabilidad financiera o valorización monetaria;
- operación offline sin reconciliación central.
