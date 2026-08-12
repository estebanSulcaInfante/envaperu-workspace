---
tipo: tech-spec
estado: implementada-local-pendiente-uat
historia: "[[../02_User_Stories/US-010E_Molienda_y_Material_Recuperado_Trazable|US-010E]]"
fecha_actualizacion: 2026-08-03
tags: [scm, molienda, merma, kardex, kg, genealogia]
---

# TS-010E: Molienda, merma y material recuperado

## Decisiones de arquitectura

1. El Kardex de artículos existente conserva cantidades en `UN`. La merma y el
   material recuperado se controlan en un subledger trazable en `KG`; no se
   crean artículos ficticios ni se mezclan unidades.
2. Una bolsa/lote de merma crea existencia una sola vez con su peso neto de
   almacén. El pesaje previo al molino gobierna el consumo y se concilia contra
   ese saldo; ambos pesos se conservan y nunca se suman.
3. Familias de material, procesos de origen y condiciones son maestros
   configurables, activos y versionados. Color nominal y familia de color
   reutilizan los maestros existentes.
4. Las reglas de compatibilidad son revisiones inmutables. Una revisión
   aprobada no puede editarse; una nueva revisión no reinterpreta órdenes
   históricas.
5. La combinación inyección/soplado de hasta 10 % se carga como configuración
   inicial editable, no como constante de dominio.
6. El cierre de molienda debita entradas y acredita el lote de salida en una
   transacción idempotente. Un saldo nunca puede quedar negativo.
7. El material recuperado queda `PENDIENTE_LIBERACION`; solo el Jefe de
   Producción puede convertirlo en `DISPONIBLE`.

## Modelo físico

| Tabla | Responsabilidad |
|---|---|
| `scm_familia_material_reproceso` | Maestro de polímeros/familias |
| `scm_proceso_material_reproceso` | Maestro de procesos de origen |
| `scm_condicion_merma` | Condición y recuperabilidad |
| `scm_regla_compatibilidad_reproceso` | Revisión y porcentaje máximo |
| `scm_lote_merma_recuperable` | Bolsa/lote y saldo en kg |
| `scm_movimiento_merma` | Subledger append-only |
| `scm_orden_molienda` | Objetivo, estado y balance |
| `scm_orden_molienda_aporte` | Aporte planificado/real y snapshot de regla |
| `scm_lote_material_recuperado` | Salida, composición y liberación |

La composición de salida se congela como JSON cuantificado por aporte además
de las llaves relacionales de genealogía. Pesos usan `Numeric(15,3)`.

## Estados

- Merma: `ALMACENADA`, `RESERVADA`, `CONSUMIDA`, `BLOQUEADA`, `ANULADA`.
- Orden: `BORRADOR`, `VALIDADA`, `BLOQUEADA_COMPATIBILIDAD`,
  `EN_EJECUCION`, `CERRADA`, `ANULADA`.
- Recuperado: `PENDIENTE_LIBERACION`, `DISPONIBLE`, `BLOQUEADO`, `ANULADO`.

## Contratos API

Base: `/api/scm/v1/reproceso`.

- `GET/POST/PATCH /maestros/{familias-material|procesos|condiciones}`
- `GET/POST /reglas-compatibilidad`
- `POST /reglas-compatibilidad/{id}/aprobar`
- `GET/POST /mermas`
- `GET /mermas/{id}/movimientos`
- `GET/POST /ordenes-molienda`
- `POST /ordenes-molienda/{id}/aportes`
- `POST /ordenes-molienda/{id}/validar`
- `POST /ordenes-molienda/{id}/pesos-pre-molino`
- `POST /ordenes-molienda/{id}/iniciar`
- `POST /ordenes-molienda/{id}/cerrar`
- `POST /lotes-recuperados/{id}/liberar`
- `GET /lotes-recuperados`

Los comandos que mueven kg exigen `Idempotency-Key`, `X-Actor-Id`, motivo y
capacidad. Errores de compatibilidad, saldo y tolerancia responden `409/422`
con un código estable y detalles accionables.

## Reglas de cálculo

```text
pct_aporte = kg_pre_molino / suma_kg_pre_molino * 100
diferencia_custodia = kg_pre_molino - kg_almacenado_consumido
diferencia_balance = kg_entrada - kg_salida - kg_perdida
```

La tolerancia inicial de custodia es `1.000 kg`. Superarla crea alerta y exige
autorización de Jefatura. La tolerancia de balance nace como parámetro sin valor
aprobado y bloquea el cierre hasta configurarse.

## Seguridad

Capacidades: `MERMA_RECUPERABLE_REGISTRAR`, `MOLIENDA_VER`,
`MOLIENDA_ORDEN_CREAR`, `MOLIENDA_EJECUTAR`,
`MOLIENDA_REGLA_ADMINISTRAR`, `MOLIENDA_REGLA_APROBAR`,
`MOLIENDA_EXCEPCION_APROBAR`, `MOLIENDA_LOTE_LIBERAR` y `MOLIENDA_ANULAR`.

## UI

`/produccion/reproceso` presenta una bandeja por tareas:

- Almacén: registrar/pesar merma y ver saldo;
- Operador de molino: preparar, validar, repesar y cerrar orden;
- Jefe de Producción: excepciones, liberaciones y alertas;
- Configuración/Ingeniería: maestros y revisiones de compatibilidad;
- Gerencia: consulta de balance y genealogía.

Cada formulario muestra requeridos, unidades, razón del bloqueo, éxito y
reintento seguro; ninguna acción destructiva elimina eventos.

## Pruebas

- unitarias: porcentajes, simetría, 10 %, balance y transiciones;
- integración: saldo no negativo, doble pesaje sin duplicación, cierre
  idempotente y liberación por capacidad;
- contrato: errores estables y concurrencia de versión;
- UI: estados vacío/cargando/error, acción por permiso y flujo feliz completo.

Primera prueba RED: registrar peso pre-molino por segunda vez no puede acreditar
kg; debe actualizar la conciliación del aporte sin crear otra entrada.
