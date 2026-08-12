---
tipo: modelo_objetivo
estado: aceptado-para-especificacion
tags: [dominio, planificacion, demanda, producto-terminado, scm]
relaciones:
  - "[[ProductoTerminado]]"
  - "[[Articulo_SCM]]"
  - "[[Ruta_Produccion]]"
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Armado]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-07-30
---

# Orden de Producción

Documento de demanda productiva que expresa **qué productos terminados necesita
el negocio, en qué cantidad y para cuándo**. No es la instrucción técnica de un
molde.

La entidad técnica persistida actualmente como `OrdenProduccion` evoluciona a
[[Orden_Fabricacion]]. Las filas históricas no se reinterpretan. Este documento
define el nuevo agregado OP que evoluciona desde `SolicitudProduccion` de
US-010P.

## Responsabilidad

La OP:

- contiene una o más líneas de [[ProductoTerminado]];
- registra origen, prioridad y fecha de necesidad;
- congela las revisiones de estructura y ruta utilizadas para planificar;
- calcula cobertura con PT, WIP, piezas, suministro entrante y órdenes
  ejecutables;
- conserva asignaciones trazables hacia stock, [[Orden_Fabricacion|OF]] y
  [[Orden_Armado|OA]];
- mide cumplimiento en unidades de producto terminado.

La OP no es autoridad sobre molde, máquina, cavidades, ciclo, receta, color,
maquinista, manga o peso. Esos datos pertenecen a las órdenes y hechos de
ejecución.

## Cabecera

| Campo | Regla |
|---|---|
| `id`, `public_id` | Identidad estable interna y pública. |
| `codigo_op` | Correlativo humano `OP-######`; nunca se reutiliza. |
| `origen` | `PEDIDO`, `REPOSICION_STOCK_PT`, `MUESTRA`, `MANUAL` u otro catálogo gobernado. |
| `referencia_origen` | Pedido, solicitud o referencia externa opcional. |
| `fecha_necesidad` | Fecha objetivo de disponibilidad del resultado. |
| `prioridad` | Política gobernada; no se deriva del correlativo. |
| `estado` | `BORRADOR`, `APROBADA`, `PLANIFICADA`, `EN_COBERTURA`, `COMPLETADA` o `CANCELADA`. |
| `created_by_id`, `approved_by_id` | Participantes auditables. |
| `created_at`, `approved_at`, `completed_at` | Tiempos UTC; la zona de presentación es independiente. |
| `version` | Control de concurrencia y revisión. |

## OrdenProduccionLinea

Una línea es la unidad mínima de demanda productiva:

| Campo | Regla |
|---|---|
| `producto_terminado_id` | Producto comercial solicitado. |
| `cantidad_solicitada` | Entero positivo en la unidad base del PT. |
| `fecha_necesidad` | Puede heredar cabecera o especificar una fecha propia. |
| `estructura_revision_id/hash` | BOM multinivel congelada al aprobar/planificar. |
| `ruta_revision_id/hash` | Ruta aplicable congelada. |
| `cantidad_cubierta_stock` | Proyección desde asignaciones activas a stock. |
| `cantidad_cubierta_suministro` | Proyección desde salidas OF/OA asignadas. |
| `cantidad_satisfecha` | Resultado final físicamente elegible ya adjudicado. |
| `cantidad_pendiente` | Solicitada menos satisfecha/cancelada según política. |

Aunque la primera interfaz pueda crear una OP de una sola línea, el agregado
soporta varias para no imponer un documento por SKU cuando compartan prioridad,
origen y fecha.

## Cobertura multinivel

La planificación recorre [[Articulo_SCM]], estructuras y rutas:

```text
demanda de ProductoTerminado
  -> cobertura con PT disponible
  -> explosión de la cantidad restante
  -> cobertura con WIP y PiezaColor
  -> faltantes de fabricación y armado
  -> propuestas de OF/OA
  -> asignaciones de suministro
```

La cobertura de un nodo padre evita volver a producir sus componentes para la
misma cantidad. Una fuente desconocida o no conciliada produce
`COBERTURA_NO_CALCULABLE`; nunca se interpreta silenciosamente como cero.

## AsignacionDemandaSuministro

Relación N:M que adjudica una fuente de suministro a una línea de OP. Puede
apuntar a:

- stock elegible de `ProductoTerminado`;
- stock de WIP o componentes que evita operaciones anteriores;
- salida esperada de [[Orden_Fabricacion]];
- salida esperada de [[Orden_Armado]];
- resultado físico confirmado y liberado.

