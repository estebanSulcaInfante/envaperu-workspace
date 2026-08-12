---
tipo: decision-arquitectura
estado: aceptada
fecha: 2026-08-11
tags: [scm, kardex, almacen, ubicacion, custodia, transferencia, gs1, scor]
relaciones:
  - "[[US-013_Kardex_MultiAlmacen_Custodia_y_Operaciones_QR]]"
  - "[[Inventario_SCM]]"
  - "[[Almacen_SCM]]"
  - "[[Ubicacion_Inventario]]"
  - "[[Transferencia_Inventario]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
---

# ADR: almacenes, custodia, transferencias y Kardex único

## Contexto

El piloto conserva existencias por `ArticuloSCM + UbicacionInventario`. La
recepción selecciona una ubicación compatible por manga. El abastecimiento a
Armado mueve saldos por ubicaciones técnicas `TRANSITO_PRODUCCION`,
`MESA_ARMADO` y `TRANSITO_ALMACEN`.

Este diseño preserva la cantidad física, pero todavía mezcla tres dimensiones:

- **almacén:** ámbito organizacional responsable;
- **ubicación:** lugar físico o punto operativo;
- **disposición/custodia:** disponible, reservada, en picking, en tránsito,
  recibida, bloqueada o consumida.

Además, `INVENTARIO_VER` autoriza hoy una proyección global: no limita datos por
almacén asignado o clase de artículo.

## Decisión

1. Existe un único libro mayor append-only de inventario para toda la empresa.
2. `AlmacenSCM` es una frontera de responsabilidad, seguridad y conciliación.
3. `UbicacionInventario` pertenece a un almacén, área productiva o red de
   tránsito y conserva su tipo explícito.
4. Una transferencia mantiene origen, destino, custodio, unidad logística y
   documento causal. En tránsito sigue siendo existencia física de EnvaPerú,
   pero no saldo libre del origen ni del destino.
5. El despacho y la recepción son eventos distintos. `PICKUP` es una modalidad
   de entrega física en la que el receptor recoge en staging; no equivale a
   consumo.
6. Las vistas de materias primas, piezas/WIP y producto terminado son
   proyecciones especializadas del mismo Kardex, no libros separados.
7. La autorización combina capacidad por acción y alcance de datos por almacén,
   ubicación y clase. El backend aplica ambos; ocultar controles no es seguridad.
8. Los códigos de tránsito actuales se preservan durante compatibilidad, pero
   dejan de ser la autoridad semántica: la transferencia pasa a ser la entidad
   que explica el tránsito.
9. No existen códigos ni jerarquía física que deban sembrarse como verdad de
   planta. El administrador configura almacenes, ubicaciones, compatibilidades
   y puntos de pickup antes de operar; los códigos de la TS son ejemplos.
10. En el piloto, el solicitante de Armado recoge en el almacén. Al confirmar
    pickup acepta custodia para `MESA_ARMADO` y el comando acredita el destino
    directamente. El recorrido corto a pie no crea tránsito adicional.
11. Una diferencia de entrega/recepción genera incidencia inmediata. Una manga
    producida y pesada que permanece 24 horas sin ingreso a ningún almacén
    genera alerta configurable y visible en Control; ninguna alerta mueve saldo
    o recibe automáticamente.

## Semántica objetivo

```text
DISPONIBLE -> RESERVADA -> EN_PICKING -> LISTA_PARA_PICKUP
 -> EN_TRANSITO -> RECIBIDA_DESTINO -> EN_STAGING/CONSUMIDA

EN_STAGING -> PENDIENTE_RETORNO -> EN_TRANSITO_RETORNO
 -> RECIBIDA_ORIGEN -> DISPONIBLE
```

Calidad permanece ortogonal a la posición logística.

## Alineación SCM

La solución adopta como vocabulario de referencia:

- GS1 EPCIS/CBV: identidad del objeto, tiempo, punto de lectura, ubicación de
  negocio, paso `picking/shipping/receiving` y disposición `in_transit`;
- SCOR Digital Standard: recibir, pick, stage, ship y recibir transferencias
  intraempresa.

Esto es alineación semántica, no una afirmación de conformidad EPCIS. La
exportación EPCIS queda fuera del primer incremento.

Referencias oficiales:

- https://www.gs1.org/standards/epcis
- https://ref.gs1.org/cbv/Disp-in_transit
- https://scor.ascm.org/processes/fulfill

## Consecuencias

### Positivas

- el inventario total no desaparece durante un traslado;
- se puede responder quién tenía custodia y quién debe confirmar;
- una sola verdad alimenta operaciones y control;
- los trabajadores ven únicamente su ámbito operativo;
- el flujo admite lector QR, lote, pickup y entrega tradicional.

### Costes

- migración aditiva y backfill de ubicaciones actuales;
- nuevos alcances por trabajador y administración correspondiente;
- compatibilidad temporal con los estados/códigos de US-010H;
- conciliación y alertas para transferencias envejecidas o incompletas.

## Alternativas descartadas

1. **Sacar la manga del Kardex mientras viaja:** pierde cantidad física y
   control de custodia.
2. **Crear tres Kardex independientes:** duplica reglas y rompe transferencias.
3. **Usar solo un estado `EN_TRANSITO`:** no identifica origen, destino,
   responsables ni recepción pendiente.
4. **Confiar únicamente en roles:** no restringe qué almacén puede operar cada
   persona.

## Compatibilidad y adopción

La adopción será expand/cutover/contract:

1. crear almacenes, jerarquía, alcances y transferencias sin retirar campos;
2. proyectar los movimientos actuales hacia la nueva semántica;
3. migrar UI y comandos;
4. comparar saldos y genealogía;
5. retirar únicamente aliases técnicos cuando UAT demuestre equivalencia.

## Decisiones operativas cerradas el 2026-08-11

- La jerarquía nace por configuración, no por semilla normativa.
- El pickup habitual lo ejecuta la misma persona que solicitó materiales para
  Armado.
- Confirmar pickup significa aceptar custodia y recepción en `MESA_ARMADO`.
- `ENTREGA` conserva despacho y recepción separados para recorridos que sí
  necesiten tránsito observable.
- El umbral inicial de manga pesada sin recepción es 24 horas y permanece
  versionado/configurable en Alertas.
