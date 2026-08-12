---
tipo: decision
estado: aceptada
tags: [scm, fabricacion, corte-horario, pesaje, manga, calidad-proceso, ocr, tiempo-real]
relaciones:
  - "[[Registro_Diario]]"
  - "[[Detalle_Produccion_Hora]]"
  - "[[Control_Peso]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
  - "[[US-011A_Dashboard_Gerencial_Avance_Pesajes]]"
  - "[[2026-08-01_Stickers_Prepesaje_como_Orden_Fisica_de_Manga]]"
fecha_creacion: 2026-08-01
fecha_actualizacion: 2026-08-01
---

# Corte horario sin pesaje de manga abierta

> [!NOTE] Revisión funcional propuesta — 2026-08-07
> [[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]] reabre la
> exclusión de pesajes acumulativos para permitir mangas que continúan en
> llenado durante varios turnos. Mientras esa historia permanezca
> `en-refinamiento`, esta decisión sigue siendo la regla productiva vigente y
> todavía no se considera reemplazada.

## Contexto

El Registro Diario legacy pedía conteos y coladas por hora escritos por los
trabajadores. Los conteos tenían mucho error y posteriormente podían ser
transcritos mediante OCR. También se evaluó pesar una misma manga abierta cada
hora para observar avance en tiempo real.

Pesar una manga abierta y volver a pesarla terminada produce lecturas
acumuladas. Sumarlas duplicaría todo el contenido existente en la primera
lectura. Aunque podría calcularse un delta, aumentaría estados, conciliaciones,
movimientos físicos y riesgo de interpretar una observación como producción.

## Decisión

1. La OT diaria continúa siendo el documento canónico. No se crea otro
   `RegistroDiarioProduccion` separado.
2. [[Detalle_Produccion_Hora]] evoluciona conceptualmente a `CorteHorarioOT`,
   hijo de la OT y orientado a observación de proceso.
3. En el piloto una manga se pesa una sola vez, después de cerrarse. No existe
   pesaje normal de una manga `EN_LLENADO`.
4. La cantidad buena autoritativa proviene del cierre de manga; el peso físico
   proviene de Balanza y el Kardex nace posteriormente en Almacén.
5. El conteo horario manual, cuando se use, es `PROVISIONAL` y nunca acredita
   producción, consume componentes ni mueve Kardex.
6. Los ciclos reales provienen preferentemente de lecturas acumuladas del
   contador de máquina. El sistema calcula el intervalo por diferencia entre
   lecturas válidas.
7. El OCR queda para documentos históricos o contingencia. Su resultado crea
   una propuesta que requiere confirmación humana; nunca un hecho productivo
   definitivo.

## Contenido del corte horario

Por `OT + franja horaria` se conserva:

- lectura acumulada del contador y ciclos derivados del intervalo;
- estado de máquina: operando, parada, cambio de molde/color u otro;
- motivo y duración de parada cuando corresponda;
- conteo provisional opcional de una manga abierta;
- mangas cerradas y pesajes finales ocurridos en la franja, enlazados
  automáticamente;
- muestra horaria de Calidad de fabricación;
- actor, fuente, momento real y observaciones.

La persona que ya realiza la ronda horaria puede capturar contador, estado y
muestra mediante un dispositivo móvil o posteriormente desde una PC. El
maquinista no necesita completar un formulario en la máquina. Si la captura se
realiza después, el sistema muestra su latencia y no afirma tiempo real.

## Fuentes de verdad

| Magnitud | Fuente | Autoridad |
|---|---|---|
| Meta | OF/OT | Plan |
| Ciclos reales | Diferencia de contador | Rendimiento de máquina |
| Unidades teóricas | Ciclos por cavidades snapshot | Estimación |
| Conteo horario | Captura manual | Provisional |
| Unidades buenas | Cierre de manga | Producción confirmada |
| Kg físicos | Pesaje final | Evidencia física |
| Existencia disponible | Recepción + Calidad de Almacén | Kardex |

El dashboard no suma conteo provisional y cantidad confirmada. Al cerrar una
manga, concilia el provisional aplicable, conserva la diferencia y deja de
mostrarlo como abierto.

## Calidad de fabricación

Tomar una pieza por máquina y hora se modela como muestra de proceso, distinta
de la decisión de Calidad posterior a la recepción en Almacén. Hasta definir
qué se evalúa, el sistema solo puede afirmar `MUESTRA_TOMADA`, no
`MUESTRA_CONFORME`.

Quedan por validar con Planta:

- características revisadas: apariencia, color, rebaba, llenado, dimensiones,
  peso, resistencia o armado;
- resultado y evidencia mínima;
- acción ante una muestra no conforme;
- intervalo de mangas que debe retenerse desde la última muestra conforme.

## Evolución futura descartada del piloto

Si posteriormente se aprueban pesajes acumulativos de control, se modelarán
como `PESAJE_CONTROL`, separados de `PESAJE_FINAL`, sobre el mismo `manga_id`:

```text
delta_intervalo = neto_acumulado_actual - neto_acumulado_anterior
```

Solo la lectura final podría confirmar la manga. Los controles no imprimirían
etiqueta final, no acreditarían producción y un delta negativo exigiría
conciliación. Esta capacidad no forma parte del primer piloto.

## Criterios de aceptación

- **CHR-01:** dos cortes horarios pueden enlazar pesajes finales distintos sin
  sumar dos veces ninguna manga.
- **CHR-02:** una manga `EN_LLENADO` no admite `CONFIRMAR_PESAJE_MANGA`.
- **CHR-03:** cerrar y pesar una manga acredita una sola cantidad y un solo peso
  físico.
- **CHR-04:** un conteo provisional diferente de la cantidad final conserva la
  diferencia, pero no altera Kardex.
- **CHR-05:** una lectura OCR queda pendiente de confirmación y no alimenta
  totales autoritativos.
- **CHR-06:** registrar únicamente la toma de una muestra no la marca
  automáticamente como conforme.
