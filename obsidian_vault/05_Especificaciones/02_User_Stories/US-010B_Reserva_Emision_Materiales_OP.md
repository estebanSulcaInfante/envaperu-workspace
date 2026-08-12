---
tipo: user-story
subtipo: historia-hija
estado: implementado-piloto-local-pendiente-uat
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, trazabilidad, materiales, reserva, emision, premezcla, produccion, lotes, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
  - "[[US-010L_Material_Segunda_Reproceso_y_Mezcla_Preparada_Trazable]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[Vista_US-010B_Preparacion_Materiales]]"
  - "[[Orden_Fabricacion]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[Lote_Color]]"
  - "[[Composicion_Materiales]]"
  - "[[Receta_Colorantes]]"
  - "[[2026-08-03_Alcance_Piloto_Apertura_Inicial_sin_Recepcion_Compras]]"
fecha_creacion: 2026-07-15
fecha_actualizacion: 2026-08-08
---

# US-010B: Reserva, Emisión y Premezcla Trazable de Materiales para una OF

> [!SUCCESS] Incremento transaccional local — 2026-08-03
> `/materiales/preparaciones` consume la API SCM y permite generar
> requerimientos, reservar saldos de apertura, emitir, devolver y confirmar una
> premezcla trazable. La migración se aplicó únicamente a PostgreSQL local. La
> historia permanece pendiente de UAT operativa y no autoriza despliegue.

> [!WARNING] Brecha de autoridad física — 2026-08-08
> La implementación local confirma la premezcla consumiendo automáticamente el
> saldo `emitido - devuelto - consumido` y deriva la salida como suma de esos
> saldos. No captura todavía incorporaciones reales, bruto/tara/neto, dispositivo
> ni pérdidas. Esta simplificación no cubre preparación experimental ni permite
> una UAT física de dosificación. La extensión y sus criterios están en
> [[US-010L_Material_Segunda_Reproceso_y_Mezcla_Preparada_Trazable|US-010L]].

> [!IMPORTANT] Terminología vigente
> Esta historia recibe una [[Orden_Fabricacion|OF]] liberada. Las menciones
> históricas a OP técnica, `OrdenProduccion` o `orden_id` se mantienen solo en
> contratos legacy durante la migración; la [[Orden_Produccion|OP]] de demanda
> no reserva materia prima directamente.

## 1. Decisión de Alcance

Esta historia comienza cuando [[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]] entrega una OF `LIBERADA`, con una o más corridas, ciclos/salidas planificados y una revisión técnica y de receta congelada. Termina cuando Producción conoce qué cantidades de qué lotes físicos están reservadas, cuáles fueron emitidas desde el almacén de materias primas y, cuando se prepara resina ya coloreada antes de alimentar la máquina, qué inputs formaron cada lote de premezcla.

US-010B no decide cuántos `ProductoTerminado` fabricar, no explota su BOM y no crea la OF técnica. Su primera acción sobre una OF liberada es generar requerimientos absolutos; después propone lotes físicos. La reserva comienza únicamente cuando un usuario autorizado confirma esa propuesta.

US-010B separa explícitamente:

1. **Planificado:** lo que indica la receta congelada de la OF/corrida.
2. **Reservado:** cantidad comprometida para la OF, todavía físicamente en almacén.
3. **Emitido a Producción:** cantidad identificada que se movió a preparación o pie de máquina.
4. **Devuelto:** cantidad emitida que retorna conservando identidad y aptitud.
5. **Consumido en preparación:** cantidad emitida incorporada realmente a una premezcla y que ya no puede devolverse como componente separado.
6. **Lote de premezcla:** resina ya coloreada obtenida de inputs identificados y disponible como WIP para una corrida.
7. **Consumido en máquina:** cantidad que la corrida de inyección o soplado confirma como entrada real; corresponde a [[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]].

Emitir material no equivale a consumirlo. La salida de almacén cambia ubicación y compromiso, pero no destruye existencia física. La confirmación de una premezcla sí consume sus inputs y crea otra identidad trazable; todavía no demuestra que esa premezcla entró a la máquina.

## 2. Avance en Paralelo con US-010A y US-010P

La ficha [[Validacion_Operativa_US-010A]] no es requisito para redactar estos escenarios ni para probar el núcleo de reserva.

US-010B se prueba contra contratos de inventario y OF liberada con fixtures sintéticos. No necesita conocer:

- nombres reales de racks, silos o responsables;
- valores productivos de tolerancia de recepción;
- motivos iniciales cargados en planta;
- números reales de OC, guías o lotes de proveedor.

Sí necesita que el contrato de US-010A garantice, aunque todavía sea mediante un fake de pruebas:

- identidad estable de material y lote;
- cantidad física y cantidad disponible en kg;
- estado de Calidad;
- retenciones documentales u operativas;
- ubicación compatible con materias primas;
- versión o mecanismo de concurrencia para no reservar dos veces el mismo saldo.

También necesita que el contrato de US-010P garantice, aunque todavía sea mediante una OF fixture:

- OF en estado `LIBERADA` y revisión estable;
- lote de producción y `ColorProduccion` identificados;
- ciclos, salidas `PiezaColor` y kg netos derivados;
- receta y base de dosificación congeladas;
- clave idempotente para generar requerimientos una sola vez.

US-010B puede refinarse y desarrollar su dominio antes de integrar US-010A o implementar el frontend de US-010P. Para el nuevo piloto puede consumir inventario real nacido de un lote de `APERTURA_INICIAL` aprobado; no requiere fingir una recepción de compra. No puede completar su E2E ni liberarse a operación hasta recibir saldos reales del Kardex y una revisión de OF liberada mediante el contrato de US-010P.

## 3. Historia de Usuario

**Como** responsable de Producción y Almacén de materias primas  
**Quiero** calcular, reservar, emitir y preparar materiales identificados por lote para cada lote de producción  
**Para** evitar dobles asignaciones, impedir el uso de material no disponible y conservar la procedencia con la máxima granularidad realmente observada para cada corrida.

## 4. Resultado de Negocio Observable

Al completar esta historia:

1. Cada lote de producción muestra requerimiento planificado, reservado, emitido, consumido en preparación, WIP resultante, devuelto y pendiente por material.
2. Cada reserva identifica cantidades concretas de uno o varios `LoteMaterial`.
3. Dos OF no pueden comprometer la misma cantidad disponible.
4. Almacén no puede emitir material pendiente, bloqueado, rechazado o retenido.
5. La emisión conserva lote, cantidad, origen, destino, balanza cuando exista, trabajador y momento.
6. El stock físico no se reduce por reservar y tampoco se declara consumido por emitir.
7. Cada premezcla conserva su propia identidad y declara procedencia `EXACTA` cuando conoce lotes/cantidades o `CONJUNTO_CANDIDATOS` cuando la tolva perdió esa granularidad.
8. [[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]] puede tomar un lote de premezcla o, si una receta excepcional no la usa, cantidades emitidas identificadas, y confirmar cuáles entraron realmente a la corrida.

