---
tipo: uat
estado: lista-para-ejecucion-local
tags: [uat, scm, almacen, qr, kardex, calidad]
tech_spec: "[[TS-010I_Recepcion_Mangas_y_Nacimiento_Kardex]]"
fecha_creacion: 2026-08-03
fecha_actualizacion: 2026-08-03
base_datos: envaperu_test
revision_minima: f62e0b8d7c36
---

# UAT TS-010I — Recepción de Mangas y Kardex

## Preparación

1. Confirmar que `envaperu_test` está en head; no sembrar ni limpiar la base.
2. Tener una manga con pesaje final y etiqueta `POSTPESAJE` impresa.
3. Tener un actor `ALMACEN_RECEPCION` y otro `CALIDAD`.
4. Abrir `/produccion/recepcion-mangas`.

## Caso A — Recepción normal

1. Entrar como Almacén.
2. Escanear el QR final y presionar Enter si el lector no lo hace.
3. Verificar que artículo, color, cantidad, bruto, tara, neto, OT y fechas sean
   solo lectura.
4. Confirmar presencia, bolsa cerrada y coincidencia de etiquetas.
5. Aceptar `RECEPCION_PIEZAS_WIP` o `RECEPCION_PT`, según la clase.
6. Confirmar que la manga desaparece de pendientes y aparece con Calidad
   `PENDIENTE`.
7. Abrir Kardex: físico aumenta, no disponible aumenta y libre no cambia.

## Caso B — Idempotencia

Reenviar el mismo request/clave desde cliente técnico. Debe devolverse la misma
existencia y mantenerse un único `INGRESO_PRODUCCION`.

## Caso C — Calidad

1. Cambiar a actor Calidad.
2. Abrir “Custodia y Calidad”.
3. Liberar con motivo.
4. Confirmar en Kardex que no disponible baja y libre aumenta.
5. Probar otra manga bloqueada y otra rechazada; ambas conservan físico y libre
   cero.

## Caso D — Rechazo antes de custodia

1. Identificar una manga pendiente.
2. Rechazar indicando daño o diferencia de etiquetas.
3. Confirmar que el rechazo queda visible y que no nace movimiento ni saldo.

## Caso E — Guardas

- QR invalidado: rechaza y solicita etiqueta vigente.
- preetiqueta sin final impresa: `PESAJE_FINAL_REQUERIDO`.
- PT en ubicación de piezas/WIP: `UBICACION_INCOMPATIBLE`.
- segunda recepción: `MANGA_YA_RECIBIDA`.
- actor sin capacidad: acción oculta y API `403`.

## Caso F — Reversa segregada

1. Usar una manga recibida, sin reservas ni consumo posterior.
2. Como `ALMACEN_RECEPCION`, solicitar reversa con motivo y evidencia.
3. Intentar aprobar con el mismo actor: debe responder `SEGREGACION_REQUERIDA`.
4. Como un `JEFE_PRODUCCION` distinto, aprobar la reversa.
5. Confirmar existencia `REVERSADA`, movimiento compensatorio y manga
   `PENDIENTE_RECEPCION_ALMACEN`.
6. Confirmar que físico y no disponible vuelven exactamente al baseline previo.

## Caso G — Reversa y anulación del pesaje

1. Antes de reversar, intentar anular el pesaje: debe responder
   `RECEIPT_REVERSAL_REQUIRED`.
2. Aprobar la reversa del Caso F.
3. Volver a **OT y mangas → Ver pesaje** y anular con `JEFE_PRODUCCION`.
4. Confirmar Original inmutable, Vigente ausente, QR inválidos y cupo devuelto.
5. Crear una manga normal de reemplazo y confirmar que no aparece como `EXTRA`.

Si la existencia tiene reservas, la reversa debe responder
`EXISTENCIA_COMPROMETIDA`; no liberar reservas mediante SQL para forzar el caso.
## Evidencia a conservar

- capturas de identificación y recepción;
- código de manga, actor y hora;
- estado de Kardex antes y después;
- decisión de Calidad y motivo;
- solicitud y aprobación segregadas de la reversa;
- movimiento compensatorio y saldos antes/después;
- anulación posterior, QR inválidos y manga normal de reemplazo;
- cualquier criterio de inspección solicitado por Calidad para incorporarlo a
  la siguiente revisión.

