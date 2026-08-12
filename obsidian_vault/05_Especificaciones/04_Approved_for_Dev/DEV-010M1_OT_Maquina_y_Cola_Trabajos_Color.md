---
tipo: approved-for-dev
estado: implementado-local-pendiente-uat
tags: [scm, ot, trabajo-color, tdd, migracion]
relaciones:
  - "[[US-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[Baseline_TS-010R_C_D_2026-07-24]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-09
---

# DEV-010M1: OT de máquina y cola de Trabajos de color

## Resultado autorizado

Implementar la envolvente OT de máquina/turno y sus Trabajos de color conforme
a TS-010M1. No se autoriza modificar el alcance por conveniencia de la
implementación.

## Componentes

- Backend: modelos, migración expand/backfill, servicios, permisos y API.
- Frontend: tablero por máquina, cola y acciones de estado.
- Contratos: versión compatible para OT/trabajo y color humano estructurado.
- Pruebas: unitarias, integración PostgreSQL, API, UI y migración.

## Secuencia TDD obligatoria

1. **BASELINE:** repetir la suite integral indicada por TS-010M1 y registrar
   resultado verde actual, fecha y fallos preexistentes.
2. **RED M1-01:** demostrar que hoy una OT no admite dos trabajos atómicos.
3. **GREEN M1-01:** agregar esquema mínimo, creación y consulta.
4. **RED/GREEN M1-02:** exclusión concurrente por máquina en PostgreSQL.
5. Implementar M1-03…M1-06 uno por vez, sin adelantar escenarios.
6. **RED/GREEN M1-07:** expand/backfill con fixtures legacy reales.
7. **RED/GREEN M1-08:** separar exclusividad de máquina y elegibilidad de
   Balanza.
8. **RED/GREEN M1-09:** combinar máquinas activas con OT de fecha/turno y
   demostrar una tarjeta por máquina sin crear OT implícitas.
9. **RED/GREEN M1-10:** proyectar color humano; única opción read-only y varias
   opciones seleccionables sin lenguaje “corrida/C01”.
10. **REFACTOR:** retirar duplicación interna, no columnas legacy todavía.
11. Ejecutar suites, builds y comparación de conteos antes/después.

## Restricciones

- No fusionar OT históricas.
- No crear `scm_orden_trabajo`: `RegistroDiarioProduccion` conserva la cabecera
  física de la OT durante expand/cutover.
- Usar exactamente `POST /ots/fabricacion`, `GET /ots`,
  `POST /ots/{ot_id}/trabajos-color` y las acciones
  `/trabajos-color/{id}/{iniciar|pausar|reanudar|completar|anular}`; la fachada
  legacy por OF permanece.
- Persistir solo `PLANIFICADO`, `EN_EJECUCION`, `PAUSADO`, `COMPLETADO` y
  `ANULADO`; listo/bloqueado son proyecciones.
- No eliminar ni reutilizar UUID/códigos existentes.
- No escribir totales editables en OT.
- No implementar TrabajoArmado, manga multi-jornada o material preparado.
- No usar SQLite para demostrar exclusividad o migración productiva.

## Criterio de completada

- [x] M1-01…M1-10 verdes y mapeados a evidencia.
- [x] `flask db upgrade` y chequeo de drift verdes en base nueva y poblada.
- [x] Reejecución idempotente no crea trabajos duplicados.
- [x] Frontend muestra carga, vacío, conflicto, error y éxito.
- [x] Regresión de OP/OF/corridas y OT legacy verde.
- [x] Vault actualizado si el contrato aprobado cambia durante TDD.

Evidencia automática ampliada y cerrada el 2026-08-09:

- backend completo: 328 aprobadas, 1 omitida por OCR opcional y 0 fallos;
- frontend focal OT/tablero/servicio: 32 aprobadas y 0 fallos;
- lint focal y build de producción: verdes;
- PostgreSQL/migración M1-01…M1-08: evidencia previa conservada.

M1-09/M1-10 corresponden al tablero diario y al color humano añadidos en este
corte. La aprobación visual/física permanece en
[[UAT_TS-010M_OT_y_Trabajos_Color]].
