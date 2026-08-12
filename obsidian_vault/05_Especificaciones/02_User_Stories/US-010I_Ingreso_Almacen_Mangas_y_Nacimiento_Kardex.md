---
tipo: user-story
subtipo: historia-hija
estado: implementada-parcial-local-pendiente-uat
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, almacen, manga, qr, recepcion, kardex, inventario, calidad, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
  - "[[Inventario_SCM]]"
  - "[[Ubicacion_Inventario]]"
  - "[[Unidad_Logistica]]"
  - "[[Etiqueta_Manga]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-08-03
---

# US-010I: Ingreso de Mangas a Almacén y Nacimiento de Kardex

## 1. Decisión de alcance

Esta historia formaliza la frontera entre una salida física de
Producción/Armado y una existencia aceptada por Almacén. Una manga pesada y
etiquetada permanece como `PENDIENTE_RECEPCION_ALMACEN`: todavía no es stock,
no posee ubicación de inventario y no genera `MovimientoKardex`.

El inventario nace cuando Almacén escanea un QR vigente en el punto de ingreso,
valida la presencia física y acepta su custodia. La recepción no vuelve a
pesar, contar ni corregir la producción; cualquier discrepancia se rechaza o
queda como incidencia antes de aceptar.

## 2. Historia de usuario

**Como** responsable de Almacén  
**Quiero** recibir por QR las mangas pesadas que entrega Producción  
**Para** crear una sola existencia inventariable, asignarle ubicación y
conservar la separación entre producción física y stock recibido.

## 3. Resultado de negocio

Después de la recepción se puede responder:

1. qué manga concreta ingresó y cuál era su salida, artículo, OF/OA y OT;
2. quién la entregó y quién aceptó custodia;
3. qué cantidad y peso confirmados ingresaron sin ser reinterpretados;
4. en qué ubicación se encuentra;
5. qué estado de Calidad posee y quién tomó la decisión;
6. por qué una manga fue rechazada, bloqueada o corregida;
7. si un reintento intentó duplicar el ingreso.

## 4. Actores físicos

| Actor | Responsabilidad observable |
|---|---|
| Producción / Armado | Entrega la manga pesada y con etiqueta vigente |
| Almacenero de recepción | Escanea, verifica presencia/identidad, elige ubicación compatible y acepta o rechaza custodia |
| Calidad | Decide `LIBERADA`, `BLOQUEADA` o `RECHAZADA` después del ingreso |
| Jefe de Producción | Resuelve incidencias productivas y autoriza correcciones según capacidad |
| Auditoría / Gerencia | Consulta recepción, Calidad, movimientos y correcciones |

Quien recibe no modifica la cantidad confirmada por Producción/Armado ni el
peso confirmado por Balanza.

## 5. Lenguaje de dominio

### 5.1. Recepción de manga

Evento de aceptación de custodia de una [[Unidad_Logistica]] ya pesada. Crea una
existencia 1:1 con la misma manga; no crea otra bolsa, lote, pesaje o código.

### 5.2. Sesión de recepción

Agrupa el trabajo de un almacenero, punto de ingreso y rango de tiempo. Permite
escanear varias mangas, pero cada manga se confirma de manera independiente:
un error en una no revierte las ya aceptadas.

### 5.3. Rechazo antes de custodia

`RECHAZO_RECEPCION` documenta que Almacén no aceptó la manga. No crea stock ni
movimiento de ingreso y la custodia permanece en Producción/Armado.

### 5.4. Decisión de Calidad

Hecho posterior a la recepción. Cambia disponibilidad de Calidad, no existencia
física ni genealogía. Una manga recibida comienza `PENDIENTE`.

### 5.5. Movimiento inicial

`INGRESO_PRODUCCION` es el primer movimiento de la manga y acredita exactamente
la cantidad confirmada de su artículo en la ubicación aceptada.

## 6. Invariantes

1. Pesar no crea Kardex.
2. Una manga `PENDIENTE_RECEPCION_ALMACEN` no está disponible para reserva,
   consumo o despacho.
3. El ingreso exige una etiqueta vigente y la misma identidad creada por
   Producción.
4. Un replay devuelve el resultado previo y no duplica stock.
5. La recepción crea en una transacción el movimiento inicial, ubicación y
   Calidad `PENDIENTE`.
