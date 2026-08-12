---
tipo: user-story
subtipo: historia-hija
estado: en-refinamiento
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, pesaje, mangas, unidad-logistica, qr, etiquetas, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final]]"
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[Articulo_SCM]]"
  - "[[Lote_WIP]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Perfil_Empaque]]"
  - "[[Tipo_Manga]]"
  - "[[Etiqueta_Manga]]"
  - "[[Orden_Operacion]]"
  - "[[US-011_Monitorear_Estaciones_de_Pesaje]]"
  - "[[Control_Peso]]"
  - "[[Saldo_WIP_Salida]]"
  - "[[Unidad_Logistica]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[Orden_Armado]]"
  - "[[Orden_Fabricacion]]"
  - "[[Lote_Color]]"
  - "[[2026-07-23_Autoridad_Central_OT_e_Impresion_Local]]"
  - "[[2026-07-23_Separacion_Peso_Fisico_Produccion_y_Armado]]"
  - "[[2026-07-24_Mangas_Etiquetas_Fecha_Operativa_y_Recepcion_Almacen]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-08-01_Stickers_Prepesaje_como_Orden_Fisica_de_Manga]]"
  - "[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]]"
fecha_creacion: 2026-07-23
fecha_actualizacion: 2026-08-01
---

# US-010D: Pesaje de Mangas, Etiquetado y Confirmación de Producción

## 1. Decisión de alcance

Esta historia comienza con una identidad de manga planificada por [[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]] para una salida simple o por [[US-010F_Prearmado_y_Armado_Concurrente_Trazable|US-010F]] para una transformación. El maquinista escanea la [[Etiqueta_Manga|etiqueta]] y la estación recupera tipo de manga, regla de empaque, artículo, lote `PiezaColor`/WIP/producto, OF/OT/operación de contexto y cantidad asignada.

El pesaje confirma la existencia física y el peso de la misma manga, pero **no la ingresa a inventario**. Después de una captura válida existe una sola manga y un solo evento de pesaje; queda `PENDIENTE_RECEPCION_ALMACEN`, sin ubicación, disponibilidad ni movimiento de Kardex. El movimiento inicial pertenece a [[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex|US-010I]].

El contrato productivo de esta historia sustituye el envío legacy `POST /api/sync/pesajes`. La continuidad y observación del piloto pueden coexistir, pero no crean `ControlPeso`, Kardex ni inventario SCM definitivo.

La estación de Balanza es el primer punto digital que usa el maquinista: no hay
PC en la máquina. El sticker fue planificado en central, impreso en esta misma
estación y entregado físicamente por el supervisor. Al escanearlo se recupera
todo el contexto de solo lectura.

### 1.1. Secuencia vertical sin dependencia circular

- **US-010D-core:** manga de salida simple, aplicación del saldo/reserva WIP definido por US-010C, captura de balanza y etiqueta final. Depende de US-010C.
- **US-010F-inline:** [[Orden_Operacion]] y comando compuesto de cierre. Reutiliza el saldo de C, artículos/rutas de US-010R y primitivas de D-core.
- **Adaptador D/F de bolsa transformada:** pantalla y sincronización para `LOTE_WIP` o producto final. Se entrega coordinadamente con US-010F y no bloquea el corte simple de D-core.

## 2. Historia de usuario

**Como** maquinista u operador de pesaje  
**Quiero** escanear el identificador previamente impreso de una manga y asignarle el peso capturado por la balanza  
**Para** confirmar una única salida física trazable sin volver a seleccionar ni ingresar manualmente OF, OT, pieza, color o cantidad.

## 3. Resultado observable

