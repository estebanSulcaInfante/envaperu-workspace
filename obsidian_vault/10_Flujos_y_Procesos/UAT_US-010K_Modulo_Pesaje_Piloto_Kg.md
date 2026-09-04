---
tipo: uat
uat_id: UAT-US-010K-PESAJE-20260902
estado: ejecucion-parcial-ux-rejected
modalidades_uat: [funcional, operativa, fisica]
historia: "[[US-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]]"
tech_spec: "[[TS-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]]"
dev: "[[DEV-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]]"
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
perfiles_uat: [PES-v1, LEC-v1, CON-v1, IMP-v1]
spec_phase: approved
delivery_state: review
functional_validation: untested
ux_validation: rejected
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
fecha_preparacion: 2026-09-02
---

# UAT del módulo de Pesaje — guion del piloto

Guion preparado para ejecutar el alcance implementado y registrar hallazgos.
**No es una UAT aprobada ni un flujo integral solo kg terminado.** K3/K4 tienen
QA automático verde; el módulo ampliado conserva `functional_validation:
untested` hasta verificar todos sus casos aplicables. El anexo de adaptación
kg no hereda la aprobación de K4.

## 1. Alcance y fuentes — BASE

| Bloque | Qué se puede validar | Límite |
|---|---|---|
| A. Control ordinario y bloqueos | Un botón/F2, controles repetidos sin conteo, misma manga/QR/persona/OT, errores y recuperación. | Implementado K3/K4, ensayo local disponible. |
| B. Cierre y stickers vigentes | Cierre único, separación registro/impresión, preetiqueta compacta y salida física v5. | Regresión del contrato actual: cierre normal todavía copia plan UN. No acredita un conteo real. |
| C. Operación integral solo kg | Cierre anticipado, relevos, nueva OT, saldo kg, devolución repesada. | Pendiente de diseño/implementación. Casos definidos en §8, no marcarlos PASS con K1/K2. |
| D. Conciliación detallada de Armado | Consumo, merma, remanente y diferencias. | Diferida por el responsable; no condiciona el desarrollo básico ni se certifica aquí. |

Fuentes: US/TS/DEV K3 y K4; [[PROTO_US-010K4_Estado_y_Accion_Pesaje]],
[[REC_2026-09-01_Stickers_Pesaje_TSPL5_y_Peso_Fabricado]], [[Etiqueta_Manga]],
[[Unidad_Logistica]], [[Inventario_SCM]],
[[2026-08-31_Control_Avance_en_Kg_sin_Conteo_y_Accion_Unica_Pesaje]],
[[Feedback_Pesaje_y_Cierre_Kg_sin_Conteo]]. Los casos K4 detallados permanecen
en [[UAT_US-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]].

Plantilla v2 y perfiles v1, expandidos en §6. Fuentes de datos: Central para
identidad, permiso y tara congelada; backend de estación/balanza para bruto y
estabilidad; NET = bruto − tara. Foto, plan, sticker previo y Google Sheet
legacy no son prueba de cantidad física. No usar la hoja legacy como maestro
validado ni cargar/corregir datos de producción para este ensayo.

## 2. Preparación y seguridad — BASE / CONTEXTO

- Responsable funcional: Esteban, confirmar disponibilidad; operador
  representativo y observador: por designar. Renato puede recopilar evidencia
  si Esteban lo designa, no se le asigna ni notifica automáticamente.
- Supervisor autorizado de Central prepara/inicia trabajos y resuelve permisos;
  cambiar quien pulsa F2 no cambia por sí solo el maquinista atribuido.
- Puesto: PC compartida, balanza, lector y TSC. Registrar modelo, puerto,
  protocolo, estabilidad, sufijo lector, pantalla/resolución/escalado, postura,
  distancia, manos/EPP y pico de trabajo observado; no inventar valores.
- Referencia de impresión: 203 dpi, 109 × 50 mm, gap 3 mm; cada identidad tiene
  dos copias por hoja. Verificar modelo/papel/driver reales antes del ensayo físico.
- Acta lista para completar: [[ACTA_UAT_Pesaje_Piloto_Kg]]. Asignar RUN propio
  al ejecutar; no reutilizar una aceptación anterior.
- Contingencia `bloqueo-seguro`. Supervisor define la custodia de la manga ante
  interrupción larga antes del ensayo; no hay operación offline autorizada.
- Detener ante producción real seleccionada, peso/tara no concordantes,
  identidad equivocada, permiso inesperado, cierre involuntario o duplicación.
