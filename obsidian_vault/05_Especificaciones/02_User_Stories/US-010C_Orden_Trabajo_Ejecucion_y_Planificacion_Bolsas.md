---
tipo: user-story
subtipo: historia-hija
estado: implementado-local-pendiente-uat-y-adaptacion-of
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, produccion, orden-trabajo, rdp, ejecucion, mangas, etiquetas, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[TS-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[Orden_Fabricacion]]"
  - "[[Registro_Diario]]"
  - "[[Saldo_WIP_Salida]]"
  - "[[Perfil_Empaque]]"
  - "[[Tipo_Manga]]"
  - "[[Etiqueta_Manga]]"
  - "[[Orden_Operacion]]"
  - "[[Lote_WIP]]"
  - "[[Lote_Color]]"
  - "[[2026-07-23_Autoridad_Central_OT_e_Impresion_Local]]"
  - "[[2026-07-23_Separacion_Peso_Fisico_Produccion_y_Armado]]"
  - "[[2026-07-24_Mangas_Etiquetas_Fecha_Operativa_y_Recepcion_Almacen]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-08-01_Dos_Modalidades_Armado_y_Responsabilidades]]"
  - "[[2026-08-01_Stickers_Prepesaje_como_Orden_Fisica_de_Manga]]"
  - "[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]]"
fecha_creacion: 2026-07-23
fecha_actualizacion: 2026-08-01
---

# US-010C: Orden de Trabajo, Ejecución y Planificación de Mangas

## 1. Decisión de alcance

La **Hoja de Producción diaria**, el `RegistroDiarioProduccion` actual y la **Orden de Trabajo (OT)** representan el mismo agregado de negocio. Esta historia no crea una segunda cabecera paralela: evoluciona el registro existente hasta convertirlo en la OT canónica, identificada y creada por el sistema central.

La API central es la autoridad de la OT y de su correlativo. La estación de pesaje puede solicitar la creación, conservar una copia operativa y ejecutar la impresión física, pero no inventa una OT autoritativa ni obliga a reconstruirla desde el primer pesaje.

La historia comienza durante la liberación de una [[Orden_Fabricacion|OF]] y sus
corridas, donde central calcula automáticamente un plan agregado de mangas por
salida. Al crear cada OT diaria se asigna una parte de ese plan y recién se
generan las identidades imprimibles con fecha operativa, máquina y maquinista
previstos. La historia termina con mangas planificadas y etiquetas de prepesaje
disponibles en la estación. La captura del peso pertenece a
[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]]; el
nacimiento de inventario pertenece a
[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex|US-010I]].

No existen PCs en las máquinas. La interacción digital ocurre desde las PCs de
oficina y la estación de Balanza. El supervisor entrega físicamente la hoja de
OT y los stickers de prepesaje; cada sticker comunica una manga y cantidad
asignadas. El maquinista produce, cuenta y pesa sin buscar documentos ni
digitar OP, OT, pieza, color o cantidad.

US-010C también conserva la responsabilidad original de ejecución: confirmar
qué premezcla o materiales emitidos entran a la corrida, registrar sus detalles
reales y producir salidas identificadas por `LoteSalidaPiezaColor`. Una salida
puede embolsarse directamente o pasar sin almacenamiento intermedio a
[[US-010F_Prearmado_y_Armado_Concurrente_Trazable|US-010F]]. El vínculo
vertical es `OF -> corrida -> OT -> mangas planificadas -> estación`.

## 2. Historia de usuario

**Como** responsable de Producción o supervisor de turno  
**Quiero** crear centralmente una OT desde una corrida de OF liberada, ejecutarla y preparar etiquetas identificadas para las bolsas que se producirán  
**Para** reemplazar el talonario manual, evitar que la estación infiera hojas a partir de pesajes y entregar a los maquinistas identidades trazables antes de embolsar.

## 3. Resultado observable

Al completar esta historia:

1. Cada OT posee un identificador global y un código legible correlativo, y referencia una OF/corrida real.
2. El sistema reconoce explícitamente que OT, RDP y Hoja de Producción son la misma cabecera.
3. Crear una OT en central y reintentar la misma solicitud no genera duplicados.
4. La impresión ocurre en la estación y sus fallos no crean otra OT.
5. Una OT ejecuta una sola corrida/color. Los relevos de maquinista se registran
   en detalles auditados sin alterar la identidad de la OT.
