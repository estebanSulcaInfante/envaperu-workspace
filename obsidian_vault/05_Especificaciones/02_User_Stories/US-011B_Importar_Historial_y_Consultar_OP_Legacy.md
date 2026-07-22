---
tipo: user-story
estado: en-desarrollo
tags: [scm, pesaje, legacy, importacion, calidad-datos, orden-produccion, gerencia, atdd, tdd]
relaciones:
  - "[[US-011A_Dashboard_Gerencial_Avance_Pesajes]]"
  - "[[US-011_Monitorear_Estaciones_de_Pesaje]]"
  - "[[US-011C_Continuidad_y_Operacion_Auditada_Pesajes_Piloto]]"
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[TS-TE-004_Despliegue_y_Comunicacion_Estacion_Pesaje]]"
fecha_creacion: 2026-07-18
---

# US-011B: Importar Historial y Consultar OP Legacy

## 1. Historia

**Como** Gerencia o responsable de Produccion  
**Quiero** conservar y consultar centralmente el historial completo de pesajes y OP de la estacion legacy  
**Para** revisar produccion vigente e historica sin perder eliminaciones, cierres ni valores originales y sin convertir esos registros en inventario SCM.

## 2. Decision funcional

La importacion historica conserva cada captura original y construye una lectura normalizada separada. No se modifica la SQLite fuente, no se reescriben valores crudos y no se insertan pesajes legacy en `ControlPeso`, Kardex ni unidades logisticas.

La curacion tiene dos niveles:

1. **Normalizacion segura:** trim, colapso de espacios y mayusculas para comparar textos.
2. **Resolucion de negocio:** vinculo manual o validado a una OP o entidad de catalogo. Una normalizacion textual nunca demuestra por si sola identidad de negocio.

Una OP con formato dudoso permanece `PENDIENTE_MAPEO`. No se completa con ceros automaticamente. En particular, `OP-213` y `OP-0213` se conservan separadas porque en la evidencia real corresponden a moldes, maquinas y OT diferentes.

## 3. Linea base real

La SQLite descargada el 2026-07-18 contiene:

| Indicador | Valor |
|---|---:|
| Filas totales | 11,676 |
| Filas activas para calculos | 11,449 |
| Soft deletes conservados | 227 |
| Rango de captura | 2026-03-02 a 2026-07-18 |
| Textos OP distintos | 157 |
| OP con cuatro digitos | 147 textos / 10,536 filas activas |
| OP con tres digitos | 10 textos / 913 filas activas |
| Colisiones al aplicar padding | 1: `OP-213` / `OP-0213` |
| OP cerradas localmente | 1: `OP-0069` |
| Pesajes de la OP cerrada | 158 / 1,125.600 kg |
| Colores crudos distintos | 64 |
| Colores tras normalizacion segura | 49 |

La lista legacy llamada "OP activas" significaba realmente "OP con pesajes que no aparecen en `op_cerradas`". Como solo se cerro una, no es evidencia de que las otras 156 sigan en produccion.

## 4. Autoridad del dato

| Dato | Autoridad |
|---|---|
| ID, peso, fecha y textos originales | SQLite legacy, preservados sin mutacion. |
| Soft delete original | SQLite legacy; excluye calculos, no auditoria. |
| Normalizacion mecanica | Importador versionado. |
| Correspondencia con OP central | Resolucion explicita; nunca padding automatico. |
| Cierre legacy | `op_cerradas`, importado como antecedente de visualizacion. |
| Estado de una OP central vinculada | `OrdenProduccion` central. |
| Inventario, lote y unidad logistica | Fuera de esta historia. |

## 5. Alcance

Incluye:

