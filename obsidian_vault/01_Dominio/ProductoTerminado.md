---
tipo: modelo_bd
tabla: producto_terminado
estado: activo
tags: [dominio, maestro, producto, BOM, TS-007, US-010R]
relaciones:
  - "[[Articulo_SCM]]"
  - "[[Ruta_Produccion]]"
  - "[[Orden_Armado]]"
  - "[[Orden_Operacion]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Presentacion_Comercial]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-08-06
---

# ProductoTerminado

Maestro del SKU comercial que se planifica en una [[Orden_Produccion]]. Se clasifica por [[Linea]] y [[Familia]], pero no posee un color único: sus salidas físicas se definen mediante la BOM.

## Campos esenciales

| Campo | Regla |
| :--- | :--- |
| `cod_sku_pt` | Identidad estable `PT-NNNNNN`, correlativa y autogenerada por el backend. Es inmutable. |
| `producto` | Nombre comercial obligatorio y no vacío. |
| `linea_id`, `familia_id` | La combinación debe estar habilitada en [[LineaFamilia]]. |

Al crear el producto, el sistema genera también su subtipo 1:1 en
[[Articulo_SCM]] con unidad base `UN`. Esos cuatro datos —SKU automático,
nombre, línea y familia— forman el alta mínima. Peso referencial y marca son
referencias opcionales y no cambian la identidad. La unidad base SCM es `UN`.

Los campos heredados `doc_x_paq` y `doc_x_bulto` se conservan en base de datos y
API por compatibilidad con registros e importaciones anteriores, pero no se
capturan en el alta o edición normal del producto terminado ni gobiernan el
flujo SCM. La capacidad operativa de empaque tiene una única fuente de verdad:
el tipo de contenedor, el perfil empacable del artículo y su regla de empaque
aprobada. Packs, juegos y códigos de barras se modelan mediante
[[Presentacion_Comercial]], sin duplicar la BOM.

`cod_producto` fue eliminado del modelo en la migración `f46f9b7d1c20`.
Era un número heredado usado para construir SKUs legacy; mantenerlo junto al
correlativo estable habría creado una segunda identidad sin función SCM.

## Estructura/BOM revisionada y multinivel

`ProductoTerminado` posee un subtipo 1:1 dentro de [[Articulo_SCM]]. Su composición canónica es una `RevisionEstructuraArticulo` cuyo artículo resultado es ese producto.

Los componentes pueden ser:

- [[PiezaColor]] cuando se incorpora una pieza suelta;
- un artículo `SUBENSAMBLE_WIP` cuando una operación previa ya unió componentes;
- otro artículo permitido por una evolución aprobada del dominio.

Esto permite, por ejemplo:

```text
ProductoTerminado Balde Completo
├── WIP Balde con Asa
│   ├── PiezaColor Cuerpo
│   └── PiezaColor Asa
└── PiezaColor Tapa
```

`ProductoPieza`, `RevisionBOMProducto` y `RevisionBOMProductoPieza` permanecen
como adaptador transitorio para `/api/ordenes`, que todavía valida la OP
excepcional con la composición plana. El alta/edición normal del maestro no la
expone: las composiciones nuevas se crean, versionan y aprueban en
**Ingeniería SCM** mediante `RevisionEstructuraArticulo`. El adaptador se retira
cuando ese endpoint consuma la estructura aprobada.

Restricciones:

- toda cantidad es positiva y usa una unidad compatible;
- una revisión aprobada es inmutable;
- la pareja `revision_id + articulo_componente_id` es única;
- la aprobación rechaza autorreferencia y ciclos transitivos;
- no se infiere el color desde el producto;
- OP y [[Orden_Operacion]] congelan revisión, `content_hash` y snapshot legible.

No se migra `PiezaColor.tipo=KIT` hacia producto terminado porque EnvaPerú confirmó que nunca existieron datos operativos de esos kits. El retiro exige preflight vacío y falla ante cualquier fila inesperada.

## Ruta

La estructura responde qué contiene el producto. [[Ruta_Produccion]] responde qué operaciones generan piezas, WIP y resultado final. Una nueva OP congela ambas revisiones; cambiar cualquiera de ellas no reescribe ejecuciones anteriores.

## Relaciones

- **Composición:** artículos SCM mediante estructura revisionada multinivel; `ProductoPieza` es un adaptador transitorio del endpoint excepcional.
- **Clasificación:** [[Linea]] y [[Familia]].
- **Consumidor:** [[Orden_Produccion]].
- **Plan de proceso:** [[Ruta_Produccion]].
- **Ejecución física:** [[Orden_Operacion]]; [[Orden_Armado]] permanece como especialización funcional.
- **Lote final:** [[Lote_Producto_Terminado]].
