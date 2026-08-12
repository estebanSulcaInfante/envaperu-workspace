---
tipo: user-story
subtipo: historia-hija
estado: aprobada-para-desarrollo-local
epica: "[[US-013_Kardex_MultiAlmacen_Custodia_y_Operaciones_QR]]"
tags: [scm, qr, picking, pickup, transferencia, custodia, transito, atdd]
relaciones:
  - "[[Transferencia_Inventario]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
  - "[[TS-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# US-013B: sesiones multi-QR, picking, pickup y transferencias

## Historia

**Como** almacenero o receptor de Producción  
**Quiero** abrir una operación con origen/destino y escanear una o varias
unidades antes de entregarlas o recogerlas  
**Para** mover custodia y Kardex sin perder existencias ni confirmar mangas
equivocadas.

## Criterios de aceptación

### AGP-B01 — Sesión de entrada por lote

**Dado** el almacén y ubicación de recepción configurados por planta  
**Cuando** se escanean 12 mangas válidas y se confirma el lote  
**Entonces** cada una genera su ingreso idempotente y la sesión muestra 12/12;
un replay no duplica movimientos.

### AGP-B02 — Escaneo inválido aislado

**Dado** un lote en borrador  
**Cuando** se escanea una manga incompatible o repetida  
**Entonces** no entra al lote, se mantiene el foco QR y ninguna candidata válida
se pierde.

### AGP-B03 — Reserva y picking no mueven

**Cuando** una manga disponible se reserva y prepara  
**Entonces** aumenta reservado/estado de picking, pero su ubicación y físico no
cambian hasta pickup o despacho.

### AGP-B04 — Entrega tradicional

**Dado** un picking listo  
**Cuando** Almacén despacha  
**Entonces** origen disminuye, tránsito aumenta y custodia queda con el
despachador/transportista; cuando Armado recibe ocurre el movimiento inverso
hacia staging.

### AGP-B05 — Pickup en staging

**Dado** un picking `LISTO_PARA_PICKUP`  
**Cuando** la misma persona solicitante de Armado escanea el lote al recogerlo
en el punto configurable del almacén  
**Entonces** acepta custodia, el Kardex mueve origen→`MESA_ARMADO` de forma
atómica y quedan registrados preparador, receptor y punto de lectura; pickup no
consume las piezas.

### AGP-B06 — Diferencia en recepción

**Dado** un despacho de 10 mangas  
**Cuando** destino recibe 9 y declara 1 faltante  
**Entonces** las 9 llegan a staging, la faltante continúa en tránsito/incidencia
y el sistema no ajusta cantidad silenciosamente.

### AGP-B07 — Retorno

**Dada** una manga parcialmente consumida en Armado  
**Cuando** se solicita, despacha y recibe el remanente  
**Entonces** conserva identidad/genealogía, pasa por tránsito de retorno y solo
queda disponible al confirmar ubicación y Calidad aplicable.

### AGP-B08 — Concurrencia

**Dada** la misma manga escaneada en dos sesiones  
**Cuando** ambas intentan confirmar  
**Entonces** solo una obtiene custodia; la otra recibe conflicto accionable.

### AGP-B09 — Transferencia envejecida

**Dada** una transferencia despachada sin recepción  
**Cuando** supera el umbral configurado  
**Entonces** sigue en tránsito, aparece en Control y genera alerta; no se recibe
automáticamente.

### AGP-B10 — Teclado y lector

El recorrido de escaneo, retirar candidata, revisar y confirmar es operable con
lector que emite Enter y teclado, con feedback audible/visual configurable y
sin depender del mouse.

### AGP-B11 — Manga pesada sin recepción

**Dada** una manga con pesaje final confirmado y estado pendiente de recepción  
**Cuando** transcurren 24 horas sin ingresar a ningún almacén  
**Entonces** se crea una sola alerta operativa visible en Control/Alertas, con
antigüedad y deep link; el sistema no crea ingreso ni mueve Kardex.

## Invariantes

- máximo inicial 100 unidades por sesión;
- confirmación válida transaccional e idempotente;
- una unidad no participa en dos transferencias activas;
- tránsito conserva físico, reserva, origen, destino y custodia;
- consumo solo ocurre mediante el comando productivo correspondiente;
- correcciones son compensatorias y segregadas.
- 24 horas es el valor inicial versionado de la regla, no una constante de UI.

## Errores de dominio

- `TRANSFER_SESSION_NOT_OPEN`;
- `TRANSFER_UNIT_DUPLICATE`;
- `TRANSFER_UNIT_INCOMPATIBLE`;
- `TRANSFER_ALREADY_ACTIVE`;
- `TRANSFER_SOURCE_BALANCE_CHANGED`;
- `TRANSFER_RECEIPT_MISMATCH`;
- `TRANSFER_CUSTODY_CONFLICT`.
