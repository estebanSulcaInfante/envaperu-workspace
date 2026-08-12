---
tipo: user-story
subtipo: historia-hija
estado: lista-para-validacion-operativa
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, almacen, abastecimiento, picking, qr, inventario, armado, mangas, genealogia, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[Inventario_SCM]]"
  - "[[Unidad_Logistica]]"
  - "[[Orden_Armado]]"
  - "[[Registro_Diario]]"
  - "[[Articulo_SCM]]"
  - "[[Ubicacion_Inventario]]"
fecha_creacion: 2026-07-30
fecha_actualizacion: 2026-08-03
---

# US-010H: Abastecimiento Interno, Picking QR y Consumo de Mangas

## 1. Decisión de alcance

Esta historia cubre el flujo físico y documental de las mangas de piezas o WIP
que salen de Almacén para abastecer una OT de Armado. Comienza con la
necesidad derivada de la BOM y la cuota diaria de la OT, y termina cuando las
unidades entregadas fueron consumidas, devueltas o conciliadas.

No reemplaza:

- [[US-010B_Reserva_Emision_Materiales_OP|US-010B]], que abastece resinas,
  colorantes, aditivos y premezclas a Fabricación;
- [[US-010F_Prearmado_y_Armado_Concurrente_Trazable|US-010F]], que confirma
  qué componentes fueron incorporados a cada manga WIP/PT resultante;
- [[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex|US-010I]], que crea
  inventario cuando Almacén recibe por primera vez una manga producida.

La reserva, el picking, el despacho, la recepción en Armado y el consumo son
hechos distintos. Preparar o entregar una manga no demuestra todavía que su
contenido fue incorporado a un producto.

## 2. Historia de usuario

**Como** responsable de Almacén o de Armado  
**Quiero** preparar, despachar, recibir, consumir y devolver por QR las mangas
requeridas por una OT de Armado  
**Para** conservar el saldo, la custodia y la genealogía de las piezas físicas
sin inventar consumos, orígenes ni movimientos.

## 3. Resultado de negocio

Al terminar este flujo, el sistema puede responder:

1. qué pidió cada OT de Armado y con base en qué BOM/cuota;
2. qué mangas concretas reservó y preparó Almacén;
3. quién entregó y quién recibió cada unidad, dónde y cuándo;
4. cuánto se incorporó realmente a cada manga WIP/PT;
5. qué saldo quedó en una manga abierta y si retornó al Almacén;
6. qué unidades candidatas pudieron alimentar una salida cuando se perdió la
   separación física;
7. dónde se encuentra una unidad que aún no fue consumida.

## 4. Actores físicos

| Actor | Responsabilidad observable |
|---|---|
| Planificación / Jefe de Producción | Libera la OA y su cuota; autoriza excepciones de abastecimiento cuando corresponda |
| Responsable de Armado | Inicia la necesidad de la OT, recibe físicamente las mangas y confirma consumos al cerrar las salidas |
| Almacenero de picking | Escanea, selecciona y prepara unidades liberadas |
| Almacenero de despacho | Confirma la salida física desde Almacén |
| Almacenero de recepción de retorno | Recibe y ubica remanentes identificados |
| Calidad | Libera, bloquea o rechaza unidades sin alterar su existencia física |
| Auditoría / Gerencia | Consulta eventos, diferencias, correcciones y genealogía |

Una persona puede asumir más de una función si sus capacidades lo permiten.
Aun así, el sistema registra cada acción y su contexto por separado. La
configuración de roles no se deduce del nombre o cargo del trabajador.

## 5. Lenguaje de dominio

### 5.1. Solicitud de abastecimiento interno

Documento operativo nacido de una OT de Armado y de su snapshot de BOM.
Declara artículos y cantidades requeridas para la cuota diaria. No identifica
por sí solo qué mangas se usarán.

La propuesta inicial se genera automáticamente al crear o recalcular la cuota
de la OT. El responsable puede solicitar su preparación; cualquier diferencia
respecto del requerimiento congelado queda explícita y autorizada.

### 5.2. Línea de abastecimiento

Necesidad por `ArticuloSCM` y unidad de medida. Conserva, como dimensiones
separadas:

- cantidad requerida;
- cantidad reservada;
- cantidad preparada;
- cantidad despachada;
- cantidad recibida por Armado;
- cantidad consumida;
- cantidad retornada;
- saldo pendiente de conciliar.

### 5.3. Asignación de unidad

