---
tipo: decision_dominio
estado: aceptada
fecha: 2026-08-07
tags: [scm, rutas, soplado, fabricacion, uat]
relaciones:
  - "[[Ruta_Produccion]]"
  - "[[Vista_US-010R_Ingenieria_SCM]]"
  - "[[Plan_Cierre_UAT_y_Marcha_Blanca_2026-08]]"
---

# Soplado como operación de fabricación

## Contexto

La UAT de Alcancía Pablo Grande detectó que el producto se fabrica por soplado,
pero Ingeniería SCM solo permitía declarar `INYECCION` como proceso de máquina.
Usar inyección como sustituto habría falseado la ruta y la evidencia operativa.

## Decisión

`SOPLADO` se incorpora como tipo canónico de centro de trabajo y operación de
ruta. Es una operación de fabricación y, por tanto, se ejecuta mediante OF/OT
con `executor_kind = OP_OT`, igual que inyección en cuanto a autoridad
documental, pero conservando su identidad industrial propia.

Las bases existentes se amplían mediante migración sin modificar rutas de
inyección. La interfaz ofrece **SOPLADO** tanto al crear centros como al
configurar operaciones.

## Consecuencias

- La ruta de Alcancía Pablo puede representar el proceso real.
- Planificación clasifica la operación como propuesta de OF porque la autoridad
  sigue siendo `OP_OT`.
- No se crean equivalencias silenciosas entre inyección y soplado.
- Una eventual reversa de la migración normaliza registros de soplado a
  inyección únicamente para poder restaurar la restricción técnica anterior;
  dicha reversa no forma parte de la operación normal.

## Verificación

- prueba de servicio: creación de centro `SOPLADO` y publicación directa de una
  ruta de fabricación;
- prueba de interfaz: creación del centro seleccionando `SOPLADO`;
- prueba de migración: ambas restricciones admiten el nuevo tipo y el árbol de
  Alembic conserva una única cabeza.
