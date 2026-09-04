---
tipo: recibo_ejecucion
estado: qa-green-uat-ux-rejected
tags: [agentes, evidencia, scm, pesaje, manga, reapertura]
fecha: 2026-09-03
historia: "[[US-010K6_Reapertura_Auditada_de_Manga_por_Cierre_Accidental]]"
dev: "[[DEV-010K6_Reapertura_Auditada_de_Manga_por_Cierre_Accidental]]"
---

# REC-2026-09-03 — Reapertura auditada de manga por cierre accidental

## Objetivo y alcance

- **Historia / DEV:** US-010K6 / DEV-010K6.
- **Porción vertical:** JP/GG reabre desde Central un cierre normal accidental;
  misma manga/QR/cupo/controles, final histórico y nuevo cierre permitido.
- **Fuera de alcance:** Armado, cierre parcial, inventario exclusivamente kg,
  conciliación de retornos y despliegue productivo.
- **Branch / commit:** worktree compartido sucio; sin commit. Se preservaron
  cambios ajenos.
- **Gate de entrada:** regla PMI-15 y solicitud explícita del responsable
  funcional durante UAT.
- **Gate alcanzado:** implementación local y `functional_validation: qa_green`;
  aceptación UX/física pendiente.

## Cambios

| Componente | Motivo | Tipo |
|---|---|---|
| modelo/migración `ScmPesajeManga` y `ScmReaperturaManga` | Historial append-only y un único final vigente | producto/datos |
| servicio/API de Pesaje Central | Reabrir con permiso, versión, motivo, idempotencia y guardas de Almacén | producto |
| Almacén, alertas y observabilidad | Consumir el cierre vigente sin confundir históricos | producto |
| capacidad `MANGA_REABRIR` | Restringir a GG/JP | autorización |
| diálogo `Ver pesaje` | Reabrir antes de Corregir; Anular separado en rojo | producto/UX |
| pruebas K6 y migración | QR/cupo/controles, nuevo final, permisos, versión, alcance, recepción e idempotencia | prueba |
| US, TS, DEV, dominio, endpoint y UAT K6 | Trazabilidad y gates | documento |

## Verificaciones ejecutadas

| Comando / revisión | Resultado | Interpretación |
|---|---|---|
| RED inicial K6 | import/modelo de reapertura inexistente | brecha reproducida |
| focal K6 final | `3 passed` | camino feliz, alcance, autoridad, versión, recepción y migración verdes |
| regresión de anulación/corrección/recepción | `5 passed` | recuperación nueva no rompe compensaciones previas |
| `scripts/test.ps1 -Component backend` | `517 passed`, `1 skipped`, `1 failed` | único rojo preexistente `OPENING_LINES_REQUIRED` en Portfolio Demo |
| `scripts/test.ps1 -Component frontend` | 81 archivos, `511 passed` | regresión Central verde |
| focal UI posterior al ajuste visual | `1 passed`, 41 omitidos por filtro | jerarquía final verde |
| ESLint focal | cero errores; una advertencia preexistente de hook | sin error del incremento |
| build Central | verde | artefacto compilable; warning de chunk preexistente |
| `scripts/test.ps1 -Component pesaje` | `147 passed` | estación no rota |
| `scripts/test-contracts.ps1` | proveedor 1 + consumidor 2 | contrato Central–Pesaje verde |
| `scripts/test-sync-e2e.ps1` | pasó, `12.5 kg` reconocido | sincronización aislada verde |
| migración PostgreSQL UAT | `f91… -> f92…` aplicada | esquema/capacidad listos sin reset |
| actualización UAT final | Central, Pesaje y API LISTO | código final activo; documentos/saldos conservados |
| lectura API M001 posterior | v5, cierre VIGENTE, pendiente Almacén | fixture accidental preservado para UAT |
| ejecución humana de reapertura + lectura API | v6, `EN_LLENADO`, sin cierre vigente; cierre `REABIERTO`, postetiqueta `INVALIDADA` | K6-02 confirmado en estado/auditoría; continuidad física aún pendiente |
| reescaneo humano del QR original M001 | la estación resolvió la misma manga y la mostró abierta | K6-03 aprobado en UAT local; no se creó una identidad nueva |
| intento K6-04 y lectura API | Control no estaba marcado; F2 creó cierre final NET `4.970 kg`; M001 v8 volvió a pendiente de recepción | backend conforme; K6-04 interrumpido y UX rechazada por repetición del error operativo |

## Evidencia UX y operativa

- **Viewport:** Central desktop `1440 × 1450`, DPR 1, datos UAT reales.
- **Estado capturado:** diálogo M001 antes de reabrir; resumen, Reabrir,
  Corrección y Anulación visibles.
- **Jerarquía:** Reabrir es el primer bloque accionable, explica misma
  ID/QR/controles/cupo; Corregir queda secundario y Anular al final en rojo.
- **Accesibilidad básica:** campos etiquetados, motivo requerido, acciones con
  nombres distintos y copy textual además del color.
- **Validación humana:** la JP ejecutó la reapertura real de M001; aún no se ha
  aceptado el recorrido completo ni la continuidad posterior en Pesaje.
- **Evidencia:** `output/uat-k6-reapertura/02-dialogo-final-reapertura-m001.png`.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Rediseñar la intención de control frente a cierre final | dos omisiones de la casilla causaron cierres accidentales durante UAT guiada | cierre irreversible por omisión fácil | producto + UX + ingeniería |
| Repetir K6-04 después de recuperar el escenario | detenido hasta rediseñar y validar la intención de cierre | otro cierre accidental | responsable UAT + JP |
| Retiro físico del final y reescaneo del mismo QR | periféricos simulados | etiqueta equivocada | operador representativo |
| Lector, balanza e impresora reales | UAT local simulada | ergonomía/hardware | responsable UAT |
| PostgreSQL test harness automatizado | no se ejecutó Docker; migración sí corrió en PostgreSQL UAT | diferencias de entorno residuales | CI/release |
| Reparar Portfolio Demo | fallo anterior y fuera de alcance | suite global no totalmente verde | dueño del seed Portfolio |
| Despliegue productivo | no autorizado | impacto de planta | release controlado |

## Resultado

```yaml
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: rejected
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** selección/retiro de sticker equivocado, comprensión de
  Reabrir frente a Corregir/Anular y recuperación después de recepción.
- **Ejecución parcial registrada:** reapertura `c9c9a471-3cb9-42eb-adb9-d8c18ae86a15`,
  operación `3f8e6511-6280-4f55-bbe4-251e4c41f1b6`, actor `3`, motivo
  `Cierre accidental en UAT: se pulsó F2 sin marcar Control de peso`.
- **Hallazgo UAT:** después del reescaneo exitoso, F2 generó un nuevo cierre
  `c0937d59-9a3d-4362-8ad6-f2fc1ae1f823` de NET `4.970 kg` y la postetiqueta
  `e304d059-c8b1-4455-98a6-b35d57182e6f`; no se registró el control esperado.
  El usuario confirmó que no marcó **Control de peso**. Es comportamiento
  funcional esperado, pero la segunda omisión durante UAT rechaza la UX actual.
- **Decisión humana pendiente:** aceptar el recorrido completo con M001 después
  del reescaneo, nuevo control y nuevo cierre.
- **Marcha blanca:** pendiente; no habilitada.
- **Siguiente acción segura:** detener nuevas mutaciones, definir una protección
  explícita para el cierre final manteniendo una sola acción de pesaje y repetir
  K6-04 después del ajuste. No reabrir M001 otra vez solo para continuar la UAT
  con la misma interacción rechazada.
