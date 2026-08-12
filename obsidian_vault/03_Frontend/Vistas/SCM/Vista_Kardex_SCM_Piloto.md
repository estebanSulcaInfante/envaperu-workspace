---
tipo: componente-ui
estado: implementado-local
ruta: /produccion/kardex
tags: [frontend, scm, inventario, kardex]
relaciones:
  - "[[Inventario_SCM]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
fecha_actualizacion: 2026-07-30
---

# Vista Kardex SCM del piloto

Pantalla orientada a Almacén, Planificación, JP y consulta.

## Presenta

- totales de existencia física, reservada y libre;
- saldos por artículo SCM y ubicación;
- búsqueda por código, nombre o ubicación;
- últimos movimientos con actor, fecha y motivo.

## Acciones por capacidad

- `INVENTARIO_VER`: consulta;
- `INVENTARIO_SALDO_INICIAL`: carga de conteo de arranque;
- `INVENTARIO_AJUSTAR`: ajuste positivo/negativo.

El formulario exige artículo, cantidad, ubicación y motivo. No permite editar
ni borrar movimientos.
