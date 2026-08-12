---
tipo: user-story
estado: sustituida-parcialmente
tags: [catalogo, frontend, backend, bom, productos]
relaciones: 
  - "[[US-002_Refactor_CRUD_Molde_Pieza_Producto]]"
  - "[[TS-013_Codigos_Correlativos_Automaticos_Catalogo]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
fecha_actualizacion: 2026-08-10
---

# US-003: Creación Manual y Gestión de BOM de Productos Terminados

> [!IMPORTANT] Continuidad de alta
> El CRUD individual continúa siendo válido para crear o mantener la identidad de un PT. [[US-012_Alta_Guiada_Integral_de_ProductoTerminado|US-012]] pasa a ser la experiencia principal para una alta desde cero y orquesta después la estructura revisionada de US-010R.

> [!IMPORTANT] Decisión posterior aprobada
> “Creación manual” se refiere a seleccionar los datos y construir la BOM. Según [[TS-013_Codigos_Correlativos_Automaticos_Catalogo|TS-013]], el SKU `PT-NNNNNN` es asignado por el backend y no se escribe en el formulario ordinario.

> [!IMPORTANT] Estructura multinivel posterior
> La BOM plana `ProductoTerminado -> PiezaColor` y la tabla `producto_pieza`
> descritas en los criterios originales corresponden al primer corte.
> [[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque|US-010R]] las sustituyó
> como fuente canónica por `RevisionEstructuraArticulo`, capaz de consumir
> también WIP WIP. Desde el corte `f46`, el CRUD del maestro crea solo
> la identidad; la BOM se administra en Ingeniería SCM.

> [!IMPORTANT] Identidad normalizada aprobada
> `cod_producto` no forma parte de `ProductoTerminado`. Era un componente
> numérico del SKU legacy y fue retirado. El alta mínima vigente exige nombre,
> Línea y Familia; `cod_sku_pt` se asigna automáticamente como `PT-NNNNNN`.

## 1. Contexto
Actualmente, el sistema permite crear Productos Terminados (Kits o Assemblies) automáticamente mediante el Wizard de Creación Ágil. Sin embargo, no existe una forma **manual** e intuitiva desde el Catálogo de Productos (`ProductosAdmin.jsx`) para crear un `ProductoTerminado` desde cero, ni para construir su Receta de Componentes o *BOM* (asignarle una o varias `PiezaColor` con sus respectivas cantidades).

## 2. Actores
*   **Administrador de Sistema / Gestor de Catálogo:** Es el responsable de crear Productos Terminados y vincularles los SKUs físicos (`PiezaColor`) que componen el producto de venta; el código del PT se asigna automáticamente.

## 3. Criterios de Aceptación
1. **Creación de identidad:** nombre, Línea y Familia son obligatorios; el
   backend genera `cod_sku_pt`. No se solicita `cod_producto`.
2. **Referencias opcionales:** peso, presentación, unidad comercial, marca y
   código de barras pueden completarse sin formar parte de la identidad.
3. **Gestión de BOM:** se realiza en Ingeniería SCM mediante una revisión de
   estructura; requiere validación y aprobación antes de usarse en planificación.
4. **Errores accionables:** el formulario identifica los campos incompletos o
   inválidos y la API devuelve error, código y campo cuando aplica.
