---
tipo: recibo_ejecucion
estado: cerrado-con-uat-pendiente
fecha: 2026-09-03
historia: "[[US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
dev: "[[DEV-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
uat: "[[UAT_US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
tags: [recibo, scm, pesaje, ux, f2]
---

# REC-2026-09-03-K7: Recibo — control por defecto y cierre deliberado

## Objetivo y alcance

- **Historia / DEV:** US-010K7 / DEV-010K7.
- **Porción vertical:** estado cliente, selector seguro, diálogo accesible,
  ATDD, QA visual, recuperación M001 y UAT instanciada.
- **Fuera de alcance:** API/backend, pesos, etiquetas, permisos, inventario,
  offline y despliegue productivo.
- **Branch / worktree / commit:** worktree compartido con cambios previos; sin
  commit creado por este incremento.
- **Gate de entrada:** autorización funcional explícita tras dos cierres
  accidentales en UAT.
- **Gate alcanzado:** implementación en review con QA verde; UAT humana/física
  pendiente.

## Cambios

| Archivo o componente | Motivo | Tipo |
|---|---|---|
| `ScmWeighing.jsx` / `scmWeighingState.js` | Control por defecto, cierre seleccionado y confirmación/cancelación segura. | producto |
| pruebas de `ScmWeighing` y estado | K7-01..07 y regresión del comportamiento previo. | prueba |
| `index.css` | Jerarquía verde/roja/ámbar y diálogo legible. | producto |
| US, TS, DEV, ADR, prototipo y UAT K7 | Trazabilidad y gate operativo. | documento |
| `output/qa/us-010k7/*.png` | Cuatro estados en viewport objetivo local. | evidencia |

## Verificaciones ejecutadas

| Comando / revisión | Resultado | Interpretación |
|---|---|---|
| focal K7 | 41/41 | Rutas de control/cierre y guardas verdes. |
| `npm test -- --run` estación | 74/74 | Regresión frontend verde. |
| `npm run build` estación | PASS | Bundle Vite generado. |
| `./scripts/test-contracts.ps1` | 3/3 | Copias e implementaciones Central–Pesaje compatibles. |
| `./scripts/test.ps1 -Component all` | 518 pass, 1 skip, 1 fail | Fallo fuera de K7 en seed portfolio sin líneas; el script detuvo fases posteriores. |
| prueba portfolio aislada | FAIL reproducible | Deuda preexistente/independiente, no causada por archivos frontend K7. |

## Evidencia UX y operativa

- **Dispositivo / viewport:** Chrome headless, 1440×1200, estación local 5051.
- **Estados capturados:** Control, cierre seleccionado, diálogo y cancelación.
- **Comparación con wireflow:** coincide; el diálogo muestra M001, NET 5.070
  kg, efecto y cancelación dominante.
- **Accesibilidad básica:** `role=dialog`, `aria-modal`, foco inicial en
  Cancelar, Escape cancela y F2 dentro del diálogo no confirma.
- **Validación humana:** no; pendiente de repetición por el usuario UAT.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| lector/balanza/TSC/papel reales | UAT local usa periféricos simulados | medio/alto | responsable del piloto |
| postura, distancia, EPP y ritmo | requieren observación en puesto | alto | responsable UX/operación |
| contingencias físicas completas | no ejecutadas en este corte | medio | UAT CON/IMP |
| suite integral completamente verde | seed portfolio falla sin líneas | bajo para K7, deuda workspace | equipo backend |

## Resultado

```yaml
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgo restante:** confirmar que el operador ya no intenta cerrar por
  omisión y comprende el diálogo sin ayuda.
- **Decisión humana pendiente:** aceptar/rechazar la interacción tras el run.
- **Observación productiva:** pendiente; no habilitada.
- **Siguiente acción segura:** ejecutar K7-01..07 con M001 reabierta y los dos
  QR disponibles.
