---
tipo: guia_usuario
estado: piloto
ruta: /guia/scm
fecha_actualizacion: 2026-08-10
tags: [frontend, scm, guia-usuario, operacion, trazabilidad]
relacionados:
  - "[[Guia_Roles_y_Permisos_SCM_Piloto]]"
  - "[[Arquitectura_Guia_SCM_Markdown]]"
  - "[[UAT_01_Configuracion_Participantes_y_Permisos]]"
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[Trabajo_OT]]"
  - "[[Trabajo_Color]]"
  - "[[Asignacion_Trabajo_OT]]"
  - "[[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes]]"
  - "[[Vista_US-010N3_Jornadas_de_Planta]]"
  - "[[US-010N4_Supervision_de_Produccion_Read_Model_Operativo]]"
  - "[[Vista_US-010N4_Supervision_de_Produccion]]"
---

# Documentación oficial SCM

## Propósito

La ruta /guia/scm es la documentación oficial de consulta para las personas que operan el SCM.
Debe permitir realizar las tareas del piloto con capacitación mínima, utilizando
los nombres visibles de las pantallas, el orden correcto de los pasos y las
reglas de autorización.

No es material para presentar el sistema. No incluye instrucciones para
facilitadores, reuniones o exposición de casos de prueba.

## Arquitectura de documentación

La interfaz adopta el patrón de documentación de producto utilizado por
frameworks y plataformas técnicas:

- navegación persistente por capítulos;
- búsqueda global por conceptos, procesos y procedimientos;
- tabla **En esta página** para referencias extensas;
- separación entre conceptos, reglas protegidas y procedimiento recomendado;
- glosario común y enlaces directos a las pantallas operativas;
- versión y alcance visibles en el encabezado.

La fuente visible continúa siendo datos estructurados del frontend para poder
probar navegación y contenido automáticamente. El vault conserva decisiones,
modelo de dominio y trazabilidad editorial; no se presenta al usuario como una
segunda guía competidora.

## Contenido

| Orden | Sección | Ruta operativa principal |
|---:|---|---|
| 1 | Cómo utilizar la guía | / |
| 2 | Participantes, roles y permisos | /datos-maestros/trabajadores |
| 3 | Maestros e imágenes | /datos-maestros |
| 4 | OP, cobertura y planificación | /planificacion |
| 5 | Recepción y Calidad de materias primas | /materiales/recepciones |
| 6 | Reserva, emisión y premezcla | /materiales/preparaciones |
| 7 | OF/OA y Jornadas de Planta | /produccion/ots-mangas |
| 8 | Supervisión de producción | /control/supervision-produccion |
| 9 | Armado y cierre de mangas PT | /produccion/ordenes-armado |
| 10 | Pesaje y postetiqueta | /produccion/pesajes |
| 11 | Corrección, reemplazo y anulación | /produccion/ots-mangas |
| 12 | Recepción de mangas, Calidad y Kardex | /produccion/recepcion-mangas |
| 13 | Merma recuperable y molienda | /produccion/reproceso |

## Estructura de cada sección

Cada tarea contiene:

1. propósito;
2. responsable;
3. información requerida;
4. condición que debe cumplirse;
5. resultado esperado;
6. elementos que debe revisar el usuario;
7. reglas que el proceso protege;
8. procedimiento recomendado;
9. enlace a la pantalla operativa.

## Principios de redacción

- Utilizar instrucciones directas y nombres visibles en la interfaz.
- Explicar una tarea por sección.
- Indicar requisitos previos antes de los pasos.
- Distinguir claramente acciones permitidas, restringidas y prohibidas.
- Explicar el resultado que debe comprobarse después de guardar.
- Indicar quién debe actuar cuando se requiere otro rol.
- No incluir datos de pruebas como si fueran información operativa.
- No describir funcionalidades fuera del piloto como comandos disponibles.

## Controles transversales

