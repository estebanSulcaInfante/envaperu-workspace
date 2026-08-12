---
tipo: mapa_dominio
estado: activo
tags: [dominio, maestros, cobertura, US-010A, US-010R]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-08-04
---

# Mapa de maestros

Este documento delimita qué opciones de **Datos maestros** son entidades persistidas y cuáles siguen siendo configuración visual pendiente de contrato.

| Área de la interfaz | Modelo canónico | Persistencia actual | Documento |
| :--- | :--- | :---: | :--- |
| Productos y BOM | `ProductoTerminado`, `ProductoPieza` | Sí | [[ProductoTerminado]] |
| Piezas y SKU físico | `Pieza`, `PiezaColor` | Sí | [[Pieza]], [[PiezaColor]] |
| Artículos SCM y estructuras multinivel | `ArticuloSCM`, `RevisionEstructuraArticulo` | No; modelo objetivo | [[Articulo_SCM]] |
| Rutas y operaciones | `RevisionRutaProducto`, `OperacionRuta` | No; modelo objetivo | [[Ruta_Produccion]] |
| WIP WIP | `DefinicionWIP`, `LoteWIP` | No; modelo objetivo | [[Lote_WIP]] |
| Tipos de manga y reglas de empaque | `TipoContenedor(clase=MANGA)`, `PerfilEmpacable`, `ReglaEmpaqueRevision` | No; configurar durante el piloto | [[Tipo_Manga]], [[Perfil_Empaque]] |
| Moldes y cavidades | `Molde`, `MoldePieza` | Sí | [[Molde]], [[MoldePieza]] |
| Líneas y familias | `Linea`, `Familia`, `LineaFamilia` | Sí | [[Linea]], [[Familia]], [[LineaFamilia]] |
| Sesión de alta guiada | `ScmAltaProductoSesion` | No; propuesta TS-017A | [[Sesion_Alta_Producto]] |
| Colores | `FamiliaColor`, `ColorBase`, `ColorProduccion` | Sí | [[FamiliaColor]], [[ColorBase]], [[Color_Produccion]] |
| Recetas | `RecetaColorMaestra`, `RecetaColorLinea` | Sí | [[RecetaColorMaestra]] |
| Materias primas y colorantes | `ScmMaterial` | Sí | [[MaterialSCM]] |
| Proveedores | `ScmProveedor` | Sí | [[ProveedorSCM]] |
| Categorías de recepción | `ScmCategoriaRecepcion` | Sí | [[CategoriaRecepcionSCM]] |
| Máquinas, trabajadores y roles | `Maquina`, `Trabajador`, `RolOperativo` | Sí | [[Maquina]], [[Trabajador]], [[RolOperativo]] |
| Ubicaciones | Sin modelo canónico | No; prototipo | Pendiente de contrato CRUD |
| Motivos | Sin modelo canónico | No; prototipo | Pendiente de contrato CRUD |
| Políticas y tolerancias | Sin modelo canónico | No; prototipo | Pendiente de contrato y gobierno |

## Límites importantes

- Las cavidades y el peso operativo pertenecen a [[MoldePieza]], no a [[Pieza]] ni a [[PiezaColor]].
- El color físico de una salida se expresa en [[PiezaColor]]; `ProductoTerminado` no guarda un color único.
- La imagen de una pieza pertenece a [[PiezaColor]]. [[Pieza]] no tiene fotografía porque representa una forma abstracta.
- En moldes de múltiples salidas, un color solo está habilitado si existe cobertura completa de [[PiezaColor]] para todas las asociaciones activas de [[MoldePieza]].
- `ProductoPieza` expresa la BOM plana actualmente persistida. [[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque|US-010R]] la sustituye como fuente canónica por una estructura revisionada de artículos que admite WIP.
- Una manga no se relaciona directamente con `PiezaColor`: [[Tipo_Manga]] gobierna sus propiedades físicas y [[Perfil_Empaque]] separa geometría y capacidad por artículo.
- `RecetaColorMaestra` es la receta gobernada. [[Receta_Colorantes]] conserva la fotografía aplicada a una OP y `RecetaColorNormalizada` es información histórica/analítica.
- `ScmMaterial.unidad_base` se persiste en `KG`; la UI puede capturar y mostrar colorantes en gramos realizando la conversión explícita.

## Pendiente funcional, no documental

Ubicaciones, motivos y políticas aparecen en la navegación para validar la experiencia, pero no deben presentarse como CRUD conectado hasta definir sus entidades, reglas y endpoints. Los nuevos maestros de US-010R tampoco deben mostrarse como persistidos hasta aprobar su Tech Spec e implementación.
