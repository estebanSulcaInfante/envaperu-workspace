---
tipo: uat
uat_id: UAT-US-010K7-CIERRE-SEGURO-20260903
estado: lista-para-ejecucion-local
modalidades_uat: [funcional, operativa, fisica]
historia: "[[US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
tech_spec: "[[TS-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
dev: "[[DEV-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
perfiles_uat:
  - "[[PERF_UAT_Estacion_Pesaje]]"
  - "[[PERF_UAT_Lector_Compartido_Tablet]]"
  - "[[PERF_UAT_Impresion]]"
  - "[[PERF_UAT_Conectividad_Contingencia]]"
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
fecha_preparacion: 2026-09-03
tags: [uat, scm, pesaje, control-por-defecto, cierre-deliberado, f2]
---

# UAT US-010K7 — control por defecto y cierre final deliberado

## 1. Objetivo, entorno y unidad

Comprobar que una omisión ya no cierra la manga: después de resolver un QR,
F2 registra **Control de peso** por defecto. El cierre solo ocurre tras marcar
**Cerrar manga en este pesaje**, revisar código/NET y pulsar la confirmación
explícita. Enter y cancelar no mutan.

| Campo | Valor |
|---|---|
| UAT / RUN | `UAT-US-010K7-CIERRE-SEGURO-20260903` / completar al ejecutar |
| Entorno | UAT local aislada: Central `5174`, API `5100`, Pesaje `5051` |
| Unidad principal | `OF000001-OT002-M001` |
| `manga_id` | `cc2319c4-a157-4b6e-925a-0fe2489efeaf` |
| QR/preetiqueta vigente | `ba676a92-97ba-40d6-a8a3-6331e1e83a7f`, versión 1 |
| Preparación actual | `EN_LLENADO`, versión 9, mismo QR y cupo |
| Control previo conservado | bruto `4.820 kg`, tara `0.030 kg`, NET `4.790 kg` |
| Lectura inicial sugerida | bruto `5.100 kg`, NET `5.070 kg` |
| Actor de estación | Operador UAT `4`; maquinista del Trabajo `Jose Quispe` |
| Contingencia | `bloqueo-seguro`; no existe operación offline autorizada |

La segunda reapertura fue ejecutada por Jefa de Producción UAT `3` con
`operation_id=a3afda06-ff5f-4f2f-8db2-03a3f694dd76`. Invalidó únicamente la
postetiqueta accidental `e304d059-c8b1-4455-98a6-b35d57182e6f`; no creó otra
manga ni otro QR.

## 2. Información, acción, estados y recuperación

- Información primaria: NET, código completo y rótulo textual
  **CONTROL DE PESO** o **CIERRE FINAL**.
- Acción primaria única de la pantalla: `Pesar manga (F2)`.
- Espera: sin QR, sin balanza, NET inválido o sin aumento sobre el control.
- Listo seguro: Control verde y casilla de cierre apagada.
- Cierre seleccionado: bloque rojo, parcial subordinado y aviso de confirmación.
- Error: texto con causa/recuperación; sin acuse no hay éxito ni impresión.
- Recuperación del diálogo: foco en `Cancelar; volver a Control`; Escape hace lo
  mismo; F2 dentro del diálogo no confirma.

## 3. Secuencia UAT sin indicar al operador dónde pulsar

| Paso | Tarea entregada | Resultado esperado | Evidencia |
|---|---|---|---|
| 1 | Escanear M001 y revisar qué ocurrirá al pulsar F2. | Enter solo resuelve; el operador identifica Control, manga abierta y NET. | Captura/relato; cero hechos nuevos. |
| 2 | Con bruto `5.100 kg`, registrar un control sin cambiar selectores. | Un `AVANCE_KG` NET `5.070`; M001 sigue `EN_LLENADO`; no hay final. | Control, operación, estado y sticker CONTROL. |
| 3 | Sin aumentar peso, volver a pulsar F2. | Bloqueo `Sin aumento desde el último control`; cero duplicados. | Conteo antes/después. |
| 4 | Aumentar el bruto por encima de `5.100 kg` y preparar el cierre. | El operador debe seleccionar cierre; aparece estado rojo. | Captura de intención. |
| 5 | Pulsar F2 y luego F2 repetido/sostenido en el diálogo. | Aparece manga + NET; ningún F2 confirma ni llama Central. | Estado/IDs antes-después. |
| 6 | Cancelar o pulsar Escape. | Vuelve a Control, conserva QR/lectura y no muta. | Captura de retorno. |
| 7 | Seleccionar cierre otra vez y confirmarlo explícitamente. | Un solo final vigente, comprobante final y estado pendiente de Almacén. | Pesaje, postetiqueta y auditoría. |
| 8 | Resolver el segundo QR disponible y volver a M001. | Cada QR limpia la intención de cierre y vuelve al estado seguro permitido. | Anuncio de cambio y ausencia de cierre cruzado. |

