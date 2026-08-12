---
tipo: tech-spec
estado: implementado-local-pendiente-uat
historia: "[[US-010B_Reserva_Emision_Materiales_OP]]"
tags: [scm, materiales, reserva, emision, premezcla, postgres]
fecha_creacion: 2026-08-03
fecha_actualizacion: 2026-08-08
---

# TS-010B: Reserva, emisión y premezcla de materiales

## Objetivo

Implementar el tramo transaccional entre una OF liberada y el WIP de
premezcla, usando saldos de `APERTURA_INICIAL` durante el piloto. La recepción
de compras queda fuera; no existe Kardex digital legacy que migrar.

## Modelo persistente

| Entidad | Propósito |
|---|---|
| `scm_requerimiento_material` | Cantidad absoluta congelada por corrida, material y revisión de receta. |
| `scm_reserva_material` | Compromiso contra un saldo y control separado de emitido/consumido. |
| `scm_emision_material` | Traslado físico a Preparación, todavía separable. |
| `scm_devolucion_material` | Retorno compensatorio de material no incorporado. |
| `scm_lote_premezcla` | WIP identificable disponible para máquina. |
| `scm_lote_premezcla_input` | Genealogía entre el WIP y cada emisión incorporada. |

Migraciones: `f58a6b3c4d21` y `f59b7c4d5e32`.

## Reglas de cálculo

- resina base: kg estándar de salidas más runner de los ciclos;
- materia prima fraccionaria: `base_resina × fracción`;
- colorante/aditivo dosificado: `kg_virgen × dosis_g / base_kg / 1000`;
- cantidades normalizadas a tres decimales;
- solo una revisión de receta aprobada y resoluble genera requerimientos.

## Transacciones e invariantes

1. La reserva múltiple es atómica y bloquea saldos para evitar sobreasignación.
2. Reservar no modifica existencia física.
3. Emitir mueve físico y reservado a `PREPARACION_PRODUCCION`; no consume.
4. Devolver revierte custodia y no puede superar lo emitido separable.
5. Confirmar premezcla exige todos los componentes emitidos en proporción de
   receta, consume esos saldos y crea un WIP.
6. Un input consumido no puede devolverse posteriormente.
7. Todo comando usa `Idempotency-Key` y registra actor/evento.

## Capacidades

| Capacidad | Rol piloto |
|---|---|
| `MATERIAL_REQUERIMIENTO_GENERAR` | Jefe de Producción |
| `MATERIAL_RESERVAR` | Jefe de Producción |
| `MATERIAL_EMITIR` | Almacén de recepción/materiales |
| `MATERIAL_DEVOLVER` | Almacén de recepción/materiales |
| `MATERIAL_PREMEZCLA_CONFIRMAR` | Jefe de Producción |

Estas asignaciones son semillas del piloto; la autenticación y administración
final de permisos permanecen configurables.

## API y UI

Los contratos están en [[SCM_Materiales_OF_Reserva_Emision_Premezcla]]. La
vista canónica es `/materiales/preparaciones/:numeroOp` y consume la API SCM.
Los errores funcionales del backend se muestran en alertas y los comandos
irreversibles solicitan motivo.

## Evidencia automatizada

- `backend/tests/scm/test_scm_material_execution.py`;
- regresión conjunta con inventario piloto y OT: 11 pruebas verdes;
- `frontend/src/tests/PreparacionMateriales.spec.jsx`: 3 pruebas verdes;
- build Vite exitoso.

## Pendiente

- UAT con responsables reales de Producción y Almacén;
- validar ubicaciones y criterio de `CONJUNTO_CANDIDATOS`;
- consumo del WIP en máquina en US-010C;
- despliegue de migraciones solo después de aprobar UAT.

## Addenda US-010M — integración sin material preparado

- `scm_trabajo_color.corrida_fabricacion_id` es la unión con el contexto de
  requerimiento/reserva existente.
- La OT no duplica color, receta, material ni cantidades de la corrida.
- Pausar y reanudar A → B → A no vuelve a generar requerimientos.
- Este incremento no crea asignación o consumo de lote preparado por Trabajo de
  color; tampoco agrega mediciones de materiales.
- Cualquier consumo real futuro debe registrar su propia cantidad y actor; no
  se deriva del cupo de mangas ni del estado del trabajo.