6. Cada etiqueta de manga planificada identifica la salida física exacta, no solo un texto de color.
7. Las mangas planificadas no suman inventario ni producción real.
8. El piloto exige conexión con central para crear, imprimir y pesar; la operación offline queda diferida.
9. El consumo real de inputs y las salidas de la corrida quedan enlazados a la misma OT.
10. La proyección en tiempo real separa ciclos, unidades/masa estándar producidas por la OT, prearmado provisional abierto, armado confirmado y kg físicos embolsados.
11. Las piezas buenas aún sueltas poseen un saldo WIP explícito y solo pueden destinarse una vez a embalaje directo o armado en línea.
12. Cada manga de Fabricación posee una cantidad asignada previamente; el
    maquinista cuenta físicamente, pero no ingresa datos en la estación. En una
    manga de Armado, la cantidad real la confirma el responsable de Armado en
    el módulo de Armado; la balanza solo captura el peso.
13. El sistema propone cantidad y número de mangas desde una `ReglaEmpaqueRevision` congelada, usando capacidad en unidades y kg; la última manga puede quedar parcial.
14. Una manga identifica si su salida será `LoteSalidaPiezaColor`, `LoteWIP` o producto terminado y nunca lo decide por el peso.
15. La OT materializa únicamente operaciones de ruta
    `executor_kind=ORDEN_FABRICACION`; el tipo de ejecutor no impide que una
    operación terminal produzca directamente producto terminado.
16. Una manga adicional por encima del plan activo es `EXTRA`, exige autorización del Jefe de Producción y conserva motivo.
17. La hoja de OT comunica el trabajo general y cada preetiqueta funciona como
    orden física de una manga; ninguna requiere una pantalla en la máquina.
18. El seguimiento horario es un corte operativo de la OT. Una manga abierta
    puede tener conteo provisional, pero solo una manga cerrada puede pasar al
    pesaje final.

## 4. Lenguaje de dominio

### 4.1. OrdenTrabajo

Nombre canónico de la cabecera actualmente persistida como `registro_diario_produccion`. Conserva:

- identidad interna estable;
- código visible `OT-######`;
- OF y corrida ejecutadas;
- máquina, fecha operativa, turno y horario;
- `created_at`, `iniciada_at`, `cerrada_at` y `timezone_snapshot`;
- snapshots técnicos de la OF, corrida y máquina;
- estado de ejecución;
- detalles horarios con maquinista, color, ciclos y observaciones;
- consumos y salidas vinculadas;
- estación de origen cuando una acción se inicia desde el módulo de pesaje.

`RegistroDiarioProduccion` permanece como nombre técnico/legacy durante una migración compatible, no como un segundo agregado.

### 4.2. Correlativo OT

Código humano asignado en la misma operación que crea la OT. No representa fecha, prioridad, color ni estación. El código nunca se reutiliza después de confirmar la creación o anulación.

### 4.3. Plan agregado de mangas de OF/corrida

Al liberar la OF/corrida, central calcula automáticamente `PlanMangasOF` por
salida usando cantidad objetivo, peso unitario snapshot, [[Tipo_Manga]] y
[[Perfil_Empaque]]. El plan conserva cantidad total de unidades, kg teóricos,
cantidad de mangas propuesta y distribución de la última manga parcial. Todavía
no asigna correlativos de manga, fecha de OT ni maquinista.

Al crear una OT se asigna una porción del plan de OF/corrida. La suma de
asignaciones normales activas de las OT no puede superar el plan sin
autorización de manga extra.

### 4.4. Manga planificada de salida

Identidad reservada antes del pesaje para una futura unidad logística de salida. Declara como mínimo:

- OT, OF y corrida;
- `LoteSalidaPiezaColor` exacto;
- pieza y color visibles como snapshot;
- secuencia dentro de la OT y código visible `OF0042-OT0301-M003`;
- maquinista asignado, si ya se conoce;
- estado de impresión;
- peso real vacío.

La planificación reserva identidad, no existencia física ni inventario. El primer sticker impreso consume un cupo normal del plan; un borrador no lo consume y una manga anulada libera el cupo.

Cada plan congela la revisión de [[Perfil_Empaque]], tipo de contenedor, cantidad objetivo, peso unitario snapshot, peso teórico y tolerancias. El cálculo parte de unidades físicamente probadas y respeta el peso bruto máximo.

