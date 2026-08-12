---
tipo: approved-for-dev
estado: implementado-local-pendiente-uat
historia: "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
tech_spec: "[[TS-010F_Armado_Genealogia_Mangas_PT_y_Cierre_Armado]]"
fecha_aprobacion: 2026-08-03
---

# DEV-010F2: Excepciones de origen y correcciones de Armado

## Decisión

La genealogía exacta sigue siendo la vía normal. Cuando la realidad física no
permite identificar cada manga fuente se habilitan dos excepciones explícitas:

1. `CONJUNTO_CANDIDATOS`: conserva todas las mangas posibles como relación N:M
   y descuenta un saldo agregado. No atribuye cantidades individuales.
2. `LEGACY_SIN_ORIGEN`: incorpora un conteo físico inicial con artículo,
   ubicación, cantidad, motivo, actor y evento de Kardex.

Ambas modalidades se muestran como excepcionales en la interfaz y requieren
capacidades específicas. Nunca son elegidas automáticamente por el sistema.

## Corrección de cantidad

- el cierre original de Armado es inmutable;
- el responsable o Jefe de Armado solicita la corrección con motivo;
- el Jefe de Producción la aprueba con un actor distinto;
- el sistema genera consumos o restituciones compensatorias y actualiza la
  proyección vigente de manga, OT, salida y lote;
- solo se permite mientras la manga está cerrada y pendiente de pesaje;
- después del pesaje o recepción se bloquea y exige un flujo físico coordinado
  con custodia, Inventario y, cuando corresponda, Calidad.

## Fuera de habilitación productiva

- reapertura física posterior al pesaje;
- política de planta para `USO_EN_PROCESO`, scrap y excedentes;
- perfil y Tipo de manga PT reales;
- UAT con una cadena física anonimizada.