- lote de importacion identificado por estacion y SHA-256 de la fuente;
- carga idempotente por `(station_id, legacy_pesaje_id)`;
- las 11,676 filas, incluidas las 227 eliminadas logicamente;
- valor crudo y valor normalizado de OP, OT, molde, color, maquina y turno;
- estado `FORMATO_VALIDO`, `PENDIENTE_MAPEO`, `VINCULADA_CENTRAL` o `NO_ENCONTRADA` para referencias OP;
- preservacion de cierres legacy, motivo y fecha;
- listado paginado de todas las OP con busqueda y filtros;
- vistas `En curso`, `Cerradas`, `Historico` y `Por resolver`;
- detalle por OP con kilos, bolsas, rango, OT, molde, color, maquina y capturas;
- fuente y limitacion `LOCAL_REPORTED_LEGACY` visibles;
- publicacion por lotes desde la estacion sin bloquear pesaje o impresion.

No incluye:

- corregir automaticamente errores como `NARAMJA`, `TOJO` o `MRLON NORDICO`;
- decidir si `OP-213` debe convertirse en otro numero;
- crear piezas, PiezaColor, trabajadores o maquinas desde texto legacy;
- hard delete, edición libre o mutaciones sin actor y motivo;
- crear `ControlPeso`, inventario, lote de salida o movimientos SCM;
- sustituir los eventos normalizados previstos por US-010D.

## 6. Invariantes

1. Reimportar la misma fuente no duplica filas ni kilos.
2. Un `legacy_pesaje_id` con contenido diferente produce conflicto y no sobrescribe silenciosamente.
3. El valor crudo siempre permanece disponible aunque exista normalizacion o mapeo.
4. Las 227 filas eliminadas se conservan y nunca suman en indicadores activos.
5. `OP-213` y `OP-0213` permanecen separadas hasta una resolucion explicita.
6. Cerrar una OP la retira de `En curso`, pero no de `Historico` ni elimina capturas.
7. Ausencia de cierre no basta para declarar una OP en curso; se distingue `SIN_CIERRE_LEGACY` de `ACTIVA_CENTRAL`.
8. Ningun import, replay, cierre legacy o consulta escribe en tablas SCM de inventario.
9. Una importacion incompleta no queda disponible como fotografia vigente.
10. El dashboard diario de US-011A y el historial no suman dos veces la misma fuente.

## 7. Estados de OP en la vista

| Estado visible | Regla |
|---|---|
| `ACTIVA_CENTRAL` | Referencia vinculada a una `OrdenProduccion.activa=true`. |
| `CERRADA_CENTRAL` | Referencia vinculada a una `OrdenProduccion.activa=false`. |
| `CERRADA_LEGACY` | Existe cierre importado y no hay una autoridad central vinculada. |
| `PENDIENTE_MAPEO` | Formato dudoso, colision o resolucion manual pendiente. |
| `ABIERTA_PILOTO` | Tiene pesajes y no existe cierre legacy vigente; no afirma actividad SCM formal. |
| `CIERRE_PENDIENTE` | US-011C registró el cierre y espera acuse de la estación. |
| `REAPERTURA_PENDIENTE` | US-011C registró la reapertura y espera acuse de la estación. |

El estado de mapeo es independiente del estado operativo. Las operaciones auditadas del despliegue provisional se definen en US-011C.

## 8. Escenarios ATDD

### US-011B-01: Importacion completa y auditable

**Dado** el archivo real con 11,676 filas y SHA-256 conocido  
**Cuando** la estacion completa todos los lotes de importacion  
**Entonces** central conserva 11,676 filas, informa 11,449 activas y 227 eliminadas, y registra estacion, hash, conteos y fecha de importacion.

### US-011B-02: Replay idempotente

**Dado** un lote ya completado  
**Cuando** se reenvia el mismo manifiesto y los mismos fragmentos  
**Entonces** central reutiliza los acuses y ningun conteo cambia.

### US-011B-03: Conflicto de fila

**Dado** un ID legacy ya importado  
**Cuando** llega el mismo ID con peso, fecha o contenido diferente  
**Entonces** central responde conflicto y conserva la version aceptada.

### US-011B-04: Soft deletes