Vincula una manga concreta con una línea mediante su identidad inmutable y QR
vigente. Una asignación no transforma ni consume el contenido.

### 5.4. Transferencia de custodia

Par de eventos que evita movimientos instantáneos ficticios:

1. Almacén confirma el despacho y la unidad queda en tránsito;
2. Armado confirma la recepción y la unidad queda en su zona de staging.

`ubicacion_actual`, `custodio_actual`, disponibilidad logística y estado de
Calidad son dimensiones diferentes.

### 5.5. Consumo de armado

Cantidad realmente incorporada a una salida de
[[US-010F_Prearmado_y_Armado_Concurrente_Trazable|US-010F]]. Se registra al
ejecutar `CERRAR_MANGA_ARMADO`, no al reservar, preparar, despachar o recibir.

### 5.6. Fraccionamiento

Operación controlada que crea una unidad hija cuando una manga debe dividirse
físicamente. La hija recibe identidad y QR propios; conserva relación con la
unidad madre y no duplica cantidad.

Abrir una manga y consumir solo una parte no obliga a fraccionarla. Si el
remanente continúa dentro del mismo envase, conserva la misma identidad y saldo.

### 5.7. Pool de origen candidato

Conjunto contado de unidades que fueron mezcladas físicamente antes de poder
atribuir su contenido exacto a cada salida. Mantiene todas las procedencias
plausibles N:M sin inventar porcentajes ni cantidades por candidato.

## 6. Flujo normal

1. La OA aprobada y la OT de Armado congelan su cuota, BOM y artículos.
2. Central genera la solicitud con las cantidades teóricas necesarias.
3. El responsable solicita abastecimiento.
4. Central reserva saldo libre por artículo sin crear movimiento de Kardex.
5. Almacén recibe una lista sugerida de mangas elegibles.
6. El almacenero escanea cada QR y el servidor valida identidad, saldo,
   ubicación, Calidad, compatibilidad y reserva concurrente.
7. Almacén cierra el picking y confirma el despacho.
8. Las mangas quedan en tránsito y dejan de estar disponibles en Almacén.
9. Armado escanea y confirma la recepción en `MESA_ARMADO`, zona de staging
   ubicada dentro de la propia fábrica.
10. Durante la operación, las mangas quedan asignadas a la OT y pueden abrirse
    para consumo parcial.
11. Al cerrar cada manga de salida, Armado confirma las unidades de origen y
    cantidades incorporadas.
12. El comando central consume saldo y crea genealogía hacia la manga WIP/PT
    resultante en una sola transacción idempotente.
13. Los remanentes identificados se solicitan en devolución.
14. Armado confirma su salida de retorno y Almacén confirma recepción y
    ubicación.
15. La solicitud se cierra cuando no quedan cantidades entregadas sin consumir,
    devolver o conciliar.

## 7. Estados

### 7.1. Solicitud de abastecimiento

```text
BORRADOR
  -> SOLICITADA
  -> EN_PREPARACION
  -> LISTA
  -> DESPACHADA
  -> RECIBIDA
  -> CERRADA
```

Estados laterales: `CANCELADA` e `INCIDENCIA`.

Una solicitud puede avanzar parcialmente. Su estado agregado no reemplaza los
saldos de cada línea o unidad.

### 7.2. Custodia logística de una unidad

```text
DISPONIBLE_ALMACEN
  -> RESERVADA
  -> EN_PICKING
  -> EN_TRANSITO_PRODUCCION
  -> EN_STAGING_ARMADO
  -> ABIERTA_EN_CONSUMO
  -> CONSUMIDA
```

Retorno:

```text
EN_STAGING_ARMADO / ABIERTA_EN_CONSUMO
  -> PENDIENTE_RETORNO
  -> EN_TRANSITO_ALMACEN
  -> RECIBIDA_RETORNO
  -> DISPONIBLE_ALMACEN
```

Calidad `PENDIENTE`, `LIBERADA`, `BLOQUEADA` o `RECHAZADA` es ortogonal a
estos estados.

En el piloto, `EN_STAGING_ARMADO` corresponde físicamente a `MESA_ARMADO`.

## 8. Reglas e invariantes

1. Solo una unidad inventariada, con saldo positivo y Calidad `LIBERADA` puede
   reservarse para consumo normal.
2. La reserva reduce saldo libre, pero no mueve existencia física ni Kardex.
3. Un QR identifica una unidad; no contiene la verdad completa del movimiento.
4. Toda mutación se valida en la API central. El dispositivo móvil no decide
   disponibilidad, compatibilidad ni permisos.
