---
tipo: approved-for-dev
estado: implementado-local-pendiente-uat
tags: [scm, trabajo-color, relevo, asignacion, trabajador, tdd]
relaciones:
  - "[[US-010M3_Relevos_en_Trabajo_Color]]"
  - "[[TS-010M3_Relevos_en_Trabajo_Color]]"
  - "[[DEV-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# DEV-010M3: Relevos dentro de un Trabajo de color

## Resultado autorizado

Permitir relevos auditados dentro del mismo Trabajo de color y OT, conservando
el flujo normal de QR sin prometer atribución que el sistema no observa.

## Componentes

- Backend: asignaciones por intervalo, relevo atómico y custodia de mangas.
- Frontend: responsable vigente, historial y acción supervisada de relevo.
- Mangas: subconjuntos por maquinista, reasignación masiva pendiente y
  transferencia excepcional abierta dentro de la misma OT.
- Etiquetas: reemplazo versionado si el sticker impreso muestra al responsable
  anterior.
- Pruebas: intervalos, concurrencia, autorización y frontera US-010K.

## Secuencia TDD obligatoria

1. **BASELINE:** M1 y M2 verdes.
2. **RED M3-01:** demostrar el acoplamiento vigente al maquinista único.
3. **GREEN M3-01:** primera asignación y relevo atómicos.
4. **RED/GREEN M3-02:** dos relevos concurrentes sobre PostgreSQL.
5. Implementar M3-03…M3-05 con cupo e identidad de manga inmutables.
6. Implementar M3-06 sin generar pesaje ni postetiqueta.
7. Implementar M3-07/M3-08 separando asignación, actor y fuente de unidades.
8. Implementar M3-09 como bloqueo explícito, no soporte parcial de K.
9. **REFACTOR:** centralizar resolución de responsable vigente y auditoría.

## Restricciones

- No sobrescribir trabajador histórico de una manga pesada/recibida; una
  etiqueta pendiente reasignada crea nueva versión para la misma manga.
- Usar `POST /trabajos-color/{id}/asignaciones` como contrato de primera
  asignación y relevo; no inventar endpoints paralelos.
- No repartir unidades por peso, tiempo o proporción implícita.
- No cruzar OT, fecha ni turno.
- No crear `TramoMangaTrabajoColor` ni capturas intermedias.
- No convertir al trabajador en parte de la identidad del trabajo.

## Criterio de completada

- [x] M3-01…M3-09 verdes.
- [x] Un solo responsable principal vigente por máquina.
- [x] Reintentos no duplican asignaciones, manga, cupo ni etiquetas.
- [x] El pesaje snapshottea asignación de manga e identidad de Balanza por
  separado.
- [x] Responsable productivo e identidad registrada por Balanza permanecen
  separados.
- [x] UI explica cuándo no existen unidades exactas por persona.
- [x] Transferencia hacia otra OT responde `MULTI_SHIFT_BAG_NOT_ENABLED`.

La concurrencia M3-02 se verificó con dos sesiones PostgreSQL reales. La UAT
física de relevo y reimpresión permanece pendiente.
