---
tipo: prototipo_operativo
estado: aprobado-para-implementacion-local
historia: "[[US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
ux_risk: high
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha_creacion: 2026-09-03
tags: [pesaje, control, cierre, confirmacion, f2]
---

# PROTO US-010K7: control seguro y cierre deliberado

## Wireflow

```mermaid
flowchart TD
  A[QR resuelto] --> B[CONTROL por defecto]
  B -->|F2| C[Registrar AVANCE_KG]
  C --> D[Manga abierta y mismo QR]
  B -->|Marcar Cerrar manga| E[Modo CIERRE FINAL]
  E -->|F2| F[Diálogo: manga + NET + efecto]
  F -->|Cancelar o Escape| B
  F -->|F2 repetido| F
  F -->|Confirmar cierre| G[Cierre final idempotente]
```

## Estados principales

```text
┌──────────────────────────────────────────────────────┐
│ CONTROL DE PESO · LA MANGA CONTINUARÁ ABIERTA       │
│ Solo kg · no cambia OT, turno ni maquinista          │
│                                                      │
│ [ ] Cerrar manga en este pesaje                      │
│     Requiere confirmación antes de enviar            │
│                                                      │
│              [ PESAR MANGA (F2) ]                    │
└──────────────────────────────────────────────────────┘

┌──────────── CONFIRMAR CIERRE FINAL ─────────────────┐
│ OF000001-OT002-M001                                  │
│ NET 4.970 kg                                         │
│ No es un control. La manga quedará cerrada y se      │
│ generará el comprobante final.                       │
│                                                      │
│ [Cancelar; volver a Control] [Confirmar cierre]      │
└──────────────────────────────────────────────────────┘
```

El foco inicial del diálogo queda en Cancelar. Escape cancela. F2 dentro del
diálogo no confirma. El selector y los textos usan palabras además de color.
La confirmación debe caber en el viewport de UAT local; la aceptación desde el
puesto real continúa pendiente.
