---
tipo: tech_spec
id: TS-017A
titulo: "Sesión durable y shell de alta guiada"
estado: implementada-local-pendiente-uat
tags: [catalogo, wizard, borrador, api, frontend]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
user_story: "[[../02_User_Stories/US-012A_Sesion_Reanudable_e_Identidad_de_Producto]]"
relaciones:
  - "[[../../../01_Dominio/Sesion_Alta_Producto]]"
  - "[[../../../02_Backend/Endpoints/SCM_Alta_Guiada_ProductoTerminado]]"
  - "[[../../../03_Frontend/Vistas/SCM/Vista_US-012_Alta_Guiada_Integral_PT]]"
---

# TS-017A: Sesión durable y shell de alta guiada

## 1. Objetivo técnico

Introducir el expediente durable que soporta guardado, reanudación, navegación por seis pasos e idempotencia. El incremento A entrega el shell completo y conecta realmente `IDENTIDAD`; `COMPONENTES` empieza en B.

## 2. Modelo

Crear `scm_alta_producto_sesion` conforme a [[../../../01_Dominio/Sesion_Alta_Producto|Sesión de Alta de Producto]].

Restricciones mínimas:

- `id UUID PRIMARY KEY`;
- `estado` mediante `CHECK` cerrado;
- `paso_actual` mediante `CHECK` con `IDENTIDAD`, `COMPONENTES`, `COLORES`, `ESTRUCTURA`, `RUTA_EMPAQUE`, `REVISION`;
- `borrador_json`, `estados_paso_json`, `bloqueos_paso_json`, `fuentes_json`, `referencias_json`, `readiness_json` e `invalidated_steps_json` con defaults vacíos compatibles;
- `producto_terminado_id` nullable;
- `version INTEGER NOT NULL DEFAULT 1`;
- índices `(estado, updated_at)`, `producto_terminado_id`, `creada_por_id` y `actualizada_por_id`;
- timestamps server-side.

Los JSON se validan con esquemas versionados. `schema_version` forma parte del borrador; no se interpreta libremente.

## 3. API

Prefijo: `/api/scm/v1/altas-producto`.

| Método | Ruta | Uso |
|---|---|---|
| `POST` | `/` | Crear sesión con `Idempotency-Key`; `data` inicial pertenece a IDENTIDAD. |
| `GET` | `/?estado=&q=` | Listar sesiones autorizadas. |
| `GET` | `/{id}` | Obtener pasos, fuentes, referencias, readiness y versión. |
| `PUT` | `/{id}/pasos/{codigo}` | Guardar `data` opaca y `estado_paso` con `expected_version`. |
| `POST` | `/{id}/pasos/{codigo}/aplicar` | Materializar una fase y guardar sus referencias en un único comando idempotente. |
| `POST` | `/{id}/validar` | Recalcular bloqueos estructurales y handoffs. |
| `POST` | `/{id}/finalizar` | Finalizar sólo si los seis pasos están completos y válidos. |

El frontend no encadena «crear maestro» y luego «guardar referencia». `aplicar` compone el servicio canónico y el checkpoint de sesión bajo la misma operación. IDENTIDAD crea o reutiliza el ProductoTerminado de forma atómica y deja `producto_ref`; una respuesta perdida puede reintentarse sin crear otro PT.

`aplicar` exige `Idempotency-Key`, `expected_version` y una `application_key` estable por intento de fase. Si una ejecución queda `PARTIAL`, la sesión conserva resultados y referencias ya creadas. El reintento usa la misma `application_key`, puede corregir sólo unidades todavía pendientes y nunca sustituye silenciosamente una unidad ya materializada. Una fase `APPLIED` se reabre en modo consulta; cualquier corrección posterior usa la acción canónica explícita del maestro o una nueva revisión.

### Errores

`SESSION_NOT_FOUND`, `SESSION_IMMUTABLE`, `VERSION_CONFLICT`, `INVALID_STEP`, `SESSION_NOT_READY`, `IDEMPOTENCY_CONFLICT`, `CLASSIFICATION_PAIR_INACTIVE` y códigos canónicos propagados con `field_path`.

## 4. Guardado e invalidación

Cada `PUT` exige `expected_version`, conserva la data opaca del paso y extrae referencias conocidas. Cambiar un paso completado invalida sus descendientes sin borrar su evidencia. Por ejemplo, cambiar `COLORES` marca `ESTRUCTURA`, `RUTA_EMPAQUE` y `REVISION` como `INVALIDADO`. Repetir la misma operación con su `Idempotency-Key` devuelve la misma respuesta.

