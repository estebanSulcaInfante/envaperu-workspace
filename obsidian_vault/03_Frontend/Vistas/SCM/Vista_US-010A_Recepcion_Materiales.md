---
tipo: vista-frontend
estado: mock-funcional-local
fuente_datos: mock-local-en-memoria
tags: [frontend, scm, recepcion, calidad, materia-prima, us-010a]
relaciones:
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
  - "[[TS-010A_Recepcion_Trazable_Materiales]]"
  - "[[SCM_Frontend_Overview_US-010]]"
  - "[[Vista_US-010B_Preparacion_Materiales]]"
fecha_creacion: 2026-07-15
fecha_actualizacion: 2026-07-21
---

# Vista US-010A — Recepción de Materiales

## Estado Actual

La experiencia está implementada como **prototipo funcional local con datos mock en memoria**. La historia ya está preparada y [[TS-010A_Recepcion_Trazable_Materiales]] define los futuros endpoints, contratos, autorización e idempotencia.

La visualización cubre el ciclo funcional completo de US-010A con estado React en memoria: catálogos maestros, OC, documentos externos y evidencias, borrador/rechazo/confirmación de recepción, creación local de lotes y saldos, Calidad parcial, movimientos, retención y regularización documental, correcciones compensatorias, devoluciones y trazabilidad. Las acciones se reinician al recargar: no usan `fetch`, `axios`, `localStorage`, backend ni base de datos.

El workspace también incluye un CRUD local completo de `OrdenCompraMaterial`: crear cabecera y líneas, consultar saldos, editar borradores, agregar o quitar líneas, enviar, devolver a borrador, aprobar, descartar, cancelar lógicamente y crear una nueva revisión. La guía del proveedor permanece separada de la autorización interna.

## Implementación

| Elemento | Ubicación |
| :--- | :--- |
| Vista | `frontend/src/components/RecepcionMateriales.jsx` |
| Operaciones y catálogos | `frontend/src/components/Us10aOperations.jsx` |
| Adaptador | `frontend/src/services/recepcionMateriales.js` |
| Fixtures | `frontend/src/mocks/recepcionMateriales.js` |
| Pruebas | `frontend/src/tests/RecepcionMateriales.spec.jsx` |
| Navegación | grupo `Materias primas` en `frontend/src/components/Sidebar.jsx` |

## Alcance de Almacén

US-010A administra únicamente recepciones y ubicaciones de **materias primas**: resinas, masterbatch, pigmentos y aditivos. Los almacenes de PiezaColor y ProductoTerminado son ámbitos separados y no deben aparecer como destinos compatibles en esta vista.

## Rutas del Mock

| Ruta | Propósito | Carácter |
| :--- | :--- | :--- |
| `/materiales/recepciones` | Bandeja de recepciones y pendientes | Implementada |
| `/materiales/recepciones/nueva` | Revisar el formulario de borrador | Implementada |
| `/materiales/recepciones/:recepcionId` | Detalle, Calidad e historial | Implementada |
| `/materiales/recepciones/:recepcionId/editar` | Editar únicamente un borrador | Implementada en memoria |
| `/materiales/compras` | CRUD completo, saldo, aprobación, cancelación y revisiones de órdenes internas | Implementada en memoria |
| `/materiales/inventario` | Lotes, saldos, Calidad, movimientos, retenciones, correcciones y devoluciones | Implementada en memoria |
| `/materiales/documentos` | CRUD de documentos externos, conciliación y reemplazo de evidencias | Implementada en memoria |
| `/datos-maestros/materiales` | CRUD lógico de materiales, proveedores y categorías | Integrado con `/api/scm/v1`; acepta `?catalogo=` para abrir un catálogo concreto. Ubicaciones, motivos y políticas permanecen bloqueados sin datos simulados hasta contar con contrato CRUD. |
| `/configuracion` | Participantes, evidencias y modalidades de categoría | Implementada en memoria |
| `/materiales/cobertura` | Mapa navegable de `REC-01` a `REC-46` y evidencia de idempotencia/conflictos | Implementada |

