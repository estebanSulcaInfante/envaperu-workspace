---
tipo: user-story
estado: en-refinamiento
tags: [catalogo, frontend, backend, refactor, crud]
relaciones: 
  - "[[US-001_Creacion_Agil_Molde_Producto_Pieza]]"
---

# US-002: Actualización del CRUD de Molde, Pieza y Producto (Post-Refactoring Ágil)

## 1. Contexto y Borrador Original
**Borrador (Draft):** "Necesito actualizar las vistas de catalogo de Molde pieza producto en base a los cambios realizados en el wizard de creacion agil. Por favor revisa la documentacion para entender la logica y estructura de datos actual y propon una nueva estructura de rutas para que se pueda implementar."

Tras la implementación de la TS-001 ("Creación Ágil"), la estructura de datos del dominio ha cambiado fundamentalmente:
*   `MoldePieza` pasó a llamarse `Pieza` (Representa la forma geométrica pura o cavidad del molde).
*   La antigua `Pieza` pasó a llamarse `PiezaColor` (Representa la variante física pintada/SKU que se produce e inventaría).
*   La relación actual es: Un `Molde` produce muchas `Pieza` (Formas), y cada `Pieza` puede fabricarse en múltiples `PiezaColor` (Variantes físicas de inventario).

Debido a esto, las vistas actuales del CRUD ("Mantenimiento" o catálogo) en el frontend y las rutas del backend que los soportan han quedado obsoletas, ya que aún esperan los nombres de tablas y contratos antiguos.

## 2. Actores
*   **Jefe de Planta / Supervisor de Producción:** Su necesidad principal es operativa. Necesita consultar el catálogo para verificar qué formas y colores existen, o realizar actualizaciones a parámetros técnicos del molde (como el *tiempo de ciclo* o *peso tiro*) que impactan la producción del día a día.
*   **Administrador de Sistema:** Es el dueño de la integridad de los datos maestros. Tiene permisos avanzados para realizar altas (crear nuevos moldes y colores) o bajas lógicas (desactivar SKUs/Formas). Se encarga de mantener limpio el catálogo y evitar inconsistencias o duplicados.

## 3. Análisis y Lagunas Lógicas Identificadas
1.  **Vistas Agrupadas vs Vistas Separadas:** 
    *   *Laguna:* ¿Debe el usuario editar las Formas y Colores en la misma vista del Molde, o tener tablas maestras separadas para Formas (`Pieza`) y SKUs (`PiezaColor`)? 
    *   *Resolución Propuesta:* Es mejor una vista maestra enfocada en el **Molde**. Al entrar a un Molde, se deberían listar sus **Formas** (`Pieza`), y anidadas a estas Formas, se listarían las **Variantes de Color** (`PiezaColor`).
2.  **Generación de SKUs en Edición:** 
    *   *Laguna:* Si el usuario añade un nuevo color a una forma existente desde el CRUD, ¿se auto-genera el SKU usando la regla `F{linea}-{familia}-{correlativo}-{color}` igual que en Creación Ágil?
    *   *Resolución Propuesta:* Sí, toda adición de color debe reutilizar la misma lógica de negocio del servicio `catalogo_service.py` para asegurar que las restricciones UNIQUE del modelo relacional se respeten.
3.  **Integridad al Eliminar (DELETE):**
    *   *Laguna:* Si una `PiezaColor` o un `Molde` se borran, ¿qué ocurre si ya existen Órdenes de Producción o registros de Inventario asociados?
    *   *Resolución Propuesta:* El CRUD debe soportar borrado lógico o fallar gracefully si se viola una ForeignKey constraint (mostrando una alerta amigable de que "El ítem tiene histórico de producción").

## 4. Propuesta de Estructura de Rutas (Backend & Frontend)

### Frontend (Rutas y Componentes)
*   `/catalogo/moldes` -> `ListadoMoldes.jsx` (Muestra la lista de moldes con su tiempo de ciclo, peso tiro).
*   `/catalogo/moldes/:codigo` -> `DetalleMolde.jsx` (Vista de detalles. Muestra una tabla con sus "Formas" asociadas. Al expandir una forma, muestra la lista de "Colores de Inyección" vinculados como SKUs).
*   `/catalogo/skus` -> `ListadoSKU.jsx` (Tabla general plana para consultar el inventario físico de piezas terminadas `PiezaColor` y Kits).

### Backend (Endpoints REST)
*   `GET /api/catalogo/moldes` -> Listar moldes.
*   `GET /api/catalogo/moldes/<codigo_molde>` -> Retornar detalle del molde incluyendo `[ { forma: ..., variantes_color: [...] } ]`.
*   `POST /api/catalogo/moldes/<codigo_molde>/formas` -> Añadir una nueva cavidad a un molde existente.
*   `POST /api/catalogo/formas/<forma_id>/colores` -> Añadir un nuevo SKU/PiezaColor a una forma (reutilizando generador de SKU).
*   `PUT /api/catalogo/piezacolor/<sku>` -> Actualizar atributos menores (ej. peso específico, estado) de un SKU.

## 5. Criterios de Aceptación (BDD)

**Escenario 1: Consultar el Detalle de un Molde actualizado**
*   **Given** (Dado) que un Molde "Balde 20L" tiene 1 Forma ("Base") que se produce en 2 colores (Rojo y Azul)
*   **When** (Cuando) el Jefe de Planta entra a la vista de edición del Molde
*   **Then** (Entonces) debe ver una sección de "Formas (1)", y al seleccionarla, debe ver listadas las variantes "Base - Rojo" y "Base - Azul" con sus respectivos SKUs físicos.

**Escenario 2: Agregar una nueva variante de color a una forma existente**
*   **Given** (Dado) que estoy en la vista de detalle de la Forma "Base" del molde "Balde 20L"
*   **When** (Cuando) agrego el color "Verde" y guardo los cambios
*   **Then** (Entonces) el backend debe crear un nuevo registro `PiezaColor`, autogenerar el SKU físico evitando duplicados, y la tabla de variantes debe actualizarse inmediatamente.

**Escenario 3: Borrado protegido de una Forma**
*   **Given** (Dado) que intento eliminar una Forma (`Pieza`) del molde
*   **When** (Cuando) dicha forma ya tiene Variantes físicas (`PiezaColor`) asociadas o historial de Órdenes
*   **Then** (Entonces) el sistema debe rechazar la acción y mostrar un mensaje explicativo ("No se puede eliminar la Forma porque tiene SKUs de inventario asociados. Desactive o elimine los SKUs primero").