6. Una etiqueta invalidada, manga anulada o manga ya recibida no admite otro
   ingreso normal.
7. `fecha_operativa`, `pesada_at` y `recibida_at` se conservan por separado.
8. Cada manga posee como máximo un movimiento inicial vigente.
9. La recepción acredita el artículo y cantidad ya confirmados; nunca infiere
   unidades desde kg.
10. El almacenero no puede editar artículo, color, cantidad, bruto, tara o neto.
11. Una discrepancia previa a la aceptación genera rechazo/incidencia; no crea
    inventario parcial silencioso.
12. Calidad `PENDIENTE` cuenta como existencia física, pero no como saldo libre.
13. `BLOQUEADA` y `RECHAZADA` no eliminan existencia ni genealogía.
14. Solo `LIBERADA` participa en picking, consumo o despacho normal.
15. Ubicación, custodia, Calidad y disponibilidad son dimensiones separadas.
16. Toda ubicación elegida debe ser activa y compatible con la clase del
    artículo.
17. La recepción es conectada y autoritativa en central.
18. Cada comando acepta una clave de idempotencia.
19. Los hechos confirmados son append-only; las correcciones usan reversa o
    compensación.
20. El stock inicial del piloto sin manga conserva su naturaleza
    `LEGACY_SIN_ORIGEN`; no se transforma retroactivamente en bolsas ficticias.

## 7. Flujo normal

1. Almacén escanea la etiqueta vigente.
2. Central resuelve manga, OP, OF/OA, OT, artículo, cantidad y peso.
3. Central verifica que exista pesaje inicial confirmado y que la manga esté
   `PENDIENTE_RECEPCION_ALMACEN`.
4. La interfaz muestra artículo, color, cantidad, bruto, tara, neto, OT, fecha
   productiva y hora de pesaje como datos de solo lectura.
5. El operador confirma presencia física, estado visible y ubicación.
6. Central registra `recibida_at`, actor, sesión y punto de ingreso.
7. Central crea `INGRESO_PRODUCCION`, la existencia 1:1 y la proyección de
   ubicación dentro de una sola transacción.
8. La manga pasa a `RECIBIDA_PENDIENTE_CALIDAD`.
9. Calidad revisa la manga recibida y decide `LIBERADA`, `BLOQUEADA` o
   `RECHAZADA`.
10. Solo `LIBERADA` participa del saldo libre para reserva, consumo o despacho.

## 8. Estados

### 8.1. Estado de ingreso

```text
NO_INGRESADA
  -> PENDIENTE_RECEPCION_ALMACEN
  -> RECIBIDA
```

Estado lateral previo a custodia: `RECHAZADA_RECEPCION`.

### 8.2. Calidad posterior

```text
PENDIENTE
  -> LIBERADA
  -> BLOQUEADA
  -> RECHAZADA
```

`BLOQUEADA` también puede originarse desde `LIBERADA` por una incidencia
posterior. `RECHAZADA` exige después una disposición explícita; no mueve ni
destruye físicamente la manga.

### 8.3. Disponibilidad

```text
NO_DISPONIBLE = pendiente, bloqueada, rechazada o comprometida
DISPONIBLE = recibida + liberada + saldo libre + ubicación compatible
```

## 9. Etiquetas y QR

1. El QR resuelve `manga_id` y `label_id`; no transporta el saldo autoritativo.
2. Una etiqueta invalidada nunca puede recibir.
3. La manga debe poseer pesaje confirmado y etiqueta final vigente.
4. Si el QR final no puede leerse por deterioro físico, la preetiqueta vigente
   puede identificar alternativamente la misma manga. La aceptación exige que
   central compruebe que existen pesaje y etiqueta final vigentes; la
   preetiqueta no los reemplaza.
5. Si el QR está ilegible, la búsqueda manual por código requiere capacidad,
   confirmación reforzada y deja evidencia; nunca crea una identidad nueva.
6. Reemplazar una etiqueta pertenece al flujo autorizado de US-010C/D y no
   modifica la recepción ya confirmada.

## 10. Calidad

### 10.1. Liberación

Calidad confirma conformidad y puede adjuntar observación/evidencia. La
liberación registra actor y tiempo y vuelve elegible el saldo para US-010H.

