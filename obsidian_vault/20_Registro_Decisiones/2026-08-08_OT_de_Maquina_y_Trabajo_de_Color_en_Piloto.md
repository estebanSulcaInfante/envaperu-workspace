---
tipo: decision-arquitectura
estado: aceptada
fecha_decision: 2026-08-08
fecha_actualizacion: 2026-08-08
tags: [scm, mom, isa95, piloto, ot, trabajo-color, manga, pesaje]
relaciones:
  - "[[Refactor_OT_y_Trabajo_de_Color_alineado_ISA95]]"
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[Registro_Diario]]"
  - "[[Orden_Fabricacion]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
  - "[[US-010L_Material_Segunda_Reproceso_y_Mezcla_Preparada_Trazable]]"
  - "[[Alcance_Nuevo_Piloto_SCM_2026-08]]"
---

# OT de máquina y Trabajo de color incluidos en el piloto

## Contexto

La planta usa **OT** como el documento de la máquina durante una fecha y turno,
pero la implementación vigente hace que cada OT pertenezca directamente a una
sola OF, corrida y color. Una máquina que cambia varias veces de color genera
muchas OT visibles, aunque para Planta continúe siendo una sola jornada de
máquina.

El piloto necesita conservar la nomenclatura conocida sin perder la atomicidad
de la ejecución, el cupo de mangas, el pesaje ni la trazabilidad por corrida.
El análisis se registró en
[[Refactor_OT_y_Trabajo_de_Color_alineado_ISA95]].

## Decisión

### 1. OT como envolvente de despacho

La OT de Fabricación identifica una combinación de:

- máquina o centro exactos;
- fecha operativa;
- turno;
- tipo de proceso;
- cola ordenada de trabajos;
- estado y métricas agregadas.

Para el flujo normal existe una OT canónica por esa combinación. Puede contener
trabajos de distintas OF, corridas, colores o moldes siempre que sean
compatibles con la máquina y el proceso. La OT no conserva como datos
autoritativos una OF, corrida, color, receta, cuota o contador concretos.

La unicidad por máquina/fecha/turno/proceso se aplica a las **cabeceras nuevas
normalizadas**, sin `orden_id`, OF o corrida directos. Varias OT monocolor
legacy que compartan esa combinación permanecen válidas, consultables y
adaptadas; no bloquean el upgrade ni se fusionan.

El nombre canónico de dominio es **OT**. Durante `expand/backfill/cutover`, la
cabecera física continúa en `RegistroDiarioProduccion`; no se crea una tabla
paralela `scm_orden_trabajo`. Conservar el nombre físico legacy es una decisión
de compatibilidad y no cambia la semántica del agregado.

### 2. Trabajo de color como unidad atómica

El **Trabajo de color** es la unidad ejecutable y trazable de Fabricación.
Referencia exactamente:

- una OF liberada;
- una corrida perteneciente a esa OF;
- una máquina mediante su OT;
- una cuota y salidas exactas;
- snapshots técnicos, secuencia, estados, tiempos y resultados propios.

`Trabajo de color` es el término visible de Planta. Internamente puede
implementarse como `TrabajoOT` especializado, pero este incremento solo habilita
Fabricación. Las OT de Armado continúan mediante el adaptador actual y no se
crea todavía `TrabajoArmado`.

### 3. Exclusividad y cambios de contexto

Solo un Trabajo de color puede estar `EN_EJECUCION` en una misma máquina e
instante. Una parada sin cambiar el contexto pausa y reanuda el mismo trabajo.
Cambiar de corrida, receta, molde, máquina o límite de Calidad crea otro.

En una secuencia A → B → A, el primer trabajo A se puede reanudar únicamente si
conserva la misma corrida, receta, molde y límite de Calidad. En otro caso se
crea un trabajo continuación. El cambio registra tiempo de preparación,
limpieza o purga, motivo y merma asociada cuando exista.

### 4. Mangas y pesaje

