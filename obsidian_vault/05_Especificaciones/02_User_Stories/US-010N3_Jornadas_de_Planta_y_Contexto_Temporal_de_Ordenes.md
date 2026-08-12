---
tipo: user-story
estado: implementada-local-pendiente-uat
tags: [scm, frontend, ux, jornadas, fechas, fabricacion, armado, atdd]
relaciones:
  - "[[2026-08-09_Jornadas_de_Planta_y_Fechas_Proyectadas_de_OF_OA]]"
  - "[[TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]]"
  - "[[Vista_US-010N3_Jornadas_de_Planta]]"
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Armado]]"
  - "[[Registro_Diario]]"
fecha_creacion: 2026-08-09
fecha_actualizacion: 2026-08-09
---

# US-010N3: Jornadas de Planta y contexto temporal de órdenes

## Historia

**Como** responsable de Producción o Planificación  
**Quiero** comprender el plazo de cada OF/OA y consultar todas las jornadas de
Fabricación y Armado por fecha y turno  
**Para** programar y supervisar la planta sin duplicar fechas ni buscar cada OT
de Armado dentro de una OA distinta.

## Alcance

- fechas de OF/OA como proyecciones de demanda y ejecución, no inputs;
- Jornada de Planta con Fabricación por máquina y Armado por centro;
- selección contextual de OT y apertura de su editor especializado;
- Armado concurrente enlazado al Trabajo de color exacto;
- estados vacíos para recursos sin OT y órdenes sin jornada;
- responsive, accesibilidad y autorización por capacidades.

## Reglas de negocio

1. La OP conserva la fecha de necesidad autoritativa.
2. OF/OA no reciben una fecha productiva editable.
3. La fecha real programada pertenece a cada OT.
4. Una proyección temporal se recalcula desde asignaciones y OT; no se escribe
   de vuelta a OP, OF u OA.
5. Fabricación se agrupa por máquina y Armado por centro de trabajo.
6. Seleccionar una tarjeta no modifica datos.
7. Editar usa el contrato y capacidad del agregado original.
8. Una OT concurrente de Armado referencia un Trabajo de color exacto.
9. Una OT de Armado ejecuta una sola OA; una OT normalizada de Fabricación puede
   contener Trabajos de color de varias OF compatibles.

## Escenarios ATDD/BDD

### N3-01 — OF/OA muestran demanda sin fecha duplicada

**Dado** una OF u OA que cubre líneas de OP con fechas distintas  
**Cuando** se consulta la orden técnica  
**Entonces** muestra el rango de necesidad derivado y no ofrece editar una
fecha propia.

### N3-02 — Rango de ejecución desde OT

**Dado** una OA distribuida en tres OT de Armado  
**Cuando** se consulta su contexto temporal  
**Entonces** muestra primera y última fecha operativa; si no existe OT, muestra
**Sin jornada programada**.

### N3-03 — Tablero de Fabricación completo

**Dado** una fecha y turno con máquinas activas  
**Cuando** se abre Jornadas de Planta / Fabricación  
**Entonces** aparece una tarjeta por máquina, incluso sin OT, y cada OT muestra
su Trabajo de color actual sin mezclar datos de Armado.

### N3-04 — Tablero de Armado completo

**Dado** centros de Armado activos y OT repartidas entre varias OA  
**Cuando** se abre Jornadas de Planta / Armado  
**Entonces** aparece una tarjeta por centro con OA, OT, responsable, cuota,
mangas y abastecimiento de la fecha/turno, incluso cuando el centro no tenga
OT; si hay varias OT/OA en el mismo centro, ninguna se oculta y se elige la
jornada exacta antes de editar.

### N3-05 — Edición contextual sin duplicación

**Dado** una tarjeta de Fabricación o Armado  
**Cuando** el actor selecciona **Abrir jornada**  
**Entonces** conserva fecha, turno y OT seleccionada y abre el detalle
especializado; no crea una segunda OT ni otro formulario paralelo.

### N3-06 — Contexto concurrente inequívoco

**Dado** una OT de máquina con dos Trabajos de color  
**Cuando** se crea una OT de Armado concurrente  
**Entonces** se exige elegir el Trabajo de color por color, artículo y OF, y se
rechaza guardar solo con la OT de máquina.

### N3-07 — Permiso de consulta no concede edición

**Dado** un actor con consulta de OT pero sin capacidad de crear o ejecutar  
**Cuando** abre Jornadas de Planta  
**Entonces** puede ver las tarjetas permitidas, pero no aparecen comandos de
edición y la API continúa rechazando escrituras.

### N3-08 — Responsive y foco

**Dado** un viewport de 390, 768 o 1440 px  
**Cuando** cambia entre Fabricación y Armado y abre una tarjeta  
**Entonces** no existe desborde global, el foco es predecible y el contexto
seleccionado permanece visible.

## Fuera de alcance

- planificación finita o promesa automática de cumplimiento;
- Gantt, calendario drag-and-drop o reprogramación masiva;
- fecha editable en OF/OA;
- creación de `TrabajoArmado`;
- fusión de OT históricas;
- cambiar la cardinalidad OT de Armado → OA.

## Estado de implementación

Implementada localmente el 2026-08-09 conforme a TS-010N3. La proyección
temporal de OF/OA, el tablero dual de Jornadas, la navegación contextual y el
Trabajo de color exacto para Armado concurrente cuentan con evidencia
automática. El smoke visual y la aceptación humana permanecen pendientes en
[[UAT_TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]].

## Definición de preparada

- [x] Semántica temporal aprobada.
- [x] Cardinalidades de Fabricación y Armado diferenciadas.
- [x] Agrupación por recurso aprobada.
- [x] Edición contextual definida.
- [x] Contexto concurrente atómico definido.
- [x] Escenarios observables y automatizables.
- [x] Tech Spec disponible.