- No hacer Reset para repetir. Crear nuevas mangas/documentos UAT con RUN
  distinto; conservar los hechos existentes. Migración/reset/impresión real
  requieren alcance y autorización separados del ensayo visual.

Estado local leído el 2026-09-02: escenario `jarra-real-6l-pesaje-piezas`,
base `enva_uat_recorrido` en loopback; Central, frontend y estación detenidos.
No se arrancaron ni se borraron documentos. Esto no confirma versión desplegada.

Actualización posterior, 2026-09-02 12:47 Lima: por solicitud explícita del
responsable se ejecutó reset con respaldo y arranque. Central, frontend y
Pesaje quedaron LISTO; estación conectada ONLINE a Central, con periféricos
simulados. El escenario comienza nuevamente, no reutilizar IDs del recorrido
anterior. Detalles: [[REC_2026-09-02_Reset_y_Arranque_UAT_Pesaje]]. No implica
aceptación de los casos ni certificación de hardware.

### Ensayo visual inmediato, sin Central ni hardware

Desde `modulo-pesaje/frontend`:

```powershell
npm.cmd run dev -- --host 127.0.0.1 --port 5186 --strictPort
```

Abrir `http://127.0.0.1:5186/qa/k4.html`. Usa el componente real con respuestas
en memoria y queda fuera del build productivo. Seleccionar escenario; escribir
`qa` en «QR de manga SCM» y Enter; `invalido` produce rechazo. Recargar reinicia
solo el fixture. No prueba permisos backend, impresión ni idempotencia durable.

### Integración y física, después del preflight

Revisar `scripts/uat-local.ps1 Status`; si se acuerda usar ese entorno,
`Start` conserva la base. Si informa revisión incompatible, detener y acordar
migración; no ejecutar `Update`/`Reset` automáticamente. Confirmar que estación
y Central apuntan a UAT y que la impresión sigue simulada para integración.
Para hardware real, registrar configuración y autorización de ensayo aislado.

## 3. Dataset reiniciable — CONTEXTO / BDD

Los aliases siguientes se mapean a IDs reales **antes** de integración/física.
No se inventan UUID ni se reutiliza una manga cerrada para volver a pesar.

| Alias | Preparación Central/UAT | Caso |
|---|---|---|
| A | Manga NORMAL con preetiqueta IMPRESA y Trabajo EN_EJECUCION; sin control/final | Dos controles ordinarios. |
| B | Preetiqueta IMPRESA, Trabajo PLANIFICADO | Bloqueo e inicio por Central. |
| C | Manga con final vigente | Bloqueo de manga cerrada. |
| D | Manga histórica CONTINUIDAD_PENDIENTE | Solo diagnóstico, no traspaso nuevo kg. |
| E | Preetiqueta invalidada y reemplazo autorizado vigentes en historia | Rechazo de versión antigua. |
| F | Segunda manga válida de artículo/color diferente | Cambio de contexto y foco. |
| G | Manga dedicada al cierre de regresión; sin final previo | Cierre único, fuente del conteo e impresión. |
| P/R | Pala y rastrillo, dos salidas del mismo molde, cada manga con artículo único | No fusionar artículos, etiquetas ni pesajes. Maestros UAT por verificar/preparar. |
| W | WIP concurrente autorizado con sus fuentes y snapshots | Comparar NET total vs peso fabricado teórico; no inferir componentes medidos. Datos por preparar. |

Fixture visual A: bruto 7.600, tara 0.020, NET 7.580 kg; segundo bruto 8.000,
NET 7.980 kg, incremento 0.400 kg. Son datos sintéticos, NO nuevo peso maestro
de Embudo. En física usar lecturas reales y registrar la tara autorizada.

Para cada alias guardar: manga/label, OP si existe, OF/OA, OT/Trabajo/tramo,
maquinista/actor de captura, artículo/color, tara, versión de plantilla,
print_job_id y conteos de eventos antes/después. Excluir tokens y `.env`.

## 4. Guion principal — BDD K3/K4 / BASE

Todos los resultados humanos comienzan PENDING. En cada paso anotar quién,
permiso, lugar, objeto en manos, lectura/fuente, acción, efecto, recuperación,
ayuda y evidencia. Enter consulta; solo botón/F2 confirma el hecho físico.

