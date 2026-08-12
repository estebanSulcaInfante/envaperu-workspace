---
tipo: contexto-operativo
estado: decision-aplicada-pendiente-uat
fecha_creacion: 2026-08-07
fecha_actualizacion: 2026-08-08
tags: [scm, produccion, ot, maquinas, maquinistas, talonario, qr, pesaje, fast-food]
relaciones:
  - "[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]"
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[Refactor_OT_y_Trabajo_de_Color_alineado_ISA95]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
  - "[[Registro_Diario]]"
  - "[[Orden_Fabricacion]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-08-01_Stickers_Prepesaje_como_Orden_Fisica_de_Manga]]"
  - "[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]]"
  - "[[Flujo_Distribucion_Stickers_y_Pesaje_Sin_PC_en_Maquina]]"
---

# Contexto operativo: 13 máquinas, talonario, QR y pesaje central

## 1. Propósito y fuente

Esta nota registra el contexto productivo comunicado por el responsable
funcional el 7 de agosto de 2026. Separa hechos observados, alternativas y la
decisión adoptada el 8 de agosto mediante
[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]. Las alternativas se
conservan como evidencia; la ADR y US-010M son la autoridad vigente.

## 2. Realidad productiva comunicada

1. La planta opera aproximadamente 13 máquinas de producción.
2. En cada máquina trabaja un solo maquinista en un instante dado. La persona
   puede cambiar por turno, relevo, ausencia o reasignación.
3. Una misma máquina puede cambiar de color durante el día.
4. Existe una sola Balanza con una PC, lector QR e impresora compartidos por
   todos los maquinistas.
5. Los maquinistas cuentan físicamente sus unidades y las anotan en un
   talonario.
6. Incorporar el talonario al SCM exigiría rediseñar el formato y desarrollar
   OCR más una validación humana de resultados ambiguos.
7. La prioridad es reducir al mínimo la digitación del maquinista para evitar
   errores: idealmente recibe identificadores QR, escanea y pesa.
8. El pesaje ordinario ocurre al final del turno y se evalúa un control
   intermedio a mitad del día.
9. Algunas mangas pueden permanecer en llenado durante varios días.
10. Gerencia solicita una experiencia semejante a FastFood: una demanda genera
    órdenes o tickets, cada estación/trabajador recibe trabajo y después
    registra su cumplimiento.

## 3. Interpretación vigente de OT, trabajador y color

La OT no pertenece a un trabajador ni a un color. En el piloto representa la
cabecera familiar de una máquina para una fecha operativa y turno:

    máquina + fecha operativa + turno

Dentro de ella se crea una cola de `Trabajo de color`; cada hijo conserva la
atomicidad técnica:

    OF + corrida/color + molde/receta + salidas + cupo

Las cardinalidades vigentes son:

- una máquina tiene como máximo una OT de Fabricación vigente por fecha/turno;
- una OT contiene uno o varios Trabajos de color;
- solo un Trabajo de color puede estar `EN_EJECUCION` por máquina;
- A → B → A pausa y reanuda los trabajos sin cambiar la cabecera OT;
- una manga pertenece al Trabajo de color y salida exactos;
- un Trabajo de color puede tener maquinistas secuenciales y subconjuntos de
  mangas asignados, nunca dos responsables principales simultáneos;
- cambiar trabajador no cambia la OT ni el Trabajo de color;
- cambiar corrida/color cambia el Trabajo de color, no necesariamente la OT.

El responsable predeterminado de la OT solo propone la primera asignación; el
trabajador no integra la identidad documental.

## 4. Traducción del modelo FastFood al SCM

