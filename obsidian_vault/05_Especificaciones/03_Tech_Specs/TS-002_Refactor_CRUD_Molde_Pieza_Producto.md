---
tipo: tech-spec
estado: en-revision
tags: [catalogo, backend, frontend, arquitectura, crud]
relaciones: 
  - "[[US-002_Refactor_CRUD_Molde_Pieza_Producto]]"
  - "[[TS-012_Normalizacion_Relacion_Molde_Pieza_NM]]"
  - "[[TS-013_Codigos_Correlativos_Automaticos_Catalogo]]"
---

# TS-002: Especificación Técnica para Refactor de CRUD de Molde, Pieza y Producto

> [!IMPORTANT] Corrección posterior
> [[TS-012_Normalizacion_Relacion_Molde_Pieza_NM|TS-012]] sustituye la definición de `Pieza` como hija directa de un único molde. El CRUD vigente separa el maestro global `Pieza` de la composición `MoldePieza`, donde se editan cavidades y peso operativo.
>
> [[TS-013_Codigos_Correlativos_Automaticos_Catalogo|TS-013]] sustituye el generador basado en línea, familia, nombre, molde o color. El CRUD no recibe códigos manuales: el backend asigna correlativos `ML`, `PZ`, `PC` y `PT` y los formularios los muestran como solo lectura.

## 1. Objetivo Técnico
Refactorizar los endpoints REST y los componentes React del catálogo maestro de productos/moldes para soportar la arquitectura de dominio actualizada en TS-001 (separación estricta entre Forma=`Pieza` y Variante Física=`PiezaColor`). Se debe garantizar que las modificaciones respeten las reglas de generación de SKUs y manejen integridades referenciales seguras.

## 2. Modelos de Datos Afectados
*   **`Molde`**: Raíz de agregación para el CRUD principal. Atributos críticos a actualizar: `tiempo_ciclo_std`, `peso_tiro_gr`.
*   **`Pieza` (Forma)**: Hijo directo de `Molde` (relación 1:N). No posee SKU. Representa cavidades físicas del molde.
*   **`PiezaColor` (SKU / Variante Física)**: Hijo directo de `Pieza` (relación 1:N). Posee la llave primaria `sku` y se almacena en inventario.

## 3. Endpoints REST (Backend)

Todos los endpoints usarán prefijo `/api/catalogo`.

### 3.1. `GET /moldes`
*   **Descripción:** Retorna listado general de moldes.
*   **Respuesta Exitosa (200):** Array de objetos `{ codigo, nombre, tipo, peso_tiro_gr, ... }`

### 3.2. `GET /moldes/<codigo>`
*   **Descripción:** Retorna el detalle completo de un molde, con sus formas y variantes anidadas.
*   **Respuesta Exitosa (200):**
    ```json
    {
      "codigo": "M001",
      "nombre": "Balde Romano 20L",
      "peso_tiro_gr": 500.0,
      "formas": [
        {
          "id": 1,
          "nombre": "Base",
          "cavidades": 1,
          "peso_unitario_gr": 450.0,
          "variantes": [
            { "sku": "FHOG-BALD-0001-ROJO", "color": "ROJO", "color_id": 3 },
            { "sku": "FHOG-BALD-0001-AZUL", "color": "AZUL", "color_id": 5 }
          ]
        }
      ]
    }
    ```

### 3.3. `PUT /moldes/<codigo>`
*   **Descripción:** Actualiza metadatos del molde.
*   **Payload:** `{ nombre, tipo, peso_tiro_gr, tiempo_ciclo_std }` (Solo campos técnicos / operativos).

### 3.4. `POST /moldes/<codigo>/formas`
*   **Descripción:** Añade una nueva cavidad a un molde que ya existe.
*   **Payload:** `{ nombre, cavidades, peso_unitario_gr }`
*   **Lógica:** Instancia un nuevo registro `Pieza` asociado al `molde_codigo`.

### 3.5. `POST /formas/<forma_id>/colores`
*   **Descripción:** Crea una variante física SKU para una forma existente.
*   **Payload:** `{ color_id }`
*   **Lógica:** 
    1. Resuelve la línea y familia a través del Molde de la Forma.
    2. Solicita el siguiente correlativo `PC` mediante el servicio definido en [[TS-013_Codigos_Correlativos_Automaticos_Catalogo|TS-013]].
    3. Persiste el nuevo registro `PiezaColor`. Retorna error 409 si el color ya existe para esa forma.

### 3.6. `DELETE /formas/<forma_id>`
*   **Descripción:** Borrado lógico o físico de una forma.
*   **Lógica de Integridad:** El backend interceptará la llamada. Si existen `PiezaColor` atados a esta forma, devolverá `400 Bad Request` indicando que existen SKUs inventariados.

## 4. Componentes Frontend (React)

*   **`src/services/api.js`:** Nuevos métodos `getMolde(codigo)`, `updateMolde(codigo, data)`, `addFormaMolde(codigo, data)`, `addVarianteColor(forma_id, color_id)`.
*   **`src/views/Catalogo/MoldesIndex.jsx`:** Vista general plana. Usa un DataGrid/Table para listar moldes y un buscador por código/nombre.
*   **`src/views/Catalogo/MoldeDetalle.jsx`:** Vista Master-Detail:
    *   **Cabecera:** Panel de edición en vivo (Jefe de Planta) para tiempos y pesos.
    *   **Cuerpo (Formas):** Sistema de `Accordion` (Acordeón). Cada acordeón es una Forma. 
    *   **Contenido de Acordeón:** Tabla (DataGrid) listando los SKUs `PiezaColor` y un botón "+ Añadir Color".
*   **`src/views/Catalogo/SkusIndex.jsx`:** Vista para Administrador de Sistema, mostrando un maestro de SKUs globales sin anidación para revisiones rápidas.

## 5. Implementación (Plan de Ejecución)
1.  **Migración / Controladores Backend:** Crear las nuevas rutas en `rutas_catalogo.py` con sus respectivas protecciones try-except.
2.  **Lógica de SKU:** Centralizar la asignación correlativa del backend para que wizard y CRUD individual compartan [[TS-013_Codigos_Correlativos_Automaticos_Catalogo|TS-013]].
3.  **Frontend Views:** Construir el esqueleto Master-Detail (`MoldeDetalle.jsx`).
4.  **Integración:** Conectar el componente Acordeón con los endpoints `POST /formas/...`.