5. Una unidad no puede asignarse simultáneamente a dos OTs. Reasignarla exige
   liberar o transferir explícitamente su compromiso.
6. El despacho y la recepción son eventos separados. Una manga en tránsito no
   está disponible ni en origen ni para consumo en destino.
7. Entregar una manga no la consume.
8. El consumo ocurre exclusivamente contra una confirmación de salida de
   Armado.
9. Una salida puede consumir varias mangas y una manga puede alimentar varias
   salidas mediante consumos parciales.
10. La suma de consumos, devoluciones, ajustes compensatorios y saldo no puede
    superar la cantidad recibida de una unidad.
11. No se permiten saldos negativos.
12. La sustitución de un artículo BOM no es una decisión de picking. Exige una
    regla o autorización explícita y preserva el artículo esperado y el usado.
13. Si se divide físicamente una manga, cada fragmento almacenable debe poseer
    una identidad distinta y genealogía hacia la unidad madre.
14. Si se mezclan físicamente unidades y se pierde la atribución exacta, se
    declara procedencia candidata; nunca se reparte una cantidad ficticia entre
    proveedores, lotes u OTs.
15. Los registros legacy sin QR pueden ingresar únicamente mediante conteo
    inicial gobernado `LEGACY_SIN_ORIGEN`, con actor, motivo, cantidad y
    Calidad. Su saldo es finito.
16. Una unidad bloqueada después de reservarse se retira del picking y genera
    incidencia. Si ya fue despachada, queda contenida y no puede consumirse
    hasta resolver Calidad.
17. Cancelar una solicitud libera lo no despachado. No devuelve
    automáticamente unidades que ya cambiaron de custodia.
18. Toda corrección confirmada es append-only mediante reversa o compensación;
    no edita ni elimina el evento original.
19. Cada comando acepta clave de idempotencia. Un replay devuelve el resultado
    original sin duplicar reserva, movimiento, consumo o devolución.
20. Almacenes y ubicaciones de staging deben ser compatibles con la clase de
    artículo; el sistema rechaza destinos incompatibles.
21. Los cuerpos acreditados en línea mediante `SaldoWIPSalida` pertenecen al
    contrato de US-010F y no se convierten artificialmente en un picking de
    Almacén.
22. En este corte la operación es conectada. Sin central disponible no se
    confirma una mutación de inventario.
23. Durante el piloto, una misma persona puede confirmar despacho y recepción
    si posee ambas capacidades. Los dos eventos, momentos y contextos se
    conservan por separado.
24. Un retiro no solicitado exige motivo y aprobación del Jefe de Producción
    antes de reservar o despachar.

## 9. Criterios de selección

Central propone unidades en este orden inicial:

1. artículo y variante exactos;
2. Calidad `LIBERADA`;
3. ubicación compatible y saldo libre;
4. fecha de recepción más antigua primero;
5. menor cantidad de mangas abiertas compatible con la necesidad;
6. desempate por código estable.

La sugerencia no sustituye el escaneo ni la confirmación humana. FEFO podrá
reemplazar el criterio temporal cuando el artículo use caducidad o fecha de
reinspección.

Por defecto se despachan mangas completas. Un fraccionamiento se admite solo
como operación explícita con nueva etiqueta cuando la división física sea
necesaria.

## 10. Genealogía al cerrar una manga de salida

### 10.1. Exacta

Armado mantiene separadas las mangas de entrada y confirma cuánto aportó cada
una. La suma exacta coincide con el consumo registrado para el componente.

### 10.2. Conjunto de candidatos

Las entradas se mezclaron en una zona o recipiente contado y ya no puede
conocerse qué fracción alimentó cada salida. La confirmación enlaza el pool y
todas sus unidades candidatas. El saldo total del pool sí se controla; las
cantidades individuales por candidato se reportan como desconocidas.

### 10.3. Legacy sin origen

Se permite durante la migración desde una apertura contada y visible como
legacy. No genera una OF, OT, proveedor o lote ficticios.

## 11. Devoluciones y remanentes

1. El remanente que conserva envase e identidad mantiene su QR original y saldo.
2. Armado declara cantidad restante antes de solicitar retorno.
3. Almacén vuelve a escanear y confirma ubicación.
4. Una diferencia entre saldo lógico y conteo físico abre incidencia; no se
   corrige silenciosamente.
