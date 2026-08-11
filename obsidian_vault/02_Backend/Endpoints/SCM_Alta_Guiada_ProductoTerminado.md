---
tipo: endpoint_api
estado: implementado-local-pendiente-uat
tags: [backend, catalogo, wizard, producto-terminado, idempotencia]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
relaciones:
  - "[[../../01_Dominio/Sesion_Alta_Producto]]"
  - "[[../../05_Especificaciones/03_Tech_Specs/TS-017A_Sesion_Durable_y_Shell_de_Alta_Guiada]]"
  - "[[../../05_Especificaciones/03_Tech_Specs/TS-017B_Configuracion_Fisica_Formulaciones_y_UX_Premium]]"
  - "[[../../05_Especificaciones/03_Tech_Specs/TS-017C_Ingenieria_Readiness_y_Publicacion_Guiada]]"
---

# API de Alta Guiada de ProductoTerminado

## Propósito

Persistir y orquestar una sesión de alta sin duplicar reglas de ProductoTerminado, Molde/Pieza, Color/Receta, BOM, Ruta o Empaque.

## Prefijo

`/api/scm/v1/altas-producto`

## Operaciones

| Método | Ruta | Efecto |
|---|---|---|
| `POST` | `/` | Crea una sesión con `Idempotency-Key`. |
| `GET` | `/` | Lista sesiones por estado y búsqueda. |
| `GET` | `/{id}` | Devuelve pasos, fuentes, referencias, readiness y versión. |
| `PUT` | `/{id}/pasos/{codigo}` | Guarda un paso opaco con optimistic lock e invalida descendientes. |
| `POST` | `/{id}/pasos/{codigo}/aplicar` | Ejecuta la materialización idempotente de la fase y persiste sus referencias. |
| `POST` | `/{id}/imagenes/{entity_type}/{entity_id}` | Asocia una imagen multipart idempotente a un PT/PiezaColor de la sesión. |
| `POST` | `/{id}/validar` | Recalcula completitud estructural, readiness y handoffs. |
| `POST` | `/{id}/finalizar` | Finaliza sólo cuando la validación vigente lo permite. |

## Guardado de paso

```json
{
  "expected_version": 4,
  "estado_paso": "COMPLETADO",
  "data": {
    "modo": "NUEVO",
    "producto_ref": "PT-000321",
    "procedencia": {"tipo": "EXCEL", "referencia": "SKU PIEZAS 2026"}
  }
}
```

`codigo` pertenece al conjunto `IDENTIDAD`, `COMPONENTES`, `COLORES`, `ESTRUCTURA`, `RUTA_EMPAQUE`, `REVISION`. La respuesta `200` incrementa `version` e informa `invalidated_steps`. `409 VERSION_CONFLICT` incluye `current_session`, pero no mezcla valores automáticamente.

`GET /{id}` incluye por paso un `application_status` resumido (`APPLIED|PARTIAL`, `application_key`, created/reused/pending y referencias resueltas). No expone el journal crudo. Con ello otro navegador reanuda una operación parcial sin depender de `localStorage` y reconoce una fase ya aplicada.

## Aplicación de fase

```json
{
  "expected_version": 4,
  "application_key": "3db7d0f9-0a21-46a6-aa5b-e7e833214742",
  "data": {"modo": "NUEVO", "producto": {"producto": "COLADOR #3"}}
}
```

El comando llama al servicio canónico y guarda la referencia dentro de la misma operación. Una aplicación parcial conserva checkpoints. Su reintento usa la misma `application_key`; acepta correcciones en unidades pendientes y verifica por ID la equivalencia de unidades ya resueltas. Una aplicación completa no admite crear sustitutos silenciosos.

`ESTRUCTURA` y `RUTA_EMPAQUE` son unidades atómicas: sus servicios canónicos se ejecutan sin `commit` interno y la sesión confirma una sola vez. Un fallo revierte maestros, vínculos, eventos y operación idempotente. Para volver a aplicar una fase C ya materializada se exige `supersedes_application_key` apuntando a la aplicación vigente; el journal anterior permanece como historial.

## Imágenes de sesión

`POST /{id}/imagenes/{entity_type}/{entity_id}` usa `multipart/form-data`:

- `imagen`: archivo JPEG, PNG o WEBP de máximo 2 MB;
- `expected_version`: entero;
- `application_key`: string estable;
- `entity_type`: `PRODUCTO_TERMINADO` o `PIEZA_COLOR`.

La entidad debe estar resuelta dentro de la misma sesión. La respuesta agrega:

```json
{
  "image_results": {
    "status": "APPLIED|REPLAYED",
    "application_key": "imagen-pt-principal",
    "entity_type": "PRODUCTO_TERMINADO",
    "entity_id": "PT-000321",
    "mime_type": "image/webp",
    "size_bytes": 183420,
    "sha256": "...",
    "imagen_url": "/api/productos/PT-000321/imagen"
  }
}
```

El servidor decodifica la imagen, verifica formato↔MIME, carga completa, máximo 25 millones de píxeles y ausencia de contenido polyglot posterior; no guarda base64. En S3 usa una clave content-addressed por SHA-256, preserva la anterior hasta confirmar la transacción y limpia best-effort el objeto nuevo si el commit falla. `GET /{id}` agrega `imagenes[]` con el último resultado por entidad. Errores gobernados: `404` por sesión/entidad fuera de alcance, `409` por conflicto idempotente, `413` por tamaño, `415` por tipo/contenido y `503` por almacenamiento.

## Idempotencia y validación

POST, PUT, aplicar, validar y finalizar requieren `Idempotency-Key`. Cada petición HTTP nueva usa una clave de operación nueva; la `application_key` del intento de fase permanece estable durante un PARTIAL. Una misma `Idempotency-Key` con otro comando responde `409 IDEMPOTENCY_CONFLICT`.

La autoridad de secuencia vive en backend. COMPONENTES exige IDENTIDAD materializada; COLORES exige COMPONENTES materializado. Una formulación sólo puede referenciar colores declarados por la propia fase.

`validar` consulta los objetos canónicos y devuelve `BLOCKED`, `PENDING_APPROVAL` o `READY`, con `items`, bloqueos, advertencias y handoffs. Recorre BOM/WIP de forma recursiva y coteja las revisiones de estructura, ruta y empaque elegidas por la sesión.

`finalizar` incompleto responde `422 SESSION_NOT_READY`, persiste `CON_BLOQUEOS` y no completa pasos por el usuario.

## Autorización

La sesión exige `ARTICULO_ADMINISTRAR`. Sólo su creador puede mutarla. Un actor con `AUTORIZACION_SCM_ADMINISTRAR` puede listar y leer sesiones ajenas para auditoría, pero recibe `404` al intentar guardarlas, aplicarlas, validarlas o finalizarlas. En B/C, cada integración adicional conserva además las capacidades de Materiales, Estructuras, Rutas, Empaque y publicación; el contrato de sesión nunca las sustituye.

## Compatibilidad

`POST /api/configurar-producto` no forma parte de esta API. Puede mantenerse temporalmente como fachada Molde–Pieza–PiezaColor, pero su rama legacy de ProductoTerminado/BOM plano no se invoca ni se documenta como alternativa.
