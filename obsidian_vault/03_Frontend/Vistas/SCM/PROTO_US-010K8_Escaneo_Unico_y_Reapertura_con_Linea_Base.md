---
tipo: prototipo_operativo
estado: implementado-en-uat-local
historia: "[[US-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]]"
ux_risk: high
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha_creacion: 2026-09-03
fecha_actualizacion: 2026-09-04
---

# PROTO US-010K8

## Wireflow de estación

```mermaid
flowchart TD
  A[Escanear QR] --> B[Contexto kg visible · intención armada]
  B -->|F2 Control| C[Control aceptado]
  B -->|Cerrar + confirmar| D[Final aceptado]
  C --> E[QR consumido · F2 bloqueado]
  D --> E
  E -->|Escanear QR de B| F[Nueva identidad armada]
  E -->|Reescanear QR de A abierta| B
```

```text
MANGA OF000001-OT002-M001     ABIERTA
EMBUDO #4 · ANARANJADO SÓLIDO
Peso fabricado teórico       7.440 kg
Último NET aceptado          4.790 kg
NET actual                   4.970 kg
Diferencia                   0.180 kg

[ PESAR MANGA (F2) ]

ÉXITO · 4.970 kg registrados
F2 BLOQUEADO
Retire la manga y escanee el QR del siguiente pesaje.
```

## Wireflow de reapertura

```mermaid
flowchart TD
  A[Final vigente sin recepción] --> B{Tipo explícito}
  B -->|CIERRE_ACCIDENTAL| C[Historia sí · línea base no]
  B -->|CONTINUAR_LLENADO| D[Historia sí · línea base = NET final]
  C --> E[Misma manga/QR en llenado]
  D --> E
```

La selección administrativa muestra antes de confirmar el NET final, la
invalidación de la postetiqueta y si ese NET será referencia del siguiente
pesaje. La validación representativa sigue pendiente.
