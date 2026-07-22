---
tipo: user-story
subtipo: historia-hija
estado: en-refinamiento
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, planificacion, demanda, producto-terminado, pieza-color, orden-produccion, bom, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-007_Normalizar_ProductoTerminado_PiezaColor_Salidas_OP]]"
  - "[[US-008_Normalizacion_ColorProduccion]]"
  - "[[TS-012_Normalizacion_Relacion_Molde_Pieza_NM]]"
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[Orden_Produccion]]"
  - "[[Snapshot_Composicion_Molde]]"
  - "[[Vista_US-010P_Planificacion_Demanda_OP]]"
  - "[[SCM_Frontend_Overview_US-010]]"
fecha_creacion: 2026-07-15
---

# US-010P: Planificar Demanda de ProductoTerminado y Generar Órdenes de Producción

> [!IMPORTANT] Fuente de composición del molde
> Según [[TS-012_Normalizacion_Relacion_Molde_Pieza_NM|TS-012]], planificación resuelve moldes compatibles mediante asociaciones `MoldePieza` activas y toma de ellas cavidades y peso operativo. La revisión de OP congela esos valores; cambios posteriores del maestro y cavidades dañadas durante una corrida no reescriben el snapshot histórico.

## 1. Corrección Conceptual

La cantidad de `ProductoTerminado` deseada debe ser una entrada normal de planificación, pero no convierte al `ProductoTerminado` en la salida física de una Orden de Producción.

El flujo correcto separa dos niveles:

1. **Necesidad comercial o de reposición:** cuántos paquetes de catálogo `ProductoTerminado` se necesitan.
2. **Ejecución industrial:** qué `PiezaColor` faltan y qué moldes, colores y ciclos deben ejecutarse para obtenerlas.

Una OP de inyección o soplado produce `PiezaColor`. El `ProductoTerminado` se obtiene posteriormente en armado, consumiendo las cantidades definidas por su BOM. Por ello:

- una solicitud de `1,000` productos puede no generar ninguna OP si todo está cubierto por stock;
- puede generar una OP si un solo molde produce todas las piezas faltantes;
- puede generar varias OP si requiere moldes o colores diferentes;
- una OP puede cubrir varias solicitudes cuando comparten las mismas `PiezaColor`;
- un molde multipieza puede generar excedentes inevitables de una pieza para cubrir el componente limitante.

Esta historia se identifica como `US-010P` para introducir la planificación antes de US-010B sin renumerar historias ya desarrolladas. La letra `P` significa **Planificación**.

## 2. Historia de Usuario

**Como** responsable de Planificación o Producción  
**Quiero** registrar una demanda de uno o más `ProductoTerminado`, calcular su cobertura y convertir los faltantes de `PiezaColor` en propuestas de OP  
**Para** fabricar únicamente lo necesario, hacer visibles los excedentes técnicos y entregar a US-010B órdenes liberadas desde las cuales calcular y reservar materiales.

## 3. Resultado de Negocio Observable

Al completar esta historia:

1. El usuario puede indicar producto, cantidad requerida, fecha de necesidad, prioridad y origen de la demanda.
2. El sistema congela la revisión de BOM utilizada para calcular la necesidad.
3. La pantalla diferencia necesidad bruta, cobertura existente, suministro entrante comprometido y faltante neto por `PiezaColor`.
4. Los faltantes se convierten en propuestas de lotes de producción agrupados por molde y `ColorProduccion` compatible.
5. Los ciclos son enteros y determinan cantidades y kg netos; `meta_kg` deja de ser la entrada comercial primaria.
6. El sistema muestra coproductos y excedentes inevitables antes de confirmar una propuesta.
7. La confirmación crea una o varias OP en borrador sin reservar materia prima.
8. Solo la liberación explícita de una OP congela su configuración y permite que US-010B genere requerimientos.
9. Puede recorrerse la relación desde la demanda de `ProductoTerminado` hasta las OP, sus salidas `PiezaColor` y las futuras reservas de material.

## 4. Límites de Responsabilidad

### 4.1. Lo que decide esta historia

- qué se necesita fabricar a partir de demanda de `ProductoTerminado`;
- qué parte puede cubrirse con existencias o suministro ya comprometido;
- qué faltantes requieren producción;
- qué molde y `ColorProduccion` conforman cada propuesta;
- cuántos ciclos y salidas se planifican;
- cuándo una propuesta se convierte en OP borrador;
- cuándo una OP se libera y habilita el cálculo de materiales.

### 4.2. Lo que conserva la OP

La OP continúa siendo la instrucción técnica de fabricación. Conserva:

- molde y snapshot de su composición;
- uno o más lotes de producción, cada uno con un único `ColorProduccion`;
- ciclos planificados por lote;
- salidas esperadas por `PiezaColor`;
- pesos unitarios y kg netos derivados;
- receta/revisión, máquina prevista y demás parámetros de ejecución;
- vínculos N:M con las demandas que ayuda a cubrir.

