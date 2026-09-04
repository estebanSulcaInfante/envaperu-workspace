---
tipo: uat
estado: preparada-pendiente-ejecucion
uat_id: UAT-US-010K2
modalidades_uat: [funcional, operativa, fisica]
historia: "[[US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
tech_spec: "[[TS-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
dev: "[[DEV-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
perfiles_uat:
  - "[[PERF_UAT_Estacion_Pesaje]]"
  - "[[PERF_UAT_Lector_Compartido_Tablet]]"
  - "[[PERF_UAT_Escritorio_Administrativo]]"
  - "[[PERF_UAT_Impresion]]"
  - "[[PERF_UAT_Conectividad_Contingencia]]"
spec_phase: approved
delivery_state: deployed
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
version_objetivo: central-f3-k2-y-pesaje-1.2.0-pilot.13-desplegados
fecha_preparacion: 2026-08-29
tags: [uat, scm, pesaje, manga, relevo, impresion, qr]
---

# UAT US-010K2 — relevo multijornada, QR único y stickers de control

## 1. Identidad, objetivo y alcance

| Campo | Valor |
|---|---|
| UAT / `RUN_ID` | `UAT-US-010K2-RUN-____` al ejecutar. |
| Modalidades | Funcional, operativa y física. Las pruebas automáticas cubren la primera parcialmente; las dos últimas requieren participantes y hardware reales. |
| Resultado de negocio | Conservar una manga y su QR al cambiar responsable o jornada; imprimir un sticker sin QR por control y un único final. |
| Fuentes | [[US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]], [[TS-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]], [[DEV-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]] y [[PROTO_US-010K2_Relevo_Multijornada_y_Stickers_de_Peso]]. |
| Entorno y versión | Central F3+K2 desplegado y estación `PESAJE-PLANTA-01` en `1.2.0-pilot.13`. Antes de ejecutar, confirmar que estas versiones siguen activas y registrar los commits/health del run. |
| Fecha y ventana | Pendiente de coordinación; incluir al menos un relevo a mitad de turno y, si es viable, una continuidad al turno/día siguiente. |
| Responsable UAT | Pendiente de designación humana. |
| Participantes | Supervisor, operador de Pesaje y dos maquinistas representativos (saliente/entrante); nombres pendientes. |
| Lugar | Central de Producción, estación única de Pesaje y máquina origen. |
| Evidencia técnica preparada | `output/US-010K2_etiqueta_control_peso_sin_qr.svg`; pruebas y recibo enlazado al cierre. |
| Escenario reiniciable | Dataset dedicado K2; cada repetición usa otra manga/operación y conserva la historia. No borrar ni reutilizar QR impresos. |

### Alcance

- **Incluye:** control acumulado, aporte comparable, sticker CONTROL sin QR,
  relevo dentro de la misma OT, continuidad K1 a OT compatible, final sin QR,
  reintento del mismo trabajo y bloqueo seguro sin Central.
- **Excluye:** operación offline autoritativa, trasvase/división, atribución de
  unidades por inferencia de kg, activación automática de “orrines” y
  habilitación operativa regular en planta.
- **Riesgo operativo:** `high` por identidad física única, superposición de
  stickers, cambio de responsable y un único cierre con efecto productivo.
- **Resultado físico:** una manga, una preetiqueta/QR visible, dos stickers
  CONTROL y un sticker FINAL; un solo pesaje final y crédito.
- **Fuentes autoritativas:** bruto/tara/NET desde balanza y tara configurada;
  conteo desde declaración supervisada; responsable/tramo y estados desde
  Central; QR desde la preetiqueta vigente.

## 2. Contexto pendiente de completar antes de ejecutar

El contexto confirma una sola PC, balanza, lector e impresora compartidos para
aproximadamente 13 máquinas. No registra todavía los siguientes valores; no se
inventan y bloquean la aceptación física:

- modelo/protocolo de balanza, criterio de estabilidad y precisión observada;
- modelo/configuración del lector, sufijo Enter y comportamiento de foco;
- modelo/driver/DPI de impresora, papel, márgenes y adhesivo;
- resolución, escalado, navegador, viewport, distancia y ángulo de lectura;
- postura, manos disponibles, EPP, transportista real y ritmo/cola pico;
- procedimiento físico autorizado durante caída o emisión incierta.

Información primaria: tipo `CONTROL`/`FINAL`, manga y `PESO NETO REAL (kg)`.
Acciones primarias: `Registrar control — continúa abierta` en Pesaje y
`Registrar relevo — continúa incompleta` en Central. Aporte, conteo, estándar,
WIP/color, hora y diagnóstico son secundarios.

