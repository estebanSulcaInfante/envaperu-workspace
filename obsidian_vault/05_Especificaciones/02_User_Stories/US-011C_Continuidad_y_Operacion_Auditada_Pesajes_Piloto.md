---
tipo: user-story
estado: en-desarrollo
tags: [scm, pesaje, legacy, continuidad, soft-delete, orden-produccion, auditoria, offline-first, atdd, tdd]
relaciones:
  - "[[US-011_Monitorear_Estaciones_de_Pesaje]]"
  - "[[US-011A_Dashboard_Gerencial_Avance_Pesajes]]"
  - "[[US-011B_Importar_Historial_y_Consultar_OP_Legacy]]"
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[TS-TE-004_Despliegue_y_Comunicacion_Estacion_Pesaje]]"
fecha_creacion: 2026-07-18
fecha_actualizacion: 2026-07-23
---

# US-011C: Continuidad y Operación Auditada de Pesajes del Piloto

## 1. Historia

**Como** Gerencia o responsable de Producción  
**Quiero** consultar los pesajes históricos y nuevos como un único flujo y administrar sus OP desde central  
**Para** monitorear la producción sin una brecha temporal y aplicar anulaciones, cierres o reaperturas sin perder evidencia ni alterar inventario SCM.

## 2. Decisión funcional

La fotografía importada por US-011B es la semilla del historial de la estación. Después de ella, cada pesaje nuevo se publica incrementalmente y aparece en las mismas vistas `/pesaje/avance` y `/pesaje/ordenes`. No existe una sección histórica separada de otra sección actual.

El piloto deja de ser exclusivamente de consulta. Central puede registrar tres **comandos de datos**:

- `VOID_CAPTURE`: soft delete de un pesaje individual;
- `CLOSE_OP`: cierre de una referencia OP legacy;
- `REOPEN_OP`: reapertura de una referencia OP legacy.

Estos comandos no controlan balanza, puerto serial, Socket.IO, impresora ni proceso Windows. La estación los obtiene mediante polling saliente, los aplica en su SQLite y devuelve un acuse. Si está desconectada, permanecen pendientes.

La autenticación humana final sigue diferida. Durante el piloto cada acción exige `requested_by` y `reason` escritos explícitamente. Es una identificación operativa provisional, no sustituye login, firma ni RBAC.

## 3. Autoridad y límites

| Dato o acción | Autoridad del piloto |
|---|---|
| Peso, contexto y `legacy_pesaje_id` | SQLite de la estación. |
| Copia consultable y cursor | API central por `station_id`. |
| Soft delete | Estación; central conserva solicitud, estado y proyección. |
| Cierre/reapertura legacy | Estación; central conserva solicitud, estado y proyección. |
| Actor y motivo | Solicitud central auditada. |
| Inventario, Kardex, lote de salida y unidad logística | Fuera de esta historia; permanecen intactos. |
| Balanza e impresora | Solo estación local; sin comandos remotos. |

`CERRADA_LEGACY` significa cerrada para el flujo de pesaje piloto. No equivale por sí sola al cierre formal de una `OrdenProduccion` SCM vinculada.

## 4. Alcance

Incluye:

- cursor central por estación después de una importación completa;
- publicación incremental de filas con `legacy_id` mayor al cursor;
- replay idempotente mediante `batch_id` y hash de payload;
- snapshot vigente de cierres locales;
- una lectura unificada para historial y avance diario;
- soft delete individual, nunca borrado físico;
- cierre y reapertura de cualquier OP visible del piloto;
- actor y motivo obligatorios;
- estados `PENDING`, `DELIVERED`, `APPLIED` y `FAILED`;
- aplicación local idempotente y acuse a central;
- operación offline de captura e impresión;
- contrato `station-legacy-continuity-v1`.

No incluye:

- hard delete;
- editar peso, fecha, OP, OT, molde o color;
- activar el envío antiguo `POST /api/sync/pesajes`;
- crear `ControlPeso`, reservas, consumos, Kardex o unidades logísticas;
- control remoto de hardware;
- autenticación humana final ni matriz RBAC;
- resolver automáticamente alias como `OP-213` y `OP-0213`.

## 5. Invariantes

1. La importación completa y los deltas forman una sola secuencia por `station_id` y `legacy_pesaje_id`.
2. Un pesaje se cuenta una sola vez aunque también exista un snapshot agregado anterior.
3. Un `batch_id` repetido con el mismo contenido devuelve el mismo resultado; con otro contenido produce conflicto.
4. Una fila aceptada no se sobrescribe silenciosamente con contenido diferente.
5. `VOID_CAPTURE` conserva la fila y excluye su peso de cálculos activos.
6. Cerrar o reabrir una OP no elimina sus pesajes.
7. Todo comando conserva estación, objetivo, actor, motivo, solicitud, entrega, aplicación y error.
8. Un comando repetido es idempotente.
9. Central nunca abre una conexión entrante hacia la estación.
10. La caída de central no impide pesar ni imprimir.
11. Ninguna operación de esta historia escribe en `ControlPeso` ni inventario.
12. `remote_hardware_commands` permanece `false`; `pilot_data_commands` es una capacidad distinta.
13. Un `VOID_CAPTURE` aplicado después del umbral configurable desde el pesaje
    genera una alerta central; la fila original permanece visible y auditable.