## 5. Lenguaje de Dominio

### 5.1. Lote de producción

Segmento ejecutable de una OF para un color y una receta congelada. Evoluciona conceptualmente el `LoteColor` actual hacia `CorridaFabricacion` sin asumir que su tabla deba renombrarse en esta historia.

### 5.2. Requerimiento de material

Línea planificada e inmutable para una revisión de receta:

- lote de producción;
- definición estable de material;
- cantidad objetivo;
- unidad base y regla de conversión usada;
- origen del cálculo y revisión de receta;
- clasificación: resina, material recuperado/comprado, masterbatch, pigmento o aditivo.

No representa inventario ni lote físico.

### 5.3. Reserva de material

Compromiso de una cantidad disponible de un `LoteMaterial` con un requerimiento y lote de producción. No cambia la ubicación ni la existencia física; reduce la cantidad que otras órdenes pueden reservar.

### 5.4. Emisión de material

Movimiento físico de una cantidad reservada desde una ubicación de materias primas hacia una ubicación compatible de preparación, mezcla o alimentación de Producción. Mantiene la identidad del lote de origen mientras esa identidad sea físicamente preservable.

### 5.5. Devolución de material emitido

Retorno de una cantidad no consumida a una ubicación compatible. Solo puede reincorporarse al lote original cuando permanece identificada, no mezclada y apta según la política aplicable.

### 5.6. Preparación o mezcla

**Decisión de negocio refinada el 2026-07-21:** EnvaPerú realiza premezcla al juntar las materias primas definidas por la receta —resina virgen y/o de segunda— con colorante y aditivos aplicables. La frontera observable del WIP es la mezcla homogenizada que sale de la tolva lista para alimentar la máquina.

Cuando los materiales se mezclan y dejan de ser separables, ya no existe una simple emisión ni una devolución de componentes originales. Debe confirmarse una `PreparacionMezcla` que:

- consume cantidades reales cuando fueron registradas o, si la práctica de tolva perdió esa granularidad, el conjunto conservador de recepciones/proveedores candidatos;
- crea un `LoteMezclaPreparada` con identidad estable, incluso cuando se lleva inmediatamente a la máquina;
- conserva lote de producción, revisión de receta, trabajador, momento, tolva, balanza cuando aplique y nivel de genealogía de inputs;
- permite mover o almacenar el resultado como WIP sin fingir que los componentes continúan separados.

La cantidad de bolsas por tanda y la forma de identificar físicamente la premezcla siguen siendo parámetros operativos por validar. En el flujo normal la salida de tolva pasa a alimentación de máquina; cualquier almacenamiento intermedio debe registrarse como movimiento de WIP.

#### 5.6.1. Granularidad de Procedencia

Cada `LoteMezclaPreparada` declara uno de estos niveles:

- `EXACTA`: se conocen los lotes internos y cantidades realmente incorporadas.
- `CONJUNTO_CANDIDATOS`: se mezclaron materiales compatibles de varias recepciones o proveedores sin registrar qué bolsa o cantidad exacta aportó cada origen. Se conservan todos los candidatos posibles, el material, la ventana temporal y la tolva/tanda.

`CONJUNTO_CANDIDATOS` es una pérdida de granularidad aceptada para v1, no una genealogía exacta. Toda consulta de impacto o retiro debe incluir a todos los candidatos; la interfaz y reportes no pueden atribuir porcentajes ni consumos individuales que no fueron observados.

### 5.7. Consumo real

El consumo siempre requiere una transformación confirmada; nunca se infiere automáticamente como `emitido - devuelto`.

- US-010B confirma el consumo de resina, colorantes, aditivos u otros inputs incorporados a una `PreparacionMezcla` y crea el WIP resultante.
- US-010C confirma el consumo del `LoteMezclaPreparada` en la corrida de inyección o soplado.
- Si en el futuro existe dosificación directa para una receta excepcional, US-010C consume los lotes emitidos directamente.

La mezcla remanente, material en tolva, purga, derrame u otro WIP debe quedar pendiente de conciliación y no convertirse en consumo por diferencia.

## 6. Contrato Funcional con US-010A

Para cada cantidad candidata, B debe poder consultar como mínimo:

| Dato contractual | Regla consumida por US-010B |
|---|---|
| `lote_material_id` | Identidad estable y no reutilizable. |
| `material_id` | Debe coincidir con el requerimiento o una sustitución autorizada. |
| `proveedor_id` | Procedencia conocida de la recepción, aunque el lote externo esté `NO_INFORMADO`. |
| `lote_proveedor_estado` | `INFORMADO`, `NO_INFORMADO` o `ILEGIBLE`; su ausencia no invalida por sí sola el lote interno. |
| `cantidad_fisica_kg` | Existencia actual antes de reservas y movimientos. |
| `cantidad_reservada_kg` | Compromisos activos de todas las órdenes. |
| `cantidad_emitida_no_consumida_kg` | Existencia asignada que ya está fuera del almacén disponible. |
| `cantidad_disponible_kg` | Proyección reservable, nunca un campo modificable libremente. |
| `estado_calidad` | Solo `LIBERADO` permite nueva reserva o emisión. |
| `retenciones` | Cualquier retención incompatible impide nueva reserva o emisión. |
| `ubicacion_id` y propósito | Debe pertenecer al ámbito de materias primas. |
| `version` | Permite detectar carreras y recalcular atómicamente. |

Proyección mínima:

`disponible_para_reserva = existencia_liberada_sin_retenciones - reservas_activas - compromisos_no_disponibles`

La Tech Spec decidirá si la proyección se calcula por eventos, saldos transaccionales o ambos. Las pruebas no podrán simular éxito sin verificar persistencia y concurrencia reales en el nivel de integración.

## 7. Normalización de la Receta Planificada

### 7.1. Snapshot obligatorio

La reserva utiliza una revisión congelada de receta. Cambiar posteriormente el catálogo de materiales, la fórmula o el color no modifica requerimientos ni reservas históricas.

### 7.2. Materiales con identidad estable

La OF selecciona definiciones existentes. No puede crear `MateriaPrima` o `Colorante` por nombre libre durante su guardado, como ocurre actualmente en `rutas_produccion.py`.

### 7.3. Cantidad absoluta resoluble

