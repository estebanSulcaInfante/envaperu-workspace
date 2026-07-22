---
tipo: user-story
estado: en-desarrollo
tags: [backend, frontend, catalogo, color, receta, normalizacion, materia-prima, colorante]
relaciones:
  - "[[Lote_Color]]"
  - "[[Composicion_Materiales]]"
  - "[[Receta_Colorantes]]"
  - "[[US-001_Creacion_Agil_Molde_Producto_Pieza]]"
draft_origen: "obsidian_vault/05_Especificaciones/01_Drafts/Normalizacion del color e impresion de OP.md"
fecha_creacion: 2026-07-11
fecha_actualizacion: 2026-07-23
---

# US-006: Normalizar Composición del Color-Familia

> [!INFO]
> **Avance 2026-07-23:** el maestro CRUD de familias de color, colores y recetas, la paleta/HEX visual opcional, los estados borrador/aprobada/inactiva y el versionado están implementados según [[../03_Tech_Specs/TS-016_Maestro_Colores_y_Recetas|TS-016]]. La OP excepcional ya aplica la receta, calcula colorantes/aditivos sobre la fracción virgen y congela la referencia y revisión usadas. La autorización humana final permanece como trabajo transversal previo al despliegue multiusuario.

## 1. Contexto y Borrador Original

**Borrador (Draft):** "Normalizar Composición del COLOR-FAMILIA: Siendo sus componentes Materia Prima, Colorante, Aditivo por cada 25kg. No olvidar la existencia de Materias Primas de segunda. Tomar en cuenta que un color-familia puede ser generado por 1 o más composiciones de colores."

Actualmente, cuando el usuario crea una Orden de Producción y agrega un [[Lote_Color]], debe configurar **manualmente** para cada lote:
1. La **lista de materias primas** (tabla `se_compone`) con sus fracciones (ej. PP Clarif. 3/6, PP Iny. Molido 3/6).
2. La **lista de colorantes** (tabla `se_colorea`) con sus gramajes (ej. Azul Ultramar 120g, Dióxido de Titanio 10g).

Esto es repetitivo y propenso a errores, ya que la misma combinación de materiales y colorantes se repite cada vez que se produce el mismo color para la misma familia de productos. La propuesta es crear una **entidad de Receta de Color normalizada** a nivel de catálogo, de modo que al seleccionar un color en un lote, el sistema **precargue automáticamente** su composición estándar.

## 2. Actores

*   **Supervisor de Planta / Planificador:** Crea Órdenes de Producción y necesita configurar los lotes rápidamente sin recargar la misma composición de materiales y colorantes cada vez.
*   **Ingeniero de Procesos:** Define y mantiene las recetas estándar de cada color-familia (proporciones de materia prima, gramajes de colorante por cada 25kg de material virgen). Es quien valida que la composición sea correcta.
*   **Operador de Máquina:** Consulta la receta impresa en la hoja de ruta para preparar la mezcla. No modifica la receta, pero depende de su exactitud.

## 3. Análisis y Lagunas Lógicas Identificadas

### 3.1. Concepto de "Color-Familia" como Clave de Receta

*   **Laguna:** Actualmente, `ColorProducto` es una entidad simple (id, nombre, código, FK a `FamiliaColor`). No tiene ninguna composición asociada. La composición de materiales y colorantes vive **por lote** en la OP, lo que significa que se define cada vez desde cero.
*   **Resolución:** Crear una nueva entidad **`RecetaColor`** (o **`ComposicionColorFamilia`**) que vincule un `ColorProducto` + `FamiliaColor` con su receta estándar de materias primas, colorantes y aditivos. Esta receta actúa como **plantilla reutilizable**.

### 3.2. ¿Qué identifica una receta? Color o ColorProduccion?

*   **Laguna:** El draft dice "un color-familia puede ser generado por 1 o más composiciones de colores". 
*   **Resolución (confirmada):** De acuerdo al nuevo modelo de dominio (ver ADR 2026-07-11 Reemplazo ColorProducto), la clave natural de la receta es `(color_produccion_id, version)`. El `ColorProduccion` ya representa la combinación exacta de `ColorBase` + `FamiliaColor` (ej. "ROJO SOLIDO"). Un mismo `ColorProduccion` **puede tener múltiples recetas válidas** (ej. "Rojo Sólido fórmula A" vs "Rojo Sólido fórmula B"). Se añade un campo `nombre_variante` (string, requerido) para distinguirlas. Una de ellas se puede marcar como `es_default = True` para la precarga automática.

> [!NOTE]
> **Decisión cerrada:** El usuario confirmó que sí existen casos donde un mismo ColorProduccion tiene más de una receta válida. Se requiere el campo `nombre_variante`.

### 3.3. Componentes de la Receta: Materia Prima, Colorante, Aditivo

*   **Laguna:** El draft menciona tres componentes: Materia Prima, Colorante y Aditivo. Actualmente, el modelo solo distingue entre `MateriaPrima` (tipo: VIRGEN, SEGUNDA) y `Colorante`. No existe el concepto de "Aditivo" como entidad separada.
*   **Resolución (confirmada):** Los aditivos se expresan en gramos, igual que los colorantes. La base concreta debe quedar explícita por línea de receta; para colorantes se validó posteriormente que corresponde a **gramos por cada 25kg de material virgen**. Los aditivos se modelan dentro de la misma tabla `Colorante` añadiendo un campo `tipo` con valores: `'COLORANTE'` (default) o `'ADITIVO'`. Esto evita crear una tabla nueva y permite reutilizar la infraestructura de dosificación sin asumir que todas las líneas comparten base implícitamente.

