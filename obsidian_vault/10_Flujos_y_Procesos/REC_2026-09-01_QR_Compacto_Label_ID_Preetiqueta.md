---
tipo: recibo_ejecucion
estado: cerrado_pendiente_uat_fisica
fecha: 2026-09-01
tags: [scm, qr, preetiqueta, estacion-pesaje, evidencia]
---

# REC-2026-09-01: QR compacto por `label_id` en preetiqueta

## Objetivo y alcance

- **Historia / DEV:** `TS-010C` / `DEV-010C1`.
- **Porción vertical ejecutada:** Central anuncia el contrato compacto en
  etiquetas nuevas; la estación imprime el sobre `LABEL_REF_V1`, conserva el
  payload autoritativo completo y continúa leyendo formatos anteriores.
- **Fuera de alcance respetado:** despliegue, impresión real, pegado en manga,
  aprobación de operario, cambio a código de barras y migración de etiquetas ya
  generadas.
- **Branch / worktree / commit:** raíz `main@b61aec8`; Central
  `codex/portfolio-demo-pilot@c6e19fa`; estación
  `codex/portfolio-edge-demo@46e0a6f`. Worktrees con cambios previos del usuario;
  incremento sin commit.
- **Gate de entrada:** autorización explícita del usuario para actualizar el QR.
- **Gate solicitado:** `qa_green`; UAT física antes de habilitar el contrato en
  planta.

## Cambios

| Archivo o componente | Motivo | Tipo |
|---|---|---|
| Servicio OT Central | Añadir `template.qr_contract = LABEL_REF_V1` solo a etiquetas nuevas. | Producto |
| Servicio de preetiquetas estación | Serializar `{"label_id":"…","v":1}` cuando el marcador está presente y reservar zona silenciosa. | Producto |
| Lectura de pesaje estación | Comprobar que el sobre compacto sigue resolviendo por `label_id`. | Prueba |
| Pruebas Central/estación | Cubrir contrato nuevo, tamaño, TSPL y compatibilidad legacy. | Prueba |
| ADR, dominio, Tech Spec y UAT | Registrar autoridad, compatibilidad, dimensiones y gate físico. | Documento |

## Verificaciones ejecutadas

| Comando / revisión | Resultado | Evidencia | Interpretación |
|---|---|---|---|
| Baseline estación pesaje | `140 passed` | Suite previa al cambio. | Base funcional verde. |
| RED estación | `3 failed, 26 passed` | Falló contenido compacto, versión/tamaño y preview esperados. | Las pruebas detectaron el comportamiento anterior. |
| RED Central | `1 failed` por `qr_contract` ausente | Prueba enfocada OT. | Central aún no anunciaba el contrato. |
| Pruebas enfocadas estación | `30 passed` | Preetiquetas + lectura de pesaje. | Contrato compacto y compatibilidad verdes. |
| Regresión estación pesaje | `143 passed` | Suite completa del componente. | Sin regresión detectada. |
| Contratos Central–estación | `3 passed` | Proveedor `1`, consumidor `2`. | Integración contractual verde. |
| Servicio OT Central | `38 passed` | Suite completa del servicio, con warnings existentes de SQLAlchemy. | Generación Central verde. |
| Inspección estática del SVG real | QR `132 × 132 dots`; posiciones `(144,151)` y `(584,151)`; lienzo `872 × 400 dots`. | Salida generada por el servicio. | Conserva hoja 109 × 50 mm, dos copias y área compacta. |

## Evidencia UX y operativa

- **Dispositivo / viewport:** geometría objetivo TSC TE200, 203 DPI, papel
  `109 × 50 mm`, dos columnas de 50 mm.
- **Estados capturados:** no hubo captura; la política segura del navegador
  rechazó abrir el SVG en memoria.
- **Comparación con contrato:** símbolo compacto de 33 módulos, cuatro dots por
  módulo y reserva de cuatro módulos blancos; área aproximada `20.5 mm`.
- **Accesibilidad básica:** no aplica a la serialización; la legibilidad física
  del QR requiere lector real.
- **Validación humana realizada:** no.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Impresión TSC TE200 | No autorizada ni ejecutada en esta sesión. | Corte, escalado o zona silenciosa real insuficiente. | Responsable UAT de estación. |
| Lectura con etiqueta pegada | Requiere manga y lector autorizados. | Lectura degradada por curvatura, material o distancia. | Operario + observador UAT. |
| Lectura de QR legacy físico | No se imprimió muestra anterior. | Regresión práctica no observada pese a compatibilidad automatizada. | Responsable UAT de estación. |
| Despliegue Central/estación | No solicitado. | El piloto activo todavía no usa el contrato compacto. | Responsable de liberación. |

## Resultado

```yaml
spec_phase: approved
delivery_state: ci_green
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** comportamiento físico de impresora/lector y aceptación
  del tamaño por el trabajador.
- **Decisión humana pendiente:** aprobar márgenes y lectura de ambas copias
  pegadas; confirmar también una etiqueta legacy e invalidada.
- **Observación productiva / marcha blanca:** pendiente.
- **Siguiente acción segura:** ejecutar `IMP-01` a `IMP-04` con TSC TE200 y
  lector real; solo después autorizar despliegue o ampliación del piloto.
