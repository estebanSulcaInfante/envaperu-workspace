---
tipo: tech-spec
estado: draft
tags: [catalogo, trabajadores, maquinistas, maquinas, frontend, backend, normalizacion, trazabilidad]
user_story: "[[US-009_Normalizar_Trabajadores_Maquinas_y_Vistas_Catalogo]]"
fecha_creacion: 2026-07-12
---

# TS-009: Normalizar Trabajadores y Máquinas y Actualizar las Vistas de Catálogo

## 1. Objetivo
Normalizar los trabajadores (operadores/maquinistas) y las máquinas de producción mediante la creación de entidades de catálogo maestras. Eliminar los campos legacy residuales de la normalización de colores (US-008) en las vistas de ProductoTerminado y PiezaColor, y adaptar la sincronización offline, el OCR y el registro de producción (RDP) al nuevo esquema.

## 2. Modelos de Datos a Crear/Modificar

### 2.1. Nuevos Modelos (app/models/trabajador.py)

#### `RolOperativo`
Catálogo de roles disponibles (MAQUINISTA, OPERADOR_PESAJE, etc.).
- `id` (PK, Integer)
- `codigo` (String, UNIQUE)
- `nombre` (String)
- `activo` (Boolean, default=True)

#### `Trabajador`
Entidad maestra de la persona operativa.
- `id` (PK, Integer)
- `codigo` (String, UNIQUE) - Estable y no reutilizable (ej. TR-001)
- `nombres` (String)
- `apellidos` (String)
- `nombre_corto` (String, nullable=True) - Para tickets/impresión.
- `activo` (Boolean, default=True)
- `observaciones` (Text, nullable=True)
- Relación: `roles` (N:M con `RolOperativo` vía tabla `trabajador_rol`)

#### `TrabajadorRol`
Tabla intermedia (N:M).
- `trabajador_id` (FK a Trabajador)
- `rol_operativo_id` (FK a RolOperativo)

### 2.2. Modificación de `Maquina` y creación de `TipoMaquina` (app/models/maquina.py)

#### `TipoMaquina` (Nuevo)
- `id` (PK, Integer)
- `codigo` (String, UNIQUE)
- `nombre` (String)
- `proceso` (String) - INYECCION, SOPLADO, OTRO.
- `fabricante` (String, nullable=True)
- `modelo` (String, nullable=True)
- `capacidad_toneladas` (Float, nullable=True)
- `activo` (Boolean, default=True)

#### `Maquina` (Actualizado)
- `id` (PK, Integer)
- `codigo` (String, UNIQUE) - Código estable (ej. INY-05).
- `nombre` (String)
- `tipo_maquina_id` (FK a `TipoMaquina`)
- `estado` (String, default='OPERATIVA') - OPERATIVA, MANTENIMIENTO, FUERA_SERVICIO, BAJA.
- `activo` (Boolean, default=True)
- `numero_serie` (String, nullable=True)
- `observaciones` (Text, nullable=True)
- *Migración*: Convertir `tipo` (String) a una relación a `TipoMaquina`.

### 2.3. Modificaciones en Registros Operativos (app/models/registro.py, orden.py)

#### `DetalleProduccionHora`
- **Añadir**: `trabajador_id` (FK a `Trabajador`, nullable temporalmente para histórico).
- **Renombrar/Mantener**: `maquinista` -> `maquinista_snapshot` (String) para conservar el texto histórico.

#### `RegistroDiarioProduccion` & `OrdenProduccion`
- **Añadir**: `maquina_codigo_snapshot`, `maquina_nombre_snapshot` (Strings) para preservar el estado histórico de la máquina asignada.

## 3. Endpoints de Backend

### 3.1. Trabajadores y Roles (`app/api/rutas_trabajadores.py` o dentro de `rutas_catalogo.py`)
- `GET /api/catalogo/trabajadores`: Lista con paginación, filtros (`q`, `rol`, `activo`).
- `POST /api/catalogo/trabajadores`: Creación (genera código auto-secuencial si no se provee).
- `GET /api/catalogo/trabajadores/<id>`
- `PUT /api/catalogo/trabajadores/<id>`
- `PATCH /api/catalogo/trabajadores/<id>/estado`
- `GET /api/catalogo/roles-operativos`

### 3.2. Máquinas y Tipos (`app/api/rutas_maquinas.py` o dentro de `rutas_catalogo.py`)
- `GET /api/catalogo/maquinas`: Lista con filtros (`q`, `estado`, `tipo`, `activo`).
- `POST /api/catalogo/maquinas`
- `PUT /api/catalogo/maquinas/<id>`
- `PATCH /api/catalogo/maquinas/<id>/estado`
- `GET /api/catalogo/tipos-maquina`
- `POST /api/catalogo/tipos-maquina`

