---
tipo: user-story
subtipo: historia-hija
estado: implementada-piloto-local
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, planificacion, demanda, producto-terminado, orden-produccion, orden-fabricacion, orden-armado, bom, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-007_Normalizar_ProductoTerminado_PiezaColor_Salidas_OP]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[Orden_Produccion]]"
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Operacion]]"
  - "[[Orden_Armado]]"
  - "[[Articulo_SCM]]"
  - "[[Ruta_Produccion]]"
  - "[[Vista_US-010P_Planificacion_Demanda_OP]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-07-31_Generacion_Desde_Una_OP_y_Cobertura_NM]]"
  - "[[Flujo_Plan_Confirmado_Liberacion_Ejecucion]]"
fecha_creacion: 2026-07-15
fecha_actualizacion: 2026-07-31
---

# US-010P: Planificar demanda de ProductoTerminado y generar OP, OF y OA

> [!IMPORTANT] Cambio de lenguaje aprobado
> La OP es el documento de demanda de `ProductoTerminado`. La entidad técnica
> por molde que antes se llamaba OP pasa a [[Orden_Fabricacion|OF]]. Una
> [[Orden_Armado|OA]] gobierna transformaciones posteriores. OP, OF y OA se
> relacionan N:M mediante asignaciones cuantificadas; no forman un árbol rígido.

## 1. Corrección conceptual

El flujo separa cuatro niveles:

1. **Demanda:** qué `ProductoTerminado` y cantidad necesita el negocio.
2. **Cobertura:** qué stock, WIP o suministro entrante puede satisfacerla.
3. **Órdenes ejecutables:** qué fabricación por molde y qué armados faltan.
4. **Despacho de planta:** qué porción de una OF se ejecuta en cada
   [[Registro_Diario|OT]].

La cantidad de PT es la entrada de la OP, pero no se fuerza como salida de una
OF. Una OF puede producir varias `PiezaColor`, WIP o directamente un PT según la
ruta. Una OA puede producir WIP o completar el PT.

Por ello:

- una OP puede no generar órdenes cuando queda cubierta por stock;
- puede generar varias OF y OA;
- una OF/OA puede cubrir varias OP;
- una OF puede existir para reposición de piezas sin inventar un PT;
- un molde multipieza puede generar excedentes inevitables;
- una ruta terminal de fabricación puede producir PT sin crear OA.

## 2. Historia de usuario

**Como** responsable de Planificación o Producción<br>
**Quiero** crear una OP con una o más líneas de `ProductoTerminado`, calcular su
cobertura multinivel y convertir los faltantes en propuestas de OF y OA<br>
**Para** fabricar y armar solamente lo necesario, consolidar campañas
compatibles y mantener trazabilidad desde la demanda hasta la ejecución física.

## 3. Resultado observable

1. El usuario crea una OP con origen, prioridad, fecha y una o más líneas de PT.
2. El sistema congela revisiones de BOM y ruta al aprobar/planificar.
3. La pantalla diferencia necesidad bruta, cobertura, faltante y suministro
   comprometido.
4. El cálculo evita explotar componentes cuando un padre queda cubierto.
5. Los faltantes de molde generan propuestas de OF por compatibilidad técnica.
6. Los faltantes de transformación generan propuestas de OA.
7. Los ciclos propuestos son enteros y muestran todas las salidas/coproductos.
8. Confirmar propuestas crea OF/OA en borrador y asignaciones N:M.
9. Liberar OF habilita US-010B; crear o aprobar OP no reserva materia prima.
10. Puede recorrerse OP → línea → necesidad → asignación → OF/OA → OT →
    mangas/pesajes → resultado.
11. La creación técnica manual queda identificada como `OF excepcional`.
12. La producción directa de PT se representa mediante una OF terminal.

## 4. Límites de responsabilidad

### 4.1. US-010P decide

- demanda y sus líneas;
- revisiones de estructura/ruta usadas para planificar;
- cobertura disponible y comprometida;
- faltantes por nivel;
- propuestas de OF/OA;
- consolidación compatible;
- asignaciones de suministro;
- aprobación de OP;
- creación de OF/OA borrador;
- liberación explícita o entrega al rol autorizado.

