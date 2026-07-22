---
tipo: tech-spec
estado: implementada
tags: [catalogo, color, receta, frontend, backend, api]
relaciones:
  - "[[../02_User_Stories/US-006_Normalizar_Composicion_Color_Familia|US-006]]"
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-23
---

# TS-016: Maestro de colores y recetas

## Objetivo

Permitir que el usuario mantenga colores de producción y cree sus propias recetas reutilizables desde `/datos-maestros/colores`. La OP excepcional puede aplicar una receta aprobada, copiar sus componentes editables y conservar una referencia histórica explícita a la revisión usada.

## Modelo

### ColorProduccion

- `hex_referencia`: `#RRGGBB` opcional y exclusivamente visual. La UI ofrece selector nativo de paleta, colores frecuentes y edición HEX exacta.
- `activo`: baja lógica.
- `version`: control de concurrencia optimista.
- Se conserva la unicidad de `color_base_id + familia_color_id`.

### FamiliaColor

- Catálogo administrable de acabados como `SOLIDO`, `CARAMELO`, `TRANSPARENTE` y `PASTEL`.
- `activo`: baja lógica; una familia inactiva no aparece en nuevas selecciones, pero conserva sus colores existentes.
- `version`: control de concurrencia optimista.
- `nombre` y `codigo` permanecen únicos.

### RecetaColorMaestra

- Pertenece a un `ColorProduccion`.
- Puede ser genérica o estar acotada por `producto_sku`.
- Identidad de negocio: color, alcance de producto, variante y revisión.
- Estados: `BORRADOR`, `APROBADA`, `INACTIVA`.
- Una sola receta aprobada puede ser predeterminada por color y alcance.
- Editar una receta aprobada crea una revisión nueva e inactiva la anterior; un borrador se edita en sitio usando `version`.

### RecetaColorLinea

- `MATERIA_PRIMA`: cantidad en `FRACCION`.
- `COLORANTE` o `ADITIVO`: cantidad en `GRAMOS` y `base_kg` explícita.
- Para aprobar, las fracciones de materias primas deben sumar exactamente `1`.
- La dosis absoluta solo se calcula cuando el consumidor declara `kg_virgen_base`; la materia de segunda no aumenta la dosis.

`Colorante.tipo` distingue `COLORANTE` y `ADITIVO`. Los componentes se seleccionan desde el catálogo común `ScmMaterial`, por lo que no se guardan nombres libres dentro de la receta.

## API

| Método | Ruta | Uso |
|---|---|---|
| GET/POST | `/api/colores` | Listar y crear colores |
| PUT/DELETE | `/api/colores/{id}` | Editar o inactivar un color |
| GET/POST | `/api/familias-color` | Listar y crear familias de color |
| PUT/DELETE | `/api/familias-color/{id}` | Editar o inactivar una familia |
| GET | `/api/catalogo/ingredientes-receta-color` | Ingredientes elegibles |
| GET/POST | `/api/catalogo/recetas-color` | Listar y crear recetas propias |
| GET/PUT/DELETE | `/api/catalogo/recetas-color/{id}` | Detalle, nueva revisión/edición e inactivación |
| GET | `/api/catalogo/receta-color` | Resolver primero la receta maestra aprobada y, si no existe, una sugerencia histórica |

La receta ingresada y aprobada por una persona es la fuente autoritativa. `RecetaColorNormalizada`, aprendida de OP anteriores, permanece únicamente como sugerencia y nunca sobrescribe una fórmula aprobada.

## Interfaz

La pestaña **Datos maestros > Colores y recetas** permite:

- crear, editar, inactivar y reactivar colores;
- escoger un color desde una paleta o colores frecuentes, editar su HEX y ver la muestra visual;
- abrir **Gestionar familias** para crear, editar, inactivar y reactivar familias de color;
- crear recetas vacías o completas;
- agregar/remover materias primas, colorantes y aditivos;
- guardar borradores incompletos;
- aprobar, marcar como predeterminada y versionar una receta;
- consultar recetas activas o históricas inactivas.

## Integridad y pruebas

- Validaciones de dominio y restricciones de base impiden estados, unidades y componentes incompatibles.
- La unicidad parcial de PostgreSQL impide dos recetas predeterminadas aprobadas para el mismo alcance.
- Hay pruebas de API para CRUD de color, HEX, borradores, aprobación, revisión y receta predeterminada.
- Hay una prueba aislada de migración y pruebas UI para crear un color y una receta propia aprobada.
- Cuando el formulario aplica una receta maestra, envía `receta_aplicada: {id, revision}`. El backend vuelve a comprobar estado aprobado, revisión, color y alcance de producto dentro de la transacción.
- `LoteColor` conserva la FK al maestro y snapshots de revisión, nombre de variante y base virgen. Una edición futura del catálogo no reescribe la evidencia de la OP.

## Pendiente transversal

- Aplicar permisos por rol cuando se cierre el desarrollo transversal de autorización.
