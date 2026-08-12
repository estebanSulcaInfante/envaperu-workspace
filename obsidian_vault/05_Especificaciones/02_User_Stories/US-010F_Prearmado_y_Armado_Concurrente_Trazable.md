---
tipo: user-story
subtipo: historia-hija
estado: en-refinamiento
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, produccion, armado, prearmado, wip, producto-terminado, genealogia, tiempo-real, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[Articulo_SCM]]"
  - "[[Ruta_Produccion]]"
  - "[[Orden_Operacion]]"
  - "[[Lote_WIP]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Perfil_Empaque]]"
  - "[[ProductoTerminado]]"
  - "[[Orden_Armado]]"
  - "[[Orden_Fabricacion]]"
  - "[[Saldo_WIP_Salida]]"
  - "[[Unidad_Logistica]]"
  - "[[2026-07-23_Separacion_Peso_Fisico_Produccion_y_Armado]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-07-30_OT_Diaria_Comun_para_Fabricacion_y_Armado]]"
  - "[[2026-08-01_Dos_Modalidades_Armado_y_Responsabilidades]]"
fecha_creacion: 2026-07-23
fecha_actualizacion: 2026-08-02
---

# US-010F: Prearmado y Armado Concurrente Trazable

## 1. Decisión de alcance

El armado es una transformación distinta de la inyección aunque ocurra entre ciclos, junto a la máquina y con los mismos trabajadores. En el caso validado por EnvaPerú, la OT actual produce cuerpos de balde y, durante sus ciclos lentos, el personal incorpora asas que ya estaban fabricadas. Las asas pueden proceder de otra OF, OT, fecha o molde.

El asa no es tara, merma ni un porcentaje que deba desaparecer del peso. Es una `PiezaColor` consumida desde inventario. Según [[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque|US-010R]], balde + asa genera [[Lote_WIP]] cuando todavía faltan operaciones y `ProductoTerminado` únicamente cuando completa la estructura comercial aprobada.

Esta historia adelanta el corte mínimo de US-010F necesario para que [[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]] y [[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]] no inflen el avance de la máquina. El armado posterior masivo podrá ampliar el mismo agregado sin crear otro modelo incompatible.

## 2. Historia de usuario

**Como** responsable de Armado o trabajador de prearmado  
**Quiero** confirmar el prearmado realizado durante una OT, consumiendo piezas actuales y piezas previamente fabricadas  
**Para** conocer en tiempo real cuánto produjo la máquina, cuánto WIP o producto se transformó, qué inventario anterior se utilizó y cuál es el peso físico real de cada bolsa.

## 3. Tres verdades que no se deben fusionar

| Dimensión | Significado | Autoridad |
|---|---|---|
| Producción de inyección | Unidades buenas y kg estándar atribuibles a las piezas creadas por la OT actual | Ciclos, detalle de producción y `LoteSalidaPiezaColor` |
| Ejecución de operación | Conjuntos transformados y cantidades reales de cada componente consumido | [[Orden_Operacion]] y sus consumos |
| Embalaje físico | Bruto, tara y neto total de la bolsa ya armada | Balanza y captura de US-010D |

El peso físico de la bolsa no se asigna íntegramente a la OT de inyección. Tampoco se puede afirmar que el peso real individual del cuerpo fue medido después de pesarlo unido al asa.

## 4. Lenguaje de dominio

### 4.1. Armado concurrente o en línea

Ejecución de una BOM durante otra OT aprovechando tiempos de ciclo. Conserva un `ot_contexto_id` para navegación y avance, pero no convierte todos sus componentes en producción de esa OT.

### 4.2. OrdenOperacion / OrdenArmado

Congela operación de ruta, artículo de salida, revisión de estructura, cantidades objetivo, ubicación y responsables. `OrdenArmado` permanece como nombre funcional especializado. Puede vincularse a una OT de contexto y recibir componentes de múltiples lotes, unidades, OTs y moldes.

### 4.3. Consumo y orígenes

`ConsumoComponenteArmado` registra por confirmación/bolsa el componente y la cantidad **incorporada**. La cantidad se valida contra la BOM congelada. Roturas o scrap consumen saldo en un hecho separado y no se suman al peso esperado del contenido.

- `EXACTA`: una o varias `AsignacionOrigenExacta` declaran origen y cantidad; su suma coincide con lo incorporado.
- `CONJUNTO_CANDIDATOS`: se consume desde un pool físicamente contado cuya genealogía enlaza N:M todos los orígenes plausibles sin inventar cantidades por candidato.
- `LEGACY_SIN_ORIGEN`: se consume desde una apertura/unidad legacy contada, con actor, motivo y Calidad; no permite saldo negativo ni crea una OT/lote ficticio.

