---
tipo: draft
estado: promovido-a-us-010k8
fecha_creacion: 2026-09-03
fecha_actualizacion: 2026-09-04
tags: [pesaje, qr, kg, reapertura, seguridad-operativa]
relaciones:
  - "[[Feedback_Pesaje_y_Cierre_Kg_sin_Conteo]]"
  - "[[US-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]]"
---

# Identidad de un solo uso en Pesaje y reapertura con línea base

## Evidencia aportada

Durante la UAT local del 2026-09-03 se identificó que, después de aceptar un
`AVANCE_KG`, la estación conserva armado el mismo QR. Si se retira la manga A,
se coloca físicamente la manga B y no se escanea B, un segundo F2 puede registrar
el peso bajo A. Un umbral de diferencia no resuelve el error de identidad.

La vista resuelta conserva además elementos del contrato anterior en unidades:
cantidad teórica como dato principal, cierre parcial por «unidades reales» y
resultado/atribución en UN, aunque la dirección funcional vigente para
Fabricación es kg sin conteo humano confiable.

También se aclaró que una reapertura no borra el final: lo conserva como hecho
`REABIERTO`. Falta distinguir si ese final fue una lectura accidental que no
debe usarse o un cierre correcto después del cual se añadió material y que sí
debe actuar como línea base del siguiente aporte.

## Decisión funcional del responsable

- Cada resolución QR habilita exactamente un envío exitoso; después se exige
  volver a escanear, incluso si se pesa nuevamente la misma manga.
- La manga puede seguir `EN_LLENADO`; el bloqueo posterior pertenece a la
  sesión de estación, no equivale a cerrar el objeto de negocio.
- La vista de Fabricación abierta prioriza kg y no solicita unidades reales.
- Central distingue `CIERRE_ACCIDENTAL` y `CONTINUAR_LLENADO`.
- Ambos conservan el final en historia e invalidan la postetiqueta vigente.
- Solo `CONTINUAR_LLENADO` conserva el NET final anterior como línea base.
- No se fija una tolerancia nueva en gramos en este incremento.