| ID / origen | Acción y objeto | Resultado visible y comprobación digital | Evidencia |
|---|---|---|---|
| UAT-P01 / K4-01,02 | Operador escanea C y B; intenta F2 | C indica cerrada; B Trabajo sin iniciar. Cero hechos nuevos. Supervisor inicia B; reescaneo actualiza capacidad, mismo QR. | Capturas, IDs/estados antes-después. |
| UAT-P02 / K3-01, K4-03 | Operador pone A en balanza, marca Control y usa botón | NET registrado, manga EN_LLENADO; mismo Trabajo/persona/tramo. Sin conteo, cierre, Kardex ni pausa. | Control AVANCE_KG, fuente/tara, sticker y consulta central. |
| UAT-P03 / K3-02, K4-04 | Misma persona y OT: reescanear A, alternar checkbox sin añadir contenido | Sin aumento, F2 bloqueado; referencia de último NET conservada. | Pantalla y número de controles. |
| UAT-P04 / K3-02,03 | Añadir avance real a A y registrar otro control con F2 | Segundo control, mismo tramo; diferencia entre NETs, no suma de acumulados. En fixture 0.400, no 15.560 kg. | Dos controles, un tramo, ambos actores/tiempos. |
| UAT-P05 / K3-04,05,06; K4-05 | Escanear F y luego E/QR inválido | Nuevo contexto inequívoco, checkbox limpio, foco lector. Rechazo borra contexto anterior; nunca pesar F desde QR rechazado. Foto ausente no bloquea. | Capturas, foco y ausencia de mutación. |
| UAT-P06 / K3-03; TS K3 §5 | G dedicada, sin marcar Control, lectura válida, F2 | Un final y dos copias del comprobante; preetiqueta preservada; pendiente Almacén, cero ingreso por pesar. Registrar que UN proceden del plan, no de conteo. | Pesaje/fuente, job, papel, ausencia de Kardex. |
| UAT-P07 / K3-08, K4-05 | Doble F2, respuesta perdida y reintento de la misma operación en UAT | Un hecho y job lógico. No cambiar intención durante incertidumbre; recuperar operación, no capturar otra para imprimir. | operation_id/capture_id/eventos, error y recuperación. |
| UAT-P08 / K4-01,05 | QR incorrecto/de otro módulo, D, balanza desconectada, NET inválido o límite snapshot | Motivo y recuperación; F2 no registra. Trabajo PAUSADO mantiene semántica vigente, no inventar bloqueo por cabecera. | Capturas y contador de eventos. |
| UAT-P09 / TS K4, CON | Cortar red antes/después de resolver y perder respuesta al confirmar, solo UAT | Sin éxito falso ni cola offline; resolver/reconciliar. Custodia física previamente acordada. | Estado, logs saneados, operación y objeto. |
| UAT-P10 / IMP, TSPL5 | Preetiquetas con/sin OP, control y final; fallar impresora de prueba | OP encima de máquina, tipo debajo, pieza/color separados, separador, KG TEORICOS. Final con maquinista bajo fecha y peso fabricado teórico bajo NET. Sin QR en control/final. Registro ≠ impresión. | Preview y papel, lectura QR pegado, job/versiones. |
| UAT-P11 / dominio Unidad_Logistica | Preparar P/R del mismo molde, escanear y pesar cada manga separada | Una pala-color por identidad y un rastrillo-color por otra; dos mangas/pesajes independientes, no pieza combinada. | IDs artículos/salidas/mangas y stickers. |
| UAT-P12 / peso fabricado teórico | W preparada por Armado, revisar fuentes y comprobante | NET corresponde al conjunto; peso fabricado teórico solo a componente producido en OT. No tratar diferencia como merma ni kg incorporados medidos. | BOM/snapshots, consumo/fuente y etiqueta. |

UAT-P06 no acepta el cierre exclusivamente kg de §8. UAT-P11/P12 necesitan
dataset preparado; no están cubiertos por el fixture visual de Embudo.
La cadena control→final al mismo NET está bloqueada actualmente: registrar
GAP-02, no añadir peso ficticio para hacer pasar la prueba.

## 5. Estados de interfaz — BASE / RIESGO