Cuando las piezas se unen con componentes preexistentes antes de embolsarse, US-010C no crea una bolsa simple: entrega su `LoteSalidaPiezaColor` a US-010F, que planifica una bolsa de [[Orden_Operacion]] cuyo contenido será [[Lote_WIP]] o producto final según la ruta congelada.

El prearmado concurrente no convierte al maquinista en digitador de armado.
La OT de Fabricación conserva ciclos y unidades buenas; la OT de Armado
concurrente conserva el cierre de la manga y sus consumos. Ambas pueden tener
el mismo trabajador como actor físico, pero mantienen responsabilidades y
hechos separados.

### 4.5. Etiqueta e intento de impresión

Cada impresión se modela como [[Etiqueta_Manga]] y posee `label_id` distinto del `manga_id`. Una etiqueta emitida no se reimprime: reemplazarla requiere autorización del Jefe de Producción, invalida la versión anterior con motivo y crea una nueva. La manga y su cupo no cambian.

### 4.6. Tiempo real operativo

Significa que cada ciclo/intervalo, cantidad buena, consumo, armado o pesaje confirmado actualiza inmediatamente la proyección local y se refleja en central al recibir su evento. No implica conocer ciclos que nadie registró ni instalar sensores de máquina en este corte. La interfaz siempre muestra recencia y eventos pendientes de sincronización.

### 4.7. SaldoWIPSalida

Proyección por `LoteSalidaPiezaColor` de piezas buenas confirmadas que todavía no fueron embolsadas ni consumidas por armado. Se acredita mediante `SALIDA_BUENA_CONFIRMADA` y se debita mediante `EMBALAJE_DIRECTO` o `CONSUMO_EN_LINEA_ARMADO`, con `operation_id` idempotente. Permite alimentar US-010F sin crear una bolsa ficticia; su definición completa está en [[Saldo_WIP_Salida]].

### 4.8. ReservaWIPSalida

Asignación autoritativa creada en central antes de que una manga pueda pesarse. Para salida simple usa `SALDO_EXISTENTE` y fija `cantidad_asignada`; para armado puede usar saldo existente o `CREDITO_EN_LINEA_PENDIENTE` con cantidad máxima.

### 4.9. Tiempos de la OT y del pesaje

`fecha_operativa` determina el día al que se acredita el avance. `created_at` demuestra cuándo central creó la OT y `pesada_at` demuestra cuándo ocurrió el pesaje. Son datos distintos. Una OT puede cruzar medianoche o pesarse la mañana siguiente sin mover su producción a otro día.

En `America/Lima`, un pesaje el día siguiente está permitido. Una diferencia mayor a un día calendario genera alerta y exige motivo, pero no requiere aprobación; un pesaje anterior a `fecha_operativa` se bloquea salvo corrección autorizada.

## 5. Invariantes

1. Central es la única autoridad conectada para crear una OT y asignar su identidad y código.
2. La estación no crea una OT central implícitamente al sincronizar un pesaje.
3. Ninguna búsqueda por `OF + máquina + fecha + turno` sustituye al `ot_id` estable.
4. Dos OT distintas pueden compartir OF, máquina, fecha y turno cuando la operación lo requiera; no se fusionan por coincidencia de campos.
5. Todo comando de creación usa una clave idempotente.
6. El estado de impresión es independiente del estado de la OT.
7. Reemplazar una etiqueta conserva identidad y código de manga, exige autorización del JP y crea otro `label_id`.
8. La OT referencia una sola corrida/color; un relevo de maquinista se conserva
   en detalles y eventos sin convertir la OT en otra corrida.
