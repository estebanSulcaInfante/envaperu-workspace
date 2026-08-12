---
tipo: modulo
estado: placeholder
tags: [pesaje, balanza, hardware, integracion]
fecha_creacion: 2026-04-21
---

# Integración con Balanza

Documenta la interfaz entre el sistema y las balanzas físicas de planta.

## Hardware común
- **Protocolo de comunicación:** Serial (RS-232), USB, o API de balanza
- **Formato de datos del peso:** Unidad, precisión decimal, frecuencia de lectura
- **Flujo de captura:** Cómo viaja la lectura estable desde la balanza hacia el adaptador de captura
- **Manejo de errores:** Timeouts, lecturas inválidas, calibración

## Flujo legacy vigente

- Los pesos del piloto se registran en [[Control_Peso]].
- Su suma se compara con [[Registro_Diario]], pero representa kg físicos reportados y puede incluir componentes previos; no demuestra producción exclusiva de la máquina.

## Flujo SCM objetivo

- La lectura pertenece a una [[Unidad_Logistica]] identificada y conserva bruto, tara y neto.
- Una salida simple se confirma mediante US-010D-core.
- Una bolsa armada usa `CONFIRMAR_BOLSA_ENSAMBLADA`; la misma lectura física no permite aislar el peso real del cuerpo y del asa.
- El peso físico se compara con el peso esperado por BOM para obtener residual, mientras ciclos/unidades/kg estándar de la OT se muestran por separado.
- `ControlPeso` y `total_kg_real` permanecen como compatibilidad legacy, no como destino obligatorio de todo pesaje nuevo.

> **TODO:** Completar protocolo, estabilidad, tara, calibración y pruebas con el hardware real antes de aprobar US-010D.