5. Una manga retornada que ya fue liberada por Calidad conserva esa liberación;
   no pasa por una reinspección automática solo por haber salido a Armado.
6. Si durante la manipulación se reporta daño, contaminación u otra incidencia,
   la unidad se bloquea y Calidad decide su disposición.
7. La cantidad del remanente se confirma mediante conteo y se acompaña de
   pesaje como control físico. El conteo es la cantidad autoritativa; el peso no
   infiere unidades.
8. Si el remanente fue reenvasado, se usa fraccionamiento y nueva etiqueta; no
   se reutiliza el QR de otra unidad.

## 12. Permisos futuros

| Capacidad | Acción |
|---|---|
| `ABASTECIMIENTO_VER` | Consultar solicitudes, unidades, saldos y eventos |
| `ABASTECIMIENTO_SOLICITAR` | Solicitar preparación desde una OT de Armado |
| `PICKING_PREPARAR` | Escanear y cerrar la preparación |
| `PICKING_DESPACHAR` | Confirmar salida física desde Almacén |
| `ABASTECIMIENTO_RECIBIR` | Confirmar recepción en Armado |
| `ABASTECIMIENTO_DEVOLVER` | Iniciar retorno de un remanente |
| `ABASTECIMIENTO_RETORNO_RECIBIR` | Recibir y ubicar el retorno |
| `UNIDAD_LOGISTICA_FRACCIONAR` | Crear unidad hija y nueva etiqueta |
| `GENEALOGIA_CANDIDATA_CONFIRMAR` | Declarar pool candidato contado |
| `ABASTECIMIENTO_CORREGIR_SOLICITAR` | Solicitar compensación |
| `ABASTECIMIENTO_CORREGIR_APROBAR` | Aprobar compensación segregada |
| `ABASTECIMIENTO_EMERGENCIA_APROBAR` | Autorizar un retiro no solicitado con motivo |

Las capacidades se asignarán a roles configurables. La historia no asigna
personas ni confía en controles visuales del frontend.

## 13. Escenarios ATDD

### Escenario 1: reservar no mueve Kardex

- **Dado** un artículo con 100 unidades físicas, 0 reservadas y Calidad liberada
- **Cuando** una OT reserva 30 unidades
- **Entonces** existencia física sigue en 100, reservada es 30 y libre es 70
- **Y** no existe movimiento de salida.

### Escenario 2: picking exacto por QR

- **Dado** dos mangas liberadas del mismo `PiezaColor`
- **Cuando** Almacén escanea una manga sugerida
- **Entonces** la asignación conserva el ID exacto, cantidad disponible,
  ubicación, lote/OT de origen y etiqueta vigente.

### Escenario 3: rechazar una variante equivocada

- **Dado** una línea que requiere el cuerpo amarillo
- **Cuando** se escanea una manga del cuerpo fucsia
- **Entonces** el servidor rechaza el picking y no cambia reserva ni custodia.

### Escenario 4: transferencia en dos pasos

- **Dado** una manga preparada
- **Cuando** Almacén confirma despacho
- **Entonces** queda en tránsito y no disponible
- **Y cuando** Armado escanea y recibe
- **Entonces** queda bajo custodia de Armado en su staging.

### Escenario 5: entregar no consume

- **Dado** una manga con 50 piezas recibida por Armado
- **Cuando** todavía no se cerró una manga de salida
- **Entonces** su saldo consumido es cero y conserva 50 piezas.

### Escenario 6: consumo exacto parcial

- **Dado** una manga de entrada con 50 asas
- **Cuando** se cierra una manga PT de 20 baldes y se incorporan 20 asas
- **Entonces** se consumen 20, quedan 30 y la salida enlaza exactamente esa
  manga y cantidad.

### Escenario 7: múltiples orígenes exactos

- **Dado** mangas de entrada A con 8 cuerpos y B con 12 cuerpos
- **Cuando** se cierra una manga PT de 20 unidades
- **Entonces** la salida enlaza A por 8 y B por 12 sin perder sus orígenes.

### Escenario 8: una entrada alimenta varias salidas

- **Dado** una manga de 50 asas
- **Cuando** alimenta salidas PT de 20 y 25 unidades
- **Entonces** ambas genealogías apuntan a la misma entrada por su cantidad
  respectiva y quedan 5 asas.

### Escenario 9: mezcla de orígenes candidatos