1. Escanear una bolsa válida carga su contexto de solo lectura.
2. La estación conserva bruto, tara, neto y tres decimales en kg.
3. F2 confirma una sola captura mediante un identificador de evento idempotente.
4. La manga pasa a `PESADA` y luego `PENDIENTE_RECEPCION_ALMACEN` sin cambiar de identidad.
5. El evento identifica contenido exacto (`LoteSalidaPiezaColor`, [[Lote_WIP]] o [[Lote_Producto_Terminado]]), OT/operación de contexto cuando aplica, estación y actor reales.
6. Repetir la misma solicitud por pérdida de respuesta aplica sus efectos una sola vez y devuelve el mismo resultado.
7. Reescanear una manga pesada muestra su resultado; reemplazar una etiqueta requiere autorización JP y nueva identidad de etiqueta.
8. Una corrección nunca sobrescribe silenciosamente el hecho original.
9. El piloto exige conexión central; no acepta capturas offline.
10. El peso físico de una bolsa transformada permanece separado de los kg estándar atribuibles a la OT actual y de los componentes consumidos previamente.
11. Tipo físico de contenedor y tipo de contenido permanecen separados y se resuelven desde el plan congelado.
12. La cantidad asignada se confirma implícitamente al pesar, sin digitación del maquinista; el peso no infiere unidades.
13. `fecha_operativa` de OT y `pesada_at` permanecen separadas; el avance se acredita al día de la OT.
14. El pesaje no crea inventario ni Kardex.
15. El flujo normal no exige búsquedas, dropdowns ni digitación de documentos o
    cantidades por parte del maquinista.

## 4. Lenguaje de dominio

### 4.1. Manga de salida

La misma identidad iniciada como manga `PLANIFICADA` se confirma físicamente al pesar. Como mínimo conserva:

- identificador global y código legible;
- OT/OF/corrida de contexto;
- exactamente un contenido principal: `LoteSalidaPiezaColor`, [[Lote_WIP]] o [[Lote_Producto_Terminado]];
- `tipo_contenedor_id` y revisión de [[Perfil_Empaque]] congelados;
- cantidad planificada, asignada, confirmada y contenida separadas; en el flujo normal la confirmada toma la asignada sin input manual;
- peso bruto, tara y neto;
- estado `PENDIENTE_RECEPCION_ALMACEN` y `estado_inventario=NO_INGRESADA`;
- ubicación de inventario nula;
- estación, captura y actor;
- fecha operativa OT y tiempo real de pesaje;
- manga, [[Etiqueta_Manga]] y sus IDs separados.

### 4.2. Captura de peso

Hecho inmutable originado por una estación. `operation_id` identifica el comando completo y es único junto a `source_system`; `capture_id` es un efecto hijo determinístico. El `source_event_id` del envelope de trazabilidad toma el mismo valor que `operation_id`, no una segunda clave independiente. Guardar la captura y conseguir imprimir son resultados independientes.

### 4.3. Etiqueta final

Conserva el mismo `manga_id`, crea una [[Etiqueta_Manga]] `POSTPESAJE` con `label_id` propio y añade peso, fecha y tipo `NORMAL` o `EXTRA`. La etiqueta de prepesaje permanece vigente.

Una etiqueta emitida no se reimprime de forma indistinguible. Su reemplazo requiere autorización del Jefe de Producción, invalida la versión anterior con motivo y crea otro `label_id`. La manga no cambia ni se vuelve extra.

### 4.4. Peso físico y atribución

La balanza solo mide la bolsa completa. En una bolsa WIP de baldes con asas previas, el neto incluye ambos componentes. US-010D conserva esa medición; US-010F calcula por separado los kg estándar de cuerpos actuales, asas anteriores y residual usando cantidades y snapshots. El campo porcentual legacy “descuento ajeno a la pieza” no es genealogía.

### 4.5. Confirmación de bolsa de operación

La estación envía un solo comando `CONFIRMAR_MANGA_OPERACION`; `CONFIRMAR_BOLSA_OPERACION` permanece como alias de transición. Central confirma cantidad/peso, aplica reservas, consume entradas, acredita [[Lote_WIP]] o producto según la salida congelada y deja la manga pendiente de recepción en una transacción. No publica pesaje y consumos como finales independientes y no crea Kardex.

### 4.6. Namespaces de tipo

- `qr_object_type=SCM_MANGA`: objeto estable de la manga.
- `label_qr_type=SCM_MANGA_LABEL`: impresión concreta, con `label_id` y versión.
- `tipo_contenedor_id`: [[Tipo_Manga]] físico gobernado.
- `content_lot_type=LOTE_SALIDA_PIEZA_COLOR | LOTE_WIP | LOTE_PRODUCTO_TERMINADO` para producción.
- `ui_mode=SALIDA_SIMPLE | WIP_TRANSFORMADO | PRODUCTO_TERMINADO`, derivado del contenido/operación y nunca enviado como identidad de dominio.

## 5. Invariantes