| Metáfora FastFood | Concepto SCM | Responsabilidad |
|---|---|---|
| Pedido del cliente | OP | Qué producto y cantidad necesita el negocio. |
| Lote/receta de cocina | OF + corrida | Cómo fabricar, con qué molde/material y en qué color. |
| Bandeja de una estación | OT | Qué máquina trabajará en una fecha/turno y qué cola atenderá. |
| Ticket de preparación | Trabajo de color | Qué OF/corrida/color, salidas y cupo se ejecutan atómicamente. |
| Empleado que toma el ticket | Asignación operativa | Quién atiende la máquina durante un intervalo. |
| Ítem individual del pedido | Manga/preetiqueta | Contenedor, artículo y cantidad física a completar. |
| Pase o expedición | Balanza | Verifica el QR, registra peso y confirma cumplimiento. |
| Pedido servido | Manga finalizada | Cantidad confirmada, postetiqueta y espera de Almacén. |

La hoja de OT y las preetiquetas ya forman una versión física de este modelo:
el supervisor despacha el trabajo, el maquinista recibe tickets y la Balanza
confirma cada resultado sin reconstruir documentos.

## 5. Baseline evaluado y resultado del refactor

### 5.1. Baseline anterior

- OT diaria asociada a una corrida/color y máquina exactas.
- Maquinista previsto con relevos auditados sin cambiar la identidad de la OT.
- Hoja de OT como instrucción general y preetiqueta como orden física de una
  manga.
- Cantidad objetivo impresa y confirmación sin digitación cuando se completa.
- El peso controla evidencia física, pero nunca infiere unidades.
- OCR únicamente como propuesta o contingencia con confirmación humana.

### 5.2. Rigidez encontrada antes de US-010M

- crear OT exige un solo maquinista;
- ese maquinista se copia a todas las mangas;
- no existe asignación temporal, relevo ni reasignación canónica;
- una manga pertenece a una sola OT;
- existe un único pesaje final por manga;
- una manga pendiente bloquea el cierre de su OT;
- la identidad pesado_por de la estación procede de una configuración fija,
  no de la credencial de quien usa la única Balanza.

### 5.3. Resultado aprobado

US-010M reemplaza para Fabricación la regla `una OT = una corrida/color` por
`una OT = una máquina/fecha/turno` con uno o varios Trabajos de color hijos.
La atomicidad no se elimina: baja al Trabajo de color. El relevo conserva ese
trabajo; el cambio de corrida/color pausa el actual e inicia o reanuda otro
dentro de la misma OT.

El único pesaje final por manga se conserva. Pesaje intermedio y continuidad
multi-jornada continúan en US-010K y no fueron incluidos en este refactor.

## 6. Fuentes posibles de cantidad y atribución

Ningún QR ni balanza observa por sí solo el conteo escrito por el maquinista.
Cada fuente responde algo diferente:

| Fuente | Qué demuestra | Límite |
|---|---|---|
| Cantidad fija de la preetiqueta | Unidades exactas declaradas cuando la manga se completa según el ticket. | No reparte una manga abierta entre varios trabajadores. |
| Diferencia entre pesajes de frontera | Kg físicos aportados durante un tramo. | No equivale a unidades exactas. |
| Conteo en relevo | Unidades declaradas por cada trabajador/tramo. | Requiere comunicar al menos un número. |
| Ciclos × cavidades | Unidades teóricas de máquina por intervalo. | Rechazos y piezas no conformes requieren excepción. |
| Talonario | Conteo manual declarado y detalle horario. | Errores, demora y transcripción. |
| OCR del talonario | Propuesta digital del papel. | No puede ser autoridad sin revisión humana. |
| Contador/PLC/IoT | Ciclos automáticos y tiempos. | Integración de 13 máquinas, resets, red y Calidad. |

Para una manga completa atendida por un trabajador, la cantidad fija del QR
permite confirmar unidades sin entrada manual. El problema de atribución exacta
solo aparece cuando una misma manga cruza trabajadores u OT y se necesita
repartir sus unidades entre ellos.

## 7. Alternativas operativas

### Opción A — Cerrar cada manga al terminar la OT

Cada día o cambio de trabajador termina con una manga final, aunque tenga una
cantidad menor a la capacidad estándar. La siguiente OT inicia otra manga.

**Ventajas:** respeta el modelo actual, evita traspasos y conserva atribución
directa.