- **Dado** tres mangas que fueron volcadas a un recipiente común contado
- **Cuando** se cierra una salida sin poder separar el aporte individual
- **Entonces** la salida enlaza el pool y las tres candidatas
- **Y** no muestra porcentajes ni cantidades inventadas por candidata.

### Escenario 10: devolución del remanente

- **Dado** una manga recibida con saldo de 30 piezas no usadas
- **Cuando** Armado solicita retorno y Almacén lo recibe por QR
- **Entonces** quedan registrados ambos custodios, tránsito, cantidad y nueva
  ubicación
- **Y** conserva la liberación de Calidad previa si no se reportó una
  incidencia
- **Y** el conteo confirmado y el pesaje de control quedan registrados.

### Escenario 11: fraccionamiento físico

- **Dado** una manga de 40 piezas
- **Cuando** Almacén separa físicamente 15 en otro envase
- **Entonces** crea una unidad hija con QR nuevo por 15
- **Y** la madre queda con 25
- **Y** ambas conservan genealogía sin duplicar cantidad.

### Escenario 12: bloqueo de Calidad antes del despacho

- **Dado** una manga reservada
- **Cuando** Calidad la bloquea antes de salir
- **Entonces** no puede despacharse, se abre incidencia y el sistema propone
  otra unidad elegible.

### Escenario 13: bloqueo después del despacho

- **Dado** una manga en staging de Armado
- **Cuando** Calidad la bloquea
- **Entonces** queda físicamente localizada pero no puede consumirse
- **Y** su resolución queda auditada.

### Escenario 14: concurrencia

- **Dado** una manga con 20 unidades libres
- **Cuando** dos OTs intentan reservarla simultáneamente
- **Entonces** solo una asignación se confirma y la otra recibe conflicto con
  saldo actualizado.

### Escenario 15: replay idempotente

- **Dado** un despacho ya confirmado
- **Cuando** el móvil reenvía la misma clave de idempotencia
- **Entonces** obtiene el mismo resultado y no se duplica el movimiento.

### Escenario 16: cancelación con unidades despachadas

- **Dado** una solicitud con 20 unidades sin preparar y 30 ya entregadas
- **Cuando** se cancela
- **Entonces** libera solo las 20 no despachadas
- **Y** exige consumir, retornar o conciliar las 30 bajo custodia de Armado.

### Escenario 17: sustitución no autorizada

- **Dado** una BOM que exige una variante concreta
- **Cuando** Almacén intenta sustituirla por una similar sin autorización
- **Entonces** el servidor rechaza la selección y registra el intento sin
  alterar saldo.

### Escenario 18: central no disponible

- **Dado** el móvil sin conexión con la API central
- **Cuando** el almacenero intenta confirmar un despacho
- **Entonces** la interfaz no declara éxito ni cambia el saldo localmente
- **Y** conserva el escaneo como intento no confirmado.

### Escenario 19: corrección compensatoria

- **Dado** una recepción interna confirmada con cantidad equivocada
- **Cuando** una corrección segregada es aprobada
- **Entonces** se registran reversa/compensación y motivo
- **Y** el evento original permanece consultable.

### Escenario 20: WIP producido en línea

- **Dado** cuerpos de la OT de Fabricación actual acreditados como
  `CREDITO_EN_LINEA_PENDIENTE`
- **Cuando** Armado los usa concurrentemente
- **Entonces** se aplica el contrato `SaldoWIPSalida` de US-010F
- **Y** no se crea un despacho ficticio desde Almacén.

### Escenario 21: retiro de emergencia

- **Dado** una OT que necesita una manga no incluida en su solicitud
- **Cuando** el responsable registra motivo y el Jefe de Producción autoriza
- **Entonces** se crea una ampliación trazable antes del picking
- **Y** no se modifica silenciosamente la BOM ni la solicitud original.

### Escenario 22: misma persona en ambos handoffs

- **Dado** un trabajador con capacidad de despacho y recepción durante el
  piloto
- **Cuando** confirma ambos pasos
- **Entonces** el sistema acepta la transferencia
- **Y** conserva dos eventos con sus momentos, ubicaciones y acción ejecutada.

## 14. Dataset de ejemplo

