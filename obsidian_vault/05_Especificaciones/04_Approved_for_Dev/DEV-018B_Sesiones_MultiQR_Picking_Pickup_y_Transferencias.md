---
tipo: approved-for-dev
estado: incremento-local-mvp-validado
historia: "[[US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
tech_spec: "[[TS-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
fecha_aprobacion: 2026-08-11
tags: [scm, qr, picking, pickup, transferencia, custodia, alertas, tdd]
relaciones:
  - "[[DEV-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos]]"
  - "[[DEV-018C_Vistas_Especializadas_y_Control_de_Kardex]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
  - "[[US-010J_Alertas_Operativas_e_Inconsistencias]]"
---

# DEV-018B: sesiones multi-QR, picking, pickup y transferencias

Se autoriza desarrollo local después de A verde. No autoriza desplegar ni
reemplazar de inmediato el flujo US-010H/US-010I.

## Resultado del incremento

- sesión con tipo/modalidad/origen/destino y 1..100 QR;
- candidatos validados sin movimiento hasta confirmar;
- transferencia y custodia durable;
- entrega con tránsito y recepción separados;
- pickup por solicitante con origen→`MESA_ARMADO` atómico, sin consumo;
- retorno preservador;
- diferencia explícita y concurrencia fail-closed;
- alertas `TRANSFERENCIA_DIFERENCIA` y
  `MANGA_PESADA_SIN_RECEPCION` (>24 h configurable).

## Secuencia TDD

1. Baseline de inventario, recepción, abastecimiento y alertas.
2. RED B04: el despacho vigente depende del código de tránsito y no posee
   transferencia/custodia de primera clase.
3. Crear sesión/transferencia UoW sin mover todavía UI.
4. GREEN ingreso multi-QR, reserva/picking, entrega y recepción.
5. RED pickup: confirmar debe producir dos eventos y un solo commit directo a
   Mesa, sin consumo ni saldo intermedio.
6. GREEN retorno, diferencia 10→9, replay y competencia PostgreSQL.
7. RED/Green alertas con reloj controlado a 23:59 y >24:00.
8. Integrar UI con lector/teclado y feature flag.
9. Ejecutar comparación dual del flujo US-010H antiguo/nuevo.

## Baseline mínimo

```text
backend\.venv\Scripts\python.exe -m pytest \
  tests\scm\test_scm_internal_supply.py \
  tests\scm\test_scm_inventory_pilot.py -q

frontend> npm.cmd test -- --run \
  src/tests/InternalSupplyScm.spec.jsx \
  src/tests/WarehouseReceivingScm.spec.jsx
```

## Invariantes de implementación

- total físico global se conserva en transferencias;
- pickup acredita Mesa y transfiere custodia, pero no consume;
- una manga solo pertenece a una transferencia activa;
- lote confirmado es atómico/idempotente;
- diferencia no se distribuye ni ajusta automáticamente;
- alertas comparten US-010J y no mueven inventario;
- el umbral 24 h es revisión de regla, no constante del componente.

## Definition of Done

- [ ] ATDD B01–B11 verdes;
- [ ] UoW, rollback, replay y conflicto cubiertos;
- [ ] PostgreSQL concurrente real en schema aislado;
- [ ] lector Enter y lote 20 cubiertos en UI automatizada;
- [ ] compatibilidad US-010H/US-010I sin doble movimiento;
- [ ] UAT B–F permanece pendiente de ejecución física.

## Evidencia local 2026-08-11

- sesión 1..100 QR; escanear y quitar candidatos no altera Kardex;
- pickup confirmado mueve origen→Mesa y custodia sin consumo y con replay idempotente;
- entrega usa ubicación técnica de tránsito y recepción explícita;
- diferencia crea incidencia/alerta sin ajustar saldos; retorno prepara el flujo inverso;
- consulta de trazabilidad por código/UUID devuelve custodia, transferencias y movimientos.

Pendiente antes de producción: competencia PostgreSQL real, lector físico,
casos de diferencia 10→9 y reloj controlado de 24 h en UAT.
