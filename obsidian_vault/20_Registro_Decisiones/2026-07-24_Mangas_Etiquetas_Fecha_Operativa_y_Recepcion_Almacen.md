---
tipo: decision
estado: aceptada-con-adenda
tags: [scm, manga, etiqueta, pesaje, fecha-operativa, almacen, kardex, piloto]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[Unidad_Logistica]]"
  - "[[Etiqueta_Manga]]"
  - "[[Tipo_Manga]]"
  - "[[2026-07-30_Cierre_Armado_Pesaje_PT_Recepcion_y_Calidad]]"
  - "[[2026-08-01_Stickers_Prepesaje_como_Orden_Fisica_de_Manga]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-08-01
---

# Mangas, etiquetas, fecha operativa y recepción de Almacén

> [!important] Adenda 2026-07-30
> La regla 4 permanece para salida simple de fabricación. Para WIP/PT armado,
> la cantidad real la confirma el responsable de Armado antes de Balanza y el
> pesaje no consume ni acredita producción. Véase
> [[2026-07-30_Cierre_Armado_Pesaje_PT_Recepcion_y_Calidad]].

> [!important] Adenda 2026-08-01
> No existen PCs en las máquinas. La hoja de OT y las preetiquetas se imprimen
> en la estación de Balanza y el supervisor las entrega físicamente. El QR
> recupera el contexto completo para que el maquinista solo produzca, cuente y
> pese. Véase [[2026-08-01_Stickers_Prepesaje_como_Orden_Fisica_de_Manga]].

## Decisión

1. La OP calcula automáticamente un plan agregado de mangas usando capacidad en unidades y kg. Cada OT diaria asigna una parte y genera códigos `OP0084-OT001-M001`.
2. El primer sticker emitido consume un cupo normal. Una manga adicional es `EXTRA`, requiere autorización del Jefe de Producción y motivo.
3. La manga y cada etiqueta poseen IDs distintos. Reemplazar una etiqueta requiere autorización JP, invalida la anterior y crea otra versión sin crear una manga extra.
4. El maquinista cuenta físicamente, pero no digita cantidades. Pesar confirma implícitamente la cantidad asignada y nunca infiere unidades desde kg.
5. `fecha_operativa` determina el día de avance. `created_at`, `pesada_at` y la futura `recibida_at` conservan los tiempos físicos/auditables.
6. Pesar el día siguiente está permitido. Más de un día calendario genera alerta y motivo; no exige aprobación.
7. El piloto opera conectado.
8. El pesaje deja la manga `PENDIENTE_RECEPCION_ALMACEN`, sin stock, ubicación ni Kardex.
9. El movimiento inicial nace únicamente con el futuro escaneo de recepción de Almacén.
10. El maestro de [[Tipo_Manga]] se configura durante la puesta en marcha del piloto.

## Consecuencias

- US-010C gobierna planificación OP/OT y etiqueta de prepesaje.
- US-010D gobierna balanza, cantidad asignada, etiqueta de postpesaje y evidencia productiva.
- US-010I queda fuera del piloto y gobierna el nacimiento de inventario.
- La implementación legacy de OT debe añadir `created_at` sin reutilizar `fecha` como timestamp técnico.
- Los contratos anteriores que creaban `MovimientoKardex` en F2 quedan sustituidos.
