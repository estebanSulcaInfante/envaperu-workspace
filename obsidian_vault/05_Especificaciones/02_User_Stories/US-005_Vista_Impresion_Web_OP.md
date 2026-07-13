---
tipo: user-story
estado: propuesta
tags: [frontend, backend, impresion, multipieza, html, css, print]
relaciones:
  - "[[US-004_Actualizar_Botones_Accion_Ordenes]]"
  - "[[Orden_Produccion]]"
  - "[[Snapshot_Composicion_Molde]]"
  - "[[Lote_Color]]"
  - "[[Composicion_Materiales]]"
  - "[[Receta_Colorantes]]"
draft_origen: "obsidian_vault/05_Especificaciones/01_Drafts/Normalizacion del color e impresion de OP.md"
fecha_creacion: 2026-07-11
---

# US-005: Vista de Impresión Web de la Orden de Producción (Multi-Pieza)

## 1. Contexto y Borrador Original

**Borrador (Draft):** "Necesitamos imprimir la op, al comienzo pensaba hacerlo generando un excel pero me di cuenta que podemos simplemente generar un html e imprimirlo directamente o descargarlo como pdf. Ya existe una plantilla de excel previa para la impresión. Sin embargo, esta plantilla fue diseñada sin considerar la existencia de molde multipieza por lo que algunos campos no tienen coherencia como cavidad, peso y otras especificaciones por moldes con piezas individuales."

Actualmente, la Orden de Producción se exporta como archivo Excel (`.xlsx`) que el Supervisor descarga y luego imprime desde su Excel local. Este flujo presenta varias fricciones:

1.  **Paso intermedio innecesario:** El Supervisor debe descargar el archivo, abrirlo en Excel, y luego mandar a imprimir. Si la computadora de planta no tiene Excel instalado (o tiene una versión incompatible), la hoja sale descuadrada.
2.  **Incompatibilidad con Multi-Pieza:** La cabecera del template asume un molde con una sola pieza (un "Peso Unitario", una "Cavidad"). Con el modelo multi-pieza (ej. un molde que produce cuerpo + tapa simultáneamente), estos campos pierden su significado.
3.  **Saltos de página frágiles:** El template Excel requiere configuración manual de zonas de impresión y saltos de página, que se desestabilizan al insertar filas dinámicas.

**La solución:** Crear una vista HTML de impresión dentro del sistema web que replique el formato de la hoja de ruta de la OP (fiel a la plantilla existente), soporte nativamente el desglose multi-pieza, y permita al usuario imprimir directamente desde el navegador (Chrome/Edge) o guardar como PDF, sin necesidad de descargar archivos.

> **Referencia técnica:** El análisis detallado del problema con el template Excel se encuentra en el artefacto de sesión `analisis_excel_template.md`.

## 2. Actores

*   **Supervisor de Planta:** Persona que genera la Orden de Producción desde el sistema y necesita imprimir la "Hoja de Ruta" para entregarla al equipo de planta. Necesita que la impresión sea rápida (1 clic), sin descargas intermedias, y que el formato sea limpio y legible.
*   **Operador de Máquina:** Persona que recibe la hoja impresa y la coloca junto a la máquina de inyección como referencia operativa. Consulta: coladas por color, receta de materiales, gramajes de colorante, y el código QR para el módulo de pesaje.
*   **Jefe de Producción:** Puede necesitar revisar la hoja de ruta en pantalla sin imprimir, o generar un PDF archivable para auditorías.

## 3. Análisis y Lagunas Lógicas Identificadas

### 3.1. Composición del Molde Multi-Pieza en la Cabecera

*   **Laguna:** El formato original de la hoja de ruta muestra "Peso Unitario: Xg" y "Cavidad: N" asumiendo un solo tipo de pieza. Con multi-pieza, estos campos son la **suma consolidada** de todas las piezas (`calculo_peso_neto_golpe`, `calculo_cavidades_totales`), pero el operario pierde visibilidad del desglose.
*   **Resolución:** Añadir una **mini-tabla de composición** debajo del nombre del molde, listando cada pieza con sus cavidades, peso unitario y subtotal. Los campos consolidados (Peso Neto Golpe, Cav. Total, Peso Tiro) se mantienen como resumen rápido.

### 3.2. Diferencia entre "Peso Colada" y "Peso Tiro"

*   **Laguna:** En el template anterior, el campo "Peso Colada" estaba mostrando el valor de `calculo_peso_tiro_gr` (piezas + ramal), generando confusión. El "Peso Colada" debería ser solo el ramal (`snapshot_peso_colada_gr`), y el "Peso Tiro" el total.
*   **Resolución:** Separar ambos valores en la vista de impresión:
    - **Peso Neto Golpe:** Suma de (cavidades × peso_unit) de todas las piezas.
    - **Peso Colada (Ramal):** Peso del runner/ramal únicamente.
    - **Peso Tiro:** Peso Neto Golpe + Peso Colada.

### 3.3. Salto de Página para Colorantes

