---
tipo: decision
estado: aceptada
tags: [scm, armado, producto-terminado, manga, pesaje, almacen, calidad, impresion]
relaciones:
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[Orden_Armado]]"
  - "[[Unidad_Logistica]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Tipo_Manga]]"
  - "[[2026-07-30_OT_Diaria_Comun_para_Fabricacion_y_Armado]]"
fecha_creacion: 2026-07-30
fecha_actualizacion: 2026-07-30
---

# Cierre de armado, pesaje de PT, recepción y Calidad

## Decisión

1. La [[Orden_Armado]] conserva el plan agregado. Cada OT de Armado recibe
   una cuota diaria, planifica sus mangas y reserva sus identidades.
2. **Todas** las mangas de producto terminado deben pesarse.
3. La cantidad real de producto terminado es contada y confirmada por el
   responsable de Armado desde su propio módulo. La balanza no confirma ni
   infiere unidades.
4. Cerrar una manga en Armado consume sus componentes, conserva su genealogía
   y acredita el resultado productivo en una transacción idempotente. La manga
   queda `CERRADA_ARMADO_PENDIENTE_PESAJE`.
5. El módulo de pesaje recibe una manga ya cerrada, captura bruto, tara y neto,
   y emite la etiqueta final. No vuelve a consumir componentes ni a acreditar
   producción.
6. La solicitud de preimpresión nace en el módulo de Armado. Mientras no exista
   una impresora dedicada, central enruta el trabajo a la impresora de la
   estación de pesaje.
7. Producción entrega la manga pesada a Almacén. El ingreso por QR crea su
   existencia y ubicación con Calidad `PENDIENTE`.
8. Calidad libera, bloquea o rechaza **después** de la recepción de Almacén.
   Recibir físicamente no equivale a dejar el producto disponible.
9. La manga es la unidad primaria de inventario y trazabilidad de producto
   terminado. Un lote o partida de PT es un agrupador opcional futuro y no es
   requisito para crear, pesar, recibir, reservar o despachar una manga.
10. El [[Tipo_Manga]] y su [[Perfil_Empaque]] son configurables. Todavía deben
    crearse para los productos reales, pero una OA no puede planificar ni
    imprimir mangas sin exactamente un perfil aprobado y predeterminado.

## Separación de hechos

| Hecho | Actor responsable | Efecto |
|---|---|---|
| Planificar mangas PT | Planificación / Jefe de Producción | Reserva identidades y cantidades; no crea stock. |
| Imprimir preetiqueta | Armado; impresión ejecutada temporalmente por estación de pesaje | Materializa una versión de etiqueta; no confirma producción. |
| Cerrar manga de armado | Responsable de Armado | Confirma cantidad real, consume componentes y fija genealogía. |
| Pesar manga PT | Operador de balanza | Registra bruto, tara y neto; no altera cantidad ni BOM. |
| Recibir en Almacén | Almacenero PT | Crea movimiento inicial y ubicación con Calidad pendiente. |
| Liberar | Calidad | Habilita reserva, consumo o despacho sin cambiar ubicación. |

## Consecuencias

- Se retira para WIP/PT el comando que mezclaba cierre de armado y F2 de
  balanza. Se reemplaza por dos comandos idempotentes enlazados a la misma
  manga.
- La pantalla de pesaje presenta la cantidad confirmada por Armado como solo
  lectura.
- Si el conteo fue incorrecto, Armado solicita una corrección de cantidad/BOM;
  no se edita el pesaje.
- Si el peso fue incorrecto, Balanza solicita repesaje o corrección de peso; no
  se reabre automáticamente la genealogía.
- La manga recibida permanece no disponible hasta una decisión de Calidad.
- La impresora es un recurso direccionable por estación, no una
  responsabilidad de dominio de Armado.

## Comandos separados

```text
CERRAR_MANGA_ARMADO
  -> cantidad real + consumos + genealogía + resultado productivo
  -> CERRADA_ARMADO_PENDIENTE_PESAJE

CONFIRMAR_PESAJE_MANGA
  -> bruto + tara + neto + evidencia de balanza
  -> PENDIENTE_RECEPCION_ALMACEN

RECIBIR_MANGA_ALMACEN
  -> ubicación + movimiento inicial + Calidad PENDIENTE
  -> RECIBIDA_PENDIENTE_CALIDAD

DECIDIR_CALIDAD_MANGA
  -> LIBERADA | BLOQUEADA | RECHAZADA
```
