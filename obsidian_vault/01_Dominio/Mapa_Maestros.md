---
tipo: mapa_dominio
estado: activo
tags: [dominio, maestros, cobertura, US-010A]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# Mapa de maestros

Este documento delimita qué opciones de **Datos maestros** son entidades persistidas y cuáles siguen siendo configuración visual pendiente de contrato.

| Área de la interfaz | Modelo canónico | Persistencia actual | Documento |
| :--- | :--- | :---: | :--- |
| Productos y BOM | `ProductoTerminado`, `ProductoPieza` | Sí | [[ProductoTerminado]] |
| Piezas y SKU físico | `Pieza`, `PiezaColor` | Sí | [[Pieza]], [[PiezaColor]] |
| Moldes y cavidades | `Molde`, `MoldePieza` | Sí | [[Molde]], [[MoldePieza]] |
| Líneas y familias | `Linea`, `Familia`, `LineaFamilia` | Sí | [[Linea]], [[Familia]], [[LineaFamilia]] |
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
- La composición del producto se expresa mediante `ProductoPieza` dentro de [[ProductoTerminado]].
- `RecetaColorMaestra` es la receta gobernada. [[Receta_Colorantes]] conserva la fotografía aplicada a una OP y `RecetaColorNormalizada` es información histórica/analítica.
- `ScmMaterial.unidad_base` se persiste en `KG`; la UI puede capturar y mostrar colorantes en gramos realizando la conversión explícita.

## Pendiente funcional, no documental

Ubicaciones, motivos y políticas aparecen en la navegación para validar la experiencia, pero no deben presentarse como CRUD conectado hasta definir sus entidades, reglas y endpoints.