## 6. Estados visibles

| Estado | Significado |
|---|---|
| `ABIERTA_PILOTO` | La referencia tiene pesajes y no posee cierre legacy vigente. |
| `CIERRE_PENDIENTE` | Central registró el cierre y espera acuse local. |
| `CERRADA_LEGACY` | La estación aplicó o ya contenía el cierre. |
| `REAPERTURA_PENDIENTE` | Central registró la reapertura y espera acuse local. |

El estado de mapeo (`MAPEADA` o `PENDIENTE_MAPEO`) es una dimensión independiente. Una OP puede estar abierta y pendiente de mapeo al mismo tiempo.

## 7. Escenarios ATDD

### US-011C-01: Continuidad sin brecha

**Dado** un import completo cuyo cursor máximo es `11699`  
**Y** la estación registra el pesaje `11700`  
**Cuando** ejecuta su siguiente ciclo de monitoreo  
**Entonces** central incorpora `11700` en la misma OP, historial y avance diario sin duplicar los registros importados.

### US-011C-02: Replay de delta

**Dado** un delta aceptado  
**Cuando** la estación repite el mismo `batch_id` y payload por pérdida del acuse  
**Entonces** central devuelve el mismo cursor y no duplica kilos ni bolsas.

### US-011C-03: Soft delete auditado

**Dado** un pesaje activo visible en el detalle de una OP  
**Cuando** un responsable solicita anularlo con actor y motivo  
**Entonces** el comando queda pendiente, la estación aplica `deleted_at`, central recibe el acuse y el pesaje continúa visible como `Anulado` sin sumar al avance.

### US-011C-04: Cierre con estación desconectada

**Dado** una OP `ABIERTA_PILOTO` y la estación sin comunicación  
**Cuando** central registra `CLOSE_OP`  
**Entonces** la OP muestra `CIERRE_PENDIENTE` y el comando se conserva hasta que la estación vuelva a consultar.

### US-011C-05: Reapertura

**Dado** una OP `CERRADA_LEGACY`  
**Cuando** el responsable solicita reapertura con motivo  
**Entonces** la estación elimina únicamente el cierre local, conserva todos los pesajes y central vuelve a mostrar `ABIERTA_PILOTO` tras el acuse.

### US-011C-06: Sin actor o motivo

**Dado** cualquier acción mutante  
**Cuando** falta `requested_by` o `reason`  
**Entonces** central rechaza la solicitud y no crea ningún comando.

### US-011C-07: Sin efectos SCM

**Dado** deltas, anulaciones, cierres y reaperturas aplicados  
**Cuando** termina el ciclo  
**Entonces** `ControlPeso`, Kardex, reservas, consumos, lotes y unidades logísticas no cambian.

### US-011C-08: Sin control de hardware

**Dado** un usuario del dashboard central  
**Cuando** opera el piloto  
**Entonces** solo puede administrar datos legacy y no encuentra acciones para conectar balanza, leer COM, imprimir o detener la estación.

## 8. Experiencia frontend

`/pesaje/avance` agrega la fuente detallada importada e incremental para la fecha solicitada. Un snapshot agregado solo actúa como respaldo cuando una estación todavía no posee capturas detalladas para esa fecha, evitando doble conteo.

`/pesaje/ordenes` permite:

- consultar todas las OP históricas y actuales;
- distinguir estado operativo y estado de mapeo;
- cerrar o reabrir una OP;
- abrir el detalle y anular un pesaje activo;
- ingresar responsable y motivo en un diálogo de confirmación;
- ver acciones pendientes y pesajes anulados.

## 9. Estrategia TDD

1. Contrato canónico, ejemplos y copias proveedor/consumidor.
2. Cursor, delta y replay en central.
3. Publicador incremental local.
4. Comandos locales idempotentes y acuses.
5. Read model unificado sin doble conteo.
6. API de comandos con actor y motivo obligatorios.
7. Componentes React para soft delete, cierre y reapertura.
8. E2E con desconexión y verificación `ControlPeso = 0`.

## 10. Despliegue

El orden obligatorio es:

1. desplegar API central y crear las tablas nuevas;
2. desplegar el frontend central;
3. actualizar la estación física;
4. verificar capabilities y un ciclo sin comandos;
5. ensayar un cierre/reapertura controlado antes del primer soft delete real.

No se debe actualizar primero la estación: requiere que central anuncie `station-legacy-continuity-v1` y `pilot_data_commands=true`.

## 11. Definición de terminado

- escenarios US-011C-01 a US-011C-08 automatizados;
- contratos y copias idénticos;
- migración central idempotente;
- historial y avance integran filas importadas y nuevas;
- soft delete, cierre y reapertura conservan auditoría;
- UI responsive y accesible;
- suites de central, estación y frontend verdes;
- build frontend verde;
- evidencia de `ControlPeso = 0`;
- runbook de despliegue actualizado.

## 12. Deuda deliberada

[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]] reemplazará esta continuidad basada en IDs locales por eventos globales asociados a `LoteSalidaPiezaColor` y unidad logística. La autenticación final reemplazará el actor escrito manualmente por la identidad de sesión, sin perder el historial generado durante el piloto.