Cada consumo enlaza la confirmación de bolsa y el lote WIP/producto resultante. La base de peso conserva tipo, valor, referencia, versión y momento de congelación. Solo genealogía `EXACTA` puede usar el promedio gobernado del lote exacto; candidatos/legacy usan snapshot de estructura o rango gobernado.

### 4.4. Resultado y manga

La unidad trazable primaria del resultado es la manga y su
`ConfirmacionBolsaOperacion`. Puede reservar identidad en estado planificado
antes del cierre, sin cantidad real, peso ni saldo.

- la manga contiene WIP si la salida congelada es `SUBENSAMBLE_WIP`;
- contiene `ProductoTerminado` si la operación completa la estructura
  comercial.

La confirmación conserva genealogía N:M hacia sus consumos. No se etiqueta
silenciosamente un resultado parcial como producto terminado.
[[Lote_Producto_Terminado]] queda como partida agrupadora opcional futura, no
como requisito para inventariar una manga PT.

### 4.5. Atribución de peso

Para una bolsa de productos armados:

```text
peso_neto_fisico_kg = medicion_balanza_bruto - tara

kg_estandar_ot_actual =
    SUM(cantidad_incorporada_actual * peso_unitario_base_gr) / 1000

kg_estandar_componentes_previos =
    SUM(cantidad_incorporada_previa * peso_unitario_base_gr) / 1000

desviacion_armado_kg =
    peso_neto_fisico_kg
  - kg_estandar_ot_actual
  - kg_estandar_componentes_previos
```

Los dos `kg_estandar_*` son derivados y se presentan como tales. Solo `peso_neto_fisico_kg` es una medición de la bolsa completa. Scrap, asas rotas u otros consumos que no quedaron dentro de la bolsa no participan en el peso esperado.

### 4.6. SaldoWIPSalida

Saldo por `LoteSalidaPiezaColor` de piezas buenas confirmadas que permanecen sueltas en línea. US-010C lo introduce y acredita; US-010F reutiliza su `ReservaWIPSalida` y lo debita como `CONSUMO_EN_LINEA_ARMADO`. No exige crear una bolsa intermedia y nunca puede quedar negativo. Véase [[Saldo_WIP_Salida]].

Antes de descargar una bolsa, central fija `modo_origen_cuerpo=SALDO_EXISTENTE | CREDITO_EN_LINEA_PENDIENTE`, cantidad máxima, estación y vigencia. Esos modos son mutuamente excluyentes; la estación no los elige offline.

### 4.7. AvanceArmado provisional

Evento operativo incremental e idempotente asociado a [[Orden_Operacion]] y bolsa planificada. Registra `delta_unidades`, actor, momento, `operation_id` y `bag_progress_seq`; actualiza inmediatamente `cantidad_prearmada_provisional_abierta`, pero no consume componentes ni acredita WIP/producto. Puede corregirse con otro evento enlazado.

Es **opcional** y no representa un registro por ciclo de máquina. En el
prearmado concurrente el maquinista no está obligado a digitar avances: el
responsable de Armado puede registrar un checkpoint agregado si necesita
visibilidad antes de cerrar la manga. La cantidad autoritativa siempre se
confirma en `CERRAR_MANGA_ARMADO`.

La pantalla separa siempre `prearmado provisional abierto` de `armado confirmado`. Al cerrar la bolsa, `provisional_cutoff_seq` concilia todos los avances hasta ese corte, registra cantidad final/diferencia/actor y deja de contarlos como abiertos. Un evento tardío dentro del corte se concilia al llegar; uno posterior no reabre una bolsa confirmada.

### 4.8. Cierre de Armado y pesaje separado

`CERRAR_MANGA_ARMADO` lleva su propio `operation_id` y contiene manga, orden,
`cantidad_real_confirmada`, `provisional_cutoff_seq`, asignaciones de
componentes, reserva/modo de origen, responsable y tiempos. Central lo aplica
en una transacción: concilia el avance, acredita la salida buena en línea si
aún no fue confirmada, aplica reservas, debita WIP e inventario, valida la BOM,
acredita el resultado de la manga y la deja
`CERRADA_ARMADO_PENDIENTE_PESAJE`.

Todas las mangas PT se pesan después. `CONFIRMAR_PESAJE_MANGA` registra bruto,
tara, neto, balanza, operador y tiempos sobre la misma identidad, sin repetir
consumos ni acreditar producción. Después de imprimir la etiqueta final queda
`PENDIENTE_RECEPCION_ALMACEN`.

Cada comando deduplica `(source_system, operation_id, payload_hash)` y genera
efectos hijos determinísticos. Un replay exacto devuelve el resultado
existente; reutilizar el ID con otro hash produce `IDEMPOTENCY_CONFLICT`. Un
fallo de balanza no revierte el cierre de Armado.