## 3. Perfiles seleccionados y descartados

| Perfil | Aplica | Motivo | IDs |
|---|---|---|---|
| `PES` v1 | Sí | Se confirma bruto, tara y NET en la balanza. | `PES-01..12` |
| `LEC` v1 | Sí | La única PC/lector cambia entre maquinistas y mangas. | `LEC-01..07`, `LEC-09..12` |
| `ADM` v1 | Sí | El supervisor localiza la manga y registra un relevo sensible. | `ADM-01..11` |
| `IMP` v1 | Sí | Cada control y final producen soporte físico 2-up. | `IMP-01..12` |
| `CON` v1 | Sí | Central, red, balanza o impresora pueden dejar resultado incierto. | `CON-01..07`, `CON-09..12` |
| `MQR` | No | Se resuelve una sola manga/QR por control; no existe lote multi-QR. | Descartado. |

Preguntas descartadas: `LEC-08` porque el puesto objetivo es PC, no tablet
(reabrir si se prueba tablet); `ADM-12` porque no hay exportación ni salto a
otro detalle en esta acción; `CON-08` porque el recorrido no reserva/libera
stock antes del final. La recepción final y su QR se validan como regresión,
pero no amplían este caso a un lote multi-QR.

## 4. Preparación y baseline

- Dataset: manga `OF0021-OT0410-M007`, objetivo `50 UN`, tara `0.030 kg`;
  José `4.800 kg/20 UN`, Pedro `8.950 kg/35 UN`, final `12.000 kg/50 UN`.
- Un único QR `SCM_MANGA_LABEL` vigente debe estar pegado antes del primer
  control y permanecer visible después de superponer stickers de peso.
- Registrar IDs y versiones de OT, Trabajo, manga, preetiqueta, tramos,
  controles y trabajos de impresión antes/después.
- Verificar permisos de Supervisor/Gerente para relevo y ausencia de la acción
  en un rol sin `MANGA_REASIGNAR_MAQUINISTA`.
- Modo de contingencia: `bloqueo-seguro`, autorizado por la TS. No hay outbox
  autoritativo offline.
- Detener si se cubre/daña el QR único, cambia la tara sin conciliación, existe
  emisión incierta, el contexto no corresponde o aparece doble efecto.

## 5. Secuencia física y digital

| Paso | Actor/lugar | Acción | Resultado visible y efecto | Evidencia |
|---|---|---|---|---|
| 1 | José / máquina y Pesaje | Llevar la manga con preetiqueta, escanear y resolver. | Misma manga, José y Trabajo visibles; escanear no muta. | Foto QR aplicado, pantalla y IDs iniciales. |
| 2 | Operador / Pesaje | Esperar lectura estable y registrar primer control `4.830-0.030`. | Control `4.800`, aporte `4.800`, `0 UN` acreditadas y un `print_job_id`. | Bruto/tara/NET, respuesta y conteos DB. |
| 3 | Operador / impresora | Imprimir y pegar CONTROL sin cubrir la preetiqueta. | Dos copias físicas 2-up; neto dominante; sin QR. | Preview y foto lado a lado. |
| 4 | Supervisor / Central | Buscar la manga controlada, elegir Pedro y motivo, confirmar relevo misma OT. | Mismo código/QR/Trabajo; José cerrado, Pedro activo; cero preetiquetas/jobs nuevos. | Capturas antes/después e IDs de tramos. |
| 5 | Pedro / Pesaje | Escanear el mismo QR y registrar segundo control `8.980-0.030`. | Contexto muestra Pedro; neto `8.950`, aporte `4.150`; un segundo job. | Pantalla, sticker y auditoría. |
| 6 | Supervisor / Central | Vincular a OT posterior compatible o repetir relevo cuando aplique. | Frontera reutilizada, misma manga/QR, nuevo tramo único. | OT/Trabajo/tramo antes/después. |
| 7 | Operador / Pesaje | Finalizar con F2 en `12.030-0.030`, `50 UN`. | Un final/crédito y sticker FINAL sin QR; aporte `3.050`. | Pesaje, job, crédito y etiqueta. |
| 8 | Almacén / recepción | Resolver la manga usando el QR original de preetiqueta. | El QR sigue válido; control/final no crean otra identidad. | Lectura física y estado de recepción. |

## 6. Matriz de criterios instanciados

Cada fila queda `PENDING` hasta la ejecución humana/física; la evidencia
automática indicada no la convierte en aceptada.