Antes de reservar, cada línea debe resolverse a una cantidad absoluta en kg con tres decimales y conservar:

- valor original;
- unidad original;
- base de dosificación;
- regla de conversión;
- resultado normalizado.

Una fórmula ambigua no se convierte silenciosamente en cero ni en una dosis supuesta.

### 7.4. Base validada para colorantes

Esta regla ya aparecía parcialmente en [[US-006_Normalizar_Composicion_Color_Familia]] como “gramos por bolsa de 25kg” y en [[Receta_Colorantes]] como “gramos por bolsa”, pero faltaba declarar qué material formaba la base.

**Decisión de negocio validada el 2026-07-15:** los gramajes de colorante se expresan por cada bolsa de `25 kg` de material virgen. El material de segunda, tanto recuperado internamente como comprado, no aumenta esta base de dosificación.

La receta debe conservar un dato conceptual equivalente a `dosis_g_por_25kg_virgen`. El nombre físico de columna pertenece a la Tech Spec, pero su semántica no puede cambiar. El requerimiento absoluto se obtiene así:

`colorante_plan_kg = (kg_virgen_base / 25.000) × (dosis_g_por_25kg_virgen / 1000)`

Ejemplo: `70.000 kg` de virgen con una dosis de `500 g/25 kg virgen` requieren `1.400 kg` de colorante. Los `28.000 kg` de material recuperado del mismo lote no cambian ese resultado. Calcular sobre `98 kg` de mezcla daría `1.960 kg`, y calcular sobre una `meta_kg` de `100 kg` daría `2.000 kg`; ambos son incorrectos.

Si una receta posee más de una línea virgen, debe declarar cuáles componen `kg_virgen_base`; no se infiere por texto libre ni se usa automáticamente el peso total del lote. Una cantidad parcial de bolsa escala proporcionalmente.

Para planificar, `kg_virgen_base` es la cantidad absoluta de virgen que la revisión congelada manda preparar, después de las reglas explícitas de composición o merma que correspondan. Al ejecutar la premezcla se conservan por separado los kg de virgen realmente incorporados y la desviación frente al plan; nunca se recalcula el histórico desde el peso final de piezas buenas.

La dosis de receta, la cantidad absoluta planificada, la cantidad pesada/emitida y la cantidad realmente incorporada son datos diferentes. No deben compartir un único campo ambiguo llamado `gramos`.

### 7.5. Contradicciones actuales que requieren refactor

La regla validada no coincide con la implementación existente:

1. `RecetaColorNormalizada.gr_por_kg` expresa gramos por kg de producto y `to_dict(meta_kg)` multiplica por la meta total.
2. `_aprender_de_op` calcula `gramos / lote.meta_kg` y promedia muestras. Con material de segunda, aprende una dosis distinta de la receta real.
3. Una observación histórica puede servir como sugerencia o alerta, pero no debe modificar silenciosamente una receta aprobada y versionada.
4. El frontend consulta `obtenerRecetaColor` con `color_id`, mientras el endpoint vigente exige `color_produccion_id`.

US-010B debe reemplazar esa semántica por una base explícita de virgen y separar al menos: dosis maestra, cantidad planificada, cantidad emitida y cantidad incorporada. Los nombres de tablas, migración y compatibilidad pertenecen a `TS-010B`.

### 7.6. Fracciones y aditivos

La suma `1.0` de `SeCompone.fraccion` puede representar solo la mezcla de resinas, mientras pigmentos y aditivos se agregan aparte. El sistema debe declarar qué componentes participan en cada base de cálculo; no puede exigir que todas las líneas sumen `1.0` y simultáneamente añadir otras cantidades sin explicarlo.

Los colorantes usan la base validada de `25 kg` de virgen. Un aditivo solo usa esa misma base cuando su línea de receta lo declara explícitamente; no se supone por pertenecer al mismo catálogo.

El balance de masa de la premezcla pertenece a esta historia; el balance de la transformación por inyección o soplado pertenece a US-010C. B debe conservar el desglose planificado y real que C necesitará.

## 8. Invariantes

1. Planificado, reservado, emitido, devuelto y consumido son cantidades distintas.
2. Una reserva no reduce existencia física ni mueve el lote.
3. Una emisión mueve cantidad física, pero no la declara consumida.
4. Solo puede reservarse o emitirse material `LIBERADO`, sin retención y en ubicación compatible.
5. La coincidencia se realiza por identidad de material, no por nombre visible.
6. No se permite sustitución libre. Toda sustitución requiere regla o revisión autorizada, motivo y snapshot.
7. Una reserva puede distribuir un requerimiento entre varios lotes físicos.
8. Un lote físico puede abastecer varias órdenes solo con cantidades no superpuestas.
9. La suma de reservas activas no puede exceder la cantidad reservable del lote.
10. La confirmación de reservas múltiples es atómica: se confirman todas o ninguna.
11. La insuficiencia puede producir una propuesta parcial visible, pero nunca una reserva completa ficticia.
12. Para emitir más de lo reservado primero debe ampliarse la reserva; no existe sobreemisión silenciosa.
13. La cantidad emitida de una reserva no puede superar su saldo reservado no emitido.
14. La devolución no puede superar la cantidad emitida aún no consumida ni devuelta.
15. Material mezclado o cuya identidad se perdió no puede regresar al lote original mediante una devolución simple.
16. Una devolución identificada restaura por defecto el saldo no emitido de la misma reserva; liberarlo para otras OF requiere una acción explícita.
17. Liberar una reserva devuelve a disponibilidad únicamente su saldo no emitido.
18. Cancelar o cerrar una OF no devuelve físicamente material emitido; requiere devolución, transformación o disposición explícita.
19. Reabrir una OF no recrea reservas canceladas.
20. Si Calidad bloquea un lote después de reservarlo, se impiden nuevas emisiones y la reserva queda en incidencia; no se borra.
21. Si el lote ya fue emitido cuando se bloquea, se genera una alerta de contención vinculada a la OF y ubicación actual.
22. Una corrección de recepción no puede reducir el lote por debajo de cantidades reservadas o emitidas sin resolver su impacto.
23. Todo comando confirmado posee clave idempotente; repetirla con el mismo contenido retorna el mismo resultado.
24. Repetir una clave con contenido distinto produce conflicto y no cambia saldos.
25. Los eventos confirmados no se editan ni eliminan; se corrigen mediante eventos compensatorios enlazados.
26. Cantidades de inventario se normalizan a kg con tres decimales; las conversiones conservan precisión suficiente antes del redondeo final.
27. FEFO no se aplica mientras no existan fechas de vencimiento o reanálisis confiables. Una política automática puede usar FIFO u otra estrategia aprobada, pero queda versionada.
28. Una selección manual fuera de la estrategia sugerida registra motivo cuando la política lo exige.
29. Una OF o corrida en estado no habilitado no admite nuevas reservas ni emisiones.
30. Origen y destino de la emisión deben ser ubicaciones activas y compatibles con materias primas/WIP.
31. Todo evento registra actor autenticado, trabajador cuando corresponda, momento, origen, destino, motivo y referencia a OF/corrida.
32. La dosis de colorante se calcula exclusivamente sobre los kg de material virgen declarados como base de dosificación.
33. Agregar material de segunda, tanto recuperado internamente como comprado, no aumenta por sí mismo el requerimiento de colorante.
34. Una emisión continúa sin consumirse hasta que una preparación o una corrida confirme la cantidad realmente incorporada.
35. Toda premezcla confirmada crea un `LoteMezclaPreparada` aunque pase inmediatamente a máquina, y declara genealogía `EXACTA` o `CONJUNTO_CANDIDATOS`.
36. Después de confirmar la premezcla, sus inputs no pueden devolverse ni reasignarse como lotes originales separados.
37. Una genealogía candidata incluye todas las recepciones/proveedores plausibles y nunca asigna cantidades o porcentajes no observados.
38. Una consulta de impacto sobre cualquiera de los candidatos alcanza la premezcla y sus salidas hasta que exista evidencia que descarte esa relación.