- Confirmar siempre la identidad seleccionada antes de guardar.
- No compartir identidades.
- No eliminar directamente registros confirmados.
- En Productos terminados, utilice **Desactivar/Reactivar**. El borrado físico está bloqueado incluso para perfiles administradores.
- Utilizar corrección, anulación o reversa según corresponda.
- Conservar el evento original y registrar motivo, actor y fecha.
- Separar solicitante y aprobador cuando aplica el control de cuatro ojos.
- Verificar estado, etiqueta, ubicación y nuevo evento antes de continuar.

## Regla de maestros de piezas

- **Pieza** representa una forma abstracta y no lleva fotografía ni color.
- **PiezaColor** representa la variante física fabricable y posee SKU, color e imagen.
- En un molde de varias salidas, el color se habilita para el tiro completo. El sistema crea o reutiliza las PiezaColor de todas las piezas activas del molde.
- No se admite declarar disponibilidad de color para una sola salida si las demás piezas se producen simultáneamente en el mismo tiro.

## Mindset de Artículos SCM y BOM multinivel

Un Artículo SCM es una identidad operativa, no una carpeta genérica. Debe
representar algo que la planta fabrica, arma, cuenta, pesa, mueve, almacena,
reserva, consume, empaca o necesita trazar independientemente.

- PiezaColor es la hoja fabricable con SKU y color.
- WIP es un estado intermedio real con cantidad o responsabilidad propia.
- PT es la estructura comercial completa.
- Una agrupación creada solo para ordenar la pantalla no es un WIP.

La BOM responde qué componentes y cantidades forman una salida. La ruta define
orden y centro; el perfil de empaque define acomodo; la regla define capacidad;
la OT de máquina organiza la jornada; el Trabajo de color identifica la
combinación atómica de OF, color y configuración técnica; inventario conserva cantidad, ubicación y
condición. No se duplican BOM por máquina, turno, color, centro o modalidad si
la composición permanece igual.

El sistema rechaza ciclos directos e indirectos, limita componentes a
PiezaColor/WIP, limita resultados a WIP/PT, conserva una sola revisión aprobada
vigente y congela snapshots operativos. Estas guardas evitan inconsistencias
técnicas, pero Ingeniería SCM debe mantener estructuras cortas y evitar WIP que
no representen estados reales de planta.

## Fechas de OP, OF, OA y OT

Cada fecha responde una pregunta distinta:

- **Fecha de necesidad de OP:** indica para cuándo necesita el negocio el
  producto terminado. Es la fecha autoritativa de demanda.
- **Necesidad mostrada en OF/OA:** es una consulta derivada de las OP que esa
  orden técnica cubre. Si cubre varias fechas, se muestra un rango. No se edita
  en la OF/OA.
- **Fecha operativa de OT:** indica el día y turno concretos en que se programa
  una porción del trabajo.
- **Creada, liberada, iniciada y cerrada:** son marcas de auditoría; no
  reemplazan ni la necesidad ni la fecha operativa.

Una OF u OA puede durar varias jornadas. Por eso no se le asigna una única
fecha productiva editable: se consulta su primera y última OT. Si todavía no
tiene ninguna, el sistema debe mostrar **Sin jornada programada**. Una orden
para stock o una excepción sin OP puede mostrar **Sin fecha de necesidad**.

## Jornadas de Planta

La experiencia aprobada organiza el día con una sola fecha y turno y dos modos:

1. **Fabricación por máquina:** muestra cada máquina, su OT y el Trabajo de
   color actual.
2. **Armado por centro:** muestra cada mesa/celda, su OT de Armado, OA,
   responsable, cuota, mangas y abastecimiento.

Un recurso activo permanece visible aunque todavía no tenga OT. Seleccionar una
tarjeta abre la jornada existente; no crea ni modifica registros por sí solo.
Los comandos continúan en el detalle especializado y requieren sus capacidades
habituales.