**Costos:** más bolsas, más etiquetas, más ingresos en Almacén y captura
supervisada de la cantidad final parcial. No representa bien artículos que
tardan varios días.

### Opción B — Manga exclusiva del trabajador hasta completarse

La manga continúa varios días con el mismo responsable. Si otro maquinista
toma la máquina, inicia su propia manga y la anterior queda segregada para el
dueño original.

**Ventajas:** cero digitación normal, cantidad final atribuible a una persona y
poca lógica de traspaso.

**Costos:** varias mangas físicas abiertas, espacio y riesgo de abandono ante
ausencias. La atribución diaria sigue siendo limitada.

### Opción C — OT diaria con asignaciones y tramos de manga

La OT conserva fecha/turno. La manga se ancla a OF/corrida/color y mantiene el
mismo QR. Cada participación registra un tramo con OT, máquina, trabajador,
inicio/fin y pesajes de frontera. La siguiente OT acepta la continuidad.

**Ventajas:** preserva la arquitectura y reportes diarios, representa relevos y
mangas de varios días, y mide kg por tramo.

**Costos:** requiere el refactor más importante de manga, cierre de OT,
etiquetas y pesajes. Las unidades por tramo necesitan conteo, ciclos o una
estimación explícita.

Puede limitarse a perfiles marcados PERMITE_MULTI_JORNADA; el flujo normal
continúa con un solo tramo.

### Opción D — OT multijornada y partes diarios

La OT se redefine como ticket de máquina+corrida/color que dura hasta terminar
el trabajo. Debajo se crean jornadas/turnos con trabajador y contadores. La
manga nunca cruza OT; solo cruza partes diarios.

**Ventajas:** modelo mental FastFood muy directo y continuidad simple de la
manga.

**Costos:** reemplaza la decisión fuerte de OT diaria y exige rehacer reportes,
estados, códigos, cierres, contratos y UAT. También se aproxima a la
responsabilidad que ya cumple la corrida de OF.

### Opción E — Tickets QR de aporte

Además del QR de manga, el trabajador recibe tickets de cantidades fijas, por
ejemplo 100 o 200 unidades. Escanear el ticket registra cumplimiento de ese
bloque y permite sumar unidades exactas por persona sin teclado.

**Ventajas:** reproduce literalmente recibir pedido -> completar ticket, usa
la impresora y lector existentes y conserva exactitud por trabajador.

**Costos:** más papel y escaneos, manejo de pérdidas/duplicados y excepción para
remanentes que no completan un bloque.

### Opción F — Talonario estructurado y OCR

Se rediseña el parte, se incorpora QR por OT y el OCR genera un borrador que el
supervisor confirma.

**Ventajas:** cambia poco el hábito actual y puede apoyar la marcha blanca.

**Costos:** automatiza una fuente ruidosa, mantiene doble registro, entrega datos
tarde y requiere confirmación. No debe ser la fuente maestra del flujo nuevo.

### Opción G — Contadores automáticos de máquina

Se asigna trabajador a máquina/intervalo y se capturan ciclos desde contador,
PLC o hardware adicional. El pesaje confirma mangas, no la producción diaria.

**Ventajas:** mínima interacción y visibilidad continua.

**Costos:** integración, red y mantenimiento en 13 máquinas; los ciclos siguen
siendo unidades teóricas hasta descontar rechazos.

## 8. Decisión adoptada para el piloto

### 8.1. Camino normal

Adoptar una experiencia FastFood sobre la cabecera OT y su cola de trabajos:

1. Tablero de 13 máquinas con una columna por recurso.
2. Cada columna muestra la OT de la jornada y su cola de Trabajos de color,
   maquinista vigente, mangas entregadas, abiertas y completadas.
3. El supervisor asigna al maquinista por intervalo del Trabajo de color y
   distribuye en bloque subconjuntos de stickers.
4. Cada sticker declara una cantidad objetivo. El maquinista cuenta hasta esa
   cantidad, escanea el QR y pesa; completar confirma el objetivo sin digitar.