### 4.3. Lo que comienza en US-010B

US-010P no selecciona ni reserva lotes físicos de resina, material recuperado, masterbatch o aditivos.

El punto exacto de entrega es:

```text
OP liberada
  -> snapshots técnicos inmutables
  -> US-010B genera requerimientos absolutos una sola vez
  -> US-010B propone LoteMaterial
  -> usuario confirma reserva
```

Crear o guardar una OP en borrador no compromete inventario de materias primas.

### 4.4. Contrato temporal con inventarios de piezas y PT

El cálculo de cobertura necesita cantidades disponibles y no comprometidas de `PiezaColor` y, cuando se permita cubrir la solicitud con paquetes ya armados, de `ProductoTerminado`.

US-010P puede desarrollarse con fixtures y un puerto de disponibilidad antes de normalizar completamente esos almacenes. Para uso operativo debe cumplirse una de estas condiciones:

1. integrar un read model confiable del inventario normalizado por US-010D/US-010F; o
2. integrar temporalmente el inventario legacy mediante un adaptador conciliado y explícitamente identificado.

Si la fuente está caída, desactualizada o no integrada, el estado es `COBERTURA_NO_CALCULABLE`. El sistema no debe convertir una lectura desconocida en stock cero ni permitir confirmar silenciosamente un plan potencialmente duplicado.

## 5. Lenguaje de Dominio

### 5.1. SolicitudProduccion

Cabecera que expresa una necesidad trazable. Como mínimo conserva:

- identificador estable;
- origen: `PEDIDO`, `REPOSICION_STOCK`, `MUESTRA` u otro motivo catalogado;
- fecha de necesidad y prioridad;
- estado;
- creador, confirmador y marcas de tiempo;
- líneas solicitadas;
- versión de cálculo vigente.

No es una OP, una reserva de materia prima ni un lote físico.

### 5.2. SolicitudProduccionLinea

Indica un `ProductoTerminado` y una cantidad entera positiva de paquetes o unidades de catálogo. Una solicitud puede contener varias líneas.

Debe conservar por separado:

- cantidad solicitada;
- cantidad cubierta con stock de `ProductoTerminado`, si se decide utilizarlo;
- cantidad restante por armar;
- revisión de BOM congelada.

### 5.3. SnapshotBOMProductoTerminado

Versión inmutable de la composición utilizada en el cálculo. Cada línea identifica:

- `PiezaColor` requerida;
- cantidad por `ProductoTerminado`;
- `Pieza`, `ColorProduccion` y SKU resueltos en ese momento;
- revisión o huella de la BOM fuente.

Modificar el catálogo después no reescribe una planificación confirmada.

### 5.4. NecesidadPiezaColor

Resultado consolidado de explotar las líneas de demanda. Mantiene:

- cantidad bruta;
- cobertura con stock no comprometido;
- cobertura con suministro entrante elegible y no comprometido;
- faltante neto;
- cantidad propuesta a producir;
- excedente técnico esperado.

### 5.5. AsignacionCoberturaDemanda

Compromiso de planificación que evita utilizar la misma existencia o salida futura para cubrir dos demandas. No mueve físicamente inventario ni sustituye el consumo de componentes durante armado.

Puede apuntar a:

- stock disponible de `ProductoTerminado`, antes de explotar la cantidad restante por armar;
- stock disponible de `PiezaColor`;
- salida esperada de una OP liberada;
- salida esperada de una OP todavía en planificación.

Debe distinguir al menos:

- `PLANIFICADA`: enlaza una demanda con una OP borrador para consolidar el plan, pero no declara suministro confirmado;
- `COMPROMETIDA`: aparta stock disponible o suministro elegible según la política validada;
- `SATISFECHA`: la cantidad física requerida ya fue producida o asignada definitivamente;
- `CANCELADA`: deja de participar en cobertura sin borrar el historial.

La Tech Spec deberá decidir el nivel de lote físico disponible en cada fase. Ninguna cantidad puede participar simultáneamente en dos asignaciones activas incompatibles.

### 5.6. PropuestaOrdenProduccion

Resultado recalculable que todavía no autoriza ejecución. Agrupa:

- un molde compatible;
- uno o más lotes propuestos, separados por `ColorProduccion`;
- ciclos enteros por lote;
- salidas, kg netos y excedentes calculados;
- demandas y necesidades cubiertas;
- advertencias o bloqueos.

Una propuesta puede descartarse o recalcularse. No reserva materiales.

### 5.7. AsignacionDemandaOP

Relación N:M entre demanda y OP. Debe expresar qué cantidad planificada de cada `PiezaColor` aporta una OP a una o varias solicitudes.

No debe reemplazarse por un `producto_sku` singular dentro de la OP.