9. Cada bolsa simple planificada referencia un `LoteSalidaPiezaColor` inequívoco de la OF/corrida/OT.
10. Una manga `BORRADOR`, `PLANIFICADA` o `PREETIQUETADA` tiene peso real nulo y no participa en stock.
11. Un lote de etiquetas 2-up imprime dos identidades distintas por fila salvo una solicitud explícita de copia duplicada.
12. El payload QR contiene versión, tipo, ID y control de integridad; los textos impresos no son su identidad.
13. La impresión física solo se ejecuta en una estación autorizada con impresora configurada.
14. Los nombres impresos son snapshots; las FKs estables siguen siendo la fuente de relación.
15. La suma de pesos de bolsas compuestas no se registra como kg producidos por la máquina; los componentes previos pertenecen al armado.
16. Una pieza producida por la OT puede tener destino `EMBALAJE_DIRECTO` o `CONSUMO_EN_LINEA_ARMADO` sin acreditarse dos veces.
17. La proyección se reconstruye desde eventos idempotentes y no suma snapshots repetidos.
18. Los ciclos calculan unidades teóricas por cavidad; las unidades buenas reales requieren confirmación de salida y se asignan una sola vez a embalaje directo o armado.
19. El `SaldoWIPSalida` nunca es negativo y no es editable directamente.
20. Una OT no puede cerrar mientras tenga mangas directas que no estén resueltas como `PENDIENTE_RECEPCION_ALMACEN` o `ANULADA`, ni salidas buenas sin destino o saldo WIP explícito.
21. El piloto conectado bloquea el cierre mientras exista una captura en curso o una manga planificada sin pesar/anular.
22. Una [[Orden_Operacion]] puede continuar después de cerrar su OT de contexto cuando los cuerpos buenos ya quedaron acreditados y el WIP de la OT está conciliado; sus bolsas y consumos posteriores se gobiernan por el estado de la propia orden.
23. Una bolsa armada con modo `CREDITO_EN_LINEA_PENDIENTE` bloquea el cierre de la OT hasta sincronizar su comando o anular la reserva; central nunca añade producción nueva a una OT cerrada.
24. Una reserva WIP activa es exclusiva por cantidad.
25. Una manga sin ingreso manual usa su `cantidad_asignada` como confirmación implícita al pesar, con fuente `PLAN_CONFIRMADO_POR_PESAJE`; el peso jamás determina unidades.
26. La cantidad por bolsa proviene de una regla de empaque aprobada o de un override autorizado con motivo; nunca solo de kg objetivo.
27. Cambiar el maestro de empaque no modifica bolsas ya planificadas o impresas.
28. Una etiqueta sobrante se invalida y una manga no utilizada se anula; ninguna se reasigna silenciosamente a otro artículo, color u operación.
29. El override puede reducir cantidad o usar tara real, pero nunca superar capacidad probada, peso neto operativo ni peso bruto máximo; una regla inviable no crea identidades.
30. Una operación `ORDEN_FABRICACION` no crea una `OrdenArmado` paralela ni
    acredita dos veces WIP/producto.
31. Una manga es `NORMAL` mientras las mangas activas que consumen cupo no excedan el plan; excederlo exige autorización JP, tipo `EXTRA` y motivo.
32. Anular una manga antes de pesar libera el cupo; reemplazar su etiqueta no lo libera ni consume otro.
33. Todo avance de una manga se acredita a `OT.fecha_operativa`, no a `DATE(pesada_at)`.
34. Los cortes horarios enlazan pesajes finales por identidad y nunca copian o
    suman nuevamente el peso de una manga.
35. El OCR de un parte horario produce un borrador pendiente de confirmación y
    no acredita unidades buenas.

## 6. Flujo principal

1. El supervisor abre la interfaz central desde una PC de oficina o desde la PC
   de Balanza.
2. Selecciona una OF/corrida liberada.
3. La interfaz consulta central y muestra su snapshot vigente.
4. El supervisor confirma máquina, fecha, turno y demás datos requeridos.
5. La interfaz solicita a central crear la OT con idempotencia.
6. Central valida, asigna identidad global/correlativo y devuelve la OT.
7. Central envía la hoja/sticker OT a la impresora de Balanza; si falla, queda
   pendiente de impresión.
8. Central muestra el `PlanMangasOF` calculado al liberar la OF/corrida y el usuario asigna a la OT la porción que ejecutará ese día.
9. Central propone cantidad y número de mangas usando una regla de empaque aprobada; el usuario revisa el reparto —incluida la última parcial— y cualquier override exige permiso/motivo.
10. Al confirmar, central crea identidades `OPxxxx-OTxxx-Mxxx` y congela regla, tipo de manga, cantidad y pesos teóricos, sin acreditar inventario.
11. La estación imprime etiquetas de prepesaje 2-up y el supervisor las
    entrega físicamente a los maquinistas.
