---
tipo: user-story
subtipo: historia-hija
estado: aprobada-para-desarrollo-local
epica: "[[US-013_Kardex_MultiAlmacen_Custodia_y_Operaciones_QR]]"
tags: [scm, kardex, vistas, almacen, control, observabilidad, atdd]
relaciones:
  - "[[Vista_US-013_Kardex_y_Operaciones_de_Almacen]]"
  - "[[TS-018C_Vistas_Especializadas_y_Control_de_Kardex]]"
  - "[[US-013A_Almacenes_Ubicaciones_y_Alcance_por_Trabajador]]"
  - "[[US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# US-013C: vistas especializadas y Control de Kardex

## Historia

**Como** almacenero especializado o jefe de Control  
**Quiero** una experiencia enfocada en mi tipo de inventario y un consolidado
transversal cuando tengo permiso  
**Para** operar sin ruido y supervisar saldos, tránsito, bloqueos y diferencias.

## Criterios de aceptación

### AGP-C01 — Piezas y WIP

La vista prioriza recepción desde Fabricación, calidad, stock por pieza/color,
picking hacia Armado, mangas en mesa y retornos.

### AGP-C02 — Materias primas

La vista prioriza lotes/kg, calidad documental, reserva/emisión a OF, premezcla,
devoluciones y material recuperado sin presentar mangas PT como candidatas.

### AGP-C03 — Producto terminado

La vista prioriza recepción desde Armado, calidad, ubicación, disponibilidad y
preparación de despacho, sin mezclar piezas internas.

### AGP-C04 — Mismo ledger

**Dado** un traslado de 200 unidades de Piezas a Armado  
**Cuando** lo consultan Piezas y Control  
**Entonces** ambos ven el mismo movimiento/transferencia, con distinta
presentación y sin doble contabilización.

### AGP-C05 — Scope fail-closed

Un almacenero de PT no puede descubrir cantidades, códigos sensibles ni
transferencias de MP fuera de su alcance mediante búsqueda, resumen, export o
detalle.

### AGP-C06 — Control transversal

Control muestra físico, libre, reservado, no disponible, picking, tránsito y
staging por almacén/clase, además de transferencias envejecidas y diferencias.

### AGP-C07 — Búsqueda por QR/código

La búsqueda encuentra una manga autorizada y presenta línea de tiempo,
ubicación/custodio actual, documento causal y siguiente acción; no permite
mutar desde Control salvo capacidad específica.

### AGP-C08 — Responsive y accesibilidad

En escritorio se usa tabla densa; en 390/768 px tarjetas/acciones no desbordan.
Filtros, lectura de estados y acciones son operables por teclado y no dependen
solo de color.

### AGP-C09 — Frescura honesta

Toda proyección muestra `as_of`; un fallo de actualización conserva el último
snapshot marcado como desactualizado y nunca finge tiempo real.

### AGP-C10 — Alertas logísticas

Control y la bandeja de Alertas muestran diferencias de transferencia desde que
se detectan y mangas pesadas sin recepción al superar 24 horas. Reconocer o
resolver una alerta no mueve inventario ni corrige el hecho origen.

## Fuera de alcance

- valoración monetaria;
- forecasting de inventario;
- despacho comercial completo;
- diseño de layout físico o recomendación automática de bins.