### 4.2. La OF conserva

- molde y snapshot de composición;
- corridas por color;
- receta y material;
- ciclos enteros;
- salidas por artículo;
- kg estándar, merma y excedentes;
- parámetros técnicos;
- máquina prevista;
- asignaciones N:M a demanda.

### 4.3. La OA conserva

- operación y ruta;
- artículo WIP/PT resultante;
- BOM y componentes;
- cantidad objetivo;
- modo y ubicación de ejecución;
- asignaciones N:M a demanda.

### 4.4. US-010B comienza

```text
OF liberada
  -> configuración técnica inmutable
  -> generar requerimientos absolutos
  -> proponer lotes de material
  -> confirmar reservas
```

La OP no reserva resina, colorante ni aditivos. Una OA reserva componentes según
US-010F/inventarios, no mediante la preparación de materia prima de inyección.

### 4.5. US-010C comienza

```text
OF liberada + corrida liberada
  -> plan agregado de mangas
  -> programar OT
  -> asignar parte del plan
  -> emitir identidades y etiquetas
```

## 5. Lenguaje de dominio

### 5.1. OrdenProduccion

Cabecera de demanda. Conserva:

- identidad y código `OP-######`;
- origen y referencia;
- fecha de necesidad;
- prioridad;
- estado;
- creador/aprobador;
- líneas y versión de cálculo.

No contiene molde, máquina, color, ciclos o receta.

### 5.2. OrdenProduccionLinea

Solicita un `ProductoTerminado` y cantidad entera positiva. Conserva por
separado:

- solicitado;
- cubierto con PT;
- cubierto por WIP/componentes;
- cubierto por suministro OF/OA;
- satisfecho;
- pendiente;
- revisión de estructura/ruta.

### 5.3. SnapshotEstructuraRutaProducto

Fotografía inmutable de la explosión utilizada:

- artículo resultado/componente;
- cantidad por padre;
- nivel y camino;
- tipo `PIEZA_COLOR`, `SUBENSAMBLE_WIP` o `PRODUCTO_TERMINADO`;
- operación que produce el nodo;
- ejecutor `ORDEN_FABRICACION` u `ORDEN_ENSAMBLE`;
- revisiones y hashes fuente.

Los aliases `OP_OT` y `ORDEN_OPERACION` se aceptan únicamente durante la
migración de rutas.

### 5.4. NecesidadArticulo

Resultado consolidado por artículo/nivel:

- cantidad bruta;
- stock elegible;
- suministro comprometido;
- faltante neto;
- cantidad propuesta;
- excedente esperado;
- estado de calculabilidad.

### 5.5. AsignacionDemandaSuministro

Adjudicación N:M entre línea de OP y suministro:

- PT/WIP/PiezaColor disponible;
- salida esperada de OF;
- salida esperada de OA;
- resultado físico confirmado.

Estados:

- `PLANIFICADA`;
- `COMPROMETIDA`;
- `SATISFECHA`;
- `CANCELADA`.

No mueve inventario y no sustituye consumos. Impide usar dos veces la misma
cantidad para demandas incompatibles.

### 5.6. PropuestaOrdenFabricacion

Resultado recalculable que agrupa:

- molde/revisión compatible;
- corridas por color y receta;
- ciclos enteros;
- salidas y kg estándar;
- demandas cubiertas;
- excedentes y advertencias.

No reserva material ni autoriza ejecución.

### 5.7. PropuestaOrdenArmado

Resultado recalculable para una operación de ruta:

- artículo WIP/PT de salida;
- componentes;
- cantidad;
- BOM/revisión;
- demandas cubiertas;
- dependencias de suministro.

### 5.8. Orden ejecutable excepcional

Una OF/OA sin línea OP puede originarse en reposición, muestra, reproceso o
prueba técnica. Exige:

- origen catalogado;
- motivo;
- actor;
- autorización conforme a capacidad;
- vínculo con el suministro producido.

