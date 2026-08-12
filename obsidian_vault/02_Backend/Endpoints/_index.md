---
tipo: modulo
estado: placeholder
tags: [backend, api, endpoints]
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-08-11
---

# Backend — Endpoints API

> Este directorio documenta cada endpoint de la API REST del backend.

## Formato de Documentación

Cada archivo documenta un endpoint o grupo de endpoints con:
- Método HTTP y ruta
- Parámetros de entrada
- Estructura de respuesta JSON
- Reglas de negocio asociadas
- Entidades de dominio involucradas

## Endpoints Conocidos
- `/api/scm/v1/altas-producto` → [[SCM_Alta_Guiada_ProductoTerminado]]; sesión durable, pasos versionados y readiness de US-012.
- `GET /api/auth/me` y validación del JWT de Supabase → [[Autenticacion_Supabase_SCM]].
- `GET /api/catalogo/capacidades`, CRUD de `/roles-operativos` y asignación de
  rol principal → [[Catalogo_Roles_Capacidades_Workspace]].
- `GET /api/ordenes/<id>` → Adaptador técnico legacy; modelo objetivo [[Orden_Fabricacion]]
- `/api/scm/ordenes-produccion` → Nueva [[Orden_Produccion]] de demanda (TS-010P)
- `GET /api/ordenes/<op>/registros` → Ver [[Registro_Diario]]
- `/api/scm/v1/articulos/{id}/estructuras` y `/estructuras/{id}` → [[SCM_Estructuras_BOM]].
- `/api/scm/v1/productos/{sku}/rutas`, `/rutas/{id}` y `/centros-trabajo` → [[SCM_Rutas_Produccion]].
- `/api/scm/v1/tipos-contenedor`, `/perfiles-empacables` y `/reglas-empaque` → [[SCM_Perfiles_y_Reglas_Empaque]].
- `/api/scm/v1/ordenes-fabricacion/{of}/plan-mangas`, `/ots/fabricacion`,
  `/ots/{ot}/trabajos-color`, `/trabajos-color/{id}/mangas` y trabajos técnicos
  de impresión → [[SCM_OT_Mangas_y_Etiquetas_Prepesaje]].
- `/api/scm/v1/inventario/*` y `/ordenes-produccion/{id}/ajustar-metas` → [[SCM_Inventario_y_Ajuste_Plan]].
- `/api/scm/v1/materiales-ejecucion`, requerimientos por OF, reservas, emisiones, devoluciones y premezclas → [[SCM_Materiales_OF_Reserva_Emision_Premezcla]].
- `/api/scm/v1/recepcion-mangas/*` → [[SCM_Recepcion_Mangas_Kardex]]; recepción QR, existencia física y Calidad posterior.
- `/api/scm/v1/almacenes`, `/operaciones-almacen`, `/transferencias` y read
  model scoped de inventario → [[SCM_Operaciones_Almacen_y_Transferencias]];
  contrato aprobado por TS/DEV-018, todavía no implementado.
- `/api/scm/v1/ordenes-armado/{id}/plan-mangas`, `/ots/{id}/mangas-salida`, `/mangas/{id}/cerrar-armado` y `/genealogia` → [[SCM_Armado_Cierre_Mangas_PT]].

### Clasificación de catálogo

- CRUD lógico/versionado de `/api/catalogo/lineas` → [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]] y [[Linea]].
- CRUD lógico/versionado de `/api/catalogo/familias` → [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]] y [[Familia]].
- Asociación `/api/catalogo/lineas/{linea_id}/familias` → [[LineaFamilia]].
- `GET /api/catalogo/familias?linea_id={id}` filtra mediante asociaciones N:M activas.

### Piezas, variantes e imágenes

- `GET /api/piezas` y CRUD relacionado → catálogo jerárquico [[Pieza]]/[[PiezaColor]].
- `POST /api/moldes/{codigo}/colores` → habilitación atómica de un color para todas las salidas activas del molde.
- `GET|PUT|DELETE /api/piezas-color/{sku}/imagen` → imagen de la variante física.
- Contratos y errores: [[Catalogo_Piezas_SKU_e_Imagenes]].

> **TODO:** Documentar todos los endpoints del backend aquí conforme se desarrollen.
