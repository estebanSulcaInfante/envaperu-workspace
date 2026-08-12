---
tipo: user-story
subtipo: historia-hija
estado: en-refinamiento
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, pesaje, manga, pesaje-intermedio, cierre-final, avance-color, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[Pesaje_intermedio_cierre_explicito_y_avance_por_color]]"
  - "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[US-010J_Alertas_Operativas_e_Inconsistencias]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[TS-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje]]"
  - "[[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final]]"
  - "[[Perfil_Empaque]]"
  - "[[Etiqueta_Manga]]"
  - "[[Orden_Fabricacion]]"
  - "[[Registro_Diario]]"
  - "[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]]"
  - "[[2026-08-01_Stickers_Prepesaje_como_Orden_Fisica_de_Manga]]"
fecha_creacion: 2026-08-07
fecha_actualizacion: 2026-08-07
---

# US-010K: Pesaje intermedio, cierre de mangas y avance por color

## 1. Decisión de alcance

Producción pesa normalmente al final del turno y necesita además un corte a
mitad del día. Algunas mangas no alcanzan su cantidad objetivo durante un solo
turno y pueden permanecer en llenado hasta tres días. El sistema debe observar
ese avance sin convertir cada lectura acumulada en otra bolsa, sin acreditar
prematuramente todas las unidades y sin crear inventario antes del cierre.

Esta historia reabre de manera explícita la decisión
[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]], que excluyó los
pesajes acumulativos del primer piloto. Mientras US-010K continúe
`en-refinamiento`, el comportamiento productivo vigente sigue siendo un único
pesaje final sobre una manga cerrada. La aprobación posterior de esta historia
exigirá una nueva decisión que reemplace parcialmente aquella regla, sin borrar
su historial ni sus criterios sobre OCR y cortes horarios.

El primer recorrido vertical cubre mangas simples de Fabricación. Las mangas
de WIP o producto obtenidas mediante Armado podrán reutilizar la semántica de
control, pero su confirmación de cantidades, consumos y genealogía continuará
gobernada por US-010F y no se modifica silenciosamente desde esta historia.

## 2. Historia de usuario

**Como** maquinista u operador de Balanza  
**Quiero** registrar lecturas intermedias de una manga con su mismo QR y decidir
explícitamente cuándo quedó completa  
**Para** observar el avance durante el día o entre turnos sin duplicar peso ni
producción, y conocer cuánto falta de la corrida/color antes de solicitar el
cambio al supervisor.

Como actor secundario, el supervisor necesita distribuir y transferir mangas,
resolver cierres parciales, ver la meta de la corrida y autorizar la continuidad
o el cambio de color sin pedir al maquinista que reconstruya documentos.

## 3. Resultado observable

1. Una manga conserva el mismo QR durante todo su llenado.
2. Admite cero o más `PESAJE_CONTROL` y un único `PESAJE_FINAL` vigente.
3. Cada control conserva bruto, tara y neto acumulado, pero no confirma
   unidades, no imprime postetiqueta y no habilita recepción ni Kardex.
4. La interfaz nunca suma controles acumulados como si fueran bolsas distintas.
5. El maquinista distingue con acciones explícitas `Registrar avance; sigue
   abierta` y `Completar manga; cerrar e imprimir`.
6. El cierre completo confirma la cantidad asignada sin pedirla nuevamente.
7. Un cierre definitivo por debajo de la asignación es una excepción distinta,
   exige conteo real, motivo y autoridad de supervisión.
8. Una manga puede continuar entre turnos u OT diarias compatibles sin cambiar
   de identidad ni ocultar qué trabajador y OT participaron.
9. La vista muestra la meta de la salida y de la corrida/color separando mangas
   cerradas, abiertas, sin iniciar, extras y anuladas.
10. Alcanzar la meta comunica que se debe detener ese color y avisar al
    supervisor; la pantalla no crea ni autoriza por sí sola otra corrida.
11. Una manga abierta sigue siendo no inventariable y Almacén bloquea su
    recepción.
12. Un cierre accidental puede reabrirse mediante compensación antes de
    Almacén; después de la recepción exige primero la reversa correspondiente.

## 4. Lenguaje de dominio

### 4.1. Pesaje de control

Observación física acumulada de una manga que continúa abierta. Registra la
lectura completa en ese momento, no solamente el incremento desde el control
anterior. Es repetible, inmutable e idempotente.

El delta se calcula para explicar el avance:

```text
delta_observado = neto_acumulado_actual - neto_acumulado_anterior_vigente
```

El delta no infiere unidades, no acredita producción y no mueve Kardex. Una
disminución fuera de tolerancia indica retiro de contenido, cambio físico o
error y requiere conciliación; nunca se oculta reemplazando la lectura previa.

### 4.2. Pesaje final completo

Decisión explícita de que la manga no recibirá más piezas y alcanzó la cantidad
individual que tenía asignada. Crea el único pesaje final vigente, confirma esa
cantidad, genera la postetiqueta y deja la manga pendiente de recepción en
Almacén.

El peso esperado puede ayudar a advertir una desviación, pero no decide por sí
solo que la manga está completa ni calcula cuántas unidades contiene.

### 4.3. Cierre final parcial

Cierre definitivo con una cantidad real menor a la asignada porque terminó la
corrida, cambió la prioridad o existe otra causa aprobada. No equivale a una
manga incompleta que seguirá llenándose. Exige conteo real, motivo y un actor
con autoridad; libera o replantea el remanente sin convertirlo en merma por
defecto.

### 4.4. Manga parcial planificada

La última manga de un plan puede tener desde el inicio un objetivo menor que la
capacidad estándar del contenedor. Esa manga está completa cuando alcanza su
propia cantidad asignada. No requiere una excepción por no llenar físicamente
la bolsa hasta su máximo.

### 4.5. Tramo de continuidad

Participación auditada de una OT y una asignación de maquinista en una manga
que permanece abierta. Conserva inicio, fin o relevo, responsable, OT de
contexto y controles que delimitan el tramo. Permite cerrar una OT diaria y
continuar la misma manga en otra OT compatible sin atribuir todo el resultado
al primer o al último día.

La forma de persistencia pertenece a la Tech Spec; la US solo exige que la
continuidad y sus actores sean observables.

### 4.6. Meta de corrida/color

Meta correspondiente a una corrida y `ColorProduccion` exactos, no a la simple
coincidencia del nombre visible del color. Conserva desglose por salida para
moldes multipieza y no mezcla otras corridas, recetas o lotes.

## 5. Invariantes

1. Una manga posee una identidad estable aunque se pese como control varias
   veces.
2. Una manga admite `0..N` controles y `0..1` pesaje final vigente.
3. Los controles son valores acumulados absolutos; para kg abiertos se usa solo
   el último control válido de cada manga, nunca la suma histórica.
4. Un control no confirma cantidad, no consume saldo definitivo, no acredita
   WIP/PT, no imprime postetiqueta y no crea inventario ni Kardex.
5. Solo el pesaje final habilita el tránsito hacia recepción.
6. El peso nunca se usa para inferir unidades.
7. Completar normalmente confirma la cantidad asignada; una cantidad distinta
   exige el flujo de cierre parcial o corrección autorizado.
8. La manga permanece ligada a un contenido, corrida/lote y color compatibles.
   Un cambio de color o corrida no reutiliza su QR.
9. Tara, tipo de contenedor y perfil congelados no se sobrescriben. Si la bolsa
   se rompe o se cambia el envase, se registra una transferencia controlada a
   otra identidad física.
10. Maquinista asignado y actor real de Balanza son atribuciones diferentes.
11. Un relevo conserva historial; no reemplaza silenciosamente el responsable
    anterior.
12. Una manga multi-jornada conserva los tramos de OT que contribuyeron. Su
    cierre no acredita todo el resultado a una sola OT sin evidencia.
13. Los deltas de peso pueden observar un tramo, pero no sustituyen el conteo
    necesario para atribuir unidades exactas por trabajador u OT.
14. Una manga abierta no bloquea el cierre de la OT anterior cuando fue
    transferida formalmente a una OT compatible y su tramo quedó conciliado.
15. Una OT no puede desprenderse de una manga abierta sin cierre, transferencia
    o anulación explícitos.
16. Un control o final repetido con la misma identidad y contenido devuelve el
    mismo resultado; con contenido diferente genera conflicto.
17. Dos estaciones no pueden confirmar concurrentemente dos finales de la
    misma manga.
18. La impresión fallida no revierte un pesaje final aceptado.
19. Reabrir una manga conserva los controles y el final invalidado, invalida la
    postetiqueta y no devuelve cupo porque la misma manga continuará llenándose.
20. Anular la manga es una operación distinta: termina su identidad y libera el
    remanente según el plan.