### 10.2. Bloqueo

Conserva físicamente la manga y su ubicación, pero retira todo su saldo libre.
Debe registrar motivo y puede requerir evidencia.

### 10.3. Rechazo

Declara que el contenido no puede usarse normalmente. No equivale a devolución,
merma, destrucción o reproceso; esas disposiciones requieren eventos
posteriores.

### 10.4. Decisión masiva

La interfaz puede seleccionar varias mangas homogéneas, pero el servidor crea
una decisión por manga. Un fallo parcial queda visible y no finge atomicidad
del lote completo.

## 11. Incidencias y correcciones

### 11.1. Antes de aceptar custodia

Se registra `RECHAZO_RECEPCION` cuando:

- falta físicamente la manga;
- el QR/etiqueta no corresponde;
- la manga está abierta o dañada;
- el contenido visible no coincide;
- no existe pesaje final;
- la ubicación propuesta es incompatible.

No nace Kardex. Producción/Armado conserva custodia hasta corregir, reemplazar
etiqueta o anular según su historia dueña.

La verificación física mínima de Almacén comprende:

- presencia de la manga;
- bolsa cerrada y sin daño visible;
- coincidencia entre preetiqueta, etiqueta final y datos resueltos.

Almacén no vuelve a contar ni pesar durante este ingreso.

### 11.2. Después de aceptar custodia

Un error descubierto después del ingreso no borra la recepción. Se bloquea la
manga y se solicita una corrección compensatoria. Si la cantidad o peso de
producción eran incorrectos, la corrección se realiza en US-010F/D y propaga el
ajuste de inventario sin sobrescribir hechos.

### 11.3. Reversión excepcional

Solo se admite si la misma manga continúa físicamente controlada, no fue
reservada, movida, consumida ni despachada y existe aprobación segregada. La
reversa crea un movimiento opuesto y devuelve custodia; jamás elimina la
recepción original.

## 12. Estado actual de incorporación al piloto

### Incorporado

- ubicaciones e inventario normalizado base;
- saldo físico, reservado y libre por `ArticuloSCM`;
- movimientos `SALDO_INICIAL` y ajustes auditados;
- reserva transaccional al confirmar un plan;
- pantalla de consulta y carga inicial.
- resolución por QR final, preetiqueta alternativa y código manual autorizado;
- sesión opcional de recepción;
- verificación física, rechazo previo y ubicación compatible;
- transición de manga a `RECIBIDA`;
- existencia 1:1 y movimiento `INGRESO_PRODUCCION` idempotentes;
- stock físico separado entre reservado, no disponible y libre;
- decisiones de Calidad `LIBERADA`, `BLOQUEADA` y `RECHAZADA`;
- ajuste compensatorio del Kardex cuando una corrección de pesaje posterior
  cambia la cantidad recibida;
- interfaz central por actor y guía UAT.

El saldo inicial no crea mangas, lotes ni pesajes ficticios.

### Todavía pendiente

- criterios y evidencias concretos de Calidad por clase de artículo;
- reversa excepcional con solicitud/aprobación segregada;
- decisión masiva con resultado individual por manga;
- UAT con lector QR real y actores de Almacén/Calidad.

Pesar sigue sin crear Kardex y US-010D conserva su frontera. El núcleo normal
de US-010I está implementado localmente; no debe desplegarse hasta cerrar las
puertas pendientes.

## 13. Permisos futuros

| Capacidad | Uso |
|---|---|
| `RECEPCION_MANGA_VER` | Consultar pendientes, recibidas y rechazadas |
| `RECEPCION_MANGA_CONFIRMAR` | Aceptar custodia y crear el ingreso |
| `RECEPCION_MANGA_RECHAZAR` | Registrar rechazo previo a custodia |
| `RECEPCION_MANGA_BUSCAR_MANUAL` | Resolver una manga sin QR legible |
| `CALIDAD_MANGA_VER` | Consultar pendientes y decisiones |
| `CALIDAD_MANGA_LIBERAR` | Liberar una manga recibida |
| `CALIDAD_MANGA_BLOQUEAR` | Bloquear con motivo/evidencia |
| `CALIDAD_MANGA_RECHAZAR` | Rechazar y exigir disposición |
| `RECEPCION_MANGA_CORREGIR_SOLICITAR` | Solicitar reversa/compensación |
| `RECEPCION_MANGA_CORREGIR_APROBAR` | Aprobar corrección segregada |

