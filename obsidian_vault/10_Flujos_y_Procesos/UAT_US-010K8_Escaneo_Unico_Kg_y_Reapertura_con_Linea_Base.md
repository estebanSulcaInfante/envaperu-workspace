---
tipo: uat
uat_id: UAT-US-010K8-QR-UNICO-BASE-20260904
estado: lista-para-ejecucion-local
modalidades_uat: [funcional, operativa, fisica]
historia: "[[US-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]]"
tech_spec: "[[TS-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]]"
dev: "[[DEV-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]]"
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
perfiles_uat:
  - "[[PERF_UAT_Estacion_Pesaje]]"
  - "[[PERF_UAT_Lector_Compartido_Tablet]]"
  - "[[PERF_UAT_Escritorio_Administrativo]]"
  - "[[PERF_UAT_Impresion]]"
  - "[[PERF_UAT_Conectividad_Contingencia]]"
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
fecha_preparacion: 2026-09-04
tags: [uat, scm, pesaje, kg, qr, reapertura, linea-base]
---

# UAT US-010K8 — escaneo único, kg y reapertura con línea base

## 1. Objetivo y alcance

Comprobar con las dos preetiquetas disponibles que cada lectura QR habilita
como máximo un pesaje exitoso, de modo que colocar una segunda manga sin
escanearla no pueda atribuir un control falso a la primera. Comprobar además
que una reapertura nunca borra el cierre anterior y que solo
`CONTINUAR_LLENADO` conserva su NET como línea base.

| Campo | Valor |
|---|---|
| RUN | `UAT-US-010K8-QR-UNICO-BASE-20260904` / completar al ejecutar |
| Entorno | UAT local aislada: Central `5174`, API `5100`, Pesaje `5051` |
| Escenario | `jarra-real-6l-pesaje-piezas`; actualizar sin Reset para conservar la sesión actual |
| Manga A | `OF000001-OT002-M001`; `manga_id=cc2319c4-a157-4b6e-925a-0fe2489efeaf`; `label_id=ba676a92-97ba-40d6-a8a3-6331e1e83a7f`; `EN_LLENADO` v12; último control NET `4.790 kg` |
| Manga B | `OF000001-OT002-M002`; `manga_id=13732aed-c8d4-438b-a919-b09afddca2d0`; `label_id=90329ac2-eb2b-49f1-a15b-ded483730c54`; `PREETIQUETADA` v2; sin control/final |
| Actores | Operador de Pesaje UAT `4`; María José/Jefa de Producción UAT `3` para reapertura |
| Contingencia | `bloqueo-seguro`; no existe confirmación offline autorizada |
| Hardware | simulación local disponible; modelo real de lector, balanza, impresora, papel, viewport, distancia, postura y EPP por registrar |

Incluye estación kg-first, un solo botón/F2, control por defecto, reescaneo de
la misma manga, reapertura administrativa de dos tipos, historial, impresión e
idempotencia. Excluye tolerancia operativa de 90 g, inventario/Kardex integral
en kg, retorno de consumo, merma y despliegue productivo.

Condición de parada: código distinto del objeto, segundo control sin reescaneo,
cierre borrado, línea base incorrecta, existencia ya recibida en Almacén,
Central no disponible o impresión incierta presentada como éxito.

## 2. Información, acción y estados

- Primario: código de manga, pieza/color, estado, NET actual, último NET y
  diferencia; `CONTROL DE PESO` o `CIERRE FINAL` debe quedar inequívoco.
- Acción primaria única: `Pesar manga (F2)`.
- Listo: QR recién resuelto, lectura válida y aumento sobre la referencia.
- Éxito consumido: resultado visible, F2/selector bloqueados y mensaje
  `Pesaje registrado · escanee el siguiente QR`.
- Recuperación: retirar la manga y escanear el QR del siguiente pesaje, aunque
  sea el mismo QR.
- Reapertura Central: seleccionar tipo y motivo; retirar o marcar inválido el
  comprobante final anterior.

## 3. Secuencia física y digital