| Estado | Qué debe reconocer la persona | Recuperación |
|---|---|---|
| Inicial | Falta QR, F2 no registra | Escanear. |
| Consultando / registrando | Operación en curso, sin doble envío | Esperar resultado; ante timeout recuperar la misma operación. |
| Bloqueado por Central | Estado, motivo y quién lo resuelve | Central corrige/inicia; reescanear. |
| Sin lectura válida | Balanza/NET/tara/límite no permiten confirmar | Revisar lectura y objeto; no corregir el maestro por intuición. |
| Listo | Control mantiene abierta; sin marcar cierra | Mismo botón/F2. |
| Registro exitoso | Identidad, NET, abierto/cerrado e impresión separados | Conservar preetiqueta y verificar soporte correcto. |
| Error recuperable / incierto | No hay éxito confirmado | Recuperar operación o reescanear según respuesta, sin duplicar. |
| Desconectado | Pesaje SCM bloqueado | Restablecer red y revalidar; no improvisar offline. |

## 6. Preguntas instanciadas — perfiles v1

Todas las filas requieren evidencia y resultado humano en el acta. No hay
preguntas de los perfiles seleccionados descartadas. LEC-04 adapta contexto
a manga: un QR rechazado sí debe limpiar esa selección para no pesar la anterior.
LEC-06 no impone un timeout inexistente; registra el riesgo y procedimiento real.
ADM no seleccionado: no se acepta una nueva interfaz Central; su inicio de
Trabajo es preparación. MQR no seleccionado: no se acumulan unidades para
recepción/picking. Agregarlos cuando se implemente el anexo §8.

| Origen | Preparación y criterio aplicado al puesto | Evidencia / resultado esperado |
|---|---|---|
| PES-01 | A, desde posición real registrada: reconocer NET y unidad | Foto/relato; registrar si bruto dominante confunde. |
| PES-02 | A/B/C y lectura inestable/desconectada | Capturas; distingue espera, estable, bloqueo y confirmado. Número válido no prueba estabilidad física. |
| PES-03 | A con texto largo en monitor objetivo | Contexto, NET y F2 visibles sin scroll primario. Si no, hallazgo. |
| PES-04 | A con tara conocida | Bruto − tara = NET con unidad/precisión correctas; lectura y registro. |
| PES-05 | Enter en B/A y F2 | Enter cero hechos, F2 solo válido; antes/después. |
| PES-06 | B/C/D y balanza caída | Causa textual y acción segura; trabajador identifica responsable. |
| PES-07 | UAT-P07 | Misma clave produce un hecho; eventos centrales y job. |
| PES-08 | E, QR inválido/otro módulo | Rechazo seguro, cero pesajes; pantalla y consulta. |
| PES-09 | Dos controles con postura/manos/EPP reales | Observación sin guía, registrar ayuda, dudas y tiempo sin umbral inventado. |
| PES-10 | Control y final, con impresión exitosa/fallida | Reconoce NET/ID/estado/siguiente paso; relato y papel. |
| PES-11 | A→F, después otro operador | No confirmar manga ni atribución equivocadas; contexto y personas observados. |
| PES-12 | Pérdida de respuesta al capturar | Sin disponibilidad/éxito falsos; revisar operación y custodia. |
| LEC-01 | Lector real y sufijo observado | Enter resuelve; documentar modelo/configuración. |
| LEC-02 | Antes de cada confirmación A/F | Manga, pieza/color, OT y persona inequívocos; captura. |
| LEC-03 | Botón con mouse y siguiente escaneo | Foco regresa al QR, recorrido continuo sin reenfocar. |
| LEC-04 | E tras A | Rechazo limpia selección de manga A; ninguna mutación. |
| LEC-05 | A→F | Escaneo explícito cambia identidad y limpia intención anterior. |
| LEC-06 | Contexto abandonado y segundo operador | Evaluar reescaneo/revalidación; no suponer expiración automática. Registrar riesgo si hereda identidad. |
| LEC-07 | Segundo operador con QR asignado | No atribuir producción por quien pulsa; contrastar persona resuelta y real. |
| LEC-08 | Monitor/zoom real, tablet solo si entra al alcance físico | Teclado/barras no ocultan acción; N/A tablet solo con decisión del responsable. |
| LEC-09 | Control, duplicado y rechazo | Texto además de color, comprensión observada. |
| LEC-10 | Escaneo rápido, duplicado/incompleto | IDs aceptados/rechazados; sin mutación ni acción sobre manga anterior. |
| LEC-11 | Lector y F2 con objetos reales | Completa tarea sin mouse ni ayuda crítica. |
| LEC-12 | Suspender/reconectar puesto | Reescanear conserva referencia/estado honestos; captura. |
| CON-01 | TS K3/K4 y UAT-P09 | Bloqueo seguro; sin captura offline autorizada. |
| CON-02 | Central cae antes de Enter | Motivo y cero hechos; captura/log. |
| CON-03 | Cae después de resolver | Bloqueo al detectarse o rechazo al confirmar, sin éxito falso. |
| CON-04 | Respuesta perdida durante F2 | Clave/estado/evento central permiten recuperar el único hecho. |
| CON-05 | Reiniciar navegador/estación en incertidumbre | Reconsultar; no asumir que memoria del navegador conservó clave. Cotejar efecto central. |
| CON-06 | Interrupción prolongada autorizada | Supervisor define custodia/ubicación; foto y procedimiento, sin mezcla. |
| CON-07 | Replay misma operación | Un evento y efecto, no segunda impresión ciega. |
| CON-08 | Estado remoto cambia tras escaneo | Conflicto obliga a revalidar, no libera stock ni inventa otra manga. |
| CON-09 | Espera, timeout y acuse | Distingue sin confirmar/confirmado; no estado offline ficticio. |
| CON-10 | Impresión/acuse inciertos | No declarar IMPRESA o disponible sin evidencia. |
| CON-11 | Timeout/reintento | Operador comprende siguiente paso sin adivinar si repite peso. |
| CON-12 | Soporte del fallo | Solo IDs, estados y lecturas; sin credenciales ni datos sensibles. |
| IMP-01 | Equipo y consumibles reales | Modelo/driver/spooler/DPI/papel/columnas registrados y fotografiados. |
| IMP-02 | UAT-P10 | Preview y papel coinciden en campos, orden, tamaño y márgenes. |
| IMP-03 | Código y nombres largos | Texto/kg/estado completos y legibles; revisar GAP-03/04, no aceptar por el ejemplo corto. |
| IMP-04 | QR compacto pegado | Lector real resuelve misma manga y etiqueta vigente. |
| IMP-05 | A/F alternadas | Copias asociadas al objeto correcto; observar retiro/pegado. |
| IMP-06 | Job de una y de dos identidades | Dos copias por identidad/hoja; no intercambiar ni crear dos mangas. |
| IMP-07 | Papel agotado, atasco/spool detenido o salida incierta | Separar hecho registrado de soporte emitido y recuperar según estado. |
| IMP-08 | Etiqueta dañada/perdida | Reemplazo autorizado/versionado; IDs e historia, no copia silenciosa. |
| IMP-09 | Reintento permitido del mismo job | Sin nuevo pesaje, Kardex o QR vigente accidental; historial. |
| IMP-10 | Manga sale del puesto | Identificación vigente y comprobante exigido aplicados al objeto. |
| IMP-11 | Posible emisión ya entregada | No reintento ciego; recuperación supervisada y versión cuando corresponda. |
| IMP-12 | Campos secundarios | No desplazan código, NET, estado o QR; reconocimiento del trabajador. |