Si una mesa o centro posee más de una OT de Armado en la misma fecha y turno,
la tarjeta permite elegir la OT/OA exacta. No sume ni trate esas jornadas como
una sola orden.

En Armado concurrente seleccione el **Trabajo de color exacto** que aporta el
contexto. Revise color, artículo, OF, OT y máquina. No seleccione únicamente la
OT de máquina cuando contiene más de un color.

> [!note] Disponibilidad
> DEV-010N3 ya está implementado localmente en `/produccion/ots-mangas` con
> Fabricación por máquina y Armado por centro. El despliegue y la aceptación
> humana siguen pendientes; las acciones especializadas de Armado continúan en
> `/produccion/ordenes-armado`.

## Supervisión de producción

Use **Control > Supervisión de producción** cuando necesite responder qué OT de
Fabricación y Armado existen en un día o rango, en qué etapa están y qué
unidades, mangas, pesajes o recepciones se han confirmado. Esta pantalla es una
consulta: no inicia, pausa, corrige, recibe ni anula registros.

No confunda las dos superficies:

- **Jornadas y Trabajos de color** organiza la ejecución de un recurso, fecha y
  turno y contiene los accesos para operar.
- **Supervisión de producción** reúne una fila por OT para comparar, filtrar y
  abrir su detalle, aunque una OT de Fabricación tenga varios colores.

Procedimiento recomendado:

1. Abra `/control/supervision-produccion` y elija fecha o rango, turno y tipo de
   OT. El valor inicial es el día local.
2. Revise una fila por OT. En Fabricación, los Trabajos de color se resumen y
   se detallan sin duplicar la OT; en Armado se utilizan confirmaciones de
   salida, no avances provisionales sumados otra vez.
3. Compare **Unidades confirmadas**, **Peso físico neto** y **Kg estándar** en
   campos distintos. El peso físico proviene de pesajes vigentes; el estándar
   proviene de unidades efectivas y pesos técnicos congelados.
4. Revise las mangas pendientes de pesaje, pendientes de recepción y recibidas.
   Pesar no equivale a recibir y recibir no equivale a liberar en Calidad.
5. Abra el detalle para ver trabajos, mangas, etiquetas, recepción, inventario,
   Calidad y alertas que su perfil esté autorizado a consultar.
6. Si un campo muestra **No informado** o **Por asignar**, escale el dato
   faltante. No lo interprete como cero.
7. Compruebe **Actualizado a…**. La pantalla se actualiza cada 30 segundos
   mientras está activa y permite pausar; **Última actividad** describe un
   evento de negocio, no la salud de sincronización.
8. Para ejecutar o corregir, utilice **Abrir en Jornadas** y confirme el
   contexto de fecha, turno y OT antes de actuar.

Los datos de pesaje, alertas, Almacén y Calidad aparecen progresivamente según
capacidades. Almacén y Calidad son permisos distintos: ver uno no concede el
otro. Que una dimensión no sea visible no significa que no existan hechos. Los
filtros sensibles tampoco se convierten en “cero resultados” cuando falta
permiso.

> [!warning] Fuente legacy separada
> Las vistas históricas de avance/pesajes locales no se suman al read model de
> Supervisión. No compare un total combinado ni trate ambos como pestañas de la
> misma fuente.

> [!note] Disponibilidad
> N4 está implementada localmente y sus suites automáticas, lint y build están
> verdes. La ruta no se considera desplegada ni aceptada hasta completar smoke
> visual y [[UAT_TS-010N4_Supervision_de_Produccion|UAT-N4]] humana.

## OT de máquina y Trabajo de color

Para Fabricación se utilizan tres identidades distintas:

1. **OT de máquina:** representa una jornada definida por máquina, fecha y
   turno. Puede contener varios colores y no pertenece a un maquinista.
2. **Trabajo de color:** es el ticket atómico que vincula una OF y un color
   técnicamente homogéneo dentro de la OT. Conserva su propia meta, estado, mangas y
   asignaciones.