## 9. Flujo Funcional

### 9.1. Generar requerimientos

1. Recibir una OF `LIBERADA` y la revisión técnica congelada por US-010P.
2. Verificar la receta, sus bases de dosificación, ciclos, salidas y kg derivados.
3. Resolver cada línea a cantidad absoluta y unidad base, o reutilizar el resultado idempotente de la liberación.
4. Rechazar fórmulas ambiguas, materiales inactivos o cantidades no positivas.
5. Mostrar plan por material y diferencia contra reservas existentes.
6. No habilitar propuesta o confirmación de reserva para una OF `BORRADOR` o `PROGRAMADA`.

### 9.2. Proponer lotes

1. Consultar cantidades disponibles compatibles.
2. Aplicar una política versionada o selección manual autorizada.
3. Excluir estados y retenciones incompatibles.
4. Mostrar lote interno, proveedor, estado del lote externo, ubicación, disponible y cantidad propuesta.
5. Mostrar faltante explícito si no existe saldo suficiente.

### 9.3. Confirmar reserva

1. Validar nuevamente saldos y versiones dentro de una transacción.
2. Confirmar todas las líneas o rechazar la operación completa.
3. Registrar actor, política/selección, cantidades y clave idempotente.
4. Actualizar la proyección disponible sin cambiar existencia física.

### 9.4. Emitir a Producción

1. Escanear o seleccionar el lote reservado.
2. Registrar cantidad medida, unidad original y balanza cuando exista.
3. Seleccionar destino compatible de preparación o máquina.
4. Validar saldo reservado, Calidad, retenciones y estado de la OF.
5. Registrar movimiento físico y vínculo con requerimiento/reserva.
6. Mantener la cantidad como emitida no consumida hasta una devolución, una `PreparacionMezcla` o una transformación directa confirmada por US-010C.

### 9.5. Confirmar premezcla

1. Seleccionar las emisiones y cantidades reales incorporadas; si la tolva ya perdió esa distinción, seleccionar de forma conservadora todas las emisiones/recepciones candidatas.
2. Registrar trabajador, momento, tolva, ubicación de preparación, balanza cuando aplique y revisión de receta.
3. Confirmar atómicamente el consumo de los inputs y la creación de un `LoteMezclaPreparada`.
4. Registrar la cantidad resultante y su método de determinación (`MEDIDA` o `DERIVADA`); una diferencia no se oculta y queda pendiente de conciliación según política.
5. Registrar `EXACTA` con cantidades por origen o `CONJUNTO_CANDIDATOS` con todos los orígenes plausibles y sin cantidades inventadas.
6. Mover el WIP a almacenamiento temporal o alimentación de máquina sin declararlo consumido por la corrida.

### 9.6. Devolver material identificado

1. Seleccionar una emisión con saldo no consumido.
2. Confirmar que el material conserva identidad y aptitud.
3. Registrar cantidad, origen de Producción y destino de materias primas.
4. Restaurar la cantidad al saldo no emitido de la misma reserva; liberarla para otras OF requiere una acción explícita.
5. Si el material está mezclado, contaminado o sin identidad, derivar a premezcla/WIP, bloqueo o disposición; no devolver al lote original.

### 9.7. Liberar o cancelar reserva

1. Calcular saldo reservado aún no emitido.
2. Registrar liberación con motivo y actor.
3. Devolver ese saldo a disponibilidad.
4. Mantener emitido, devuelto y eventos históricos sin alteración.

## 10. Dataset ATDD Sintético

Este dataset no pretende ser la configuración real de EnvaPerú.

### 10.1. Lote de producción y requerimientos

| Dato | Valor de prueba |
|---|---|
| OF | `OF-B-TEST-001` |
| Lote producción | `LP-B-ROJO-001` |
| Revisión receta | `REC-TEST-R1` |
| PP virgen | `MAT-PP-V`, `70.000 kg` |
| PP recuperado/comprado | `MAT-PP-R`, `28.000 kg` |
| Dosis masterbatch rojo | `MAT-MB-R`, `500 g/25 kg virgen` |
| Masterbatch rojo calculado | `MAT-MB-R`, `1.400 kg` |
| Lote de premezcla esperado | `LMP-B-ROJO-001`, `99.400 kg` derivados, sin pérdida en el fixture base |

### 10.2. Lotes físicos

| Lote material | Material | Físico | Reservado previo | Disponible | Calidad | Retención | Ubicación |
|---|---|---:|---:|---:|---|---|---|
| `LM-PP-A` | `MAT-PP-V` | `50.000` | `0.000` | `50.000` | `LIBERADO` | No | `UBI-MP-A` |
| `LM-PP-B` | `MAT-PP-V` | `40.000` | `0.000` | `40.000` | `LIBERADO` | No | `UBI-MP-A` |
| `LM-PP-BLOQ` | `MAT-PP-V` | `30.000` | `0.000` | `0.000` | `BLOQUEADO` | No | `UBI-MP-B` |
| `LM-R-A` | `MAT-PP-R` | `30.000` | `0.000` | `30.000` | `LIBERADO` | No | `UBI-MP-R` |
| `LM-MB-A` | `MAT-MB-R` | `5.000` | `0.000` | `5.000` | `LIBERADO` | No | `UBI-MP-COLOR` |
| `LM-MB-RET` | `MAT-MB-R` | `10.000` | `0.000` | `0.000` | `LIBERADO` | Sí | `UBI-MP-COLOR` |

