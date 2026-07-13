---
tipo: tech-spec
estado: propuesta
tags: [arquitectura, backend, modelos, api, migracion]
relaciones:
  - "[[US-008_Normalizacion_ColorProduccion]]"
  - "[[TS-001_Creacion_Agil_Molde_Producto_Pieza]]"
fecha_creacion: 2026-07-11
---

# TS-008: Normalización de Dominio: Reemplazo de ColorProducto

## 1. Visión General

Esta especificación técnica detalla los pasos para erradicar el modelo legado `ColorProducto` y reemplazarlo por la estructura relacional de `ColorBase` y `ColorProduccion`. Este cambio profundo afectará los modelos de datos, endpoints del catálogo y producción, así como los scripts de migración inicial.

## 2. Modelos de Base de Datos (SQLAlchemy)

### 2.1. Nuevos Modelos en `producto.py`

Se eliminará la clase `ColorProducto`. En su lugar, se crearán dos clases nuevas:

```python
class ColorBase(db.Model):
    """El pigmento puro, independiente de la familia comercial."""
    __tablename__ = 'color_base'
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(50), nullable=False, unique=True)  # Ej. "ROJO"
    # El código heredado es inconsistente. Si es necesario, puede ser un campo libre, pero se sugiere no usarlo como UNIQUE.

class ColorProduccion(db.Model):
    """La combinación operativa de un pigmento en un acabado."""
    __tablename__ = 'color_produccion'
    id = db.Column(db.Integer, primary_key=True)
    
    color_base_id = db.Column(db.Integer, db.ForeignKey('color_base.id'), nullable=False)
    color_base_rel = db.relationship('ColorBase', backref='colores_produccion')
    
    familia_color_id = db.Column(db.Integer, db.ForeignKey('familia_color.id'), nullable=False)
    familia_color_rel = db.relationship('FamiliaColor', backref='colores_produccion')
    
    # Campo opcional para referenciar un código legacy importado
    codigo_legacy = db.Column(db.Integer, nullable=True) 

    __table_args__ = (
        db.UniqueConstraint('color_base_id', 'familia_color_id', name='uix_color_base_familia'),
    )
```

### 2.2. Modificaciones a Modelos Existentes

#### `PiezaColor` (antigua `Pieza` en `producto.py`)
- **[MODIFY]** Cambiar FK `color_id` (que apuntaba a `color_producto`) por `color_produccion_id` (que apunta a `color_produccion.id`).
- **[MODIFY]** Actualizar constraint: `db.UniqueConstraint('pieza_id', 'color_produccion_id')`.

#### `ProductoTerminado` (`producto.py`)
- **[DELETE]** `cod_familia_color`
- **[DELETE]** `familia_color`
- **[DELETE]** `familia_color_id` y su `relationship`.
- **[Nota]** La autogeneración de SKU se basará exclusivamente en las `PiezaColor` vinculadas a través de `ProductoComponente` (BOM).

#### `LoteColor` (`orden.py` / `lote.py`)
- **[MODIFY]** Reemplazar `color_id` (FK a `color_producto`) por `color_produccion_id` (FK a `color_produccion`).

#### `RecetaColor` (`receta_color.py` o análogo en US-006)
- **[MODIFY]** La clave primaria o FK debe apuntar a `color_produccion_id`, más el campo de variante.

#### `Pesaje` (`modulo-pesaje/backend/app/models/pesaje.py`)
- **[MODIFY]** El campo color se mantiene como `String` para servir de *snapshot*, desvinculado de la integridad referencial para evitar errores si cambia el catálogo. Apuntar a `lote_salida_pieza_color_id` para trazabilidad de la pieza física real.

## 3. Estrategia de Migración de Base de Datos (Alembic)

Dado que se trata de un cambio destructivo y de reestructuración mayor en una BD (potencialmente con datos de prueba, aunque se indica que los SKUs reales vienen del migrador), la estrategia será:

1. **Drop tables dependientes:** Limpiar temporalmente tablas que dependen de `color_producto` (si es un entorno de desarrollo/testing). Si hay datos de producción, se requiere un script de migración complejo. *Se asume entorno Dev/Test donde se puede repoblar desde seeders/migradores.*
2. **Creación:** Generar tabla `color_base`.
3. **Creación:** Generar tabla `color_produccion`.
4. **Modificación:** Actualizar `pieza_color`, `producto_terminado`, `lote_color` y sus constraints.
5. **Drop:** Eliminar tabla `color_producto`.

## 4. Endpoints API (`rutas_catalogo.py` y `rutas_produccion.py`)

### 4.1. `GET /api/catalogo/colores`
- **[MODIFY]** Este endpoint debe devolver una estructura anidada o dos listas: una de `ColorBase` y otra de `ColorProduccion` (o simplemente `ColorProduccion` con los nombres unificados "ColorBase + Familia", ej: `{"id": 1, "nombre": "ROJO SÓLIDO"}`).
- Esto permite que el Frontend cargue el select de colores directamente con la combinación lista.

### 4.2. `POST /api/catalogo/configurar-producto`
- **[MODIFY]** El payload debe recibir `color_produccion_id` en lugar de `color_id` simple.
- **[MODIFY]** Eliminar toda la lógica que asignaba `familia_color` al PT.

### 4.3. `GET /api/catalogo/validar-orden-prereq`
- **[MODIFY]** Debe recibir `molde_id` y `color_produccion_id`. La búsqueda del SKU compatible (`ProductoTerminado`) debe hacerse buscando qué PT tiene un BOM (`ProductoComponente`) cuyas `PiezaColor` coincidan con el molde y el `color_produccion_id` dado.

## 5. Scripts de Soporte (`migrar_skus.py`)

El script de importación masiva debe ser reescrito casi en su totalidad para la sección de colores:

- **[MODIFY] Extracción de ColorBase:** Extraer los nombres puros de colores de la hoja de Piezas, limpiando sufijos y normalizando, y poblar la tabla `ColorBase`.
- **[MODIFY] Extracción de FamiliaColor:** Poblar a partir de los tipos de color identificados (SOLIDO, CARAMELO, etc.).
- **[MODIFY] Construcción de ColorProduccion:** Cruzar las piezas reales del Excel para crear las combinaciones de `ColorProduccion` que realmente existan.
- **[MODIFY] Mapeo de BOM:** Las relaciones ProductoTerminado -> PiezaColor deben construirse asociando el código SKU importado y resolviendo sus piezas, sin forzar coincidencias difusas de color (ej. ignorar el campo "Familia Color" del ProductoTerminado).

## 6. Frontend

### 6.1. Creación Ágil (Wizard)
- Cambiar el selector de "Color" para que consuma `/api/catalogo/colores` (que ahora retorna la combinación `ColorProduccion`).
- Los labels deben mostrar `ColorBase.nombre + " " + FamiliaColor.nombre` (ej. "ROJO SOLIDO").

### 6.2. Órdenes de Producción
- El formulario de Lotes (`OrdenForm.jsx` o similar) debe permitir seleccionar el `ColorProduccion`, no el color base aislado.

## 7. Plan de Ejecución (Fases)

| Fase | Tarea | Riesgo |
|:---|:---|:---|
| **Fase 1** | Modelos y migraciones Alembic (DB) | 🔴 Alto |
| **Fase 2** | Endpoints de catálogo (GET colores, config producto) | 🟡 Medio |
| **Fase 3** | Ajustes en OPs (LoteColor, prerequisitos, recetas) | 🟡 Medio |
| **Fase 4** | Refactorización de `migrar_skus.py` | 🔴 Alto |
| **Fase 5** | Frontend: Actualización de selects y etiquetas | 🟢 Bajo |
| **Fase 6** | Tests: Arreglar fixtures y asserts rotos | 🟡 Medio |