1. Una identidad de manga solo admite un pesaje vigente inicial.
2. Un replay exacto devuelve el resultado anterior; la misma clave con otro payload genera conflicto.
3. El peso neto es `bruto - tara` y debe ser positivo.
4. Todos los pesos SCM usan `Decimal` y kg con tres decimales.
5. Tipo de contenedor, artículo, lote, OF/OT/operación de contexto y color provienen de la bolsa; no se escriben libremente al pesar.
6. El actor real del pesaje se registra aunque difiera del maquinista previsto.
7. Una manga anulada, bloqueada o ya pesada no acepta captura normal. Una manga directa pendiente impide cerrar su OT.
8. Una captura local confirmada no se elimina ni edita; una corrección crea un evento enlazado.
9. Central no deduplica por peso/hora/texto, sino por `(source_system, operation_id)` y hash canónico. Cada efecto hijo usa ID determinístico por tipo/línea.
10. La impresión fallida nunca revierte un peso aceptado; un soporte posiblemente emitido se invalida y reemplaza con autorización JP.
11. La sincronización productiva exige `station_id`, `operation_id`, `unidad_logistica_id`, `tipo_contenedor_id`, `content_lot_type` y `content_lot_id`; `source_event_id=operation_id` en el envelope y `ot_id` se conserva como contexto cuando corresponda.
12. El payload QR es versionado y no usa posiciones separadas por `;` como contrato autoritativo.
13. Toda manga exige `cantidad_asignada`; pesar la confirma implícitamente y el peso nunca se divide para inferirla.
14. Pesar una bolsa transformada no acredita automáticamente todo su neto al `LoteSalidaPiezaColor` de la OT actual.
15. El replay de una captura de operación no duplica pesaje, consumos ni resultado.
16. Cantidad planificada, asignada, confirmada y contenida se conservan por separado; una diferencia registra actor y motivo cuando la tolerancia lo exige.
17. Una bolsa transformada se gobierna por su [[Orden_Operacion]]. Cerrar la OT de contexto no la invalida si sus cuerpos buenos ya fueron acreditados; si declara `CREDITO_EN_LINEA_PENDIENTE`, bloquea esa OT hasta sincronizar o anularse. La Orden de Operación no cierra mientras tenga bolsas o comandos pendientes.
18. El piloto rechaza el inicio de una captura cuando central no está disponible.
19. La cantidad contenida de una salida simple proviene del conteo confirmado o de una reserva WIP previa; nunca del peso.
20. Una reserva vencida no se reutiliza automáticamente; exige conciliación antes de pesar.
21. `PENDIENTE_RECEPCION_ALMACEN` no equivale a inventario, ubicación ni disponibilidad.
22. Una cantidad confirmada menor a la asignada aplica el contenido real y libera el remanente atómicamente; una mayor se rechaza o concilia sin débito parcial.
23. `tipo_contenedor_id` y `content_lot_type` son dimensiones distintas y no se derivan mutuamente.
24. El avance se atribuye a `OT.fecha_operativa`; `pesada_at` solo registra el tiempo físico.
25. Un pesaje en el día calendario siguiente está permitido. Más de un día después genera alerta y motivo; antes de la fecha operativa se bloquea salvo corrección.
26. Además del desfase contra la fecha operativa, una regla configurable puede
    alertar por tiempo transcurrido entre emisión de preetiqueta y pesaje. Son
    referencias distintas y se conservan ambas.
27. Un pesaje confirmado no se elimina. Una anulación/corrección compensatoria
    posterior al umbral configurable genera una alerta de jefatura con actor,
    motivo y cronología, según [[US-010J_Alertas_Operativas_e_Inconsistencias|US-010J]].
26. Ni el pesaje simple ni el compuesto crean `MovimientoKardex`.
27. La ausencia de PC en máquina no autoriza a reconstruir la OT desde el peso:
    la estación exige un QR de manga planificada y vigente.
28. En el piloto `CONFIRMAR_PESAJE_MANGA` exige una manga cerrada. Una manga
    abierta no admite pesajes acumulativos ni etiqueta final.
29. Los cortes horarios consultan pesajes finales existentes por ID; nunca
    generan otra captura ni suman lecturas acumuladas de la misma manga.

## 6. Flujo principal