### 10.3. Reserva esperada principal

| Requerimiento | Asignación esperada |
|---|---|
| `MAT-PP-V 70.000 kg` | `LM-PP-A 50.000 + LM-PP-B 20.000` |
| `MAT-PP-R 28.000 kg` | `LM-R-A 28.000` |
| `MAT-MB-R 1.400 kg` | `LM-MB-A 1.400` |

El lote bloqueado y el lote retenido nunca participan, aunque tengan existencia física.

## 11. Escenarios ATDD/BDD

### MAT-01: Generar requerimientos desde una receta congelada

**Dado** `LP-B-ROJO-001` con revisión `REC-TEST-R1`  
**Cuando** se genera su plan de materiales  
**Entonces** se crean requerimientos por `70.000`, `28.000` y `1.400 kg`  
**Y** cada línea conserva material, base, unidad, conversión y revisión.

### MAT-02: Calcular colorante solo sobre material virgen

**Dado** una dosis de `500 g/25 kg virgen`  
**Y** una receta con `70.000 kg` de virgen, `28.000 kg` recuperados y `meta_kg = 100.000`  
**Cuando** se genera el requerimiento  
**Entonces** el requerimiento de colorante es `1.400 kg`  
**Y** no se calcula `1.960 kg` sobre la mezcla ni `2.000 kg` sobre `meta_kg`.

### MAT-03: Reservar un requerimiento desde un solo lote

**Dado** `MAT-PP-R` por `28.000 kg` y `LM-R-A` disponible por `30.000 kg`  
**Cuando** se confirma la reserva  
**Entonces** `28.000 kg` quedan reservados para `LP-B-ROJO-001`  
**Y** el físico continúa en `30.000 kg`  
**Y** quedan `2.000 kg` disponibles para otras órdenes.

### MAT-04: Dividir una reserva entre lotes

**Dado** el requerimiento de `MAT-PP-V` por `70.000 kg`  
**Cuando** se confirma la asignación principal  
**Entonces** se reservan `50.000 kg` de `LM-PP-A` y `20.000 kg` de `LM-PP-B`  
**Y** ambos aportes quedan vinculados al mismo requerimiento.

### MAT-05: Impedir reservar un lote no liberado

**Dado** `LM-PP-BLOQ` con `30.000 kg` físicos y estado `BLOQUEADO`  
**Cuando** se intenta incluirlo en una reserva  
**Entonces** la operación se rechaza  
**Y** ninguna cantidad cambia.

### MAT-06: Impedir reservar un lote retenido

**Dado** `LM-MB-RET` liberado por Calidad pero con retención documental  
**Cuando** se intenta reservarlo  
**Entonces** la operación se rechaza  
**Y** Calidad `LIBERADO` no oculta la retención.

### MAT-07: Mostrar faltante sin inventar stock

**Dado** un requerimiento por `100.000 kg` y solo `90.000 kg` reservables  
**Cuando** se solicita una propuesta  
**Entonces** se muestran `90.000 kg` asignables y `10.000 kg` faltantes  
**Y** no se confirma una reserva completa ficticia.

### MAT-08: Confirmar reservas de forma atómica

**Dado** una propuesta para las tres líneas del dataset  
**Y** que otro proceso consume la disponibilidad de `LM-MB-A` antes de confirmar  
**Cuando** se confirma la propuesta completa  
**Entonces** se rechaza toda la operación  
**Y** tampoco quedan reservadas las líneas de PP.

### MAT-09: Evitar doble reserva concurrente

**Dado** `LM-PP-B` con `40.000 kg` disponibles  
**Cuando** dos órdenes intentan reservar simultáneamente `30.000 kg` cada una  
**Entonces** como máximo una reserva obtiene `30.000 kg`  
**Y** el saldo nunca queda negativo ni sobrecomprometido.

### MAT-10: Reintento idempotente de reserva

**Dado** que `RSV-TEST-001` confirmó la asignación principal  
**Cuando** se repite la misma solicitud con la misma clave y contenido  
**Entonces** se retorna la reserva original  
**Y** no se duplica ninguna cantidad.

### MAT-11: Conflicto de clave de reserva

**Dado** que `RSV-TEST-001` ya fue usada  
**Cuando** se repite con cantidades distintas  
**Entonces** se responde conflicto  
**Y** se conserva el resultado original.

### MAT-12: Reservar no mueve ni consume

**Dado** la reserva confirmada de `LM-R-A` por `28.000 kg`  
**Cuando** se consulta el lote  
**Entonces** conserva `30.000 kg` físicos en su ubicación  
**Y** muestra `28.000 kg` reservados y `2.000 kg` disponibles  
**Y** su consumo continúa en `0.000 kg`.

### MAT-13: Emitir una cantidad reservada

**Dado** `20.000 kg` reservados de `LM-PP-B`  
**Cuando** Almacén emite `20.000 kg` hacia `UBI-PROD-PREP`  
**Entonces** se registra origen, destino, lote, OF, actor y cantidad<br>
**Y** esa cantidad queda emitida no consumida para `LP-B-ROJO-001`.

### MAT-14: Impedir emitir más de lo reservado

**Dado** `20.000 kg` reservados y no emitidos de `LM-PP-B`  
**Cuando** se intenta emitir `21.000 kg`  
**Entonces** se rechaza la emisión completa  
**Y** primero debe ampliarse la reserva.

### MAT-15: La emisión no demuestra consumo

**Dado** `20.000 kg` emitidos a preparación  
**Y** que todavía no se confirmó una premezcla ni una corrida  
**Cuando** se consulta el avance de materiales  
**Entonces** muestra `20.000 kg` emitidos y `0.000 kg` consumidos  
**Y** ninguna diferencia calculada sustituye la confirmación de una transformación.

### MAT-16: Devolver material identificado no consumido

**Dado** `20.000 kg` emitidos de `LM-PP-B`  
**Y** que `2.000 kg` permanecen identificados, no mezclados y aptos  
**Cuando** se confirma su devolución a una ubicación compatible  
**Entonces** quedan `18.000 kg` emitidos netos  
**Y** `2.000 kg` regresan como saldo reservado no emitido de la misma OF<br>
**Y** no quedan disponibles para otra orden hasta liberar expresamente esa reserva.

### MAT-17: Impedir devolver una mezcla como lote original