## 6. Invariantes

1. `ProductoTerminado` es una BOM de `PiezaColor`; no es la salida directa del molde.
2. Toda línea de demanda usa una cantidad entera positiva.
3. Toda BOM confirmada se conserva como snapshot inmutable.
4. Una BOM sin componentes, con cantidades no positivas o con referencias inactivas no puede planificarse.
5. Cada componente debe resolver una `PiezaColor` válida y, por ella, una `Pieza` y un `ColorProduccion` exactos.
6. Ninguna cobertura puede usar stock o suministro ya comprometido con otra demanda.
7. Una OP borrador o propuesta no cuenta como suministro confirmado para otras solicitudes.
8. Un lote de producción utiliza un solo `ColorProduccion`.
9. Los ciclos planificados siempre son enteros mayores que cero.
10. Las unidades esperadas se derivan de ciclos por cavidades snapshot, nunca de una división fraccionaria de kg.
11. Toda contingencia o cantidad adicional se muestra separada, con política o motivo y autorización; nunca se oculta dentro de `meta_kg`.
12. El kg neto es una magnitud derivada de salidas y pesos snapshot; cualquier ajuste manual conserva motivo, actor y valor anterior.
13. Si un molde produce varias piezas por golpe, todas sus salidas y excedentes deben mostrarse, incluso cuando una no tenga faltante.
14. Toda salida y coproducto del molde debe resolver una `PiezaColor` antes de liberar.
15. No se crea una OP sin molde capaz de producir las `Pieza` previstas.
16. No se combinan colores diferentes dentro del mismo lote de producción.
17. Confirmar la misma propuesta con la misma clave idempotente no crea OP duplicadas.
18. Reintentar la entrega de la misma revisión liberada a US-010B no duplica requerimientos de material.
19. Cambiar molde, color, ciclos, composición o receta de una OP liberada exige una nueva revisión o replanificación auditable.
20. Cancelar una demanda u OP libera únicamente compromisos no ejecutados y conserva el historial.
21. La reserva de materia prima empieza después de liberar la OP y pertenece a US-010B.
22. Una OP manual sin demanda de `ProductoTerminado` requiere propósito y motivo; no puede perder trazabilidad técnica.
23. Una fuente de inventario desconocida no equivale a cantidad disponible cero.

## 7. Cálculo de Necesidades

### 7.1. Cantidad de ProductoTerminado por armar

La utilización de stock de `ProductoTerminado` debe ser visible, no una resta oculta:

```text
cantidad_pt_a_armar = MAX(
    0,
    cantidad_pt_solicitada - cantidad_pt_cubierta_con_stock
)
```

Hasta que Gerencia defina una política automática, la cobertura propuesta se muestra y requiere confirmación del planificador.

### 7.2. Explosión de BOM

Para cada línea de snapshot:

```text
necesidad_bruta_pieza_color =
    cantidad_pt_a_armar * cantidad_pieza_color_por_pt
```

Las necesidades de la misma `PiezaColor` pueden consolidarse entre varias líneas, conservando el desglose de procedencia.

### 7.3. Necesidad neta

```text
faltante_neto = MAX(
    0,
    necesidad_bruta
    - stock_pieza_color_disponible_no_comprometido
    - suministro_liberado_no_comprometido
)
```

Una OP borrador, una producción estimada sin liberar o una cantidad bloqueada por Calidad no debe reducir el faltante.

### 7.4. Ciclos de un molde multipieza

Para cada `PiezaColor i` del mismo grupo molde-color:

```text
objetivo_produccion_i =
    faltante_neto_i + contingencia_autorizada_i

ciclos_necesarios_i = CEIL(objetivo_produccion_i / cavidades_i)
ciclos_grupo = MAX(ciclos_necesarios_i)
salida_planificada_i = ciclos_grupo * cavidades_i
excedente_tecnico_i = MAX(
    0,
    salida_planificada_i - objetivo_produccion_i
)

exceso_total_sobre_faltante_i = MAX(
    0,
    salida_planificada_i - faltante_neto_i
)
```

`contingencia_autorizada` es cero mientras no exista una política o decisión explícita. No se deriva de un porcentaje oculto. También deben calcularse las piezas coproducto del molde aunque su faltante sea cero.

### 7.5. Kg netos derivados

```text
kg_neto_planificado = SUM(
    salida_planificada_i * peso_unitario_snapshot_i_g
) / 1000
```

Los kg brutos de resina, recuperado, masterbatch y aditivos se resuelven posteriormente desde la receta congelada. `meta_kg` puede mantenerse como proyección derivada durante la migración, pero no como único origen de verdad del objetivo.

## 8. Ejemplo Reproducible

### 8.1. Demanda y BOM

