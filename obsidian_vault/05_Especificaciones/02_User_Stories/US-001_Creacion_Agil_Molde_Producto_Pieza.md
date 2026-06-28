---
tipo: user_story
id: US-001
titulo: Creación Ágil de Molde-Producto-Pieza
estado: draft
draft_origen: "[[01_Drafts/Creacion de Molde-Producto-Pieza]]"
tags:
  - catalogo
  - molde
  - producto
  - pieza
  - config-rapida
  - integridad
fecha_creacion: 2026-06-08
actores:
  - Supervisor de Planta
  - Planificador de Producción
---

# US-001: Creación Ágil de Molde-Producto-Pieza

## Contexto y Motivación

Actualmente existe la vista **Catálogo > Configuración Rápida** (`/catalogo/configurar`) que permite crear la tripla Molde → Pieza(s) → ProductoTerminado en una sola operación tipo wizard (4 pasos). Sin embargo, se han detectado los siguientes problemas de integridad y modelado que no reflejan la realidad productiva de la fábrica:

### Problemas Identificados

1. **Color asociado al nivel incorrecto.** En el flujo actual los colores se seleccionan en el paso del Molde (Paso 1). Conceptualmente, un molde es el bloque de acero — no tiene color. Los colores se combinan con las **Piezas (Formas puras)** para generar los SKUs físicos de inventario (**PiezaColor**), por lo que el color no es propiedad del molde en sí.

2. **`FamiliaColor` en `ProductoTerminado` es solo descriptiva.** El campo `familia_color` del PT (SOLIDO, CARAMELO, TRANSPARENTE…) es meramente clasificatorio para el catálogo comercial. No debe participar en conteos, cálculos de producción ni lógica de generación de SKU en el wizard.

3. **Integridad cuestionable en la generación en cascada.** El endpoint `POST /api/catalogo/configurar-producto` presenta:
   - Variable `resultado` referenciada antes de ser definida (línea 745: `resultado['errores']` vs. `response_data`).
   - `db.session.add(kit_pieza)` duplicado (líneas 853-854 y 856-857).
   - La generación de SKU es frágil: depende de truncamientos de strings (`[:10]`) y sustituciones de prefijos (`MOL-`) que pueden colisionar.

4. **Líneas y Familias están hardcodeadas en el frontend.** Las constantes `LINEAS` y `FAMILIAS` del componente `ConfigurarProducto.jsx` no se leen del backend, lo cual genera desfase si se agregan nuevas líneas/familias en la base de datos.

5. **El modelo permite colores independientes por variante dentro del mismo molde.** Actualmente, la tabla que guarda el SKU físico (hoy mal llamada `Pieza`) tiene un atributo `color_id` individual. Esto permite crear combinaciones físicamente imposibles como "Tapa Roja + Pico Azul" saliendo del mismo molde. En la realidad productiva, **todas las cavidades de un molde se inyectan con el mismo color en la misma colada** — si hay tapa roja, también hay pico rojo. El color es una propiedad de la **colada/golpe**, no del SKU individual.

---

## Historias de Usuario

### US-001a: Reubicar selección de color al nivel correcto y aplicar color por colada

**Como** Planificador de Producción  
**Quiero** seleccionar los colores de inyección después de definir las formas puras (**Piezas**) del molde, y que el color seleccionado se aplique automáticamente a **todas** las formas del molde por igual  
**Para** que el modelo refleje la realidad productiva: el molde define la geometría, el color se aplica por colada (a todas las cavidades simultáneamente), y no existan combinaciones imposibles como "Tapa Roja + Pico Azul" del mismo molde.

> ⚠️ **Regla de Negocio Crítica:** En inyección de plásticos, todas las geometrías de un golpe/colada salen del **mismo color**. Si un molde produce "Tapa" + "Pico", ambas serán rojas O ambas serán azules — nunca una de cada color. El color es propiedad de la colada, no de las variantes individuales.

#### Criterios de Aceptación

**Escenario 1: Crear un molde nuevo sin colores**
- **Dado** que el usuario está en Configuración Rápida y elige crear un molde nuevo
- **Cuando** completa el Paso 1 (Molde) con nombre, código, peso tiro y tiempo de ciclo
- **Entonces** el Paso 1 NO muestra selector de colores; el selector aparece después de definir las formas (Paso 2)

**Escenario 2: Un color aplica a todas las formas del molde**
- **Dado** que el usuario ha definido 2 formas ("Tapa Regadera" y "Base Regadera") y selecciona el color "Rojo"
- **Cuando** el sistema genera las Piezas coloreadas
- **Entonces** se crean ambas: "Tapa Regadera Rojo" y "Base Regadera Rojo", ambas con `color_id = Rojo`; **nunca** se permite crear "Tapa Roja" sin "Base Roja" o viceversa

