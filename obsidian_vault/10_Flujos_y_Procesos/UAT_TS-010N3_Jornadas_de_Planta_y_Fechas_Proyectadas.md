---
tipo: uat
estado: pendiente
tags: [scm, uat, jornadas, fechas, fabricacion, armado, responsive]
relaciones:
  - "[[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes]]"
  - "[[TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]]"
  - "[[DEV-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]]"
  - "[[Vista_US-010N3_Jornadas_de_Planta]]"
fecha_creacion: 2026-08-09
fecha_actualizacion: 2026-08-09
---

# UAT TS-010N3: Jornadas de Planta y fechas proyectadas

## Estado

**PENDIENTE.** Este documento prepara la aceptación; ningún caso humano queda
aprobado por la elaboración de la especificación.

## Objetivo

Confirmar que los plazos de OF/OA son comprensibles sin fechas duplicadas y que
Producción puede consultar todas las jornadas de Fabricación y Armado por fecha
y turno, conservando la edición especializada.

## Precondiciones

- versión N3 desplegada en entorno UAT;
- una OP con OF y OA asignadas;
- una orden con más de una fecha de necesidad;
- una OF sin OT, otra con dos OT y una OA con al menos dos OT;
- un centro con dos OT de Armado para OA distintas en la misma fecha/turno;
- dos máquinas y dos centros activos, uno de cada tipo sin OT;
- una OT de máquina con dos Trabajos de color;
- perfiles de consulta y de Jefatura;
- viewports 390, 768 y 1440 px.

## Recorrido

| Caso | Acción | Resultado esperado | Estado |
|---|---|---|---|
| N3-U01 | Abrir OF/OA con demandas de fechas distintas | Muestra necesidad mínima/máxima, sin input de fecha propio. | PENDIENTE |
| N3-U02 | Abrir orden sin OT | Muestra **Sin jornada programada**. | PENDIENTE |
| N3-U03 | Abrir orden con varias OT | Muestra primera/última fecha y cantidad de jornadas correctas. | PENDIENTE |
| N3-U04 | Abrir Jornadas / Fabricación | Aparece una tarjeta por máquina, incluida la máquina sin OT. | PENDIENTE |
| N3-U05 | Abrir Jornadas / Armado | Aparece una tarjeta por centro, incluido el centro sin OT; si un centro tiene dos OT/OA, ambas son seleccionables y conservan cuota/abastecimiento propios. | PENDIENTE |
| N3-U06 | Seleccionar tarjeta de Fabricación | Abre la misma OT y su cola; conserva fecha/turno. | PENDIENTE |
| N3-U07 | Seleccionar tarjeta de Armado | Abre la OA y OT exactas; no crea otra jornada. | PENDIENTE |
| N3-U08 | Crear Armado concurrente sobre OT multicolor | Exige seleccionar color/artículo/OF exactos y conserva Trabajo de color. | PENDIENTE |
| N3-U09 | Probar perfil solo consulta | Ve tarjetas, no comandos; una escritura directa sigue bloqueada. | PENDIENTE |
| N3-U10 | Probar 390, 768 y 1440 px | Sin desborde global; tabs, tarjetas, foco y acciones son utilizables. | PENDIENTE |

## Evidencia automática disponible — 2026-08-09

- escenarios N3-01…N3-08 cubiertos por suites focales;
- backend: **43 pruebas aprobadas** en planificación, OT, Armado, rutas e
  identidad de color;
- frontend: **69 pruebas aprobadas** en Jornadas, OF/OA, navegación contextual,
  permisos, guía y fecha Lima;
- lint: **0 errores**; se conserva una advertencia preexistente fuera de N3;
- build productivo Vite: correcto;
- el contrato temporal se deriva en lectura y los comandos de OF/OA rechazan
  campos no permitidos;
- el backend rechaza Armado concurrente sin un Trabajo de color exacto de una
  OT de Fabricación válida para la fecha.

Pendiente antes de aceptación: smoke visual documentado en 390, 768 y 1440 px.
La evidencia automática no modifica el estado **PENDIENTE** de N3-U01…N3-U10.

## Criterio de aprobación

- N3-U01…N3-U10 aprobados por usuario autorizado;
- cero edición temporal duplicada;
- cero mezcla de datos de Fabricación y Armado;
- cero pérdida de contexto al abrir una tarjeta;
- cero selección implícita de Trabajo de color concurrente;
- hallazgos bloqueantes resueltos y regresionados.
