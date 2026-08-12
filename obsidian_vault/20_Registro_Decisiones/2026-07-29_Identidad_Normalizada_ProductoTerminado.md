---
tipo: decision
estado: aprobada
tags: [producto-terminado, identidad, migracion, UX, US-010R]
relaciones:
  - "[[ProductoTerminado]]"
  - "[[Articulo_SCM]]"
  - "[[US-003_Creacion_Manual_Producto_Terminado]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
fecha: 2026-07-29
---

# Identidad normalizada de ProductoTerminado

## Decisión

El alta mínima de un `ProductoTerminado` contiene:

1. `cod_sku_pt` autogenerado como `PT-NNNNNN`;
2. nombre comercial obligatorio;
3. Línea;
4. Familia compatible con la Línea.

El artículo SCM `PRODUCTO_TERMINADO` con unidad base `UN` nace
automáticamente. Las referencias logísticas son opcionales. La composición no
se captura en el modal del maestro: se gobierna con una BOM revisionada y
aprobada en Ingeniería SCM.

## Retiro de `cod_producto`

`cod_producto` era un número heredado utilizado para concatenar el SKU del
catálogo anterior. Se elimina porque:

- `cod_sku_pt` ya es la identidad estable e inmutable;
- no aporta trazabilidad ni clasificación;
- conservar ambos permitiría identidades divergentes;
- los productos se migrarán al modelo normalizado.

La conservación legacy se limita a los pesajes históricos y sus números de OT.
No se usa el esquema antiguo de productos como segunda fuente maestra.

## Consecuencias

- migración `f46f9b7d1c20` elimina la columna y exige nombre no vacío;
- el detalle API devuelve IDs de clasificación y referencias editables;
- el formulario diferencia identidad obligatoria de logística opcional;
- los errores de validación indican el campo afectado;
- `producto_pieza` queda como adaptador transitorio de `/api/ordenes`; no se
  expone en el CRUD normalizado y se retirará al migrar esa validación a la BOM
  aprobada.
