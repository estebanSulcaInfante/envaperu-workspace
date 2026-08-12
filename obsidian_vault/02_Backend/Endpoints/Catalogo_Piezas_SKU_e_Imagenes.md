---
tipo: endpoint_api
estado: implementado
tags: [backend, api, catalogo, pieza, pieza-color, imagen, molde]
fecha_creacion: 2026-08-04
fecha_actualizacion: 2026-08-04
relaciones:
  - "[[Pieza]]"
  - "[[PiezaColor]]"
  - "[[Molde]]"
  - "[[Vista_Catalogo_Piezas_SKU_e_Imagenes]]"
---

# API — Catálogo de piezas, SKU e imágenes

## Consulta jerárquica

`GET /api/piezas`

Devuelve cada [[Pieza]] con sus moldes y variantes [[PiezaColor]]. La búsqueda contempla código y nombre de pieza, molde, SKU y color. Cada variante con imagen expone:

```json
{
  "sku": "PC-000001",
  "pieza_id": 1,
  "color_produccion_id": 1,
  "color": "VERDE JARDÍN",
  "color_hex": "#2E7D32",
  "imagen_url": "/api/piezas-color/PC-000001/imagen"
}
```

`imagen_url` es `null` mientras la variante no posea imagen.

## Habilitar color para un molde

`POST /api/moldes/{codigo}/colores`

Entrada:

```json
{ "color_id": 1 }
```

El comando obtiene todas las asociaciones activas de [[MoldePieza]] y crea o reutiliza la [[PiezaColor]] correspondiente para cada pieza. La transacción es atómica: si una salida no puede resolverse, no se confirma ninguna creación.

- Responde `201` cuando crea al menos una variante.
- Responde `200` cuando todas ya existían.
- Es idempotente por la unicidad `pieza_id + color_produccion_id`.
- Rechaza moldes sin salidas activas y colores inexistentes o inactivos.

`POST /api/formas/{id}/colores` permanece como adaptador compatible, pero aplica la misma regla al molde completo.

## Imagen de PiezaColor

| Método | Ruta | Resultado |
| :--- | :--- | :--- |
| `GET` | `/api/piezas-color/{sku}/imagen` | Devuelve el binario con su MIME o `404`. |
| `PUT` | `/api/piezas-color/{sku}/imagen` | Guarda `multipart/form-data`, campo `imagen`. |
| `DELETE` | `/api/piezas-color/{sku}/imagen` | Elimina MIME y contenido; conserva el SKU. |

Restricciones:

- formatos: JPG, PNG o WebP;
- tamaño máximo: 2 MB;
- el contenido binario debe coincidir con la firma del MIME declarado;
- la ausencia del archivo devuelve `400` con “Selecciona una imagen”;
- formato o contenido inválido devuelve `415`;
- exceso de tamaño devuelve `413`.

La imagen no se publica mediante un almacenamiento externo en este piloto: `imagen_mime` e `imagen_data` se persisten en PostgreSQL y el API entrega el contenido autenticado.

## Migración

La revisión `f63a2c8d4e70` añadió `imagen_mime` e `imagen_data` a `pieza_color` y eliminó ambas columnas de `pieza`. No realizó copia automática de imágenes ambiguas.
