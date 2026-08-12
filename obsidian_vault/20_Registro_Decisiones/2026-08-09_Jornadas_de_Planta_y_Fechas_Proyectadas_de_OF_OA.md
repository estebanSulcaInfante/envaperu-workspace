---
tipo: decision-arquitectura
estado: aceptada
fecha_decision: 2026-08-09
fecha_actualizacion: 2026-08-09
tags: [scm, frontend, ux, jornadas, fechas, orden-fabricacion, orden-armado, orden-trabajo]
relaciones:
  - "[[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes]]"
  - "[[TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]]"
  - "[[Orden_Produccion]]"
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Armado]]"
  - "[[Registro_Diario]]"
  - "[[Trabajo_Color]]"
  - "[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]"
---

# Jornadas de Planta y fechas proyectadas de OF/OA

> [!info] Implementación local
> La decisión quedó implementada localmente el 2026-08-09 y cuenta con suites
> focales verdes. El despliegue, el smoke visual y la UAT humana permanecen
> pendientes; ver [[UAT_TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]].

## Contexto

La OP expresa para cuándo necesita el negocio un producto, mientras que una OF
o una OA puede abastecer varias líneas de demanda y ejecutarse durante varias
jornadas. Copiar una única fecha editable en cada orden técnica crearía una
segunda autoridad temporal y sería ambiguo cuando las demandas o las OT tengan
fechas distintas.

La vista vigente de **Jornadas y Trabajos de color** presenta únicamente OT de
Fabricación por máquina. Las OT de Armado existen, pero se consultan dentro de
cada OA. Esta separación es correcta para editar cada agregado, aunque no
permite al responsable observar toda la planta por fecha y turno.

## Decisión

### 1. Semántica temporal

- La `fecha_necesidad` de la OP o de su línea es la fecha autoritativa de
  demanda.
- OF y OA permanecen como órdenes técnicas agregadas **sin fecha productiva
  editable**. Sus timestamps de creación, liberación, inicio y cierre son
  auditoría de ciclo de vida, no fechas de programación.
- Cada OT conserva una sola `fecha_operativa` y turno. Es la autoridad de la
  programación diaria y de la ejecución real.
- Las vistas de OF/OA proyectan, sin persistir otra fuente de verdad:
  - fecha de necesidad mínima y máxima de las demandas asignadas;
  - primera y última fecha operativa de sus OT;
  - estado explícito **Sin jornada programada** cuando todavía no existen OT.
- Una orden excepcional o para stock sin OP muestra **Sin fecha de necesidad**
  hasta que una política futura defina un compromiso propio; no inventa la
  fecha de creación como vencimiento.

### 2. Jornadas de Planta

Producción incorpora una entrada única **Jornadas de Planta** con dos
proyecciones hermanas:

1. **Fabricación por máquina:** tarjeta por máquina, OT de máquina y Trabajos de
   color de la fecha/turno.
2. **Armado por centro:** tarjeta por mesa/celda/centro, OT de Armado, OA,
   responsable, cuota, mangas y abastecimiento de la fecha/turno. Si un centro
   tiene varias OT para OA distintas, la tarjeta las lista/indica y exige
   seleccionar una; no las fusiona ni oculta.

Ambas comparten fecha, turno, estados de carga/vacío/error, capacidades y
patrones responsive. No se mezclan los estados internos ni se convierte Armado
en Trabajo de color.

### 3. Edición contextual

El tablero es una proyección de consulta y acceso. Seleccionar una tarjeta abre
el detalle contextual del agregado existente:

- Fabricación conserva OT → Trabajo de color → mangas;
- Armado conserva OA → OT de Armado → abastecimiento/mangas/cierre.

No se crean formularios duplicados ni otra fuente de estado. Una acción exige
la misma capacidad y contrato server-side que en su vista de origen.

### 4. Armado concurrente

Una OT de Armado concurrente debe seleccionar el **Trabajo de color exacto**
que aporta el contexto, no solamente la OT de máquina. La selección muestra
máquina, OT, color, artículo y OF; exige misma fecha operativa y un trabajo
compatible en estado planificado, en ejecución o pausado.

La OT de Fabricación se deriva y conserva como contexto padre para consulta,
pero `trabajo_color_contexto_id` es la referencia atómica. Si una OT posee más
de un Trabajo de color, nunca se elige uno por posición o de forma implícita.

### 5. Cardinalidades vigentes

- Una OT nueva normalizada de Fabricación contiene N Trabajos de color.
- Cada Trabajo de color referencia una OF/corrida exacta.
- Por ello una OT de Fabricación puede agrupar trabajos de varias OF
  compatibles durante la misma máquina, fecha y turno.
- Una OF puede repartirse entre N Trabajos de color y N OT.
- Una OT de Armado referencia exactamente una OA; una OA puede repartirse en N
  OT de Armado.
- La coexistencia concurrente enlaza contextos, pero nunca convierte una OT en
  ejecutora simultánea de OF y OA.

## Consecuencias

- Planificación puede explicar el plazo sin duplicar fechas editables.
- Producción obtiene una lectura diaria completa de Fabricación y Armado.
- El detalle sigue siendo especializado y conserva trazabilidad y permisos.
- La planificación finita y el cálculo automático de fecha de inicio continúan
  fuera de este incremento.
- Las afirmaciones históricas “una OT de Fabricación ejecuta una sola OF” quedan
  sustituidas únicamente para Fabricación; permanecen vigentes para OT de
  Armado respecto de su OA.
