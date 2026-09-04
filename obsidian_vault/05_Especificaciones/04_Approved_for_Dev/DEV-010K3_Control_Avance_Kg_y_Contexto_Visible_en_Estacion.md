---
tipo: approved-for-dev
estado: implementado-local-qa-green-uat-ux-rejected
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: rejected
physical_uat: pending
release_constraint: no_habilitar_en_planta
historia: "[[US-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
tech_spec: "[[TS-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
fecha_aprobacion: 2026-08-31
fecha_actualizacion: 2026-09-03
tags: [dev, scm, pesaje, avance-kg, ui, tdd]
---

# DEV-010K3: control de avance en kg y contexto visible

## Autoridad y alcance

La prueba y validaciones del responsable funcional del 2026-08-31 autorizan
registrar la decisión y corregir el incremento local. No autorizan migración
productiva, recuperación destructiva de controles existentes ni despliegue de
la estación.

- [x] Migración aditiva/compatible `AVANCE_KG` sin conteo.
- [x] Central mantiene manga/tramo activos y admite controles repetidos.
- [x] Payload de imagen opcional sin base64.
- [x] Estación usa checkbox + un botón/F2.
- [x] Foco vuelve al lector y anuncia cambio de manga.
- [x] Código de manga dominante y foto/fallback.
- [x] Identidad de contenido con nombre y muestra de color; patrón accesible
  para Transparente y HEX maestro para sólidos.
- [x] Sticker de avance sin conteo/estándar/QR.
- [x] Pruebas, builds, evidencia visual, UAT y recibo.

## Hallazgo UAT posterior — 2026-09-03

El backend respetó la intención enviada, pero el usuario omitió dos veces el
checkbox **Control de peso** y F2 ejecutó cierres finales accidentales. La
segunda ocurrencia sucedió incluso después de una reapertura guiada. Se conserva
`functional_validation: qa_green`, pero la interacción actual queda
`ux_validation: rejected` y no debe habilitarse en planta hasta implementar y
revalidar una protección explícita del cierre final con la acción única.

## BASELINE registrado

- estación backend: `139 passed`;
- Central focal: `9 passed, 40 deselected`;
- estación UI `ScmWeighing`: `10 passed`;
- un intento inicial de la suite Central desde el directorio raíz falló por
  `ModuleNotFoundError: app`; se corrigió ejecutando desde `backend` y no es un
  fallo del producto.

## Secuencia RED → GREEN → REFACTOR

1. RED migración/modelo: demostrar que `AVANCE_KG` y varios controles por tramo
   hoy son rechazados.
2. GREEN dominio/migración y compatibilidad con `CORTE_TURNO`.
3. RED servicio: avance sin conteo no debe cerrar tramo/Trabajo.
4. GREEN servicio, contrato de resolución e imagen.
5. RED estación backend: payload no contiene conteo/motivo manual.
6. GREEN coordinador local e impresión idempotente.
7. RED UI: un botón, checkbox, foco, anuncio, correlativo y foto.
8. GREEN/REFACTOR UI y estilos.
9. RED/GREEN renderer `CONTROL_PESO_TSPL_2`.
10. Regresión, builds, contrato, visual y UAT.
11. RED/GREEN aditivo para identidad estructurada de color y representación
    Transparente, sin mutar snapshots ni estados de manga.

## Guardas

- No inferir unidades desde kg.
- No convertir avance en `CORTE_TURNO` ni pausar Trabajo.
- No perder compatibilidad de replays/históricos K1/K2.
- No sumar netos acumulados.
- No duplicar control o impresión por doble acción.
- No usar base64 para fotos ni bloquear si faltan.
- No sobrescribir cambios ajenos del worktree.
- No desplegar ni declarar listo para planta.

## Criterio de salida local

- pruebas focales y regresión proporcional verdes;
- migración upgrade/downgrade verificada;
- captura de estados inicial, QR resuelto, avance listo, éxito, cambio de manga
  y foto ausente/existente;
- UAT K3 preparada, no autoaceptada;
- recibo con riesgos y rollback.

## Resultado local

Cumplido el 2026-08-31. Ver
[[REC_2026-08-31_Control_Avance_Kg_y_Contexto_Visible_Estacion]] y
[[UAT_US-010K3_Control_Avance_Kg_y_Contexto_Visible]]. La publicación, la UAT
humana y la prueba física permanecen pendientes.

El incremento visual del 2026-09-03 quedó en UAT local sin reset. Ver
[[REC_2026-09-03_Identidad_Visual_Color_Estacion_Pesaje]]. La revisión humana
del patrón, contraste y reconocimiento desde el puesto continúa pendiente.