Condición de parada: código/NET distintos del objeto, cierre sin diálogo, F2 en
el diálogo que muta, Central no disponible, impresión incierta o identidad de
QR reemplazada. No resetear el dataset para repetir.

## 4. ATDD y casos de aceptación

| ID | Criterio | Estado |
|---|---|---|
| K7-01 | F2 sin tocar selector llama control y nunca final. | AUTO GREEN / HUMANA PENDING |
| K7-02 | Seleccionar cierre + F2 abre diálogo sin llamada final. | AUTO GREEN / HUMANA PENDING |
| K7-03 | Cancelar/Escape vuelve a Control sin mutar. | AUTO GREEN / HUMANA PENDING |
| K7-04 | Confirmación explícita produce un cierre idempotente. | AUTO GREEN / HUMANA PENDING |
| K7-05 | F2 repetido no atraviesa el diálogo. | AUTO GREEN / FÍSICA PENDING |
| K7-06 | Si solo existe final, F2 queda bloqueado hasta seleccionar cierre. | AUTO GREEN / HUMANA PENDING |
| K7-07 | Cierre parcial no aparece antes de seleccionar cierre. | AUTO GREEN / HUMANA PENDING |

## 5. Perfiles instanciados

| IDs fuente | Criterio concreto en este run | Estado |
|---|---|---|
| `PES-01..04` | A 1440×1200, NET domina; código y Control/Cierre se ven junto a la acción primaria sin depender solo del color. | QA VISUAL GREEN / PUESTO REAL PENDING |
| `PES-05..08` | Enter no muta; F2 usa la intención visible; peso repetido, QR inválido y tecla sostenida no crean otro hecho. | AUTO GREEN / FÍSICA PENDING |
| `PES-09..12` | Operador completa control/cancelación/cierre sin guía crítica y reconoce resultado/recuperación. | PENDING |
| `LEC-01..05` | Lector con sufijo Enter resuelve, mantiene código visible y un QR nuevo restablece Control. | AUTO PARCIAL / LECTOR REAL PENDING |
| `LEC-09..12` | Texto acompaña color; duplicado, ráfaga y reconexión no heredan intención ni duplican. | AUTO PARCIAL / FÍSICA PENDING |
| `IMP-01..06` | CONTROL conserva el QR de preetiqueta; final solo nace tras confirmación y se asocia a la manga visible. | CONTRATO GREEN / PAPEL PENDING |
| `IMP-07..12` | Fallo/reintento no duplica hecho o impresión; salida incierta no comunica éxito. | AUTO PARCIAL / TSC REAL PENDING |
| `CON-01..07` | Aplica bloqueo seguro; respuesta incierta conserva operación y doble envío tiene un solo efecto. | CONTRATO GREEN / FALLA FÍSICA PENDING |
| `CON-09..12` | La UI diferencia listo, en curso, sin confirmar y confirmado con recuperación textual. | AUTO GREEN / HUMANA PENDING |

`LEC-06..08` quedan fuera: esta estación no define timeout/tablet en K7. El
relevo de identidad no cambia. `CON-08` no aplica porque el selector cliente no
reserva ni libera stock.

## 6. Evidencia técnica y visual preparada

- Focal: 41/41 pruebas de estado/componente.
- Frontend de estación: 74/74 pruebas y build Vite verde.
- Contrato Central–Pesaje: 3/3 pruebas verdes.
- Workspace: backend 518 verdes, 1 skip y 1 fallo ajeno en el seed de portfolio
  demo (`OPENING_LINES_REQUIRED`); reproducido aislado y no tocado por K7.
- Capturas agente a 1440×1200:
  - `output/qa/us-010k7/01-control-por-defecto.png`
  - `output/qa/us-010k7/02-cierre-seleccionado.png`
  - `output/qa/us-010k7/03-confirmacion-cierre.png`
  - `output/qa/us-010k7/04-cancelacion-retorna-control.png`

Las capturas demuestran render y jerarquía, no aceptación humana. La validación
de lector, balanza, impresora, papel, postura, distancia, EPP y ritmo reales
continúa pendiente.

## 7. Veredicto

```yaml
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

**RUN / fecha:** ______  
**Responsable / operador:** ______  
**Viewport y hardware:** ______  
**Ayuda, dudas o casi-error:** ______  
**Veredicto y firma humana:** ______

