---
tipo: decision
estado: implementada-en-uat-local
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
fecha_creacion: 2026-09-03
fecha_actualizacion: 2026-09-04
tags: [pesaje, qr, kg, reapertura, linea-base]
relaciones:
  - "[[2026-09-03_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
  - "[[US-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]]"
---

# Escaneo único por pesaje y reapertura con línea base

## Decisión

1. Resolver una preetiqueta crea una intención temporal para un solo pesaje.
2. Un control o cierre aceptado consume esa intención. F2 queda bloqueado hasta
   resolver otra vez un QR; cambiar la lectura de balanza no vuelve a habilitarlo.
3. El éxito conserva visible el resultado y devuelve el foco al lector con la
   instrucción de retirar la manga y escanear la siguiente. Reescanear el mismo
   QR es válido si la manga sigue abierta.
4. Un error sin acuse conserva la misma operación para replay idempotente y no
   se presenta como éxito.
5. En Fabricación simple, la pantalla usa NET, último NET aceptado, diferencia y
   peso fabricado teórico en kg. Las UN no se presentan como conteo físico ni se
   solicitan para cierre parcial en esta estación.
6. `CIERRE_ACCIDENTAL` conserva el final solo como historia y no como referencia.
7. `CONTINUAR_LLENADO` conserva el final como historia y congela su NET como
   línea base. El siguiente control/final debe superarlo y su aporte es la
   diferencia contra esa base.
8. La reapertura sigue siendo de Central, exige permiso, motivo, versión e
   idempotencia; no se permite después de recepción sin reversa.

## Consecuencia

La reapertura deja de ser exclusivamente sinónimo de error. El tipo y la línea
base quedan auditados de manera explícita. El cierre anterior nunca desaparece.
La postetiqueta anterior se invalida en ambos casos y debe retirarse o marcarse.

## Restricción

La aprobación del responsable autoriza implementación y QA local mediante el
pipeline. No constituye validación UX representativa ni UAT física; se conserva
`no_habilitar_en_planta`.