| ID | Criterio concreto | Preparación / resultado esperado | Evidencia | Estado |
|---|---|---|---|---|
| `PES-01` | `PESO NETO REAL (kg)` domina pantalla y papel desde la postura real. | Probar `4.800`, `8.950` y `12.000`; el trabajador nombra primero el NET. | Foto y captura a resolución/distancia registradas. | PENDING |
| `PES-02` | Desconectada, inestable, estable, bloqueada y confirmada son distinguibles. | Simular cada estado sin mutación indebida. | Captura y explicación del operador. | PENDING |
| `PES-03` | Manga/responsable y acción siguiente caben sin scroll en el recorrido primario. | Resolver preetiqueta con José y después Pedro. | Captura completa del viewport. | PENDING |
| `PES-04` | Peso bruto, tara y peso neto real usan kg y 3 decimales. | Comparar `8.980-0.030=8.950`. | Foto balanza y pantalla. | PENDING |
| `PES-05` | Enter solo resuelve; control explícito guarda control y F2 solo finaliza. | Verificar IDs antes/después. | Eventos y estados. | PENDING |
| `PES-06` | Control/F2 bloqueados explican contexto ausente, inestabilidad o periférico. | Tres negativos y recuperación. | Capturas. | PENDING |
| `PES-07` | Doble acción o respuesta perdida deja un solo control/final. | Reusar `operation_id`. | Conteo central y claves. | PENDING |
| `PES-08` | QR inválido, reemplazado u otro módulo no muta. | Probar tres QR no válidos. | Rechazo y conteos. | PENDING |
| `PES-09` | Operador completa el recorrido con manos/EPP/ritmo reales. | No guiar dónde pulsar. | Tiempo, dudas y casi-errores. | PENDING |
| `PES-10` | Éxito muestra control/final, manga, NET, impresión y siguiente acción. | Ejecutar control y final. | Capturas y relato. | PENDING |
| `PES-11` | Cambiar de José a Pedro evita confirmar sobre el contexto anterior. | Dos escaneos consecutivos tras relevo. | Actor/tramo atribuido. | PENDING |
| `PES-12` | Fallo tras capturar no comunica éxito falso ni obliga a pesar de nuevo. | Fallo sin emisión y emisión incierta. | Estado central/físico. | PENDING |
| `LEC-01` | Modelo y sufijo Enter del lector coinciden con resolución automática. | Registrar configuración real. | Modelo y recorrido. | PENDING |
| `LEC-02` | Manga, Trabajo y responsable activo permanecen visibles antes de pesar. | José y Pedro consecutivos. | Capturas. | PENDING |
| `LEC-03` | El foco vuelve al escaneo sin mouse tras éxito/error. | Tres mangas consecutivas. | Video o registro de teclado. | PENDING |
| `LEC-04` | QR incorrecto no borra contexto válido ni muta. | QR de otro módulo. | Estado antes/después. | PENDING |
| `LEC-05` | Cambiar manga/intención limpia la anterior explícitamente. | Control seguido de final/otra manga. | Contextos e IDs. | PENDING |
| `LEC-06` | Timeout o sesión visible evita uso silencioso por otra persona. | Espera equivalente al timeout real. | Expiración y recuperación. | PENDING |
| `LEC-07` | Pedro no hereda atribución/permisos de José. | Relevo y nuevo escaneo. | Auditoría de actores. | PENDING |
| `LEC-09` | Éxito, duplicado y error usan texto además de color/sonido. | Provocar los tres. | Capturas y comprensión. | PENDING |
| `LEC-10` | Duplicados, escaneo incompleto o fuera de orden no duplican hechos. | Ráfaga controlada. | IDs aceptados/rechazados. | PENDING |
| `LEC-11` | Flujo principal funciona sin mouse con objetos reales. | Escáner/teclado y manga en manos. | Observación. | PENDING |
| `LEC-12` | Desconexión/reinicio deja recuperación segura. | Reiniciar navegador/estación. | Estado antes/después. | PENDING |
| `ADM-01` | Supervisor encuentra “Registrar relevo — continúa incompleta” con vocabulario de planta. | Entrar desde navegación normal. | Recorrido sin URL dictada. | PENDING |
| `ADM-02` | Manga, control y saliente preceden a datos secundarios. | Manga controlada representativa. | Captura. | PENDING |
| `ADM-03` | El formulario no oculta entrante, motivo ni confirmación. | Viewport objetivo. | Captura/observación. | PENDING |
| `ADM-04` | No hay overflow global; scroll interno es controlado. | Viewports y zoom reales. | Capturas. | PENDING |
| `ADM-05` | Búsqueda, cero resultados y manga no elegible se distinguen. | Tres consultas. | Capturas. | PENDING |
| `ADM-06` | Carga/error/recencia no presentan datos obsoletos como vigentes. | Cortar API y forzar versión antigua. | Timestamp y mensajes. | PENDING |
| `ADM-07` | Supervisor/Gerente ven la acción; rol limitado no la ve ni ejecuta. | Dos perfiles reales de prueba. | UI y API 403. | PENDING |
| `ADM-08` | Confirmar relevo explica que conserva manga/QR y cambia responsabilidad. | Cancelar una vez y confirmar otra. | Diálogo y auditoría. | PENDING |
| `ADM-09` | Tab/Shift+Tab, foco y nombres accesibles cubren el formulario. | Solo teclado. | Registro de foco. | PENDING |
| `ADM-10` | Versión/conflicto concurrente permite refrescar sin doble tramo. | Dos sesiones sobre la manga. | Error y recuperación. | PENDING |
| `ADM-11` | La vista diferencia `CONTINUIDAD_PENDIENTE` de final/impresión. | Comparar estados. | Explicación del supervisor. | PENDING |
| `IMP-01` | Equipo/DPI/papel/orientación coinciden con `109×50 mm` 2-up. | Registrar configuración real. | Foto y configuración saneada. | PENDING |
| `IMP-02` | Preview SVG y papel coinciden en orden, márgenes y columnas. | Imprimir CONTROL y FINAL. | Foto lado a lado. | PENDING |
| `IMP-03` | Neto, aporte, unidad y estado se leen completos. | Tres valores del dataset. | Inspección física. | PENDING |
| `IMP-04` | El QR original se lee después de pegar/superponer stickers sin QR. | Pegar dos CONTROL y un FINAL. | Lectura con lector real. | PENDING |
| `IMP-05` | Cada sticker se asocia inequívocamente con su manga. | Dos mangas próximas. | Observación retiro/pegado. | PENDING |
| `IMP-06` | Una etiqueta, 2-up y última columna no mezclan identidades. | Trabajos de 1 y 2 etiquetas. | Muestras físicas. | PENDING |
| `IMP-07` | Papel agotado/desconexión/atasco no comunican impresión confirmada. | Un fallo real o seguro por tipo. | Estado central y estación. | PENDING |
| `IMP-08` | Reintento usa mismo job; reemplazo de preetiqueta sigue versionado. | Fallo sin emisión y soporte QR dañado. | IDs/versiones. | PENDING |
| `IMP-09` | Reintento no duplica control ni QR vigente. | Mismo `print_job_id`. | Historial. | PENDING |
| `IMP-10` | La manga conserva su preetiqueta y recibe cada sticker antes de salir. | Recorrido completo. | Secuencia física. | PENDING |
| `IMP-11` | Sticker de peso dañado/perdido tiene copia controlada auditable. | Caso supervisado. | Procedimiento e historial. | PENDING |
| `IMP-12` | Estándar y diagnóstico no compiten con neto/aporte ni cubren QR. | Nombre WIP largo. | Foto y comprensión. | PENDING |
| `CON-01` | Aplica `bloqueo-seguro`; no hay acreditación offline. | Fuente TS K2 §10. | Captura de regla y estado. | PENDING |
| `CON-02` | Caída antes de resolver bloquea contexto y mutación. | Desconectar Central. | Captura/conteos. | PENDING |
| `CON-03` | Caída tras resolver y antes de confirmar bloquea control/final. | Interrumpir en estado listo. | Sesión y recuperación. | PENDING |
| `CON-04` | Respuesta perdida durante control conserva un solo hecho/job. | Repetir misma operación. | `operation_id` y conteos. | PENDING |
| `CON-05` | Reinicio conserva un estado honesto y permite reclamar el mismo job. | Reiniciar navegador/estación. | Antes/después. | PENDING |
| `CON-06` | Interrupción larga define dónde queda la manga sin mezclarla. | Aplicar procedimiento humano autorizado. | Foto y relato. | PENDING |
| `CON-07` | Reconexión/replay deja un control, un tramo y un job. | Doble envío. | IDs y saldo. | PENDING |
| `CON-09` | UI distingue no confirmado, control confirmado e impresión pendiente. | Tres estados contractuales. | Capturas. | PENDING |
| `CON-10` | Incertidumbre no imprime ni comunica disponibilidad falsa. | Emisión incierta. | Papel/estado central. | PENDING |
| `CON-11` | Timeout explica si reintentar impresión o resolver nuevamente. | Pérdida de acuse. | Mensaje y acción observada. | PENDING |
| `CON-12` | Diagnóstico permite soporte sin secretos. | Exportar muestra saneada. | Log saneado. | PENDING |