No se crea una OP ficticia ni un `ProductoTerminado` referencial.

## 6. Invariantes

1. Una OP aprobada posee al menos una línea válida.
2. Cada línea usa un PT activo y cantidad entera positiva.
3. Estructura/ruta cíclica, vacía o inactiva bloquea planificación.
4. Cobertura desconocida no equivale a stock cero.
5. La misma existencia/salida no se compromete dos veces.
6. La cobertura se aplica de arriba hacia abajo.
7. OP no posee un `producto_sku` singular como salida industrial.
8. Una OF no posee una OP padre obligatoria.
9. Cada corrida OF usa un color/receta y ciclos enteros.
10. Las salidas OF provienen del molde/ruta congelados.
11. Una OF/OA borrador no cuenta como suministro confirmado.
12. Liberar una OF requiere configuración técnica completa.
13. Cambiar configuración liberada exige revisión/replanificación auditable.
14. Cancelar libera solo compromisos no ejecutados.
15. Crear OF/OA es idempotente.
16. Una operación de ruta tiene exactamente un ejecutor.
17. Una OF terminal puede acreditar PT.
18. Una salida WIP nunca se presenta como PT.
19. El avance OP se deriva de asignaciones/resultados; no se digita.
20. Calidad e inventario permanecen estados separados.

## 7. Cálculo

### 7.1. Faltante neto

```text
faltante_neto =
    max(
      necesidad_bruta
      - stock_elegible_no_comprometido
      - suministro_comprometido_elegible,
      0
    )
```

Una propuesta o borrador no reduce faltante como suministro confirmado.

### 7.2. Ciclos de molde

Para cada salida limitante:

```text
ciclos_necesarios =
    ceil(faltante_unidades / cavidades_efectivas_snapshot)
```

La propuesta toma el máximo compatible requerido y deriva todas las salidas:

```text
unidades_salida =
    ciclos_propuestos * cavidades_salida_snapshot

kg_estandar_salida =
    unidades_salida * peso_unitario_snapshot_gr / 1000

excedente =
    max(unidades_salida - faltante_asignado, 0)
```

### 7.3. Armado

```text
cantidad_componente =
    cantidad_resultado * cantidad_componente_bom_snapshot
```

La cobertura de WIP/componentes se aplica antes de proponer operaciones
anteriores.

## 8. Flujos

### 8.1. Crear y aprobar OP

1. Crear cabecera.
2. Añadir líneas de PT.
3. Validar maestros.
4. Congelar estructura/ruta.
5. Aprobar OP.

### 8.2. Calcular cobertura

1. Consultar disponibilidad.
2. Aplicar cobertura PT.
3. Explotar cantidad restante.
4. Aplicar cobertura WIP/componentes.
5. Consolidar faltantes.
6. Mostrar fuente y recencia.

### 8.3. Proponer OF/OA

1. Resolver ejecutor por operación.
2. Para molde, resolver `MoldePieza`, color y receta.
3. Calcular ciclos/salidas/excedentes.
4. Para armado, calcular componentes y dependencias.
5. Consolidar órdenes compatibles.
6. Mostrar bloqueos y contingencias.

### 8.4. Confirmar plan

1. Revalidar versiones.
2. Crear OF/OA borrador idempotentemente.
3. Crear asignaciones N:M.
4. No reservar materiales.
5. Registrar evento auditable.

### 8.5. Liberar

1. Validar snapshots y configuración.
2. Autorizar según rol.
3. Congelar revisión.
4. Publicar OF a US-010B/C u OA a US-010F.
5. Registrar liberación idempotente.

## 9. Estados

### 9.1. OP

`BORRADOR -> APROBADA -> PLANIFICADA -> EN_COBERTURA -> COMPLETADA`

`CANCELADA` conserva historia desde estados permitidos.

### 9.2. OF/OA

`BORRADOR -> LIBERADA -> PROGRAMADA -> EN_EJECUCION -> PAUSADA -> EN_EJECUCION -> CERRADA`

