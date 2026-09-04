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
fecha_actualizacion: 2026-09-04
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

La preetiqueta nueva `PREPESAJE_TSPL_5` prioriza el reconocimiento inmediato de
la manga y muestra únicamente:

- código de manga `OF000017-OT007-M003`, en 24 puntos de plantilla;
- pieza y color en filas independientes;
- separación horizontal después de color;
- OP opcional cuando el payload tiene una referencia inequívoca, arriba de máquina;
- máquina y, debajo, `TIPO MANGA`; luego turno y fecha operativa original de OT;
- operador previsto y fecha/hora local de impresión;
- `KG TEORICOS`, con tres decimales, calculados como
  `cantidad_planificada_un × peso_unitario_snapshot_g / 1000`;
- QR compacto identificado.

El resto del texto usa 16 puntos de plantilla. `KG TEORICOS` es una referencia
previa al pesaje y nunca sustituye el peso real. Los UUID y cantidades permanecen
en el payload autoritativo. El renderer comparte layout compacto para v4/v5 y
admite `kg_estimados` como fallback; no afirmar que re-renderizar v4 reproduce
exactamente un papel antiguo. El payload y hash de emisión conservan su historia.

Brecha a revisar en UAT: `tipo_manga` se alimenta actualmente con `manga.tipo`
(`NORMAL`/`EXTRA`), no con el nombre físico del contenedor. No afirmar que ya
imprime «reciclada grande». Ver hallazgos del guion de módulo.

La etiqueta nueva `POSTPESAJE_TSPL_5` muestra:

- fecha/hora y debajo el maquinista del contexto de cierre;
- `PESO NETO FINAL (kg)`: peso medido de todo el contenido;
- debajo, `PESO FABRICADO TEORICO (kg)`, cuando existe una fuente válida:
  excluye componentes incorporados que no se fabricaron en esa OT;
- `FINAL · MANGA CERRADA` y cantidad según fuente: `CONTEO TEORICO` para
  `PLAN_CONFIRMADO_POR_PESAJE`; `CONTEO CONFIRMADO` para fuente explícita
  Armado/parcial/corrección. El segundo rótulo no acredita fiabilidad humana;
  la nueva política cero conteos aún no está implementada integralmente;
- no imprime otro QR: se conserva la preetiqueta.

`CONTROL_PESO_TSPL_2` para `AVANCE_KG` muestra NET acumulado y aporte desde el
control anterior, `AVANCE EN KG · SIN CONTEO`, sin QR ni unidades.
Brecha conocida del final: su rótulo `APORTE ULTIMO TRAMO` recibe un delta desde
el último control; varios controles dentro de un tramo hacen que no equivalga
al aporte completo del trabajador. No certificar esa atribución en la UAT.

No se usan “peso bruto” y “peso neto” para representar estas dos magnitudes porque no constituyen tara y contenido: ambas describen perspectivas distintas del contenido productivo. Bruto y tara permanecen en el registro digital y pueden imprimirse solo si el espacio/operación lo exige.

El diseño `PREPESAJE_TSPL_5` conserva el formato 2-up: soporte de `109 mm × 50 mm`, `GAP 3
mm`, 203 DPI y dos columnas de `50 mm`/400 dots, iniciadas en X `24` y `464`.
El renderer vigente emite dos copias de la misma identidad por hoja; si el
trabajo contiene dos identidades, produce dos hojas. No son dos mangas nuevas.
La alineación y legibilidad todavía requieren UAT física en la impresora piloto.
Fuente: [[REC_2026-09-01_Stickers_Pesaje_TSPL5_y_Peso_Fabricado]] y
[[UAT_US-010K_Modulo_Pesaje_Piloto_Kg]].

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

El QR impreso usa un sobre compacto y resoluble:

```json
{
  "v": 1,
  "label_id": "uuid-etiqueta"
}
```

`label_id` identifica una impresión concreta. La estación consulta Central para
resolver la manga, el tipo y versión de etiqueta, el trabajo-color y la vigencia;
estos campos permanecen en el payload autoritativo y no se duplican dentro del
símbolo físico. Una etiqueta invalidada sigue bloqueándose por su `label_id` y
señala el reemplazo vigente.

Los QR largos v1 ya emitidos y el UUID directo permanecen aceptados como formatos
de lectura compatibles. La emisión nueva usa el sobre compacto definido en
[[../20_Registro_Decisiones/2026-09-01_QR_Compacto_por_Label_ID_en_Preetiqueta|QR compacto por label_id]].

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

### Cierre reabierto

`REABRIR_MANGA` no reemplaza la preetiqueta: su `label_id`, QR e identidad de
manga siguen vigentes. Invalida únicamente los comprobantes `POSTPESAJE` del
cierre que dejó de ser vigente. La persona autorizada debe retirar o marcar
como inválido el comprobante final anterior antes de continuar con la misma
manga. El siguiente cierre crea otro hecho y otro comprobante sin alterar el
QR pegado. La reapertura distingue `CIERRE_ACCIDENTAL`, cuyo NET anterior no
gobierna el siguiente peso, y `CONTINUAR_LLENADO`, cuyo NET queda como línea
base acumulativa. Esto es distinto de `ANULAR_PESAJE`, que invalida toda la
identidad operativa y devuelve el cupo al plan.