## 7. Casos BDD y negativos

| ID | Caso | Resultado | Evidencia | Estado |
|---|---|---|---|---|
| `K2-01/K2-10` | Controles, relevos y final. | Un `manga_id`, un QR de preetiqueta, cero QR en CONTROL/FINAL. | Artefactos y lectura final. | AUTO GREEN / FÍSICA PENDING |
| `K2-02/K2-08` | Control y reintento de impresión. | `0 UN`, cero Kardex, un control/job; retry no repite control. | API/DB/estación. | AUTO GREEN / FÍSICA PENDING |
| `K2-03/K2-12` | Render de 1 y 2 etiquetas. | Neto dominante, sin siglas/QR y TSPL termina `PRINT 1,1\r\n`. | SVG, TSPL y papel. | AUTO GREEN / FÍSICA PENDING |
| `K2-04/K2-07` | Segundo control y tara distinta. | Aporte `4.150`; tara no comparable revierte control/job. | Transacción y UI. | AUTO GREEN / HUMANA PENDING |
| `K2-05/K2-06` | Relevo misma OT y continuidad posterior. | Misma manga/QR, un tramo nuevo por frontera. | IDs y observación. | AUTO GREEN / HUMANA PENDING |
| `K2-09` | Emisión incierta. | No reimpresión ciega ni cambio productivo. | Estados de job. | AUTO PARCIAL / FÍSICA PENDING |
| `K2-11` | WIP y estándar. | Neto físico del conjunto; estándar rotulado como cálculo. | Papel y comprensión. | AUTO GREEN / HUMANA PENDING |
| `NEG-QR` | QR inválido/reemplazado/otro módulo. | Rechazo sin mutación. | Captura y conteos. | PENDING |
| `NEG-TARA` | Tara o fuente cambia. | `CONTROL_TARE_NOT_COMPARABLE`; no sticker engañoso. | Error y auditoría. | AUTO GREEN / FÍSICA PENDING |
| `NEG-FINAL` | Manga ya finalizada. | No nuevo control/relevo/final. | Error y conteo. | PENDING |
| `IDEM-01` | Doble control/relevo/F2. | Un solo efecto por operación. | Claves e IDs. | AUTO GREEN / OPERATIVA PENDING |
| `OFF-01` | Central no disponible. | Bloqueo seguro, sin éxito ni impresión autoritativa. | Capturas. | PENDING |

