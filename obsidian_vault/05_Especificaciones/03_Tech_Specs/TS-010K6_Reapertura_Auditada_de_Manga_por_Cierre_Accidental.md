---
tipo: tech-spec
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha: 2026-09-03
---

# TS-010K6 — Reapertura auditada de manga por cierre accidental

Implementa [[US-010K6_Reapertura_Auditada_de_Manga_por_Cierre_Accidental]].
Autorización: petición explícita del responsable funcional durante UAT local;
excepción provisional de riesgo alto, sin autorización para planta.

## Contrato de dominio

- `ScmPesajeManga.estado`: `VIGENTE | REABIERTO | ANULADO`. Índice parcial
  garantiza un único final vigente por manga, permitiendo conservar finales
  invalidados y crear uno nuevo.
- `ScmReaperturaManga`: compensación append-only, única por final y operación;
  registra manga, pesaje, motivo, evidencia, actor y momento.
- La transacción bloquea manga/final/tramos, valida versión y capacidad
  `MANGA_REABRIR`, descuenta de cada Trabajo la atribución confirmada por el
  final, limpia la proyección confirmada de manga, reactiva el último tramo y
  marca `REABIERTO` el final. No toca cupos ni controles.
- Para este corte solo se admite Fabricación `NORMAL`, fuente
  `PLAN_CONFIRMADO_POR_PESAJE` y sin existencia vigente de Almacén.
- Las postetiquetas vigentes se invalidan con motivo; PREPESAJE permanece
  `IMPRESA`. Correcciones pendientes del final se rechazan.
- Anulación definitiva marca el final `ANULADO` y conserva su semántica previa.

## Contrato API y datos

`POST /api/scm/v1/mangas/{manga_id}/reabrir`

```json
{
  "version": 4,
  "motivo": "Cierre accidental; no se marcó Control de peso",
  "evidencia": "UAT-2026-09-03"
}
```

Requiere `Idempotency-Key`. Responde `manga`, `pesaje_invalidado`, `reapertura`
y postetiquetas invalidadas. Errores estables: `MANGA_VERSION_CONFLICT`,
`MANGA_REOPEN_NOT_AVAILABLE`, `WEIGHING_NOT_ACTIVE`,
`RECEIPT_REVERSAL_REQUIRED`, `OPERATION_REOPEN_REQUIRED` y autorización común.
El GET de detalle distingue `vigente`, `reapertura` e `historial`; resolución de
estación y recepción consideran exclusivamente `estado=VIGENTE`.

Migración: añadir estado/backfill a pesajes, sustituir unique total por índice
parcial, crear tabla de reapertura y sembrar `MANGA_REABRIR` para GG/JP.
Downgrade se bloquea si existen reaperturas o más de un final por manga.

## Contrato de interacción y presentación

En el diálogo `Ver pesaje`, JP/GG ve dos bloques separados:

1. `Reabrir manga` (warning): conserva M001/QR/cupo, invalida el final y exige
   motivo; es la recuperación de cierre accidental.
2. `Anular pesaje definitivamente` (error): termina manga/QR y devuelve cupo.

Durante envío se deshabilitan acciones. En éxito se cierra el diálogo, se
refresca la OT y aparece: manga abierta, mismo QR, sticker final inválido. La
estación no cambia de layout: reescaneo es la recuperación observable.

## Pruebas, observabilidad y liberación

- BASELINE: backend `515 passed`, `1 failed` preexistente en portfolio demo.
- Primera RED: cerrar manga tras control, reabrir y exigir mismo QR habilitado,
  final histórico, cupo estable y nuevo final posible.
- Integración: permiso, versión, idempotencia, doble reapertura, recepción,
  alcance Fabricación normal y postetiquetas.
- UI: botón por capacidad, motivo obligatorio, copy diferencial y error de
  recepción. Contrato Central–estación sin ruptura; pruebas de ambos lados.
- QA visual: diálogo antes/durante/después, viewport desktop objetivo; UAT
  física reescanea la preetiqueta pegada y retira/marca postetiqueta inválida.
- Observabilidad: evento `MANGA_REOPENED_AFTER_ACCIDENTAL_CLOSE` con IDs y
  resultado, sin credenciales.
- Rollback de código: revertible. Downgrade de datos no permitido tras usar la
  feature; restaurar release anterior manteniendo esquema aditivo.

APPROVED-FOR-DEV: autorización humana explícita del 2026-09-03; alcance local y
restricción `no_habilitar_en_planta` conservados.
