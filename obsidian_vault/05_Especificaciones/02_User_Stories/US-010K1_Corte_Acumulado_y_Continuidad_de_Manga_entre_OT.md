---
tipo: user-story
subtipo: historia-hija
estado: implementada-local-pendiente-uat
epica: "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
tags: [scm, fabricacion, pesaje-control, manga, qr, continuidad, ot, atdd]
relaciones:
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010M3_Relevos_en_Trabajo_Color]]"
  - "[[Asignacion_Trabajo_OT]]"
  - "[[2026-08-26_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
  - "[[TS-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
fecha_creacion: 2026-08-26
fecha_actualizacion: 2026-08-26
---

# US-010K1: Corte acumulado y continuidad de manga entre OT

## Historia

**Como** operador de Pesaje y supervisor de Producción  
**Quiero** registrar un corte acumulado de una manga abierta y vincularla a la
siguiente OT compatible sin cambiar su QR  
**Para** continuar el llenado entre turnos, cerrar la manga una sola vez y
atribuir exactamente cuánto hizo cada OT y maquinista.

## Resultado observable

Jose entrega una manga de `50 UN` abierta con un corte acumulado de `20 UN`.
Ese control no acredita, no imprime y no crea Kardex. El supervisor vincula la
misma manga y QR a una OT compatible cuyo responsable es Pedro; Pedro no debe
aceptarla. El cierre final confirma `50 UN` una sola vez y presenta la
atribución reconciliada `20 UN` para Jose/OT origen y `30 UN` para Pedro/OT
destino.

## Alcance

- cero o más controles acumulados sobre la misma manga y QR;
- peso estable y conteo acumulado reportado en cada control;
- motivo obligatorio para el corte de turno;
- vínculo supervisado hacia una OT/Trabajo compatible;
- tramos auditados de OT, asignación y trabajador;
- continuidad sin aceptación adicional del maquinista receptor;
- un único pesaje final con postetiqueta;
- atribución por diferencia de conteos, confirmada solo al final;
- reintentos idempotentes y rechazo atómico de incompatibilidades.

## Fuera de alcance

- acreditar unidades, imprimir o crear Kardex desde un control;
- inferir unidades desde kg, ciclos, tiempo o velocidad;
- sustituir el QR o mover contenido a otra manga;
- cerrar parcialmente la manga para continuar después;
- reapertura, corrección destructiva o edición de controles;
- metas por color y recomendación automática de cambio;
- continuidad offline o para mangas de Armado.

## Lenguaje funcional

### Control acumulado

Observación de una manga que sigue abierta. Tanto el peso como
`conteo_acumulado_un` describen el contenido total observado en ese momento,
no solamente lo agregado desde el control anterior.

### Tramo de continuidad

Intervalo durante el cual una OT, un Trabajo de color, una asignación y un
trabajador contribuyen a la manga. El primer tramo comienza en cero; un vínculo
supervisado cierra el tramo vigente en el conteo de frontera y abre el destino
desde ese mismo conteo.

### Atribución confirmada

Partición del único total final entre tramos contiguos. Antes del pesaje final,
los conteos son evidencia de avance y no producción confirmada. Al cerrar, cada
aporte es `fin_acumulado - inicio_acumulado` y la suma debe igualar la cantidad
final.

## Invariantes

1. La manga, su código y su QR no cambian durante K1.
2. `manga.ot_id` y su Trabajo de origen no se sobrescriben; la continuidad es
   un historial adicional.
3. Una manga admite `0..N` controles y `0..1` final vigente.
4. Un control confirma cero unidades, imprime cero etiquetas y genera cero
   movimientos de inventario.
5. Los controles acumulados nunca se suman entre sí.
6. Las unidades de un tramo proceden de conteos acumulados, nunca de deltas de
   peso.
7. El conteo de frontera es monotónico y menor a la cantidad objetivo; si ya
   alcanzó el total corresponde usar el final, no una continuidad. El control
   queda enlazado al tramo que cierra.
8. Solo un supervisor autorizado vincula otra OT; Pedro no realiza una
   aceptación adicional.
9. El destino debe ser compatible y estar operativo. Un rechazo no cierra el
   tramo origen ni cambia al responsable.
10. Solo F2 ejecuta el cierre final y genera la postetiqueta.
11. El cierre final acredita la cantidad total exactamente una vez.
12. Las atribuciones son contiguas, no se solapan y suman exactamente el total
    final.
13. Una manga abierta no puede recibirse y no aparece en Kardex.
14. Repetir una operación con la misma clave y contenido devuelve el mismo
    resultado; cambiar el contenido produce conflicto.

## Flujo principal aprobado

1. La manga está preetiquetada para `50 UN`, asociada a Jose y a la OT origen.
2. En Balanza se escanea el QR original y se obtiene una lectura estable de
   `4.830 kg` bruto, `0.030 kg` tara y `4.800 kg` neto.
3. El operador elige `Registrar corte de turno — continúa abierta`, reporta
   `20 UN` acumuladas y un motivo.
4. Central guarda el control y responde que la manga sigue abierta y debe usar
   el mismo QR. No imprime ni acredita; pausa automáticamente el Trabajo origen
   y cierra el intervalo personal de Jose.
5. En Central, el supervisor elige una OT compatible cuyo responsable es Pedro
   y selecciona la manga entre las continuidades pendientes. Central toma las
   `20 UN` del último control válido; el supervisor no redigita el conteo.
