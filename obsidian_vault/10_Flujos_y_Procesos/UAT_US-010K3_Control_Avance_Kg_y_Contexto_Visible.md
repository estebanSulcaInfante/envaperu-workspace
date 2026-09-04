---
tipo: uat
estado: uat-local-ux-rejected
uat_id: UAT-US-010K3
modalidades_uat: [funcional, operativa, fisica]
historia: "[[US-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
tech_spec: "[[TS-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
dev: "[[DEV-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
perfiles_uat:
  - "[[PERF_UAT_Estacion_Pesaje]]"
  - "[[PERF_UAT_Lector_Compartido_Tablet]]"
  - "[[PERF_UAT_Impresion]]"
  - "[[PERF_UAT_Conectividad_Contingencia]]"
  - "[[UAT_US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: rejected
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
fecha_preparacion: 2026-08-31
tags: [uat, scm, pesaje, avance-kg, manga-incompleta, qr, impresion]
---

# UAT US-010K3 — avance en kg y contexto visible en Pesaje

## 1. Objetivo y alcance

| Campo | Valor |
|---|---|
| UAT / `RUN_ID` | `UAT-US-010K3-RUN-____` al ejecutar. |
| Resultado | Una manga puede recibir uno o varios controles acumulados en kg sin conteo, sin corte de tramo y sin quedar bloqueada; después puede seguir llenándose y cerrarse con la misma acción. |
| Entorno | Primero demo local aislada; después `PESAJE-PLANTA-01` con versión/commit anotados antes del run. |
| Responsable | Pendiente de designación humana. Renato Peña Damián puede participar como operador representativo si el responsable del piloto lo confirma. |
| Lugar | PC, balanza, lector QR e impresora TSC de Pesaje. |
| Escenario reiniciable | Usar mangas dedicadas; cada repetición usa otra manga u otra `operation_id`. No borrar controles ni reutilizar una identidad cerrada. |

Incluye el checkbox `Manga incompleta`, botón único/F2, controles `AVANCE_KG`,
foco del lector, correlativo dominante, anuncio de cambio de manga, foto opcional,
sticker CONTROL sin QR/conteo/estándar, reintento idempotente y cierre posterior.
La identidad del contenido incluye además nombre y muestra de color; la familia
Transparente usa un patrón cuadriculado que debe validarse frente a blanco sólido.
Excluye conteo durante fabricación, inferencia de unidades desde kg, operación
offline autoritativa, relevo entre trabajadores y despliegue productivo.

Riesgo `high`: una señal ambigua puede cerrar una manga, atribuir producción o
pegar evidencia en la unidad equivocada. Modo de contingencia:
`bloqueo-seguro`; sin acuse de Central no hay éxito ni impresión autoritativa.

## 2. Contexto por completar antes de la UAT física

- modelo/protocolo de balanza, precisión y criterio real de estabilidad;
- modelo/configuración del lector y confirmación del sufijo Enter;
- modelo/driver/DPI de la impresora, papel `109 × 50 mm` y márgenes;
- resolución, escalado, navegador, distancia, postura, manos y EPP reales;
- procedimiento autorizado para papel agotado, spooler detenido y emisión
  incierta;
- pieza-color con foto y otra sin foto para probar ambas variantes.

Información primaria: NET, `MANGA ACTIVA`, código completo, artículo/foto y
modo `Manga incompleta`. Acción primaria: `Pesar manga (F2)`. Datos de OT,
color y diagnóstico permanecen secundarios.

## 3. Preparación y baseline

1. Crear dos mangas normales abiertas y con preetiqueta vigente: `M001` con
   foto de pieza y `M002` sin foto.
2. Registrar sus `manga_id`, `label_id`, Trabajo, tramo activo, estado e
   inventario/producción antes de comenzar.
3. Para `M001`, preparar lecturas acumuladas: bruto `4.830`, tara `0.030`,
   NET `4.800`; luego bruto `8.980`, NET `8.950`; final bruto `12.030`, NET
   `12.000`.
4. Verificar que el único QR físico sea la preetiqueta. Los stickers de control
   no deben crear otra identidad.
5. Detener la prueba si cambia la tara/fuente, el QR queda cubierto, Central no
   acusa, la impresión es incierta o la pantalla muestra otra manga.

## 4. Secuencia física y digital