## 14. Escenarios ATDD

### Escenario 1: pesar no crea inventario

- **Dado** una manga pesada y etiquetada
- **Cuando** todavía no fue escaneada por Almacén
- **Entonces** no posee ubicación, movimiento inicial ni saldo disponible.

### Escenario 2: recepción normal por QR

- **Dado** una manga pendiente con etiqueta final vigente
- **Cuando** Almacén escanea, verifica y acepta una ubicación compatible
- **Entonces** crea una sola existencia y `INGRESO_PRODUCCION`
- **Y** queda `RECIBIDA` con Calidad `PENDIENTE`.

### Escenario 3: datos productivos de solo lectura

- **Dado** una manga con 50 unidades y 12.500 kg netos confirmados
- **Cuando** se abre la recepción
- **Entonces** cantidad y pesos se muestran sin controles editables
- **Y** Almacén solo acepta o rechaza.

### Escenario 4: replay idempotente

- **Dado** un ingreso confirmado
- **Cuando** el móvil reenvía la misma clave
- **Entonces** retorna la misma recepción y no duplica saldo ni movimiento.

### Escenario 5: segundo ingreso de la misma manga

- **Dado** una manga ya recibida
- **Cuando** otro actor intenta recibirla con otra clave
- **Entonces** central responde `MANGA_YA_RECIBIDA` con ubicación y tiempo
- **Y** no crea otro ingreso.

### Escenario 6: etiqueta invalidada

- **Dado** una etiqueta reemplazada
- **Cuando** se escanea su QR anterior
- **Entonces** central rechaza y señala la versión vigente.

### Escenario 7: preetiqueta sin pesaje final

- **Dado** una manga solo preetiquetada
- **Cuando** llega a recepción
- **Entonces** se rechaza porque no posee pesaje/etiqueta final confirmados.

### Escenario 8: ubicación incompatible

- **Dado** una manga de producto terminado
- **Cuando** se intenta recibir en una posición exclusiva de materia prima
- **Entonces** el servidor rechaza antes de crear Kardex.

### Escenario 9: rechazo antes de custodia

- **Dado** una manga dañada al llegar
- **Cuando** Almacén registra motivo y evidencia
- **Entonces** queda `RECHAZADA_RECEPCION`
- **Y** no nace inventario y Producción conserva custodia.

### Escenario 10: liberación posterior

- **Dado** una manga recibida con Calidad pendiente
- **Cuando** Calidad la libera
- **Entonces** su saldo puede participar en reserva y picking.

### Escenario 11: bloqueo

- **Dado** una manga recibida
- **Cuando** Calidad la bloquea
- **Entonces** conserva existencia y ubicación, pero saldo libre es cero.

### Escenario 12: rechazo de Calidad

- **Dado** una manga recibida
- **Cuando** Calidad la rechaza
- **Entonces** no desaparece del inventario
- **Y** queda pendiente de una disposición explícita.

### Escenario 13: corrección posterior

- **Dado** una manga recibida cuyo pesaje fue corregido de forma autorizada
- **Cuando** se confirma la compensación
- **Entonces** el inventario registra un ajuste enlazado
- **Y** conserva recepción, pesaje original y corrección.

### Escenario 14: búsqueda manual

- **Dado** un QR ilegible y una etiqueta visible
- **Cuando** un actor autorizado busca el código y confirma los datos
- **Entonces** recibe la misma manga
- **Y** registra que la resolución fue manual.

### Escenario 15: recepción múltiple con fallo parcial

- **Dado** tres mangas escaneadas, una con etiqueta invalidada
- **Cuando** se confirma la sesión
- **Entonces** las dos válidas se reciben una sola vez
- **Y** la inválida queda fallida y accionable.

### Escenario 16: central no disponible

- **Dado** el dispositivo sin conexión
- **Cuando** se intenta recibir
- **Entonces** no declara éxito ni crea saldo local autoritativo.

### Escenario 17: fechas separadas

- **Dado** una OT del 29, un pesaje del 30 y recepción del 31
- **Cuando** se consulta la manga
- **Entonces** conserva las tres fechas sin atribuir la producción al día de
  recepción.