### 4.9. Calidad de componentes

Los componentes tomados de stock previo deben estar `LIBERADO`. Para cuerpos
que pasan directamente desde la OT se propone una política explícita
`USO_EN_PROCESO`; si Planta no la aprueba, también deberán liberarse antes del
armado.

La manga de salida se recibe primero en Almacén con Calidad `PENDIENTE`.
Calidad decide después `LIBERADA`, `BLOQUEADA` o `RECHAZADA`; solo la primera
queda disponible.

## 5. Invariantes

1. Ejecutar prearmado o armado no incrementa ciclos ni cavidades de la OT de inyección.
2. El peso del asa nunca se acredita como producción del molde actual.
3. Una manga de prearmado contiene WIP y una manga final contiene
   `ProductoTerminado`; ambas conservan su confirmación y genealogía propias.
   Una partida PT adicional es opcional.
4. La genealogía del resultado puede incluir componentes de distintos moldes, OTs, fechas y lotes.
5. La cantidad de unidades transformadas dentro de la bolsa es obligatoria; el peso no permite inferirla de forma autoritativa.
6. Consumir componentes y acreditar el resultado productivo ocurre al cerrar
   Armado. Confirmar el pesaje es una transacción idempotente posterior e
   independiente; el ingreso a inventario es todavía posterior.
7. Ningún componente puede consumirse dos veces por replay, doble F2 o pérdida de respuesta.
8. La suma de consumos no excede el saldo disponible en inventario o en `SaldoWIPSalida`. Genealogía legacy o candidata nunca exceptúa esta regla.
9. El nivel de genealogía se conserva y nunca se mejora automáticamente de candidatos a exacta.
10. El dashboard mantiene separados avance de máquina, avance de armado y peso físico embalado.
11. Un descuento porcentual de balanza no sustituye consumos ni genealogía.
12. Una corrección de peso, una de cantidad/estructura y una reapertura física son comandos distintos; compensan solo los efectos aplicables y no sobrescriben hechos confirmados.
13. Offline solo puede confirmar bolsas, reserva WIP y asignaciones de componentes previamente creadas/descargadas; no elige inventario ni `modo_origen_cuerpo` desconocidos por central.
14. Si el cuerpo ya fue acreditado como salida buena, el armado solo lo consume/asigna; si la confirmación ocurre en línea, acreditación y consumo comparten el mismo comando idempotente. Nunca se crean dos unidades producidas por el mismo cuerpo.
15. Un `AvanceArmado` provisional no altera stock, lote WIP/producto ni consumos definitivos; la confirmación lo concilia por bolsa/corte y los eventos tardíos no reabren el avance.
16. La confirmación final conserva cantidad planificada, provisional al corte, confirmada, diferencia, actor y motivo aplicable.
17. La [[Orden_Operacion]] no cierra con bolsas planificadas, reservas o comandos pendientes. Cerrar la OT de contexto no invalida una bolsa cuyos cuerpos buenos ya fueron acreditados, pero `CREDITO_EN_LINEA_PENDIENTE` bloquea esa OT hasta sincronizar o anularse.
18. Un fallo del cierre de Armado revierte todos sus consumos y acreditaciones.
    Un fallo de pesaje no revierte Armado y deja la manga pendiente de repesaje
    o conciliación.
19. Por cada bolsa y componente, `cantidad_incorporada = cantidad_confirmada * cantidad_estructura_snapshot`; sustitución o diferencia exige regla explícita. Scrap se consume aparte y no integra el peso esperado.
20. Cada consumo enlaza la confirmación, bolsa y lote WIP/producto concretos; una Orden de Operación con varias salidas no diluye genealogía entre ellas.
21. `CONJUNTO_CANDIDATOS` debita un pool contado con orígenes N:M sin reparto; `LEGACY_SIN_ORIGEN` debita una apertura contada. Ninguno inventa cantidades por fuente.
22. El piloto conectado no inicia la captura si central no está disponible; una confirmación rechazada permanece en `CONCILIACION`.
23. Los componentes previos requieren Calidad `LIBERADO`; el uso directo de cuerpos pendientes depende de la política `USO_EN_PROCESO` que Planta debe validar.
24. Confirmar menos que la reserva consume/acredita lo real y libera el sobrante en la misma transacción; confirmar más bloquea todo el comando y exige conciliación.
25. La misma operación puede ejecutarse entre ciclos y en estación dedicada sin cambiar artículo, estructura o genealogía.
26. Confirmar un prearmado parcial no acredita cobertura de producto terminado.
27. Esta historia ejecuta únicamente operaciones
    `executor_kind=ORDEN_ENSAMBLE`; una operación
    `ORDEN_FABRICACION` se resuelve mediante OF/OT en US-010C y no crea ambos
    agregados. Los valores anteriores son aliases transitorios.