| Paso | Actor / objeto | Acción | Resultado esperado | Evidencia |
|---|---|---|---|---|
| 1 | Operador / manga A | Escanear A y Enter. | Solo resuelve. Muestra kg teóricos, último NET, NET actual y diferencia; no muestra conteo real para Fabricación simple. | Captura y conteo de hechos antes/después. |
| 2 | Operador / A | Con lectura estable y mayor a la referencia, pulsar F2 sin marcar cierre. | Un `AVANCE_KG`; A sigue abierta; sticker de control sin QR ni conteo. | `operation_id`, NET, aporte, estado e impresión. |
| 3 | Operador / B sin escanear | Retirar A, colocar B, cambiar la lectura y pulsar/doblar F2. | F2 permanece bloqueado; cero segunda llamada y cero hecho nuevo para A. | Captura de bloqueo y conteo Central. |
| 4 | Operador / A | Volver a escanear A, incluso el mismo QR. | Se rearma una sola intención y recupera el último NET desde Central. | Contexto y botón habilitado. |
| 5 | Operador / A | Aumentar peso, marcar cierre, F2 y confirmación explícita. | Un final vigente; A se bloquea y queda pendiente de Almacén. | Cierre, postetiqueta, historial. |
| 6 | JP / A en Central | Abrir pesaje, elegir `CONTINUAR_LLENADO`, indicar motivo y confirmar. | Final pasa a `REABIERTO`, sigue visible en historial; A vuelve abierta, misma identidad/QR/cupo; NET final queda como base. | Reapertura, evento, versión, base y postetiqueta invalidada. |
| 7 | Operador / A | Escanear el mismo QR; simular un NET igual/menor y luego uno mayor. | Igual/menor bloqueado. Mayor acepta un control cuyo aporte es exactamente nuevo NET menos base. | Capturas y decimales a `0.001 kg`. |
| 8 | Operador + JP / B | Cerrar B con una lectura declarada errónea y reabrir como `CIERRE_ACCIDENTAL`. | Cierre queda histórico, pero base nula; el último control válido —si existe— sigue siendo la referencia. | Tipo/base e historial. |
| 9 | Operador / B | Reescanear B y usar una lectura corregida menor que el cierre erróneo pero mayor que su último control válido. | Acepta el nuevo control/final; el cierre erróneo no impone monotonicidad. | NET/aporte y consulta posterior. |
| 10 | Soporte / A o B | Repetir una confirmación con la misma clave y simular pérdida de respuesta. | Un solo hecho; recuperación honesta, sin impresión duplicada automática. | Operación, eventos y trabajos de impresión. |

## 4. Casos de aceptación

| ID | Caso | Resultado esperado | Estado |
|---|---|---|---|
| `K8-01` | Control exitoso y cambio de lectura sin QR | F2 continúa bloqueado | AUTO GREEN / HUMANA PENDING |
| `K8-02` | Manga B colocada sin escanear | Ningún hecho atribuido a A | AUTO GREEN / FÍSICA PENDING |
| `K8-03` | Reescaneo del mismo QR A | Una intención nueva; último NET persistido | AUTO GREEN / HUMANA PENDING |
| `K8-04` | Cierre final aceptado | Intención consumida; resultado visible | AUTO GREEN / HUMANA PENDING |
| `K8-05` | Contexto simple de Fabricación | Referencias en kg; sin captura/presentación de conteo real | AUTO GREEN / HUMANA PENDING |
| `K8-06` | Reapertura accidental | Cierre histórico, base nula | AUTO GREEN / HUMANA PENDING |
| `K8-07` | Reapertura para continuar | Cierre histórico, base NET positiva; aporte incremental | AUTO GREEN / HUMANA PENDING |
| `K8-08` | Tipo inválido, versión/permiso/recepción o replay | Rechazo/idempotencia sin mutación indebida | AUTO PARCIAL / HUMANA PENDING |
| `K8-09` | Diálogo Central | Tipo, efecto, mismo QR y retiro del final se comprenden | AUTO GREEN / HUMANA PENDING |

## 5. Criterios de perfiles instanciados

