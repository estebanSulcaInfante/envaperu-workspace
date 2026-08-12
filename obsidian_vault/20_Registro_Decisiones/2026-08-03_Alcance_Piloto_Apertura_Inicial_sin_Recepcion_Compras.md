---
tipo: decision
estado: aprobada
fecha: 2026-08-03
tags: [scm, piloto, alcance, kardex, inventario-inicial, recepcion]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[US-010E_Molienda_y_Material_Recuperado_Trazable]]"
  - "[[Alcance_Nuevo_Piloto_SCM_2026-08]]"
---

# Alcance del nuevo piloto: apertura inicial sin recepción de compras

## Decisión

El nuevo piloto no incluye la recepción completa de compras de materia prima de
US-010A. El circuito comienza con un inventario físico de corte y movimientos
de `APERTURA_INICIAL`; no se inventan OC, guías, proveedores ni lotes externos
para justificar existencias legacy.

No existe información digital legacy de Kardex que deba migrarse. Se retiran
la API `/api/kardex/*` y sus proyecciones `InventarioManga` y
`MovimientoKardex`; el SCM normalizado es la única autoridad de inventario.
Esta decisión no elimina ni reescribe los pesajes históricos.

La apertura inicial es una fuente legítima y auditable del Kardex, diferente de
una recepción de compra. Toda corrección posterior es compensatoria y conserva
el movimiento original.

## Objetivo del piloto

Validar una cadena cerrada desde inventario inicial hasta mangas de producto
terminado almacenadas:

`conteo -> Kardex -> OP -> OF/OA -> reserva/emisión -> OT/mangas -> pesaje -> recepción -> abastecimiento interno -> armado -> manga PT -> pesaje -> recepción PT`.

## Relación con planificación

- La OP calcula cobertura con PT, WIP y piezas disponibles.
- La ausencia de materia prima no impide crear ni aprobar la OP.
- La OF calcula requerimientos de materia prima y valida disponibilidad al
  reservar o liberar ejecución.
- Un faltante se muestra de forma explícita; no se convierte en saldo ficticio.

## Molienda

La molienda es una transformación interna y no depende de la recepción de
compras. En el primer recorrido se registra, pesa, clasifica y almacena la merma
recuperable. La ejecución completa de molienda puede probarse en un segundo
recorrido específico o antes si la OP elegida requiere material recuperado.

El material recuperado existente al corte puede ingresar mediante
`APERTURA_INICIAL`, identificado como tal y sin atribuirle una procedencia que no
pueda demostrarse.

## Restricciones de la apertura

1. Solo actores con capacidad expresa pueden registrar el corte.
2. Debe conservar artículo, cantidad, unidad, ubicación, fecha, responsable y
   motivo.
3. La puesta en marcha debe agrupar movimientos en un lote de apertura
   revisable y aprobable con segregación de funciones.
4. Un saldo aprobado no se edita ni elimina.
5. Las compras posteriores no se registran como nuevas aperturas.
6. El piloto seleccionará OP compatibles con el stock físico contado para no
   usar la apertura como mecanismo recurrente de abastecimiento.

## Consecuencias

- US-010A permanece fuera del alcance de lanzamiento del nuevo piloto y se
  desarrollará después como entrada ordinaria de compras.
- La infraestructura común de Kardex, ubicaciones, Calidad y movimientos se
  reutiliza; no se crea un inventario paralelo para el piloto.
- El dispositivo QR y cualquier cliente móvil nuevo deben consumir los
  contratos `/api/scm/v1/*`; no se mantiene compatibilidad con `/api/kardex/*`.
- US-010B continúa siendo necesaria en un corte mínimo: requerimiento, reserva,
  emisión, devolución y, cuando aplique, premezcla.
- El lote de apertura controlada quedó implementado localmente con borrador,
  pegado tabular, revisión, aprobación segregada y aplicación atómica. Queda
  pendiente su UAT con el conteo físico y los actores reales del piloto.
