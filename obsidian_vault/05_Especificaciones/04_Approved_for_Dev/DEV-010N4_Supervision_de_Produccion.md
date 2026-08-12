---
tipo: approved-for-dev
estado: implementado-local-pendiente-uat
historia: "[[US-010N4_Supervision_de_Produccion_Read_Model_Operativo]]"
tech_spec: "[[TS-010N4_Supervision_de_Produccion]]"
fecha_aprobacion: 2026-08-10
fecha_actualizacion: 2026-08-10
---

# DEV-010N4: Supervisión de producción

Se autoriza implementar P0 y P1 de TS-010N4 mediante TDD. Esta autorización no
aprueba despliegue, datos productivos ni UAT humana.

## Contrato congelado

- feature `control.productionSupervision`;
- ruta `/control/supervision-produccion`;
- capacidad base `OT_VER`, sin capacidad nueva;
- GET de lista y detalle bajo `/api/scm/v1/observabilidad/ots`;
- GET `/api/scm/v1/observabilidad/resumen?granularidad=DIA|MES`;
- lista una fila por OT; detalle por trabajo/manga; resumen del mismo universo;
- lista con `limit=25` por defecto (`1..100`), cursor versionado que fija
  snapshot/filtros y rango de fechas sin máximo artificial en v1;
- unidades efectivas, kg físico y kg estándar separados;
- enriquecimientos según `MANGA_PESAJE_VER`, `ALERTA_VER` y
  `RECEPCION_MANGA_VER` y `CALIDAD_MANGA_VER`, sin acoplar recepción con
  Calidad;
- `as_of`, última actividad y nulls visibles;
- Jornadas y legacy permanecen separados.

## Secuencia TDD obligatoria

1. **BASELINE:** registrar suites de OT/Trabajo de color, Armado, pesaje,
   recepción, alertas, permisos, navegación y vistas Control.
2. **RED/GREEN N4-01/N4-03:** lista unificada; una OT multicolor aparece una vez
   y agrega hechos vigentes.
3. **RED/GREEN N4-04/N4-05:** Armado y separación kg físico/estándar.
4. **RED/GREEN N4-06/N4-07:** corrección, anulación, recepción, inventario y
   Calidad sin doble conteo.
5. **RED/GREEN N4-08/N4-09:** capacidades parciales, bloques `null` y 403 de
   filtros sensibles.
6. **RED/GREEN N4-10:** filtros/rango/cursor sin pérdida o duplicación; cubrir
   `INVALID_OBSERVABILITY_LIMIT`, `INVALID_OBSERVABILITY_DATE_RANGE`,
   `INVALID_OBSERVABILITY_CURSOR` y `OBSERVABILITY_CURSOR_FILTER_MISMATCH`.
7. **RED/GREEN N4-11:** resumen diario/mensual conciliado.
8. **RED/GREEN N4-12/N4-13:** auto-refresh, pausa, `as_of`, error parcial y
   datos no informados.
9. **RED/GREEN N4-02/N4-14/N4-15:** UI sin comandos, responsive/a11y y
   aislamiento legacy.
10. **REFACTOR:** extraer selectores/serializadores comunes sin introducir un
    agregado o estado persistido.
11. Ejecutar focales, regresión relevante, lint, build y smoke visual.
12. Registrar evidencia en TS/DEV/UAT sin marcar casos humanos aprobados.

## Entregables

- read model de lista, detalle y resumen;
- autorización progresiva y errores sin side channel;
- servicio frontend y feature de workspace;
- vista tabla/tarjetas, filtros y detalle;
- guía visible y vault sincronizados;
- pruebas automáticas y UAT preparada.

## Restricciones de desarrollo

- no añadir comandos a Supervisión;
- no mover acciones de Jornadas;
- no crear `PRODUCCION_SUPERVISAR`;
- no inferir cero desde `null` ni permiso ausente;
- no inventar SLA de eventos; mostrar recencia real;
- no sumar avance provisional con confirmado;
- no sumar pesaje original con su corrección o manga anulada;
- no fusionar kg físicos y estándar;
- no incorporar snapshots legacy en los totales;
- no implementar tendencias avanzadas, exportación o vistas guardadas.

## Gates P0 y P1

| Gate | Criterio |
|---|---|
| P0 listo | día/turno, lista/detalle, resumen esencial, permisos, freshness, responsive y cero comandos |
| P1 listo | rangos, filtros completos, cursor y resumen DIA/MES conciliado |
| salida técnica | suites y build verdes, diff contractual revisado, sin P0/P1 abiertos |
| salida UAT | solo después de ejecutar y firmar [[UAT_TS-010N4_Supervision_de_Produccion]] |

## Estado y evidencia

**Implementado localmente; smoke visual desktop ejecutado y UAT humana pendiente.** Evidencia de
cierre técnico del 2026-08-10:

- backend focal de observabilidad: 8/8; suite backend completa: 351 passed,
  1 skipped OCR, 21 deselected y 0 fallos;
- frontend focal ampliada: 8 archivos y 55/55; suite completa: 57 archivos y
  295/295;
- `npm run lint` y `npm run build`: verdes; el build mantiene únicamente el
  warning no bloqueante de chunk mayor a 500 kB;
- caso de volumen backend: resumen de 103 OT sin truncamiento por la página de
  lista y consultas acotadas por página;
- ninguna migración ni base remota modificada por este cierre.
- smoke local en navegador contra `enva_uat_alcancia`: 2 OT del 2026-08-10
  (Fabricación y Armado), filtro pendiente de pesaje 1/1, modo Recursos y drawer
  OP → OF/OA → OT → TrabajoColor → manga verificados sin ejecutar comandos.

Los comandos reproducibles y el alcance se conservan en
[[TS-010N4_Supervision_de_Produccion#15. Evidencia técnica de cierre local — 2026-08-10|TS-010N4]].
Esta evidencia satisface el gate técnico local, pero no aprueba despliegue,
smoke responsive 390/768/1440 ni [[UAT_TS-010N4_Supervision_de_Produccion|UAT-N4]].

## Incremento implementado N4.1 - indice global de mangas

- [x] Endpoint paginado `/observabilidad/mangas` sin migracion.
- [x] Busqueda servidor por codigo de manga, articulo, color y contexto OT.
- [x] Filtros `manga`, `estado_manga`, `articulo` y cursor con snapshot `as_of`.
- [x] Modo UI `Mangas` junto a Lista de OT y Recursos.
- [x] Tabla desktop y tarjetas responsive.
- [x] Trazabilidad hacia el drawer jerarquico de la OT padre.
- [x] Peso fisico y kg estandar presentados como magnitudes distintas.
- [x] Sin comandos de recepcion, pesaje, correccion o inventario.
- [x] Backend focal N4: 10/10.
- [x] Frontend focal componente+API: 23/23.
- [x] Lint/build, focal componente+API 23/23 y regresion N4/navegacion 57/57.
- [ ] Smoke visual responsive.
- [ ] UAT N4.1 con actores reales.
- [ ] Despliegue Render y smoke remoto.

No se declara disponible en Render hasta completar despliegue y smoke remoto.