**Escenario 3: Múltiples colores generan conjuntos completos**
- **Dado** que el molde tiene N formas y el usuario selecciona C colores
- **Cuando** el sistema genera Piezas coloreadas
- **Entonces** se crean N × C piezas, organizadas en C conjuntos de N piezas cada uno, donde cada conjunto comparte el mismo color (ej: {Tapa Roja, Base Roja}, {Tapa Azul, Base Azul})

**Escenario 4: No seleccionar colores (flujo sin color)**
- **Dado** que el usuario no selecciona ningún color
- **Cuando** avanza al paso de revisión y confirma
- **Entonces** el sistema crea solo las formas puras (**Piezas**, actualmente `MoldePieza`) sin generar los SKUs coloreados de inventario (**PiezaColor**, actualmente `Pieza`), y no arroja errores

---

### US-001b: Familia de Color como campo descriptivo (no funcional)

**Como** Supervisor de Planta  
**Quiero** que `familia_color` en `ProductoTerminado` sea solo un campo informativo de clasificación  
**Para** que no interfiera con la lógica de producción, conteos o generación de SKU

#### Criterios de Aceptación

**Escenario 1: Familia de color no afecta la creación en cascada**
- **Dado** que el usuario crea un nuevo Molde + Piezas + Producto Terminado en el wizard
- **Cuando** el PT tiene `familia_color = "SOLIDO"` o cualquier valor
- **Entonces** ese valor no influye en la generación de SKUs ni en la asociación Forma ↔ VarianteColoreada; solo queda como metadato descriptivo del catálogo comercial

**Escenario 2: Validación de pre-requisitos de OP no filtra por familia de color**
- **Dado** que el endpoint `/api/catalogo/validar-orden-prereq` busca SKUs compatibles para un molde + color
- **Cuando** se evalúa la compatibilidad
- **Entonces** se usa el `color_id` directo de la Pieza (no la `familia_color` del PT) para determinar si el SKU existe

---

### US-001c: Corregir errores de integridad en el endpoint de creación en cascada

**Como** Planificador de Producción  
**Quiero** que la creación en cascada (`POST /api/catalogo/configurar-producto`) sea robusta y libre de errores  
**Para** evitar fallos silenciosos, duplicados en BD y colisiones de SKU

#### Criterios de Aceptación

**Escenario 1: Variable de respuesta correcta**
- **Dado** que el endpoint recibe un payload válido
- **Cuando** procesa la creación
- **Entonces** la variable de acumulación de resultados usa un nombre consistente (`resultado` o `response_data`, pero no ambos) y nunca arroja `NameError`

**Escenario 2: Kit no se inserta dos veces**
- **Dado** que se solicita crear un Kit para un molde multi-pieza con 3 colores
- **Cuando** el sistema crea las Piezas Kit coloreadas
- **Entonces** cada Kit se inserta una sola vez en la BD (eliminar el `db.session.add` + `flush` duplicado)

**Escenario 3: Generación de SKU determinista y sin colisiones**
- **Dado** que se crean piezas coloreadas a partir de formas con nombres largos (> 10 caracteres)
- **Cuando** el sistema genera los SKUs
- **Entonces** el SKU resultante es único y determinista (considerar un hash o un esquema de numeración secuencial en lugar de truncamiento)

---

### US-001d: Líneas y Familias dinámicas desde el backend

**Como** Planificador de Producción  
**Quiero** que las listas de Líneas y Familias en el wizard provengan del backend  
**Para** que si se agrega una nueva Línea o Familia en la BD, el frontend la refleje automáticamente sin necesidad de un despliegue

#### Criterios de Aceptación

**Escenario 1: Cargar Líneas y Familias al abrir el wizard**
- **Dado** que el usuario navega a `/catalogo/configurar`
- **Cuando** el componente `ConfigurarProducto` se monta
- **Entonces** se realizan llamadas `GET /api/catalogo/lineas` y `GET /api/catalogo/familias` para obtener las opciones actualizadas de la BD

**Escenario 2: Filtrar Familias por Línea seleccionada**
- **Dado** que el usuario selecciona la Línea "HOGAR"
- **Cuando** el Autocomplete de Familias se actualiza
- **Entonces** solo muestra las familias cuyo `linea_id` corresponde a la Línea seleccionada (ya existe en frontend, solo falta alimentar desde backend)

---

### US-001e: Garantizar consistencia de color por colada en el modelo relacional

**Como** Supervisor de Planta  
**Quiero** que el sistema impida la existencia de Kits o agrupaciones donde SKUs del mismo molde tengan colores distintos  
**Para** que el catálogo de inventario refleje la realidad física de la inyección: todos los componentes de una colada comparten el mismo color.

#### Criterios de Aceptación