Conserva:

| Campo | Regla |
|---|---|
| `orden_produccion_linea_id` | Demanda cubierta. |
| `tipo_fuente`, `fuente_id`, `salida_id` | Identidad estable del suministro. |
| `cantidad_planificada` | Intención recalculable. |
| `cantidad_comprometida` | Suministro reservado para esa línea. |
| `cantidad_satisfecha` | Resultado definitivamente adjudicado. |
| `estado` | `PLANIFICADA`, `COMPROMETIDA`, `SATISFECHA` o `CANCELADA`. |
| `operation_id`, `version`, timestamps | Idempotencia y auditoría. |

La suma activa adjudicada a una fuente nunca supera su cantidad elegible. Una
OF/OA puede cubrir varias líneas y una línea puede usar varias fuentes.

## Generación de órdenes ejecutables

Planificación propone, pero no libera automáticamente:

- [[Orden_Fabricacion|OF]] para operaciones de molde/fabricación;
- [[Orden_Armado|OA]] para operaciones que consumen artículos y producen WIP
  o producto final;
- ninguna orden cuando el stock elegible cubre toda la demanda.

Cuando una operación de fabricación produce directamente el PT, la ruta termina
en OF y no se crea una OA ficticia.

Las propuestas pueden consolidar faltantes compatibles de varias OP. La
compatibilidad considera molde, color, receta/material, revisión técnica y
ventana de necesidad. Los excedentes inevitables se muestran antes de
confirmar.

## Avance

La OP no recibe producción real digitada. Sus indicadores son proyecciones:

```text
solicitado
  -> cubierto/comprometido
  -> en fabricación
  -> en armado
  -> terminado
  -> liberado y disponible
```

El avance de OF proviene de OT, salidas, mangas y pesajes; el avance de OA
proviene de confirmaciones y consumos. La OP los agrega únicamente mediante
`AsignacionDemandaSuministro`.

## Impresión A4

La impresión de OP es ejecutiva y de planificación. Incluye:

- código, origen, fecha requerida y prioridad;
- productos y cantidades;
- cobertura por stock, OF y OA;
- faltantes y riesgos;
- estado y responsables de aprobación;
- referencias a órdenes ejecutables.

No imprime parámetros técnicos de molde ni resultados de pesaje. La antigua
impresión técnica de OP pasa a [[Orden_Fabricacion|OF]].

## Invariantes

1. Toda OP posee al menos una línea válida antes de aprobarse.
2. Toda línea referencia un `ProductoTerminado` activo y una cantidad entera
   positiva.
3. Aprobar/planificar congela estructura y ruta; cambios maestros no reescriben
   el plan histórico.
4. Una OP no identifica un molde ni una máquina como padre técnico.
5. Una OP puede requerir cero, una o varias OF/OA.
6. Una OF/OA puede cubrir varias OP mediante asignaciones explícitas.
7. El stock o suministro no puede comprometerse dos veces.
8. Cancelar conserva historia y libera solo compromisos no ejecutados.
9. Completar OP exige cantidades satisfechas según la política, no solamente
   cerrar sus órdenes relacionadas.
10. Calidad e inventario permanecen estados separados de la OP.

## Migración semántica

| Concepto actual | Concepto objetivo |
|---|---|
| `SolicitudProduccion` | `OrdenProduccion` |
| `SolicitudProduccionLinea` | `OrdenProduccionLinea` |
| `AsignacionDemandaOP` | `AsignacionDemandaSuministro` |
| `OrdenProduccion` técnica actual | [[Orden_Fabricacion]] |
| Formulario `OP excepcional` | `OF excepcional` |
| PDF técnico de OP | PDF técnico de OF |

La estrategia física, versionado de API y adaptadores se define en la Tech Spec
de US-010P. Ningún pesaje o documento legacy se elimina como parte de este
cambio.

## Adenda: sugerencia, decisión y reserva

El cálculo produce dos magnitudes distintas por documento ejecutable:

- `cantidad_calculada`, derivada de demanda, BOM y saldo libre;
- `cantidad_objetivo`, decisión confirmable de Planificación.

Modificar la segunda exige motivo, actor y una nueva revisión del plan. No
cambia la cantidad solicitada ni reescribe la sugerencia.

Confirmar el plan reserva PT, WIP o PiezaColor elegible en
[[Inventario_SCM]]. No lo consume. La cantidad reservada nunca puede superar
la existencia física y sólo el saldo libre participa en cálculos posteriores.
