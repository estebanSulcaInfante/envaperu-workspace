---
tipo: modelo_objetivo
estado: implementado-local-pendiente-uat
tags: [dominio, scm, manga, etiqueta, qr, impresion, auditoria, US-010C, US-010D]
relaciones:
  - "[[Unidad_Logistica]]"
  - "[[Tipo_Manga]]"
  - "[[Registro_Diario]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[Orden_Fabricacion]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-07-29
---

# Etiqueta de Manga

Evidencia identificada de una impresión física asociada a una [[Unidad_Logistica|manga]]. La identidad de la manga y la identidad de la etiqueta son distintas:

- `manga_id` identifica el contenedor y su contenido;
- `etiqueta_id` identifica una impresión concreta;
- reemplazar una etiqueta no crea otra manga ni consume un cupo extra.

## Tipos

- `PREPESAJE`: acompaña la manga desde antes del pesaje.
- `POSTPESAJE`: complementa la anterior con el resultado de balanza.

Ambos tipos pueden estar vigentes simultáneamente. Imprimir la etiqueta de postpesaje no invalida la de prepesaje.

## Contenido visible del piloto

Ambas etiquetas repiten deliberadamente los datos de identidad para que el trabajador pueda comprobar que pertenecen a la misma manga:

- fecha y hora de esa impresión;
- fecha operativa de OT;
- `OF-OT`;
- maquinista previsto;
- pieza-color o artículo de salida;
- color;
- código de manga `OF0042-OT301-M003`;
- tipo `NORMAL` o `EXTRA`, destacado visualmente;
- QR identificado.

La etiqueta `POSTPESAJE` añade:

- `KG FÍSICO`: peso neto medido de todo el contenido;
- `KG PROD. OT`: masa estándar atribuible a la producción de la OT, descontando componentes previos según cantidades y snapshots.

No se usan “peso bruto” y “peso neto” para representar estas dos magnitudes porque no constituyen tara y contenido: ambas describen perspectivas distintas del contenido productivo. Bruto y tara permanecen en el registro digital y pueden imprimirse solo si el espacio/operación lo exige.

El diseño `PREPESAJE_TSPL_2` conserva el formato 2-up: soporte de `109 mm × 50 mm`, `GAP 3
mm`, 203 DPI y dos columnas de `50 mm`/400 dots, iniciadas en X `24` y `464`.
Cada columna corresponde a una manga y etiqueta distintas; un lote impar deja
la segunda columna vacía. La alineación y legibilidad todavía requieren UAT
física en la impresora piloto.

## Atributos objetivo

| Campo | Regla |
|---|---|
| `id` | UUID/ULID global de la etiqueta. |
| `manga_id` | Manga estable a la que pertenece. |
| `tipo` | `PREPESAJE` o `POSTPESAJE`. |
| `version` | Correlativo por `(manga_id, tipo)`. |
| `estado` | `GENERADA`, `IMPRESA`, `FALLIDA_SIN_EMISION`, `EMISION_INCIERTA` o `INVALIDADA`. |
| `plantilla_version` | Versión del diseño físico. |
| `print_job_id` | Identidad idempotente del trabajo de impresión. |
| `impresa_at`, `impresa_por_id`, `estacion_id` | Evidencia de impresión. |
| `invalidada_at`, `invalidada_por_id`, `motivo_invalidacion` | Evidencia de reemplazo. |
| `payload_hash` | Integridad del payload autoritativo recibido de central. |
| `rendered_payload_hash` | SHA-256 del TSPL exacto por intento, incluida la hora física local. |

## QR

El QR usa un contrato versionado y contiene, como mínimo:

```json
{
  "v": 1,
  "type": "SCM_MANGA_LABEL",
  "manga_id": "uuid-o-ulid",
  "label_id": "uuid-o-ulid",
  "label_type": "PREPESAJE",
  "label_version": 2
}
```

El código humano de una manga nueva, por ejemplo `OF0042-OT301-M003`, se
imprime como ayuda, pero no sustituye los IDs. Una etiqueta v1 ya emitida
conserva su código `OP…` legacy y sigue resolviendo por `manga_id`.

## Invalidación y reemplazo

“Anular una etiqueta” significa invalidar lógicamente una impresión, no borrar la evidencia ni anular la manga:

1. requiere autorización del Jefe de Producción y motivo;
2. la etiqueta anterior pasa a `INVALIDADA`;
3. se crea una etiqueta con nuevo `id` y versión superior;
4. el código e identidad de manga permanecen;
5. escanear el QR anterior informa que la etiqueta ya no es vigente y señala la versión válida.

Un fallo confirmado antes de que el soporte salga físicamente de la impresora
puede reintentar el mismo `print_job_id`; cada intento queda como evidencia
append-only en la estación. Si existe la posibilidad de que la etiqueta haya
sido emitida, se invalida y reemplaza; no se declara una reimpresión
indistinguible.