`PAUSADA` es un estado agregado: solo se muestra cuando todas las OT o
corridas ejecutables pendientes de la OF/OA están pausadas. Si alguna OT
continúa activa, la OF/OA permanece `EN_EJECUCION`. La pausa no cambia la
configuración liberada, no revierte consumos y no libera reservas
automáticamente.

### 9.3. Pausa de ejecución

La pausa por cambio de prioridad se aplica primero a la OT:

```text
PLANIFICADA -> EMITIDA -> EN_CURSO -> PAUSADA -> EN_CURSO
                                      -> FINALIZADA -> CERRADA
```

La OP no se pausa por una detención de planta. Permanece `APROBADA` o
`PLANIFICADA`; una eventual suspensión de toda la demanda es una decisión de
negocio distinta.

Cada pausa conserva actor, momento, motivo, orden prioritaria relacionada,
estado anterior y política aplicada a las reservas. Las reservas permanecen
retenidas por defecto. Liberarlas requiere descompromiso autorizado y nueva
evaluación de cobertura. Una manga abierta debe pesarse, cerrarse o anularse
antes de abandonar la estación.

`ANULADA` exige motivo y no borra ejecución.

### 9.4. Asignación

`PLANIFICADA -> COMPROMETIDA -> SATISFECHA`

`CANCELADA` libera únicamente el remanente.

## 10. Interfaz

### 10.1. Planificación

Asistente:

```text
Demanda OP
  -> Cobertura
  -> Propuestas OF/OA
  -> Configuración
  -> Liberación
```

Debe mostrar:

- líneas PT;
- cobertura por nivel;
- faltantes;
- propuestas técnicas;
- excedentes;
- relaciones N:M;
- fuente/recencia del inventario.

### 10.2. Producción

- `Órdenes de fabricación`;
- `OF excepcional`;
- detalle/impresión técnica OF;
- programación de OT desde una corrida.

### 10.3. Armado

- `Órdenes de armado`;
- componentes, dependencias y salida;
- ejecución concurrente o dedicada.

### 10.4. Documentos

- OP: demanda, fechas, cobertura y referencias;
- OF: molde, corridas, receta, ciclos y salidas;
- OA: BOM, operación y cantidades;
- OT: jornada, máquina, maquinista y mangas.

## 11. Permisos

Capacidades mínimas:

- `OP_CREAR`;
- `OP_APROBAR`;
- `PLANIFICACION_CALCULAR`;
- `PLANIFICACION_CONFIRMAR`;
- `OF_EXCEPCIONAL_CREAR`;
- `OF_LIBERAR`;
- `OA_LIBERAR`;
- `OT_CREAR`;
- `OT_PAUSAR_PRIORIDAD`;
- `OT_REANUDAR`;
- `OT_DESCOMPROMETER_RESERVA`;
- `OF_ANULAR` / `OA_ANULAR`;
- `PLANIFICACION_OVERRIDE_COBERTURA`.

Planificación crea/aprueba OP; JP libera y autoriza excepciones; supervisor
programa OT. Los roles son configurables y las reglas usan capacidades.

## 12. Compatibilidad y migración

| Actual | Objetivo |
|---|---|
| `SolicitudProduccion` | `OrdenProduccion` |
| `SolicitudProduccionLinea` | `OrdenProduccionLinea` |
| `AsignacionDemandaOP` | `AsignacionDemandaSuministro` |
| `OrdenProduccion` técnica | `OrdenFabricacion` |
| `LoteColor` | `CorridaFabricacion` |
| `OP excepcional` | `OF excepcional` |
| PDF técnico OP | PDF técnico OF |

Las filas/pesajes legacy no se reinterpretan. Los números `OP-*` técnicos
existentes se preservan como alias legacy de OF. Las OF nuevas usan `OF-*`.

US-010C/D ya implementadas localmente se adaptan mediante contrato versionado:
OT y manga referencian `orden_fabricacion_id`/`corrida_id`; los IDs existentes
siguen estables.

## 13. Criterios BDD

### PLN-01: demanda totalmente cubierta