28. La cantidad real es confirmada por el responsable de Armado en su módulo;
    la estación de balanza la muestra como solo lectura.
29. Toda manga PT debe pesarse antes de recepción de Almacén.
30. La recepción crea Calidad `PENDIENTE`; Calidad libera después de recibir,
    no antes.
31. La OA no puede planificar mangas sin un perfil de empaque aprobado y
    predeterminado, aunque el maestro real se cargue durante la puesta en
    marcha.
32. Una OA se ejecuta mediante una o más OT de Armado diarias. Cada manga
    pertenece exactamente a una OT, fecha operativa, turno y responsable.
33. Una OT de Armado ejecuta una sola OA. Trabajar dos OA el mismo día exige
    dos OT, aunque compartan equipo o centro.

## 6. Flujo principal: balde con asa como WIP

1. La OT actual inicia la producción del cuerpo de balde.
2. El responsable abre una OT de Armado para una porción diaria de la OA,
   con fecha operativa, turno, centro, responsable y equipo.
3. Las unidades buenas de cuerpo se confirman y acreditan al `SaldoWIPSalida` de su `LoteSalidaPiezaColor`; si el conteo real solo se conoce al cerrar la bolsa, se prepara para acreditarlo y consumirlo en el mismo comando.
4. Se reservan unidades/lotes `LIBERADO` de asas existentes —o un pool candidato/legacy contado— aunque provengan de otro molde u otra OT.
5. Central asigna a la OT una cuota del plan agregado de la OA, planifica sus
   mangas y reserva sus identidades; cada `PlanBolsa`
   congela `ReglaEmpaqueRevision`, `TipoContenedor`, cantidad, peso unitario y
   neto teórico. También crea `ReservaWIPSalida` con modo, cantidad máxima,
   estación y vigencia.
6. El módulo de Armado solicita las preetiquetas. Mientras no tenga impresora
   propia, central envía el trabajo a la impresora de la estación de pesaje.
7. Mientras arma, el responsable puede registrar incrementos opcionales
   `AvanceArmado` con secuencia por manga; esto no es una tarea obligatoria del
   maquinista ni de la estación de Fabricación.
8. El responsable cuenta y ejecuta `CERRAR_MANGA_ARMADO` con cantidad real,
   `provisional_cutoff_seq` y asignaciones. Central consume y acredita el
   resultado; la manga queda pendiente de pesaje.
9. US-010D pesa la manga completa. F2 envía `CONFIRMAR_PESAJE_MANGA`, sin
   consumo ni acreditación productiva.
10. Tras el acuse y etiqueta final queda
    `PENDIENTE_RECEPCION_ALMACEN`.
11. Almacén recibe por QR, crea Kardex con Calidad `PENDIENTE` y Calidad decide
    posteriormente su liberación.
12. La proyección conserva por separado cuerpos producidos por la OT,
    provisional abierto, conjuntos confirmados, componentes previos consumidos,
    scrap de armado y kg físicos embalados.

## 6.1. Pausa de una OT de armado

Una OT de armado puede pasar a `PAUSADA` por cambio de prioridad y reanudar
su saldo pendiente sin alterar la OA ni repetir consumos. La OA solo se muestra
pausada cuando no queda otra OT o ejecución activa para su objetivo.

La pausa conserva reservas de asas, cuerpos y otros componentes por defecto.
Liberar una reserva exige permiso, motivo y nueva evaluación. Las mangas con
contenido se deben cerrar y luego pesar; si no pueden cerrarse, se reconcilian
y anulan antes de abandonar la estación.

La pausa de una OT de armado puede ocurrir mientras la OT de fabricación de
contexto continúa. Son ejecuciones distintas y sus avances permanecen
separados.

## 7. Proyección de avance en tiempo real

Cada evento actualiza, sin doble conteo, una proyección acorde con su naturaleza:

- ciclos y unidades buenas por salida de la OT;
- kg estándar atribuibles a la OT actual;
- unidades prearmadas provisionales abiertas, excluyendo eventos ya conciliados por una bolsa confirmada;
- unidades WIP/producto confirmadas al cerrar cada bolsa;
- cantidades de componentes previos consumidas;
- scrap/rechazo de armado separado de lo incorporado;
- bolsas y kg físicos embalados;
- desviación física contra el peso esperado por estructura;
- recencia y estado de sincronización.

La interfaz no muestra un único “kg real de producción” cuando existen bolsas compuestas. Un peso raro explicado por una estructura ejecutada es una composición válida; solo el residual fuera de tolerancia genera alerta.