1. El operador escanea una etiqueta de `OP0084-OT001-M001`.
2. La estación resuelve en central manga, etiqueta vigente y reserva.
3. La interfaz muestra contenedor, regla de empaque, OT/OF/operación de contexto, artículo/lote, color, cantidades planificada/asignada, vigencia y maquinista como solo lectura.
4. La balanza entrega peso bruto estable.
5. Se aplica la tara configurada o capturada y se muestra el neto.
6. La estación toma `cantidad_asignada` como confirmación implícita; no muestra un input de unidades en el flujo normal.
7. F2 crea `CONFIRMAR_PESAJE_MANGA` para salida simple o `CONFIRMAR_MANGA_OPERACION` para transformación.
8. Central valida idempotencia, etiqueta vigente, reserva, fecha operativa y tolerancias.
9. Para salida simple, central aplica `ReservaWIPSalida`, debita [[Saldo_WIP_Salida]], registra el pesaje y deja la manga pendiente de recepción.
10. Para WIP o producto terminado, central ejecuta el comando compuesto de US-010F en una sola transacción.
11. La estación imprime la etiqueta `POSTPESAJE`; si falla, conserva el peso y permite solicitar reemplazo autorizado.
12. La manga queda `PENDIENTE_RECEPCION_ALMACEN`, sin movimiento ni ubicación de inventario.

## 7. Criterios de aceptación ATDD/BDD

### PSD-01 — Escanear bolsa planificada

**Dado** `OP0084-OT001-M001` planificada para `OT-000123`, Asa Fucsia  
**Cuando** el operador escanea su QR  
**Entonces** la estación muestra esos datos de solo lectura y queda preparada para capturar peso.

### PSD-02 — Peso válido

**Dado** bruto `25.420 kg`, tara `0.120 kg` y una reserva WIP activa de 120 piezas  
**Cuando** se confirma F2  
**Entonces** se registra neto `25.300 kg`, contenido de 120 piezas con fuente `PLAN_CONFIRMADO_POR_PESAJE` y la manga queda pendiente de recepción.

### PSD-03 — Doble F2

**Dado** una captura en curso  
**Cuando** F2 se presiona dos veces  
**Entonces** solo una solicitud adquiere la identidad y existe un único pesaje.

### PSD-04 — Respuesta perdida

**Dado** que central aceptó el evento pero la estación perdió el acuse  
**Cuando** la estación reintenta el mismo UUID y payload  
**Entonces** central devuelve la misma manga sin duplicar peso, consumo ni resultado.

### PSD-05 — Conflicto idempotente

**Dado** un UUID aceptado con neto `25.300 kg`  
**Cuando** se reutiliza con `24.900 kg`  
**Entonces** se rechaza con `IDEMPOTENCY_CONFLICT` y se conserva el hecho original.

### PSD-06 — Bolsa ya pesada

**Dado** una bolsa con captura confirmada  
**Cuando** se escanea de nuevo  
**Entonces** se muestra el peso existente y acciones de corrección o reemplazo autorizado de etiqueta; F2 no crea otra captura normal.

### PSD-07 — Impresión fallida

**Dado** un peso guardado correctamente  
**Cuando** la impresora falla después de que el soporte pudo emitirse  
**Entonces** el peso sigue vigente  
**Y** el JP puede invalidar la etiqueta fallida y autorizar otra con nuevo `label_id`, sin repetir la balanza.

### PSD-08 — Piloto conectado

**Dado** una OT y mangas planificadas, y central no disponible  
**Cuando** el maquinista intenta iniciar el pesaje  
**Entonces** la estación bloquea F2 e informa que el piloto requiere conexión  
**Y** no guarda una captura offline.

### PSD-09 — Contexto inválido

**Dado** una bolsa anulada, no planificada o con una salida no disponible  
**Cuando** se intenta pesar  
**Entonces** la estación bloquea F2 y explica la condición sin permitir reemplazar manualmente la OT o el color.

### PSD-10 — Actor diferente al previsto

**Dado** una etiqueta asignada a Juan y un pesaje realizado por María  
**Cuando** María se autentica y confirma  
**Entonces** se conserva Juan como asignación prevista y María como actor real.

### PSD-11 — QR legacy

**Dado** un QR posicional del piloto  
**Cuando** se usa en el perfil SCM productivo  
**Entonces** no crea inventario; se rechaza o se dirige al flujo de conciliación legacy.

### PSD-12 — Corrección auditada