| ID fuente | Criterio concreto | Preparación y evidencia | Estado |
|---|---|---|---|
| `PES-01` | NET y kg se reconocen primero desde la posición real. | Foto del puesto + captura; registrar distancia. | PENDING |
| `PES-02` | Desconectada, inestable, estable, bloqueada y confirmada son distinguibles por texto. | Provocar y capturar cinco estados. | PENDING |
| `PES-03` | A/B, estado y siguiente acción se ven sin competir con NET. | Captura completa en viewport real. | PENDING |
| `PES-04` | Bruto, tara, NET, último NET y diferencia usan tres decimales y no se confunden. | Comparación con lectura física/simulada. | PENDING |
| `PES-05` | Enter no muta; cada F2 exitoso exige un escaneo nuevo. | Estados/eventos antes y después. | AUTO GREEN / FÍSICA PENDING |
| `PES-06` | F2 bloqueado explica “escanear siguiente QR” o la causa Central. | Capturas de bloqueo. | AUTO GREEN / HUMANA PENDING |
| `PES-07` | Doble F2, tecla sostenida y cambio de peso producen un solo hecho. | Operación y conteo Central. | AUTO GREEN / FÍSICA PENDING |
| `PES-08` | QR inválido/reemplazado/ajeno rechaza sin conservar una manga insegura. | Tres rechazos y cero mutación. | PENDING |
| `PES-09` | El operador completa A→B y A→A con manos/EPP/ritmo reales. | Observación, tiempo, ayuda y casi-error. | PENDING |
| `PES-10` | Tras éxito reconoce código, NET, estado y obligación de reescaneo. | Relato sin asistencia. | PENDING |
| `PES-11` | Colocar B sin escanear no confirma con A. | Paso 3, foto e IDs. | AUTO GREEN / FÍSICA PENDING |
| `PES-12` | Fallo posterior a captura no comunica disponibilidad ni éxito falso. | Respuesta perdida y estado Central. | PENDING |
| `LEC-01` | El lector real envía Enter y resuelve una vez. | Modelo/configuración y video corto. | PENDING |
| `LEC-02` | Código/OT/color de A o B permanecen visibles antes de F2. | Captura por QR. | PENDING |
| `LEC-03` | El foco vuelve al escáner después de resolver, éxito y error. | Recorrido sin mouse. | AUTO GREEN / LECTOR PENDING |
| `LEC-04` | QR incorrecto no acredita ni deja una identidad anterior habilitada. | Secuencia A→incorrecto→F2. | PENDING |
| `LEC-05` | Cambiar A→B exige escaneo explícito y limpia la intención consumida. | Paso 3/4 e IDs. | AUTO GREEN / FÍSICA PENDING |
| `LEC-07` | El operador no hereda capacidad de reapertura de la JP. | Comparar perfiles UI/API. | PENDING |
| `LEC-09` | Éxito, duplicado y error usan texto además de color. | Capturas y explicación. | PENDING |
| `LEC-10` | Ráfaga, duplicado o QR incompleto no crea hechos cruzados. | Secuencia e IDs. | PENDING |
| `LEC-11` | Escaneo y F2 se completan sin mouse con objetos reales. | Observación. | PENDING |
| `LEC-12` | Desconexión/reinicio exige resolver nuevamente y no rearma A silenciosamente. | Reinicio y recuperación. | PENDING |
| `ADM-01` | JP encuentra `Ver pesaje` y comprende los dos tipos sin URL dictada. | Recorrido observado. | PENDING |
| `ADM-07` | Solo JP/GG puede reabrir; Operador/Supervisor no ve/ejecuta la acción. | Dos perfiles y rechazo API. | PENDING |
| `ADM-08` | La acción explica alcance, invalida final y exige tipo/motivo. | Cancelar/confirmar y auditoría. | AUTO GREEN / HUMANA PENDING |
| `ADM-09` | Tipo, motivo y confirmación se recorren con teclado/foco visible. | Registro de Tab/Shift+Tab. | PENDING |
| `ADM-10` | Versión obsoleta pide actualizar antes de reabrir. | Dos pestañas. | PENDING |
| `ADM-11` | Vigente, `REABIERTO`, base e historial no se confunden. | Consulta antes/después. | PENDING |
| `IMP-01` | Impresora/DPI/papel/layout corresponden al puesto. | Configuración y foto. | PENDING |
| `IMP-02` | Preview y papel coinciden para control y final. | Comparación lado a lado. | PENDING |
| `IMP-03` | Código, NET, kg, estado y texto sin conteo son legibles. | Inspección física. | PENDING |
| `IMP-04` | La preetiqueta conservada se lee pegada después de reabrir. | Escaneo físico. | PENDING |
| `IMP-05` | Cada comprobante se asocia inequívocamente con A o B. | Observar retiro/pegado. | PENDING |
| `IMP-06` | 2-up no mezcla A/B ni desplaza el contenido. | Muestras físicas. | PENDING |
| `IMP-07` | Papel agotado/spool/salida incierta tienen recuperación honesta. | Un fallo físico. | PENDING |
| `IMP-08` | El final anterior se marca/retira y queda auditado al reabrir. | Foto + historial. | PENDING |
| `IMP-09` | Replay no duplica negocio ni impresión automática. | Job/operación. | AUTO PARCIAL / FÍSICA PENDING |
| `IMP-10` | La manga no sale con un comprobante final inválido aparente. | Secuencia física. | PENDING |
| `IMP-11` | Etiqueta dañada/perdida usa reemplazo controlado. | Caso y versiones. | PENDING |
| `IMP-12` | Información secundaria no reduce código/NET/estado. | Foto y comprensión. | PENDING |
| `CON-01` | Aplica `bloqueo-seguro`, autorizado por K8. | Fuente enlazada. | DOCUMENTADO |
| `CON-02` | Caída antes de resolver bloquea sin mutación. | Captura/log saneado. | PENDING |
| `CON-03` | Caída después de resolver y antes de F2 no confirma. | Estado/objeto segregado. | PENDING |
| `CON-04` | Respuesta perdida conserva `operation_id` y un solo hecho. | Operación/evento. | PENDING |
| `CON-05` | Reinicio no presenta el escaneo anterior como armado. | Antes/después. | PENDING |
| `CON-06` | Interrupción indica retirar/segregar la manga para no mezclar A/B. | Procedimiento observado. | PENDING |
| `CON-07` | Reconexión/replay produce un solo control/cierre. | Conteo Central. | PENDING |
| `CON-09` | La UI distingue sin confirmar, en curso, confirmado y escaneo consumido. | Capturas. | AUTO GREEN / HUMANA PENDING |
| `CON-10` | Incertidumbre no imprime ni comunica disponibilidad falsa. | Estado/job. | PENDING |
| `CON-11` | El mensaje indica reintentar la misma operación o reescanear, sin adivinar. | Relato del operador. | PENDING |
| `CON-12` | Diagnóstico no expone token ni `.env`. | Log saneado. | PENDING |