3. **Manga:** es el contenedor físico identificado. Pertenece a un Trabajo de
   color y conserva como contexto la OT de la jornada.

Una OT puede contener una cola de varios Trabajos de color, pero solamente uno
puede permanecer **En ejecución**. Los demás permanecen planificados, pausados,
completados o anulados. Cambiar de color no crea otra OT si se mantiene la misma
máquina, fecha y turno.

La pantalla diaria muestra una tarjeta por máquina activa, incluso cuando aún
no tiene OT. Seleccione fecha y turno, revise cuál produce, cuál está pausada o
libre y abra una tarjeta para gestionar su cola. El formulario muestra **Color
a fabricar**. Si solo existe uno, se presenta como dato heredado de la
PiezaColor/OF; el término técnico “corrida” no es necesario para operar.

### Cambio y retorno de color A → B → A

1. pausar el Trabajo A;
2. iniciar el Trabajo B;
3. completar o pausar B;
4. reanudar el mismo Trabajo A.

El retorno a A no crea otro ticket A. Pausar tampoco invalida sus mangas ni sus
QR. Una manga ya cerrada de A puede pesarse mientras A está pausado, incluso si
B es el trabajo activo de la máquina.

### Mangas, stickers y relevo de maquinista

- Las mangas y sus stickers se asignan al Trabajo de color y al maquinista que
  los ejecutará.
- El maquinista no es propietario de la OT. Un cambio de responsable no cambia
  la identidad de la jornada ni del Trabajo de color.
- En un relevo, el Supervisor selecciona el subconjunto de mangas pendientes
  que transfiere al reemplazo. Las mangas resueltas conservan al responsable
  histórico y el relevo registra actor, fecha, motivo, responsable anterior y
  responsable nuevo.
- Una manga abierta o incompleta se transfiere individualmente dentro de la
  misma OT. El Supervisor registra el motivo y el conteo acumulado en la
  frontera del relevo.
- Ese conteo documenta el traspaso físico: no es un pesaje intermedio. La manga
  conserva su identidad, color y Trabajo de color. Si la preetiqueta mostraba
  al responsable anterior, se invalida y se imprime su reemplazo antes de usarla.
- El conteo de frontera es una declaración supervisada. Sin conteo verificable,
  ticket fijo o contador de máquina, el sistema conserva custodia e intervalos,
  pero no atribuye unidades exactas a cada trabajador.
- En la balanza se escanea el QR. La estación obtiene OT, Trabajo de color, OF,
  configuración técnica, color, manga y asignación sin que el maquinista
  digite esos datos.
  El pesaje conserva además la identidad configurada en la estación de balanza
  como actor del hecho. Este dato no demuestra por sí solo qué persona llevó la
  manga si la estación usa una identidad técnica compartida.

### Frontera del piloto

El alcance de [[US-010M_OT_de_Maquina_y_Trabajo_de_Color]] termina dentro de una
sola OT y jornada:

- no se traslada una manga a la OT del día siguiente;
- no se acumulan pesajes parciales o intermedios sobre la misma manga;
- no se incluye material preparado, receta experimental ni niveles de
  reproceso;
- antes de cerrar la OT, sus mangas se completan, anulan o reemplazan mediante
  el procedimiento autorizado.

Cuando una manga no pueda resolverse dentro de la jornada, se escala el caso al
Jefe de Producción. No se debe improvisar un traslado de QR o un pesaje parcial.

## Alcance de pesaje

El rol OPERADOR_PESAJE procesa mangas trazables de fabricación y mangas de
producto terminado ya cerradas por Armado. Registra bruto, tara y neto y genera
la postetiqueta. En Fabricación, el QR también identifica el Trabajo de color y
la asignación vigente. Una manga cerrada puede pesarse aunque su Trabajo de
color se encuentre pausado.