**Dado** una OP aprobada cuya cantidad está disponible y elegible<br>
**Cuando** se calcula cobertura<br>
**Entonces** no se propone OF/OA<br>
**Y** se registra la asignación al stock sin doble compromiso.

### PLN-02: faltante genera varias órdenes

**Dado** un PT que requiere piezas de distintos moldes y un armado<br>
**Cuando** se planifica<br>
**Entonces** se proponen las OF necesarias y una OA<br>
**Y** cada salida queda cuantificada contra la línea OP.

### PLN-03: molde multipieza

**Dado** un molde con varias piezas y cavidades distintas<br>
**Cuando** se calcula la OF<br>
**Entonces** los ciclos son enteros<br>
**Y** se muestran todas las salidas y excedentes.

### PLN-04: consolidación N:M

**Dado** dos OP con faltantes compatibles<br>
**Cuando** Planificación consolida la campaña<br>
**Entonces** una OF puede cubrir ambas<br>
**Y** existen asignaciones separadas sin duplicar cantidades.

### PLN-05: fabricación directa de PT

**Dado** una ruta cuya operación de molde produce el PT final<br>
**Cuando** se planifica<br>
**Entonces** se propone una OF terminal<br>
**Y** no se crea OA ficticia.

### PLN-06: OF para stock

**Dado** una reposición autorizada de `PiezaColor`<br>
**Cuando** se crea una OF excepcional<br>
**Entonces** exige origen, motivo y autorización aplicable<br>
**Y** no crea una OP ni PT referencial.

### PLN-07: cobertura no calculable

**Dado** una fuente de inventario caída o no conciliada<br>
**Cuando** se calcula cobertura<br>
**Entonces** el resultado es `COBERTURA_NO_CALCULABLE`<br>
**Y** no se asume stock cero.

### PLN-08: reintento idempotente

**Dado** un plan confirmado<br>
**Cuando** se repite el mismo comando<br>
**Entonces** devuelve las mismas OP/OF/OA/asignaciones<br>
**Y** no duplica órdenes.

### PLN-09: liberación entrega a materiales

**Dado** una OF completa<br>
**Cuando** JP la libera<br>
**Entonces** se congelan snapshots<br>
**Y** US-010B puede generar requerimientos exactamente una vez.

### PLN-10: trazabilidad completa

**Dado** una línea OP satisfecha<br>
**Cuando** se consulta su genealogía<br>
**Entonces** se recorren asignaciones, OF/OA, OT, mangas, pesajes y resultado.

## 14. Pruebas

- unitarias de explosión, cobertura, ciclos y consolidación;
- integración de OP/OF/OA/asignaciones;
- concurrencia y no doble compromiso;
- contrato versionado para US-010B/C/D/F;
- migración de nombres/aliases sin alterar IDs legacy;
- autorización y auditoría;
- frontend para estados vacíos, bloqueados y N:M;
- E2E OP → OF → OT → manga → pesaje;
- E2E OP → OF/OA → PT;
- regresión del historial autónomo de pesajes.

## 15. Definition of Done

1. Dominio y Tech Spec usan OP como demanda y OF como fabricación.
2. OP, líneas y asignaciones poseen persistencia y API.
3. El plan genera OF/OA borrador idempotentes.
4. OF congela molde/corridas/salidas y puede liberarse.
5. US-010B recibe OF, no OP de demanda.
6. OT/mangas referencian OF/corrida sin perder IDs.
7. OF excepcional exige gobierno.
8. La UI y los PDFs usan nombres correctos.
9. Permisos se expresan como capacidades.
10. Migración y rollback preservan pesajes/documentos legacy.
11. Pruebas afectadas están verdes.
12. UAT valida al menos cobertura total, N:M, multipieza, directa a PT,
    excepcional y ejecución con manga.

## 16. Estado del mock existente

El mock de `/planificacion` sigue siendo aprovechable, pero sus rótulos cambian:

- la antigua “solicitud” pasa a OP;
- “Propuestas de OP” pasa a “Propuestas de OF/OA”;
- “OP excepcional” pasa a “OF excepcional”;
- la entrega a materiales se realiza desde OF liberada;
- el detalle de demanda muestra asignaciones N:M.

