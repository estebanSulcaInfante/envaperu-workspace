---
tipo: approved-for-dev
estado: implementado-local-pendiente-uat
tags: [scm, trabajo-color, manga, pesaje, anulacion, kardex, tdd]
relaciones:
  - "[[US-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color]]"
  - "[[TS-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color]]"
  - "[[DEV-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# DEV-010M2: Mangas, pesaje y anulación por Trabajo de color

## Resultado autorizado

Hacer que el Trabajo de color sea el padre atómico de cupo, manga y ejecución,
preservando el flujo QR reducido y todas las identidades históricas.

## Componentes

- Backend: FK y migración, plan/cupo, extras, pesaje, anulación, recepción y
  proyecciones.
- Estación: contrato de contexto y bloqueo de sustitución manual.
- Frontend: detalle de trabajo, mangas, estados y errores compensatorios.
- Integraciones: frontera US-010B por corrida, adaptación C/D/I y conciliación
  11213–11216.

## Secuencia TDD obligatoria

1. **BASELINE:** M1 y regresión C/D/I verdes.
2. **RED M2-01:** el QR actual todavía depende de `manga.ot` monocolor.
3. **GREEN M2-01:** lectura dual y contexto exacto por trabajo.
4. Implementar M2-02 y M2-03 antes de cambiar escrituras de cupo.
5. Implementar la transacción M2-04 con pérdida/reintento simulados.
6. Implementar M2-05 y comprobar reversa previa real.
7. Probar M2-06 en API aunque el botón esté oculto.
8. Cerrar M2-07 y M2-08 sin introducir modelos de US-010L.
9. Implementar M2-09 sin reactivar trabajos pausados.
10. **REFACTOR:** eliminar derivaciones por OT del contrato nuevo; conservar
   adaptadores legacy explícitos.

## Restricciones

- `ANULAR_PESAJE` nunca hace `DELETE` ni edita el hecho original.
- El cupo se devuelve una sola vez y dentro de la misma transacción.
- No inferir trabajo, color o salida desde texto/código humano.
- No agregar campos al flujo normal del maquinista.
- No crear lote preparado, R1…Rn, pesaje intermedio ni soporte offline.

## Criterio de completada

- [x] M2-01…M2-09 cubiertos automáticamente en su lógica; M2-08 conserva una
  conciliación física pendiente en UAT.
- [x] Concurrencia/idempotencia probadas sobre PostgreSQL.
- [x] Contratos central-estación cubiertos por pruebas de integración.
- [x] Reemplazo después de anulación vuelve a ser `NORMAL`.
- [x] Después de recepción se exige reversa sin mutación parcial.
- [x] Eliminación directa bloqueada para todos los perfiles.
- [ ] Stickers 11213–11216 explicados y preservados.

La conciliación de los IDs reales 11213–11216 requiere el entorno UAT; no se
declara satisfecha mediante fixtures genéricos.

La doble anulación se verificó con dos sesiones PostgreSQL: un ganador, un
`WEIGHING_ALREADY_ANNULLED`, un solo retorno de cupo y un reemplazo
`NORMAL / PLANIFICADA`.