**Escenario 1: Kit siempre tiene componentes del mismo color**
- **Dado** que se crea un Kit "Jarra Regadera Roja" para un molde de 2 formas
- **Cuando** el sistema registra los componentes del Kit (`PiezaComponente`)
- **Entonces** todos los componentes del Kit tienen el mismo `color_id`; si "Tapa" es roja, "Base" también es roja

**Escenario 2: Validación impide Kit con colores mixtos**
- **Dado** que un usuario (o una llamada API directa) intenta crear un Kit con componentes que tienen `color_id` distintos y provienen del mismo molde
- **Cuando** el sistema procesa la solicitud
- **Entonces** rechaza la operación con error descriptivo: "Las piezas de un mismo molde deben compartir el mismo color de inyección"

**Escenario 3: Endpoint cascada genera conjuntos coherentes**
- **Dado** que se invoca `POST /api/catalogo/configurar-producto` con un molde de 2 formas y colores [Rojo, Azul]
- **Cuando** el sistema crea los Kits
- **Entonces** genera exactamente 2 Kits: "Kit Rojo" = {Tapa Roja + Base Roja} y "Kit Azul" = {Tapa Azul + Base Azul}; nunca mezcla colores entre kits

---

## Resumen de Lagunas Detectadas en el Draft

| # | Laguna | Impacto | Resolución Propuesta |
|---|--------|---------|---------------------|
| 1 | Colores en el paso del Molde | Modelo conceptual incorrecto | Mover selector después de formas → **US-001a** |
| 2 | `Pieza.color_id` independiente por variante | Permite combinaciones imposibles (Tapa Roja + Pico Azul mismo molde) | Color por colada, no por SKU individual → **US-001a** + **US-001e** |
| 3 | `familia_color` usada en lógica de match | Falsos negativos en validación de OP | Ignorar en lógica, solo descriptiva → **US-001b** |
| 4 | Bug `resultado` vs `response_data` | `NameError` en runtime si molde ya existe | Unificar nombres → **US-001c** |
| 5 | `db.session.add` duplicado para Kit | Kit insertado 2 veces → `IntegrityError` | Eliminar duplicado → **US-001c** |
| 6 | SKU con truncamiento `[:10]` | Colisiones potenciales entre formas con nombres similares | Usar esquema determinista → **US-001c** |
| 7 | Líneas/Familias hardcodeadas en frontend | Desfase con BD | Cargar desde API → **US-001d** |

---

## Dependencias

- [[Orden_Produccion]] — La configuración de molde/pieza impacta directamente en `snapshot_composicion_molde` al crear una OP.
- [[Snapshot_Composicion_Molde]] — Las formas (MoldePieza) se congelan aquí al crear la OP.
- [[Lote_Color]] — Cada lote de color de la OP referencia al `ColorProducto` de la Pieza.

## Regla de Negocio Fundamental

> 🏭 **Color por Colada:** En inyección de plásticos, todas las cavidades de un molde se llenan con el mismo material/color en un solo golpe. Si el molde tiene "Tapa" y "Pico", ambas salen del mismo color. El color NO es una propiedad independiente de cada pieza individual — es una propiedad de la **colada/golpe completo**. Las piezas coloreadas del inventario (SKUs) son la combinación de una **forma del molde** + un **color de inyección**, y siempre existen en conjuntos completos por color.

## Diseño de Entidad-Relación (ER) Propuesto

Para soportar correctamente esta regla de negocio y normalizar la separación entre forma y color (como se evidenció en el análisis de dominio), se propone la siguiente estructura de entidades:

1. **Molde**: El bloque de acero físico de inyección. (Ej. "Molde Regadera")
2. **Pieza (Forma)**: La abstracción de la geometría que sale del molde, independiente del color. Posee atributos como peso unitario y cavidades. (Ej. "Tapa Regadera")
3. **Color**: La entidad que representa el pigmento o masterbatch. (Ej. "Rojo")
4. **PiezaColor (SKU Inventario)**: La entidad intersección que representa el producto físico almacenable. Combina una `Pieza` (forma) y un `Color`. (Ej. "Tapa Regadera Roja")

> 💡 **Nota de Refactorización Semántica:** Actualmente, el backend llama `Pieza` a lo que conceptualmente es `PiezaColor` (el SKU coloreado), y usa `MoldePieza` para representar la `Pieza` (forma pura). Alinear el código con este nuevo modelo ER (donde `Pieza` = Forma pura, y `PiezaColor` = Variante coloreada) resolverá la confusión conceptual.

## Notas Adicionales

> ⚠️ **Prioridad sugerida:** US-001c (bugs) > US-001a + US-001e (color por colada) > US-001d (dinámico) > US-001b (descriptivo). Los bugs en el endpoint pueden causar errores en producción; la corrección del modelo de color es crítica para la integridad del catálogo; los demás son mejoras de mantenibilidad.
