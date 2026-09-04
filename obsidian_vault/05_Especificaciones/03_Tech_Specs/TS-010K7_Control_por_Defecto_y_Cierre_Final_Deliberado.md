---
tipo: tech-spec
estado: implementada-pendiente-uat
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
historia: "[[US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
fecha_creacion: 2026-09-03
fecha_actualizacion: 2026-09-03
tags: [scm, pesaje, react, ux-segura, atdd]
relaciones:
  - "[[PROTO_US-010K7_Control_por_Defecto_y_Cierre_Deliberado]]"
  - "[[TS-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
  - "[[DEV-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
---

# TS-010K7: control por defecto y cierre final deliberado

## Alcance y arquitectura

Corrección cliente en `ScmWeighing` y `getWeighingState`. No hay migración ni
cambio de API. `POST .../manga-weighing-controls` sigue siendo control;
`POST .../manga-weighings` sigue siendo final. El cliente decide la ruta solo
después de una intención visible.

## Cuatro contratos

### Dominio

- No cambia ningún hecho, transición, permiso, peso o idempotencia Central.
- La ausencia de selección representa Control cuando esa capacidad existe.
- Nunca se crea una reapertura ni compensación automática.

### API y datos

- `closeManga=false` envía el control existente.
- `closeManga=true` solo abre confirmación; no reserva `operation_id` ni llama API.
- `confirmFinal()` conserva `operation_id` en respuesta incierta y llama al
  endpoint final una vez por intento lógico.
- Cancelar antes del envío deja ambos endpoints en cero llamadas.

### Interacción

- QR nuevo: `closeManga=false`, parcial limpio y diálogo cerrado.
- F2 normal: control por defecto.
- Selector de cierre: cambia el estado visible; el parcial solo aparece allí.
- F2 en cierre: abre diálogo `role=dialog`, `aria-modal=true` y foco en Cancelar.
- F2/repeat dentro del diálogo: cero mutación; Escape cancela cuando no hay envío.
- Confirmar: final; cancelar: vuelve a Control y conserva manga/lectura.
- Si no hay capacidad de control, el modo inicial explica que debe seleccionar
  cierre; no ejecuta final automáticamente.

### Presentación

- Bloque seguro verde/azul para Control; bloque de cierre ámbar/rojo solo al
  seleccionarlo.
- Estado y botón explican `seguirá abierta` o `requiere confirmación`.
- Diálogo muestra código completo, NET con tres decimales y consecuencia.
- Un único botón principal permanece en la pantalla.

## ATDD, baseline y primera RED

Baseline 2026-09-03:
`npm test -- --run src/components/ScmWeighing.test.jsx src/utils/scmWeighingState.test.js`
→ 2 archivos, 36 pruebas verdes.

Primera RED: al resolver una manga y pulsar F2 sin tocar selectores, esperar
`scmWeighingApi.control` y cero `confirm`; el código vigente llama a `confirm`.

| BDD | Prueba |
|---|---|
| K7-01 | componente + estado: default Control y ruta `control` |
| K7-02/K7-03 | componente: diálogo sin mutación y cancelación segura |
| K7-04 | componente: confirmación final única y resultado |
| K7-05 | componente: F2 repetido no confirma diálogo |
| K7-06 | estado/componente: solo final requiere selección |
| K7-07 | componente: parcial oculto hasta cierre |

Regresión: focal UI, suite frontend completa de Pesaje y build. Contratos y
backend no deberían cambiar; ejecutar pruebas de contrato como comprobación de
no regresión.

Resultado 2026-09-03: focal 41/41, frontend estación 74/74, build PASS y
contratos 3/3. La suite integral obtuvo 518 pruebas backend verdes y un fallo
ajeno/reproducible en el seed portfolio (`OPENING_LINES_REQUIRED`).

## QA visual, reversibilidad y UAT

Capturar: Control listo por defecto, Cierre seleccionado, diálogo y retorno al
Control. Verificar teclado, Escape, F2 y foco. Rollback: revertir únicamente el
estado/presentación cliente; no existen datos nuevos. UAT combina PES, LEC, IMP
y CON, mantiene hardware físico pendiente y no habilita planta.
