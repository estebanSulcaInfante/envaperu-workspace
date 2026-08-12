---
tipo: especificacion
subtipo: approved_for_dev
estado: implementado-local-pendiente-uat
fecha_actualizacion: 2026-08-03
tags: [scm, piloto, kardex, apertura-inicial, cutover]
relaciones:
  - "[[2026-08-03_Alcance_Piloto_Apertura_Inicial_sin_Recepcion_Compras]]"
  - "[[Inventario_SCM]]"
  - "[[Alcance_Nuevo_Piloto_SCM_2026-08]]"
---

# DEV-PILOTO: Apertura inicial controlada

## Resultado implementado

El piloto puede nacer desde un conteo físico sin simular compras ni recepciones
legacy. Almacén prepara un lote; un Jefe de Producción distinto lo aprueba; el
sistema aplica todo el lote o nada.

## Contrato operativo

1. Estados: `BORRADOR -> PENDIENTE_APROBACION -> APLICADO|RECHAZADO`.
2. Solo el creador modifica y envía el borrador.
3. El creador no puede resolverlo, aun si posee capacidad de aprobación.
4. Aprobar requiere evidencia/motivo y genera movimientos append-only.
5. Rechazar no modifica Kardex.
6. No se admite una segunda apertura aplicada para el mismo ítem/ubicación ni
   una apertura sobre un saldo físico no nulo.
7. Artículos se controlan en `UN`; materiales se controlan en `KG`.
8. `PENDIENTE` acredita existencia física, pero no saldo libre.

## Superficies

- API de lotes bajo `/api/scm/v1/inventario/aperturas`.
- Kardex ampliado con saldos y movimientos de materiales.
- Vista de Kardex con creación, pegado tabular, edición, envío y resolución por
  capacidades.
- Capacidades `INVENTARIO_APERTURA_PREPARAR` (Almacén) e
  `INVENTARIO_APERTURA_APROBAR` (Jefe de Producción).

## Evidencia técnica

- Migraciones `f55c3e0f9b68` y `f56d4f1a2c09` aplicadas y validadas en
  PostgreSQL local.
- Pruebas backend de segregación, atomicidad y disponibilidad por Calidad.
- Pruebas frontend de experiencia por actor y aprobación con evidencia.

## Pendiente de cierre

- Ejecutar UAT con actores, ubicaciones y hoja de conteo reales.
- Conciliar el total del lote aprobado contra la hoja física firmada.
- Respaldar la base antes del corte y prohibir nuevas aperturas como mecanismo
  ordinario de abastecimiento.
