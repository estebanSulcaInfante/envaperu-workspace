---
tipo: user-story
subtipo: historia-hija
estado: implementada-local-pendiente-uat
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, alertas, jefaturas, inconsistencias, auditoria, pesaje]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-011C_Continuidad_y_Operacion_Auditada_Pesajes_Piloto]]"
  - "[[US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
  - "[[Alerta_Operativa_SCM]]"
  - "[[2026-08-02_Alertas_Operativas_Configurable_para_Jefaturas]]"
fecha_creacion: 2026-08-02
fecha_actualizacion: 2026-08-11
---

# US-010J: Alertas Operativas e Inconsistencias

## Historia

**Como** jefe responsable de una etapa productiva  
**Quiero** consultar y gestionar alertas sobre hechos inusuales dentro de mi
alcance  
**Para** investigar atrasos o correcciones sensibles sin depender de revisar
manualmente todas las bolsas y pesajes.

## Reglas de negocio

1. Las reglas, umbrales, severidades y destinatarios son configurables.
2. Crear una alerta no cambia el evento origen ni inventario.
3. Una misma condición activa produce una sola alerta mediante huella
   idempotente.
4. Reconocer no equivale a resolver ni aprobar.
5. Resolver o descartar exige actor y motivo.
6. La visibilidad depende de capacidades y alcance, no de pantallas separadas
   hardcodeadas por nombre de rol.
7. Un pesaje o bolsa SCM nunca se elimina físicamente para resolver una alerta.

## Alertas iniciales

| Tipo | Referencias | Valor inicial |
|---|---|---|
| Pesaje tardío operativo | `OT.fecha_operativa -> pesada_at` | Más de 1 día calendario |
| Pesaje tardío desde preetiqueta | `preetiqueta.impresa_at -> pesada_at` | Más de 24 horas, configurable |
| Anulación/corrección tardía | `pesada_at -> anulada/corregida_at` | Más de 24 horas, configurable |
| Diferencia de custodia de merma | `peso_almacenado -> peso_pre_molino` | Diferencia absoluta mayor a 1.000 kg, configurable |

Las dos primeras no son equivalentes: una mide a qué jornada pertenece la
producción y la otra cuánto tiempo permaneció abierta la orden física entregada
al maquinista.

## Extensiones propuestas por US-013

| Tipo | Referencias | Valor inicial |
|---|---|---|
| Manga pesada sin recepción | `pesada_at -> recepción de almacén` | Más de 24 horas, configurable |
| Diferencia de transferencia | `despachadas -> recibidas` | Inmediata al confirmar faltante o sobrante |

Estas dos reglas pertenecen a TS-018 y todavía no forman parte del resultado
implementado de US-010J.

## Bandeja de jefatura

- conteo por severidad y antigüedad;
- filtros por etapa, OP, OF, OT, máquina, turno, actor y tipo;
- resumen comprensible y cronología;
- acceso al pesaje, manga y eventos relacionados;
- acciones `RECONOCER`, `ASIGNAR`, `RESOLVER` y `DESCARTAR` según capacidad;
- historial completo de acciones.

El canal inicial es solamente este panel interno del SCM. No se envían correos,
mensajes ni notificaciones externas.

## Criterios de aceptación

- **ALT-01:** pesar fuera del umbral crea una sola alerta aunque se reprocese el
  evento.
- **ALT-02:** pesar dentro del umbral no crea alerta.
- **ALT-03:** cambiar una regla conserva la evaluación histórica y aplica la
  nueva versión a hechos posteriores o a una reevaluación explícita.
- **ALT-04:** anular/compensar tardíamente conserva el pesaje original visible y
  crea una alerta con ambos actores y tiempos.
- **ALT-05:** reconocer una alerta no la elimina de pendientes de resolución.
- **ALT-06:** un jefe solo consulta alertas de su alcance, salvo capacidad
  transversal.
- **ALT-07:** un umbral puede cambiarse sin desplegar código.
- **ALT-08:** una manga pesada pendiente de recepción genera una sola alerta al
  superar 24 horas y no crea movimiento de Kardex.
- **ALT-09:** una diferencia de transferencia aparece en Control y Alertas con
  la misma identidad y referencias.

## Pendientes de refinamiento

1. Definir jefaturas destinatarias y alcance organizacional de cada tipo.
2. Definir severidades y tiempo esperado de resolución.
3. Ampliar el catálogo con inconsistencias de Kardex, molienda y armado.