Los pasos se pueden inspeccionar libremente, pero su materialización respeta prerequisitos en backend: IDENTIDAD antes de COMPONENTES y COMPONENTES antes de COLORES. Un salto fuera de orden responde `422 ONBOARDING_PREREQUISITE_REQUIRED` sin crear maestros.

En A, `validar` demuestra completitud estructural y devuelve handoffs a los maestros todavía no integrados. No certifica que el PT esté listo para planificar. TS-017C extiende esta misma operación con readiness canónico sin cambiar la ruta.

## 5. Frontend

Ruta canónica propuesta: `/datos-maestros/alta-producto`.

El shell contiene:

- encabezado sticky con título derivado de `IDENTIDAD` —o provisional mientras no se resuelva—, estado y “Guardado hace…”;
- rail de seis pasos con `PENDIENTE`, `EN_PROGRESO`, `COMPLETADO` o `INVALIDADO`;
- contenido central y acciones sticky **Atrás**, **Guardar**, **Guardar y continuar** y **Guardar y salir**;
- salida segura hacia una bandeja **Altas en curso**;
- navegación Atrás/Adelante del navegador que guarda primero el último snapshot local; si guardar falla o hay conflicto, conserva el paso y sus datos en lugar de reemplazarlos;
- reanudación de `BORRADOR`, `CON_BLOQUEOS` y `LISTA_PARA_PUBLICAR` en su `paso_actual` y última `version` persistida;
- foco restaurado al encabezado del paso después de navegar;
- versión móvil con rail resumido y panel de pasos desplegable.

Los pasos completados siempre se pueden reabrir. En A, los cinco pasos futuros se representan explícitamente como integración pendiente y ofrecen el handoff vigente; no fingen persistencia canónica.

## 6. Clasificación en contexto

La creación o reutilización de Familia usa exclusivamente `POST /api/catalogo/lineas/{linea_id}/familias`. Con `{ "familia": { ... } }` crea o reactiva la Familia y con `{ "familia_id": 123 }` vincula una Familia global existente; en ambos casos crea/reactiva `LineaFamilia` en una transacción. El frontend refresca el filtro de la Línea y selecciona el ID devuelto. Dentro del asistente queda prohibido `POST /api/catalogo/familias`, porque crea una Familia global sin vínculo con la Línea activa.

## 7. Autorización

- `ARTICULO_ADMINISTRAR`: crear/editar sesión y crear/reutilizar IDENTIDAD.
- La lectura de catálogos conserva sus capacidades existentes.
- Una sesión sólo es editable por su creador. `AUTORIZACION_SCM_ADMINISTRAR` permite auditar listado y detalle, no mutar ni finalizar una sesión ajena. No existe takeover implícito y `GERENTE_GENERAL` no omite el optimistic lock.

## 8. Pruebas

| Escenario | Nivel |
|---|---|
| AGP-A01 | API + UI de reanudación con recarga real del componente |
| AGP-A02 | integración PostgreSQL de optimistic lock |
| AGP-A03 | servicio/API; correlativo no avanza al reutilizar |
| AGP-A04 | integración de transacción Familia–LineaFamilia + UI |
| AGP-A05 | UI de navegación y invalidación dependiente |
| AGP-A06 | contrato/API de PT sin escritura lateral en Pieza |
| AGP-A07 | UI/API de Guardar y salir, título derivado y reanudación de estados abiertos |

### Primera RED

`test_step_save_is_opaque_versioned_and_invalidates_descendants`: debe fallar porque la entidad y el contrato durable todavía no existen.

### Baseline

- backend: suite de catálogo, clasificación y códigos correlativos;
- frontend: `ConfigurarProducto`, `ProductoDialogClassification`, navegación y permisos;
- registrar por separado cualquier fallo preexistente antes de RED.

## 9. Migración y compatibilidad

La ruta antigua permanece como alias durante un ciclo de despliegue. La implementación existente no se elimina en A, pero deja de ser la entrada recomendada. Las sesiones no migran estado React o `localStorage` anterior.

## 10. Puerta para TS-017B

- sesión durable, autosave, conflicto y reanudación verdes;
- IDENTIDAD crea o reutiliza PT sin duplicar;
- alta contextual Línea/Familia atómica;
- shell responsive y navegable por teclado.

Esta puerta completa únicamente A: shell + `IDENTIDAD` real. Los otros cinco pasos continúan visibles como handoffs honestos y se implementan en B/C; no se declara completa la solución integral ni su UAT.