5. Cambiar de color pausa el Trabajo de color anterior e inicia o reanuda otro
   dentro de la misma OT; el maquinista conserva la nomenclatura conocida.
6. Talonario y SCM se mantienen en paralelo durante la marcha blanca. No se
   condiciona el piloto al OCR.

### 8.2. Excepción multi-jornada

No forma parte de US-010M. Durante el piloto, una manga SCM debe cerrarse con
su único pesaje final dentro de la OT propietaria. Los perfiles que tardan
varios días permanecen en el talonario/flujo anterior hasta aprobar e
implementar US-010K; no se reasigna `manga.ot_id` ni se simulan pesajes
intermedios.

### 8.3. Identidad en la Balanza compartida

Un QR de manga permite recuperar al responsable esperado, pero no prueba quién
operó físicamente la Balanza. Hay dos políticas válidas:

- **un escaneo:** manga preasignada; se atribuye al responsable vigente;
- **dos escaneos sin teclado:** credencial personal + QR de manga; se conserva
  responsable de producción y actor real de pesaje.

Si Gerencia necesita auditoría personal del uso de la Balanza, se recomienda la
segunda. Una sesión personal larga es riesgosa porque el siguiente maquinista
podría pesar con la identidad anterior.

### 8.4. Manga propietaria de Trabajo de color y relevo manual

Se adoptó conservar cada manga dentro de un Trabajo de color de una OT,
asignar subconjuntos de stickers a un maquinista y permitir que el encargado de
Producción reasigne los pendientes y, excepcionalmente, una manga abierta
dentro de la misma OT.

La propuesta es coherente y de baja carga para el caso normal, con estas
fronteras:

- cada Trabajo de color ejecuta una sola corrida/color; una OT puede contener
  varios trabajos durante la misma fecha y turno;
- un Trabajo de color puede tener maquinistas consecutivos; el trabajador no
  forma parte de su identidad y el relevo no crea otro trabajo si el contexto
  técnico no cambia;
- reasignar trabajador dentro del mismo trabajo no altera el cupo del plan;
- una manga pesada o recibida no admite reasignación retroactiva;
- no se debe traspasar a otra OT sobrescribiendo `manga.ot_id` ni cambiar su
  Trabajo de color, porque se perderían historia, fecha, cuota y coherencia de
  etiqueta.

El encargado debe operar por estado físico y digital:

| Situación | Acción permitida |
|---|---|
| Manga todavía sin etiqueta | Reasignación masiva al nuevo maquinista. |
| Etiqueta generada o impresa, pero no entregada | Reasignar y reemplazar la versión si el nombre del trabajador está impreso. |
| Etiqueta entregada, manga no iniciada | Recuperación física y aceptación del nuevo custodio antes de reasignar. |
| Manga abierta o incompleta dentro de la misma OT | Transferencia individual con motivo, conteo de frontera y entrega/recepción física; no genera pesaje intermedio. |
| Manga pesada o recibida | Asignación inmutable; cualquier corrección sigue el flujo compensatorio. |
| Cambio de corrida/color | Otro Trabajo de color dentro de la misma OT; los stickers anteriores permanecen con su trabajo, se reservan o anulan, nunca se reciclan. |

En el contrato implementado, el QR identifica tanto la manga como una versión
concreta de etiqueta mediante `label_id`. Reemplazar la preetiqueta invalida la
anterior y genera otro QR. Si Planta desea conservar físicamente el mismo QR en
cada relevo, debe cambiarse el contrato para que el sticker identifique solo la
manga y la asignación vigente se resuelva en central; no basta con una regla de
UI.

`Incompleta` no debe ser un único checkbox ambiguo. Hay que distinguir:

1. manga abierta que continuará llenándose;
2. cierre final parcial autorizado porque terminó la corrida o cambió la
   prioridad;
3. manga dañada cuyo contenido requiere transferencia o conciliación.

Para una manga abierta transferida a otro trabajador, la asignación indica
custodia, pero no demuestra por sí sola cuánto produjo cada persona. Un control
exactamente en el relevo delimita kilogramos; para atribuir unidades exactas se
necesita además conteo de frontera, contador de máquina o ticket de cantidad.

