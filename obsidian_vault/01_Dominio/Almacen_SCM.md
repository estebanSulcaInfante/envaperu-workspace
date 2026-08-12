---
tipo: modelo_objetivo
estado: propuesto-us-013
tags: [dominio, scm, almacen, ubicacion, seguridad, custodia]
relaciones:
  - "[[Inventario_SCM]]"
  - "[[Ubicacion_Inventario]]"
  - "[[Transferencia_Inventario]]"
  - "[[US-013A_Almacenes_Ubicaciones_y_Alcance_por_Trabajador]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# Almacén SCM

Frontera organizacional que posee responsables, ubicaciones, clases de
inventario admitidas y reglas de operación. No es un texto decorativo ni una
ubicación de tránsito.

## Configuración e identidad mínima

No existe un catálogo real previo que deba codificarse en migración. La primera
configuración autorizada crea la jerarquía desde UI/API. Las semillas técnicas
solo pueden crear capacidades, nunca inventar almacenes físicos productivos.

- `id`, `codigo`, `nombre` y `tipo`;
- estado activo/versionado;
- clases de inventario admitidas;
- ubicación de recepción, staging y devolución predeterminadas;
- política de pickup/entrega;
- punto de pickup predeterminado opcional;
- responsable y zona horaria de planta.

Tipos iniciales: `MATERIAS_PRIMAS`, `PIEZAS_WIP`, `PRODUCTO_TERMINADO` y
`GENERAL_CONTINGENCIA`. El tipo orienta la experiencia, pero no reemplaza las
compatibilidades explícitas.

## Alcance del trabajador

`AsignacionAlmacenTrabajador` vincula trabajador, almacén, clases admitidas y
vigencia. No concede una acción por sí sola: para leer o ejecutar se requiere
la capacidad correspondiente y un alcance vigente.

Una jefatura puede recibir alcance transversal de consulta sin recibir
capacidad de movimiento. Un almacenero puede operar más de un almacén sin que
su nombre de rol cambie.

## Invariantes

1. Una ubicación operativa pertenece como máximo a un almacén responsable.
2. Tránsito y puntos productivos no se presentan como stock libre de almacén.
3. Desactivar un almacén conserva historia, pero bloquea nuevas operaciones.
4. Toda operación valida capacidad y alcance en backend.
5. El supervisor transversal consulta; no adquiere custodia por consultar.
6. Ningún código de ejemplo (`ALM-PIEZAS`, `ALM-MP`, `ALM-PT`) es obligatorio;
   unicidad, actividad y compatibilidad sí lo son.
