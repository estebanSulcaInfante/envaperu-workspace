---
tipo: approved-for-dev
estado: incremento-local-mvp-validado
historia: "[[US-013C_Vistas_Especializadas_y_Control_de_Kardex]]"
tech_spec: "[[TS-018C_Vistas_Especializadas_y_Control_de_Kardex]]"
fecha_aprobacion: 2026-08-11
tags: [scm, frontend, kardex, control, read-model, responsive, a11y, tdd]
relaciones:
  - "[[DEV-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos]]"
  - "[[DEV-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
  - "[[Vista_US-013_Kardex_y_Operaciones_de_Almacen]]"
---

# DEV-018C: vistas especializadas y Control de Kardex

Se autoriza desarrollo local después de A y B verdes. Las vistas especializadas
son proyecciones del mismo ledger; no se crean tres implementaciones de Kardex.

## Resultado del incremento

- workspace operativo según scope para Piezas/WIP, MP y PT;
- Kardex de mi almacén y bandeja de transferencias/pickup;
- `/control/inventario` transversal, read-only por defecto;
- búsqueda por QR/código con timeline y custodia;
- KPIs por unidad sin sumar UN/KG;
- diferencias y mangas >24 h enlazadas a Alertas;
- `as_of`, cursor, estado stale y responsive/a11y.

## Secuencia TDD

1. RED C05: resumen/lista/búsqueda vigentes exponen datos globales.
2. Construir read model paginado y scoped con query-bound.
3. GREEN posiciones, movimientos, transferencias y detalle QR.
4. Montar shell por scope y navegación sin duplicar componentes.
5. GREEN Control sin mutaciones y deep links condicionados.
6. Probar búsqueda/export/detail contra side-channels.
7. Probar 390/768/1440, Tab/Shift+Tab, foco, live region y reduced motion.
8. Mantener rutas antiguas durante comparación y retirar solo tras UAT.

## Baseline mínimo

```text
frontend> npm.cmd test -- --run \
  src/tests/navigation.spec.js \
  src/tests/WorkspaceFeatureRoute.spec.jsx \
  src/tests/WorkspaceNavigationShell.spec.jsx

frontend> npm.cmd run lint
frontend> npm.cmd run build
```

Backend debe añadir una suite focal de observabilidad de inventario con límites
de consultas, cursor/snapshot, scope y unidades.

## Restricciones

- Control no concede capacidad operativa;
- filtros URL nunca amplían scope;
- no sumar UN y KG;
- no duplicar alertas ni inventar tiempo real;
- no retirar `/produccion/recepcion-mangas` o `/produccion/kardex` antes de
  equivalencia funcional y redirección aprobada.

## Definition of Done

- [ ] ATDD C01–C10 verdes;
- [ ] read model scoped/query-bound;
- [ ] suites focales, regresión, lint y build verdes;
- [ ] smoke visual en tres anchos;
- [ ] comparación con vistas antiguas;
- [ ] UAT G/H pendiente hasta ejecución humana.

## Evidencia local 2026-08-11

- nuevas rutas `/almacen/operaciones`, `/almacen/kardex`,
  `/almacen/transferencias`, `/control/inventario` y `/administracion/almacenes`;
- Control no renderiza acciones operativas y la API mantiene capability + scope;
- búsqueda de unidad logística y KPIs separados en UN y KG;
- 25 pruebas frontend focales, lint y build verdes;
- smoke visual escritorio y 390 px correcto.

Pendiente antes de producción: cursor/exportación del read model, comparación
formal con las vistas legacy y UAT humana G/H.