12. La ejecución registra detalles, inputs reales y cantidades buenas contra la misma OT y acredita su `SaldoWIPSalida` una sola vez; para prearmado inmediato, esa acreditación puede ocurrir dentro del comando compuesto de US-010F.
13. Antes de habilitar el pesaje, central crea `ReservaWIPSalida`: cantidad exacta para salida simple o modo/cantidad máxima para una operación.
14. Una salida directa pasa a US-010D y aplica la reserva como `EMBALAJE_DIRECTO`; una salida destinada a prearmado pasa primero a US-010F y se debita como `CONSUMO_EN_LINEA_ARMADO` al confirmar la bolsa de operación.
15. El cierre valida balance, bolsas directas pendientes, reservas/créditos pendientes y destino/saldo explícito de cada salida; no espera el cierre de una Orden de Operación que solo use la OT como contexto ya conciliado.
16. Una OT emitida o en ejecución puede pasar a `PAUSADA` por cambio de prioridad mediante un comando autorizado. La pausa no revierte hechos confirmados ni reasigna reservas automáticamente.

## 7. Estados

### 7.1. OT

`PLANIFICADA -> EMITIDA -> EN_CURSO -> PAUSADA -> EN_CURSO -> FINALIZADA -> CERRADA`

Compatibilidad temporal: `CREADA` se interpreta como `PLANIFICADA` y
`EN_EJECUCION` como `EN_CURSO` para contratos existentes. Transiciones
compensatorias: `PLANIFICADA` o `EMITIDA` pueden pasar a `ANULADA`; una OT
cerrada no se elimina ni se reabre sin autorización y motivo.

La transición a `CERRADA` exige resolver todas las mangas simples planificadas. Las mangas de operación WIP/producto no bloquean por sí solas cuando los cuerpos ya están acreditados; sí bloquean mientras declaren `CREDITO_EN_LINEA_PENDIENTE`. Una vez conciliada la producción, la [[Orden_Operacion]] conserva autoridad aunque cierre la OT contextual.

`PAUSADA` es una detención temporal de la ejecución, no una anulación ni una
congelación de configuración. Exige motivo, actor y momento; puede incluir la
orden prioritaria que la originó. Las reservas se mantienen retenidas por
defecto. Liberarlas requiere una acción explícita con permiso y motivo.

Una manga abierta con contenido debe cerrarse y después pesarse; si no puede
cerrarse, su contenido se reconcilia y la manga se anula antes de abandonar la
estación. Una manga preetiquetada no puede reutilizarse para otra OT.

### 7.2. Manga

`BORRADOR -> PLANIFICADA -> PREETIQUETADA -> PESADA -> ETIQUETADA_FINAL -> PENDIENTE_RECEPCION_ALMACEN`

Desde cualquier estado previo al pesaje puede pasar a `ANULADA` con motivo; solo el Jefe de Producción puede autorizar la anulación. Una manga pesada solo se corrige mediante eventos compensatorios. La recepción de almacén es posterior y no forma parte de este piloto.

## 8. Criterios de aceptación ATDD/BDD

### OTC-01 — Crear la OT central

**Dado** una OF/corrida liberada con máquina y snapshot técnico válidos  
**Cuando** la estación solicita crear una OT con fecha y turno  
**Entonces** central crea un único registro canónico, asigna identidad global y `OT-######`, y la estación recibe su payload imprimible.

### OTC-02 — Reintento idempotente

**Dado** que central creó una OT pero la estación perdió la respuesta  
**Cuando** repite la misma clave y payload  
**Entonces** obtiene la misma OT y el mismo correlativo, sin consumir otro número.

### OTC-03 — Conflicto de clave

**Dado** una clave usada para crear una OT  
**Cuando** se reutiliza con otra OF/corrida, máquina o fecha  
**Entonces** central responde `IDEMPOTENCY_CONFLICT` y no crea nada.

### OTC-04 — OF no ejecutable

**Dado** una OF borrador, cerrada o inexistente  
**Cuando** se intenta crear la OT  
**Entonces** el comando se rechaza sin asignar correlativo.

### OTC-05 — Impresora falla después de crear

**Dado** una OT central creada  
**Cuando** la impresora no acepta el trabajo  
**Entonces** la OT permanece creada con impresión pendiente y puede reimprimirse con la misma identidad.

### OTC-06 — Reimpresión

**Dado** una OT existente  
**Cuando** un usuario autorizado solicita reimprimir  
**Entonces** se registra un nuevo intento, se marca como copia y no se crea ni consume otra OT.

