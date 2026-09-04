---
tipo: approved-for-dev
estado: desplegado-provisional-pendiente-uat
spec_phase: approved_for_dev
delivery_state: deployed
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
historia: "[[US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
tech_spec: "[[TS-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
tags: [dev, scm, pesaje, manga, relevo, impresion, tdd]
fecha_aprobacion: 2026-08-29
fecha_actualizacion: 2026-08-29
---

# DEV-010K2: relevo multijornada, QR único y stickers de control

## Autoridad y restricción

- Caso: `CAS-PROD-003`.
- Historia: [[US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]].
- Diseño: [[PROTO_US-010K2_Relevo_Multijornada_y_Stickers_de_Peso]].
- Técnica: [[TS-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]].

Gerencia autorizó implementar la feature usando el pipeline. El 2026-08-29 el
usuario autorizó además desplegar el candidato conjunto F3+K2 en Central y en
la estación del piloto. El despliegue no equivale a UX representativa, UAT
física ni habilitación operativa regular en planta.

## Alcance autorizado

- [x] Migración aditiva para etiqueta `CONTROL_PESO`, aporte persistido y
      capacidad de relevo en la misma OT.
- [x] Control central atómico con un trabajo de impresión y cero crédito.
- [x] Impresión local inmediata/reintentable del mismo trabajo.
- [x] Plantilla de control sin QR y plantilla final sin QR.
- [x] Neto y aporte con rótulos legibles; peso estándar inequívoco.
- [x] Relevo supervisado sobre la misma OT, Trabajo, manga y QR.
- [x] Continuidad multi-OT K1 sin regresión.
- [x] Estados y recuperación de UI de Pesaje y Central cubiertos por ATDD;
      validación humana sigue pendiente.
- [x] ATDD, regresión proporcional, render visual y UAT instanciada.
- [x] Recibo final preparado.
- [ ] UAT física ejecutada.

## Secuencia TDD

1. **BASELINE:** fijar pruebas K1, F2, impresión y CRLF vigentes.
2. **RED K2-02/K2-04:** exigir trabajo de control y aporte `4.150`.
3. **GREEN:** persistir aporte, etiqueta y job en la transacción del control.
4. **RED/GREEN K2-03/K2-12:** renderer sin QR, textos y CRLF.
5. **RED/GREEN K2-08/K2-09:** impresión local, retry y emisión incierta.
6. **RED K2-05:** demostrar el bloqueo actual a manga abierta en misma OT.
7. **GREEN:** abrir un nuevo tramo/responsable sin otra manga/preetiqueta.
8. **RED/GREEN K2-07:** tara no comparable revierte control e impresión.
9. **RED/GREEN K2-10/K2-11:** final sin QR, aporte final y estándar separado.
10. **REFACTOR:** unificar render y payloads sin mezclar identidad con
    comprobantes de peso.

## Guardas obligatorias

- No modificar `manga_id`, código ni la preetiqueta/QR vigente.
- No crear QR en stickers CONTROL o FINAL.
- No guardar controles como `ScmPesajeManga` ni relajar el final único.
- No acreditar unidades, inventario, recepción o Kardex desde controles.
- No sumar pesos acumulados.
- No ocultar un cambio de tara: rechazar aporte no comparable.
- No repetir el control para reintentar impresión.
- No abrir dos tramos ni dejar dos responsables activos.
- No declarar `LISTO_PARA_PLANTA` ni ampliar el uso operativo antes de la UAT
  física, aunque el artefacto ya esté desplegado para validación controlada.
- Preservar cambios ajenos existentes en los tres repositorios.

## Dataset mínimo

```text
manga/QR             OF0021-OT0410-M007 / uno y estable
control 1            4.800 kg netos / aporte 4.800 / 20 UN
relevo misma OT      José -> Pedro / misma manga y Trabajo
control 2            8.950 kg netos / aporte 4.150 / 35 UN
continuidad          OT posterior compatible / Pedro o Ana
final                12.000 kg netos / aporte 3.050 / 50 UN
efecto pre-final     0 crédito / 0 Kardex / 2 stickers CONTROL
efecto final         50 UN una vez / 1 sticker FINAL / 0 QR nuevos
```

## Criterio de entrega

- [x] Pruebas focalizadas y contratos Central–Pesaje verdes.
- [x] Regresión proporcional del candidato verde; el fallo global ajeno visto
      durante la implementación y su resolución posterior se documentan en el
      recibo.
- [x] SVG/TSPL inspeccionado a tamaño objetivo.
- [ ] Estados funcionales demostrados en viewport de estación/Central.
- [x] UAT física instanciada, aún pendiente de ejecución humana.
- [x] Recibo con archivos, pruebas, riesgos y rollback; el candidato desplegado
      se aisló en commits de release sin revertir cambios ajenos.

## Evidencia local

- UAT: [[UAT_US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]].
- Recibo: [[REC_2026-08-29_Relevo_Multijornada_QR_Unico_y_Stickers_Control]].
- SVG real: `output/US-010K2_etiqueta_control_peso_sin_qr.svg`.
- Despliegue conjunto documentado en
  [[REC_2026-08-29_Despliegue_F3_K2_Central_y_Estacion_Pilot13]]; la prueba
  física en la PC de Pesaje continúa pendiente.