21. Si la manga ya ingresó a Almacén, reabrir o anular exige primero reversa de
    recepción.
22. Una manga abierta nunca aparece como disponible ni posee ubicación de
    inventario; puede tener únicamente una ubicación operacional informativa.
23. Las mangas `EXTRA` se muestran aparte; las anuladas no cuentan como avance
    ni como pendientes vigentes y sus reemplazos no duplican la meta.
24. En un molde multipieza, la corrida solo puede presentarse como completa
    cuando todas sus salidas requeridas están resueltas.
25. La estación puede sugerir porcentaje de llenado por peso objetivo, siempre
    marcado como estimado y sin usarlo para cerrar automáticamente.
26. Superar el bruto máximo físico bloquea el cierre y exige reenvasar o
    conciliar. El control puede conservar la evidencia con alerta.
27. El flujo normal del maquinista no contiene búsquedas, dropdowns ni entrada
    de OP, OT, pieza, color, cantidad o peso manual.

## 6. Flujo principal

1. El supervisor entrega al maquinista una preetiqueta asignada a una manga.
2. El maquinista escanea el QR en Balanza.
3. La estación muestra como solo lectura manga, máquina, corrida/color,
   artículo, cantidad objetivo, responsable actual, último control y meta.
4. La balanza obtiene una lectura estable.
5. El maquinista elige una de dos acciones grandes y excluyentes:
   - `Registrar avance — seguirá llenándose`;
   - `Completar manga — pesaje final e imprimir`.
6. Al registrar avance, central guarda un `PESAJE_CONTROL`, devuelve
   `AVANCE GUARDADO · USE EL MISMO QR`, limpia la pantalla y no imprime
   postetiqueta.
7. La manga vuelve a su máquina y puede repetir el flujo en el mismo turno o en
   jornadas posteriores.
8. Al completar, la interfaz confirma visiblemente la cantidad asignada que se
   declarará completa.
9. Central guarda el único pesaje final, cierra la manga e imprime su
   postetiqueta.
10. La manga queda `PENDIENTE_RECEPCION_ALMACEN`; todavía no existe en Kardex.

La asignación concreta de teclas rápidas se decide en la Tech Spec y se prueba
con la estación física. No se fija un checkbox persistente como único control
porque olvidar su estado puede cerrar una manga por error.

## 7. Información de avance y ayuda para el color

Después de resolver el QR, la estación presenta dos niveles:

### 7.1. Esta salida o pieza

- meta en unidades y mangas normales;
- mangas cerradas;
- mangas en llenado;
- mangas entregadas sin control;
- mangas pendientes de asignar o iniciar;
- mangas que faltan cerrar;
- kg abiertos observados usando el último control válido, con marca
  `REFERENCIAL`;
- extras y anuladas en contadores separados.

### 7.2. Corrida/color completo

Muestra el mismo resumen agregado por todas las salidas requeridas de la
corrida. La estación deriva uno de estos mensajes operativos:

- `CONTINUAR`: todavía quedan mangas por iniciar;
- `COMPLETAR ABIERTAS — NO ABRIR OTRA`: el saldo pendiente ya está cubierto por
  capacidad asignada a mangas abiertas;
- `META COMPLETA — DETENGA ESTE COLOR Y AVISE AL SUPERVISOR`: no quedan salidas
  normales pendientes ni mangas abiertas por resolver;
- `EXCESO O INCONSISTENCIA — AVISE AL SUPERVISOR`: el avance supera el plan o
  las salidas no concilian.

La estación nunca ordena `Cambiar a azul` ni crea una nueva corrida. El cambio
requiere instrucción supervisada, materiales/receta y OT válidos.

## 8. Estados y eventos

Proyección mínima de la manga:

```text
PLANIFICADA -> ASIGNADA -> PREETIQUETADA -> EN_LLENADO
                                              |  ^
                              PESAJE_CONTROL --+  | transferencia/relevo
                                              |
                       PESAJE_FINAL_COMPLETO --+-> PENDIENTE_RECEPCION_ALMACEN
                       PESAJE_FINAL_PARCIAL  --+
```

`PESAJE_CONTROL` es un evento hijo; no es necesario crear un estado diferente
por cada lectura. `EN_LLENADO` puede derivarse de la existencia de controles o
del inicio formal de la manga. Desde estados anteriores al final puede existir
`ANULADA`; una inconsistencia física lleva a `CONCILIACION` sin borrar hechos.

