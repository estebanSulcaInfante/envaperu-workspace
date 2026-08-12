---
tipo: modelo_objetivo
estado: propuesto-us-013
tags: [dominio, scm, transferencia, custodia, picking, pickup, transito, qr]
relaciones:
  - "[[Inventario_SCM]]"
  - "[[Almacen_SCM]]"
  - "[[Ubicacion_Inventario]]"
  - "[[Unidad_Logistica]]"
  - "[[US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# Transferencia de Inventario

Documento operativo que conserva el recorrido físico y la custodia de una o
varias unidades logísticas entre origen y destino.

## Cabecera

- tipo `ENTRADA | SALIDA | TRANSFERENCIA | RETORNO`;
- modalidad `ENTREGA | PICKUP`;
- almacén/ubicación origen y destino;
- documento causal: recepción, solicitud de abastecimiento, OT/OA, devolución;
- preparador, despachador, receptor y custodio actual;
- fechas de creación, listo, despacho, pickup, recepción y cierre;
- estado, versión, idempotencia y motivo de excepción.

## Líneas y escaneos

Cada línea referencia una manga/lote y cantidad. Un escaneo en borrador no
mueve Kardex. La confirmación valida identidad, Calidad, saldo, reserva,
compatibilidad y exclusividad concurrente.

La sesión admite 1..100 unidades. Una candidata inválida se rechaza antes de
ingresar al lote; la confirmación del lote válido es transaccional e idempotente.

## Picking, pickup y custodia

- reservar compromete, no mueve;
- picking identifica/prepara unidades;
- staging indica listas para entrega;
- pickup registra que el receptor recoge en el punto acordado;
- despacho retira del origen y acredita posición de tránsito;
- recepción retira de tránsito y acredita destino;
- consumo es un evento productivo posterior.

### Pickup directo a Mesa de Armado

Para el piloto, la persona que requirió las mangas las recoge físicamente en el
almacén. Su confirmación QR es aceptación de custodia para `MESA_ARMADO`; el
comando registra salida de origen y entrada a Mesa en una transacción, sin
posición intermedia de tránsito. Esto no afirma incorporación al producto: el
consumo continúa siendo un evento posterior de Armado.

La modalidad `ENTREGA` mantiene tránsito y recepción separados cuando otro
actor transporta, el recorrido es largo o planta requiere prueba de llegada.

## Posición en tránsito

La transferencia es la autoridad. Puede existir una proyección técnica de
saldo `TRANSITO`, pero no se muestra como almacén. Debe conservar:

- origen y destino;
- último punto de lectura;
- custodio;
- fecha límite/antigüedad;
- recepción pendiente e incidencias.

Una diferencia de unidades crea incidencia inmediata. Una unidad pesada aún no
recibida no pertenece a una transferencia de almacén, pero su antigüedad se
supervisa desde la frontera Pesaje→Recepción.

## Correcciones

No se edita un movimiento confirmado. Cancelar antes del despacho libera
reservas. Una diferencia posterior genera evento compensatorio o incidencia
segregada sin borrar el recorrido original.
