---
tipo: user-story
subtipo: correccion-vertical
estado: implementada-pendiente-uat
spec_phase: story
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
epica: "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
uat_profiles:
  - "[[PERF_UAT_Estacion_Pesaje]]"
  - "[[PERF_UAT_Lector_Compartido_Tablet]]"
  - "[[PERF_UAT_Impresion]]"
  - "[[PERF_UAT_Conectividad_Contingencia]]"
fecha_creacion: 2026-09-03
fecha_actualizacion: 2026-09-03
tags: [scm, pesaje, f2, control-por-defecto, cierre-deliberado, atdd]
relaciones:
  - "[[2026-09-03_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
  - "[[US-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
  - "[[US-010K6_Reapertura_Auditada_de_Manga_por_Cierre_Accidental]]"
  - "[[TS-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
  - "[[PROTO_US-010K7_Control_por_Defecto_y_Cierre_Deliberado]]"
  - "[[UAT_US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
---

# US-010K7: control por defecto y cierre final deliberado

## Fuentes y resultado

Fuentes: UAT K3/K6 del 2026-09-03, ADR de esta historia, contexto de la Balanza
compartida y contrato K3/K4 vigente.

**Como** operador de Pesaje  
**Quiero** que F2 registre por defecto un control y que cerrar exija una
selección y confirmación inequívocas  
**Para** que olvidar un selector no cierre una manga que seguirá llenándose.

Resultado observable: tras escanear una manga abierta, la pantalla dice
**Control de peso · seguirá abierta**. F2 registra `AVANCE_KG`. Solo después de
seleccionar **Cerrar manga en este pesaje**, F2 abre una confirmación con código
y NET; cancelar no muta y confirmar ejecuta un único cierre final.

## Alcance e invariantes

- UI y estado cliente de la estación SCM de Pesaje.
- Un único botón principal y la misma tecla F2.
- Control como intención segura inicial cuando está autorizado.
- Selector explícito, confirmación y cancelación segura del cierre.
- Cierre parcial subordinado a la intención de cierre.
- El backend, API, captura de balanza, pesos, etiquetas e idempotencia no cambian.
- Enter solo resuelve; ningún diálogo ni F2 repetido puede confirmar un cierre
  sin la acción explícita del usuario.

Fuera de alcance: reapertura automática, cambios de permisos, tolerancias,
inventario kg, conteo, hardware o despliegue productivo.

## Contexto de interacción

Información primaria: código de manga, NET y modo **Control/Cierre**. Acción
primaria: `Pesar manga (F2)`. Objeto: manga física con preetiqueta. Puesto:
Balanza/PC/lector/impresora compartidos; dimensiones físicas no confirmadas.
Error más costoso: cerrar y emitir evidencia final para una manga todavía
abierta. Riesgo UX `high`; perfiles PES, LEC, IMP y CON.

## Escenarios BDD

### K7-01 — F2 seguro por defecto

**Dado** QR vigente, lectura válida y capacidad de control  
**Cuando** el operador pulsa F2 sin tocar el selector  
**Entonces** se llama una vez a `AVANCE_KG`, la manga sigue abierta y no se
invoca el cierre final.

### K7-02 — Selección de cierre todavía no muta

**Dado** el modo Control inicial  
**Cuando** selecciona **Cerrar manga en este pesaje** y pulsa F2  
**Entonces** aparece confirmación con manga y NET  
**Y** Central todavía no recibió el cierre.

### K7-03 — Cancelación segura

**Dado** el diálogo de cierre  
**Cuando** cancela o pulsa Escape  
**Entonces** vuelve a Control, conserva el contexto y no crea ningún hecho.

### K7-04 — Cierre final deliberado e idempotente

**Dado** selector de cierre y confirmación visibles  
**Cuando** pulsa **Confirmar cierre de manga**  
**Entonces** se ejecuta una vez el cierre vigente y se muestra su resultado.

### K7-05 — Tecla repetida no atraviesa la guarda

**Dado** que el diálogo está abierto  
**Cuando** F2 se repite o queda sostenida  
**Entonces** no confirma el diálogo ni llama al backend.

### K7-06 — Solo final disponible

**Dado** que Central permite final pero no control  
**Cuando** se resuelve el QR  
**Entonces** el único botón no cierra directamente  
**Y** exige seleccionar cierre y completar la confirmación.

### K7-07 — Cierre parcial subordinado

**Dado** una manga NORMAL  
**Cuando** no ha seleccionado cierre  
**Entonces** no se ofrecen campos de cierre parcial  
**Y** al seleccionar cierre puede completar la excepción vigente.

## Gates

- READY-FOR-DESIGN: completo con evidencia real y regla aprobada.
- UX-READY: excepción explícita para implementación local; continúa
  `ux_validation: provisional` hasta revalidación.
- `physical_uat: pending` y `no_habilitar_en_planta` se conservan.

## Evidencia de implementación

El 2026-09-03 quedaron verdes K7-01..07, la regresión completa del frontend de
estación (74 pruebas), su build y el contrato Central–Pesaje. Las capturas de
Control, cierre, diálogo y cancelación se encuentran en
`output/qa/us-010k7/`. Esto acredita `functional_validation: qa_green`; no
reemplaza la UAT humana ni física.
