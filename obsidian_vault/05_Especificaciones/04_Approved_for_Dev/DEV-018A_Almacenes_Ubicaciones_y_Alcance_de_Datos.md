---
tipo: approved-for-dev
estado: incremento-local-mvp-validado
historia: "[[US-013A_Almacenes_Ubicaciones_y_Alcance_por_Trabajador]]"
tech_spec: "[[TS-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos]]"
fecha_aprobacion: 2026-08-11
tags: [scm, almacen, ubicacion, scope, permisos, postgres, tdd]
relaciones:
  - "[[2026-08-11_Almacenes_Custodia_Transferencias_y_Kardex_Unico]]"
  - "[[DEV-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
---

# DEV-018A: almacenes, ubicaciones y alcance de datos

Se autoriza desarrollo local conforme a TS-018A. No autoriza migrar Supabase,
desplegar Render ni asignar almacenes reales a usuarios productivos.

## Resultado del incremento

- setup configurable sin almacenes inventados por seed;
- `AlmacenSCM`, jerarquía de ubicaciones y punto de pickup;
- alcance trabajador↔almacén/clase con auditoría;
- autorización backend `capacidad + scope` en listas, totales y detalles;
- adopción preservadora de ubicaciones técnicas actuales;
- administración y selector de ámbito activo.

## Secuencia TDD

1. Ejecutar baseline de inventario, recepción, abastecimiento, auth y migraciones.
2. RED A02: `INVENTARIO_VER` sin scope todavía expone saldos globales.
3. Implementar modelo/migración/API mínima y filtro fail-closed.
4. GREEN A01–A08 uno por uno.
5. Probar PostgreSQL real en schema aislado: constraints, RLS/ACL según patrón
   vigente, concurrencia y downgrade preservador.
6. Integrar setup/frontend solo después del contrato backend verde.
7. Comparar saldos/IDs antes y después del backfill.

## Baseline mínimo

```text
backend\.venv\Scripts\python.exe -m pytest \
  tests\scm\test_scm_inventory_pilot.py \
  tests\scm\test_scm_internal_supply.py -q

frontend> npm.cmd test -- --run \
  src/tests/WarehouseReceivingScm.spec.jsx \
  src/tests/WorkspaceFeatureRoute.spec.jsx \
  src/tests/WorkspaceNavigationShell.spec.jsx
```

## Restricciones

- no codificar `ALM-PIEZAS`, `ALM-MP` o `ALM-PT` como valores obligatorios;
- no filtrar solo en frontend;
- no reasignar ubicaciones con movimientos existentes sin setup versionado;
- no permitir que un rol transversal adquiera capacidad de movimiento;
- no romper endpoints US-010H/US-010I durante expand.

## Definition of Done

- [ ] ATDD A01–A08 con pruebas;
- [ ] migración up/down y single head;
- [ ] 404 sin side-channel para IDs fuera de scope;
- [ ] UI 390/768/1440 y teclado;
- [ ] comparación exacta de saldos;
- [ ] docs/contratos actualizados con evidencia;
- [ ] UAT A permanece pendiente hasta ejecución humana.

## Evidencia local 2026-08-11

- migración `f83a2b4c6d70` aplicada en `enva_test`; Alembic quedó en un solo head;
- modelos, API y administración para almacén, ubicación y alcance sin seeds físicos;
- lectura fail-closed y 404 fuera de alcance cubiertos en pruebas focales;
- smoke visual de `/administracion/almacenes` y `/almacen/operaciones` correcto.

Pendiente antes de producción: PostgreSQL concurrente en schema de test aislado,
backfill decidido por planta y UAT humana A01–A07.
