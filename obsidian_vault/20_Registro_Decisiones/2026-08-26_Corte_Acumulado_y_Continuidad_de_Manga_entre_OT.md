---
tipo: decision
estado: aceptada
tags: [scm, fabricacion, pesaje-control, manga, qr, continuidad, ot, atribucion]
relaciones:
  - "[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]]"
  - "[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]"
  - "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
  - "[[US-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
  - "[[TS-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
  - "[[Asignacion_Trabajo_OT]]"
fecha_creacion: 2026-08-26
fecha_actualizacion: 2026-08-26
---

# Corte acumulado y continuidad de manga entre OT compatibles

## Contexto

El corte vigente del piloto obliga a cerrar definitivamente una manga con
contenido al cambiar de turno y a crear otra identidad para el saldo. Ese
comportamiento protege el pesaje final, pero no representa el caso físico en el
que la misma manga permanece en la máquina y otro maquinista continúa
llenándola.

La alternativa tampoco puede tratar cada lectura como una manga producida: el
peso y el conteo observados son acumulados. Sumarlos acreditaría dos veces el
contenido, generaría etiquetas finales inexistentes y permitiría que una manga
abierta llegue prematuramente a Almacén.

## Decisión

### 1. Una identidad física durante toda la continuidad

Una manga que continúa llenándose conserva su `manga_id`, código y QR de
prepesaje. La OT y el Trabajo de color de origen permanecen inmutables como
linaje de creación; la continuidad hacia otra OT se registra como un vínculo o
tramo auditado, no sobrescribiendo el origen ni creando otra manga.

El QR solo puede continuar hacia una OT y Trabajo de color compatibles con la
misma máquina, OF/corrida, salida, artículo/PiezaColor, color y snapshots de
empaque. Una coincidencia de nombre visible o una reasignación libre de
trabajador no demuestra compatibilidad.

### 2. El corte es acumulado y no acredita

La estación ofrece una acción separada de F2:

`Registrar corte de turno — continúa abierta`.

El corte conserva la lectura estable completa de bruto, tara y neto, el
`conteo_acumulado_un`, motivo, actor, estación, OT/tramo y momento.
No representa un incremento aislado. El aporte del intervalo se obtiene por
diferencia de conteos acumulados, nunca convirtiendo el delta de kg en
unidades.

Registrar un corte:

- mantiene la manga abierta y preserva su QR;
- confirma `0` unidades de producción;
- no consume cupo definitivo;
- no genera ni imprime postetiqueta;
- no habilita recepción;
- no crea existencia, movimiento ni Kardex.

Los controles son hechos append-only e idempotentes. Una corrección o
invalidación se expresa mediante evidencia compensatoria; no se edita ni se
elimina el hecho original.

Como el tipo aprobado es `CORTE_TURNO`, aceptar el control también pausa el
Trabajo de color origen y cierra su intervalo personal vigente. No completa el
Trabajo ni anula la manga. La pausa libera la exclusividad de la máquina para
que, después del vínculo, pueda iniciarse la OT destino.

### 3. La continuidad es una decisión supervisada

Después del corte de frontera, un supervisor selecciona la misma manga desde
las continuidades pendientes de una OT compatible. Central reutiliza el último
control válido como frontera, sin pedir que el supervisor redigite el conteo, y
deja como responsable al maquinista del nuevo tramo. La decisión
del supervisor es suficiente para el corte K1: el receptor no ejecuta una
segunda aceptación. En el ejemplo aprobado, Pedro Huaman puede continuar en la
OT destino sin pulsar `Aceptar manga` ni aportar otra aprobación.

La operación cierra el tramo anterior en su conteo acumulado y abre el
siguiente desde el mismo valor. No imprime otra preetiqueta, no cambia el QR y
no crea cupo o manga adicional. Un destino incompatible, cerrado o sin
responsable válido se rechaza sin mutación parcial.