“Tiempo real” en este corte significa proyección local inmediata después de cada hecho registrado y actualización central después de sincronizar el evento. No se inventan ciclos o conjuntos durante una desconexión y la recencia permanece visible.

La granularidad mínima del prearmado es cada incremento manual registrado; la
del consumo definitivo es el cierre confirmado por Armado. El total operativo
no suma `provisional abierto + confirmado` como una única cifra sin etiqueta.
Si nadie registra incrementos, la interfaz no simula avance y actualiza el
confirmado cuando el responsable cierra la manga. El F2 de Balanza solo agrega
evidencia de peso.

## 8. Criterios de aceptación ATDD/BDD

### ASM-01 — Asa de otra OT y otro molde

**Dado** que `OT-000123` produce 100 cuerpos de balde y existen 100 asas liberadas de `OT-000087` fabricadas con otro molde  
**Cuando** se registran 100 baldes con asa  
**Entonces** la OT actual acredita únicamente los cuerpos  
**Y** el armado consume las 100 asas del lote anterior  
**Y** el lote WIP resultante conserva ambos orígenes.

### ASM-02 — Peso compuesto sin inflación

**Dado** 100 cuerpos de `180 g`, 100 asas de `20 g` y una bolsa con neto medido `20.300 kg`  
**Cuando** se confirma su pesaje  
**Entonces** el avance de inyección muestra `18.000 kg` estándar atribuibles a cuerpos  
**Y** el armado muestra `2.000 kg` estándar de asas previas  
**Y** embalaje muestra `20.300 kg` físicos  
**Y** la desviación de armado es `+0.300 kg`.

### ASM-03 — Cantidad obligatoria

**Dado** una bolsa planificada de WIP prearmado  
**Cuando** se intenta confirmar solo su peso sin cantidad de conjuntos  
**Entonces** el sistema bloquea el pesaje y no estima unidades dividiendo kilos.

### ASM-04 — Asas de múltiples lotes

**Dado** 60 asas del lote A y 40 del lote B  
**Cuando** se arman 100 baldes y se conoce el reparto  
**Entonces** se registra un consumo lógico incorporado de 100 y dos asignaciones exactas de 60/40  
**Y** ambas quedan enlazadas a la confirmación y bolsa resultante.

### ASM-05 — Conjunto de candidatos

**Dado** un pool contado de 100 asas antiguas mezcladas cuyos orígenes plausibles son A y B sin reparto conocible  
**Cuando** un responsable autorizado confirma el prearmado  
**Entonces** debita 100 del pool y registra A/B como candidatos sin cantidades individuales, con actor y motivo  
**Y** no debita 100 de cada lote ni afirma cuál aportó cada asa.

### ASM-06 — Stock legacy sin origen

**Dado** una apertura legacy previamente contada de 100 asas sin lote identificable  
**Cuando** se autoriza su uso  
**Entonces** debita esa existencia y queda `LEGACY_SIN_ORIGEN` con cantidad, Calidad, motivo y responsable  
**Y** no se crea una OF/OT ficticia ni se permite exceder el saldo contado.

### ASM-07 — Replays separados de Armado y Balanza

**Dado** una manga WIP de 100 baldes cerrada por Armado y luego pesada  
**Cuando** Armado reenvía su cierre o Balanza reenvía su pesaje  
**Entonces** cada comando devuelve su resultado previo  
**Y** no duplica manga, producción, consumo de asas ni peso  
**Y** cada efecto hijo conserva su ID derivado de `operation_id + tipo + line_key`.

### ASM-08 — Corrección coherente

**Dado** que se registraron 100 conjuntos pero la cantidad correcta era 98  
**Cuando** un usuario autorizado aprueba `CORRECCION_CANTIDAD_ESTRUCTURA` sin abrir ni repesar la bolsa  
**Entonces** se compensan dos cuerpos, dos asas y la proyección del lote WIP  
**Y** el peso físico original no cambia, se recalcula el residual y la razón permanece consultable.

### ASM-09 — Prearmado incompleto

**Dado** una ruta cuyo producto final exige cuerpo, asa y tapa  
**Y** existe el artículo WIP aprobado `Balde con asa prearmada`  
**Cuando** solo se unen cuerpo y asa  
**Entonces** se acredita el `LoteWIP` definido  
**Y** no se acredita todavía el `ProductoTerminado`.

### ASM-10 — Bolsa compartida sin armado

**Dado** cuerpos y asas sueltos colocados en la misma bolsa  
**Cuando** no existe unión física ni ejecución de estructura  
**Entonces** no se permite confirmarlos como `LOTE_WIP` o producto armado  
**Y** no se crea un lote de transformación  
**Y** se dirige al futuro flujo `CONTENEDOR_AGREGADO`, fuera del primer corte.