Toda manga de Fabricación referencia un Trabajo de color y una salida exacta.
El cupo, condición `NORMAL` o `EXTRA`, QR, etiqueta, pesaje, corrección,
anulación, recepción y genealogía se atribuyen al trabajo. La OT solo proyecta
sus totales.

La identidad estable de manga y las versiones de etiqueta permanecen
separadas. `ANULAR_PESAJE` devuelve el cupo al Trabajo de color; si la manga ya
fue recibida exige primero la reversa de recepción. La eliminación directa
permanece bloqueada para todos los perfiles.

### 5. Personas y relevos del piloto

El trabajador no forma parte de la identidad de la OT ni del Trabajo de color.
Un relevo compatible dentro de la misma OT crea una asignación auditada por
intervalo y no otro trabajo. El responsable productivo vigente y el actor real
del pesaje son datos distintos.

Una manga no iniciada puede reasignarse. Una preetiqueta emitida requiere
transferencia auditada y reemplazo si imprime al responsable anterior. Una
manga abierta transferida dentro de la misma OT requiere motivo y conteo de
frontera si se pretende atribuir unidades exactas a cada trabajador.

### 6. Fronteras explícitas

Este incremento **no** incluye:

- continuidad de una manga hacia otra OT o fecha;
- `TramoMangaTrabajoColor`;
- pesaje o control intermedio de una manga abierta;
- lote de material preparado almacenable;
- materia de segunda con generaciones `R1…Rn`;
- formulación experimental ni otra integración de balanza;
- migración de Armado a `TrabajoArmado`.

La primera frontera continúa en
[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color|US-010K]] y la
segunda en
[[US-010L_Material_Segunda_Reproceso_y_Mezcla_Preparada_Trazable|US-010L]].
US-010B puede atribuir al Trabajo de color la reserva, emisión y consumo ya
existentes de una receta aprobada sin introducir material preparado.

## Migración

Se adopta `expand → backfill → cutover → contract`:

1. conservar `RegistroDiarioProduccion` como cabecera OT y agregar hijos/FK sin
   retirar las columnas vigentes;
2. crear exactamente un Trabajo de color por cada OT monocolor existente;
3. copiar OF, corrida, snapshots, cuotas y contadores al trabajo;
4. enlazar mangas, asignaciones, solicitudes extra y pesajes;
5. preservar UUID, códigos OT/manga, QR, etiquetas, pesajes y `payload_json`;
6. cambiar lecturas y escrituras al nuevo agregado;
7. retirar las columnas duplicadas de OT en una migración posterior.

No se consolidan retrospectivamente varias OT históricas en una sola OT. Si
coinciden máquina, fecha y turno, cada una recibe su propio trabajo hijo y queda
fuera de la unicidad reservada para cabeceras normalizadas nuevas.

## Decisiones sustituidas parcialmente

- En [[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]], queda sustituida la
  regla `OT de Fabricación = una corrida/color`.
- En [[2026-07-30_OT_Diaria_Comun_para_Fabricacion_y_Armado]], queda sustituida
  la cardinalidad que obliga a cada OT de Fabricación a ejecutar una única OF o
  corrida. La parte de Armado permanece vigente como adaptador.
- La autoridad central de identidad, la fecha operativa, la identidad estable
  de manga dentro del QR y la recepción posterior al pesaje permanecen
  vigentes. Una versión reemplazada de etiqueta invalida su QR anterior.

## Consecuencias

- Planta conserva una sola OT visible por máquina y turno.
- La cola de colores no pierde trazabilidad por OF, corrida o salida.
- El maquinista continúa escaneando únicamente el QR de su manga en el flujo
  normal.
- Los estados y totales de OT dejan de ser otra fuente editable.
- US-010C/D requieren adaptación y nueva regresión antes de continuar su UAT.
- El piloto no puede declararse listo mientras M1, M2 y M3 no tengan pruebas
  automatizadas y UAT física aprobadas.