```text
Solicitud: SP-00041
ProductoTerminado: SET-REGADERA-ROJO
Cantidad solicitada: 1,000 paquetes

BOM:
- 1 x PC-CUERPO-ROJO-SOLIDO
- 1 x PC-TAPA-ROJO-SOLIDO
```

### 8.2. Cobertura disponible

```text
Cuerpo rojo disponible no comprometido: 100
Tapa roja disponible no comprometida: 80
Suministro entrante elegible: 0

Faltante cuerpo: 900
Faltante tapa: 920
```

### 8.3. Molde seleccionado

```text
Molde M-REG-02:
- 1 cavidad cuerpo, peso snapshot 120 g
- 1 cavidad tapa, peso snapshot 30 g
```

Resultado:

```text
Ciclos planificados: 920
Salida cuerpo: 920 -> 900 cubren demanda y 20 quedan como excedente
Salida tapa: 920 -> 920 cubren demanda y 0 excedente
Contingencia: 0
Kg netos: 920 * (120 g + 30 g) / 1000 = 138.000 kg
```

La solicitud genera una propuesta de lote rojo de `920` ciclos. Después de configurar y liberar la OP, US-010B calcula materiales sobre su receta técnica; no sobre `1,000 productos` ni sobre un kg escrito libremente.

## 9. Flujo Funcional

### 9.1. Registrar demanda

1. Crear solicitud en borrador.
2. Agregar uno o más `ProductoTerminado` y cantidades.
3. Registrar fecha, prioridad y origen.
4. Validar que cada producto tenga BOM activa y resoluble.

### 9.2. Calcular cobertura

1. Congelar una revisión de BOM para el cálculo.
2. Mostrar stock de `ProductoTerminado` elegible.
3. Determinar cantidad restante por armar mediante una decisión visible.
4. Explotar la BOM hacia `PiezaColor`.
5. Consultar stock y suministro liberado no comprometidos.
6. Bloquear confirmación si la fuente de inventario no es confiable o no está disponible.
7. Crear una propuesta de cobertura sin comprometer todavía cantidades.

### 9.3. Generar propuestas de OP

1. Tomar únicamente faltantes netos positivos.
2. Buscar moldes activos capaces de producir las `Pieza` requeridas.
3. Agrupar primero por molde y `ColorProduccion`.
4. Calcular contingencia visible, ciclos, salidas, kg netos y excedentes.
5. Permitir consolidar lotes del mismo molde en una OP cuando la secuencia sea compatible.
6. Mostrar alternativas de molde sin decidir silenciosamente por el usuario.
7. Bloquear el cálculo cuando no exista combinación técnicamente válida.

### 9.4. Confirmar plan

1. Validar nuevamente BOM, disponibilidad y compromisos.
2. Confirmar cobertura y propuestas de forma atómica.
3. Crear las OP como `BORRADOR` con vínculo a sus demandas.
4. Preservar la versión del cálculo y la clave idempotente.
5. No generar todavía reservas de materia prima.

### 9.5. Configurar OP técnica

1. Revisar molde y snapshot de composición.
2. Revisar lotes, `ColorProduccion`, secuencia y ciclos.
3. Seleccionar revisión de receta y máquina prevista cuando corresponda.
4. Mostrar outputs por `PiezaColor`, kg derivados y excedentes.
5. Resolver advertencias antes de liberar.

### 9.6. Liberar OP y entregar a US-010B

1. Validar que la OP esté completa y no haya cambiado la base del plan.
2. Crear una revisión técnica inmutable.
3. Cambiar `estado_op` a `LIBERADA`.
4. Entregar a US-010B la revisión, receta, ciclos, salidas y kg derivados mediante un contrato idempotente.
5. US-010B genera requerimientos absolutos una sola vez y cambia `estado_abastecimiento` a `REQUERIDO`.
6. Habilitar `Proponer lotes` y navegar al espacio de US-010B.

La interfaz puede presentar `Liberar y calcular materiales` como un solo comando de usuario, pero el dominio conserva dos resultados distinguibles: primero OP liberada; después requerimientos calculados. Si el segundo paso falla, debe poder reintentarse sin duplicar la liberación ni los requerimientos.

## 10. Estados Independientes

### 10.1. Estado de la solicitud

```text
BORRADOR -> CALCULADA -> CONFIRMADA -> EN_COBERTURA -> CUBIERTA
    |             ^
    |             |
    +-> COBERTURA_NO_CALCULABLE

BORRADOR/CALCULADA/CONFIRMADA -> CANCELADA
```

`CUBIERTA` significa que existen asignaciones suficientes entre stock y suministro confirmado. No significa que el `ProductoTerminado` ya fue armado o despachado.

`COBERTURA_NO_CALCULABLE` es recuperable: al restablecer o conciliar la fuente de inventario se recalcula una nueva versión. No equivale a faltante total.

### 10.2. Estado de la OP