La TS o una prueba de navegación puede consolidar estas rutas sin cambiar el flujo funcional.

## Superficies Necesarias

### 0. Orden Interna de Compra

- proveedor activo y líneas de materiales existentes;
- cantidad y unidad autorizadas, saldo pendiente y recepciones imputadas;
- estados `BORRADOR`, `PENDIENTE_APROBACION`, `APROBADA`, `PARCIALMENTE_RECIBIDA`, `CERRADA` y `CANCELADA`;
- creador y aprobador distintos para una misma revisión;
- revisión o cancelación auditada después de aprobar, sin sobrescritura;
- ausencia deliberada de precios, impuestos, pagos y contabilidad en US-010A.

### 1. Bandeja de Recepciones

- búsqueda por recepción, proveedor, documento, material o lote;
- filtros separados para estado de recepción, Calidad y retención documental;
- cantidad física, cantidad disponible y ubicación actual;
- acceso al historial sin permitir borrar recepciones confirmadas.

### 2. Borrador de Recepción

- procedencia: proveedor, `OrdenCompraMaterial` aprobada y documentos externos asociados;
- captura separada de guía, factura o pedido con emisor, tipo, serie, número, referencias y adjunto;
- conciliación de códigos, descripciones, cantidades y unidades externas contra catálogo y línea interna;
- líneas y distribución entre lotes internos de recepción;
- lote externo `INFORMADO`, `NO_INFORMADO` o `ILEGIBLE`, intentando capturarlo desde la bolsa sin bloquear v1 por defecto;
- modalidad `VIRGEN_CONFIANZA_PROVEEDOR` o `SEGUNDA_PESAJE_BOLSA`;
- para virgen: unidad, conteo, peso nominal/documental y marca visible `No pesado por EnvaPerú`;
- para segunda: captura rápida de pesos bolsa por bolsa, suma, balanza y evidencia de la hoja manual;
- bruto, tara y neto cuando la medición lo requiera;
- peso bruto declarado separado del peso neto medido por EnvaPerú;
- evaluación de tolerancia y decisión autorizada fuera de tolerancia;
- ubicación compatible del ámbito `MATERIA_PRIMA`;
- inspección mínima antes de confirmar.

### 3. Resolución de Calidad

- identidad, procedencia, evidencia e inspección del lote;
- distribución actual por cantidad, ubicación y estado;
- decisión total o parcial: `LIBERADO`, `BLOQUEADO` o `RECHAZADO`;
- remanente no resuelto visible como `PENDIENTE`;
- política de liberación directa mostrada como una transición auditada, nunca como ausencia de control.

### 4. Detalle e Historial

- recepción original inmutable;
- movimientos de ubicación y decisiones de Calidad;
- retenciones documentales independientes;
- ajustes compensatorios con autor, motivo, evidencia y aprobación;
- rechazo antes de custodia diferenciado de devolución posterior.

## Estados que la UI No Debe Mezclar

| Dimensión | Ejemplos | Consecuencia visual |
| :--- | :--- | :--- |
| Estado de Calidad | `PENDIENTE`, `LIBERADO`, `BLOQUEADO`, `RECHAZADO` | Se muestra por cantidad resuelta. |
| Ubicación física | `REC-CUARENTENA`, almacén MP, bloqueados, devoluciones | Cuarentena no es un quinto estado de Calidad. |
| Retención documental | activa o resuelta | Puede impedir disponibilidad incluso con Calidad liberada. |
| Estado del documento | borrador o confirmado | Solo el borrador se edita directamente. |
| Estado de la orden interna | borrador, pendiente, aprobada, parcial, cerrada o cancelada | La guía externa no modifica esta dimensión. |

Debe mantenerse visible la igualdad por lote: `PENDIENTE + LIBERADO + BLOQUEADO + RECHAZADO = existencia física actual`.

