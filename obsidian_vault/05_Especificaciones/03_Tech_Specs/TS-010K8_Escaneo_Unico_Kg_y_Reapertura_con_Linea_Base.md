---
tipo: tech-spec
estado: aprobada-por-solicitud-explicita
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha_creacion: 2026-09-03
fecha_actualizacion: 2026-09-04
relaciones:
  - "[[US-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]]"
  - "[[DEV-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]]"
---

# TS-010K8: escaneo único, kg y reapertura con línea base

## Contrato de dominio

`ScmReaperturaManga` añade `tipo_reapertura` con valores
`CIERRE_ACCIDENTAL|CONTINUAR_LLENADO` y `peso_base_neto_kg`. El primero exige
base nula; el segundo congela el NET positivo del final reabierto. El final pasa
a `REABIERTO` en ambos casos y permanece en historial. Para monotonicidad, la
referencia vigente es el evento más reciente entre control aceptado y
reapertura con base. La tara/fuente deben seguir siendo comparables.

## Contrato API y datos

`POST /api/scm/v1/mangas/{id}/reabrir` acepta `tipo_reapertura`; por
compatibilidad, su ausencia se interpreta `CIERRE_ACCIDENTAL`. La respuesta y
detalle incluyen tipo/base. La resolución agrega
`manga.peso_fabricado_teorico_kg` y
`continuidad.ultima_referencia_peso {fuente,peso_neto_kg,tara_kg,
tara_fuente,pesado_at}`. Migración aditiva, con backfill accidental para filas
existentes y constraint de coherencia. No cambia el QR.

## Contrato de interacción

La estación mantiene `scanConsumed=false` solo después de una resolución
exitosa. Cualquier control/final aceptado lo cambia a `true`; el estado común
bloquea botón y F2 hasta resolver un QR. El resultado no se oculta. Error sin
acuse no consume la intención y conserva la operación idempotente. Fabricación
simple elimina entrada de cierre parcial por UN y muestra cuatro magnitudes kg.

Central exige seleccionar el tipo, motivo y confirmación. Para continuación
muestra el NET que será base; para accidente dice que el NET queda solo en
historia. Ambos recuerdan retirar/marcar la postetiqueta anterior.

## Contrato de presentación

Código, pieza/color y NET dominan. Peso teórico y último NET son referencias
secundarias con rótulos inequívocos. Diferencia negativa se presenta pero no
habilita F2. El éxito usa texto y no solo color. Viewports: escritorio local de
estación y Central; dimensiones físicas reales pendientes.

## Pruebas y liberación

BASELINE: backend SCM focal 41 verde; estación 41 verde; Central OT 42 verde.
Primera RED: tras control exitoso, cambiar el peso no vuelve a habilitar F2.
Luego RED de reapertura continua: NET `5.000` debe producir base `5.000` y
aporte `0.700` al registrar `5.700`; accidente `8.950` no bloquea `4.970`
cuando el último control es `4.790`.

Mapeo: K8-01..05 pruebas UI/estado y contrato de resolución; K8-06..08 servicio,
migración e idempotencia; K8-09 UI Central. Ejecutar regresiones de ambos
frontends, backend SCM, build y contratos Central–Pesaje. Capturar inicial,
listo, éxito consumido, reescaneo, ambos diálogos y errores. Sin hardware real
no se eleva UX ni UAT física.

Rollback de código permitido; downgrade de datos solo si no existen
reaperturas `CONTINUAR_LLENADO`. Observabilidad conserva eventos existentes y
usa `MANGA_REOPENED_FOR_CONTINUED_FILLING` para el nuevo caso.
