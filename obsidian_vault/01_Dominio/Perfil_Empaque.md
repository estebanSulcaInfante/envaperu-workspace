---
tipo: modelo_objetivo
estado: implementado-r-core
tags: [dominio, scm, empaque, bolsa, contenedor, planificacion, US-010R]
relaciones:
  - "[[Articulo_SCM]]"
  - "[[Unidad_Logistica]]"
  - "[[Tipo_Manga]]"
  - "[[Lote_WIP]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-07-24
---

# Perfil de Empaque

Modelo que separa el contenedor físico, la geometría del contenido y la instrucción de llenado. Una bolsa no posee por sí sola “capacidad para una pieza”: el acomodo cambia entre una pieza suelta, un prearmado y un producto completo.

Los maestros, asociaciones por artículo, reglas revisionadas, snapshots y calculadora `Decimal` quedaron implementados localmente en R4 de [[DEV-010R_R-Core_Articulos_BOM_Rutas_y_Empaque]]. La creación persistente de planes y mangas continúa en US-010C/F.

## TipoContenedor

Para el piloto, el maestro se expone operativamente como **Tipos de manga** y se documenta en [[Tipo_Manga]]. `TipoManga` no crea una segunda clasificación: es la proyección administrable de `TipoContenedor` con `clase=MANGA`.

Maestro del soporte físico:

| Campo | Regla |
|---|---|
| `codigo`, `clase` | Identidad y clase: bolsa, jaba, caja, manga u otra. |
| `dimensiones`, `volumen_util` | Referencia física cuando sea medible. |
| `tara_nominal_g`, `tolerancia_tara_g` | Valores no negativos; definen la tara superior conservadora. |
| `peso_bruto_max_kg` | Límite físico/ergonómico positivo, no objetivo automático. |
| `activo`, `version` | Baja lógica y concurrencia. |

## PerfilEmpacable

Representa el estado físico que determina el acomodo, independientemente del color cuando este no cambia la geometría:

- `BALDE_SUELTO`;
- `BALDE_CON_ASA_PREARMADA`;
- `ASA_SUELTA`.

Un [[Articulo_SCM]] referencia un perfil predeterminado y puede seleccionar otro perfil aprobado cuando su variante modifica realmente el acomodo. Esa asociación maestra no es un override operativo ni autoriza exceder límites.

## ReglaEmpaqueRevision

Relación revisionada entre perfil y tipo de contenedor:

| Campo | Regla |
|---|---|
| `perfil_empacable_id`, `tipo_contenedor_id` | Combinación aplicable. |
| `cantidad_objetivo_un` | Cantidad operativa recomendada. |
| `cantidad_maxima_probada_un` | Máximo validado físicamente. |
| `peso_neto_operativo_max_kg` | Límite positivo obligatorio del proceso para esta regla. |
| `margen_seguridad_kg` | Reserva frente al límite físico. |
| `tolerancia_peso_abs_g`, `tolerancia_peso_pct` | Control del peso esperado. |
| `estado`, `vigencia`, `content_hash` | Gobierno e inmutabilidad. |

La capacidad probada captura volumen, forma, anidamiento y modo de acomodo. No se reemplaza por un cálculo basado únicamente en kg.

## Cálculo de bolsas

Para un artículo discreto:

```text
tara_superior_kg =
  (tara_nominal_g + tolerancia_tara_g) / 1000

limite_neto_por_bruto_kg =
  peso_bruto_max_kg
  - tara_superior_kg
  - margen_seguridad_kg

limite_neto_efectivo_kg =
  min(
    peso_neto_operativo_max_kg,
    limite_neto_por_bruto_kg
  )

capacidad_por_peso =
  floor(
    limite_neto_efectivo_kg * 1000
    / peso_unitario_snapshot_g
  )

capacidad_efectiva =
  min(
    cantidad_objetivo_un,
    cantidad_maxima_probada_un,
    capacidad_por_peso
  )

numero_bolsas =
  ceil(cantidad_planificada_un / capacidad_efectiva)
```

`tara_nominal_g` y `tolerancia_tara_g` proceden del `TipoContenedor` congelado. Todos los límites, cantidades y pesos de la fórmula deben ser positivos; si `limite_neto_efectivo_kg <= 0` o `capacidad_efectiva <= 0`, la regla es inviable y no genera bolsas (`REGLA_EMPAQUE_NO_VIABLE`).

Para cada bolsa:

```text
cantidad_planificada_bolsa =
  min(capacidad_efectiva, cantidad_pendiente)

peso_neto_teorico_kg =
  cantidad_planificada_bolsa * peso_unitario_snapshot_g / 1000
```

El peso unitario de un WIP se deriva de su estructura congelada. Las unidades reales proceden de conteo o asignación autorizada; nunca se confirman dividiendo el peso de balanza.

Un override operativo puede reducir la cantidad objetivo o reemplazar la tara por una medición real. Requiere permiso, motivo, actor y fecha; nunca puede aumentar `cantidad_maxima_probada_un`, `peso_neto_operativo_max_kg` ni `peso_bruto_max_kg`.

## PlanBolsa y evidencia histórica

La OP genera primero un plan agregado de mangas por salida. Al crear una OT diaria, central asigna una parte de ese plan y recién crea las identidades imprimibles `OPxxxx-OTxxx-Mxxx`, porque antes de la OT todavía pueden no existir fecha operativa, máquina o maquinista.

Cada bolsa planificada congela:

- artículo y lote esperado;
- revisión de regla de empaque;
- tipo de contenedor;
- cantidad objetivo;
- peso unitario y neto teórico;
- tara esperada;
- tolerancias;
- secuencia, trabajador y contexto de OF/OT u OA.

La planificación recomienda identidades; no crea inventario. La última bolsa puede ser parcial. Una etiqueta no utilizada se anula y una bolsa confirmada conserva plan, real y diferencia.

En el flujo normal el maquinista no digita cantidades: recibe una manga con `cantidad_asignada`, cuenta físicamente durante el llenado y el pesaje confirma implícitamente esa asignación con `fuente_cantidad=PLAN_CONFIRMADO_POR_PESAJE`. El peso solo controla tolerancia; nunca modifica ni infiere unidades.
