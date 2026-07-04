---
tipo: user-story
estado: priorizada
tags: [frontend, backend, excel, pruebas, refactor]
relaciones:
  - "[[US-001_Creacion_Agil_Molde_Producto_Pieza]]"
  - "[[US-002_Refactor_CRUD_Molde_Pieza_Producto]]"
---

# US-004: Actualización de Botones de Acción en Lista de Órdenes y Tests

## 1. Contexto y Borrador Original
**Borrador (Draft):** "ya aplicamos el refactor que hemos estado ejecutando en estos drafts a la OP y Molde Producto Pieza. Pero los botones de accion en la lista de ordenes pudieron haber quedado obsoletos. Revisar y corregir. Terminar con test de prueba y los tests existentes actualizarlos."

Tras el profundo cambio de dominio (Molde -> Pieza -> PiezaColor) y las alteraciones a la estructura de la Orden de Producción (OP), la vista `OrdenesLista.jsx` y los servicios que consumen (como la descarga del Excel) podrían estar apuntando a atributos o estructuras JSON que ya no existen o han cambiado de nombre. Es imperativo revisar la estabilidad de estas funciones post-refactor y subsanar las alertas técnicas (como las de MUI Grid v2 que ya surgieron en otros componentes).

## 2. Actores
*   **Supervisor de Planta / Operador de Máquina:** Interactúa con los botones de la lista de órdenes para imprimir hojas de ruta (Excel), escanear QRs, registrar producción diaria y modificar parámetros de estado.
*   **Desarrollador / QA:** Responsable de garantizar que los tests unitarios y de integración (`test_excel_generation.py`, `test_crear_orden.py`, etc.) pasen correctamente después de la refactorización estructural.

## 3. Análisis y Lagunas Lógicas Identificadas
1.  **Compatibilidad de Datos en `excel_service.py` y Código QR:**
    *   *Laguna:* ¿El servicio de Excel sigue encontrando los datos `orden.producto`, `orden.molde`, y la iteración sobre `lote.materias_primas` correctamente? ¿La generación del QR de la OP se ve afectada por el cambio de modelo?
    *   *Resolución:* Revisar si los atributos referenciados (`orden.molde`, `orden.producto`, `lote.color_rel`) están mapeados correctamente tras el refactor, tanto para el reporte como para el QR.
2.  **Operaciones de OP: Cerrar, Ajustar Parámetros y Crear Registro:**
    *   *Laguna:* Al cambiar a "PiezaColor", ¿se rompe la lógica de calcular el avance (kg) cuando cerramos la orden, ajustamos los parámetros del molde, o abrimos el formulario para un "Nuevo Registro Diario"?
    *   *Resolución:* Auditar los endpoints de estado (`PUT /ordenes/<id>/estado`), métricas (`PUT /ordenes/<id>/metricas`) y creación de registro (`POST /ordenes/<id>/registros`) para garantizar que calculan las metas y leen el catálogo con la nueva base relacional.
3.  **Advertencias de Interfaz Gráfica (MUI Grid v2):**
    *   *Laguna:* La lista de órdenes (`OrdenesLista.jsx`) todavía usa sintaxis deprecada de Material UI (`<Grid item xs={6}>`).
    *   *Resolución:* Migrar la sintaxis a la nueva API `Grid2` de MUI (`<Grid size={{ xs: 6 }}>`) en el componente `OrdenesLista.jsx` (tal como se hizo en `OrdenForm.jsx`).
3.  **Tests Obsoletos:**
    *   *Laguna:* Los tests automatizados, especialmente los relacionados al flujo de OP y Excel (`test_e2e_flujo_op.py`, `test_excel_generation.py`), muy probablemente fallen al intentar inicializar mocks con la estructura antigua.
    *   *Resolución:* Refactorizar los *fixtures* y assertions en la suite de pytest para alinearse con los modelos `Pieza` y `PiezaColor`.

## 4. Criterios de Aceptación (BDD)

**Escenario 1: Descarga Exitosa de la Hoja de Ruta (Excel)**
*   **Given** que existe una Orden de Producción activa con datos de producto, molde y lotes
*   **When** el Supervisor de Planta hace clic en el botón "Descargar Excel para Imprimir"
*   **Then** el backend genera el archivo Excel sin errores de acceso a atributos (`AttributeError`)
*   **And** el navegador inicia la descarga del archivo `.xlsx` correctamente formateado.
**Escenario 2: Operatividad de Botones de Gestión (QR, Estado, Parámetros y Registro)**
*   **Given** que existe una Orden de Producción activa
*   **When** el usuario hace clic en los botones de "Ver QR", "Cerrar OP", "Ajustar Parámetros" o "Crear Registro Diario"
*   **Then** las interfaces secundarias (Diálogos) se abren sin fallos y muestran los datos precisos de la OP actual (incluyendo el código QR generado correctamente).
*   **And** al confirmar la acción (por ejemplo, guardar un nuevo registro diario o cerrar la orden), el backend la procesa utilizando los nuevos modelos sin devolver errores 500.

**Escenario 3: Interfaz Limpia sin Advertencias de MUI**
*   **Given** que la aplicación React compila y renderiza `OrdenesLista.jsx`
*   **When** el usuario navega a la vista de "Lista de Órdenes"
*   **Then** la consola del navegador no debe mostrar errores de hidratación ni advertencias de deprecación (ej. `"MUI Grid: The item prop has been removed"`).

**Escenario 4: Actualización y Aprobación de la Suite de Pruebas**
*   **Given** los cambios arquitectónicos recientes
*   **When** el Desarrollador ejecuta la suite de pruebas mediante `pytest`
*   **Then** todos los tests relacionados a Órdenes (`test_crear_orden.py`, `test_excel_generation.py`, `test_e2e_flujo_op.py`) deben pasar exitosamente (0 failures)
*   **And** reflejan las nuevas validaciones del dominio.
