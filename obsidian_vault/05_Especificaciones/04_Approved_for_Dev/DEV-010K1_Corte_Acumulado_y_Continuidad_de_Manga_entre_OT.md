---
tipo: approved-for-dev
estado: implementado-local-pendiente-uat
historia: "[[US-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
tech_spec: "[[TS-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
tags: [dev, scm, fabricacion, pesaje-control, manga, continuidad, tdd]
fecha_aprobacion: 2026-08-26
fecha_actualizacion: 2026-08-26
---

# DEV-010K1: Corte acumulado y continuidad de manga entre OT

## Autoridad

- Decisión: [[2026-08-26_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]
- Historia: [[US-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]
- Tech Spec: [[TS-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]
- UAT: `docs/recorrido-uat-pesaje-piezas.md`, paso 5B caso B

Ante divergencia, manda la decisión para las fuentes de verdad y la US para el
resultado observable. La TS fija contratos, persistencia y pruebas.

## Alcance autorizado

- [x] `scm_tramo_manga_trabajo` y `scm_control_peso_manga` con migración segura.
- [x] Estados `CONTINUIDAD_PENDIENTE`/`EN_LLENADO`, origen de manga inmutable
      y contexto vigente por tramo.
- [x] Pausa automática del Trabajo/asignación origen al aceptar el corte.
- [x] `POST /integration/v1/manga-weighing-controls` sin efectos de final.
- [x] `POST /api/local/v1/scm/weighing/controls` y acción separada en estación.
- [x] Consulta de continuidades pendientes por OT destino y corrida.
- [x] Extensión atómica de `POST /scm/v1/ots/{ot_id}/trabajos-color` mediante
      `continuidad_manga_ids`; `asignaciones` admite `[]` en ese caso.
- [x] Movimiento del remanente de plan sin crear otra manga ni cupo.
- [x] Final F2 único, postetiqueta única y atribución `20/30`.
- [x] Proyecciones Central, detalle y controles negativos de UAT.

## Secuencia TDD obligatoria

1. **BASELINE:** M1–M3, D-core, estación conectada y Kardex verdes.
2. **RED K1-01:** intentar registrar `20 UN / 4.800 kg` como control sin final.
3. **GREEN K1-01:** persistir control append-only con cero crédito, impresión e
   inventario.
4. **RED/GREEN K1-02/K1-06:** acumulados e idempotencia/concurrencia.
5. **RED K1-03:** demostrar el bloqueo multi-OT vigente.
6. **GREEN K1-03:** GET de candidatas y POST de Trabajo destino atómico con la
   misma manga/QR y sin aceptación de Pedro.
7. **RED/GREEN K1-04:** matriz de incompatibilidad y rollback completo.
8. **RED/GREEN K1-05:** final único `50` con desglose `20/30`.
9. **RED/GREEN K1-07/K1-08:** Almacén bloqueado antes del final y un ingreso
   después.
10. **REFACTOR:** centralizar contexto vigente, acumulados y proyección sin
    mezclar controles con finales.

## Contratos que no deben desviarse

- El control central es `POST /integration/v1/manga-weighing-controls`.
- La estación local usa `POST /api/local/v1/scm/weighing/controls` con
  `Idempotency-Key`; la UUID también es `capture_id`.
- Central resuelve el tramo; la estación no envía `tramo_id`.
- Las candidatas se leen con
  `GET /scm/v1/ots/{ot_id}/continuidades-pendientes?corrida_fabricacion_id=...`.
- La continuidad se confirma dentro de
  `POST /scm/v1/ots/{ot_id}/trabajos-color`, no en un endpoint nuevo por manga.
- `asignaciones: []` es válido si `continuidad_manga_ids` no está vacío.
- F2 sigue siendo exclusivamente final e impresión.

## Guardas

- No cambiar `manga_id`, código, QR, OT/Trabajo/asignación de origen.
- No guardar controles en `scm_pesaje_manga` ni relajar su final único.
- No acreditar, imprimir, recibir ni crear Kardex desde un control o tramo.
- No sumar controles acumulados ni inferir unidades desde kg.
- No pedir aceptación a Pedro; el supervisor autoriza y Pedro es responsable.
- No dejar el Trabajo origen ejecutándose después del corte; el destino solo
  activa su tramo cuando se inicia.
- No crear otra manga, preetiqueta o `mangas_asignadas` en el destino.
- No admitir otra corrida/OF, máquina, salida, color o receta. La manga
  continuada hereda y no reescribe sus snapshots históricos de empaque.
- No permitir la misma OT ni una OT que no sea posterior por fecha/turno.
- No usar el cierre final parcial como continuidad.
- No implementar reapertura ni corrección destructiva dentro de K1.

## Dataset de aceptación

```text
manga objetivo      50 UN / QR K1-ORIGINAL
tramo 1             Jose / OT origen / 0..20
control             4.830 bruto - 0.030 tara = 4.800 kg; 20 UN
efectos control      0 producción / 0 impresión / 0 Kardex
tramo 2             Pedro / OT destino compatible / 20..50
aceptación Pedro     no existe
final F2             12.030 bruto - 0.030 tara = 12.000 kg; 50 UN
atribución final     Jose 20 + Pedro 30 = 50 UN
identidades          1 manga / 1 QR / 1 final / 1 postetiqueta
```

## Criterio de completada

- [ ] K1-01…K1-08 automatizados y baseline sin regresión.
- [ ] Dos controles o traslados concurrentes no abren dos tramos.
- [ ] Control y final concurrentes no dejan estado parcial.
- [ ] Una incompatibilidad no mueve plan, tramo, responsable ni QR.
- [ ] Producción muestra un total `50`, no `20 + 50`.
- [ ] Atribuciones muestran `20/30` y reconcilian con el único final.
- [ ] Almacén bloquea antes del final y acredita una sola vez después.
- [ ] UAT remota firmada; hardware real permanece como certificación separada.