**Dado** una bolsa pesada con valor incorrecto  
**Cuando** un usuario autorizado solicita corregir con motivo y evidencia  
**Entonces** se crea una compensación enlazada, se recalcula la proyección y el peso original continúa consultable.

### PSD-13 — Bolsa de baldes con asas previas

**Dado** una bolsa `LOTE_WIP` con 100 baldes prearmados, cuerpos de la OT actual y asas de una OT anterior  
**Cuando** la balanza confirma `20.300 kg` netos  
**Entonces** conserva `20.300 kg` como peso físico del WIP prearmado  
**Y** no lo suma íntegramente como producción de la OT actual  
**Y** US-010F conserva cantidades, orígenes y atribuciones estándar de cada componente.

### PSD-14 — Replay compuesto

**Dado** que una captura aceptada pesó una manga WIP  
**Cuando** la estación reenvía la misma solicitud por pérdida de respuesta  
**Entonces** retorna la misma unidad  
**Y** no repite el consumo de asas ni la acreditación del WIP.

### PSD-15 — Manga sin pesar y cierre de OT directa

**Dado** una manga simple planificada sin pesaje  
**Cuando** central intenta cerrar la OT  
**Entonces** la manga figura pendiente y el cierre se bloquea  
**Y** solo pesarla o anularla permite reevaluar el cierre.

### PSD-16 — Cierre de OT contextual

**Dado** una Orden de Operación en ejecución con bolsa WIP planificada, cuerpos buenos ya acreditados y una OT usada solo como contexto  
**Cuando** la OT termina su transformación y cierra con su WIP conciliado  
**Entonces** la bolsa WIP continúa siendo capturable  
**Y** es la Orden de Operación la que no puede cerrar hasta pesar o anular sus bolsas pendientes.

### PSD-17 — Diferencia entre plan y confirmación

**Dado** una manga WIP asignada para 100 conjuntos  
**Cuando** se pesa en el flujo normal  
**Entonces** confirma implícitamente 100 sin input manual  
**Pero** una corrección autorizada a 98 conserva plan, diferencia, actor y motivo y recalcula los efectos mediante compensación.

### PSD-18 — Reserva vencida

**Dado** una reserva que venció antes de iniciar el pesaje  
**Cuando** se escanea la manga  
**Entonces** central bloquea F2 y exige renovar o conciliar la reserva.

### PSD-19 — IDs hijos determinísticos

**Dado** un `CONFIRMAR_MANGA_OPERACION` que produce pesaje, dos consumos y dos movimientos WIP  
**Cuando** central recibe el comando repetido  
**Entonces** el inbox encuentra el mismo `operation_id`/hash y devuelve el resultado  
**Y** cada efecto conserva el mismo ID derivado de su tipo y `line_key`, sin colisionar con las otras líneas.

### PSD-20 — Diferencia contra reserva

**Dado** una reserva de hasta 100 unidades para una bolsa  
**Cuando** central confirma 98  
**Entonces** debita 98 y libera 2 dentro del mismo comando  
**Pero** si se confirman 102, rechaza o concilia la operación completa sin debitar 100 parcialmente.

### PSD-21 — Pesaje posterior a la fecha operativa

**Dado** una OT del 23 de julio en `America/Lima`  
**Cuando** su manga se pesa el 24 de julio  
**Entonces** se acredita el avance al 23 sin alerta bloqueante  
**Pero** si se pesa el 25 o después, registra alerta y exige motivo.

### PSD-22 — Sin nacimiento de Kardex

**Dado** una manga con pesaje y etiqueta final confirmados  
**Cuando** central completa US-010D  
**Entonces** queda `PENDIENTE_RECEPCION_ALMACEN`, `ubicacion_id=null` y `estado_inventario=NO_INGRESADA`  
**Y** no existe `MovimientoKardex` hasta US-010I.

### PSD-23 — Etiqueta invalidada

**Dado** una etiqueta reemplazada por autorización del JP  
**Cuando** se escanea su QR anterior  
**Entonces** central informa `ETIQUETA_INVALIDADA` y la versión vigente  
**Y** no permite usarla para otro pesaje ni crea otra manga.

## 8. Dataset de referencia

| Dato | Valor |
|---|---|
| OF / OT | `OF-0042 / OT-000123` |
| Manga | `OP0084-OT001-M001` |
| Salida | `LSPC-000123-01 · PC-000004 · Asa · Fucsia` |
| Estación | `PESAJE-01` |
| Bruto / tara / neto | `25.420 / 0.120 / 25.300 kg` |
| Actor previsto / real | `Juan / María` |