*   **Laguna:** ¿Dónde cortar la primera página A4? Si la OP tiene muchos colores (hasta 6), la tabla de colores + materia prima + colorantes puede no caber en una sola hoja A4.
*   **Resolución:** Usar `page-break-before: always` en CSS para forzar que la sección de **Colorantes** siempre empiece en la **Página 2**. Esto garantiza que la Página 1 contenga: Cabecera + Composición + Colores + Materia Prima, y la Página 2: Colorantes + QR.

### 3.4. Convivencia con el Botón Excel Existente

*   **Laguna:** ¿Desaparecemos el botón actual de descarga Excel o lo mantenemos?
*   **Resolución:** Mantener **ambos botones** temporalmente: el botón "XLS" (descarga para casos donde el supervisor quiera editar algo manualmente) y el nuevo botón "Imprimir" (impresión directa). A futuro, si la vista de impresión satisface todas las necesidades, se puede deprecar el Excel.

### 3.5. Código QR

*   **Laguna:** El QR se genera como imagen en el backend (`qr_service.py`). ¿Lo renderizamos en el frontend o consumimos la URL del backend?
*   **Resolución:** Consumir la URL existente del backend (`/api/ordenes/<id>/qr`) como `<img>`, lo que evita dependencias frontend adicionales y asegura que el QR sea idéntico al que se usa en el módulo de pesaje.

### 3.6. Apertura de la Vista de Impresión

*   **Laguna:** ¿Cómo se abre la vista? ¿Modal? ¿Nueva pestaña? ¿Misma página?
*   **Resolución:** Abrir en una **nueva pestaña** del navegador (`window.open`). Esto permite que el usuario la revise, la imprima con `Ctrl+P`, y luego cierre la pestaña sin perder el contexto de la lista de órdenes. Además, una pestaña separada facilita la aplicación de `@media print` sin afectar la UI principal.

## 4. Criterios de Aceptación (BDD)

**Escenario 1: El Supervisor imprime la OP de un molde de una sola pieza**
*   **Given** que existe una Orden de Producción activa con 1 pieza en su `snapshot_composicion` y al menos 1 lote de color
*   **When** el Supervisor hace clic en el botón "Imprimir" (icono 🖨️) de la fila correspondiente en la lista de órdenes
*   **Then** se abre una nueva pestaña del navegador con la vista de impresión de la OP
*   **And** la cabecera muestra: N° OP, Fecha, Producto, Máquina, Molde
*   **And** la mini-tabla de composición muestra **1 fila** con la pieza, sus cavidades, peso unitario y subtotal
*   **And** los parámetros técnicos muestran: Días, Turno, Cav. Total, Cola/Hora, Peso Neto Golpe, Peso Colada (ramal), Peso Tiro, Merma, Fecha inicio-fin
*   **And** la tabla de colores muestra los lotes con Peso Producción, Merma a Recuperar y Cantidad Coladas
*   **And** la sección de Materia Prima muestra totales y desglose por color
*   **And** la sección de Colorantes aparece en la **Página 2** (forzada por CSS)
*   **And** el código QR se muestra legible en la Página 2
*   **And** al presionar `Ctrl+P`, la vista previa de impresión de Chrome muestra 2 páginas A4 correctamente formateadas.

**Escenario 2: El Supervisor imprime la OP de un molde multi-pieza**
*   **Given** que existe una Orden de Producción activa con 3 piezas en su `snapshot_composicion` (ej. Cuerpo, Tapa, Asa)
*   **When** el Supervisor hace clic en el botón "Imprimir"
*   **Then** la mini-tabla de composición muestra **3 filas**, una por cada pieza, con sus cavidades y pesos individuales
*   **And** los campos consolidados (Peso Neto Golpe, Cav. Total) reflejan la suma correcta de las 3 piezas
*   **And** el layout no se rompe ni se desborda de la primera página A4.

**Escenario 3: Convivencia del botón XLS y el botón Imprimir**
*   **Given** que el usuario está en la vista de Lista de Órdenes
*   **When** observa la columna de acciones de cualquier orden
*   **Then** ve dos botones diferenciados: el icono de descarga (📥 XLS) y el icono de impresora (🖨️ Imprimir)
*   **And** ambos funcionan independientemente sin conflicto.

**Escenario 4: Impresión sin estilos de la aplicación**
*   **Given** que la nueva pestaña de impresión está abierta
*   **When** el usuario activa la función de impresión del navegador (`Ctrl+P` o menú)
*   **Then** la barra lateral (Sidebar), botones de navegación y fondos decorativos de la app **no aparecen** en la vista previa de impresión
*   **And** se usa un fondo blanco con texto negro para maximizar la legibilidad y ahorrar tinta
*   **And** el contenido se ajusta al ancho de una página A4 sin recortes horizontales.

**Escenario 5: Guardar como PDF**
*   **Given** que la nueva pestaña de impresión está abierta
*   **When** el usuario selecciona "Guardar como PDF" en la ventana de impresión del navegador
*   **Then** se genera un archivo PDF con el mismo layout de 2 páginas A4
*   **And** el código QR es legible y escaneable desde el PDF.