**Dado** cantidades de dos lotes ya mezcladas físicamente  
**Cuando** se intenta devolverlas como si siguieran separadas  
**Entonces** se rechaza la devolución simple  
**Y** se exige identificar el `LoteMezclaPreparada` o registrar su disposición.

### MAT-18: Liberar el saldo no emitido

**Dado** una reserva de `20.000 kg` con `12.000 kg` emitidos  
**Cuando** se libera la reserva restante  
**Entonces** solo `8.000 kg` vuelven a disponibilidad  
**Y** los `12.000 kg` emitidos permanecen asignados y visibles.

### MAT-19: Cancelar una OF no devuelve material físicamente

**Dado** una OF con reservas no emitidas y material ya emitido<br>
**Cuando** se cancela la OF<br>
**Entonces** se liberan las reservas no emitidas  
**Y** el material emitido queda pendiente de devolución, transformación o disposición explícita.

### MAT-20: Bloqueo de Calidad posterior a la reserva

**Dado** un lote liberado con reserva activa  
**Cuando** Calidad bloquea su cantidad antes de emitirla  
**Entonces** se impiden nuevas emisiones  
**Y** la reserva queda en incidencia con vínculo al evento de bloqueo.

### MAT-21: Contener material bloqueado después de emitir

**Dado** material ya emitido a Producción  
**Cuando** su lote de origen pasa a `BLOQUEADO`  
**Entonces** se genera una alerta de contención para la OF y ubicación actual<br>
**Y** no se borra ni devuelve automáticamente la emisión.

### MAT-22: Preservar una revisión de receta

**Dado** reservas creadas con `REC-TEST-R1`  
**Cuando** se publica `REC-TEST-R2`  
**Entonces** las reservas existentes conservan R1  
**Y** adoptar R2 requiere reconciliar faltantes y excedentes mediante eventos explícitos.

### MAT-23: Impedir sustitución por nombre parecido

**Dado** un requerimiento para `MAT-PP-V`  
**Cuando** se selecciona otro material con descripción similar pero identidad distinta  
**Entonces** se rechaza la selección  
**Y** solo una sustitución autorizada y registrada puede cambiar la receta aplicable.

### MAT-24: Convertir gramos a kg con base explícita

**Dado** un requerimiento resuelto de `2000 g`  
**Cuando** se normaliza para inventario  
**Entonces** se reserva `2.000 kg`  
**Y** se conservan `2000 g`, la base y la conversión usada.

### MAT-25: No aplicar FEFO sin fechas confiables

**Dado** que los lotes no poseen vencimiento ni reanálisis configurado  
**Cuando** una política automática propone lotes  
**Entonces** no afirma aplicar FEFO  
**Y** registra la estrategia realmente configurada para la propuesta.

### MAT-26: Impedir emisión a ubicación incompatible

**Dado** material reservado de `LM-PP-A`  
**Cuando** se intenta emitirlo directamente a una ubicación de `PIEZA_COLOR`  
**Entonces** se rechaza el movimiento  
**Y** no cambia la reserva ni la ubicación.

### MAT-27: Corregir sin sobrescribir eventos

**Dado** una emisión confirmada con cantidad equivocada  
**Cuando** un actor autorizado corrige el hecho  
**Entonces** se registra un evento compensatorio enlazado  
**Y** la emisión original continúa consultable.

### MAT-28: Consultar trazabilidad de preparación

**Dado** la reserva, emisiones y premezcla del dataset  
**Cuando** se consulta `LP-B-ROJO-001`  
**Entonces** se muestran receta R1, base de `25 kg virgen`, requerimientos, lotes de origen, reservas, emisiones, premezcla, devoluciones e incidencias  
**Y** se distingue el consumo de inputs en preparación del consumo posterior del WIP en máquina.

### MAT-29: Crear una premezcla con genealogía exacta

**Dado** emisiones identificadas por `70.000 kg` de `MAT-PP-V`, `28.000 kg` de `MAT-PP-R` y `1.400 kg` de `MAT-MB-R`  
**Cuando** el trabajador confirma que esas cantidades se incorporaron a una premezcla  
**Entonces** se consumen mediante una única `PreparacionMezcla` atómica  
**Y** se crea `LMP-B-ROJO-001` por `99.400 kg` derivados en el fixture sin pérdida  
**Y** el nuevo lote enlaza cada cantidad con su lote físico de origen  
**Y** el WIP permanece no consumido por máquina.

### MAT-30: Rechazar una receta legacy sin base de dosificación

**Dado** un registro legacy que solo indica `500 gramos por bolsa`  
**Y** no permite demostrar que la bolsa corresponde a `25 kg` de virgen  
**Cuando** se intenta generar el requerimiento  
**Entonces** se rechaza con `FORMULA_NO_RESOLUBLE`  
**Y** no se interpreta `500 g` como cantidad total, como `g/kg` ni como cero.

### MAT-31: Conservar proveedores candidatos después de mezclar en tolva

**Dado** bolsas compatibles del mismo material recibidas de `PROV-A` y `PROV-B`  
**Y** fueron incorporadas a la misma tolva sin registrar qué bolsa aportó a cada salida  
**Cuando** se confirma la mezcla preparada que sale hacia la máquina  
**Entonces** se crea un `LoteMezclaPreparada` con genealogía `CONJUNTO_CANDIDATOS`  
**Y** conserva `PROV-A`, `PROV-B` y sus recepciones plausibles  
**Y** no asigna pesos ni porcentajes individuales inventados  
**Y** una consulta de impacto de cualquiera de ambos proveedores incluye la mezcla y sus salidas.

## 12. Resultados de Interfaz Esperados

### 12.1. Preparación de materiales por lote de producción

Debe permitir comparar por material:

- planificado;
- reservado;
- emitido;
- devuelto;
- consumido en preparación y saldo del WIP resultante;
- consumido en máquina confirmado por US-010C;
- faltante o exceso;
- lotes físicos aportantes y estado actual.

### 12.2. Selección de lotes

Debe mostrar solo candidatos compatibles y explicar por qué otros no pueden utilizarse: Calidad, retención, ubicación, saldo, material o estado de OF.

### 12.3. Emisión y devolución

Debe admitir escaneo/selección de lote, cantidad medida, origen, destino y actor. Los errores de saldo o concurrencia deben conservar lo capturado para corregir sin duplicar el evento.

### 12.4. Confirmación de premezcla

Debe permitir seleccionar únicamente emisiones con saldo, capturar cantidades incorporadas, identificar la tanda y mostrar el `LoteMezclaPreparada` resultante. La interfaz debe diferenciar visualmente inputs todavía separables, inputs ya consumidos en preparación y WIP pendiente de entrar a máquina.

## 13. Errores Funcionales