| Paso | Acción | Debe percibirse antes/después | Efecto esperado | Evidencia |
|---|---|---|---|---|
| 1 | Escanear `M001` + Enter. | `MANGA ACTIVA`, código grande, artículo y foto; anuncio `QR leído`. Input vuelve a quedar enfocado. | Solo resolución; cero control, pesaje, producción o Kardex. | Pantalla e IDs antes/después. |
| 2 | Aplicar `4.830 kg`, marcar `Manga incompleta` y pulsar el único botón/F2. | Modo indica avance en kg y que seguirá abierta. | Un `AVANCE_KG`: NET `4.800`, aporte `4.800`, conteo nulo; manga/tramo/Trabajo activos; cero producción/inventario. | Respuesta, DB y sticker. |
| 3 | Sin volver a escanear, mantener el mismo peso. | Resultado confirmado, input QR enfocado y botón bloqueado con instrucción de agregar peso. | No nace otro hecho. | Pantalla y conteo de controles. |
| 4 | Aumentar a `8.980 kg`, volver a marcar incompleta y F2. | Lectura lista nuevamente. | Segundo control en el mismo tramo: NET `8.950`, aporte `4.150`; no suma netos ni bloquea manga. | Dos controles, mismo tramo y segundo sticker. |
| 5 | Escanear `M002` + Enter sin mouse. | Anuncio `Cambio de manga confirmado: M001 → M002`; código y fallback `Sin foto registrada`. | Contexto anterior no puede recibir la próxima confirmación. | Video/captura y IDs. |
| 6 | Volver a `M001`, elevar a `12.030 kg`, dejar checkbox apagado y F2. | Modo `cierre final`; misma posición/botón. | Un cierre final, NET `12.000`, aporte desde último control `3.050`, crédito/inventario según el contrato vigente. | Pesaje final, estados y sticker. |
| 7 | Releer el QR original ya con dos CONTROL y FINAL pegados. | Se resuelve la identidad correcta. | Un QR vigente; los controles/final no incorporan QR. | Foto y lectura real. |

## 5. Criterios instanciados por perfil

| IDs fuente | Criterio concreto | Resultado esperado | Evidencia | Estado |
|---|---|---|---|---|
| `PES-01..04` | NET domina desde la postura real; manga/modo permanecen visibles; bruto, tara y NET usan kg/3 decimales. | Operador identifica primero NET y manga sin confundir el control con un cierre. | Foto desde el puesto y captura del viewport. | REJECTED UAT LOCAL — dos cierres accidentales por omitir Control |
| `PES-COLOR-01` | Escanear una pieza Transparente y otra blanca sólida. | Ambas conservan nombre; Transparente muestra cuadriculado y blanco muestra relleno blanco con borde, sin confusión. | Capturas lado a lado y relato del operador. | AUTO GREEN / HUMANA PENDING |
| `PES-05..06` | Enter solo resuelve; F2 queda bloqueado sin contexto, con lectura inválida o sin aumento sobre el último control. | Mensaje explica causa y recuperación. | Estados y ausencia de mutación. | AUTO GREEN / FÍSICA PENDING |
| `PES-07` | Doble F2/click y respuesta perdida reutilizan la operación. | Un control y un trabajo de impresión. | `operation_id`, control/job y auditoría. | AUTO GREEN / FÍSICA PENDING |
| `PES-08` | QR vencido, inválido o de otro módulo no cambia el contexto autoritativo ni muta. | Rechazo textual seguro. | Capturas y conteos. | PENDING |
| `PES-09..10` | Operador completa la acción con manos/EPP reales y reconoce NET, estado abierto y siguiente acción. | Sin ayuda crítica ni casi-error. | Tiempo, video y relato. | PENDING |
| `PES-11` | Escanear `M002` hace inequívoco el cambio desde `M001`. | No se pesa sobre la manga anterior. | Anuncio, código y evento. | AUTO GREEN / FÍSICA PENDING |
| `PES-12` | Fallo después de capturar no comunica éxito falso ni exige volver a pesar a ciegas. | Estado incierto/bloqueado con recuperación. | Fallo controlado. | PENDING |
| `LEC-01..05` | El lector envía Enter, el código activo domina, el foco vuelve al input y cambiar QR limpia la intención anterior. | Tres mangas consecutivas sin volver a hacer click. | Video y orden de foco. | AUTO GREEN / FÍSICA PENDING |
| `LEC-09..12` | Éxito/error usan texto; duplicados o escaneos incompletos no duplican; el recorrido funciona sin mouse y recupera tras reconectar. | Trazabilidad y siguiente acción inequívocas. | Secuencia rápida y reinicio. | PENDING |
| `IMP-01..03` | TSC, DPI, papel y 2-up coinciden con preview; NET/aporte/estado son legibles. | Papel coincide con SVG/TSPL. | Preview y foto lado a lado. | PENDING |
| `IMP-04..06` | QR original sigue legible; cada CONTROL se asocia a la manga; columnas no mezclan identidades. | CONTROL sin QR y preetiqueta conservada. | Lectura y muestras físicas. | PENDING |
| `IMP-07..11` | Fallo/reintento/copia controlada mantienen un hecho y un job auditable. | No reimpresión ciega ni QR duplicado. | Historial de impresión. | AUTO PARCIAL / FÍSICA PENDING |
| `IMP-12` | Sticker de control no muestra conteo ni peso estándar; neto y aporte dominan. | `AVANCE EN KG · SIN CONTEO`, `SIN QR`. | TSPL, SVG y papel. | AUTO GREEN / FÍSICA PENDING |
| `CON-01..03` | Aplica bloqueo seguro antes de resolver o confirmar. | Sin acuse no hay control ni impresión autoritativa. | Estado y conteos. | PENDING |
| `CON-04..07` | Pérdida de respuesta, reinicio, reconexión y replay conservan un solo efecto. | Recuperación con la misma operación; objeto segregado durante incertidumbre. | IDs, logs saneados y foto. | AUTO GREEN / FÍSICA PENDING |
| `CON-09..12` | UI distingue sin confirmar/confirmado/impresión, no comunica éxito falso y guía el reintento sin secretos. | Operador sabe si agregar peso, reintentar o detener. | Capturas y relato. | PENDING |

