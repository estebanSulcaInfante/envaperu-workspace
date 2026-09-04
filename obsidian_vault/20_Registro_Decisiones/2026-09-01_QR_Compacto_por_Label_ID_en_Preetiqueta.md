---
tipo: decision
estado: aceptada
fecha_creacion: 2026-09-01
fecha_actualizacion: 2026-09-01
tags: [scm, manga, preetiqueta, qr, impresion, pesaje]
relaciones:
  - "[[../01_Dominio/Etiqueta_Manga|Etiqueta de Manga]]"
  - "[[2026-08-01_Stickers_Prepesaje_como_Orden_Fisica_de_Manga]]"
  - "[[../05_Especificaciones/03_Tech_Specs/TS-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje|TS-010C]]"
---

# QR compacto por `label_id` en la preetiqueta

## Contexto

La preetiqueta codificaba dentro del QR un JSON de aproximadamente 199 a 233
bytes con `manga_id`, `label_id`, tipo, versión de etiqueta y, cuando aplicaba,
`trabajo_color_id`. En la TSC TE200 de 203 DPI ese contenido puede producir un
símbolo de 57 × 57 módulos y obliga a reservar aproximadamente 32.5 mm
incluyendo la zona silenciosa.

La estación no usa esos campos como autoridad local. Extrae `label_id`, consulta
Central y recibe desde allí manga, OT, trabajo-color, vigencia y permisos. Central
también bloquea una etiqueta invalidada y señala su reemplazo vigente.

## Decisión

El contenido físico de los QR nuevos de tipo `PREPESAJE` será:

```json
{"v":1,"label_id":"uuid-etiqueta"}
```

- `label_id` identifica una impresión concreta, no solo la manga.
- `v` versiona el sobre compacto y no sustituye `label_version`.
- Central conserva sin reducción el payload autoritativo, su `payload_hash`, la
  relación con `manga_id`, el tipo y la versión de etiqueta.
- La estación resuelve el contexto y la vigencia exclusivamente por `label_id`.
- Se mantienen QR Modelo 2, corrección `L` y módulo de cuatro dots.
- Los QR largos ya emitidos continúan aceptándose durante la migración.

Con el UUID actual, el QR compacto usa 33 × 33 módulos; con cuatro dots por
módulo requiere aproximadamente 20.5 mm incluyendo cuatro módulos blancos por
lado. No se reduce el módulo físico por debajo de cuatro dots.

## Alternativas descartadas

### Code 128 con UUID completo

El UUID de 36 caracteres supera 53 mm de barras aun con un dot por módulo y sin
una zona silenciosa suficiente. No cabe de forma robusta en un sticker de 50 mm.

### Código corto nuevo

Haría viable Code 128, pero introduciría otra identidad, reglas de unicidad,
resolución y migración sin aportar una ventaja frente al `label_id` ya existente.

### UUID sin sobre

La estación ya lo acepta, pero omite la versión explícita del contrato impreso.
El sobre compacto añade solo 2 mm aproximados y conserva evolución controlada.

## Compatibilidad, rollback y gates

- Compatibilidad hacia atrás: JSON largo y UUID directo siguen resolviendo.
- Rollback: restaurar el serializador físico anterior; no requiere migrar datos.
- El `rendered_payload_hash` cambia porque cambia el TSPL exacto; el hash del
  payload central no se reinterpreta.
- Antes de habilitar en planta se debe imprimir con la TSC TE200, confirmar zona
  silenciosa y leer ambas copias ya pegadas con el lector real.