### OTC-07 — Relevo de maquinista dentro de una OT

**Dado** una OT que conserva la misma OF, corrida/color, máquina, fecha y turno  
**Cuando** cambia el maquinista durante su ejecución  
**Entonces** la OT conserva su identidad y registra asignaciones consecutivas con actor, inicio, fin y motivo, sin sobrescribir al responsable anterior.

### OTC-07A — Cambio de color en una máquina

**Dado** una máquina que debe pasar a otra corrida, receta o `ColorProduccion`  
**Cuando** el supervisor autoriza el cambio  
**Entonces** se pausa o finaliza la OT anterior y se crea o despacha otra OT para la nueva corrida/color  
**Y** ninguna manga o preetiqueta de la corrida anterior se reutiliza para la nueva.

### OTC-08 — Planificar bolsas de salidas exactas

**Dado** una OT con `LoteSalidaPiezaColor` vinculados para asa y broche fucsia  
**Cuando** se planifican tres bolsas de asa y dos de broche  
**Entonces** se crean cinco identidades distintas, cada una vinculada a su salida exacta y sin incrementar inventario.

### OTC-09 — Impresión 2-up

**Dado** cuatro bolsas planificadas  
**Cuando** se imprime el lote normal  
**Entonces** se producen dos filas físicas con dos QR distintos por fila y ninguna identidad duplicada entre bolsas.

### OTC-10 — Cantidad impar

**Dado** tres bolsas planificadas  
**Cuando** se imprime en formato 2-up  
**Entonces** la última columna queda vacía o marcada como no utilizable; no repite silenciosamente la tercera identidad.

### OTC-11 — Anular etiqueta no utilizada

**Dado** una bolsa planificada que no fue pesada  
**Cuando** se anula con motivo  
**Entonces** no genera inventario y un escaneo posterior informa `ANULADA`.

### OTC-12 — No inferir OT desde un pesaje

**Dado** un evento que solo contiene OF, máquina, fecha y turno, pero no `ot_id`  
**Cuando** intenta sincronizarse por el contrato SCM  
**Entonces** se rechaza o queda en conciliación; central no crea ni selecciona una OT por coincidencia heurística.

### OTC-13 — Piloto conectado

**Dado** una OT y sus mangas planificadas  
**Cuando** central deja de estar disponible  
**Entonces** el piloto bloquea creación, impresión y pesaje con un mensaje operativo  
**Y** no inventa identidades ni conserva capturas offline.

### OTC-14 — Balance de ejecución

**Dado** inputs emitidos o una premezcla identificada  
**Cuando** la OT confirma la corrida  
**Entonces** conserva consumos, buenos, rechazados, ramal, WIP y diferencia; solo cierra cuando el balance cumple tolerancia o existe desviación autorizada.

### OTC-15 — Prearmado durante ciclos lentos

**Dado** una OT que produce cuerpos de balde y un prearmado que consume asas fabricadas previamente  
**Cuando** se registran cuerpos con destino `CONSUMO_EN_LINEA_ARMADO`  
**Entonces** la OT acredita únicamente las unidades y kg estándar de los cuerpos  
**Y** delega el consumo de asas y la bolsa de baldes armados a US-010F  
**Y** el peso total de esa bolsa no infla el avance de inyección.

### OTC-16 — Actualización operativa en línea

**Dado** una OT visible en la estación y en central  
**Cuando** se confirma un intervalo de ciclos, un armado o un pesaje  
**Entonces** la estación actualiza su avance inmediatamente  
**Y** central aplica el mismo evento una sola vez al recibirlo  
**Y** ambas vistas muestran hora de actualización y sincronización pendiente cuando corresponda.

### OTC-17 — Un cuerpo, un solo destino

**Dado** 100 cuerpos buenos confirmados en el `LoteSalidaPiezaColor` de la OT  
**Cuando** 60 se embolsan directamente y 40 se consumen en armado en línea  
**Entonces** el saldo WIP queda en cero  
**Y** intentar asignar cualquiera de esas unidades otra vez se rechaza sin alterar el avance producido.

### OTC-18 — Manga pendiente bloquea el cierre

**Dado** una manga simple planificada o preetiquetada sin pesaje  
**Cuando** central intenta cerrar la OT  
**Entonces** rechaza el cierre porque la manga continúa pendiente  
**Y** después de pesarla o anularla la OT puede volver a evaluar su cierre.