`LEC-06..08` se descartan en este incremento: no se define timeout ni relevo y
el dispositivo objetivo es PC, no tablet. `CON-08` no aplica porque el control
no reserva ni libera stock. Se reabren si cambia el contexto físico.

## 6. Negativos e idempotencia

| ID | Caso | Resultado esperado | Estado |
|---|---|---|---|
| `NEG-COUNT` | Intentar enviar conteo con `AVANCE_KG`. | Rechazo de contrato; el flujo normal nunca presenta input de unidades. | AUTO GREEN |
| `NEG-MONO` | Control/final con NET igual o menor al último control. | UI bloquea el caso ordinario y Central rechaza si llega. | AUTO GREEN / FÍSICA PENDING |
| `NEG-TARA` | Cambiar tara o fuente entre controles. | `CONTROL_TARE_NOT_COMPARABLE`; sin control/job. | AUTO GREEN |
| `NEG-QR` | QR de otro módulo, cerrado o reemplazado. | Rechazo sin movimiento. | PENDING |
| `IDEM-01` | Doble control con la misma clave. | Un control, un job y una sola impresión/recovery seguro. | AUTO GREEN / FÍSICA PENDING |
| `OFF-01` | Central no disponible. | Botón bloqueado o error explícito; sin éxito ni papel autoritativo. | PENDING |

## 7. Observación y veredicto

Entregar al operador estas tareas sin indicarle dónde pulsar: registrar un
avance, continuar agregando peso, cambiar a otra manga y cerrar la primera.
Anotar tiempo, ayuda, dudas, retrocesos y casi-errores. La foto es apoyo y no
puede sustituir el código/nombre del artículo.

| Campo | Valor actual | Regla de salida |
|---|---|---|
| `functional_validation` | `qa_green` | Cambia a `uat_accepted` solo con revisión funcional humana. |
| `ux_validation` | `rejected` | Rediseñar la intención control/cierre; después repetir sin ayuda crítica ni P0/P1. |
| `physical_uat` | `pending` | Requiere balanza, lector, impresora, papel y mangas reales. |
| `release_constraint` | `no_habilitar_en_planta` | No retirar hasta aceptar UX y UAT física. |

**Fecha/run:** ______  
**Responsable:** ______  
**Operador:** ______  
**Versión Central/estación:** ______  
**Veredicto y firma humana:** ______

## 8. Ejecución local simulada 2026-09-01

| Campo | Valor |
|---|---|
| `RUN_ID` | `UAT-US-010K3-RUN-LOCAL-20260901-01` |
| Entorno | PostgreSQL local aislado `enva_uat_recorrido`; Central `127.0.0.1:5100`; estación `127.0.0.1:5051`; balanza e impresión simuladas. |
| Documentos | `OP-000001` → `OF-000001` → `OT-000001`; Trabajo `OT-000001-TC01`. |
| Mangas | `OF000001-OT001-M001` y `OF000001-OT001-M002`, ambas con preetiqueta impresa en simulación. |
| Operador/maquinista simulado | Operador local UAT; maquinista `Jose Quispe`. |
| Veredicto | Secuencia digital local verde; no equivale a aceptación humana ni UAT física. |