## 9. Escenarios ATDD/BDD

### PMI-01 — Primer control mantiene la manga abierta

**Dado** una manga preetiquetada para 1,000 unidades y sin lecturas  
**Cuando** el maquinista registra un control neto de `6.400 kg`  
**Entonces** la manga queda `EN_LLENADO`, conserva su QR y registra el control  
**Y** no confirma 1,000 unidades, no imprime postetiqueta, no habilita Almacén
ni crea Kardex.

### PMI-02 — Lecturas acumuladas no se suman

**Dado** controles vigentes de `6.400 kg` y `13.850 kg` sobre la misma manga  
**Cuando** se consulta su avance  
**Entonces** el contenido observado actual es `13.850 kg` y el último delta es
`7.450 kg`  
**Y** el sistema nunca presenta `20.250 kg` como contenido ni como producción.

### PMI-03 — Cierre final explícito

**Dado** la manga anterior todavía abierta  
**Cuando** el maquinista elige completar y confirma un neto final de
`19.920 kg`  
**Entonces** existe un único pesaje final, se confirman sus 1,000 unidades, se
genera postetiqueta y queda pendiente de recepción  
**Y** los controles previos siguen consultables sin sumarse al final.

### PMI-04 — Replay y doble confirmación

**Dado** que central aceptó un control o final pero la estación perdió el acuse  
**Cuando** repite exactamente la misma operación, incluso por doble tecla  
**Entonces** devuelve el mismo hecho sin duplicar lecturas, unidades, etiquetas
ni estados.

### PMI-05 — Reescaneo de manga abierta

**Dado** una manga con dos controles y sin final  
**Cuando** se vuelve a escanear su QR  
**Entonces** la estación muestra `ABIERTA`, último neto, delta, antigüedad,
responsable y meta  
**Y** permite otro control o su cierre explícito.

### PMI-06 — Continuidad durante tres días

**Dado** una manga del mismo lote/corrida/color que no completa su objetivo el
primer ni el segundo día  
**Cuando** se transfiere formalmente entre tres OT compatibles y se finaliza en
la tercera  
**Entonces** conserva el mismo QR y el historial de tramos, OT, responsables y
controles  
**Y** las OT diarias anteriores pueden cerrar una vez conciliado y transferido
su tramo.

### PMI-07 — Relevo de maquinista

**Dado** una manga abierta asignada a Juan  
**Cuando** el supervisor registra el relevo hacia Rosa  
**Entonces** el QR no cambia, Juan permanece en el historial y Rosa se muestra
como responsable actual  
**Y** el actor que opera Balanza se registra por separado.

### PMI-08 — Peso acumulado decreciente

**Dado** un último control de `13.850 kg`  
**Cuando** la siguiente lectura es `12.100 kg` fuera de tolerancia  
**Entonces** central conserva ambas lecturas y deriva la manga a conciliación
con motivo  
**Y** no acredita un delta negativo ni corrige silenciosamente el control
anterior.

### PMI-09 — Manga abierta no recepcionable

**Dado** una manga con uno o varios controles y sin pesaje final  
**Cuando** Almacén escanea su QR  
**Entonces** informa `MANGA AÚN EN LLENADO`, muestra el último control como dato
informativo y bloquea recepción y Kardex.

### PMI-10 — Última manga parcial planificada

**Dado** que el plan asignó deliberadamente 230 unidades a su última manga,
aunque el perfil estándar admita 1,000  
**Cuando** el maquinista la completa  
**Entonces** el cierre normal confirma 230 unidades sin exigir excepción por
no llenar la capacidad máxima.

### PMI-11 — Cierre final parcial

**Dado** una manga asignada para 1,000 unidades que terminará definitivamente
con 820 por fin de corrida  
**Cuando** un supervisor confirma el conteo real y el motivo  
**Entonces** se cierra con 820, se conserva la diferencia y las 180 restantes
se liberan o replantean de forma explícita  
**Y** no se declaran automáticamente como merma.

### PMI-12 — Meta visible sin doble conteo

**Dado** una corrida con 12 mangas normales: 8 cerradas, 2 abiertas y 2 sin
iniciar  
**Cuando** se pesa una de las mangas abiertas como control  
**Entonces** la vista mantiene 8 cerradas, 2 abiertas, 2 sin iniciar y 4 por
cerrar  
**Y** no aumenta el número de mangas producidas.

### PMI-13 — Meta multipieza