**Dado** 227 filas con `deleted_at`  
**Cuando** Gerencia consulta totales activos e historicos  
**Entonces** las filas aparecen en auditoria, pero no suman bolsas ni kilos activos.

### US-011B-05: OP con padding ambiguo

**Dado** `OP-213` y `OP-0213` con contextos productivos diferentes  
**Cuando** se normalizan las referencias  
**Entonces** se crean dos referencias crudas separadas y `OP-213` queda `PENDIENTE_MAPEO`; no se fusionan sus 95 capturas ni 903.000 kg.

### US-011B-06: Normalizacion segura de color

**Dado** `blanco`, `BLANCO` y `BLANCO `  
**Cuando** se importa el historial  
**Entonces** comparten la clave textual `BLANCO`, conservan sus valores crudos y no crean por si solas una PiezaColor.

### US-011B-07: Error que requiere curacion

**Dado** un color `NARAMJA`  
**Cuando** se importa  
**Entonces** el valor queda visible como pendiente; el sistema no lo cambia automaticamente a `ANARANJADO`.

### US-011B-08: Cierre legacy preservado

**Dado** `OP-0069` cerrada con motivo y fecha  
**Cuando** se consulta `En curso`  
**Entonces** no aparece en esa vista, pero `Historico` conserva sus 158 bolsas y 1,125.600 kg.

### US-011B-09: Todas las OP

**Dado** el lote historico completado  
**Cuando** Gerencia abre `/pesaje/ordenes`  
**Entonces** puede buscar y filtrar las 157 referencias crudas, revisar totales y abrir su detalle sin seleccionar primero una fecha.

### US-011B-10: Sin efectos SCM

**Dado** cualquier importacion, replay o consulta  
**Cuando** termina la operacion  
**Entonces** `ControlPeso`, Kardex, reservas, lotes y unidades logisticas permanecen sin cambios.

## 9. Experiencia frontend

La navegacion `Pesaje` incorpora:

- `Avance diario`: vista US-011A existente;
- `Todas las OP`: nueva ruta `/pesaje/ordenes`.

La nueva página usa tabla en escritorio y filas compactas en móvil. Muestra OP cruda, estado operativo, estado de mapeo, primera y última captura, kilos activos, bolsas activas, moldes, alertas y fuente. US-011C añade cierre, reapertura y soft delete individual con responsable y motivo; no habilita edición libre ni borrado físico.

## 10. Estrategia TDD

1. Modelos e importacion con lote vacio, replay y conflicto.
2. Normalizacion pura de OP y dimensiones textuales.
3. Soft delete y cierre legacy.
4. Read model paginado y detalle.
5. Publicador local por fragmentos con reintento.
6. Frontend con filtros, estados, vacio, error y detalle.
7. E2E aislado con una fotografia reducida y verificacion `ControlPeso = 0`.
8. Solo despues, importacion controlada de la SQLite real.

## 11. Definicion de terminado

- escenarios US-011B-01 a US-011B-10 automatizados;
- contratos versionados y copias proveedor/consumidor identicas;
- importacion idempotente y reanudable;
- consulta paginada y detalle disponibles;
- vista responsive con mutaciones limitadas, auditadas y sin hard delete;
- migracion central idempotente;
- suites y builds verdes;
- evidencia de no efectos SCM;
- runbook con backup, conteos, hash, conciliacion y rollback;
- carga real ejecutada solo con autorizacion explicita del dato operacional.

## 12. Decisiones pendientes que no bloquean desarrollo

1. Numero correcto para cada una de las diez OP de tres digitos.
2. Mapeo de errores y variantes de color al catalogo aprobado.
3. Roles definitivos para anular, cerrar o reabrir cuando se incorpore autenticación humana; durante el piloto se exige actor escrito y motivo.
4. Regla de retencion del detalle historico una vez que US-010D sea autoridad.

Estas decisiones no bloquean la preservacion, cuarentena, consulta ni pruebas del historial.