### ASM-11 — Piloto conectado

**Dado** una Orden de Operación, componentes reservados y una manga planificada  
**Cuando** central no está disponible  
**Entonces** la estación bloquea la confirmación del piloto  
**Y** no captura cantidad, consumos ni peso offline.

### ASM-12 — Avance incremental provisional

**Dado** una bolsa WIP planificada para 100 baldes prearmados  
**Cuando** el trabajador registra secuencias idempotentes `1:+10`, `2:+10` y `3:+5`  
**Entonces** la vista local muestra `25` prearmados provisionales y central muestra lo mismo al sincronizar  
**Y** el stock de asas, el saldo de cuerpos y el lote WIP de salida todavía no cambian.

### ASM-13 — Cierre de Armado atómico

**Dado** una manga con 25 conjuntos provisionales y componentes reservados  
**Cuando** `CERRAR_MANGA_ARMADO` confirma 24, pero falla la acreditación del resultado  
**Entonces** central revierte consumos, débito WIP y acreditación  
**Y** el comando puede reintentarse con el mismo `operation_id` sin producir efectos parciales.

### ASM-14 — Saldo WIP insuficiente

**Dado** un saldo de 40 cuerpos buenos de la OT actual  
**Cuando** se intenta confirmar una bolsa de 50 baldes prearmados  
**Entonces** el cierre se rechaza completo  
**Y** no consume asas ni acredita WIP  
**Y** la manga no queda habilitada para pesaje.

### ASM-15 — La OT contextual puede terminar antes

**Dado** una Orden de Operación abierta con componentes reservados, cuerpos buenos ya acreditados y una bolsa preparada  
**Cuando** la OT de contexto cierra con su producción y WIP conciliados  
**Entonces** el armado puede confirmar posteriormente esa bolsa  
**Y** la Orden de Operación continúa siendo la autoridad de sus pendientes y su cierre.

### ASM-16 — Cuerpo confirmado recién al cerrar la bolsa

**Dado** 24 cuerpos producidos en línea cuyo conteo bueno aún no fue acreditado y 24 asas reservadas  
**Cuando** `CERRAR_MANGA_ARMADO` confirma una bolsa de 24 baldes prearmados  
**Entonces** acredita 24 buenos al `SaldoWIPSalida` y los debita inmediatamente como `CONSUMO_EN_LINEA_ARMADO`  
**Y** el saldo neto queda en cero, la OT conserva 24 buenos y el armado consume exactamente 24 cuerpos.

### ASM-17 — Crédito en línea pendiente

**Dado** una manga armada cuya reserva central previa autoriza `CREDITO_EN_LINEA_PENDIENTE` hasta 24 cuerpos y cuya confirmación aún no terminó  
**Cuando** central intenta cerrar la OT de esos cuerpos  
**Entonces** la reserva `CREDITO_EN_LINEA_PENDIENTE` bloquea el cierre  
**Y** después de sincronizar o anular explícitamente la reserva, la OT vuelve a evaluar su balance sin aceptar producción tardía oculta.

### ASM-18 — Liquidación y evento provisional tardío

**Dado** avances de bolsa `1:+10`, `2:+10`, `3:+5` y una confirmación final de 24 con corte 3  
**Cuando** central aplica la confirmación y luego recibe repetido/tarde el evento de secuencia 2  
**Entonces** muestra 24 confirmados, diferencia provisional `-1` y cero provisional abierto para esa bolsa  
**Y** el evento tardío queda conciliado sin sumar nuevamente 10  
**Y** cualquier secuencia 4 posterior se rechaza o manda a conciliación porque la bolsa ya cerró.

### ASM-19 — Estructura incorporada y scrap separado

**Dado** una estructura de un cuerpo y un asa por WIP, 100 unidades confirmadas y 3 asas rotas durante el armado  
**Cuando** se confirma la bolsa  
**Entonces** registra 100 cuerpos y 100 asas incorporados, y 3 asas como `MermaComponenteArmado`  
**Y** consume 103 asas en total, pero calcula el peso esperado de la bolsa solo con las 100 incorporadas.

### ASM-20 — Genealogía por bolsa

**Dado** una Orden de Operación con bolsa 1 abastecida por asas A y bolsa 2 por asas B  
**Cuando** ambas se confirman  
**Entonces** cada consumo enlaza su propia confirmación/lote de salida  
**Y** consultar bolsa 1 no muestra B como origen exacto.

### ASM-21 — Base de peso con candidatos

**Dado** un pool con candidatos A/B sin reparto exacto  
**Cuando** se calcula el aporte estándar de sus asas  
**Entonces** usa el peso de `ESTRUCTURA_SNAPSHOT` o rango gobernado y conserva referencia/versión  
**Y** no selecciona el promedio real de A o B como si supiera cuál fue consumido.