**Dado** un molde que produce simultáneamente cuerpo y tapa del mismo color  
**Y** el cuerpo alcanzó su meta, pero aún existen mangas de tapa pendientes  
**Cuando** el maquinista consulta la corrida  
**Entonces** la salida cuerpo figura completa, pero la corrida no muestra
`META COMPLETA` ni recomienda detener el color.

### PMI-14 — Cambio de corrida o color

**Dado** una manga abierta de una corrida/color  
**Cuando** se libera otra corrida, aunque tenga un nombre de color parecido  
**Entonces** la manga anterior no puede reutilizarse para el nuevo contenido  
**Y** debe completarse, transferirse dentro de la corrida compatible, conciliarse
o anularse.

### PMI-15 — Reapertura por cierre accidental

**Dado** una manga cerrada por error y todavía no recibida en Almacén  
**Cuando** el Jefe de Producción autoriza `REABRIR_MANGA` con motivo  
**Entonces** se invalidan compensatoriamente el final y su postetiqueta, la
manga vuelve a llenado y conserva su cupo e historial  
**Y** si ya fue recibida, la acción exige primero la reversa de recepción.

### PMI-16 — Fallo de impresión final

**Dado** un pesaje final aceptado  
**Cuando** falla la impresión de la postetiqueta  
**Entonces** el final sigue vigente, la manga no vuelve a llenado y se permite
el reemplazo autorizado del soporte sin repetir la balanza.

### PMI-17 — Flujo normal sin digitación

**Dado** una preetiqueta vigente y la balanza estable  
**Cuando** el maquinista registra un control o completa la manga  
**Entonces** solo escanea, elige una de las dos acciones y confirma  
**Y** no escribe OT, máquina, color, artículo, cantidad ni peso.

## 10. Dataset reproducible

| Dato | Valor |
|---|---|
| OF / corrida | `OF-0021 / C01` |
| Color | `AZUL SÓLIDO` |
| Manga | `OF0021-OT0410-M007` |
| Cantidad asignada | `1,000 un` |
| Neto objetivo referencial | `20.000 kg` |
| Día 1 / OT / control | `2026-08-10 / OT-000410 / 6.400 kg` |
| Día 2 / OT / control | `2026-08-11 / OT-000425 / 13.850 kg` |
| Día 3 / OT / final | `2026-08-12 / OT-000438 / 19.920 kg` |
| Deltas observados | `6.400 / 7.450 / 6.070 kg` |
| Resultado físico final | `19.920 kg`, nunca `40.170 kg` |
| Meta de corrida | `12 normales: 8 cerradas, 2 abiertas, 2 sin iniciar` |

## 11. Permisos funcionales propuestos

- `MANGA_CONTROL_PESO_REGISTRAR`: maquinista u operador de Balanza.
- `MANGA_FINALIZAR_COMPLETA`: maquinista u operador autorizado.
- `MANGA_FINALIZAR_PARCIAL`: supervisor o Jefe de Producción.
- `MANGA_TRANSFERIR_OT`: supervisor.
- `MANGA_REASIGNAR_MAQUINISTA`: supervisor.
- `MANGA_REABRIR`: Jefe de Producción, con motivo.
- `CORRIDA_CAMBIO_COLOR_AUTORIZAR`: jefatura responsable de Producción.

La Tech Spec debe mapear estas capacidades a la matriz vigente sin confiar en
un rol enviado por el frontend.

## 12. Errores, correcciones y reintentos

- Un control inválido se compensa o invalida con motivo; nunca se elimina.
- Un cierre accidental usa `REABRIR_MANGA`, no `ANULAR_PESAJE`, porque la misma
  manga y su cupo continuarán vigentes.
- Una anulación real termina la manga, invalida sus etiquetas y devuelve el
  remanente correspondiente al plan.
- Una lectura decreciente, cambio de tara/envase, sobrepeso físico o diferencia
  no explicada conduce a conciliación.
- Cada control y final posee su propia clave idempotente.
- La operación concurrente usa versión o bloqueo para impedir dos finales.
- Durante el piloto, central no disponible bloquea controles y finales; no se
  inventan eventos offline.
- La política de antigüedad de manga abierta debe ser configurable por perfil o
  tipo. Una duración esperada de tres días no genera por sí sola una alerta de
  atraso si está dentro de esa política.

## 13. Fuera de alcance