6. El tramo de Jose queda delimitado en `0..20`; el de Pedro comienza en `20`.
   El Trabajo/OT origen ya puede cerrarse. Después se inicia el destino y Pedro
   continúa sin una acción de aceptación.
7. Al llegar a `50 UN`, Balanza lee `12.030 kg` bruto y `12.000 kg` neto.
8. El operador usa F2 una sola vez. Central crea el único pesaje final y la
   única postetiqueta.
9. El resultado muestra `50 UN` confirmadas y atribuciones `20/30`.
10. Recién después del final la manga puede pasar a recepción; Kardex nace una
    sola vez al aceptar custodia.

## Escenarios ATDD/BDD

### K1-01 — Corte mantiene identidad y no acredita

**Dado** una manga preetiquetada para `50 UN`, abierta en la OT de Jose  
**Cuando** se registra un corte estable de `4.830/0.030/4.800 kg` y `20 UN`
acumuladas  
**Entonces** la manga conserva su código y QR y queda abierta  
**Y** confirma `0 UN`, no genera postetiqueta, recepción ni Kardex  
**Y** el Trabajo origen queda pausado con su intervalo personal cerrado.

### K1-02 — Los valores acumulados no se suman

**Dado** un control anterior de `20 UN` y `4.800 kg` netos  
**Cuando** el contexto de la manga se vuelve a resolver  
**Entonces** presenta `20 UN` y `4.800 kg` como último avance observado  
**Y** no los suma a la futura lectura final ni los presenta como producción.

### K1-03 — Vínculo supervisado sin aceptación de Pedro

**Dado** el control de frontera de `20 UN` y una OT compatible con Pedro como
responsable  
**Cuando** Said, como supervisor, vincula la manga a esa OT  
**Entonces** se cierra el tramo de Jose en `20` y se abre el de Pedro desde
`20`  
**Y** el origen puede cerrarse y la misma manga/QR continúa al iniciar el
destino, sin que Pedro ejecute una aceptación.

### K1-04 — Destino incompatible no muta

**Dado** una OT de otra máquina, corrida, salida, color o empaque  
**Cuando** el supervisor intenta vincular la manga abierta  
**Entonces** la operación se rechaza con la incompatibilidad observable  
**Y** el tramo, responsable, QR y último control permanecen intactos.

### K1-05 — Final único y atribución 20/30

**Dado** los tramos `Jose 0..20` y `Pedro 20..abierto`  
**Cuando** F2 confirma el final de `50 UN` y `12.000 kg` netos  
**Entonces** existe un solo pesaje final y una sola postetiqueta  
**Y** se acreditan `50 UN` una vez, atribuidas `20 UN` a Jose/OT origen y
`30 UN` a Pedro/OT destino.

### K1-06 — Replay no duplica final ni atribución

**Dado** que el final anterior fue aceptado y se perdió su respuesta  
**Cuando** la estación repite la misma operación  
**Entonces** recupera el mismo pesaje, etiqueta y atribuciones  
**Y** no crea otro control, final, crédito ni trabajo de impresión.

### K1-07 — Manga abierta no entra a Almacén

**Dado** la manga con su control de `20 UN` pero sin final  
**Cuando** Almacén escanea el QR  
**Entonces** informa que la manga continúa abierta y bloquea la recepción  
**Y** no crea existencia ni movimiento.

### K1-08 — El ingreso posterior sigue siendo único

**Dado** la manga ya finalizada en `50 UN` con atribución `20/30`  
**Cuando** Almacén acepta custodia y Calidad la libera  
**Entonces** existe un solo ingreso de `50 UN` y un solo saldo físico  
**Y** no existen ingresos separados por control, tramo ni trabajador.

## Dataset reproducible

| Dato | Valor |
|---|---|
| Producto | `PT-JARRA-REAL-6L-TRANSPARENTE` |
| Máquina | `INY-01` |
| Manga | `50 UN`, tara `0.030 kg` |
| Origen | Jose Quispe / OT turno inicial |
| Corte frontera | `20 UN`; bruto `4.830`; neto `4.800 kg` |
| Destino | Pedro Huaman / OT compatible siguiente |
| Final | `50 UN`; bruto `12.030`; neto `12.000 kg` |
| Atribución al final | Jose `20 UN`; Pedro `30 UN` |
| Producción confirmada antes/después | `0 / 50 UN` |
| Postetiquetas antes/después | `0 / 1` |
| Kardex antes de recepción | `0 UN` |

## Permisos funcionales

- `MANGA_CONTROL_PESO_REGISTRAR`: operador autorizado de Pesaje.
- `MANGA_TRANSFERIR_OT`: supervisor o Jefe de Producción.
- `MANGA_FINALIZAR_COMPLETA`: operador autorizado de Pesaje.

La API resuelve capacidades en Central. No confía en un rol, actor ni
aceptación enviados por la interfaz.

## Definición de preparada

- [x] Resultado y frontera K1 aceptados por decisión del 2026-08-26.
- [x] Dataset `20/30` y resultado final exacto definidos.
- [x] Separación entre control, final y Kardex inequívoca.
- [x] Compatibilidad y autoridad supervisada declaradas.
- [x] Reintentos, conflictos y controles negativos observables.
- [x] Fuente de atribución definida como conteo acumulado de frontera.
- [x] UAT remota incorporada al recorrido de pesaje de piezas.
