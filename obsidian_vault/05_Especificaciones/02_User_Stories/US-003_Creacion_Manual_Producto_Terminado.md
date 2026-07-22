---
tipo: user-story
estado: en-refinamiento
tags: [catalogo, frontend, backend, bom, productos]
relaciones: 
  - "[[US-002_Refactor_CRUD_Molde_Pieza_Producto]]"
  - "[[TS-013_Codigos_Correlativos_Automaticos_Catalogo]]"
---

# US-003: Creación Manual y Gestión de BOM de Productos Terminados

> [!IMPORTANT] Decisión posterior aprobada
> “Creación manual” se refiere a seleccionar los datos y construir la BOM. Según [[TS-013_Codigos_Correlativos_Automaticos_Catalogo|TS-013]], el SKU `PT-NNNNNN` es asignado por el backend y no se escribe en el formulario ordinario.

## 1. Contexto
Actualmente, el sistema permite crear Productos Terminados (Kits o Assemblies) automáticamente mediante el Wizard de Creación Ágil. Sin embargo, no existe una forma **manual** e intuitiva desde el Catálogo de Productos (`ProductosAdmin.jsx`) para crear un `ProductoTerminado` desde cero, ni para construir su Receta de Componentes o *BOM* (asignarle una o varias `PiezaColor` con sus respectivas cantidades).

## 2. Actores
*   **Administrador de Sistema / Gestor de Catálogo:** Es el responsable de crear Productos Terminados y vincularles los SKUs físicos (`PiezaColor`) que componen el producto de venta; el código del PT se asigna automáticamente.

## 3. Criterios de Aceptación
1.  **Creación de Producto:** El sistema debe permitir crear un `ProductoTerminado` manualmente, definiendo sus atributos básicos (Nombre, Línea, Familia, Familia de Color, Peso estimado); el backend genera el SKU del PT.
2.  **Gestión de BOM (Receta):** En la vista de creación o edición de un producto, debe existir un panel que permita buscar SKUs de `PiezaColor` y agregarlos al producto, definiendo la **cantidad** que se usa de cada pieza (ej. 1 tapa, 1 balde).
3.  **Persistencia:** La relación debe guardarse correctamente en la tabla intermedia `producto_pieza` asegurando la integridad relacional.
4.  **Actualización:** Al editar un producto existente, el usuario puede eliminar componentes del BOM o cambiar sus cantidades.
