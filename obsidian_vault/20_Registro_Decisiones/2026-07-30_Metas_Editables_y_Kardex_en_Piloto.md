---
tipo: decision
estado: aceptada
fecha: 2026-07-30
tags: [scm, planificacion, kardex, inventario, piloto]
relaciones:
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[Inventario_SCM]]"
---

# Metas editables y Kardex en el piloto

## Contexto

Sin Kardex, la explosión de una OP propone fabricar y armar el máximo
necesario para cubrir toda la demanda. Durante el arranque existen piezas y
productos físicos que aún no están en el sistema, y Planificación necesita
ajustar metas sin falsificar el pedido.

## Decisión

1. Separar `cantidad_calculada` de `cantidad_objetivo`.
2. Permitir ajustes previos a confirmación con motivo obligatorio.
3. Crear una nueva revisión del plan por ajuste.
4. Incorporar Kardex normalizado al piloto con existencia, reserva y saldo
   libre.
5. Cargar el inventario de arranque como `SALDO_INICIAL` por artículo, sin
   inventar mangas o lotes.
6. Confirmar plan reserva stock; no lo consume.
7. Mantener pendiente la recepción QR de mangas de US-010I.

## Consecuencias

- el cálculo automático sigue siendo explicable y reproducible;
- la decisión humana queda separada y auditada;
- dos OP no pueden comprometer el mismo saldo libre;
- los pesajes legacy permanecen intactos;
- antes de desplegar se debe migrar y cargar el inventario inicial.
