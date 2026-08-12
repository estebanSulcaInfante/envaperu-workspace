---
tipo: tech-spec
estado: aprobada-para-desarrollo-local
user_story: "[[US-013C_Vistas_Especializadas_y_Control_de_Kardex]]"
tags: [scm, frontend, kardex, control, read-model, responsive, a11y]
relaciones:
  - "[[Vista_US-013_Kardex_y_Operaciones_de_Almacen]]"
  - "[[TS-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos]]"
  - "[[TS-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
  - "[[UAT_TS-018_Kardex_MultiAlmacen_Pickup_y_Custodia]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# TS-018C: vistas especializadas y Control de Kardex

## 1. Arquitectura de información

Área `Almacén e inventario`:

- `Operar Piezas y WIP`;
- `Operar Materias primas`;
- `Operar Producto terminado`;
- `Kardex de mi almacén`;
- `Transferencias y pickup`.

Área `Control`:

- `Control de inventario`, transversal y read-only por defecto.

El inicio deriva la entrada recomendada del scope activo. No se crean roles
rígidos por pantalla ni rutas duplicadas por trabajador.

## 2. Rutas propuestas

```text
/almacen/operaciones?scope=PIEZAS_WIP
/almacen/operaciones?scope=MATERIAS_PRIMAS
/almacen/operaciones?scope=PRODUCTO_TERMINADO
/almacen/kardex
/almacen/transferencias
/control/inventario
```

Los filtros relevantes viven en URL y se validan contra scope. Un valor fuera
del alcance no amplía resultados.

## 3. Read model

Endpoints paginados:

```text
GET /inventario/resumen
GET /inventario/posiciones
GET /inventario/movimientos
GET /transferencias
GET /unidades-logisticas/{codigo}/trazabilidad
```

Respuesta común: `{items,page,as_of,scope}`. Dimensiones: almacén, ubicación,
clase, artículo/material, calidad, disposición, custodio y antigüedad.

Métricas separadas:

- físico;
- libre;
- reservado;
- no disponible;
- en picking;
- en tránsito;
- en staging.

No se suman UN y KG; cada métrica declara unidad.

## 4. Experiencia operativa

### Piezas/WIP

Bandejas de recepción, Calidad, disponibilidad, solicitudes de Armado,
picking/pickup, mesa y retornos.

### Materias primas

Lotes/kg, documentos/Calidad, reservas, emisión, devolución, premezcla y
recuperado. Reutiliza US-010A/B, no simula mangas.

### Producto terminado

Recepción desde Armado, Calidad, ubicación, disponibilidad y futura
preparación de despacho. El despacho comercial permanece fuera de alcance.

## 5. Control

KPIs y tabla no ejecutan movimientos. Quick filters:

- tránsito envejecido;
- recepción pendiente;
- bloqueado por Calidad;
- diferencias abiertas;
- saldos negativos/imposibles (debe ser cero);
- ubicaciones sin responsable;
- transferencias por custodio.
- mangas pesadas sin recepción por más de 24 horas;

El detalle muestra línea de tiempo `What/When/Where/Why`, origen/destino,
documento causal y deep link a la acción autorizada.

Control integra las alertas `TRANSFERENCIA_DIFERENCIA` y
`MANGA_PESADA_SIN_RECEPCION`; la bandeja operativa muestra el mismo ID/estado
que US-010J y no crea un segundo sistema de incidencias.

## 6. UX de sesión QR

- contexto origen/destino fijo y visible;
- foco persistente en QR;
- contador válido/rechazado/duplicado;
- lista removible antes de confirmar;
- resumen del efecto de Kardex;
- acción primaria sticky, visible en 390 px;
- confirmación supervisada para lotes;
- feedback no dependiente únicamente del color.

## 7. Seguridad

El cliente consume el scope del servidor, pero la API filtra todas las listas,
resúmenes, búsquedas, exports y detalles. Control transversal exige
`INVENTARIO_CONTROL_TRANSVERSAL`; una mutación sigue exigiendo su capacidad
operativa y scope, aunque se navegue desde Control.

## 8. Frescura

Polling configurable inicial; no requiere WebSocket. `as_of` siempre visible.
Si falla refresh, se conserva snapshot con alerta. Tiempo real puede añadirse
después sin cambiar contratos autoritativos.

## 9. Pruebas

| ATDD | Nivel |
|---|---|
| C01–C03 | UI/registry por scope |
| C04/C06/C09/C10 | read model/integración/alertas |
| C05 | autorización + side-channel |
| C07 | búsqueda/trazabilidad |
| C08 | UI 390/768/1440 + teclado/a11y |

Primera RED: un almacenero de PT consulta el resumen global vigente y ve clases
ajenas. La prueba debe exigir scope fail-closed en lista, totales y búsqueda.

## 10. Puertas

- [ ] validar terminología con los tres almaceneros;
- [ ] confirmar qué funciones reales comparten una persona;
- [ ] validar móvil/lector en planta;
- [ ] UAT de Control sin capacidad de mutación;
- [ ] no retirar `/produccion/kardex` hasta equivalencia y redirección aprobadas.