- Inferir unidades desde kg o desde el porcentaje de llenado.
- Autorizar automáticamente un cambio de color, receta, corrida u OT.
- Mezclar corridas o lotes por compartir el mismo nombre de color.
- Crear Kardex, ubicación de inventario o disponibilidad desde un control.
- Reemplazar la supervisión de un cierre parcial por una decisión del peso.
- Definir en esta US tablas, endpoints o teclas definitivas de la estación.
- Operación offline.
- Atribuir exactamente unidades por tramo cuando Planta no haya definido una
  fuente de conteo válida.
- Extender automáticamente el comportamiento a bolsas transformadas de Armado
  sin validar sus consumos y genealogía.

## 14. Decisiones operativas por validar

1. ¿Los controles intermedios son solamente evidencia/visibilidad, como se
   propone, o la empresa necesita que acrediten algún indicador oficial?
2. Cuando una manga cruza varias OT, ¿se requieren unidades exactas por OT y
   trabajador? Si la respuesta es sí, ¿quién registra el conteo al relevo sin
   trasladar digitación al maquinista?
3. ¿La meta principal que espera Planta es corrida/OF, OT/máquina o ambas? La
   recomendación es mostrar ambas, usando la corrida como autoridad para el
   cambio de color.
4. ¿Qué perfiles o productos pueden permanecer abiertos varios días y cuál es
   su plazo esperado antes de alertar?
5. ¿El control intermedio requiere algún comprobante físico? La recomendación
   es conservar la preetiqueta y no imprimir otro sticker.
6. ¿Quién puede cerrar definitivamente por debajo de la cantidad asignada? La
   propuesta asigna esa excepción a supervisión.
7. ¿Se exige nombre del responsable vigente impreso en la preetiqueta? Si es
   así, cada relevo obliga a reemplazarla; la recomendación es que el QR y la
   vista central conserven el historial y que el texto físico identifique solo
   al responsable inicial.
8. Validar el nombre de planta del producto o familia mencionado como mangas
   que tardan hasta tres días, para documentarlo sin ambigüedad.
9. Validar como línea base que una manga conserve una OT de origen para código,
   cupo e identidad, y que el encargado pueda reasignar trabajador únicamente
   mediante eventos auditados, nunca sobrescribiendo historia.
10. Decidir si los perfiles multi-jornada usarán cierre final parcial diario o
    tramos de continuidad hacia otras OT compatibles. Una reasignación manual
    de trabajador no resuelve esta frontera.
11. Definir la custodia física de stickers: generados, impresos no entregados,
    entregados no iniciados y pegados en manga abierta requieren acciones
    diferentes. Si el nombre del trabajador permanece impreso, el relevo exige
    reemplazo versionado de etiqueta.

## 15. Impacto sobre decisiones y especificaciones vigentes

Al aprobar la historia se debe:

1. registrar una decisión que reemplace parcialmente
   [[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]];
2. crear `TS-010K_Pesaje_Intermedio_y_Cierre_Final_de_Mangas`;
3. actualizar US-010C/D/P para permitir controles y transferencias compatibles
   sin debilitar los cierres de OT;
4. actualizar TS-010C/D, dominio de peso/manga, contrato de estación y
   endpoints;
5. actualizar la vista de Balanza, el avance por color, la guía operativa y la
   UAT C/D;
6. dividir Approved for Dev en, como mínimo, controles/cierre/meta y
   continuidad multi-OT/relevos si el riesgo técnico lo exige.

## 16. Definición de preparada

- [x] Actor, necesidad y resultado de negocio identificados.
- [x] Diferencia entre control, final completo y final parcial declarada.
- [x] Regla contra doble conteo y frontera con Almacén/Kardex declaradas.
- [x] UX normal sin digitación descrita sin fijar implementación prematura.
- [x] Dataset de tres días y escenarios principales reproducibles.
- [x] Correcciones, reintentos, concurrencia y reversa de recepción cubiertos.
- [ ] Planta valida las decisiones del apartado 14.
- [ ] Se acuerda la fuente de atribución por OT para una manga multi-jornada.
- [ ] Se registra una línea base automatizada que demuestre el comportamiento
      actual de un único pesaje final.
- [ ] Se prueba con Balanza e impresora que las dos acciones son inequívocas.
- [ ] Se aprueba formalmente la sustitución parcial de la decisión de 2026-08-01.

Hasta cerrar las casillas pendientes, esta historia no pasa a Tech Spec ni se
declara lista para desarrollo.