### 3.3. Refactor Catálogo Piezas & Productos (`app/api/rutas_catalogo.py`)
- **Limpieza (Continuación US-008)**: 
  - Asegurar que `GET /api/catalogo/productos` no envíe/reciba `familia_color_id` u otros atributos descartados.
  - Asegurar que `POST/PUT /api/catalogo/piezas-color` exija `color_produccion_id` y `pieza_id`, y no `ColorProducto`.
- **Rutas explícitas**:
  - `GET /api/catalogo/piezas`: Solo formas abstractas (`Pieza`).
  - `GET /api/catalogo/piezas-color`: SKUs físicos (`PiezaColor`).

## 4. Frontend - Componentes y Vistas

### 4.1. Vistas de Administración (Nuevas)
- `TrabajadoresAdmin.jsx`: Tabla CRUD para listar, crear, editar y desactivar Trabajadores. Autocomplete para asignar múltiples roles.
- `MaquinasAdmin.jsx`: Tabla CRUD para listar, crear, editar y cambiar el estado de las Máquinas y los Tipos de Máquina.

### 4.2. Ajustes en Vistas Existentes
- `RegistroForm.jsx` / Fila de RDP:
  - Reemplazar el input de texto libre "Maquinista" por un `Autocomplete` (react-select o MUI) apuntando a `/api/catalogo/trabajadores?rol=MAQUINISTA`.
  - La acción de "copiar hacia abajo" debe replicar tanto el `trabajador_id` como el `maquinista_snapshot`.
  - La máquina se hereda obligatoriamente de la OP y debe validar que esté `OPERATIVA`.
- `OrdenForm.jsx`:
  - En la selección de máquina, mostrar solo máquinas con `activo=true` y `estado='OPERATIVA'`.
- `PiezasAdmin.jsx`, `PiezaDialog.jsx`, `ProductosAdmin.jsx`, `ProductoDialog.jsx`:
  - Retirar por completo las etiquetas "Color Producto", selectores de `familia_color_id` de los PT.
  - En `ProductoDialog`, el color cromático solo se deduce leyendo las `PiezaColor` dentro del BOM (Componentes).
- `CatalogoSKU.jsx` (Legacy):
  - Retirar y dividir accesos directos desde el Sidebar a `Piezas`, `Piezas Color` (físicas) y `Productos Terminados`.

### 4.3. Módulo Offline / Sincronización
- Modificar el script de sincronización del PWA para cachear `Trabajador` y `Maquina` por ID/Código, eliminando arreglos quemados de nombres.
- Modificar payload `POST` de pesajes u operaciones offline para enviar `trabajador_id` central, manteniendo el texto como fallback u `operador_snapshot`.

## 5. Migración de Base de Datos (Alembic / Scripts)

Se creará un script de migración `migrar_trabajadores_maquinas.py` que ejecutará las siguientes fases:
1. **Schema**: Crear las nuevas tablas (`trabajador`, `rol_operativo`, `trabajador_rol`, `tipo_maquina`).
2. **Schema**: Añadir las columnas de snapshot FKs en `detalle_produccion_hora`, `registro_diario_produccion` y modificar `maquina`.
3. **Data**: Insertar roles operativos base (MAQUINISTA, SUPERVISOR, etc.).
4. **Data**: Convertir los valores distintos textuales de `detalle_produccion_hora.maquinista` en Trabajadores iniciales si su coincidencia es alta (limpiar espacios). Lo ambiguo queda pendiente de mapeo manual o en snapshot.
5. **Data**: Migrar `maquina.tipo` de texto a un registro en `tipo_maquina`, reasignar `tipo_maquina_id`, establecer `codigo` base para las máquinas, y marcarlas como `OPERATIVA`.

## 6. Verificación (Testing)

Se deben crear tests unitarios e integrales (pytest):
- `test_trabajador.py`: Crear un trabajador, validar que los códigos sean únicos. Asignar múltiples roles y comprobar persistencia N:M. Validar la baja lógica (activo=False).
- `test_maquina.py`: Crear `TipoMaquina` y `Maquina`. Tratar de cambiar una máquina a `MANTENIMIENTO` y verificar que el sistema controle las OPs.
- `test_registro_produccion.py`: Crear un RDP, añadir una fila horaria con un trabajador inactivo (debe fallar) o activo (debe guardar `trabajador_id` y `maquinista_snapshot`).
- `test_offline_sync.py` (si existe): Verificar que se sincronice el `trabajador_id` en las salidas físicas.
