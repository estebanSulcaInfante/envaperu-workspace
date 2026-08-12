---
tipo: especificacion
subtipo: approved_for_dev
estado: implementado-local-pendiente-uat
tags: [scm, US-010C, ot, mangas, prepesaje, impresion]
fecha_aprobacion: 2026-07-28
fecha_actualizacion: 2026-07-28
---

# DEV-010C: OT central, mangas y etiqueta de prepesaje

## Referencias

- Historia: [[../02_User_Stories/US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]]
- Tech Spec: [[../03_Tech_Specs/TS-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje|TS-010C]]
- Base: [[DEV-010R_R-Core_Articulos_BOM_Rutas_y_Empaque]]

## Autorización y restricciones

Desarrollo autorizado el 2026-07-28, únicamente en entorno local.

- No tocar la base desplegada.
- No convertir OP legacy al modelo normalizado.
- Preservar todos los pesajes históricos del módulo autónomo.
- No inventar moldes, capacidades ni timestamps históricos.
- Crear roles y capacidades, pero no asignarlos automáticamente a personas.
- Obtener el contrato físico inicial de la impresión productiva existente.

## Resultado implementado

- `RegistroDiarioProduccion` evolucionado como OT canónica central.
- Backfill conservador `OT-LEGACY-{id}` para filas anteriores.
- Plan agregado por OP, asignación diaria, mangas normales y extras.
- Correlativos centrales de OT y por-OT de manga.
- Anulación de manga y reemplazo de etiqueta autorizados por JP.
- Trabajo de impresión con una o dos identidades distintas.
- Adaptador local TSPL `PREPESAJE_TSPL_1` de `109 × 50 mm`, `GAP 3 mm`,
  203 DPI, columnas X `24/464`.
- Evidencia local append-only y acuse técnico central.
- UI central `Producción > OT y mangas` con inicio/cierre, mangas normales,
  solicitud/aprobación extra, anulación y reemplazo; UI local `Etiquetas SCM`.
- Pruebas de idempotencia, compatibilidad legacy, migraciones, plan
  `100/100/50`, 2-up, columna impar y reintento sin emisión.

## Puertas restantes

- [ ] Imprimir físicamente 1 y 2 mangas y validar alineación/QR.
- [ ] Simular falla confirmada e incierta con la impresora piloto.
- [ ] Ejecutar el flujo con la primera OP real creada en el modelo normalizado.
- [ ] Asignar roles a usuarios del piloto antes de habilitar operación humana.
- [ ] Desarrollar TS-010D para captura de peso y etiqueta postpesaje.

Estas puertas impiden declarar producción, pero no invalidan el incremento local
de TS-010C.
