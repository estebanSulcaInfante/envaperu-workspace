---
tipo: user-story
subtipo: historia-hija
estado: en-refinamiento
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, materiales, segunda, reproceso, generaciones, mezcla-preparada, color, genealogia, trabajo-color, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[US-010E_Molienda_y_Material_Recuperado_Trazable]]"
  - "[[Refactor_OT_y_Trabajo_de_Color_alineado_ISA95]]"
  - "[[Orden_Fabricacion]]"
  - "[[Lote_Material_Recuperado]]"
  - "[[Regla_Compatibilidad_Reproceso]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# US-010L: Material de segunda, generación de reproceso y mezcla preparada trazable

## 1. Contexto operativo validado

EnvaPerú compra materia prima de segunda que ya viene coloreada. Actualmente el
proveedor la entrega como material de **reproceso 1** y la empresa no compra
generaciones posteriores. El material recuperado dentro de la planta sí puede
volver a reciclarse varias veces, por lo que debe distinguirse `R1`, `R2`, …,
`Rn` sin crear un maestro de material distinto por cada generación.

También se combinan materias primas de segunda para buscar un color. Al comenzar
la prueba no siempre existe una receta aprobada: Producción agrega material,
observa el resultado y ajusta la mezcla. La ausencia de receta inicial no debe
convertirse en ausencia de trazabilidad; cada aporte real debe quedar medido y
registrado.

La mezcla resultante puede prepararse antes de conocer la máquina o el trabajo
exacto que la consumirá. Debe poder almacenarse como un lote de material
preparado de color, permanecer disponible o reservado y abastecer después un
[[Refactor_OT_y_Trabajo_de_Color_alineado_ISA95|Trabajo de color]] compatible.

## 2. Resultado de la auditoría actual

| Necesidad | Estado al 2026-08-08 | Evidencia o brecha |
|---|---|---|
| Recibir segunda comprada por bolsas/lotes | Parcialmente cubierta | US-010A y la modalidad `SEGUNDA_PESAJE_BOLSA` conservan peso y procedencia. |
| Diferenciar segunda externa de recuperado interno | Parcialmente cubierta | US-010A y US-010E separan recepción y molienda, pero no normalizan una generación común. |
| Registrar que el lote comprado ya tiene color | No cubierta | El color no forma parte de la identidad/calidad del lote de segunda recibido. |
| Registrar `R1…Rn` | No cubierta | US-010E menciona “número de reprocesos conocido”, pero el modelo y los servicios no lo almacenan ni lo derivan. |
| Mezclar generaciones diferentes sin perder detalle | No cubierta | El lote recuperado conserva composición de orígenes, pero no composición por generación. |
| Volver a reprocesar un lote recuperado | No cubierta | La molienda implementada consume lotes de merma; el lote recuperado no puede entrar recursivamente como otro insumo trazado. |
| Reservar material recuperado liberado | No cubierta extremo a extremo | Liberar `ScmLoteMaterialRecuperado` no acredita un saldo reservable por US-010B. |
| Preparar material con receta aprobada para una corrida | Cubierta localmente, pendiente UAT | `ScmLotePremezcla` consume emisiones de US-010B y valida proporciones de la receta aprobada. |
| Preparar mediante prueba sin receta inicial | No cubierta | El servicio vigente exige componentes y proporciones de una receta aprobada. |
| Conservar los aportes reales de cada prueba | No cubierta | No existe bitácora de adiciones experimentales ni resultado observado por etapa. |
| Almacenar mezcla preparada como inventario reutilizable | Parcial en concepto; no cubierta operativamente | La premezcla actual queda ligada obligatoriamente a una corrida, usa una ubicación textual y solo admite `DISPONIBLE_MAQUINA`, `CONSUMIDO_MAQUINA` o `ANULADO`. |
| Mover, recibir y consumir la mezcla preparada en máquina | No cubierta | No existe saldo propio, Kardex, ubicación normalizada ni confirmación real de consumo del lote preparado. |
| Reservar posteriormente el lote para un Trabajo de color | No cubierta | El Trabajo de color y el vínculo de reserva todavía pertenecen al refactor. |
| Capturar pesajes reales de cada aporte | No cubierta | La confirmación vigente consume automáticamente todo lo emitido disponible; no registra bruto, tara, neto, dispositivo ni desviación por aporte. |
| Escuchar otra balanza o varios rangos | No cubierta | La estación actual configura un solo `SCALE_PORT` por proceso y su lector interpreta el número como kg; no distingue simultáneamente una balanza de bultos y otra de dosificación fina. |