El refactor tampoco resuelve los perfiles de tres días. Si la OT sigue siendo
diaria, solo existen dos políticas coherentes para un incremento futuro:

- cerrar la manga parcialmente al fin de cada fecha y crear otra manga/QR;
- conservar una OT de origen para identidad y cupo, pero registrar tramos de
  continuidad hacia las OT diarias compatibles que contribuyeron.

El segundo camino queda como alternativa de US-010K para perfiles marcados
`PERMITE_MULTI_JORNADA`; no está habilitado por US-010M.

US-010M2 cierra la laguna de cupo identificada: anular una manga elegible antes
del pesaje la invalida, devuelve su cuota al Trabajo de color y permite crear
el reemplazo normal sin reutilizar el QR.

### 8.5. Nomenclatura de Planta y agrupación por máquina

La atomicidad por corrida/color no obliga a enseñar esa estructura documental
al maquinista. Una ejecución con cinco colores siempre necesita cinco unidades
atómicas, ya sean cinco OT simples o cinco ejecuciones hijas dentro de una OT
grande. El segundo diseño reduce códigos visibles, pero no reduce la cantidad
real de eventos, cupos, mangas ni cierres que deben trazarse.

Para no cambiar la nomenclatura de los trabajadores durante el piloto se
adoptó:

1. una OT visible por máquina, fecha y turno;
2. Trabajos de color hijos, administrados por el supervisor como una cola;
3. stickers y mangas ligados al Trabajo de color exacto, sin imprimir una sigla
   técnica adicional como requisito para el maquinista;
4. pantalla de Balanza con máquina, OT, color, OF/corrida, cantidad y responsable
   resueltos desde el QR;
5. acciones `Iniciar`, `Pausar`, `Reanudar` y `Completar` sobre cada trabajo.

Así Planta conserva la palabra OT y la base conserva atomicidad por color sin
proliferar códigos OT visibles.

## 9. Capacidad de una sola Balanza

Un control intermedio y otro al final del turno implican al menos 26 visitas
diarias si cada máquina presenta una manga, sin contar las mangas normales que
se completan durante el día. Antes de imponer controles obligatorios se debe:

- medir el tiempo real desde escaneo hasta etiqueta;
- registrar el pico de mangas por hora;
- escalonar grupos de máquinas en el corte intermedio;
- evitar pesajes de control sin una decisión que use su información;
- evaluar una segunda estación solo si la cola medida justifica el costo.

## 10. Decisiones pendientes de Planta

1. ¿Gerencia necesita exactitud oficial por trabajador, por OT/día, por máquina
   o solamente por corrida/producto?
2. ¿El maquinista que inicia una manga lenta suele regresar a la misma máquina
   durante los días siguientes?
3. ¿Planta puede segregar varias mangas abiertas de un mismo color sin riesgo
   de mezcla?
4. ¿Las máquinas poseen contadores acumulados accesibles y confiables?
5. ¿Cómo se cuentan y descuentan piezas rechazadas o retrabajadas?
6. ¿Quién transporta y pesa normalmente: el propio maquinista o un operador de
   Balanza?
7. ¿Cuántas mangas llegan a la Balanza por hora y cuánto dura hoy cada pesaje?
8. ¿Se acepta una captura supervisada del conteo solo en relevos y cierres
   parciales, manteniendo cero digitación en el flujo normal?

## 11. Consecuencia para el pipeline

La decisión de OT/Trabajo de color ya recorrió ADR → US-010M1/M2/M3 → Tech
Specs → Approved for Dev → RED/GREEN/REFACTOR. El cierre funcional se valida en
[[UAT_TS-010M_OT_y_Trabajos_Color]].

US-010K conserva las decisiones todavía abiertas sobre manga multi-jornada,
pesajes de control y tramos entre OT. US-010L conserva material de segunda,
R1…Rn y preparación experimental; ninguna de esas capacidades se incorpora de
forma implícita en US-010M.
