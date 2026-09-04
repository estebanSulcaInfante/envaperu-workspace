---
tipo: recibo-ejecucion-agentica
estado: cerrado-con-uat-pendiente
tags: [scm, pesaje, kg, qr, reapertura, uat]
fecha: 2026-09-04
---

# REC-2026-09-04: Recibo de ejecución — escaneo único y reapertura con línea base

## Objetivo y alcance

- **Historia / DEV:** [[US-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]] / [[DEV-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]].
- **Porción vertical ejecutada:** un QR habilita un solo pesaje; contexto de Fabricación en kg; reapertura accidental o para continuar llenado sin borrar el final histórico.
- **Fuera de alcance respetado:** tolerancia operativa de 90 g, Kardex integral en kg, retorno/merma de Armado y despliegue productivo.
- **Branch / worktree / commit:** workspace raíz `main`; submódulos de trabajo existentes; sin commit solicitado. Se preservó el worktree previamente modificado.
- **Gate de entrada:** aprobación explícita del responsable para implementar mediante pipeline.
- **Gate solicitado:** revisión y UAT local; no habilitación en planta.

## Cambios

| Archivo o componente | Motivo | Tipo |
|---|---|---|
| Central: modelo, migración `f93d4e6a8c02` y servicio de pesaje | Conservar el final como `REABIERTO`; línea base solo para `CONTINUAR_LLENADO`; monotonicidad por última referencia causal | Producto / datos |
| Central: diálogo de mangas | Exigir tipo y motivo, explicar el efecto y enviar `tipo_reapertura` | Producto |
| Estación: pesaje SCM | Consumir la intención tras un éxito, exigir reescaneo y priorizar NET/último NET/diferencia en kg | Producto |
| Pruebas Central, backend y estación | Cubrir ambos tipos, constraints, incremento, reescaneo y ausencia de conteo real | Prueba |
| Vault K8 y UAT | Registrar contrato, decisión, diseño operativo, gates y ejecución física pendiente | Documento |

## Verificaciones ejecutadas

| Comando / revisión | Resultado | Evidencia | Interpretación |
|---|---|---|---|
| Backend focal de servicio y migración | `44 passed` | pytest local | Semántica y constraints K8 verdes |
| Estación frontend completa | `76 passed` | Vitest local | Escaneo único y contexto kg sin regresión conocida |
| Central `OtMangasScm` | `43 passed` | Vitest local | Selector y payload de reapertura verdes |
| Build estación y Central | verdes | Vite local | Artefactos compilables; Central solo emitió advertencia de tamaño de chunk |
| Contratos Central–Pesaje | `3 passed` | `scripts/test-contracts.ps1` | Contratos compartidos compatibles |
| Backend estación completo | `147 passed` | pytest local | Adaptador/servicio de estación verde |
| Backend Central completo | `521 passed`, `2 skipped`, `29 deselected` | pytest de publicación | Regresión completa del perfil aplicable sin fallas |
| Migración UAT local | head `f93d4e6a8c02` | PostgreSQL local | Columnas/constraints aplicados; reaperturas previas migradas como accidentales sin base inferida |

## Evidencia UX y operativa

- **Dispositivo / viewport:** Chrome headless local, `1440 × 1200`; hardware físico pendiente.
- **Estados capturados:** listo kg-first y éxito consumido que exige reescaneo.
- **Comparación con wireflow:** coincide con [[PROTO_US-010K8_Escaneo_Unico_y_Reapertura_con_Linea_Base]].
- **Accesibilidad básica:** texto además de color; foco vuelve al lector; F2 y selector quedan deshabilitados tras éxito.
- **Validación humana realizada:** no; queda preparada en [[UAT_US-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]].

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Lector, balanza, impresora, papel, postura y EPP reales | Requiere ejecución física | Mezcla de mangas o baja legibilidad no observada | Responsable UAT + operador |
| Comprensión de los dos tipos de reapertura | Requiere Jefa de Producción | Selección equivocada del baseline | Responsable UAT |

## Resultado

```yaml
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** confusión física A/B y comprensión real de recuperación aún no observadas.
- **Decisión humana pendiente:** ejecutar y firmar UAT física; definir por separado cualquier tolerancia mínima en gramos.
- **Observación productiva / marcha blanca:** pendiente.
- **Siguiente acción segura:** actualizar la UAT local sin reset y recorrer K8-01..09 con las dos preetiquetas disponibles.
