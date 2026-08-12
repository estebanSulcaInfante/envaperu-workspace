---
tipo: draft
estado: refinado-como-us-013
tags: [scm, kardex, almacen, ubicaciones, custodia, picking, pickup, qr]
relaciones:
  - "[[US-013_Kardex_MultiAlmacen_Custodia_y_Operaciones_QR]]"
  - "[[Inventario_SCM]]"
  - "[[Ubicacion_Inventario]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# Kardex, almacenes, custodia, pickup y vistas especializadas

## Solicitud original

La recepción actual permite escanear una manga y elegir una ubicación, pero no
abre una operación ligada a un almacén de origen/destino ni prepara una cola de
varios QR. El Kardex es una vista general compartida; no existen espacios
especializados para Almacén de Materias Primas, Piezas/WIP y Producto Terminado.

Cuando una manga sale hacia Armado, el runtime vigente conserva el saldo usando
`TRANSITO_PRODUCCION` y después `MESA_ARMADO`. El hecho es correcto, pero
`TRANSITO` se expresa como si fuera una ubicación ordinaria y la interfaz no
expone con claridad origen, destino, custodio, entrega y recepción.

## Necesidad refinada

1. Modelar `Almacen` como frontera de responsabilidad y `UbicacionInventario`
   como lugar dentro de un almacén o punto operativo.
2. Mantener una existencia en tránsito dentro del inventario físico de la
   empresa, pero fuera del saldo libre de cualquier almacén.
3. Diferenciar reserva, picking, staging, pickup/despacho, tránsito, recepción,
   consumo y retorno.
4. Permitir una sesión operativa con origen, destino y 1..N QR antes de
   confirmar el lote.
5. Asignar a los trabajadores alcances por almacén y clase de inventario,
   además de capacidades por acción.
6. Ofrecer vistas especializadas sobre un único Kardex y un control transversal
   para jefaturas.

## Aclaraciones de planta 2026-08-11

- No existe nomenclatura ni jerarquía real previa: debe ser configurable.
- El solicitante de Armado normalmente recoge personalmente en Almacén.
- Confirmar pickup acredita directamente `MESA_ARMADO` y transfiere custodia;
  no registra consumo.
- Diferencias y mangas pesadas sin recepción durante 24 horas aparecen en
  Control/Alertas.

## Riesgos que no deben ocultarse

- no convertir `TRANSITO` en un almacén físico ficticio;
- no borrar ni reescribir movimientos históricos de US-010H/US-010I;
- no confundir pickup con consumo;
- no duplicar el Kardex por tipo de almacenero;
- no confiar en filtros del frontend como seguridad de datos;
- no acreditar destino antes de la recepción física;
- no dejar una transferencia sin responsable, origen, destino o timeout
  operativo visible.

## Resultado del refinamiento

La solicitud se convierte en [[US-013_Kardex_MultiAlmacen_Custodia_y_Operaciones_QR|US-013]]
y sus hijas A/B/C. La autorización de desarrollo requiere aprobar las Tech Specs
TS-018A/B/C; este draft no autoriza migraciones ni despliegue.
