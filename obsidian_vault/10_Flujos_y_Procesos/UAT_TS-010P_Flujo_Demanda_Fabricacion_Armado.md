---
estado: lista-para-ejecucion-local
fecha: 2026-07-29
alcance: LOCAL
base_datos: envaperu_test
revision_minima: f62e0b8d7c36
---

# UAT TS-010P — OP, OF, OA, OT, mangas y pesaje

## Objetivo

Validar desde la interfaz el flujo:

`ProductoTerminado → OP demanda → plan → OF/OA → OT → mangas → pesaje`

La prueba usa el Kardex normalizado local para saldo inicial y reservas. No
consume inventario, no recibe mangas y no toca una base desplegada.

## Actores locales

| Actor | Uso | Roles relevantes |
|---|---|---|
| 1 · TR-MIG-001 | creador, ingeniería y planificación | INGENIERIA_SCM, PLANIFICACION, JEFE_PRODUCCION |
| 2 · TR-UAT-APROBADOR | aprobación segregada | JEFE_PRODUCCION |
| 3 · TRB-000001 | aprobación de demanda | GERENCIA |

El actor 1 no puede aprobar una BOM/ruta creada por él. Para aprobar se debe
cambiar temporalmente el actor local a 2 y después volver a 1.
La OP de demanda se aprueba con el actor 3; `JEFE_PRODUCCION` no concede
`OP_APROBAR`.

## Baseline comprobado

Antes de crear datos, registrar en `00-baseline.md`:

- `RUN_ID` único de la ejecución;
- revisión Alembic actual y head esperado;
- actores y roles utilizados;
- maestros seleccionados y sus imágenes;
- saldos físicos, reservados y libres iniciales;
- ausencia de OP, OF, OA y OT con el mismo `RUN_ID`.

No asumir los conteos ni fixtures de una revisión anterior. La ejecución debe
crear documentos nuevos y conservarlos como evidencia.
## Escenario recomendado

Crear un ProductoTerminado UAT y una variante PiezaColor normalizada
compatible con un molde de una sola salida. Evitar en el primer recorrido el
molde `ML-000001`, porque fabrica asa y broche simultáneamente y la ruta
actual todavía modela una sola salida por operación. Ese caso queda como UAT
específica de coproductos.

Valores seleccionados para el primer recorrido:

- Producto: `PT-000002 · MUESTRA UAT BALDE ROMANO 20L AMARILLO`.
- Artículo resultado SCM: `id=26`.
- Componente: `PC-000013 · Cuerpo Balde Romano 20L AMARILLO SOLIDO`.
- Artículo componente SCM: `id=23`.
- Cantidad demandada: `10 UN`.
- BOM: `1 UN` de `PC-000013`, merma `0 %`.
- Ruta:
  1. `FABRICAR`, autoridad `OP / OT`, salida PiezaColor.
  2. `TERMINAR`, autoridad `Orden de operación`, salida ProductoTerminado,
     usando su BOM aprobada.

## Fase 1 — Ingeniería

1. Entrar a **Datos maestros → Ingeniería SCM**.
2. Establecer actor `1`.
3. En **Estructuras BOM**, elegir el ProductoTerminado y crear la revisión.
4. Agregar la PiezaColor compatible, cantidad `1`, merma `0`.
5. Crear borrador y enviarlo a aprobación.
6. Cambiar actor a `2`, abrir **Aprobaciones** y aprobar la estructura.
7. Volver al actor `1`.
8. En **Rutas**, crear o reutilizar centros de trabajo para fabricación y
   terminación.
9. Crear la ruta con las dos operaciones indicadas.
10. Cambiar actor a `2` y aprobar la ruta.
11. Volver al actor `1`.

Resultado esperado:

- una BOM `APROBADA`;
- una ruta `APROBADA`;
- el ProductoTerminado queda elegible al aprobar una OP.

## Fase 2 — Demanda y planificación

1. Entrar a **Producción → Kardex SCM** con un actor de Almacén.
2. Registrar saldo inicial de la PiezaColor del escenario, con motivo de conteo.
3. Anotar existencia física, reservada `0` y saldo libre.
4. Entrar a **Planificación** con actor `1`.
5. Crear una OP de `10 UN`.
6. Cambiar al actor `3` y aprobar la OP.
7. Volver al actor `1` y calcular el plan.
8. Verificar que la OF propone sólo el faltante después del saldo libre.
9. Cambiar una meta de fabricación o armado e informar el motivo.
10. Guardar y verificar una nueva revisión con columnas **Sugerido** y
    **Meta confirmable**.