### ASM-22 — Corrección de peso aislada

**Dado** una bolsa confirmada con conteo y consumos correctos, pero lectura de balanza incorrecta  
**Cuando** se autoriza `CORRECCION_PESO` y se repesa  
**Entonces** compensa la lectura y recalcula residual  
**Y** no vuelve a consumir cuerpos/asas ni modifica la cantidad del resultado.

### ASM-23 — Una operación, dos modos de ejecución

**Dado** una Orden de Operación para 1,000 prearmados  
**Cuando** se confirman 400 entre ciclos y 600 en estación dedicada  
**Entonces** ambas ejecuciones acreditan el mismo artículo WIP con lotes trazables  
**Y** la orden completa exactamente 1,000 unidades  
**Y** ninguna ejecución acredita producto terminado.

### ASM-24 — Cantidad confirmada por Armado

**Dado** una manga PT planificada para 100 unidades  
**Cuando** el responsable de Armado cuenta y confirma 98  
**Entonces** quedan plan 100, real 98, diferencia -2, actor y motivo
consultables  
**Y** Balanza recibe 98 como solo lectura.

### ASM-25 — Pesaje obligatorio de PT

**Dado** una manga PT cerrada por Armado  
**Cuando** se intenta recibirla en Almacén sin pesaje confirmado  
**Entonces** central rechaza el ingreso  
**Y** la manga permanece `CERRADA_ARMADO_PENDIENTE_PESAJE`.

### ASM-26 — Impresión remota temporal

**Dado** que Armado no posee impresora local  
**Cuando** solicita dos preetiquetas  
**Entonces** central crea un trabajo dirigido a la impresora configurada de la
estación de pesaje  
**Y** cada etiqueta conserva un QR distinto  
**Y** Balanza no puede cambiar cantidad, OA ni contenido.

### ASM-27 — Calidad después de recepción

**Dado** una manga PT pesada y recibida por Almacén  
**Cuando** se crea su movimiento inicial  
**Entonces** queda `RECIBIDA_PENDIENTE_CALIDAD` y no participa del saldo libre  
**Y** solo una decisión posterior de Calidad puede liberarla.

### ASM-28 — OA ejecutada en varias OT

**Dado** una OA para 1,000 unidades  
**Cuando** se asignan 400 a una OT del día 1, 500 a una OT del día 2 y 100 a una
OT del día 3  
**Entonces** cada manga pertenece a una sola OT y conserva su fecha, turno,
centro y responsable  
**Y** las tres OT acreditan en conjunto exactamente 1,000 a la OA  
**Y** ninguna OT mezcla otra OA.

## 9. Dataset de referencia

| Dato | Valor |
|---|---|
| OF / OT actual | `OF-0042 / OT-000123` |
| Artículo de salida | `WIP-BALDE-ASA` |
| Producto final de ruta | `PT-BALDE-COMPLETO` |
| Cuerpo actual | `PC-BALDE-FUC · 180 g · LSPC-000123-01` |
| Asa previa | `PC-ASA-FUC · 20 g · LSPC-000087-02` |
| Cantidad | `100 conjuntos` |
| Peso físico neto | `20.300 kg` |
| Aporte estándar actual | `18.000 kg` |
| Aporte estándar previo | `2.000 kg` |
| Desviación | `+0.300 kg` |

## 10. Permisos mínimos

- `ENSAMBLE_CREAR`
- `ENSAMBLE_INICIAR`
- `ENSAMBLE_AVANCE_REGISTRAR`
- `ENSAMBLE_CONSUMIR`
- `ENSAMBLE_MANGA_CERRAR`
- `ENSAMBLE_PREETIQUETA_SOLICITAR`
- `ENSAMBLE_COMPLETAR`
- `ENSAMBLE_CORREGIR_SOLICITAR`
- `ENSAMBLE_CORREGIR_APROBAR`
- `ENSAMBLE_USO_EN_PROCESO_AUTORIZAR`
- `GENEALOGIA_LEGACY_AUTORIZAR`

## 11. Fronteras con historias vecinas

- US-010C produce las piezas actuales, registra ciclos/unidades y permite destino `CONSUMO_EN_LINEA_ARMADO`.
- US-010D captura el peso físico de mangas ya cerradas por Armado y sincroniza
  idempotentemente; no confirma la BOM ni la cantidad PT.
- US-010R entrega artículo, estructura, ruta y perfil de empaque aprobados.
- US-010F congela la operación aplicable, consume componentes, crea el lote WIP/producto y calcula atribuciones derivadas.
- US-010G despacha unidades ya liberadas.
- US-011A continúa mostrando peso legacy mientras migra a la proyección normalizada; no debe reinterpretarlo como masa exclusiva de la máquina.