## 8. Observación de usabilidad

Entregar las tareas sin indicar dónde pulsar. Registrar por participante:

| Tarea | Completó | Ayuda | Duda/retroceso/casi-error | Tiempo | Evidencia |
|---|---|---|---|---|---|
| Operador registra CONTROL y pega sticker sin cubrir QR. | | | | | |
| Supervisor registra relevo de José a Pedro. | | | | | |
| Pedro resuelve el mismo QR y reconoce su responsabilidad. | | | | | |
| Operador recupera un fallo sin volver a pesar. | | | | | |
| Almacén resuelve el QR original después del final. | | | | | |

## 9. Evidencia, veredicto y firma

Evidencia obligatoria: capturas a viewport objetivo; fotos de balanza,
impresora, manga y stickers; preview/papel lado a lado; lectura del QR pegado;
IDs/estados antes/después; tiempos y dudas; logs saneados. Registrar hallazgos
`P0..P3`, responsable y revalidación.

| Campo | Valor actual | Regla de salida |
|---|---|---|
| `functional_validation` | `qa_green` | Solo cambia a `uat_accepted` con aceptación funcional humana registrada. |
| `ux_validation` | `provisional` | Requiere recorrido representativo sin ayuda crítica ni casi-error P0/P1. |
| `physical_uat` | `pending` | Requiere equipo/papel/lector/balanza reales y evidencia completa. |
| `release_constraint` | `no_habilitar_en_planta` | Solo retirar tras aceptación humana de todos los gates aplicables. |

**Fecha de ejecución:** ______  
**Responsable UAT:** ______  
**Supervisor participante:** ______  
**Operador de Pesaje:** ______  
**Maquinistas:** ______ / ______  
**Veredicto humano y firma/aceptación:** ______
