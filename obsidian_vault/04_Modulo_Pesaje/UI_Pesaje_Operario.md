---
tipo: modulo
estado: objetivo-en-refinamiento
tags: [pesaje, ui, operario]
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-07-23
---

# UI de Pesaje para Operario

Documenta la interfaz de usuario específica del módulo de pesaje en planta.

## Requerimientos de UX
- Pantalla simplificada para uso en planta (resistente a errores)
- Lectura automática de balanza con confirmación manual
- Visualización del acumulado de bultos pesados
- Comparación contextual: para salida simple, peso físico versus salida asignada; para producto armado, peso físico versus BOM esperada. Nunca una única resta contra “producción” para ambos casos.

## Flujo del Operario objetivo

1. Escanear la identidad de bolsa planificada por [[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]].
2. Resolver `qr_object_type=SCM_BAG` y derivar el modo UI `SALIDA_SIMPLE` o `PRODUCTO_ENSAMBLADO`; esta última puede ser planificada por [[US-010F_Prearmado_y_Armado_Concurrente_Trazable|US-010F]].
3. Ver OT/OP de contexto, lote, pieza o producto, color y asignación como datos de solo lectura.
4. Para salida simple, mostrar conteo asignado o pedir confirmación si falta; para producto armado, ver plan/provisional abierto, confirmar cantidad final/corte y diferencia. Nunca inferir unidades desde kg.
5. Colocar la bolsa en balanza y recibir peso bruto automáticamente.
6. Confirmar tara, neto y captura mediante F2 idempotente.
7. Para salida simple se encola `CONFIRMAR_PESAJE_BOLSA`; para producto armado se encola un único `CONFIRMAR_BOLSA_ENSAMBLADA` con peso, cantidad y asignaciones preparadas.
8. Sin acuse, mostrar `CAPTURADA_PENDIENTE_SYNC`, imprimir una marca `NO DISPONIBLE` si hace falta y enviar la bolsa a staging de contingencia.
9. [[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]] materializa la unidad al sincronizar; el comando armado consume/acredita atómicamente o queda en conciliación.
10. Tras el acuse, imprimir o reintentar la etiqueta final sin repetir el pesaje.

El flujo legacy de escanear la OT y volver a escribir operador/color se conserva solo durante transición. El campo “descuento ajeno a la pieza” no modela un asa u otro componente: puede ajustar un número, pero pierde consumo, origen y genealogía. No forma parte del contrato SCM objetivo.
