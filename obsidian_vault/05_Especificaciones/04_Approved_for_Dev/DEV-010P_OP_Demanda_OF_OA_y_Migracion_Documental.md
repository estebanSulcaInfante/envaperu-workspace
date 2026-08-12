---
tipo: especificacion
subtipo: approved_for_dev
estado: en-desarrollo-local
tags: [scm, US-010P, orden-produccion, orden-fabricacion, orden-armado, migracion]
fecha_aprobacion: 2026-07-29
fecha_actualizacion: 2026-07-29
---

# DEV-010P: OP de demanda, OF/OA y migración documental

## Referencias

- Historia: [[../02_User_Stories/US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP|US-010P]]
- Tech Spec: [[../03_Tech_Specs/TS-010P_OP_Demanda_OF_OA_y_Migracion_Documental|TS-010P]]
- ADR: [[../../20_Registro_Decisiones/2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]

## Autorización y restricciones

Desarrollo autorizado el 2026-07-29 únicamente en local.

- No tocar la base desplegada.
- No crear OP de demanda desde datos técnicos legacy.
- No alterar valores, IDs o timestamps de pesajes históricos.
- Preservar códigos y etiquetas ya emitidos.
- Mantener lectores/adaptadores legacy mientras el contrato v2 se valida.
- Crear capacidades, sin asignar trabajadores automáticamente.
- Implementar mediante migración expand/backfill/contract verificable.

## Orden de implementación

1. BASELINE de backend, migraciones, frontend y estación.
2. RED de modelos OP, orden de operación, OF/corrida/salidas y asignaciones.
3. GREEN de migración expand y backfill conservador.
4. Servicios/API OP y OF.
5. Adaptación OT/plan de mangas/código y plantilla de etiquetas.
6. Frontend OP/OF/OA.
7. Pruebas PostgreSQL, E2E y UAT local.

## Primera prueba RED

`tests/scm/test_scm_production_order_planning.py` debe fallar porque todavía no
existen:

- `ScmOrdenProduccion`;
- `ScmOrdenOperacion`;
- `ScmOrdenFabricacion`;
- `ScmCorridaFabricacion`;
- `ScmOrdenOperacionSalida`;
- `ScmAsignacionDemandaSuministro`.

La primera prueba valida creación de una OP con línea PT y una OF multipieza
asignada N:M sin reutilizar `OrdenProduccion.producto_sku`.

## Puertas

- [x] Migración vacía y con fixtures verdes.
- [x] Conteos legacy verificados; la migración no escribe tablas de pesaje.
- [x] Creación OP y OF excepcional idempotentes.
- [x] OT nueva exige OF/corrida.
- [x] Etiqueta v2 usa OF–OT y v1 continúa legible.
- [ ] Frontend no muestra molde en creación OP.
- [x] OF excepcional exige motivo/autorización.
- [ ] UAT local completa.

## Corte implementado 2026-07-29

- Migraciones `f16b3d9e5a42`, `f27c4e0a6b53` y `f38d5f1b7c64`.
- Tablas nuevas de OP, líneas, orden operativa, OF, corridas, salidas y
  asignación demanda–suministro.
- Columnas canónicas opcionales en OT y plan de mangas.
- Backfill determinístico y conservador en PostgreSQL local:
  - 4 `orden_produccion` técnicas → 4 OF legacy;
  - 13 `lote_color` → 13 corridas;
  - 10 salidas legacy → 10 salidas canónicas;
  - ninguna OP de demanda inventada.
- API local:
  - crear/listar/consultar/aprobar OP;
  - crear/listar/consultar/liberar OF excepcional;
  - códigos `OP-######` y `OF-######`;
  - idempotencia y auditoría UUID.
- Capacidades OP/OF/OA creadas y asociadas a roles configurables; no se
  asignaron trabajadores automáticamente.
- Contrato central–balanza actualizado para preetiqueta y pesaje de manga.
- Verificación:
  - backend: 247 aprobadas, 1 omitida;
  - contrato/estación seleccionado: 18 aprobadas;
  - migración desde base vacía en schema PostgreSQL aislado: aprobada.

## Segundo corte implementado 2026-07-29

- Migraciones `f41a6c2d8e75` y `f42b7d3e9f86`:
  - plan de mangas y lote de artículo pueden referenciar la salida canónica;
  - la OT referencia una OF y exactamente una corrida;
  - mangas de WIP o PT directo no requieren un SKU `PiezaColor`.
- API local:
  - consultar/recalcular plan por OF;
  - crear OT desde OF indicando `corrida_fabricacion_id`;
  - listar OT y solicitudes extra filtradas por `orden_operacion_id`;
  - validación de pertenencia OF–corrida–salida también al agregar mangas.
- Identidad nueva:
  - manga `OF######-OT###-M###`;
  - prepesaje `PREPESAJE_TSPL_2`;
  - postpesaje `POSTPESAJE_TSPL_2`;
  - campo visible `of_ot`;
  - contenido QR permanece en versión 1 y conserva los UUID de manga y
    etiqueta.
- La estación de pesaje renderiza `OF/OT` en TSPL y en la vista SVG web,
  manteniendo soporte de `OP/OT` para etiquetas legacy.
- La pantalla **Producción → OT y mangas** ahora selecciona OF y corrida,
  muestra solo las salidas de esa corrida y crea la OT por la API canónica.
- Base PostgreSQL local migrada a `f42b7d3e9f86`; no se tocó la base
  desplegada ni se reescribieron pesajes o etiquetas existentes.
- Verificación:
  - backend completo: 248 aprobadas, 1 omitida;
  - flujo canónico OF → OT → preetiqueta → pesaje → postetiqueta: aprobado;
  - estación seleccionada: 7 aprobadas;
  - migración desde base vacía en schema PostgreSQL aislado: aprobada;
  - build Vite y ESLint de archivos modificados: aprobados.

## Siguiente corte después de planificación documental

1. Completar edición/liberación y ejecución de OA.
2. Configurar técnicamente las OF borrador generadas antes de liberarlas.
3. Incorporar stock real como fuente opcional de cobertura.
4. Ejecutar la UAT integral con una OP y una OF excepcional reales.

## Tercer corte implementado 2026-07-29

- Migración `f43c8e4f0a97` con snapshots auditables de planificación:
  - revisión por OP;
  - hash de entradas y contenido;
  - propuesta JSON inmutable;
  - estados `CALCULADO`, `CONFIRMADO` y `SUPERADO`;
  - separación de actores de cálculo y confirmación.
- API local:
  - `GET /ordenes-produccion/{id}/plan`;
  - `POST /ordenes-produccion/{id}/calcular-plan`;
  - `POST /ordenes-produccion/{id}/confirmar-plan`.
- El cálculo:
  - usa exclusivamente los snapshots BOM/ruta de la OP;
  - explota estructuras multinivel con merma técnica y unidades enteras;
  - propone OF para operaciones `OP_OT` y OA para
    `ORDEN_OPERACION`;
  - declara bloqueos cuando un artículo requerido no posee operación de
    ruta;
  - usa el Kardex normalizado del piloto y solo considera saldo libre
    (`cantidad_fisica - cantidad_reservada`).
- La confirmación:
  - exige versión de OP, UUID y hash exactos del plan;
  - crea OF/OA en `BORRADOR`;
  - crea asignaciones demanda–salida `PLANIFICADA`;
  - cambia la OP a `PLANIFICADA`;
  - no libera documentos ni consume inventario;
  - revalida y reserva el Kardex utilizado por la propuesta.
- La ruta principal `/planificacion` ahora usa la API local y permite crear
  la OP de demanda, aprobarla, calcular, revisar bloqueos y confirmar el
  plan.
- Caso verificado: una demanda de 10 PT con 2 piezas por PT propone una OF
  de 20 piezas y una OA de 10 PT; solo la salida final cubre la línea de
  demanda.

## Cuarto corte implementado 2026-07-29

- Migración `f44d9f5a1b08`:
  - cada OF/OA generada conserva `plan_produccion_id`;
  - cada documento conserva la `propuesta_clave` que le dio origen;
  - la combinación plan–propuesta es única y evita duplicar documentos.
- API local:
  - `PATCH /ordenes-fabricacion/{id}` configura exclusivamente una OF en
    `BORRADOR`;
  - mantiene control optimista por versión, idempotencia y evento
    `OF_DRAFT_CONFIGURED`;
  - la liberación exige máquina, molde, ciclo, turno y snapshots físicos
    completos para todas las salidas.
- Regla técnica:
  - para una salida `PIEZA_COLOR`, unidades por ciclo y peso unitario se
    derivan de la relación activa `MoldePieza`;
  - el color se deriva de `PiezaColor`;
  - los ciclos mínimos se calculan con techo para cubrir la demanda;
  - la diferencia inevitable se registra como excedente objetivo;
  - para salida WIP o PT directo, unidades por ciclo y peso se informan
    explícitamente porque no existe una relación física `MoldePieza`.
- Frontend local:
  - nueva vista **Producción → Órdenes de fabricación**;
  - selección de OF, molde y máquina;
  - edición de snapshots técnicos;
  - revisión de ciclos, cantidades, kg y excedente;
  - liberación separada después de guardar la configuración.
- Verificación:
  - backend completo: 249 aprobadas, 1 omitida;
  - migración desde base vacía en schema PostgreSQL aislado: aprobada;
  - base local `envaperu_test` en `f44d9f5a1b08`;
  - ESLint y build Vite: aprobados.

## Siguiente corte

1. Completar una UAT integral OP → plan → OF/OA → OT → mangas → pesaje.
2. Incorporar consumo físico de lotes y Kardex cuando el módulo de almacén
   entre en alcance.
3. Incorporar stock real como fuente opcional de cobertura.

## Quinto corte implementado 2026-07-29

- Migración `f45e8a6c0b19`:
  - actores y tiempos de inicio/cierre en la orden operativa;
  - cantidades conformes y rechazadas en la salida;
  - capacidad configurable `OA_EJECUTAR` para Supervisor y Jefe de
    Producción.
- API central:
  - listar y consultar OA;
  - liberar una OA contra la operación de ruta y BOM congeladas;
  - iniciar la ejecución;
  - cerrar registrando resultado conforme y rechazado.
- Al cerrar:
  - nace un `ScmLoteArticulo` de clase `SALIDA_ORDEN_OPERACION`;
  - se acredita exclusivamente la cantidad conforme;
  - se actualiza la cobertura de la demanda terminal;
  - no se descuenta Kardex ni se inventan consumos físicos.
- Frontend local:
  - nueva vista **Producción → Órdenes de armado**;
  - muestra centro de trabajo, salida objetivo y entradas teóricas;
  - permite liberar, iniciar y cerrar;
  - muestra el lote acreditado y su estado de calidad.
- Verificación:
  - backend completo: 249 aprobadas, 1 omitida;
  - frontend: 93 pruebas aprobadas;
  - migración PostgreSQL aislada desde cero: aprobada;
  - base local en `f45e8a6c0b19`;
  - ESLint y build Vite: aprobados.