## Comandos y Madurez

| Comando | Actor principal | Estado frontend actual |
| :--- | :--- | :--- |
| Guardar o editar borrador | Almacén | CRUD local; no afecta inventario hasta confirmar |
| Crear, consultar y editar orden interna | Compras | Cabecera y líneas editables mientras sea borrador |
| Descartar borrador | Compras | Eliminación física solo del estado React local |
| Enviar o devolver a borrador | Compras | Transición simulada; habilita o bloquea edición |
| Aprobar orden interna | Gerencia distinta del creador | Simulación en memoria |
| Cancelar orden | Compras | Cancelación lógica; conserva detalle para trazabilidad |
| Crear nueva revisión | Compras | Clona la versión aprobada o cancelada como borrador editable |
| Confirmar recepción | Almacén | Crea lote, saldo, evento e imputación de OC en memoria; nunca inventario real |
| Resolver total o parcialmente | Calidad | Reclasificación mock funcional con remanente pendiente |
| Mover entre ubicaciones compatibles | Almacén | Movimiento mock funcional conservando total y estado de Calidad |
| Retener o regularizar ingreso | Almacén / Supervisor distinto | Disponibilidad recalculada en memoria sin alterar existencia |
| Solicitar/aprobar corrección | Almacén o Supervisor / Gerencia | Solicitud sin efecto y resolución compensatoria funcional en memoria |
| Rechazar o devolver | Almacén/Calidad según etapa | Rechazo sin custodia y devolución total/parcial funcionales en memoria |
| Administrar materiales, proveedores y categorías | Configuración autorizada | Alta, consulta, edición y baja lógica persistente mediante API; actor local temporal hasta integrar autenticación |
| Reemplazar evidencia | Actor autorizado | Conserva adjunto anterior como `REEMPLAZADO` y enlaza el nuevo |

Las simulaciones muestran el resultado esperado y siempre se identifican como locales. Nunca comunican éxito de backend ni sobreviven a una recarga.

## Cobertura UI Prioritaria

La batería automatizada cubre:

- aislamiento explícito del prototipo respecto de HTTP y base de datos;
- `REC-08` y `REC-24`: Calidad, existencia y disponibilidad permanecen separadas;
- `REC-40`: creación, envío y aprobación local de OC con actores distintos;
- `REC-44`: virgen muestra `NO_MEDIDO`, documento/conteo y bloqueo ante discrepancia;
- `REC-45`: segunda suma cada bolsa, conserva diferencia y permite añadir filas;
- configuración lógica de participantes y tipos de evidencia.
- CRUD de materiales, proveedores, ubicaciones, motivos, categorías y políticas versionadas;
- documentos externos separados de la autorización interna, conciliación de líneas y reemplazo no destructivo de adjuntos;
- borrador editable, rechazo previo, confirmación local, entrada excepcional y decisión de Gerencia ante discrepancia;
- Calidad parcial, movimientos compatibles, retención, regularización, correcciones y devoluciones;
- mapa completo de `REC-01` a `REC-46`; los casos transaccionales muestran evidencia visual sin afirmar persistencia real.

El 2026-07-21 la suite completa del frontend quedó en `9` archivos y `37 passed`; `12` pruebas corresponden al prototipo US-010A. El build de Vite finalizó correctamente.

## Dependencias Abiertas

- contratos/API y persistencia definidos por TS-010A, todavía no implementados;
- autenticación humana para aplicar en producción el modelo objetivo de capacidades y segregación ya definido;
- valores operativos reales iniciales de ubicaciones, tolerancias y motivos para UAT;
- decisión de almacenamiento y retención de evidencias/adjuntos;
- validación de `REC-01` a `REC-46` con Compras, Almacén y Calidad.

Estas dependencias ya no dejan huecos en la visualización mock, pero siguen siendo obligatorias antes de sustituir el estado local por una implementación productiva.