El ingreso de merma recuperable y la molienda son operaciones separadas, con
permisos de Almacén, Jefe de Producción u Operador de Molino.

## Selección de artículos en catálogos grandes

Los campos de Artículo SCM en Ingeniería permiten escribir parte del código,
nombre o clase. Cada resultado muestra su clase para distinguir PiezaColor, WIP
y ProductoTerminado. La búsqueda ignora mayúsculas y tildes.

La lista ya llega limitada por la operación que se está configurando:

- resultado de una BOM: WIP o ProductoTerminado;
- componente de una BOM: PiezaColor o WIP;
- producto objetivo de una ruta: ProductoTerminado;
- artículo empacable: PiezaColor, WIP o ProductoTerminado;
- salida de una operación: artículos compatibles, con validación final al
  publicar la ruta.

Escribir en el buscador no cambia estas reglas. Antes de elegir, confirme código,
nombre y etiqueta de clase. Los campos con pocas opciones, como centro de
trabajo, perfil empacable o tipo de operación, continúan como listas simples.

## Presentaciones comerciales

Cada producto terminado mantiene unidad base `UN`. En **Productos →
Presentaciones comerciales**, registre las formas reales de venta o demanda,
por ejemplo `Pack x6`, con su cantidad de unidades y código de barras opcional.

La presentación predeterminada se propone al crear una OP. La cantidad
comercial se convierte antes de planificar: `10 Pack x6 = 60 UN`. La línea de
demanda conserva una copia del código, nombre y conversión utilizados.

Una presentación no repite ni modifica la BOM del PT. Tampoco define la
capacidad de mangas: esa responsabilidad permanece en perfiles, tipos de
contenedor y reglas de empaque.

## Perfiles y reglas de empaque

Un **perfil empacable** representa el estado físico y la forma de acomodo de un
artículo dentro de una manga. No identifica al producto ni al color. Por
ejemplo, una pieza suelta, un cuerpo con asa prearmada y un producto terminado
requieren perfiles distintos si su geometría o forma de apilado cambia. Varios
artículos pueden compartir un perfil cuando su acomodo es realmente
equivalente; no se duplica el perfil solamente por una diferencia de color.

El **tipo de manga** describe el contenedor físico: material, dimensiones, tara
nominal, tolerancia de tara y peso bruto máximo. Una **regla de empaque** combina
un perfil empacable con un tipo de manga y establece:

- cantidad objetivo habitual;
- cantidad máxima comprobada físicamente;
- peso neto operativo máximo y margen de seguridad;
- tolerancias del peso esperado;
- valores físicos del tipo de manga que se congelan al publicar la regla.

La cantidad por empaque no se registra en el maestro de producto terminado.
Los antiguos campos «unidades por paquete» y «unidades por bulto» no forman
parte del flujo operativo del piloto. Para mangas, pesaje y almacenamiento, la
fuente de verdad es la combinación aprobada de tipo de contenedor, perfil
empacable y regla de empaque.

La planificación usa la regla aprobada para determinar la capacidad efectiva,
el número de mangas y la última manga parcial. Las preetiquetas y mangas
conservan una copia de la regla utilizada. Durante el pesaje, el peso controla
tolerancias y límites, pero nunca se utiliza para inferir las unidades mediante
una división.

Los tres límites de unidades cumplen funciones distintas. La **cantidad
operativa objetivo** es la carga recomendada para trabajar normalmente. El
**máximo físico por acomodo** es el techo comprobado por geometría, volumen,
anidamiento y manipulación. El **límite neto operativo** se combina con el peso
unitario congelado del artículo para obtener el techo por peso. La capacidad
efectiva es el menor de esos tres límites y nunca se deduce solamente de los kg.

