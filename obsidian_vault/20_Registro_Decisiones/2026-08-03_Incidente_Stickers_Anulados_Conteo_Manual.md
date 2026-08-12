---
tipo: incidente
estado: mitigado
tags: [pesaje, stickers, anulacion, trazabilidad, conciliacion, legado]
relaciones:
  - "[[2026-08-01_Stickers_Prepesaje_como_Orden_Fisica_de_Manga]]"
  - "[[2026-08-02_Alertas_Operativas_Configurable_para_Jefaturas]]"
  - "[[2026-07-17_Autenticacion_Humana_Diferida_Hasta_Cierre_Funcional]]"
  - "[[Sincronizacion_Datos]]"
fecha_creacion: 2026-08-03
fecha_actualizacion: 2026-08-04
---

# Incidente: stickers de pesajes anulados contados como pesajes físicos válidos

## Resumen

Durante un conteo manual de stickers 2-up usados como evidencia física de los
pesajes que llegaron a Armado, se incluyeron cuatro stickers correspondientes a
pesajes legacy posteriormente anulados. El Excel operativo no los mostraba
porque exporta únicamente registros activos; esa diferencia hizo aparecer un
descuadre entre el conteo físico y el sistema.

No hubo pérdida de datos ni diferencia entre la copia local y central: los
registros anulados permanecen conservados en ambas bases como historial legacy.

## Evidencia verificada

| ID legacy | Captura local | Operador declarado | Peso | Anulación local |
| ---: | --- | --- | ---: | --- |
| 11213 | 2026-07-15 12:01:47 | Zapata Guatarama Crisalida | 12.3 kg | 2026-07-15 18:00:57 |
| 11214 | 2026-07-15 12:02:08 | Zapata Guatarama Crisalida | 12.3 kg | 2026-07-15 18:00:53 |
| 11215 | 2026-07-15 12:02:49 | Zapata Guatarama Crisalida | 12.3 kg | 2026-07-15 18:00:44 |
| 11216 | 2026-07-15 12:03:03 | Zapata Guatarama Crisalida | 12.2 kg | 2026-07-15 18:00:49 |

- Impacto del conteo físico: 4 stickers y 49.1 kg que no debían contarse como
  pesajes vigentes.
- Los cuatro stickers fueron impresos antes de la anulación.
- Ninguno tenía observación, motivo de anulación ni solicitud de corrección
  asociada en la base legacy.
- La exportación legacy usa solo registros activos; por diseño omite los
  anulados y no expone su motivo ni su historial de corrección.

## Causa del problema

El sticker impreso se usó como un contador físico general, pero no porta por sí
solo el estado posterior del pesaje. La anulación en el sistema legacy no
invalidaba físicamente ni marcaba el sticker ya entregado. Como consecuencia,
un conteo de stickers no distingue una captura vigente de una captura anulada.

El problema se agravó por dos brechas del flujo legacy:

1. La exportación operacional ocultaba los anulados en vez de mostrarlos con
   estado y motivo.
2. La acción de anular no registraba actor ni motivo; por tanto no es posible
   atribuir la anulación retroactivamente.

## Decisión operativa

Un sticker físico no es una fuente de verdad para el total de pesajes vigentes.
Hasta que todo el flujo actualizado esté en operación, cualquier conciliación
manual debe cruzar cada sticker contra un reporte de estado del sistema.

El total operativo se calcula con pesajes vigentes. Los anulados se conservan
como evidencia y se reportan por separado; nunca se reintroducen al total para
compensar un conteo físico.

## Controles preventivos

### Inmediatos

1. El reporte de conciliación debe incluir todos los registros del rango con
   estado `VIGENTE` o `ANULADO`, fecha de anulación, motivo, actor declarado y
   referencia de corrección/reemplazo.
2. Antes de cerrar un conteo de Armado, cruzar el identificador QR/ID de cada
   sticker contra ese reporte. Un sticker anulado se separa como evidencia y
   no suma cantidades ni peso.
3. Si se encuentra un sticker anulado en planta, Producción registra la
   incidencia y solicita la etiqueta/reemplazo vigente; no se corrige el total
   por edición manual del Excel.

### Flujo actualizado

1. La preetiqueta identifica una manga; no confirma producción ni inventario.
   La etiqueta final y el estado central de la manga son la evidencia
   autoritativa del pesaje.
2. Una anulación, corrección o reemplazo debe ser append-only, con actor,
   motivo, fecha, referencia al original y, cuando corresponda, aprobación de
   segundo actor.
3. Un QR anulado o reemplazado debe bloquearse al escanear; la etiqueta física
   anterior no puede habilitar otro pesaje.
4. La bandeja de jefatura debe alertar anulaciones tardías y exigir resolución
   documentada.

## Criterios de verificación

- Un reporte mensual muestra conteos y kg separados para `VIGENTE`, `ANULADO`
  y `CORREGIDO/REEMPLAZADO`.
- Ningún registro anulado aparece en el total vigente, aun si su sticker físico
  se conserva en la planta.
- Toda anulación nueva presenta actor declarado, motivo y vínculo al pesaje o
  manga original.
- Una prueba de conciliación con los IDs 11213–11216 los clasifica como
  `ANULADO` y produce una diferencia de 4 stickers y 49.1 kg frente al conteo
  físico sin depurar.

## Limitación histórica

La evidencia legacy permite conocer qué se anuló y cuándo, pero no quién
ejecutó la acción ni el motivo. Esa ausencia no debe rellenarse con
suposiciones; queda como brecha histórica no recuperable.

## Seguimiento 2026-08-04: conciliación mensual legacy

La conciliación posterior de julio confirma que el conteo físico de stickers y
el total del sistema no deben compararse sin fijar el mismo corte temporal y
el mismo estado de cada registro.

| Población | Registros | Peso |
| --- | ---: | ---: |
| Copia SQLite activa de julio, hasta 2026-07-31 15:02 | 3,495 | 25,950.8 kg |
| Anulados de julio, todos con sticker impreso | 96 | 763.1 kg |
| Total de la copia SQLite, activos + anulados | 3,591 | 26,713.9 kg |
| Total central comunicado para julio | — | 26,275.0 kg |

La copia SQLite descargada no incluía su WAL y terminaba a las 15:02. Central
contenía 38 pesajes activos posteriores; la diferencia entre el total central
comunicado y la copia activa es 324.2 kg, consistente con ese tramo posterior.

Las anulaciones no explican que central sea mayor que el conteo físico: al
excluirlas, reducen el total del sistema. Sí explican por qué un conteo de
stickers puede incluir evidencia que ya no es vigente.

En la copia analizada había 18 solicitudes de corrección, todas en estado
`PENDING_LOCAL_REVIEW`; no hay evidencia de que esas solicitudes hayan alterado
el peso vigente. El sistema legacy no conserva una auditoría suficiente para
probar o descartar una edición directa histórica.

También se identificaron 26 pesajes activos con reimpresiones, que generaron 46
intentos adicionales de impresión. Las reimpresiones son un riesgo adicional de
doble conteo si el registro físico no usa el ID/QR como llave única.

### Cierre pendiente de la conciliación

Para identificar cualquier diferencia residual se debe conservar el total
exacto, sin redondear, y una lista de los IDs/QR de stickers contados. Esa lista
se cruza contra el historial central del mismo corte temporal para separar:

1. pesajes válidos no presentes físicamente;
2. stickers anulados contados por error;
3. stickers reimpresos contados más de una vez; y
4. pesajes creados después del corte del conteo físico.