Por lo tanto, esta US **no está implementada**. Reutiliza bases de US-010A/B/E,
pero introduce comportamiento y datos nuevos.

## 3. Historia de usuario

**Como** responsable de Preparación de Materiales o Producción  
**Quiero** recibir o generar material de segunda con color y generación de
reproceso conocidas, preparar mezclas por receta o por prueba y almacenarlas
como lotes trazables  
**Para** abastecer las máquinas sin perder procedencia, composición real,
calidad, saldo ni cantidad de veces que el material fue reprocesado.

## 4. Lenguaje de dominio

### 4.1. Lote de material de segunda comprado

Lote externo recibido desde un proveedor. Conserva como mínimo:

- material, familia de polímero y grado declarado;
- proveedor, documento y bolsas físicas;
- color declarado por proveedor;
- color observado o resultado de Calidad, cuando exista;
- generación declarada;
- fuente de la declaración y evidencia;
- peso y saldo por lote o bolsa;
- condición y estado de liberación.

La política inicial de compra permite únicamente `R1`, pero el sistema no debe
hardcodear que todo lote externo es R1. Cuando falte respaldo se registra
`DESCONOCIDA`; no se inventa una generación para permitir su uso.

### 4.2. Generación de reproceso

La generación indica cuántas transformaciones de reciclaje atravesó el
material. Es un atributo genealógico del lote, no parte del nombre del maestro
de material.

`Rn` es una clasificación operativa interna de EnvaPerú. No demuestra por sí
sola calidad, aptitud para contacto con alimentos ni un porcentaje ambiental
de contenido reciclado. Adquisición (`COMPRADO`, `INTERNO`, `APERTURA`),
procedencia física, base de información (`MEDIDA`, `DECLARADA_PROVEEDOR`,
`ESTIMADA`, `DESCONOCIDA`) y decisión de Calidad se conservan por separado.

- merma de origen virgen que se muele por primera vez produce componente `R1`;
- un componente `Rn` que vuelve a reprocesarse se transforma en `R(n+1)`;
- recibir material externo no incrementa su generación: conserva la declarada;
- mezclar materiales sin molerlos conserva las generaciones de cada aporte;
- volver a reprocesar esa mezcla incrementa en uno cada componente conocido.

La distribución generacional se calcula sobre la masa de polímero. Pigmentos,
masterbatch y aditivos conservan su propia genealogía, pero no se etiquetan
artificialmente como R1/R2 ni alteran el denominador del polímero.

Una mezcla puede contener más de una generación. Debe conservar una
distribución cuantificada, por ejemplo:

```text
Entrada a molienda: 10 kg R1 + 5 kg R2
Salida genealógica: 10 kg R2 + 5 kg R3
Rango: R2–R3
Grado operativo conservador: R3
```

El `grado operativo` sirve para reglas y alertas, pero no sustituye ni borra la
distribución real. Si parte de la genealogía es desconocida, el lote conserva
esa fracción como `DESCONOCIDA`.

### 4.3. Lote de material preparado

Resultado físico de mezclar uno o más lotes de material antes de alimentar una
máquina. Es inventario trazable y puede existir antes de una corrida o Trabajo
de color concretos.

No es lo mismo que:

- una receta, que expresa lo planificado;
- una reserva, que compromete saldo para un destino;
- una emisión, que mueve material hacia Preparación;
- una corrida, que define el contexto técnico de fabricación;
- un Trabajo de color, que despacha y ejecuta ese contexto en una máquina.

### 4.4. Formulación experimental

Secuencia auditada de adiciones reales cuando no existe receta aprobada al
inicio. Cada paso registra lote, kg, actor, fecha, propósito y observación.

`Sin receta inicial` nunca significa `sin composición`. La formulación real
queda determinada por los aportes medidos. Si el resultado funciona, puede
proponerse como borrador de receta, pero requiere el flujo normal de revisión y
aprobación; no se publica automáticamente.

### 4.5. Alineación de referencia

El modelo separa definición de material, lote físico, transformación,
unidad logística y decisión de Calidad. La genealogía de mezcla es N:M y
cuantificada; no se resuelve con un único `parent_lot_id`.