```text
OA: OA-000025
OT Armado: OT-000141
Fecha operativa: 2026-07-30
Objetivo: 100 Balde Romano 20 L amarillo

BOM por unidad:
- PC-CUERPO-AMARILLO: 1
- PC-ASA-NEGRA: 1

Inventario liberado:
- Manga CUERPO-A: 60 un, Almacén Piezas A-01
- Manga CUERPO-B: 50 un, Almacén Piezas A-02
- Manga ASA-A: 80 un, Almacén Piezas B-01
- Manga ASA-B: 30 un, Almacén Piezas B-02

Picking:
- CUERPO-A 60 + CUERPO-B 40
- ASA-A 80 + ASA-B 20

Salidas PT:
- OA000025-OT000141-M001: 50 PT
- OA000025-OT000141-M002: 50 PT

Remanentes:
- CUERPO-B: 10 un
- ASA-B: 10 un
```

El ejemplo debe demostrar reserva, picking, despacho, recepción, dos cierres de
salida, consumos parciales, genealogía y retorno de ambos remanentes.

## 15. Errores observables

La interfaz debe traducir los rechazos del servidor a mensajes accionables:

- `UNIDAD_NO_ENCONTRADA`: verificar QR o etiqueta reemplazada;
- `ETIQUETA_NO_VIGENTE`: usar la etiqueta actual;
- `CALIDAD_NO_LIBERADA`: seleccionar otra manga o resolver con Calidad;
- `SALDO_INSUFICIENTE`: recalcular o elegir otra unidad;
- `UNIDAD_RESERVADA_POR_OT`: mostrar OT y responsable compatibles con permiso;
- `ARTICULO_INCOMPATIBLE`: indicar esperado y escaneado;
- `UBICACION_INCOMPATIBLE`: elegir staging/almacén permitido;
- `CUSTODIA_NO_CONFIRMADA`: recibir antes de consumir;
- `DIFERENCIA_FISICA`: abrir incidencia y bloquear cierre silencioso;
- `CONFLICTO_CONCURRENCIA`: refrescar selección;
- `CENTRAL_NO_DISPONIBLE`: no declarar la acción confirmada.

## 16. Fuera de alcance

- abastecimiento de materia prima, colorante o premezcla a Fabricación;
- compra y recepción de proveedor;
- consumo directo desde una manga aún no recibida por Almacén, salvo el
  mecanismo explícito de WIP en línea de US-010F;
- optimización avanzada de rutas de picking;
- operación offline con posterior sincronización;
- RFID, voz o robots de almacén;
- despacho a cliente;
- inventar lotes para el stock legacy;
- definir pantallas o tablas definitivas antes de la Tech Spec.

## 17. Dependencias

- US-010R: artículo, BOM, WIP y reglas de empaque.
- US-010P: OA, asignaciones y cuota planificada.
- US-010I: manga recibida, ubicación, saldo y Calidad.
- US-010F: confirmación de salida y consumo genealógico.
- Ubicaciones compatibles para Almacén de Piezas y staging de Armado.
- Roles y capacidades aplicados por el servidor.

## 18. Decisiones operativas validadas el 2026-07-30

1. El staging de Armado se denomina `MESA_ARMADO` y está dentro de la fábrica.
2. Una manga ya liberada no vuelve automáticamente a Calidad por retornar; solo
   una incidencia de manipulación activa bloqueo/revisión.
3. El Jefe de Producción autoriza retiros de emergencia no solicitados.
4. En el piloto, una misma persona puede despachar y recibir si posee ambas
   capacidades; se mantienen dos eventos.
5. El remanente se valida con conteo y pesaje. No requiere doble conteo y el
   peso no reemplaza la cantidad contada.

## 19. Definición de Preparada

- [x] Actor, objetivo y frontera con B/F/I definidos.
- [x] Flujo físico y documental principal descrito.
- [x] Reserva, custodia y consumo separados.
- [x] Consumo parcial, fraccionamiento, mezcla y devolución cubiertos.
- [x] Escenarios principales, errores, concurrencia e idempotencia definidos.
- [x] Dataset de ejemplo reproducible.
- [x] Ubicación real de staging validada como `MESA_ARMADO`.
- [x] Política de Calidad para mangas retornadas validada.
- [x] Excepciones de emergencia y segregación física validadas.
- [ ] Historia aprobada por Producción, Armado y Almacén.

La Tech Spec de US-010H no debe comenzar hasta cerrar estas decisiones
operativas.

Al 2026-08-03 no quedan preguntas funcionales abiertas en la historia. La
única puerta pendiente es la conformidad conjunta de Producción, Armado y
Almacén sobre los escenarios ya redactados, en especial transferencia en dos
pasos, conteo/pesaje del remanente y retiro de emergencia.