```text
BORRADOR -> PLANIFICADA -> LIBERADA -> EN_EJECUCION -> COMPLETADA
    |            |            |
    +------------+------------+-> CANCELADA
```

### 10.3. Estado de abastecimiento de la OP

```text
SIN_CALCULAR -> REQUERIDO -> RESERVA_PARCIAL -> RESERVADO
                                  |                |
                                  +-------> EMISION_PARCIAL -> EMITIDO
```

El estado industrial de la OP no debe inferirse a partir del estado de materiales, ni al revés.

## 11. Función del Formulario de OP Existente

El formulario existente no debe desaparecer; cambia de responsabilidad y nombre conceptual:

> **Configuración técnica de OP**

En el flujo normal se abre prellenado desde una `PropuestaOrdenProduccion`. Permite revisar molde, lotes por color, ciclos, receta, máquina y salidas antes de liberar.

La creación técnica manual permanece como flujo excepcional para:

- reposición directa de inventario de `PiezaColor`;
- muestras o pruebas;
- reemplazo por rechazo o faltante operativo;
- otra finalidad catalogada.

En ese caso exige propósito, motivo y actor. Una OP manual sigue produciendo `PiezaColor`; no inventa un `ProductoTerminado` de salida.

## 12. Refactorizaciones Necesarias

### 12.1. Backend y modelo

1. Introducir la solicitud, sus líneas, snapshots de BOM, necesidades y asignaciones de cobertura.
2. Representar la relación demanda-OP como N:M.
3. Retirar o deprecar `OrdenProduccion.producto_sku` como supuesto origen/salida singular.
4. Retirar `LoteColor.producto_sku_output`; las salidas físicas se modelan mediante `LoteSalidaPiezaColor`.
5. Reemplazar `activa` como único estado de OP por estados explícitos y auditables.
6. Convertir ciclos enteros y salidas por cavidad en la base del plan técnico.
7. Mantener kg netos como cálculo derivado y versionado.
8. Exponer a US-010B únicamente revisiones liberadas, identificables e inmutables para generar requerimientos.
9. Impedir que una OP cree materiales, pigmentos o colores maestros desde texto libre.

### 12.2. Frontend

1. Añadir el módulo `Planificación` antes de la lista técnica de OP.
2. Crear un asistente: `Demanda -> Cobertura -> Propuestas de OP -> Configuración -> Liberación`.
3. Mostrar unidades de `ProductoTerminado` en demanda y unidades/kg/ciclos en ejecución sin mezclarlas.
4. Renombrar el formulario actual como configuración técnica y abrirlo prellenado.
5. Separar en la lista `estado_op` y `estado_abastecimiento`.
6. Añadir una acción explícita `Liberar y calcular materiales`.
7. Mostrar después `Proponer lotes` y `Confirmar reserva` como acciones de US-010B.
8. Mantener con candado los comandos que todavía no tengan API, según [[Patron_Capacidades_API_y_Mocks]].

### 12.3. Migración de compatibilidad

Mientras existan registros legacy:

- `producto_sku` puede mostrarse como referencia histórica, no como salida física;
- `meta_kg` puede conservarse como dato legado y compararse con el kg derivado;
- una diferencia debe marcarse para conciliación, no sobrescribirse;
- ninguna migración debe fabricar vínculos N:M o BOM snapshots que no puedan demostrarse.

## 13. Escenarios ATDD/BDD

### PLN-01: Una demanda genera necesidades por componente

**Dado** un `ProductoTerminado` con cuerpo rojo x1 y tapa roja x1  
**Cuando** se solicitan `1,000` unidades y no existe cobertura  
**Entonces** se calculan `1,000` cuerpos y `1,000` tapas como necesidad bruta  
**Y** no se considera al producto como salida directa de una OP.

### PLN-02: El stock cubre totalmente la demanda

**Dado** que todo el `ProductoTerminado` solicitado se asigna desde stock disponible  
**Cuando** se confirma la cobertura  
**Entonces** la cantidad por armar es cero  
**Y** no se genera ninguna propuesta de OP.

### PLN-03: Stock parcial de componentes y molde multipieza

**Dado** el dataset `SP-00041`  
**Cuando** el molde produce un cuerpo y una tapa por ciclo  
**Entonces** se proponen `920` ciclos  
**Y** se muestran `20` cuerpos como excedente técnico.

### PLN-04: Componentes requieren moldes diferentes

**Dado** que dos faltantes no pueden producirse con el mismo molde  
**Cuando** se generan propuestas  
**Entonces** se crean al menos dos propuestas técnicas  
**Y** ambas conservan vínculo con la misma demanda.

### PLN-05: Colores diferentes no se mezclan

