---
tipo: tech-spec
estado: en-revision
tags: [catalogo, backend, frontend, bom, productos]
relaciones: 
  - "[[US-003_Creacion_Manual_Producto_Terminado]]"
  - "[[TS-013_Codigos_Correlativos_Automaticos_Catalogo]]"
---

# TS-003: Especificación Técnica - CRUD de Producto Terminado y BOM

> [!IMPORTANT] Código automático
> “Creación manual” describe la construcción interactiva del producto y su BOM, no la escritura del SKU. [[TS-013_Codigos_Correlativos_Automaticos_Catalogo|TS-013]] sustituye `cod_sku_pt` como entrada del alta: el backend asigna `PT-NNNNNN`, lo devuelve al confirmar y lo mantiene inmutable.

## 1. Objetivo Técnico
Proveer una interfaz y los endpoints REST correspondientes para crear y modificar un `ProductoTerminado` y su BOM (Bill of Materials) expresado mediante registros en la tabla `producto_pieza` (relación 1:N que asocia el Producto a las `PiezaColor` y define sus cantidades).

## 2. Modelos Afectados
*   **`ProductoTerminado`**: Representa el SKU de venta final.
*   **`ProductoPieza`**: Tabla asociativa. Posee `producto_terminado_id`, `pieza_sku` y `cantidad`.
*   **`PiezaColor`**: Entidad objetivo. Se buscará por nombre o SKU a través de un Autocomplete.

## 3. Cambios en Backend (`rutas_catalogo.py`)

### 3.1. `POST /api/productos` y `PUT /api/productos/<sku>`
Actualmente deben existir métodos pero requieren refactorizarse para soportar el envío del BOM anidado en el payload.

**Payload de Creación/Actualización:**
```json
{
  "producto": "Balde 20L Completo",
  "linea_id": 1,
  "familia_id": 2,
  "peso_g": 600,
  "precio_estimado": 15.5,
  "status": "Activo",
  "componentes": [
    { "pieza_sku": "MOL-BAL-01-ROJO", "cantidad": 1 },
    { "pieza_sku": "MOL-BAL-TAPA-ROJO", "cantidad": 1 }
  ]
}
```
**Lógica de Actualización:** 
1. Guardar metadatos de `ProductoTerminado`.
2. Para el BOM: Eliminar los `ProductoPieza` existentes para ese producto.
3. Insertar los nuevos registros en `ProductoPieza` basados en el arreglo `componentes`.

## 4. Cambios en Frontend (`ProductosAdmin.jsx`)

1. **Modal de Edición / Creación:** Ampliar el diálogo actual para incluir un "BOM Builder".
2. **BOM Builder UI:**
   - Un `Autocomplete` asíncrono que llama a `buscarPiezas(query)`.
   - Al seleccionar una pieza, se añade a una tabla local de componentes.
   - La tabla muestra: SKU, Nombre, Color, y un input numérico editable para la `Cantidad`.
   - Botón de eliminar (basurero) para quitar una pieza del BOM local antes de guardar.
3. Al guardar, el formulario empaqueta los datos base y el arreglo de componentes, y envía un POST o PUT a `/api/productos`.