Evidencia de la secuencia:

1. `M001` se resolvió y mostró el código completo como información dominante,
   el artículo y el fallback `Sin foto registrada`; el input QR quedó enfocado.
2. El primer avance guardó bruto `4.830`, tara `0.030`, NET `4.800`, aporte
   `4.800`, tipo `AVANCE_KG` y conteo nulo. La manga siguió abierta y el
   sticker `CONTROL_PESO` quedó `IMPRESA` en simulación.
3. Sin reescanear, el mismo peso dejó F2 bloqueado hasta agregar peso.
4. El segundo avance guardó bruto `8.980`, NET `8.950`, aporte `4.150`, en el
   mismo contexto, también sin conteo y con otro sticker de control sin QR.
5. El lector anunció textualmente `M001 → M002`; luego anunció `M002 → M001`
   y cambió el código dominante en ambos casos.
6. `M001` cerró con bruto `12.030`, tara `0.030`, NET `12.000`, aporte final
   `3.050` y `50.000` unidades tomadas del plan confirmado. Quedó
   `PENDIENTE_RECEPCION_ALMACEN`; `M002` permaneció `PREETIQUETADA` y sin
   pesaje.
7. La consulta de base confirmó exactamente dos controles `AVANCE_KG`, ambos
   sin conteo; durante los controles no se acreditó producción ni inventario.

Comprobaciones focales posteriores: servicio/migración Central `2 passed`,
backend de estación `11 passed` y componente de pesaje `11 passed`. No se
observaron errores en los logs de Central, estación o frontend durante el run.

Quedaron pendientes la variante con foto presente, lectura del QR en papel,
balanza real, TSC real, doble F2 físico, fallos de conectividad/spooler y
observación de un operador representativo. En el corte histórico de ese run se
conservaron:

```yaml
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

## 9. Extensión local — identidad visual de color 2026-09-03

- La misma base `enva_uat_recorrido` fue actualizada sin reset; se conservaron
  OP, OF, OT, Trabajo, mangas y etiquetas.
- Resolver la preetiqueta de `OF000001-OT002-M001` devolvió
  `color=TRANSPARENTE`, `color_hex=#EAF7F7` y base/familia estructuradas, sin el
  rótulo duplicado del snapshot.
- La captura simulada en viewport `1440 × 1200` muestra pieza y color dentro de
  `IDENTIDAD DEL CONTENIDO`, con muestra cuadriculada de 44 px y texto visible.
- El estado siguió bloqueado por `TRABAJO_NO_INICIADO`; la mejora no concedió
  capacidad ni mutó el recorrido.
- Evidencia: `output/qa/uat-color-identidad-transparente.png` y
  [[REC_2026-09-03_Identidad_Visual_Color_Estacion_Pesaje]].

La observación humana frente a una pieza blanca y el hardware físico continúan
pendientes; no cambia ningún gate de UX o planta.

## 10. Hallazgo UAT guiada — cierre accidental repetido 2026-09-03

En el recorrido del piloto con `OF000001-OT002-M001`, el usuario omitió marcar
**Control de peso** en dos ocasiones. Como el estado por defecto sin marcar es
cierre final, F2 cerró la manga correctamente según el contrato: primero con
NET `8.950 kg` y, después de una reapertura auditada y reescaneo del mismo QR,
con NET `4.970 kg`.

La segunda ocurrencia fue confirmada explícitamente por el usuario como omisión
de la casilla; no es un defecto del endpoint ni pérdida de estado del checkbox.
Sí es un fallo del criterio UX `PES-01..04`: incluso con guía, la intención de
control no fue suficientemente dominante y la omisión produjo una acción de
alto impacto. `functional_validation` permanece `qa_green`, mientras
`ux_validation` pasa a `rejected` y se conserva
`release_constraint: no_habilitar_en_planta`.

Antes de repetir el caso debe acordarse e implementar una protección que
mantenga una sola acción de pesaje pero haga deliberado el cierre final. No se
define aquí si será modo control por defecto, confirmación de cierre u otro
patrón: esa decisión requiere validación funcional/operativa.

La decisión posterior quedó registrada e implementada en
[[US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]: Control es ahora el
estado seguro inicial y el cierre exige selección más confirmación. Esta UAT K3
conserva el rechazo histórico; la revalidación se ejecuta en la UAT K7.
