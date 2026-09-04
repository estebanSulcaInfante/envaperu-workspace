---
tipo: recibo_ejecucion
estado: cerrado_pendiente_uat_fisica
fecha: 2026-09-01
tags: [scm, pesaje, preetiqueta, postpesaje, tspl, continuidad, wip]
---

# REC-2026-09-01: Stickers TSPL v5 y peso fabricado atribuible

## Objetivo y alcance

- **Historia / DEV:** `TS-010C`, `TS-010K2` / `DEV-010C1`, `DEV-010K2`.
- **Porción vertical ejecutada:** ampliar la preetiqueta con OP opcional, tipo,
  separador y kg teóricos; reorganizar POSTPESAJE para priorizar fecha/hora,
  maquinista y peso fabricado teórico; conservar continuidad multijornada.
- **Fuera de alcance respetado:** inferencia autoritativa de unidades desde kg,
  despliegue, impresión real, aprobación de planta y modificación física de una
  manga existente.
- **Branch / worktree / commit:** worktree existente y sucio con cambios previos
  del usuario; incremento sin commit.
- **Gate de entrada:** solicitud explícita y referencia visual del usuario.
- **Gate solicitado:** `qa_green`, con UAT física posterior.

## Cambios

| Archivo o componente | Motivo | Tipo |
|---|---|---|
| Payload PREPESAJE Central | Publicar `PREPESAJE_TSPL_5`, OP inequívoca y `kg_teoricos`. | Producto |
| Payload POSTPESAJE Central | Publicar OT/maquinista del tramo de cierre y peso fabricado atribuible. | Producto |
| Renderer TSPL/SVG de estación | Nueva jerarquía, separadores y ubicación de campos. | Producto |
| Demo segura de estación | Mantener la demostración alineada con v5. | Producto |
| Pruebas Central/estación | Cubrir OP presente/ausente, WIP concurrente y compatibilidad. | Prueba |
| Tech Specs y UAT | Registrar semántica y restricciones vigentes. | Documento |

## Verificaciones ejecutadas

| Comando / revisión | Resultado | Evidencia | Interpretación |
|---|---|---|---|
| Baseline estación | `144 passed` | Suite antes del incremento. | Base verde. |
| RED enfocado estación | `7 failed` | Contrato/diseño anterior detectado. | Pruebas sensibles al cambio. |
| GREEN renderer enfocado | `21 passed` | PRE/POST, OP opcional y omisión segura. | Composición v5 cubierta. |
| Regresión estación | `146 passed` | Suite completa de Pesaje. | Sin regresión detectada. |
| Central OT + armado concurrente | `50 passed` | Servicios canónicos y caso WIP. | Payload y atribución de peso verdes. |
| Contratos Central–estación | `3 passed` | Proveedor `1`, consumidor `2`. | Contrato legacy-v1 intacto. |
| Medición geométrica del SVG | Sin desbordes en campos de muestra. | Artefactos `outputs/*tspl5_revision.*`. | Ejemplo sintético cabe en 400 dots. |
| Auditoría código–Vault de cantidad | Coincidencia funcional con ambigüedad terminológica corregida. | Estación envía solo kg en cierre normal; Central copia `cantidad_asignada_un`. | `CONTEO FINAL` no describe evidencia física en fabricación normal. |
| Renderer por fuente de cantidad | `22 passed` enfocados y `147 passed` en estación. | Payload Central publica `fuente_cantidad`; SVG/TSPL actualizado. | Normal muestra `CONTEO TEÓRICO`; Armado/parcial/corrección, `CONTEO CONFIRMADO`. |
| Auditoría continuidad cambio de OT | Brecha de extremo a extremo confirmada. | Backend reutiliza manga/QR; estación K3 solo envía `AVANCE_KG`. | Falta un corte multijornada sin conteo que no invente unidades por tramo. |

## Evidencia UX y operativa

- **Dispositivo / viewport:** TSC TE200, 203 DPI, hoja `109 × 50 mm`, dos
  copias de 400 dots.
- **Estados capturados:** PREPESAJE v5 y POSTPESAJE v5 sintéticos en SVG/TSPL.
- **Comparación con referencia:** mantiene manga dominante; agrupa identidad
  antes del separador y sube contexto operativo/peso fabricado en el cierre.
- **Accesibilidad básica:** jerarquía y geometría verificadas por código; nombres
  extremos y papel físico siguen pendientes.
- **Validación humana realizada:** referencia y ajustes provistos por el usuario;
  no hubo observación con trabajador ni impresión en hardware.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Impresión TSC y lectura pegada | No se autorizó emisión física. | Variación de firmware, fuente y curvatura. | UAT de estación. |
| Conteo teórico derivado del peso real | Falta regla aprobada de redondeo/tolerancia y no puede acreditar unidades. | Confundir estimación con conteo exacto o inventario. | Responsable funcional + Ingeniería SCM. |
| Nombres máximos reales | Falta muestra física representativa. | Desborde o pérdida de lectura. | Supervisor + trabajador UAT. |
| Despliegue | No solicitado. | Piloto activo aún no consume v5. | Responsable de liberación. |

## Resultado

```yaml
spec_phase: approved
delivery_state: ci_green
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** legibilidad física, campos largos, comprensión de la
  diferencia entre neto físico y peso fabricado teórico, y continuidad de una
  manga entre OT cuando la frontera solo se conoce en kg.
- **Decisión humana pendiente:** definir si además se muestra `CONTEO ESTIMADO
  POR PESO ≈` y diseñar el corte multijornada sin atribuir unidades ficticias
  a cada tramo.
- **Observación productiva / marcha blanca:** pendiente.
- **Siguiente acción segura:** revisar los SVG y luego ejecutar UAT física en la
  estación piloto antes de desplegar o habilitar la plantilla.