Una vez creado el vínculo, el tramo origen queda resuelto y su Trabajo/OT puede
completarse y cerrarse aunque la manga física termine después en el destino.
Esa clausura documental no convierte el control en crédito. El Trabajo destino
debe iniciarse para activar el tramo de Pedro.

### 4. Un solo cierre final y atribución reconciliada

F2 conserva su significado exclusivo: pesaje y cierre final con impresión. Una
manga admite `0..N` controles y exactamente `0..1` pesaje final vigente. El
cierre final confirma una sola vez la cantidad total de la manga, genera una
sola postetiqueta y recién entonces vuelve confirmadas las atribuciones de sus
tramos.

Para una manga de `50 UN` con corte de frontera en `20 UN`:

| Tramo | Responsable | Cantidad atribuida al cierre |
|---|---|---:|
| OT origen | Jose Quispe | `20 UN` |
| OT compatible destino | Pedro Huaman | `30 UN` |
| Total físico de la manga | — | `50 UN` |

El control de `20 UN` no había acreditado producción. Al cierre existe un solo
total confirmado de `50 UN`; `20 + 30` es su partición auditada por OT y
trabajador, no dos producciones adicionales. El peso final también permanece
como un único hecho físico de la manga.

La recepción posterior crea un solo ingreso de `50 UN`. Calidad libera ese
mismo saldo; ni controles ni atribuciones generan movimientos de Kardex.

## Compatibilidad mínima

El vínculo solo es válido cuando origen y destino conservan:

- la misma máquina física;
- la misma OF/corrida y salida de fabricación;
- el mismo artículo, PiezaColor y ColorProduccion exactos;
- el mismo tipo de manga, tara y perfil de empaque congelados desde el origen;
- estados operativos que permiten continuar y un responsable destino activo.

La OT destino debe ser estrictamente posterior por fecha/secuencia de turno.
No puede representar otro color, salida, máquina ni corrida. Si una regla de
empaque cambia después del inicio, la manga conserva sus snapshots físicos
históricos; la revisión nueva aplica a identidades creadas posteriormente.

## Frontera del incremento K1

K1 incluye únicamente control acumulado, vínculo supervisado a una OT
compatible, continuidad con el mismo QR, cierre final único y atribución exacta
por conteo de frontera.

Quedan fuera:

- crédito provisional o Kardex de manga abierta;
- impresión en cada corte;
- aceptación del maquinista receptor;
- inferencia de unidades desde kg, tiempo o ciclos;
- traslado del contenido hacia otra manga o QR;
- reapertura de un cierre final;
- cierre parcial definitivo, que conserva su flujo supervisado separado;
- meta y recomendación automática de cambio de color;
- funcionamiento offline y extensión automática a Armado.

## Sustituciones parciales

Esta decisión sustituye únicamente la exclusión de pesajes acumulativos de
[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]] para el flujo K1. Se
mantienen sus fuentes de verdad: el control no acredita, el final confirma la
producción y el Kardex nace después en Almacén.

También sustituye el bloqueo multi-OT de M3 solo cuando existe un corte de
frontera y un vínculo supervisado compatible. Los relevos ordinarios dentro de
una OT continúan gobernados por M3.

## Criterios de aceptación de la decisión

- **DEC-K1-01:** un corte de `20 UN` y `4.800 kg` netos conserva manga y QR,
  deja producción confirmada en cero y no imprime.
- **DEC-K1-02:** el supervisor vincula la misma manga a una OT compatible con
  Pedro; no existe aceptación adicional del receptor.
- **DEC-K1-03:** F2 cierra una sola vez en `50 UN` y `12.000 kg`, con una sola
  postetiqueta.
- **DEC-K1-04:** la atribución confirmada queda `20/30` y suma exactamente el
  único total final de `50 UN`.
- **DEC-K1-05:** Almacén rechaza la manga mientras esté abierta y crea un solo
  ingreso únicamente después del final.
