---
tipo: user-story
estado: en-desarrollo
tags: [scm, pesaje, dashboard, gerencia, offline-first, atdd, tdd]
relaciones:
  - "[[US-011_Monitorear_Estaciones_de_Pesaje]]"
  - "[[US-011B_Importar_Historial_y_Consultar_OP_Legacy]]"
  - "[[US-011C_Continuidad_y_Operacion_Auditada_Pesajes_Piloto]]"
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[TS-TE-004_Despliegue_y_Comunicacion_Estacion_Pesaje]]"
fecha_creacion: 2026-07-17
---

# US-011A: Dashboard Gerencial Temporal de Avance por Pesajes

## 1. Historia

**Como** Gerencia o responsable de Produccion  
**Quiero** consultar en el sistema central los kilos pesados por OP durante una fecha operativa  
**Para** monitorear el avance de planta sin desplazarme a la balanza y sin confundir el reporte temporal con inventario SCM confirmado.

## 2. Decision funcional

Esta historia entrega una solución temporal de consulta sobre los pesajes del módulo local existente. US-011C amplía el piloto con continuidad y operaciones auditadas desde `Todas las OP`; el dashboard de avance permanece como read model y no suplanta los eventos trazables de US-010.

El heartbeat continua informando salud de la estacion. El avance usa un contrato independiente porque un total diario sin dimensiones mezcla OP, OT, moldes o turnos distintos.

La estacion emite un snapshot movil de 31 dias agrupado por:

- fecha operativa de captura;
- OP;
- OT;
- molde;
- color;
- maquina;
- turno.

Cada snapshot reemplaza completamente la ventana anterior de esa estacion. Una retransmision exacta es idempotente y una eliminacion o correccion local aplicada puede retirar o recalcular un grupo sin sumar kilos dos veces.

## 3. Autoridad del dato

| Dato | Autoridad en esta historia |
|---|---|
| Peso y numero de bolsas | Estacion local, fuente `LOCAL_REPORTED_LEGACY`. |
| Meta de produccion | `OrdenProduccion.calculo_peso_produccion` en central. |
| Porcentaje | Central, solo cuando encuentra exactamente la OP y la meta es mayor que cero. |
| Estado de comunicacion | Ultimo heartbeat recibido por central. |
| Inventario, salida y lote | No se modifican en esta historia. |

Los kilos son un indicador operativo. No crean `ControlPeso`, Kardex, consumo, lote de salida ni unidad logistica.

## 4. Alcance

Incluye:

- reporte saliente desde la estacion sin bloquear captura ni impresion;
- recepcion central autenticada por identidad tecnica de estacion;
- persistencia idempotente del ultimo snapshot por ventana;
- consulta por fecha operativa;
- total de kilos, bolsas, OP y estaciones reportantes;
- avance por OP y detalle por OT/molde/color/maquina/turno;
- fecha de ultima captura y recencia de la estacion;
- filtros de fecha, OP, maquina y turno;
- estados de carga, vacio, error y datos atrasados;
- actualización automática de la consulta.

No incluye:

- control remoto de balanza o impresora;
- edición libre o aprobación de pesajes desde el dashboard de avance; el soft delete auditado pertenece a US-011C;
- autenticacion humana final;
- conciliacion contra unidades logisticas;
- OEE, piezas buenas, rechazo, merma real o eficiencia de maquina;
- convertir el peso legacy en existencia central.

## 5. Invariantes

1. Dos OP pesadas el mismo dia nunca comparten un total de avance.
2. Repetir el mismo `report_id` y payload no duplica filas ni kilos.
3. Reusar un `report_id` con otro payload produce conflicto y no altera el snapshot vigente.
4. Todas las filas deben estar dentro de la ventana declarada y cada combinacion dimensional debe ser unica.
5. El reemplazo de la ventana es transaccional: se aplica completa o no se aplica.
6. Un snapshot vacio elimina los grupos previos de esa estacion dentro de la ventana.
7. Una OP ausente o con meta cero se muestra como `SIN_META`; su porcentaje es `null`.
8. La caida central nunca impide pesar, imprimir ni consultar el historial local.
9. La pantalla declara siempre la fuente legacy y la hora de actualizacion.
10. Ninguna ruta de esta historia escribe en `ControlPeso` ni en inventario.