| Código | Significado |
|---|---|
| `FORMULA_NO_RESOLUBLE` | Una línea no puede convertirse a cantidad absoluta. |
| `MATERIAL_NO_COINCIDE` | El lote pertenece a otra definición sin sustitución válida. |
| `LOTE_NO_DISPONIBLE` | Calidad, retención, ubicación o saldo impiden reservar. |
| `SALDO_CAMBIO` | La versión cambió antes de confirmar. |
| `RESERVA_INSUFICIENTE` | Se intenta emitir más que el saldo reservado. |
| `DESTINO_INCOMPATIBLE` | La ubicación no admite material/WIP. |
| `IDENTIDAD_NO_PRESERVADA` | El material no puede devolverse al lote original. |
| `BASE_DOSIFICACION_INVALIDA` | La dosis no declara o contradice la base de `25 kg` de virgen. |
| `INPUT_MEZCLA_NO_DISPONIBLE` | La cantidad a incorporar no está emitida o ya fue devuelta/consumida. |
| `OF_NO_HABILITADA` | El estado de OF/corrida no permite la acción. |
| `CLAVE_REUTILIZADA` | La clave idempotente ya existe con otro contenido. |

Los nombres HTTP y la estructura de respuesta pertenecen a la futura Tech Spec.

## 14. Decisiones Validadas y Preguntas Operativas

Estas respuestas refinan el flujo, pero no impiden probar desde ahora reservas, saldos, idempotencia y concurrencia con fixtures.

### 14.1. Decisiones validadas al 2026-07-21

1. **Existe premezcla:** junta materias primas, colorante y aditivos aplicables; el WIP observable es lo que sale de la tolva listo para la máquina.
2. **Base de colorantes:** la dosis se expresa en gramos por cada bolsa de `25 kg` de material virgen.
3. **Procedencia candidata:** si la tolva mezcla bolsas de varios proveedores sin cantidades por origen, v1 conserva el conjunto de candidatos y declara que la genealogía no es exacta.

Estas decisiones ya son reglas de aceptación. No deben reabrirse implícitamente en la Tech Spec ni sustituirse por el comportamiento actual de `gr_por_kg`.

### 14.2. Preguntas todavía pendientes

1. ¿Quién solicita y quién confirma una reserva: Planificación, Almacén o Producción?
2. ¿La selección usual es manual, FIFO por recepción u otra regla?
3. ¿Se permite reservar una cantidad de contingencia superior al plan? ¿Con qué autorización?
4. ¿Cuántas bolsas suelen formar una tanda y cómo se identifica físicamente la salida de la tolva?
5. US-010L fija que todo material incorporado —resina, recuperado,
   masterbatch/pigmento o aditivo— debe conservar cantidad real medida o una
   unidad completa previamente verificada. Quedan por levantar balanza, rango,
   resolución, método y tolerancia por componente; la balanza de recepción de
   segunda no se supone automáticamente como balanza de mezcla.
6. ¿Qué condiciones permiten devolver material emitido al lote original?
7. ¿Qué ocurre con reservas, material emitido y premezcla cuando una OF se pausa, cambia de color, se cancela o se reabre?
8. ¿Qué capacidades puede ejecutar y aprobar cada función operativa?

Las respuestas pendientes refinan roles, ubicaciones, estados y ergonomía. No impiden comenzar el TDD del cálculo validado, reservas, emisiones y genealogía mínima de premezcla con fixtures. Deben resolverse antes del piloto y ninguna se convertirá silenciosamente en una constante técnica.

## 15. Estrategia de Pruebas y TDD

| Nivel | Responsabilidad | Escenarios principales |
|---|---|---|
| Dominio unitario | cálculos de saldo, dosificación, conversiones, estados, devolución y reconciliación | MAT-01, MAT-02, MAT-03, MAT-07, MAT-12, MAT-14, MAT-16, MAT-18, MAT-24, MAT-25, MAT-30 |
| Integración con BD | atomicidad, concurrencia, idempotencia, eventos, premezcla, genealogía candidata y proyecciones | MAT-04, MAT-08, MAT-09, MAT-10, MAT-11, MAT-13, MAT-19, MAT-20, MAT-21, MAT-27, MAT-29, MAT-31 |
| Contrato A-B | lectura de disponibilidad, rechazo por estado/retención y versiones | MAT-05, MAT-06, MAT-08, MAT-20, MAT-26 |
| Contrato P-B | aceptar solo OF liberada, revisión congelada e idempotencia de requerimientos | MAT-01, MAT-22 y MAT-30 |
| Interfaz | plan contra reservas, picking, emisión, premezcla, nivel de genealogía, devolución e incidencias | MAT-07, MAT-13, MAT-14, MAT-16, MAT-20, MAT-28, MAT-29, MAT-31 |
| E2E A-P-B-C | recibir/liberar material + liberar OF -> reservar/emitir/preparar -> transformar | MAT-03, MAT-13, MAT-15, MAT-28, MAT-29, MAT-31; se habilita cuando A, P y C estén integradas |

Orden TDD recomendado:

1. `MAT-02`: dosis calculada solo sobre material virgen.
2. `MAT-30`: fórmula legacy no resoluble.
3. `MAT-03`: reserva simple sin cambiar existencia física.
4. `MAT-05`: material no liberado no es reservable.
5. `MAT-04`: reserva dividida entre lotes.
6. `MAT-09`: concurrencia sin sobreasignación, contra PostgreSQL.
7. `MAT-13`: emisión de cantidad reservada.
8. `MAT-15`: emisión separada de consumo.
9. `MAT-16`: devolución identificada.
10. `MAT-20`: bloqueo posterior y contención.
11. `MAT-29`: premezcla atómica con genealogía.
12. `MAT-31`: genealogía candidata conservadora cuando la tolva pierde granularidad.
13. `MAT-28`: consulta integrada.

Los tests de dominio pueden iniciar con un repositorio fake contractual. Atomicidad, unicidad y concurrencia solo se consideran cubiertas mediante integración real con PostgreSQL.

## 16. Definición de Preparada para TS-010B

- [x] Se delimitó la dependencia contractual con US-010A sin exigir configuración real de planta.
- [x] Se delimitó la dependencia contractual con US-010P y se permite una OF liberada fixture durante TDD.
- [x] Se separaron plan, reserva, emisión, consumo en preparación, WIP, devolución y consumo en máquina.
- [x] Existe dataset sintético reproducible.
- [x] Existen escenarios de saldo, errores, idempotencia, concurrencia y corrección.
- [x] La línea base TDD del workspace está verde y documentada en US-010A/TE-001.
- [x] Producción confirmó que existe premezcla de resina ya coloreada.
- [x] Producción definió la base de colorantes como gramos por `25 kg` de material virgen.
- [x] Producción definió la salida de tolva como frontera de la mezcla preparada y aceptó procedencia por conjunto de proveedores candidatos cuando no existe detalle exacto.
- [ ] Almacén y Producción revisaron los escenarios `MAT-01` a `MAT-31`.
- [ ] Se acordó el estado mínimo de OF/corrida que habilita reserva y emisión.
- [ ] No quedan decisiones de negocio escondidas en una política técnica.

