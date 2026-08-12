---
tipo: decision-arquitectura
estado: aceptada-para-refinamiento
tags: [arquitectura, orden-trabajo, pesaje, impresion, offline, scm]
fecha_decision: 2026-07-23
relaciones:
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[Registro_Diario]]"
  - "[[TS-TE-004_Despliegue_y_Comunicacion_Estacion_Pesaje]]"
---

# Autoridad central de OT e impresión local

## Contexto

En el piloto, la estación de pesaje acepta un correlativo manual o consume un cache local y genera un sticker OT/RDP. Esa acción no crea la cabecera central. El endpoint legacy de sincronización intenta encontrar o crear después un `RegistroDiarioProduccion` mediante OP, máquina, fecha y turno.

La Hoja de Producción diaria, el Registro Diario de Producción y la Orden de Trabajo son el mismo concepto de negocio. Mantener una OT local sin identidad central y otra cabecera inferida durante la sincronización permite duplicación, fusión accidental y pérdida del correlativo impreso.

La impresora TSC y su acceso Windows RAW sí pertenecen físicamente a la estación de pesaje.

## Decisión

1. La API central crea y conserva la OT canónica.
2. `RegistroDiarioProduccion` evoluciona hacia `OrdenTrabajo`; no se crea una cabecera paralela.
3. Central asigna un identificador global y un correlativo legible dentro de la creación idempotente; la Tech Spec fijará UUID o ULID.
4. La estación solicita la creación, cachea la OT y ejecuta la impresión física.
5. Crear y imprimir son resultados separados. Una impresión fallida produce reimpresión de la misma OT.
6. El contrato SCM nunca infiere una OT por OP, máquina, fecha y turno al recibir un pesaje.
7. En el primer corte, crear una OT exige central disponible; una OT y bolsas ya descargadas pueden seguir operando offline.
8. La creación desconectada futura requerirá lease de correlativos con propiedad de estación y reconciliación; no admitirá correlativo manual libre.
9. La interfaz puede ejecutarse en la PC de pesaje sin cambiar estas autoridades.

## Consecuencias

- El endpoint central existente de Registro Diario puede evolucionar o mantenerse como adaptador compatible.
- `Talonario` deja de representar hojas preimpresas en el flujo nuevo; los valores legacy se preservan como referencia cuando corresponda.
- La estación mantiene drivers, plantillas TSPL, intentos de impresión y outbox.
- Central mantiene estado de OT, correlativo, permisos, snapshots y trazabilidad.
- La web central no obtiene acceso directo implícito a la impresora. Una futura impresión iniciada desde ella requerirá un agente local autenticado o una cola de trabajos recogida por la estación.

## Alternativas descartadas

### OT creada solo en la estación

Descartada porque obliga a reconciliar identidades posteriormente y permite que una OT sin pesajes nunca exista en central.

### Crear OT al recibir el primer pesaje

Descartada porque un pesaje no es autoridad para crear una hoja, y la coincidencia de campos no identifica inequívocamente una OT.

### Imprimir directamente desde el servidor central

Descartada para el piloto porque la impresora y sus drivers están en la PC de la estación y no deben exponerse en red.
