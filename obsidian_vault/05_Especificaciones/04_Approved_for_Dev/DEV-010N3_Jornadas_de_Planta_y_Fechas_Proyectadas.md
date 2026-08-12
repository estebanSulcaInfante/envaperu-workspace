---
tipo: approved-for-dev
estado: implementado-local-pendiente-uat
historia: "[[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes]]"
tech_spec: "[[TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]]"
fecha_aprobacion: 2026-08-09
fecha_actualizacion: 2026-08-09
---

# DEV-010N3: Jornadas de Planta y fechas proyectadas

Se autoriza el desarrollo local del corte definido en TS-010N3. La autorización
no aprueba UAT, despliegue ni una migración de base de datos.

## Secuencia TDD

1. Registrar baseline backend/frontend antes del primer cambio.
2. RED/GREEN N3-01 y N3-02: proyección temporal OF/OA sin campos editables.
3. RED/GREEN N3-03: conservar el tablero de Fabricación por máquina.
4. RED/GREEN N3-04: agregar Armado por centro y recursos sin OT.
5. RED/GREEN N3-05: selección y edición contextual sin duplicar comandos.
6. RED/GREEN N3-06: selector y validación de Trabajo de color exacto.
7. RED/GREEN N3-07/N3-08: capacidades, accesibilidad y responsive.
8. Ejecutar regresión completa, lint, build y smoke local.
9. Actualizar evidencia en DEV/UAT sin marcar aceptación humana.

## Entregables

- proyección temporal aditiva en OF/OA;
- Jornadas de Planta con Fabricación y Armado;
- deep-link contextual por OT/OA;
- selección exacta de Trabajo de color en Armado concurrente;
- pruebas automáticas y documentación visible;
- UAT preparada, no preaprobada.

## Restricciones

- sin fecha editable ni nueva autoridad temporal en OF/OA;
- sin planificación finita;
- sin `TrabajoArmado`;
- sin fusión de OT históricas;
- sin cambiar que una OT de Armado pertenece a una sola OA;
- sin despliegue o migración productiva implícitos.

## Criterio de completada

- [x] Escenarios N3-01…N3-08 automatizados.
- [x] Suite focal, lint y build verdes.
- [ ] Smoke local en 390, 768 y 1440 px.
- [x] Vault y guía sincronizados con la implementación real.
- [x] UAT humana preparada y aún pendiente.

## Evidencia de cierre local — 2026-08-09

- 43 pruebas backend focales aprobadas;
- 69 pruebas frontend focales aprobadas;
- lint sin errores y build de producción correcto;
- contratos revisados: `contexto_temporal`, recursos con `0..N` OT, vínculo
  OA→OT, enriquecimiento de Armado y Trabajo de color concurrente exacto;
- sin P0/P1 abiertos contra ADR, US, TS, Vista o UAT.

Quedan deliberadamente fuera de este cierre el smoke visual en los tres anchos,
el despliegue y la aceptación humana.