## 7. Evidencia técnica y límites — BASE

Recibo actual: [[REC_2026-09-02_Preparacion_UAT_Modulo_Pesaje]].
Reverificación: backend estación 147, frontend estación 67 y Central focal 51
pruebas verdes; contratos 3; build y sincronización aislada correctos. No es
un E2E nuevo del módulo completo ni demuestra balance kg de artículos.

QA visual con Browser, 2026-09-02, viewport CSS 1163 × 654, DPR aproximado 1.65:
`outputs/uat-pesaje-2026-09-02/01-manga-cerrada.png` a `08-central-desconectada.png`,
más `09-control-vista-completa.png` para examinar contenido fuera del viewport.
Controles sintéticos 7.580 → 7.980 kg, segundo incremento 0.400 kg, reescaneo
bloqueado y QR rechazado sin selección. Capturas no sustituyen balanza/papel.
Las evidencias K4 previas 1366×768/768×1024 están en `outputs/uat-k4/`; pantalla
estrecha necesita scroll. En la altura de esta pasada tampoco cabe la acción
completa; no marcar PES-03 PASS. No se conoce todavía el viewport real de planta.

La última suite global registrada tiene un fallo de seed de inventario de demo
y la suite administrativa quedó incompleta con fallos de onboarding. No se
declara CI global verde ni se oculta esa deuda; ver recibo K4.

## 8. Brechas y casos de aceptación futura solo kg

Estos casos quedan BLOCKED por falta de adaptación, no PENDING físico ni PASS.
No se implementan reglas nuevas desde la UAT.

