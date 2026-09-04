---
tipo: recibo_ejecucion
estado: qa-green-uat-local
tags: [agentes, evidencia, scm, pesaje, color, transparencia]
fecha: 2026-09-03
historia: "[[US-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
dev: "[[DEV-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
---

# REC-2026-09-03: Identidad visual de color en Pesaje

## Objetivo y alcance

- **Historia / DEV:** US-010K3 / DEV-010K3.
- **Porción vertical ejecutada:** contrato Central → estación y tarjeta de
  identidad del contenido con muestra sólida o patrón Transparente.
- **Fuera de alcance respetado:** no se pesó, imprimió, cambió estado, reseteó
  la UAT ni modificó snapshots históricos.
- **Branch / worktree / commit:** worktree compartido sucio; sin commit.
- **Gate de entrada:** autorización humana equivalente para la mejora visual.
- **Gate solicitado:** funcional-verde local y UAT visual disponible.

## Cambios

| Archivo o componente | Motivo | Tipo |
|---|---|---|
| `backend/app/services/scm_weighing_service.py` | Proyectar identidad, familia y HEX de color; evitar duplicado Transparente en Pesaje. | producto |
| `modulo-pesaje/frontend/src/components/ScmWeighing.jsx` | Reunir pieza y color en la identidad principal. | producto |
| `modulo-pesaje/frontend/src/index.css` | Muestra de 44 px, sólido/Transparente/sin referencia. | producto |
| pruebas Central, estación y componente | Contrato, passthrough, patrón y HEX. | prueba |
| `modulo-pesaje/frontend/qa/color-identity.*` | Fixture aislado para evidencia visual. | prueba |
| Story, TS, DEV, prototipo, endpoint y UAT K3 | Trazabilidad y gates honestos. | documento |

## Verificaciones ejecutadas

| Comando / revisión | Resultado | Evidencia | Interpretación |
|---|---|---|---|
| `scripts/test.ps1 -Component pesaje` baseline | `147 passed`, 3 warnings preexistentes del heartbeat SQLite | consola | línea base verde |
| `scripts/test-contracts.ps1` baseline | proveedor `1 passed`; consumidor `2 passed` | consola | contrato previo verde |
| RED Central/UI | `KeyError color_hex`; 2 casos UI sin muestra | fallos esperados | brecha reproducida |
| Central focal | `2 passed, 50 deselected` | consola | proyección y deduplicación verdes |
| estación backend focal | `1 passed, 11 deselected` | consola | identidad preservada |
| estación UI completa | `69 passed` en 11 archivos | consola | regresión UI verde |
| estación backend final | `147 passed` | consola | regresión backend verde |
| `npm run build` estación | build Vite verde | `dist` | artefacto compilable |
| `scripts/test.ps1 -Component backend` | `515 passed`, `1 skipped`, `1 failed` | `test_scm_portfolio_demo.py` falla por apertura sin líneas | fallo reproducible fuera de Pesaje y de los archivos modificados; CI global no verde |
| `scripts/uat-local.ps1 Update` | servicios LISTO; datos conservados | status local | mejora activa en UAT local |
| resolución real de M001 | `TRANSPARENTE`, `#EAF7F7`, bloqueo K4 intacto | respuesta local | contrato extremo a extremo verde |

## Evidencia UX y operativa

- **Dispositivo / viewport:** navegador desktop, `1440 × 1200`, simulación local.
- **Estados capturados:** QR resuelto, Transparente, foto ausente y Trabajo no iniciado.
- **Comparación con wireflow:** código de manga sigue dominante; pieza/color se
  agrupan; diagnóstico y acción conservan jerarquía.
- **Accesibilidad básica:** nombre textual obligatorio, muestra con nombre
  accesible, patrón no depende solo del color.
- **Validación humana realizada:** no; pendiente observación representativa.
- **Captura:** `output/qa/uat-color-identidad-transparente.png`.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Comparar Transparente y blanco sólido con operador | requiere sesión humana | confusión residual | responsable UAT |
| Puesto, distancia y monitor reales | entorno simulado | tamaño/contraste | responsable UAT |
| Balanza, lector e impresora reales | cambio no autoriza hardware | integración física | responsable UAT |
| Despliegue productivo | fuera de alcance | operación de planta | release controlado |
| Reparar seed de Portfolio Demo | brecha ajena al incremento: `OPENING_LINES_REQUIRED` | CI global permanece rojo | incremento dueño de Portfolio Demo |

## Resultado

```yaml
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** reconocimiento físico de transparente frente a blanco
  y legibilidad desde la postura real.
- **Decisión humana pendiente:** aceptar o ajustar muestra/patrón durante UAT.
- **Observación productiva / marcha blanca:** pendiente.
- **Siguiente acción segura:** reescanear M001 en la estación local y validar
  visualmente sin pesar hasta que Central inicie el Trabajo.