`LEC-06` no aplica: K8 no introduce timeout de sesión. `LEC-08` solo aplica si
el dispositivo objetivo resulta ser tablet. `ADM-02..06` y `ADM-12` no aplican
porque esta excepción no introduce tabla, búsqueda, filtro, paginación ni
exportación. `CON-08` no aplica: la reapertura usa conflicto de versión, pero no
reserva/libera stock.

## 6. Evidencia técnica preparada

- Backend + migración focal: `44 passed`.
- Estación completa: `76 passed` y build Vite verde.
- Central OT focal: `43 passed`.
- Pruebas cubren escaneo consumido, contexto kg, línea base, incremento,
  restricciones de datos y selector Central.
- Evidencia visual local: `output/qa/us-010k8/01-contexto-kg-listo.png` y
  `output/qa/us-010k8/02-pesaje-consumido-reescaneo.png` en viewport
  `1440 × 1200`; el segundo estado muestra diferencia normalizada a
  `0.000 kg`, F2 bloqueado y obligación de reescaneo.

La evidencia automática demuestra comportamiento, no comprensión humana ni
hardware. Falta ejecutar los pasos 1–10 con las dos mangas/QR y capturar lector,
balanza, impresora, papel y viewport representativos.

## 7. Veredicto pendiente

```yaml
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

**RUN / fecha:** ______  
**Manga A (`manga_id` / `label_id`):** ______  
**Manga B (`manga_id` / `label_id`):** ______  
**Hardware / viewport / distancia:** ______  
**Ayuda, dudas o casi-error:** ______  
**Veredicto y firma humana:** ______