### OTC-19 — Cantidad simple asignada antes de pesar

**Dado** una manga simple con 120 unidades asignadas desde el plan y reserva central activa  
**Cuando** el maquinista cuenta físicamente y pesa sin ingresar cantidades  
**Entonces** el comando confirma 120 unidades con fuente `PLAN_CONFIRMADO_POR_PESAJE`  
**Y** no calcula cantidad dividiendo el peso.

### OTC-20 — Bolsa sin cantidad autoritativa

**Dado** una bolsa simple planificada pero sin cantidad confirmada ni reserva WIP asignada  
**Cuando** se intenta habilitar F2  
**Entonces** la estación bloquea la captura SCM y solicita asignar o confirmar unidades.

### OTC-21 — Crédito en línea conocido por central

**Dado** una futura bolsa armada que acreditará hasta 50 cuerpos al cerrar  
**Cuando** central la prepara para pesaje  
**Entonces** crea una reserva `CREDITO_EN_LINEA_PENDIENTE` con cantidad máxima y estación  
**Y** la estación no puede cambiar ese modo.

### OTC-22 — Plan de bolsas desde perfil aprobado

**Dado** un objetivo de 250 unidades y una regla aprobada con capacidad efectiva 100  
**Cuando** central planifica las bolsas  
**Entonces** propone tres identidades con cantidades 100, 100 y 50  
**Y** cada una congela tipo de contenedor, revisión, cantidad y peso teórico.

### OTC-23 — Sin regla de empaque

**Dado** una salida sin regla aprobada ni override autorizado  
**Cuando** se intenta generar etiquetas automáticamente  
**Entonces** el sistema informa `SIN_REGLA_EMPAQUE`  
**Y** no aproxima el número de bolsas dividiendo kg.

### OTC-24 — Override respeta límites físicos

**Dado** una regla aprobada cuyo límite efectivo permite 100 unidades<br>
**Cuando** se solicita un override de 110<br>
**Entonces** central lo rechaza aunque el usuario tenga permiso de override<br>
**Y** conserva motivo, actor e intento para auditoría.

### OTC-25 — Plan automático desde la OF

**Dado** una OF/corrida con salidas, cantidades y perfiles de empaque vigentes  
**Cuando** se crea o libera  
**Entonces** central calcula automáticamente el plan agregado de mangas por salida en unidades y kg  
**Y** no genera todavía códigos de manga ni etiquetas.

### OTC-26 — Asignar plan a una OT

**Dado** una corrida de OF con ocho mangas pendientes para Fucsia  
**Cuando** se crea una OT diaria y se le asignan cuatro  
**Entonces** central crea cuatro identidades `OPxxxx-OTxxx-Mxxx` normales  
**Y** conserva cuatro mangas pendientes de asignación para otra OT.

### OTC-27 — Manga extra

**Dado** una OT que ya consumió todos sus cupos planificados activos  
**Cuando** se solicita otra manga  
**Entonces** exige autorización del Jefe de Producción y motivo  
**Y** la crea con `tipo_manga_plan=EXTRA` visible en el sticker.

### OTC-28 — Reemplazo de etiqueta

**Dado** una etiqueta de prepesaje impresa y dañada  
**Cuando** el Jefe de Producción autoriza reemplazarla con motivo  
**Entonces** la etiqueta anterior queda `INVALIDADA`, se crea otro `label_id` y aumenta la versión  
**Y** la manga conserva código, contenido y cupo normal.

### OTC-29 — Fecha productiva independiente del pesaje

**Dado** una OT con `fecha_operativa=2026-07-23`  
**Cuando** una manga se pesa el `2026-07-24` por la mañana  
**Entonces** el avance se acredita al 23 de julio y se conserva el tiempo real del pesaje  
**Pero** un pesaje posterior al 24 de julio genera alerta y exige motivo.

### OTC-30 — Producto terminado directo

**Dado** una operación terminal ejecutada por `ORDEN_FABRICACION` cuya salida es producto terminado  
**Cuando** se planifican sus mangas  
**Entonces** el contenido objetivo es `LOTE_PRODUCTO_TERMINADO`  
**Y** no se crea una orden de armado ficticia.

## 9. Dataset de referencia