La API de esta historia ya reemplazó los comandos de escritura del mock. La
vista persiste OP, revisiones de plan y OF/OA en la base local del piloto.

## 17. Adenda piloto 2026-07-30: metas editables y Kardex

La propuesta automática deja de ser una orden rígida. Cada OF/OA propuesta
conserva:

- `cantidad_calculada`: sugerencia inmutable derivada de demanda, BOM y Kardex;
- `cantidad_objetivo`: meta que Planificación puede revisar antes de confirmar;
- `ajuste_manual`: cantidad anterior, motivo, actor y fecha.

Todo ajuste exige motivo, crea una nueva revisión de
`scm_plan_produccion` y marca la anterior como `SUPERADO`. Una meta cero omite
la creación del documento correspondiente sin cambiar la demanda solicitada.

El piloto incorpora [[Inventario_SCM]] para PT, WIP y PiezaColor:

1. el saldo inicial se registra por artículo y ubicación, sin inventar mangas;
2. el cálculo usa solamente `cantidad_fisica - cantidad_reservada`;
3. la cobertura se aplica de arriba hacia abajo;
4. confirmar revalida y reserva el stock utilizado;
5. reservar no equivale a consumir ni crea movimientos de salida;
6. dos planes no pueden reservar la misma cantidad libre.

### Criterios adicionales

**PLN-11 — ajuste manual:** dado un plan calculado, cuando Planificación cambia
una meta e informa el motivo, entonces nace una nueva revisión que conserva
valor sugerido y objetivo.

**PLN-12 — cobertura Kardex:** dado saldo libre de una PiezaColor requerida,
cuando se calcula la OP, entonces la OF propone sólo el faltante y confirmar
reserva la existencia usada.

Capacidades incorporadas: `INVENTARIO_VER`, `INVENTARIO_SALDO_INICIAL` e
`INVENTARIO_AJUSTAR`. La edición de metas usa
`PLANIFICACION_CALCULAR`; la confirmación mantiene
`PLANIFICACION_CONFIRMAR`.

### Adenda 2026-07-31: pausa por cambio de prioridad

La pausa operativa se aplica primero a la OT y no a la OP. Una OF/OA se muestra
`PAUSADA` solamente cuando todas sus OT/corridas ejecutables pendientes están
pausadas. La OP conserva su estado de demanda.

**PLN-13 — pausa sin doble conteo:** dada una OT con producción, consumos o
mangas confirmadas, cuando se pausa y luego se reanuda, conserva el saldo
pendiente y no duplica efectos ya aplicados.

**PLN-14 — reserva retenida:** dada una OT pausada con material reservado,
otra OP no puede usar ese saldo como libre. Liberarlo exige una acción
autorizada, motivo y nueva revisión de cobertura.

**PLN-15 — pausa agregada:** dada una OF con dos OT, cuando solo una se pausa,
la OF permanece activa; cuando todas las OT ejecutables pendientes están
pausadas, la OF/OA se muestra pausada.

**PLN-16 — manga abierta:** una OT no puede quedar pausada con una manga abierta
sin resolver. La manga debe pesarse, cerrarse o anularse; una preetiqueta no se
reutiliza para otra OT.

### Adenda 2026-07-31: generación contextual y asignación N:M

El piloto puede crear una OF/OA mientras el planificador trabaja una sola OP.
Esto define el contexto de la propuesta, pero no convierte a la OP en padre
exclusivo de la orden ejecutable.

La relación operativa se conserva mediante asignaciones cuantificadas:

```text
OP seleccionada -> propuesta OF/OA -> asignación a su línea OP
```

En una evolución posterior, una OF/OA podrá consolidar varias OP compatibles:

```text
OF-001: 160 unidades
  ├── OP-001: 100
  └── OP-002:  60
```

La interfaz inicial no exige seleccionar múltiples OP. Una OF/OA con una sola
asignación sigue siendo válida; la N:M se conserva para consolidación, stock de
reposición y cambios de prioridad sin rediseñar el modelo.