**Dado** que la demanda contiene `PiezaColor` rojas y azules del mismo molde  
**Cuando** se propone la ejecución  
**Entonces** se crean lotes de producción separados por `ColorProduccion`  
**Y** cada lote incluye todas las salidas físicas del molde para ese color  
**Y** las variantes no requeridas se muestran como coproductos o excedentes  
**Y** los lotes pueden ordenarse dentro de una misma OP sin mezclarse.

### PLN-06: Varias demandas comparten una salida

**Dado** que dos solicitudes necesitan la misma `PiezaColor`  
**Cuando** se consolida el faltante dentro del horizonte permitido  
**Entonces** una OP puede asignar cantidades a ambas solicitudes  
**Y** el desglose de cobertura sigue siendo consultable.

### PLN-07: La BOM cambia después de confirmar

**Dado** un plan confirmado con revisión `BOM-7`  
**Cuando** el catálogo cambia a `BOM-8`  
**Entonces** el plan conserva `BOM-7`  
**Y** una replanificación crea una nueva revisión sin alterar la anterior.

### PLN-08: No existe molde compatible

**Dado** un faltante de `PiezaColor` cuya `Pieza` no tiene molde activo  
**Cuando** se calculan propuestas  
**Entonces** el sistema bloquea la confirmación  
**Y** identifica la pieza y el motivo.

### PLN-09: No existe PiezaColor válida

**Dado** un componente de BOM sin `PiezaColor` activa o sin `ColorProduccion` exacto  
**Cuando** se valida la demanda  
**Entonces** no se crea automáticamente un color incompleto  
**Y** la inconsistencia se deriva al catálogo.

### PLN-10: Los ciclos nunca son fraccionarios

**Dado** un faltante que no es divisible por las cavidades del molde  
**Cuando** se calcula la propuesta  
**Entonces** se redondea hacia arriba a un ciclo entero  
**Y** el excedente queda visible.

### PLN-11: Confirmación idempotente

**Dado** un plan confirmado con una clave idempotente  
**Cuando** se reintenta la misma solicitud con el mismo contenido  
**Entonces** se devuelven las mismas OP  
**Y** no se crean duplicados.

### PLN-12: Un borrador no reserva materia prima

**Dado** una OP creada desde una propuesta y aún en `BORRADOR`  
**Cuando** se consulta US-010B  
**Entonces** no existen requerimientos reservables para esa revisión  
**Y** la interfaz explica que debe liberarse.

### PLN-13: Liberación habilita requerimientos una sola vez

**Dado** una OP técnica válida  
**Cuando** un usuario autorizado ejecuta `Liberar y calcular materiales`  
**Entonces** se congela la revisión y US-010B genera requerimientos absolutos  
**Y** si el cálculo se reintenta no duplica la liberación ni los requerimientos  
**Y** US-010B puede proponer lotes físicos.

### PLN-14: Replanificar una OP liberada conserva historia

**Dado** una OP liberada cuyos ciclos deben cambiar  
**Cuando** se autoriza la replanificación  
**Entonces** se conserva la revisión anterior y sus compromisos  
**Y** se compensan únicamente cantidades todavía no ejecutadas.

### PLN-15: OP manual exige motivo

**Dado** que el usuario elige crear una OP sin solicitud de `ProductoTerminado`  
**Cuando** no registra propósito y motivo  
**Entonces** el sistema impide guardarla  
**Y** con ambos datos puede continuar como reposición directa de `PiezaColor`.

### PLN-16: Trazabilidad desde demanda hasta materiales

**Dado** una demanda cubierta por una OP liberada  
**Cuando** se consulta su trazabilidad  
**Entonces** se observan BOM snapshot, necesidades, cobertura, OP, lotes de producción y requerimientos  
**Y** después de US-010B también se observan las reservas de `LoteMaterial` relacionadas.

### PLN-17: Inventario no disponible no se interpreta como cero

**Dado** que la fuente de stock de `PiezaColor` no responde o no está conciliada  
**Cuando** se calcula cobertura  
**Entonces** la solicitud queda en `COBERTURA_NO_CALCULABLE`  
**Y** el sistema no propone fabricar como si no existiera stock  
**Y** no permite confirmar el plan sin una resolución autorizada y auditable.

### PLN-18: No existe contingencia oculta

**Dado** un faltante neto de `920` tapas y ninguna política de contingencia  
**Cuando** se calculan ciclos  
**Entonces** la contingencia utilizada es cero y queda visible  
**Y** cualquier cantidad adicional requiere motivo o política versionada  
**Y** no se altera escribiendo un `meta_kg` mayor sin explicación.

## 14. Resultados de Interfaz Esperados

### 14.1. Bandeja de demanda

- solicitudes, origen, prioridad, fecha requerida y avance de cobertura;
- búsqueda por producto, solicitud u OP relacionada;
- acciones para crear, recalcular, confirmar, cancelar y consultar trazabilidad según permisos.

### 14.2. Asistente de planificación

