---
tipo: modulo
estado: placeholder
tags: [backend, servicios, logica-negocio]
fecha_creacion: 2026-04-21
---

# Backend — Servicios y Lógica de Negocio

> Este directorio documenta los servicios del backend que encapsulan la lógica de negocio.

## Servicios Clave
- **`actualizar_metricas()`** — Recalcula todos los campos `calculo_*` de [[Orden_Produccion]] y cascadea a [[Lote_Color]]
- **Validación de fracciones** — Asegura que `SUM(fraccion) == 1.0` en [[Composicion_Materiales]]
- **Prioridad de peso** — Lógica de fallback en [[Registro_Diario]]: pesajes reales > cálculo por coladas

> **TODO:** Documentar servicios conforme se desarrollen.