## 6. Ejemplo reproducible

El 17/07/2026 la estacion principal reporta:

| OP | OT | Maquina | Bolsas | Peso |
|---|---|---|---:|---:|
| OP-1401 | OT-0041 | HT-250B | 2 | 50.250 kg |
| OP-1402 | OT-0042 | SOP-01 | 1 | 24.900 kg |

En central, OP-1401 tiene meta de 100.000 kg y OP-1402 no tiene una meta valida. El dashboard muestra 75.150 kg y 3 bolsas. OP-1401 muestra 50.3%; OP-1402 muestra `Sin meta`, nunca 0%.

## 7. Escenarios ATDD

### US-011A-01: Dos OP del mismo dia permanecen separadas

**Dado** que OP-1401 tiene dos bolsas y OP-1402 una bolsa  
**Cuando** la estacion reporta el snapshot del 17/07/2026  
**Entonces** central devuelve dos avances independientes y un total general de 75.150 kg.

### US-011A-02: Replay exacto

**Dado** un snapshot aceptado  
**Cuando** la estacion reenvia el mismo `report_id` con el mismo payload  
**Entonces** recibe el mismo acuse y el total permanece 75.150 kg.

### US-011A-03: Recalculo local

**Dado** que una bolsa activa de OP-1401 deja de formar parte del conjunto local vigente  
**Cuando** la estacion recalcula y envia un nuevo snapshot  
**Entonces** central reemplaza la ventana y ya no conserva el peso retirado.

### US-011A-04: Central no disponible

**Dado** que la API central no responde  
**Cuando** el operador registra e imprime un pesaje  
**Entonces** la operacion local termina normalmente y el worker reintenta el reporte con backoff.

### US-011A-05: OP sin meta confiable

**Dado** un grupo cuyo numero de OP no existe o cuya meta es cero  
**Cuando** Gerencia consulta el dashboard  
**Entonces** ve kilos y bolsas, estado `SIN_META` y porcentaje nulo.

### US-011A-06: Datos atrasados

**Dado** un snapshot productivo existente y un heartbeat fuera del umbral de recencia  
**Cuando** Gerencia abre el dashboard  
**Entonces** conserva el ultimo avance con una advertencia de antiguedad; no afirma que la estacion esta apagada.

### US-011A-07: Sin efectos SCM

**Dado** cualquier snapshot valido, replay o reemplazo  
**Cuando** central lo procesa  
**Entonces** el numero de `ControlPeso` y movimientos de inventario permanece intacto.

## 8. Contratos y vistas

- `PUT /api/integration/v1/stations/{station_id}/production-progress`
- `GET /api/monitoring/v1/production-progress?date=AAAA-MM-DD`
- ruta frontend `/pesaje/avance`
- contrato `station-production-progress-v1`

La consulta gerencial agrega por OP y entrega el detalle dimensional sin duplicar la meta de la OP en el total general.

## 9. Estrategia TDD

1. Contrato y copias proveedor/consumidor.
2. Agregador local con dos OP, precision decimal y soft delete.
3. Recepcion central, replay, conflicto y reemplazo atomico.
4. Read model con meta valida, OP inexistente y meta cero.
5. Cliente/worker con central disponible e indisponible.
6. Componente React con carga, filtros, vacio, error y recencia.
7. E2E aislado que confirma `ControlPeso = 0`.

## 10. Definicion de terminado

- escenarios US-011A-01 a US-011A-07 automatizados;
- schemas canonicos y copias byte a byte;
- migracion central acotada a las tablas de monitoreo;
- suites de backend central, estacion y frontend verdes;
- build frontend verde;
- QA visual en escritorio y movil sin solapamientos;
- fuente legacy y limitacion de inventario visibles en la pagina;
- guia SCM enlaza el dashboard;
- evidencia RED, GREEN y REFACTOR registrada en TS-TE-004.

## 11. Deuda deliberada

El pesaje normalizado de US-010 reemplazara este snapshot agregado por eventos globalmente identificados y asociados a lote de salida y unidad logistica. El dashboard podra conservar su experiencia de consulta, pero debera preferir la fuente normalizada cuando exista y evitar sumar ambas fuentes.