11. Confirmar el plan.
12. Volver a Kardex y comprobar que el stock usado pasó a **Reservado**, sin
    cambiar la existencia física.

Resultado esperado:

- OP `PLANIFICADA`;
- OF y OA en `BORRADOR`;
- reserva de stock utilizado, sin movimiento de consumo;
- el valor sugerido permanece visible aunque la meta sea distinta.

## Fase 3 — Configuración y liberación de OF

1. Entrar a **Producción → Órdenes de fabricación**.
2. Seleccionar la OF generada.
3. Verificar que la vista muestre únicamente moldes que contengan todas las
   `PiezaColor` de salida y máquinas `OPERATIVA` del proceso de la ruta.
4. Si existe una sola alternativa compatible, verificar que quede propuesta
   sin guardar ni liberar automáticamente la OF.
5. Intentar enviar por API una máquina de otro proceso y confirmar
   `MACHINE_PROCESS_INCOMPATIBLE` sin cambios parciales.
6. Verificar ciclo, colada, cavidades, peso y ciclos mínimos.
7. Guardar configuración y liberar.

Resultado esperado:

- OF `LIBERADA`;
- unidades por ciclo y peso derivados de `MoldePieza`;
- excedente técnico visible;
- ninguna combinación molde–salida o máquina–proceso incompatible persiste.

## Fase 4 — OT y mangas

1. Entrar a **Producción → OT y mangas**.
2. Recalcular plan de mangas.
3. Crear una OT para fecha, máquina, turno y maquinista.
4. Generar mangas normales.
5. Generar etiquetas de prepesaje.

Resultado esperado:

- OT central creada;
- mangas con identidad `OF-OT-M`;
- trabajos de impresión pendientes para la estación.

## Fase 5 — Pesaje

1. Abrir el módulo local de pesaje.
2. Escanear una preetiqueta.
3. Confirmar el peso sin ingresar identidad manual.
4. Generar y previsualizar la etiqueta final.

Resultado esperado:

- pesaje ligado a la manga;
- bruto, tara y neto productivo auditados;
- etiqueta final vinculada, sin reescribir pesajes legacy.

## Fase 6 — OA

1. Entrar a **Producción → Órdenes de armado**.
2. Verificar entradas teóricas de la BOM.
3. Liberar e iniciar la OA.
4. Cerrar con cantidad conforme y rechazada.

Resultado esperado:

- OA `CERRADA`;
- lote SCM de salida acreditado;
- cobertura terminal actualizada;
- sin consumo físico ni movimiento Kardex.

## Fase 7 — Pausa por cambio de prioridad

1. Crear dos OT para una misma OF o dos OT de una OA.
2. Iniciar una OT y registrar al menos una manga o avance.
3. Pausar solo esa OT con motivo `CAMBIO_PRIORIDAD` y referencia a la orden
   prioritaria.
4. Verificar que la otra OT continúa disponible y que la OF/OA solo aparece
   pausada si no queda otra ejecución activa.
5. Comprobar que reservas, consumos y mangas confirmadas no se revierten.
6. Reanudar la OT y verificar que continúa desde el saldo pendiente sin crear
   mangas ni consumos duplicados.

Resultado esperado:

- OT `PAUSADA` con actor, momento y motivo auditables;
- reservas retenidas por defecto;
- manga abierta resuelta antes de abandonar la estación;
- reanudación a `EN_CURSO` o `EMITIDA` según el estado anterior;
- avance de OF/OA/OP sin doble conteo.

## Evidencia mínima

- captura de cada transición de estado;
- códigos OP, OF, OA y OT;
- código de una manga;
- SVG/TSPL de prepesaje y postpesaje;
- respuesta observada ante una acción sin capacidad;
- cualquier diferencia entre cantidad teórica y operación real.
- captura del saldo físico/reservado/libre antes y después de confirmar;
- motivo y número de revisión del ajuste de metas.

## Hallazgo previo para UAT posterior

`ML-000001` produce dos piezas por golpe. La OF admite múltiples salidas,
pero `ScmOperacionRuta` todavía declara una sola salida. No usar este molde
para el primer happy path; abrir una prueba separada de coproductos antes de
considerar completa la planificación física multipieza.