## 12. Fuera de alcance

- Sensores automáticos de ciclos u OEE completo.
- Inferir cantidades de resultado mediante división del peso.
- Afirmar el peso real individual del cuerpo o del asa sin una medición separada; para exactitud física se requeriría pesaje previo o muestreo de Calidad.
- Convertir un descuento porcentual legacy en genealogía.
- Crear automáticamente lotes ficticios para stock antiguo.
- Confirmar cuerpos/asas sueltos como `CONTENEDOR_AGREGADO`; requiere un corte posterior de agregación con contenidos hijos.
- Despacho del producto terminado.

## 13. Decisiones operativas

### 13.1. Validadas el 2026-07-30

| Decisión | Regla aceptada |
|---|---|
| ¿Quién confirma la cantidad real? | El responsable de Armado cuenta y confirma en su propio módulo antes del pesaje. |
| ¿Se pesan las mangas PT? | Todas, sin excepción normal. |
| ¿Dónde se imprimen las preetiquetas? | La solicitud nace en Armado. Temporalmente se enruta a la impresora del módulo de pesaje. |
| ¿Cuándo interviene Calidad? | Después de que Almacén recibe la manga; el ingreso nace con Calidad `PENDIENTE`. |
| ¿Cuál es la unidad mínima PT? | La manga y su confirmación. Una partida/lote PT adicional es opcional. |
| ¿Qué empaque usa PT? | Manga; el tipo y perfil reales se crearán posteriormente. Son obligatorios antes de planificar una OA real. |
| ¿Existe una OT diaria de Armado? | Sí. La OA conserva el objetivo agregado y se ejecuta mediante OT de Armado por fecha, turno, centro y responsable. |

### 13.2. Todavía por validar

| Decisión | Propuesta para el primer corte |
|---|---|
| ¿Cómo elegir las asas consumidas? | Escanear bolsas/lotes cuando estén identificados. FIFO puede proponer, pero el responsable confirma; mezcla conocida usa pool candidato y stock antiguo requiere apertura contada. |
| ¿Qué peso estándar usar para el asa? | `EXACTA` puede usar promedio gobernado de su lote; candidatos/legacy usan snapshot de estructura o rango gobernado. Siempre conservar tipo, referencia, versión y momento. |
| ¿Cómo tratar el residual? | Tolerancia configurable por artículo/estructura; advertencia con motivo y aprobación fuera de rango, sin negar el peso físico. |
| ¿Los cuerpos inline requieren liberación antes de armar? | Propuesta: política aprobada `USO_EN_PROCESO` para cuerpo de la misma corrida y lote resultante `PENDIENTE`; componentes tomados de stock siempre `LIBERADO`. |
| ¿Cómo tratar excedentes, faltantes y scrap? | Incorporado cumple estructura; sobrante utilizable se libera/devuelve. Una PiezaColor rota, aplastada o deformada consume saldo como merma de armado `RECUPERABLE_MOLIENDA` y continúa por [[US-010E_Molienda_y_Material_Recuperado_Trazable|US-010E]]; no vuelve como pieza disponible. |
| ¿Qué ocurre si central no está disponible? | El piloto bloquea la confirmación antes de capturar; operación offline queda para un incremento posterior. |
| ¿Cómo fijar el objetivo concurrente? | Planificación propone una cantidad por producto/máquina/turno; lo no ejecutado continúa en estación dedicada sin cambiar el artículo WIP. |

## 14. Definición de preparada

- [x] El armado está separado conceptual y contablemente de la inyección.
- [x] El caso de componentes de otro molde/OT está cubierto.
- [x] Peso físico, atribuciones derivadas y cantidades están separados.
- [x] Genealogía exacta, candidatos y legacy están definidos.
- [x] Replay y corrección tienen escenarios observables.
- [x] El saldo WIP en línea, avance provisional, cierre de Armado y pesaje
  separado tienen reglas y escenarios observables.
- [x] US-010R define artículo WIP, estructura multinivel, ruta y perfil de empaque.
- [x] La estructura revisionada y la genealogía por confirmación están definidas a nivel de dominio.
- [x] Planta valida actor de conteo, pesaje total, impresión temporal, recepción
  previa a Calidad y manga como unidad PT.
- [ ] Planta valida selección de orígenes, `USO_EN_PROCESO`, tolerancias,
  excedentes/scrap y objetivo concurrente.
- [ ] Se confirma una estructura, ruta y bolsa reales anonimizadas.
- [ ] Se registra línea base reproducible de central, frontend y estación.

Hasta cerrar esos pendientes, la historia permanece `en-refinamiento`.