| Dato | Valor |
|---|---|
| OF | `OF-0042` (`codigo_legacy_op=OP-0084` solo en fixture migrado) |
| OT esperada | `OT-000123` |
| Máquina | `INY-03` |
| Fecha/turno | `2026-07-23 / DIURNO` |
| Salida 1 | `LSPC-000123-01 · PC-000004 · Asa · Fucsia` |
| Salida 2 | `LSPC-000123-02 · PC-000009 · Broche · Fucsia` |
| Mangas | 3 de Asa, 2 de Broche |
| Formato | 2-up, pares distintos |

## 10. Permisos mínimos

- `OT_CREAR`
- `OT_INICIAR`
- `OT_CERRAR`
- `OT_PAUSAR_PRIORIDAD`
- `OT_REANUDAR`
- `OT_DESCOMPROMETER_RESERVA`
- `OT_ANULAR`
- `OT_REIMPRIMIR`
- `MANGA_PLANIFICAR`
- `MANGA_EXTRA_SOLICITAR`
- `MANGA_EXTRA_APROBAR`
- `MANGA_ETIQUETA_IMPRIMIR`
- `MANGA_ETIQUETA_REEMPLAZAR_APROBAR`
- `MANGA_ANULAR_APROBAR`

La asignación a personas reales continúa siendo una puerta de UAT; la autorización no se deduce de que la solicitud provenga de la estación.

## 11. Fuera de alcance

- Captura y sincronización definitiva del peso: US-010D.
- Recepción y movimiento inicial de inventario: [[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex|US-010I]].
- Molienda y nuevo lote de material recuperado: US-010E.
- Ejecución y consumo de prearmado WIP o armado final: US-010F; esta historia conserva el handoff de las piezas actuales.
- Despacho: US-010G.
- Permitir correlativos manuales libres como operación normal.
- Control remoto de balanza o impresora desde central.
- Operación y sincronización offline de la estación.

## 12. Decisiones operativas validadas — 2026-07-24

1. El sticker de OT imprime dos copias idénticas por defecto y permite configurar la cantidad; las mangas 2-up imprimen identidades distintas.
2. La OF/corrida calcula automáticamente un plan agregado; cada OT asigna una porción y genera identidades usando capacidad en unidades y kg de [[Perfil_Empaque]].
3. El maquinista impreso es la asignación prevista; el actor real se captura por separado durante la ejecución/pesaje.
4. Una OT conserva `fecha_operativa`, `created_at` y tiempos reales separados; el avance siempre pertenece a la fecha operativa.
5. El maquinista cuenta, pero no ingresa cantidades: pesar confirma implícitamente la cantidad asignada y el peso nunca infiere unidades.
6. Un cupo se consume al imprimir la primera etiqueta, una anulación libera el cupo y una manga adicional exige autorización JP y motivo.
7. Una etiqueta emitida no se reimprime: el JP autoriza invalidarla y crear otra versión identificada.
8. El piloto opera conectado; offline queda fuera de alcance.
9. Pesar deja la manga `PENDIENTE_RECEPCION_ALMACEN` y no crea Kardex.

## 13. Definición de preparada

- [x] La equivalencia OT/RDP/Hoja de Producción está explícita.
- [x] La autoridad central y la impresión local están separadas.
- [x] El flujo prioritario y sus fallos idempotentes tienen escenarios.
- [x] Las bolsas planificadas no se confunden con inventario.
- [x] La frontera con US-010D está definida.
- [x] Saldo y reserva WIP tienen reglas y escenarios observables.
- [x] Producción validó las nueve decisiones operativas del apartado 12.
- [x] Plan automático OF/corrida, asignación OT, manga extra y reemplazo de etiqueta tienen escenarios.
- [x] Fecha operativa, fecha de creación y fecha de pesaje están separadas.
- [x] El piloto conectado termina antes de recepción/Kardex.
- [x] Se acepta un dataset sintético normalizado para desarrollo porque no existen OF reales bajo el modelo nuevo.
- [ ] Se valida la primera OF real normalizada durante UAT.
- [x] Se registró [[Baseline_TS-010R_C_D_2026-07-24]]; suites rápidas verdes y PostgreSQL rojo por tres pruebas previas.

El corte C-core está implementado localmente. No se convierte ninguna OP/OF legacy
ni se alteran sus pesajes. La historia permanece pendiente de UAT física 2-up y
de la primera OF real normalizada; captura de peso y etiqueta postpesaje
continúan en [[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]].
