---
tipo: user-story
subtipo: historia-hija
estado: aprobada-para-desarrollo-local
epica: "[[US-013_Kardex_MultiAlmacen_Custodia_y_Operaciones_QR]]"
tags: [scm, almacen, ubicacion, trabajador, permisos, alcance, atdd]
relaciones:
  - "[[Almacen_SCM]]"
  - "[[Ubicacion_Inventario]]"
  - "[[TS-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# US-013A: almacenes, ubicaciones y alcance por trabajador

## Historia

**Como** gerente o administrador SCM  
**Quiero** definir almacenes, su jerarquía de ubicaciones y el alcance de cada
trabajador  
**Para** que las operaciones y consultas ocurran únicamente dentro del ámbito
físico y organizacional autorizado.

## Criterios de aceptación

### AGP-A01 — Jerarquía explícita

**Dado** que la planta no posee códigos ni jerarquía previamente definidos  
**Cuando** el administrador crea un almacén y sus zonas de recepción,
cuarentena, posiciones, staging y pickup  
**Entonces** todas quedan bajo el almacén y conservan tipo/compatibilidad sin
inferirse desde el nombre.

### AGP-A02 — Capacidad sin alcance

**Dado** un trabajador con `INVENTARIO_VER` pero sin almacén asignado  
**Cuando** consulta el Kardex operativo  
**Entonces** no obtiene existencias de un almacén ajeno y recibe una explicación
sin revelar totales.

### AGP-A03 — Alcance sin capacidad

**Dado** un trabajador asignado a `ALM-PT` sin `INVENTARIO_MOVILIZAR`  
**Cuando** intenta confirmar un traslado  
**Entonces** la API responde `403` y no crea movimiento.

### AGP-A04 — Especialización no exclusiva

**Dado** un almacenero asignado a Piezas/WIP y PT  
**Cuando** cambia su ámbito activo  
**Entonces** conserva una sola identidad y ve únicamente los dos ámbitos
asignados.

### AGP-A05 — Desactivación preservadora

**Dado** un almacén o ubicación con historia  
**Cuando** se desactiva  
**Entonces** permanece en consultas históricas, no admite nuevas operaciones y
sus saldos deben transferirse o quedar bloqueados explícitamente.

### AGP-A06 — Backfill piloto

**Dadas** `RECEPCION_PIEZAS_WIP`, `RECEPCION_PT`, `MESA_ARMADO`,
`TRANSITO_PRODUCCION` y `TRANSITO_ALMACEN`  
**Cuando** se migra la jerarquía  
**Entonces** se preservan IDs/movimientos/saldos y los puntos de tránsito no se
presentan como almacenes disponibles.

### AGP-A07 — Administración auditable

**Cuando** se asigna, revoca o cambia el alcance de un trabajador  
**Entonces** se registra actor, fecha, before/after y versión; una sesión
abierta se revalida antes de confirmar.

### AGP-A08 — Configuración sin semillas ficticias

**Dada** una instalación nueva  
**Cuando** se ejecutan migraciones y configuración inicial  
**Entonces** existen capacidades y catálogos técnicos, pero ningún almacén
físico inventado; un administrador completa el setup antes de operar.

## Errores de dominio

- `WAREHOUSE_SCOPE_REQUIRED`;
- `WAREHOUSE_SCOPE_FORBIDDEN`;
- `LOCATION_NOT_IN_WAREHOUSE`;
- `LOCATION_CLASS_INCOMPATIBLE`;
- `WAREHOUSE_INACTIVE`;
- `SCOPE_VERSION_CONFLICT`.

## Definición de preparada

- jerarquía e invariantes validadas;
- migración de códigos piloto definida;
- matriz capacidad + alcance explícita;
- ATDD A01–A07 observables;
- ATDD A08 evita convertir ejemplos en datos reales;
- no depende de decidir precios, contabilidad ni layout exacto de planta.