> [!NOTE]
> **Decisión cerrada:** El usuario confirmó que los aditivos usan gramos. Se modelan como un `tipo` dentro de la tabla `Colorante` existente.

### 3.4. Materia Prima de Segunda

*   **Laguna:** El draft recuerda "no olvidar la existencia de Materias Primas de segunda". Actualmente, `MateriaPrima.tipo` ya soporta `'SEGUNDA'` (además de `'VIRGEN'`). Sin embargo, en la tabla `se_compone` (composición por lote), no hay ningún campo que distinga "primera mezcla" vs "segunda mezcla"; el tipo se infiere del material seleccionado.
*   **Resolución:** Asegurar que la receta normalizada pueda incluir materias primas de tipo `SEGUNDA` (molido) en su lista de fracciones. No se requiere cambio de modelo, solo asegurar que la UI de recetas permita seleccionar materiales de tipo `SEGUNDA`.

### 3.5. Unidad de referencia: "por cada 25kg"

*   **Laguna:** El draft dice que la composición se define "por cada 25kg". Actualmente los colorantes se dosifican en "gramos por dosis" y las materias primas en "fracción del total". La base de 25kg no está explícita en ningún modelo.
*   **Resolución actualizada con validación de negocio del 2026-07-15:** En la receta normalizada, los colorantes se registran en **gramos por cada bolsa de 25kg de material virgen**. Al crear un lote real, el sistema escala proporcionalmente según los kg de virgen declarados como base de la revisión. El material `SEGUNDA`, tanto recuperado internamente como comprado, no incrementa la dosis. Las materias primas siguen usando fracciones para definir la mezcla, pero el peso total y `meta_kg` no sustituyen la base de virgen.

> [!IMPORTANT]
> Una dosis de `500 g/25 kg virgen` aplicada a `70 kg` de virgen y `28 kg` recuperados produce `1.400 kg` de colorante. Calcular `1.960 kg` sobre la mezcla o `2.000 kg` sobre una meta de `100 kg` contradice la regla validada.

### 3.6. Precarga Automática vs. Edición Manual

*   **Laguna:** Si la receta se precarga automáticamente, ¿el Supervisor puede modificarla para un lote específico? (ej. una partida especial donde se cambia un colorante).
*   **Resolución:** La receta normalizada funciona como **template por defecto**. Al seleccionar un color en un lote, el sistema **copia** la receta estándar como punto de partida, pero el Supervisor puede editarla libremente antes de guardar. Los cambios en el lote no afectan la receta maestra del catálogo.

## 4. Criterios de Aceptación (BDD)

**Escenario 1: El Ingeniero crea una receta estándar para un color-familia**
*   **Given** que el Ingeniero de Procesos accede al catálogo de recetas de color
*   **When** crea una nueva receta seleccionando el color "Azul" y la familia "SOLIDO"
*   **And** define la composición de materia prima: PP Clarif. (VIRGEN) fracción 3/6, PP Iny. Molido (SEGUNDA) fracción 3/6
*   **And** define los colorantes: Azul Ultramar EP-24 = 120g, Dióxido de Titanio 2220 = 10g (por cada 25kg de material virgen)
*   **Then** la receta se guarda exitosamente en el catálogo
*   **And** queda disponible para ser precargada en futuras Órdenes de Producción.

**Escenario 2: El Supervisor crea un lote y la receta se precarga automáticamente**
*   **Given** que existe una receta estándar para el color "Azul" + familia "SOLIDO"
*   **And** el Supervisor está creando una nueva Orden de Producción para un producto de familia "SOLIDO"
*   **When** agrega un nuevo lote de color y selecciona "Azul"
*   **Then** la composición de materia prima del lote se precarga con las fracciones de la receta estándar (PP Clarif. 3/6, PP Iny. Molido 3/6)
*   **And** los colorantes del lote se precargan con los gramajes estándar (Azul Ultramar 120g, TiO2 10g)
*   **And** el Supervisor puede modificar cualquier valor antes de guardar.

**Escenario 3: No existe receta para la combinación color-familia**
*   **Given** que no existe una receta registrada para el color "Naranja" + familia "CARAMELO"
*   **When** el Supervisor agrega un lote con ese color a una OP
*   **Then** la composición del lote se crea **vacía** (sin materias primas ni colorantes precargados)
*   **And** el sistema muestra un aviso informativo: "No hay receta estándar para este color. Defina la composición manualmente."

**Escenario 4: La receta incluye materia prima de segunda (molido)**
*   **Given** que el Ingeniero está definiendo una receta para el color "Rojo" + familia "SOLIDO"
*   **When** agrega una materia prima de tipo `SEGUNDA` (ej. "PP Iny. Molido Segunda") con fracción 3/6
*   **Then** la receta se guarda correctamente con la materia de segunda incluida
*   **And** al precargar esta receta en un lote futuro, la materia de segunda aparece correctamente clasificada y diferenciada visualmente
*   **And** sus kg no incrementan la cantidad planificada de colorante.

**Escenario 5: La edición de la receta maestra no afecta OPs existentes**
*   **Given** que existen Órdenes de Producción con lotes que fueron precargados desde una receta
*   **When** el Ingeniero modifica la receta estándar del color "Azul" (cambia un gramaje de colorante)
*   **Then** las OPs existentes mantienen los valores que se copiaron al momento de crear el lote
*   **And** solo las nuevas OPs futuras usarán la receta actualizada.