1. **Demanda:** líneas de `ProductoTerminado` y cantidades.
2. **Cobertura:** PT disponible, BOM explotada, stock de `PiezaColor`, suministro y faltante.
3. **Propuestas de OP:** molde, colores, contingencia, ciclos, salidas, kg y excedentes.
4. **Configuración:** datos técnicos de cada OP borrador.
5. **Revisión y liberación:** impactos, bloqueos y entrega hacia materiales.

### 14.3. Lista de OP

Cada fila debe mostrar por separado:

- estado industrial de OP;
- estado de abastecimiento;
- demandas relacionadas;
- molde y lotes/color;
- acción de configuración;
- acción `Liberar y calcular materiales` cuando corresponda;
- acción `Preparar materiales` una vez generado el requerimiento.

## 15. Contratos con Otras Historias

| Historia | Entrada o salida de US-010P |
| :--- | :--- |
| [[US-007_Normalizar_ProductoTerminado_PiezaColor_Salidas_OP]] | Entrega BOM de `ProductoTerminado`, `PiezaColor`, composición de molde y salidas normalizadas. |
| [[US-008_Normalizacion_ColorProduccion]] | Entrega la identidad exacta de color requerida para agrupar lotes. |
| [[US-009_Normalizar_Trabajadores_Maquinas_y_Vistas_Catalogo]] | Entrega máquinas, trabajadores y catálogos técnicos normalizados. |
| [[US-010A_Recepcion_Trazable_Materiales]] | No participa en la explosión de demanda; abastece posteriormente los lotes físicos elegibles. |
| [[US-010B_Reserva_Emision_Materiales_OP]] | Recibe una OP liberada y su revisión congelada; genera requerimientos absolutos, propone lotes y confirma reservas. |
| US-010C | Confirma consumo y salidas reales contra el plan de ciclos y `PiezaColor`. |
| US-010F | Consume las `PiezaColor` reales para armar lotes de `ProductoTerminado` y cerrar la demanda. |

## 16. Decisiones de Negocio por Validar

Estas preguntas no deben convertirse silenciosamente en constantes del sistema:

1. ¿Quién puede crear, confirmar y liberar una planificación?
2. ¿El stock de `ProductoTerminado` se propone siempre como cobertura o depende del origen de demanda?
3. ¿Qué estados de inventario de `PiezaColor` son elegibles para cobertura?
4. ¿Una OP ya liberada cuenta como suministro entrante antes de tener producción física buena?
5. ¿Se permite consolidar solicitudes distintas en la misma OP y dentro de qué horizonte de fechas/prioridades?
6. Si existen varios moldes compatibles, ¿quién elige y qué datos deben compararse: ciclos, merma, tiempo o disponibilidad?
7. ¿Qué cambio obliga a replanificar en vez de editar un borrador?
8. ¿Cómo se prioriza una cobertura insuficiente entre pedidos, reposición y muestras?
9. ¿Quién puede crear una OP técnica manual y qué motivos iniciales se habilitan?
10. ¿Se planifica una contingencia por rechazo, arranque o seguridad? ¿En unidades, por componente o mediante qué política aprobada?
11. ¿Qué fuente se considera autoritativa para stock disponible y compromisos de `PiezaColor` y `ProductoTerminado` durante cada fase de migración?

Para el mock puede usarse un dataset explícito con decisiones visibles. Ningún supuesto del mock se considera política aprobada.

## 17. Estrategia de Pruebas y TDD

| Nivel | Responsabilidad | Escenarios principales |
| :--- | :--- | :--- |
| Dominio unitario | explosión BOM, neteo, contingencia, ciclos, excedentes, kg y estados | PLN-01, PLN-02, PLN-03, PLN-05, PLN-10, PLN-12, PLN-18 |
| Integración BD | snapshots, asignaciones N:M, idempotencia, concurrencia y revisiones | PLN-06, PLN-07, PLN-11, PLN-13, PLN-14 |
| Contrato de catálogo e inventario | productos, piezas, colores, moldes, recetas y disponibilidad confiable | PLN-08, PLN-09, PLN-17 |
| Interfaz | asistente, advertencias, estados y acciones habilitadas | PLN-02, PLN-03, PLN-08, PLN-12, PLN-15 |
| E2E P-B | demanda -> OP liberada -> requerimiento -> propuesta de lotes | PLN-13, PLN-16 |

Orden TDD recomendado:

1. `PLN-01`: explotar una BOM congelada.
2. `PLN-03`: calcular faltante, ciclos y excedente multipieza.
3. `PLN-10`: impedir ciclos fraccionarios.
4. `PLN-02`: no crear OP cuando la cobertura es total.
5. `PLN-08` y `PLN-09`: bloquear catálogos incompletos.
6. `PLN-11`: confirmar de forma idempotente.
7. `PLN-06`: asignar una OP a varias demandas sin doble cobertura.
8. `PLN-12` y `PLN-13`: separar borrador, liberación y requerimiento.
9. `PLN-14`: replanificar sin borrar historia.
10. `PLN-17`: distinguir indisponibilidad de stock cero.
11. `PLN-18`: hacer explícita la contingencia.
12. `PLN-16`: recorrer el contrato completo hacia US-010B.