### Escenario 18: reserva mientras Calidad está pendiente

- **Dado** una manga recibida pendiente de Calidad
- **Cuando** Planificación intenta reservarla
- **Entonces** el servidor la excluye del saldo libre.

### Escenario 19: saldo inicial legacy

- **Dado** saldo cargado por conteo al iniciar el piloto
- **Cuando** se consulta inventario
- **Entonces** permanece `LEGACY_SIN_ORIGEN`
- **Y** no aparecen manga, etiqueta, pesaje u OT inventados.

### Escenario 20: reversa excepcional

- **Dado** una recepción equivocada sin movimientos posteriores
- **Cuando** un segundo actor aprueba la reversa
- **Entonces** se crea movimiento compensatorio y se devuelve custodia
- **Y** la recepción original permanece auditable.

## 15. Dataset de referencia

```text
Manga: OA000025-OT000141-M001
Artículo: PT-000002 · Balde Romano 20 L amarillo
Cantidad confirmada: 50 un
Peso bruto / tara / neto: 33.200 / 0.200 / 33.000 kg
Fecha operativa OT: 2026-07-29
Pesada at: 2026-07-30 08:15 America/Lima
Recibida at: 2026-07-30 09:05 America/Lima
Ubicación: RECEPCION_PT
Calidad inicial: PENDIENTE
Movimiento: INGRESO_PRODUCCION +50 un
```

La prueba debe demostrar recepción, replay, liberación, bloqueo, rechazo previo
y rechazo posterior sin duplicar ni borrar existencia.

## 16. Errores observables

- `MANGA_NO_ENCONTRADA`: verificar QR/código;
- `ETIQUETA_INVALIDADA`: usar la vigente;
- `PESAJE_FINAL_REQUERIDO`: devolver a Producción/Balanza;
- `MANGA_ANULADA`: no recibir;
- `MANGA_YA_RECIBIDA`: mostrar ubicación, actor y fecha;
- `UBICACION_INCOMPATIBLE`: elegir una ubicación permitida;
- `RECEPCION_RECHAZADA`: mostrar motivo y custodio actual;
- `CALIDAD_PENDIENTE`: no disponible todavía;
- `CONFLICTO_CONCURRENCIA`: refrescar el estado;
- `CENTRAL_NO_DISPONIBLE`: no declarar recepción confirmada.

## 17. Fuera de alcance

- crear, cerrar o pesar la manga;
- corregir directamente cantidad o peso productivos;
- picking y consumo hacia Armado: US-010H;
- devolución desde Armado: US-010H;
- despacho a cliente: US-010G;
- disposición final, molienda o reproceso;
- operación offline;
- inventar mangas para saldos iniciales legacy;
- optimización de posiciones de almacén.

## 18. Decisiones operativas

### Validadas el 2026-07-30

1. Las ubicaciones piloto se denominan `RECEPCION_PIEZAS_WIP` y
   `RECEPCION_PT`.
2. Si el QR final quedó físicamente ilegible, se puede escanear la preetiqueta
   vigente para resolver la misma manga. Central debe comprobar pesaje y
   etiqueta final vigentes.
3. Almacén verifica presencia, bolsa cerrada/sin daño y coincidencia de ambos
   stickers. No vuelve a contar ni pesar.
4. Una reversa excepcional requiere aprobación del Jefe de Producción por un
   actor distinto de quien recibió.

### Pendiente

1. Definir criterios y evidencias mínimas de Calidad para liberar cada clase de
   artículo.

## 19. Definición de Preparada

- [x] Frontera pesaje/recepción/inventario definida.
- [x] Recepción y Calidad separadas.
- [x] Rechazo antes de custodia y rechazo posterior diferenciados.
- [x] Identidad, idempotencia, concurrencia y correcciones cubiertas.
- [x] Dataset y escenarios ATDD definidos.
- [x] Ubicaciones piloto validadas.
- [x] Verificación física y uso alternativo de preetiqueta validados.
- [ ] Criterios mínimos de Calidad validados.
- [x] Autoridad de reversa validada.
- [ ] Historia aprobada por Producción, Almacén y Calidad.

La implementación se especifica en
[[../03_Tech_Specs/TS-010I_Recepcion_Mangas_y_Nacimiento_Kardex|TS-010I]].