Esta separación coincide conceptualmente con el modelo de materiales de
[ISA-95](https://reference.opcfoundation.org/ISA-95/v100/docs/8.4.1) y con el
`TransformationEvent` de
[GS1 EPCIS 2.0.1](https://ref.gs1.org/standards/epcis/2.0.1/). Es una guía de
diseño y no una declaración de certificación.

### 4.6. Identidades de la ejecución de preparación

```text
PreparaciónMezcla
├── Iteración 1
│   ├── Incorporación real A
│   └── Incorporación real B
├── Iteración 2 · ajuste por observación
│   └── Incorporación real C
└── LoteMaterialPreparado resultante
```

- `PreparaciónMezcla` es la sesión gobernada, normal o experimental;
- `Iteración` conserva por qué se hizo cada ajuste y su resultado observado;
- `Incorporación` es el único hecho que vuelve no separable una cantidad de
  material y consume el input;
- `LoteMaterialPreparado` es la salida física almacenada o emitida a máquina.

Reserva y emisión no prueban incorporación. El sistema debe etiquetar las
cantidades visibles como `TEÓRICA`, `COMPROMISO`, `DECLARADA`, `MEDIDA` o
`DERIVADA`, según su verdadera autoridad.

## 5. Invariantes de negocio

1. `R1`, `R2` y `Rn` no se crean como materiales o SKU independientes.
2. Ningún cambio manual puede reducir la generación histórica de un lote.
3. Toda molienda incrementa en uno la generación de cada fracción conocida.
4. Mezclar en seco, dividir, almacenar, reservar, trasladar o emitir no
   incrementa generación.
5. Toda mezcla conserva composición por lote, kg, porcentaje y generación.
6. El máximo de generación no reemplaza la distribución genealógica.
7. La generación externa se declara con fuente; `DESCONOCIDA` no equivale a
   `R1`.
8. Color declarado, color objetivo y color observado son datos diferentes.
9. Coincidir en el nombre de color no demuestra compatibilidad de polímero,
   proceso, generación o Calidad.
10. Una preparación experimental puede no tener receta planificada, pero nunca
   puede carecer de aportes reales trazados.
11. Las adiciones experimentales son append-only. Una corrección invalida o
    compensa; no borra el hecho original.
12. Mezclar consume o transforma los saldos de entrada. El material ya mezclado
    no vuelve administrativamente a sus lotes originales.
13. El lote preparado tiene saldo físico, reservado y disponible por ubicación;
    una cadena textual de ubicación no sustituye el inventario.
14. Preparar no consume todavía en fabricación. El consumo ocurre contra el
    Trabajo de color que recibe material en máquina.
15. Un lote preparado puede reservarse parcialmente; el remanente continúa
    identificado y disponible si Calidad lo permite.
16. Una cancelación del destino libera la reserva, pero no anula ni desmezcla el
    lote preparado.
17. No se permite saldo negativo, doble consumo, doble liberación ni ciclos de
    genealogía.
18. Toda excepción de compatibilidad, generación o Calidad exige capacidad,
    motivo y auditoría independientes.
19. Un valor Rn nunca libera material por sí mismo; Calidad y uso permitido son
    decisiones independientes.
20. Lote de contenido y bolsa/unidad logística son identidades distintas: un
    lote puede dividirse en varias bolsas sin cambiar composición ni Rn.

## 6. Flujos

### 6.1. Recepción de segunda comprada ya coloreada

1. Compras/Almacén registra proveedor, documento y material.
2. Declara color y generación respaldados por el proveedor.
3. Se pesan las bolsas según US-010A y nacen sus identidades físicas.
4. Calidad confirma, corrige como observación o marca desconocidos sin borrar la
   declaración original.
5. El lote queda bloqueado o disponible según la política de liberación.

### 6.2. Preparación por receta aprobada

1. Se selecciona una receta vigente y sus cantidades planificadas.
2. Se reservan y emiten lotes concretos.
3. Preparación registra los aportes reales y diferencias.
4. Se confirma el lote preparado, su balance, color y composición generacional.
5. El lote puede reservarse para el Trabajo de color previsto o almacenarse.

### 6.3. Preparación experimental sin receta inicial

1. Producción abre una preparación con color objetivo, familia de material y
   motivo de prueba.
2. Agrega un lote de segunda y registra kg reales.
3. Observa el resultado y agrega sucesivos aportes mediante eventos separados.
4. El sistema recalcula composición, generaciones y balance sin fingir una
   receta previamente aprobada.
5. Calidad registra el color observado y decide liberar, bloquear o pedir otro
   ajuste.
6. Al liberar, nace o se habilita el saldo almacenado del lote preparado.
7. Opcionalmente se genera una propuesta de receta en borrador a partir de la
   composición real aprobada.

### 6.4. Abastecimiento a un Trabajo de color

1. Planificación selecciona un lote preparado compatible y disponible.
2. Reserva una cantidad para un Trabajo de color exacto.
3. Almacén/Preparación entrega una cantidad identificada a la máquina.
4. El Trabajo de color conserva snapshot del lote, formulación real,
   generaciones y estado de Calidad.
5. La confirmación de consumo debita lo realmente utilizado; una devolución
   identificada recupera solo el remanente físicamente separable.

### 6.5. Autoridad de cantidad durante la preparación

Preparación conserva cuatro cantidades diferentes:

| Cantidad | Significado |
|---|---|
| `objetivo_kg` | Lo que la receta, prueba o siguiente ajuste autoriza incorporar. |
| `emitido_kg` | Lo trasladado físicamente a Preparación y todavía separable. |
| `incorporado_real_kg` | Neto efectivamente vertido y ya no separable, respaldado por medición. |
| `salida_preparada_real_kg` | Neto de las bolsas/tolva de mezcla resultante. |

La desviación se calcula y conserva; ninguna capa sobrescribe a la anterior.

Cada aporte físico debe obtener un neto real mediante uno de estos métodos:

1. `PESO_DIRECTO_TARADO`: pesar recipiente, aplicar tara y capturar el neto;
2. `DIFERENCIA_ENVASE_ORIGEN`: pesar el lote fuente antes y después de verter;
3. `UNIDAD_COMPLETA_VERIFICADA`: incorporar una bolsa cerrada completa cuyo
   peso neto vigente fue medido y cuya identidad se escanea;
4. `CONTINGENCIA_MANUAL`: solo ante falla documentada, con evidencia y segunda
   confirmación; nunca como operación normal.

La lectura conserva valor bruto, tara, neto, unidad original, estado estable,
estación, dispositivo, momento, actor e idempotencia. Si se usa una fracción de
bolsa, el sistema no permite confirmar únicamente “media bolsa” ni copiar la
cantidad planificada.

Capturar un peso demuestra una medición; no demuestra todavía que el material
entró a la mezcla. Cuando la balanza está lejos de Preparación, la captura
materializa una `UnidadDosificada` identificada y transportable. Solo el evento
posterior `APORTE_INCORPORADO` consume esa unidad y aumenta la composición de
la preparación. Si la balanza está junto al recipiente de mezcla, captura e
incorporación pueden confirmarse atómicamente.

En formulación experimental, cada iteración posee un objetivo o máximo
autorizado y una o varias lecturas reales. El sistema muestra acumulado y
desviación después de cada aporte. No es necesario pesar toda la mezcla entre
cada ajuste, pero sí medir todo material que entra.

Al cerrar un lote que será almacenado se pesan sus unidades logísticas de
salida. El balance es:

```text
Σ netos incorporados
  = neto lote preparado
  + pérdida o derrame
  + muestra de Calidad
  + remanente identificado en equipo
```

Una diferencia fuera de tolerancia bloquea la liberación normal o exige
conciliación autorizada. El peso final nunca se usa para reconstruir
retroactivamente cuánto aportó cada lote.

### 6.6. Estación y dispositivos de pesaje

El backend central no debe abrir puertos seriales de planta. Una estación local
captura la lectura estable y envía un evento idempotente. El modelo objetivo
admite una estación con uno o más dispositivos:

```text
Estación PREPARACION-01
├── Balanza de material a granel
└── Balanza de dosificación fina
```

Cada dispositivo declara uso permitido, unidad, capacidad máxima, capacidad
mínima, división/resolución, protocolo, vigencia de verificación y estado. Una
balanza solo puede confirmar un aporte si su rango y resolución son aptos para
la cantidad y tolerancia del componente. La capacidad mínima importa porque
pesar cargas ligeras en una balanza grande aumenta el error relativo, como
explica [OIML R 76](https://www.oiml.org/en/files/pdf_r/r076-1-e92.pdf/%40%40download/file/R076-1-e92.pdf).

Para el piloto se admiten dos topologías, sujetas a validar capacidad y flujo:

1. **Balanza central compartida:** resolver QR de preparación, lote y recipiente;
   capturar una dosis estable; crear su unidad/QR; trasladarla; y escanear su
   incorporación en Preparación. Se serializa la cola y nunca se usa el último
   peso global sin contexto.
2. **Estación junto a Preparación:** resolver preparación y lote, capturar peso
   e incorporación como una sola operación física. Es la opción de menor carga
   lógica cuando la ubicación y el proceso la permiten.

Para ingredientes pequeños se recomienda una balanza de dosificación fina que
genere kits o dosis con QR. Para resina, recuperado y blend a granel se utiliza
una balanza de plataforma/tolva compatible. No se propone una balanza por cada
una de las 13 máquinas; se propone separar el rango fino del rango a granel.

Una estación separada no implica otro SCM: es otro origen de mediciones dentro
del mismo sistema central. La aplicación local vigente escucha una sola balanza
por proceso, por lo que dos dispositivos simultáneos requieren ampliar el
contrato estación-dispositivo o desplegar estaciones independientes; no se
resuelve reutilizando silenciosamente el último peso global.

## 7. Estados mínimos propuestos

### Lote preparado

`EN_PREPARACION -> PENDIENTE_CALIDAD -> DISPONIBLE`

Laterales: `EN_AJUSTE`, `RESERVADO_PARCIAL`, `RESERVADO_TOTAL`,
`BLOQUEADO`, `AGOTADO`, `ANULADO`.

Los estados de reserva pueden derivarse de saldos; no deben duplicar una verdad
editable si la Tech Spec adopta esa proyección.

### Formulación experimental

`BORRADOR -> EN_PRUEBA -> PENDIENTE_EVALUACION -> CERRADA`

Laterales: `REQUIERE_AJUSTE`, `RECHAZADA`, `ANULADA`.

## 8. Relación con OT y Trabajo de color

Esta historia se incorpora como dependencia del refactor:

```text
Materiales/lotes de entrada
        ↓
Preparación y lote de material preparado
        ↓ reserva/emisión
Trabajo de color (contexto homogéneo de corrida/color/receta real)
        ↓
Mangas, pesajes, merma y resultado
```

- la OT de máquina/turno no es propietaria de la receta ni del lote preparado;
- el requerimiento bruto se calcula una sola vez en la corrida y se asigna por
  cuotas a sus Trabajos de color; dividir la ejecución no duplica materiales;
- el Trabajo de color recibe la reserva y el consumo;
- cambiar de Trabajo de color no convierte automáticamente el remanente en
  compatible con el siguiente;
- un lote preparado puede existir antes de la OT y después de cancelar una OT;
- una ejecución experimental debe congelar la formulación real usada, aunque
  todavía no exista una receta maestra aprobada;
- el consumo de segunda coloreada puede reducir o eliminar dosificación nueva de
  colorante, pero esa decisión debe provenir de la formulación real o aprobada,
  no solo del nombre del color.

## 9. Datos mínimos

### Por lote de segunda o recuperado

- origen `EXTERNO` o `INTERNO`;
- material/familia/grado;
- lote, bolsas y proveedor/origen;
- color declarado y observado;
- generación declarada/derivada;
- fuente y estado de conocimiento;
- distribución por generación;
- cantidad, ubicación, Calidad y genealogía.

### Por lote preparado

- código e identidad estable;
- tipo de formulación `RECETA_APROBADA` o `EXPERIMENTAL`;
- receta/revisión opcional;
- color objetivo, declarado y observado;
- familia y restricciones de compatibilidad;
- aportes reales cuantificados;
- distribución de generaciones y grado operativo;
- kg físicos, reservados y disponibles;
- ubicación y unidades logísticas;
- estado de Calidad;
- destino previsto opcional y reservas reales;
- actores, tiempos, motivo y versión.

### Por aporte y medición

- preparación, paso e intento;
- lote/unidad logística fuente;
- cantidad objetivo o máximo autorizado;
- método de determinación;
- bruto, tara, neto y unidad originales;
- estación y dispositivo;
- lectura estable, fecha y actor;
- cantidad acumulada y desviación;
- estado vigente o evento de invalidación/compensación;
- unidad dosificada y estado de traslado/incorporación, cuando la medición se
  realiza lejos de Preparación;
- clave idempotente y evidencia de contingencia, cuando aplique.

## 10. Capacidades mínimas

- `MATERIAL_SEGUNDA_RECIBIR`
- `MATERIAL_GENERACION_DECLARAR`
- `MATERIAL_GENERACION_CORREGIR`
- `MATERIAL_PREPARACION_CREAR`
- `MATERIAL_PREPARACION_APORTE_REGISTRAR`
- `MATERIAL_PREPARACION_PESAJE_CAPTURAR`
- `MATERIAL_PREPARACION_PESAJE_INVALIDAR`
- `MATERIAL_PREPARACION_CERRAR`
- `MATERIAL_PREPARACION_CALIDAD_LIBERAR`
- `MATERIAL_PREPARADO_RESERVAR`
- `MATERIAL_PREPARADO_EMITIR`
- `MATERIAL_PREPARADO_DEVOLVER`
- `MATERIAL_REPROCESO_EXCEPCION_APROBAR`
- `MATERIAL_GENEALOGIA_CONSULTAR`

Los roles concretos se asignan por capacidades. La persona que ejecuta una
preparación no debe aprobar su propia excepción o liberación cuando la política
de segregación esté activa.

## 11. Criterios de aceptación

- **MAT2-01:** recibir segunda comprada registra bolsas, color declarado y R1
  con su fuente; no la confunde con material recuperado interno.
- **MAT2-02:** si falta evidencia de generación, el lote queda `DESCONOCIDA` y
  no se convierte silenciosamente en R1.
- **MAT2-03:** moler por primera vez merma de origen virgen produce R1.
- **MAT2-04:** un lote recuperado R1 puede entrar como insumo real de otra
  molienda; se debita y la salida correspondiente queda R2.
- **MAT2-05:** reprocesar 10 kg R1 más 5 kg R2 conserva como salida 10 kg R2 y
  5 kg R3, con rango R2–R3 y grado operativo R3.
- **MAT2-06:** una regla puede bloquear el uso cuando el grado operativo supera
  el máximo admitido, sin borrar la composición.
- **MAT2-07:** una preparación experimental puede abrirse sin receta aprobada,
  pero exige material objetivo, color objetivo, motivo y primer aporte real.
- **MAT2-08:** cada ajuste agrega un evento con lote y kg; no sobrescribe los
  aportes anteriores.
- **MAT2-09:** cerrar la preparación concilia entradas, salida y pérdida dentro
  de tolerancia.
- **MAT2-10:** el color observado puede diferir del objetivo y queda sujeto a
  decisión de Calidad.
- **MAT2-11:** una formulación experimental liberada no se convierte
  automáticamente en receta maestra; solo genera una propuesta en borrador.
- **MAT2-12:** un lote preparado liberado puede almacenarse sin OT, corrida ni
  Trabajo de color asignados.
- **MAT2-13:** una reserva parcial reduce disponibilidad, no el saldo físico, y
  el remanente continúa utilizable.
- **MAT2-14:** consumir desde un Trabajo de color debita una sola vez la cantidad
  real y congela su genealogía.
- **MAT2-15:** cancelar el Trabajo de color libera la reserva no consumida y
  conserva el lote preparado.
- **MAT2-16:** dos materiales con el mismo color visible pero familias
  incompatibles no pueden mezclarse sin regla o excepción.
- **MAT2-17:** después de mezclar no existe una acción que devuelva
  administrativamente los kg a los lotes originales.
- **MAT2-18:** reintentar cualquier confirmación idempotente no duplica aportes,
  saldos, reservas ni consumos.
- **MAT2-19:** una premezcla legacy ligada a una corrida migra a lote preparado
  reservado para su destino original, conservando código, composición y saldo.
- **MAT2-20:** una consulta recorre desde el Trabajo de color hasta todos los
  lotes de segunda/recuperados y desde un lote fuente hasta los trabajos y
  productos impactados.
- **MAT2-21:** liberar material recuperado o preparado acredita exactamente un
  saldo por lote y un movimiento idempotente, elegible para reserva.
- **MAT2-22:** migrar stock ya contado por `APERTURA_INICIAL` reconcilia el lote
  físico contra ese saldo y no crea un segundo inventario.
- **MAT2-23:** una receta que solicita 10.000 kg y recibe 9.850 kg conserva ambos
  valores y una desviación de -0.150 kg; no acredita 10.000 kg.
- **MAT2-24:** cada aporte experimental queda respaldado por peso estable o por
  una unidad completa previamente verificada e identificada.
- **MAT2-25:** incorporar parte de una bolsa exige tara directa o diferencia
  antes/después; no admite fracciones textuales sin peso.
- **MAT2-26:** una balanza cuyo mínimo, máximo o resolución no satisface la
  política del componente bloquea la captura como medición normal.
- **MAT2-27:** cerrar un lote almacenado pesa sus salidas y concilia inputs,
  producto, muestra, remanente y pérdida.
- **MAT2-28:** reintentar una lectura o confirmación con la misma clave no duplica
  el aporte acumulado.
- **MAT2-29:** usar una balanza compartida exige resolver primero el QR/modo de
  Preparación; un peso no puede asociarse accidentalmente a una manga productiva.
- **MAT2-30:** el operario de Preparación normal escanea y pesa; no digita el
  valor leído por la balanza.
- **MAT2-31:** un ajuste experimental no puede superar el máximo autorizado sin
  una nueva decisión auditada del responsable de la prueba.
- **MAT2-32:** la contingencia manual conserva motivo, evidencia y doble
  confirmación y queda distinguida de una lectura conectada.
- **MAT2-33:** capturar peso en una balanza distante no consume el material en
  la mezcla; crea una dosis identificada hasta confirmar su incorporación.
- **MAT2-34:** una dosis pesada y todavía en tránsito no participa en la
  composición del WIP ni permite cerrar la preparación.
- **MAT2-35:** una estación junto al mezclador puede confirmar captura e
  incorporación atómicamente, sin inventar una unidad de tránsito.
- **MAT2-36:** fallo de impresión de la etiqueta de dosis no repite el pesaje ni
  el débito; solo habilita reimpresión de la misma identidad.

## 12. Escenarios ATDD esenciales

### Escenario A: segunda externa R1 ya coloreada

**Dado** un proveedor que declara 25 kg de PP reciclado azul R1  
**Cuando** Almacén recibe y pesa la bolsa  
**Entonces** nace un lote externo con color declarado azul, generación R1,
fuente proveedor y estado pendiente de liberación.

### Escenario B: mezcla experimental sin receta

**Dado** 20 kg de segunda azul R1 y 5 kg de segunda negra R1 compatibles  
**Cuando** Preparación registra ambos aportes para buscar azul oscuro  
**Entonces** el sistema conserva 25 kg de composición real, objetivo azul
oscuro, formulación experimental y generación R1 sin inventar una receta
previa.

### Escenario C: ajuste posterior

**Dado** la mezcla anterior en evaluación  
**Cuando** se agregan 2 kg de otro lote azul R2  
**Entonces** aparece un nuevo paso de ajuste y la composición generacional
queda cuantificada entre R1 y R2.

### Escenario D: almacenamiento antes de planificar

**Dado** un lote preparado liberado de 27 kg  
**Cuando** se ubica en Almacén de material preparado sin una OT creada  
**Entonces** conserva 27 kg disponibles, ubicación y QR, sin corrida ficticia.

### Escenario E: reserva y consumo parcial

**Dado** 27 kg disponibles y un Trabajo de color compatible que requiere 20 kg  
**Cuando** se reservan y consumen 18 kg reales  
**Entonces** quedan 9 kg físicos, de los cuales 2 kg siguen reservados hasta
cerrar o ajustar el destino, sin duplicar consumo.

### Escenario F: incremento de generaciones

**Dado** una molienda que consume 10 kg R1 y 5 kg R2  
**Cuando** se confirma su salida  
**Entonces** la salida conserva 10 kg R2 y 5 kg R3 y las reglas operan sobre
grado máximo R3.

### Escenario G: plan contra incorporación real

**Dado** un aporte objetivo de 10.000 kg de segunda azul R1  
**Cuando** la balanza confirma 9.850 kg netos estables  
**Entonces** Preparación incorpora 9.850 kg, conserva el objetivo y muestra una
desviación de -0.150 kg.

### Escenario H: ajustes experimentales acumulativos

**Dado** una preparación experimental con 20.000 kg ya incorporados  
**Cuando** se pesan sucesivamente 0.500 kg y 0.120 kg de otros lotes  
**Entonces** el acumulado queda en 20.620 kg y cada aporte conserva lote,
dispositivo y lectura; el sistema no reemplaza el primer ajuste con el segundo.

### Escenario I: dispositivo inadecuado

**Dado** un aditivo cuyo objetivo está en gramos y una balanza de bultos cuya
resolución no cumple la tolerancia  
**Cuando** se intenta capturar el aporte  
**Entonces** el sistema bloquea esa balanza y solicita un dispositivo apto o la
contingencia autorizada.

### Escenario J: dosis pesada en balanza central

**Dado** una balanza distante del punto de preparación  
**Cuando** se pesan 0.500 kg para una prueba  
**Entonces** nace una unidad dosificada de 0.500 kg en tránsito y la mezcla aún
no aumenta su composición.

### Escenario K: incorporación posterior

**Cuando** Preparación escanea e incorpora la dosis anterior  
**Entonces** se consume la unidad dosificada y el WIP aumenta 0.500 kg,
conservando la captura, el lote y ambos actores.

### Escenario L: captura directa junto al mezclador

**Dado** una estación habilitada para preparación directa  
**Cuando** captura un peso estable y el operador confirma el vertido  
**Entonces** medición e incorporación se confirman atómicamente sin crear un
tránsito ficticio.

## 13. Correcciones y excepciones

- corregir una generación declarada conserva antes/después, fuente, motivo y
  actor;
- no se permite corregir una generación derivada rompiendo su genealogía;
- un aporte equivocado se compensa antes de cerrar si todavía es físicamente
  separable; después de mezclar requiere reclasificación o conciliación;
- una liberación errónea se revoca para el saldo no consumido; lo ya consumido
  exige análisis de impacto;
- una mezcla fuera de regla permanece bloqueada hasta autorización o
  reclasificación;
- toda cantidad desconocida se mantiene como desconocida, no se reparte por
  conveniencia para cerrar porcentajes.

## 14. Fuera de alcance

- control automático de dosificadores, mezcladoras o molinos;
- inferir color mediante cámara o colorímetro sin integración aprobada;
- cálculo contable del costo de múltiples generaciones;
- decidir límites técnicos de Rn sin validación de Producción/Calidad;
- publicar automáticamente recetas a partir de una prueba;
- considerar que mismo nombre de color implica equivalencia técnica.

## 15. Decisiones pendientes para pasar a Tech Spec

1. Confirmar la definición empresarial de `R1`: primera molienda efectiva del
   material, no número de veces que EnvaPerú lo recibió o usó.
2. Definir evidencia mínima del R1 comprado y tratamiento de proveedor sin
   certificado.
3. Definir generación máxima por familia/proceso y quién puede exceptuarla.
4. Definir quién evalúa el color observado y si se usará catálogo nominal,
   muestra física o instrumento.
5. Definir tolerancia de balance de preparación y tratamiento de pérdidas.
6. Definir envases, QR, ubicaciones y fraccionamiento del lote preparado.
7. Definir si una preparación experimental puede abastecer directamente una
   máquina o exige siempre liberación de Calidad/Jefatura.
8. Definir cuándo una formulación experimental merece proponerse como receta.
9. Levantar para cada balanza disponible ubicación, capacidad mínima/máxima,
   división, unidad, protocolo, verificación y tiempo promedio por captura.
10. Decidir si la balanza productiva puede absorber Preparación sin perjudicar
    la cola de mangas o si se provisionará una estación separada.
11. Definir tolerancia por clase de componente: resina a granel, material
    recuperado, pigmento/masterbatch y aditivo.
12. Confirmar si se pesan directamente recipientes de mezcla o se utilizará
    diferencia antes/después en los envases fuente.
13. Si se reutiliza la balanza central, definir recipiente/QR, custodio y quién
    confirma la incorporación física en Preparación.
14. Confirmar si una misma estación debe escuchar simultáneamente balanza fina
    y de plataforma o si se provisionarán dos estaciones locales.

## 16. Estrategia de implementación

La Tech Spec deberá dividir el desarrollo en incrementos verticales:

1. generación y color por lote externo/interno;
2. derivación Rn y reglas de compatibilidad en molienda;
3. lote preparado almacenable con aportes reales y Calidad;
4. formulación experimental;
5. reserva, emisión y consumo desde Trabajo de color;
6. migración de `ScmLotePremezcla` y pruebas de genealogía extremo a extremo.

La migración debe seguir `expand -> backfill -> cutover -> contract`. Los
históricos sin evidencia quedan `DESCONOCIDA`; nunca se rellenan como R1 por
conveniencia. Antes de acreditar lotes existentes se reconcilian aperturas y
saldos agregados para evitar doble inventario.

No se considera implementada la US por añadir columnas aisladas. El incremento
se acepta cuando un lote real puede recibirse o producirse, prepararse,
almacenarse, reservarse, consumirse y rastrearse con pruebas automáticas.

## 17. Definición de preparada

La historia puede pasar a Tech Spec cuando Planta y Calidad resuelvan los
catorce puntos pendientes, validen los escenarios A–L con materiales reales y
aprueben la relación `Lote preparado -> reserva -> Trabajo de color` del
refactor.