Caso compuesto adicional: `BOL-WIP-000502`, 100 baldes con asa prearmada, neto físico `20.300 kg`, aporte estándar de cuerpos actuales `18.000 kg` y asas previas `2.000 kg`.

## 9. Permisos mínimos

- `MANGA_PESAR`
- `MANGA_ETIQUETA_POST_IMPRIMIR`
- `MANGA_ETIQUETA_REEMPLAZAR_SOLICITAR`
- `MANGA_ETIQUETA_REEMPLAZAR_APROBAR`
- `PESAJE_CORRECCION_SOLICITAR`
- `PESAJE_CORRECCION_APROBAR`

## 10. Fuera de alcance

- Crear la OT o planificar bolsas simples: US-010C.
- Congelar ejecución, consumir componentes o crear el lote WIP/producto: US-010F.
- Crear bolsas nuevas sin una salida planificada, salvo contingencia aprobada posteriormente.
- Molienda y material recuperado: US-010E.
- Despacho: US-010G.
- Usar el heartbeat de US-011 como evento de inventario.
- Editar o borrar un pesaje sincronizado.
- Operación offline.
- Recepción, ubicación y movimiento inicial de Kardex: [[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex|US-010I]].

## 11. Decisiones operativas validadas — 2026-07-24

1. Después de pesar se conserva el sticker previo y se imprime una etiqueta final complementaria; ambos identifican la misma manga y cada impresión posee su propio `label_id`.
2. La tara procede de [[Tipo_Manga]] congelado y permite override autorizado, conservando valor, fuente y actor.
3. El maquinista cuenta físicamente, pero no ingresa cantidades; pesar confirma la asignada y nunca infiere unidades desde kg.
4. Una manga pesada queda `PENDIENTE_RECEPCION_ALMACEN`; no posee inventario, ubicación ni Kardex.
5. Un peso atípico genera advertencia y exige motivo según tolerancia; no niega una medición física válida por sí solo.
6. Reemplazar una etiqueta requiere autorización JP, invalida la versión anterior y crea otro `label_id`.
7. El avance pertenece a `fecha_operativa`; más de un día calendario hasta el pesaje genera alerta y motivo.
8. El piloto exige conexión central.

## 12. Puertas de pipeline separadas

### 12.1. D-core — bolsa simple

- [x] La identidad previa, el pesaje y el nacimiento posterior de inventario están separados.
- [x] Idempotencia, doble F2, conexión requerida e impresión fallida tienen escenarios.
- [x] La frontera con el monitor legacy está explícita.
- [x] QR, tipo de contenedor, tipo de contenido y modo UI poseen namespaces inequívocos.
- [x] Planta validó las ocho decisiones operativas del apartado 11.
- [x] La cantidad proviene del plan confirmado implícitamente, nunca de kg.
- [x] Etiqueta y manga poseen identidades separadas y reemplazo autorizado.
- [x] Fecha operativa y tiempo real de pesaje poseen escenarios observables.
- [x] US-010D termina sin Kardex y entrega a US-010I.
- [ ] Se prueba el dataset con balanza e impresora físicas.
- [x] Se registró [[Baseline_TS-010R_C_D_2026-07-24]]; suites rápidas verdes y PostgreSQL rojo por tres pruebas previas.

`TS-010D-core` ya está redactada en [[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final]]. La prueba física y la corrección de la baseline PostgreSQL bloquean su aprobación para desarrollo, no su refinamiento documental.

### 12.2. Adaptador D/F — propiedad de US-010F sobre fundamento US-010R

- [x] El pesaje compuesto conserva el neto físico sin inflar la producción de la OT.
- [x] El comando compuesto, IDs hijos y diferencia plan/real tienen escenarios observables.
- [x] D-core y el adaptador D/F tienen una secuencia sin dependencia circular.
- [ ] Se validan las decisiones operativas y de Calidad pendientes en US-010F.
- [ ] Se prueba una BOM/bolsa real y el E2E `C -> F -> D/F` sobre línea base reproducible.

Esta segunda puerta se mapea a la Tech Spec de US-010F; no bloquea D-core ni habilita por sí sola desarrollo del armado.
