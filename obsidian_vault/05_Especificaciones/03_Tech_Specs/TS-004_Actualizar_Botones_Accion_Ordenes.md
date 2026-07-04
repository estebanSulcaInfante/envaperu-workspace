---
tipo: tech-spec
estado: draft
tags: [frontend, backend, excel, pruebas, refactor, mui]
relaciones:
  - "[[US-004_Actualizar_Botones_Accion_Ordenes]]"
  - "[[00_Meta/Arquitectura_Global]]"
---

# TS-004: Diseño Técnico para Actualización de Botones de Acción en Lista de Órdenes

## 1. Resumen y Objetivo
Esta especificación técnica detalla los cambios necesarios a nivel de código para cumplir con la **US-004**. Tras la reestructuración del catálogo (donde `MoldePieza` pasó a `Pieza` y `Pieza` pasó a `PiezaColor`), se requiere asegurar que las funcionalidades satélites de la Orden de Producción (OP) —tales como la generación del Excel, QRs, registros diarios y controles de estado— sigan funcionando correctamente y no dependan de relaciones obsoletas. Además, se corregirá la deuda técnica visual introducida por la actualización de Material UI v6/v7 (Grid v2).

## 2. Cambios en el Frontend (React)

### 2.1. Refactorización de Material UI (Grid v2)
El componente `OrdenesLista.jsx` y sus subcomponentes locales (como `LoteRow` o cualquier Dialog anidado) siguen usando la sintaxis antigua `<Grid item xs={X}>`.

*   **Cambio a realizar:** Reemplazar todas las instancias de `<Grid item xs={X} sm={Y} md={Z}>` por `<Grid size={{ xs: X, sm: Y, md: Z }}>`.
*   **Archivos Afectados:** `frontend/src/components/OrdenesLista.jsx` y potencialmente otros archivos en la ruta de importación vinculada.
*   **Justificación:** Esto silenciará los molestos warnings de la consola (`"MUI Grid: The item prop has been removed"`) que afectan la legibilidad de logs de desarrollo.

### 2.2. Revisión de Modales de Acción
1.  **Modal "Nuevo Registro" (`RegistroForm.jsx`)**: Asegurar que la prop `ordenId` pasa correctamente y que el formulario puede recuperar el `snapshot_composicion` de la orden en lugar de intentar leer el catálogo general.
2.  **Modal "Ajustar Parámetros" (`MetricasForm`)**: Asegurarse de que el payload enviado en el `PUT` afecte a los campos `snapshot_cavidades` y `snapshot_tiempo_ciclo` de la `OrdenProduccion` para no alterar el catálogo central del `Molde`.

## 3. Cambios en el Backend (Flask)

### 3.1. Adaptación del Servicio de Excel (`excel_service.py`)
El generador de hojas de ruta (`generar_op_excel`) lee atributos anidados.
*   **Atributos de OP**: Actualmente extrae `orden.producto` y `orden.molde`. Dado que en el modelo `OrdenProduccion` estos se conservaron como campos de "cache/legacy" (cadenas de texto), la compatibilidad inicial está garantizada. Sin embargo, se debe asegurar que no arroje `AttributeError` si estos vienen vacíos.
*   **Materia Prima / Pigmentos**: Verifica que `lote.materias_primas` y `lote.colorantes` sigan siendo relaciones válidas (mediante `SeCompone` y `LotePigmento`) que expongan el atributo `.peso_kg` y `.gramos`.
*   **Cálculos Totales**: Confirmar que `resumen = orden.resumen_totales` sigue calculando correctamente la merma y los totales de kilogramos considerando las `snapshot_composicion`.

### 3.2. Adaptación del Servicio QR (`qr_service.py`)
El servicio `generar_qr_imagen` y `generar_url_form` serializa el número de la OP (`orden.numero_op`) en una URL y crea un QR de formato Base64.
*   **Verificación**: Las pruebas de refactorización no alteraron el campo primario `numero_op`, pero se debe incluir un test unitario rápido que verifique que el objeto binario de la imagen se devuelve en el header HTTP apropiado (Mimetype `image/png`).
*   > [!WARNING]
    > **Retrocompatibilidad Crítica:** El módulo de pesaje (`modulo-pesaje`) lee e intercepta los parámetros de esta URL (ej. `entry.1779940712` para Molde, `entry.885430358` para peso, etc.). Estos *entry IDs* del payload del Query String de Google Forms **NO DEBEN SER ALTERADOS BAJO NINGUNA CIRCUNSTANCIA**, de lo contrario se romperá el parsing en `modulo-pesaje/backend/app/models/pesaje.py` en producción.

### 3.3. Endpoints de Operación (`rutas_produccion.py`)
*   **`PUT /api/ordenes/<numero_op>/estado`**: Sólo invierte la bandera `orden.activa`. Ningún cambio de modelo afecta esto.
*   **`PUT /api/ordenes/<numero_op>/metricas`**: Actualiza los snapshots e invoca al método de instancia que recalcula la producción. Debe validarse en test que esta función no colapse por missing properties en `LoteColor`.
*   **`POST /api/ordenes/<numero_op>/registros`**: (Lógica en `rutas_registros.py`). Al guardar la producción del turno, debe utilizar el `snapshot_peso_unitario_gr` que provee la Orden en lugar de leer el `PiezaColor` actual del catálogo (por si el peso estándar cambió a mitad del mes).

## 4. Estrategia de Pruebas (Actualización de Tests)
Varios tests en `backend/tests/` instancian modelos usando las estructuras viejas.

1.  **`test_excel_generation.py`**:
    *   Actualizar los *fixtures* para usar `PiezaColor` y no la antigua tabla de `Pieza`.
    *   Verificar que la exportación de `generar_op_excel` retorna un archivo de más de 0 bytes y que contiene el texto de la OP.
2.  **`test_crear_orden.py` y `test_e2e_flujo_op.py`**:
    *   Ajustar cómo se le pasa el `molde_id` y `producto_sku`.
    *   Reemplazar las aserciones de catálogo para confirmar que se están leyendo desde `snapshot_composicion`.
3.  **Ejecución**: Se debe poder correr `pytest backend/tests/` sin que los tests relacionados con la Lista de Órdenes revienten por errores de modelo (`AttributeError` o `IntegrityError`).

## 5. Plan de Implementación Recomendado
1.  **Fase 1 (Frontend)**: Realizar el reemplazo masivo de `<Grid item>` en `OrdenesLista.jsx` y verificar visualmente en `npm run dev`.
2.  **Fase 2 (Backend - Endpoints)**: Inspeccionar `/estado` y `/metricas` manualmente a través de la UI para confirmar comportamiento en vivo.
3.  **Fase 3 (Backend - Reportes)**: Descargar un Excel de OP. Si falla, subsanar las relaciones en `excel_service.py`.
4.  **Fase 4 (Pruebas)**: Correr la suite de pytest, identificar los tests quebrados y reescribir sus constructores de base de datos de prueba para que respeten el nuevo dominio.
