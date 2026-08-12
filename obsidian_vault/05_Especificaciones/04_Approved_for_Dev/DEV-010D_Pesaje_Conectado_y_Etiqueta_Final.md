---
tipo: especificacion
subtipo: approved_for_dev
estado: en-desarrollo-local
tags: [scm, US-010D, pesaje, mangas, etiquetas, tspl]
fecha_aprobacion: 2026-07-28
fecha_actualizacion: 2026-07-28
---

# DEV-010D: Pesaje conectado de mangas y etiqueta final

## Referencias

- Historia: [[../02_User_Stories/US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]]
- Tech Spec: [[../03_Tech_Specs/TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final|TS-010D]]
- Predecesora: [[DEV-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje]]
- Ejecución UAT: [[../../10_Flujos_y_Procesos/UAT_TS-010C_D_OT_Mangas_Pesaje|Guía UAT TS-010C/D]]

## Autorización y restricciones

Desarrollo local continuado por autorización del usuario el 2026-07-28.

- No tocar la base desplegada.
- Preservar sin modificación los pesajes históricos del módulo autónomo.
- No reinterpretar pesajes legacy como mangas SCM.
- No crear Kardex ni ubicación al pesar.
- Mantener autoridad central e impedir F2 offline en el perfil SCM.
- Crear roles/capacidades sin asignarlos automáticamente a personas.

## Primer incremento

- Simulador SVG web 2-up basado en el mismo payload, dimensiones y coordenadas
  de `PREPESAJE_TSPL_1`.
- QR real visible en la simulación.
- Modelo y migración inicial de `scm_pesaje_manga`.
- Preparación del esquema para etiquetas `POSTPESAJE`.

## Segundo incremento

- Resolución central de QR y bloqueo de etiquetas invalidadas/no listas.
- Confirmación F2 idempotente con bruto, tara, neto, cantidad y fecha operativa.
- Trabajo e impresión local `POSTPESAJE_TSPL_1`.
- UI `Pesaje SCM` sin digitación de contexto, peso ni tara.
- Evidencia local de impresión ampliada con operación, captura, manga y tipo.
- Migración central `d94f1a7c3e20` probada en PostgreSQL y aplicada solamente
  a la base local `enva_test`.

## Tercer incremento

- QR de prepesaje y postpesaje alineado al sticker productivo existente:
  corrección `L`, módulo `4`, origen `X + 120` y preview `120 × 120 dots`.
- Corrección compensatoria con solicitud, cuatro ojos, aprobación JP y
  regeneración de etiqueta final.
- Consulta central del pesaje original, la proyección vigente y el historial
  de correcciones desde `OT y mangas`.
- Migración `e05a2c8d4f31` probada en PostgreSQL y aplicada solamente a
  `enva_test`.

Permanece como puerta del piloto la UAT con balanza, lector e impresora
físicos. El dashboard agregado en tiempo real se desarrolla en US-011A
consumiendo los hechos centrales de TS-010D.