La **tolerancia de tara** se suma a la tara nominal para calcular de manera
conservadora la capacidad disponible. Si la tara nominal es `120 g` y la
tolerancia es `10 g`, la planificación reserva `130 g` antes de aplicar el
margen de seguridad. En el pesaje normal se usa la tara nominal congelada; una
tara real distinta requiere autorización, actor y motivo. La tolerancia no
habilita por sí sola la digitación libre de otra tara.

Para utilizar un artículo en la planificación de mangas:

1. crear o reutilizar el perfil que represente su acomodo real;
2. crear el tipo de manga con valores físicos verificados;
3. asociar al artículo un único perfil predeterminado activo;
4. crear la regla entre perfil y manga con evidencia física;
5. publicar la regla antes de planificar la OP u OT.

## Prearmado y armado

Al crear una OT diaria de Armado, seleccione **En mesa de armado** o
**Concurrente con fabricación**. Use la segunda opción únicamente cuando el
prearmado se realice durante la fabricación; deberá vincular una OT de
Fabricación activa de la misma fecha. Después asigne centro, responsable,
turno y cuota.

La modalidad no cambia la BOM ni el artículo producido. Para una regadera, el
prearmado de cuerpo y asa puede producir un WIP; el armado posterior consume
ese WIP junto con pico y tapa para producir el PT. La OT vinculada aporta
contexto, pero el peso del asa no se acredita como producción de la máquina.

## Cómo configurar una ruta

La BOM define los componentes y cantidades de una salida. La ruta no repite
esa composición: define **en qué orden**, **en qué centro** y **mediante qué
documento** se realiza cada transformación.

- **Fabricación mediante OF y Trabajo de color:** utilícela para trabajo de
  máquina que produce una PiezaColor. La OF autoriza la cantidad y el Trabajo
  de color identifica el color y su configuración técnica dentro de la OT de
  máquina. No se elige una estructura paralela en la operación.
- **Prearmado o armado mediante OA / OT de Armado:** utilícela para producir
  WIP o PT. Debe seleccionar la estructura aprobada que produzca exactamente
  el artículo declarado como salida.
- **Centro de trabajo:** indica el recurso predeterminado. La OT diaria puede
  escoger otro centro compatible cuando la modalidad operativa lo requiera.
- **Permite ejecución concurrente:** habilítelo solamente en una operación
  `PREARMADO` que pueda realizarse junto a Fabricación.

Las operaciones se encadenan en el orden visible. La última debe producir el
PT objetivo; una salida intermedia debe ser WIP. Para la regadera se configura
una sola ruta:

1. `PREARMAR_CUERPO_ASA`: centro Prearmado en Máquina, salida `WIP-000001`,
   estructura WIP revisión 2 y concurrencia permitida.
2. `ARMAR_REGADERA`: centro Mesa de armado, salida `PT-000001`, estructura
   PT revisión 5, sin concurrencia.

No cree dos rutas alternativas para decidir entre mesa y concurrencia. Esa
decisión se toma posteriormente al crear cada OT diaria de Armado.

## Corrección y anulación

Un error no se resuelve eliminando el pesaje o la manga:

1. localizar la manga;
2. comprobar si ingresó a Almacén;
3. ejecutar primero la reversa de recepción cuando corresponda;
4. solicitar corrección, reemplazo o anulación;
5. aprobar con un actor autorizado;
6. comprobar invalidación de QR, estado de manga y devolución del cupo al mismo
   Trabajo de color para crear una manga normal de reemplazo.

Si la manga ya ingresó a Almacén, la anulación exige primero la reversa de
recepción. La eliminación directa permanece bloqueada para todos los perfiles.

## Mantenimiento

La guía y la autorización del backend deben conservar el mismo significado.
Cuando cambien una capacidad, estado, ruta o procedimiento se actualizan juntos:

- el código;
- la prueba automática;
- la sección visible en /guia/scm;
- esta referencia del vault;
- la UAT relacionada.

La matriz detallada se mantiene en [[Guia_Roles_y_Permisos_SCM_Piloto]].