## 17. Fuera de Alcance

- Registrar demanda de `ProductoTerminado`, explotar su estructura multinivel, netear WIP, calcular faltantes y generar OP/OF/OA; corresponde a US-010P/US-010R.
- Recepcionar, inspeccionar o liberar lotes de proveedor; corresponde a US-010A.
- Confirmar consumo en la máquina, ejecutar la transformación de inyección/soplado o calcular su balance de masa; corresponde a US-010C.
- Crear `LoteSalidaPiezaColor`, registrar producción horaria o merma real; corresponde a US-010C.
- Planificar sus identidades corresponde a [[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]]; pesarlas, materializarlas y etiquetar el resultado corresponde a [[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]].
- Moler ramal/rechazo y crear material recuperado; corresponde a US-010E.
- Definir compras, precios o valorización de inventario.
- Fijar nombres reales de ubicaciones o asignar usuarios reales durante pruebas automatizadas.

## 18. Definición de Terminado

1. Ninguna reserva o emisión puede utilizar cantidad no disponible.
2. Reservas concurrentes no sobreasignan un lote.
3. Planificado, reservado, emitido, consumido en preparación, WIP, devuelto y consumido en máquina se consultan por separado.
4. Toda cantidad queda ligada a material, lote físico, lote de producción y eventos auditables.
5. Las emisiones y devoluciones conservan origen, destino, actor, momento y evidencia de pesaje cuando aplique.
6. Fórmulas ambiguas se rechazan antes de comprometer inventario.
7. Correcciones son compensatorias e idempotentes.
8. Las pruebas de dominio, integración PostgreSQL, contrato e interfaz afectada están verdes.
9. El cálculo de colorante usa los kg de virgen y demuestra que material recuperado o `meta_kg` no alteran la base.
10. Toda premezcla crea un WIP identificable y permite recorrer procedencia exacta o todos los orígenes candidatos, sin inventar cantidades.
11. El E2E A-P-B-C demuestra que una OF liberada genera requerimientos una sola vez y que una cantidad de material liberada se reserva y emite una sola vez, se consume al confirmar la premezcla y el WIP solo se consume en máquina al confirmar la corrida.
12. El vault refleja las decisiones finalmente validadas sobre mezcla y dosificación.

## 19. Evolución del Corte Frontend

Implementado el 2026-07-15 para avanzar la experiencia y el TDD sin fingir persistencia backend:

- rutas canónicas `/materiales/preparaciones` y `/materiales/preparaciones/:numeroOp`, conservando `/ordenes/:numeroOp/materiales` como alias;
- acceso desde el menú de OF y desde la acción de cada orden;
- selector de OF y corrida;
- etapas `Plan -> Reserva -> Emisión -> Premezcla -> Máquina`;
- requerimientos, lotes físicos, Calidad, ubicaciones, emisiones, WIP y genealogía con fixtures de `MAT-02` y `MAT-29`;
- cálculo visible de `70 kg virgen × 500 g / 25 kg = 1.400 kg`;
- navegación responsive para escritorio y móvil.

El adaptador frontend expone una matriz de capacidades. Mientras `apiReady = false`, todo comando que cambie inventario se presenta deshabilitado con candado y nombre accesible `(API pendiente)`. Los datos mock permiten consultar estados futuros, pero no muestran mensajes de confirmación ni simulan persistencia.

Comandos inicialmente bloqueados:

1. Confirmar reserva.
2. Emitir material.
3. Registrar devolución.
4. Confirmar premezcla.

La precarga legacy de pigmentos basada en `meta_kg` también queda bloqueada como `Receta trazable` en el formulario de OF. Solo podrá habilitarse cuando el contrato entregue una revisión aprobada con base `g/25 kg virgen` y cantidad absoluta calculada.

Pruebas frontend incorporadas:

- `MAT-02`: muestra `1.400 kg` y la fórmula basada solo en virgen.
- `MAT-29`: permite inspeccionar `LMP-B-ROJO-001`, sus `99.400 kg` y los lotes aportantes.
- los comandos sin API permanecen deshabilitados.

El mock fue el primer corte visual. El 2026-08-03 el adaptador fue reemplazado
por la API transaccional descrita en [[TS-010B_Reserva_Emision_y_Premezcla_Materiales]]
y [[SCM_Materiales_OF_Reserva_Emision_Premezcla]]. Los fixtures quedan solo para
pruebas de componente; no son la fuente de la vista operativa.

## 20. Evidencia de Implementación Local

- migraciones `f58a6b3c4d21` y `f59b7c4d5e32` aplicadas en PostgreSQL local;
- requerimientos absolutos congelados por corrida y revisión aprobada de receta;
- reserva atómica sobre saldos de apertura del Kardex;
- emisión y devolución como traslados de custodia, sin consumo implícito;
- premezcla como transformación que consume emisiones, crea un lote WIP y
  conserva inputs exactos o el nivel `CONJUNTO_CANDIDATOS`;
- capacidades separadas para generar, reservar, emitir, devolver y confirmar
  premezcla;
- 11 pruebas backend relacionadas verdes, 3 pruebas de la vista verdes y build
  frontend exitoso.

### Límite pendiente de UAT

El incremento usa saldos agregados nacidos por `APERTURA_INICIAL`, porque no
existe Kardex digital legacy. La UAT debe validar actores reales, ubicaciones,
entrega física, criterio para genealogía candidata y ergonomía de la pantalla.
El consumo del WIP en máquina continúa perteneciendo a US-010C.

## 21. Addenda US-010M — frontera con Trabajo de color

US-010M no mueve receta, requerimiento, reserva ni emisión a la cabecera OT.
Esos hechos permanecen ligados a OF/corrida. Cada Trabajo de color referencia
la corrida exacta y, por esa relación, puede resolver el contexto técnico
existente sin duplicar requerimientos al cambiar A → B → A.

Este addendum no incorpora lote preparado almacenable, mezcla experimental,
R1…Rn, una segunda balanza de materiales ni un nuevo consumo físico en máquina.
La atribución de consumo real sigue pendiente del contrato de US-010B/C y no se
infiere desde el estado del Trabajo de color.
