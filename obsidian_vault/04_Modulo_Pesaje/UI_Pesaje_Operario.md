---
tipo: modulo
estado: implementado-local-pendiente-uat-k8
tags: [pesaje, ui, operario]
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-09-04
---

# UI de Pesaje para Operario

Documenta la interfaz de Producción/Pesaje SCM comprobada en el código local.
No acredita la versión desplegada ni aceptación en planta. Guion vigente:
[[UAT_US-010K_Modulo_Pesaje_Piloto_Kg]].

## Recorrido vigente — K3/K4/K7/K8

1. Escanear la preetiqueta y Enter: solo consulta; no crea un pesaje.
2. Central resuelve manga, pieza/color, OT/Trabajo, maquinista, tara congelada,
   capacidades y motivos de bloqueo. El QR compacto referencia `label_id`.
3. Revisar `MANGA SELECCIONADA`, estado y contexto; seleccionada no significa
   habilitada. No cambiar de manga silenciosamente ni conservar la anterior
   tras rechazar un QR.
4. Leer bruto de balanza, tara y NET. El backend de estación captura la lectura
   válida; el número visual del navegador no es la fuente autoritativa.
5. Usar un único botón `Pesar manga (F2)`. El modo seguro predeterminado es
   `CONTROL DE PESO`: registra `AVANCE_KG` sin conteo, no pausa Trabajo, no
   cambia persona/OT/tramo, no cierra ni crea inventario.
6. Para cerrar, marcar `Cerrar manga en este pesaje`, pulsar F2 y confirmar en
   el diálogo. La estación de Fabricación simple ya no pide unidades reales ni
   ofrece cierre parcial; el cierre copia el plan en UN únicamente como dato
   teórico de compatibilidad, no como conteo observado.
7. Cada resolución de QR habilita como máximo un control o un cierre exitoso.
   Después del acuse, F2 y el selector quedan bloqueados hasta volver a escanear,
   incluso si se continuará pesando la misma manga. El foco vuelve al lector.
8. Almacén recibe posteriormente; ni el escaneo, ni pesar, ni imprimir crean
   por sí solos una existencia disponible.

## Jerarquía, estados y recuperación

Primarios objetivo: identidad/estado, NET y efecto del botón. Secundarios:
plan, OF/corrida e imagen opcional. La implementación aún destaca más el bruto
que el NET; requiere observación PES-01, no aceptación inferida.

| Estado | Respuesta operativa |
|---|---|
| Sin QR / consultando | Escanear / esperar, sin efecto de negocio. |
| Manga cerrada o anulada | Motivo textual; otra manga o revisión en Central. |
| Trabajo de OT sin iniciar | Central inicia el Trabajo; después reescanear. |
| Continuidad pendiente/no iniciada | Central revisa vínculo/inicio; no crear otra manga para eludir el bloqueo. |
| Lectura no válida / balanza desconectada | Corregir lectura/conexión; F2 bloqueado. |
| Listo | Explica control abierto o cierre; botón y F2 comparten habilitación. |
| Registrando | Esperar; no cambiar intención ni duplicar envío. |
| Confirmado | Distinguir registro de impresión; retirar la unidad y reescanear antes de otro pesaje. |
| Error / respuesta incierta | Recuperar la misma operación o reconsultar sin asumir éxito; no consumir el escaneo si Central rechazó. |
| Central desconectada | Bloqueo seguro. No hay captura offline autorizada para este flujo. |

El último NET persiste en Central y vuelve al reescanear. Puede provenir del
último `AVANCE_KG` o de un cierre reabierto explícitamente para
`CONTINUAR_LLENADO`. Se exige crecimiento tanto en control como en final. Una
reapertura `CIERRE_ACCIDENTAL` conserva el cierre en historial, pero no lo usa
como línea base porque su lectura fue declarada no confiable.

## Límites y aceptación

- Relevo y continuidad históricos K1/K2 conservan identidad pero requieren
  fronteras en UN. La estación K3/K4 no ejecuta ese corte histórico como control.
- La identidad del maquinista resuelta desde Central no prueba quién está
  físicamente delante del puesto compartido; observar LEC-07.
- Inventario de piezas/WIP en kg y retorno repesado siguen pendientes; no
  confundirlos con el sublibro vigente en UN. La conciliación detallada de Armado
  queda [[Conciliacion_Consumo_Armado_en_Kg_Pendiente|diferida]].
- UX provisional, UAT física pendiente, `no_habilitar_en_planta`.

Fuentes: [[TS-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]],
[[TS-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]],
[[TS-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]],
[[TS-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]],
[[PROTO_US-010K8_Escaneo_Unico_y_Reapertura_con_Linea_Base]], [[Etiqueta_Manga]].

## Referencia histórica — objetivo de julio, no guion ejecutable

Lo siguiente se conserva como antecedente. `SCM_BAG`, conteos digitados y
`CAPTURADA_PENDIENTE_SYNC` no describen el flujo conectado K3/K4 ni autorizan
operación offline. Para ejecutar usar exclusivamente el recorrido vigente anterior.

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