Los primeros cálculos deben implementarse como funciones puras con fixtures. La unicidad de asignaciones, la concurrencia y la idempotencia se verifican después contra PostgreSQL.

## 18. Definición de Preparada para Tech Spec

- [x] Se separó demanda comercial de ejecución industrial.
- [x] Se definió que la salida de OP es `PiezaColor`.
- [x] Se definieron explosión de BOM, faltante neto, ciclos enteros y excedentes.
- [x] Se delimitó el punto de entrega hacia US-010B.
- [x] Existe un dataset reproducible y escenarios ATDD/BDD.
- [x] Se identificó la nueva función del formulario de OP.
- [ ] Producción y Gerencia validaron las decisiones de la sección 16.
- [ ] Se acordaron estados elegibles de inventario de `PiezaColor`.
- [ ] Se acordaron roles mínimos para confirmar y liberar.
- [ ] Se acordó la fuente autoritativa o adaptador temporal de inventario para cobertura.
- [ ] Los escenarios `PLN-01` a `PLN-18` fueron revisados con usuarios del proceso.

La estructura frontend mock puede avanzar antes de cerrar estas preguntas, siempre que muestre los supuestos y mantenga bloqueados los comandos sin API.

## 19. Fuera de Alcance

- pronóstico de ventas o demanda automática;
- compras y órdenes de compra;
- optimización matemática completa de capacidad, turnos o secuenciación;
- reserva y emisión de lotes de materia prima, que corresponden a US-010B;
- ejecución de máquina y confirmación de consumo, que corresponden a US-010C;
- pesaje y creación de unidades logísticas de salida;
- armado físico de `ProductoTerminado`, que corresponde a US-010F;
- promesa de fecha al cliente o planificación financiera;
- sustitución automática de piezas, colores, materiales o moldes sin autorización.

## 20. Definición de Terminado

1. Una demanda confirmada conserva su BOM snapshot y sus decisiones de cobertura.
2. El sistema calcula faltantes sin contar dos veces stock ni suministro.
3. Toda propuesta muestra molde, color, ciclos enteros, salidas, kg y excedentes.
4. La contingencia se muestra separada y ninguna indisponibilidad de inventario se interpreta como stock cero.
5. Una demanda puede generar cero, una o varias OP; una OP puede cubrir varias demandas.
6. La OP no utiliza un `ProductoTerminado` singular como salida física.
7. El formulario técnico recibe datos prellenados desde planificación y el flujo manual exige motivo.
8. Una OP borrador no genera reservas ni aparenta disponibilidad futura confirmada.
9. Liberar una revisión válida permite que US-010B genere requerimientos idempotentes y proponga lotes.
10. Estados de OP y abastecimiento se consultan por separado.
11. Puede trazarse demanda -> BOM -> necesidad -> cobertura -> OP -> lote de producción -> requerimiento.
12. Correcciones y cancelaciones conservan historia y liberan solo compromisos no ejecutados.
13. Las pruebas unitarias, de integración, contrato, interfaz y E2E afectadas están verdes.

## 21. Corte Frontend con Datos Mock

Se implementó un primer corte navegable de US-010P sin adelantar decisiones de negocio ni fingir persistencia:

- bandeja de solicitudes en `/planificacion` y detalle direccionable en `/planificacion/:solicitudId`;
- asistente `Demanda -> Cobertura -> Propuestas de OP -> Configuración -> Liberación`;
- cálculos puros de BOM, faltante neto, ciclos enteros, salidas, kg, contingencia y excedente técnico;
- fixtures para cobertura completa, molde faltante, inventario no disponible y OP liberada;
- entrega visible hacia `/materiales/preparaciones/OP-B-TEST-001` para representar la frontera con US-010B;
- navegación principal `Planificación` y reclasificación de la creación directa como `OP excepcional` dentro de Producción;
- candado de API en todos los comandos que crearían o modificarían datos reales.

La reserva de lotes físicos no se ejecuta al crear o configurar la OP. Comienza en US-010B únicamente después de que exista una OP liberada con requerimientos calculados.

Este corte cubre de forma observable `PLN-02`, `PLN-03`, `PLN-08`, `PLN-10`, `PLN-12`, `PLN-13`, `PLN-17` y `PLN-18`, con soporte de cálculo para `PLN-01`. No cambia el estado general de la historia: la persistencia, permisos, idempotencia, revisiones y escenarios N:M continúan pendientes de Tech Spec y backend.