| ID | Caso objetivo | Resultado requerido / dependencia |
|---|---|---|
| KG-01 | Cierre normal o anticipado sin conteo humano | NET medido, estimación UN solo referencia; Central autoriza excepción. [[US-010K5_Cierre_Fisico_en_Kg_sin_Conteo]]. |
| KG-02 | Relevo maquinista con misma OT | Central registra frontera pesada y vínculo viejo/nuevo; mismo QR. Varios controles ≠ varios tramos. Migrar fronteras UN. |
| KG-03 | Nueva OT compatible durante dos días | Misma manga/QR, sucesión auditable de OT/fecha/turno/persona; cupo/avance sin unidades ficticias. No cerrar físicamente solo por cambiar OT. |
| KG-04 | Cierre tras control sin añadir peso | Resolver regla de igualdad y tara/comparabilidad; no aumentar peso artificialmente. |
| KG-05 | Recepción de piezas/WIP en kg | Stock neto medido, UN aproximadas no autoritativas; recepción/Calidad separadas. Diseñar migración/reservas/consumos del actual libro UN. |
| KG-06 | Entrega 10 kg, retorno repesado 3 kg | Devolución enlazada, recepción/sticker sin nueva producción ni doble movimiento; 7 kg pendientes de clasificación, no consumo confirmado. |
| KG-07 | Varios controles y cierre de un mismo tramo | Aporte por tramo desde sus fronteras, no último delta ni suma de NETs. Sin fronteras comparables no atribuir ficticiamente. |

[[Conciliacion_Consumo_Armado_en_Kg_Pendiente]] permanece diferida. KG-06 no
exige resolver esa conciliación detallada, pero sí conservar entrega/retorno
y no convertir la resta en consumo ni existencia libre verificada.

### Hallazgos de preparación, no aceptados por el agente

| ID | Evidencia / impacto | Gate y siguiente responsable |
|---|---|---|
| GAP-01 | Relevo, continuidad y parcial usan UN; el final normal copia el plan. | KG-01…03/05: diseño y desarrollo separados; responsable funcional/ingeniería. |
| GAP-02 | Final exige NET mayor al último control, incluso sin cambio físico. | KG-04: definir cierre normal vs repetición; no tolerancia inventada. |
| GAP-03 | POSTPESAJE dice APORTE ULTIMO TRAMO, pero payload es delta del último control. | KG-07 / IMP-03: corregir semántica antes de certificar atribución impresa. |
| GAP-04 | TIPO MANGA imprime NORMAL/EXTRA, no nombre físico de manga. | IMP-03: confirmar significado esperado y corregir si debe ser reciclada/etc. |
| GAP-05 | Bruto dominante; la acción no cabe completa en viewport ensayado 1163×654 ni en el estrecho previo. | PES-01/03: observación en equipo real y ajuste si no es operable. |
| GAP-06 | Dataset P/R/W y entorno físico sin preparar/confirmar. | Preflight: responsable UAT; no fabricar datos ni declarar E2E físico listo. |
| GAP-07 | El modo sin marcar cerraba la manga; durante la UAT guiada se omitió dos veces **Control de peso** y F2 creó cierres accidentales. | Corrección K7 implementada: Control por defecto y cierre con confirmación. Pendiente repetir [[UAT_US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]] antes de cambiar `ux_validation: rejected`. |

## 9. Observación y salida — BASE

Tarea al operador, sin indicar controles: «Identifica estas mangas, pesa como
control la que continuará abierta y explica qué harías con las bloqueadas».
Para final usar G dedicada con instrucción inequívoca del observador. Registrar
finalización, ayuda, dudas, retrocesos, casi-errores, tiempo y evidencia en acta.

- Aceptación funcional de A/B: todos sus casos aplicables verificados; IDs,
  pesos y fuentes concordantes, sin efectos duplicados ni falsos conteos.
- Aceptación UX: trabajador representativo completa sin ayuda crítica y entiende
  estado, NET, efecto de F2 y recuperación. No basta revisar screenshots.
- Aceptación física: lector sobre QR pegado, balanza/estabilidad/tara y TSC/papel
  representativos, con fallos y recuperación observados.
- Resolver hallazgos críticos; los de un bloque excluido permanecen explícitos,
  no se certifica el módulo integral kg por aprobar únicamente controles K4.
- Registrar persona, fecha, entorno, versiones y decisión en
  [[ACTA_UAT_Pesaje_Piloto_Kg]]. No firmar por el trabajador ni levantar
  `no_habilitar_en_planta` sin todos los gates correspondientes.
