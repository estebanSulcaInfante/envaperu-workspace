---
tipo: vista-frontend
estado: implementado
tags: [frontend, scm, pesaje, dashboard, gerencia, us-011a]
relaciones:
  - "[[US-011A_Dashboard_Gerencial_Avance_Pesajes]]"
  - "[[US-011_Monitorear_Estaciones_de_Pesaje]]"
  - "[[TS-TE-004_Despliegue_y_Comunicacion_Estacion_Pesaje]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
fecha_creacion: 2026-07-17
fecha_actualizacion: 2026-07-23
---

# Vista US-011A: Dashboard de Avance por Pesajes

## Ruta y madurez

- ruta: `/pesaje/avance`;
- navegacion: `Pesaje > Avance de produccion`;
- fuente: API central real;
- madurez: monitor temporal implementado;
- actor principal: Gerencia y responsable de Produccion;
- autoridad: consulta de solo lectura.

## Proposito

Mostrar kilos físicos y bolsas reportados por la estacion local, separados por contexto de OP y fecha operativa. La vista permite monitorear el embalaje sin abrir ni controlar remotamente la aplicacion instalada junto a la balanza.

La pantalla actualmente declara `Reporte local legacy` y advierte que el dato no confirma inventario SCM, consumo ni unidad logistica. Queda pendiente añadir la advertencia específica de composición: tampoco demuestra que todo el peso pertenezca a la salida del molde, porque una bolsa prearmada puede incluir componentes previos como asas.

## Anatomia

1. Cabecera compacta con nombre de la vista, fuente y actualizacion manual.
2. Aviso de autoridad del dato.
3. Filtros de fecha, OP, maquina y turno.
4. Hora del ultimo snapshot productivo recibido.
5. Indicadores de peso, bolsas, OP y estaciones reportantes.
6. Advertencia cuando el heartbeat no es reciente.
7. Tabla por OP en escritorio o lista compacta en movil.
8. Avance porcentual solo cuando central posee una meta mayor que cero.
9. Detalle desplegable por OT, molde, color, maquina, turno, bolsas y peso.

## Estados de interfaz

| Estado | Representacion |
|---|---|
| Cargando inicial | Indicador de progreso y texto de consulta. |
| Actualizacion | Barra superior sin retirar los datos previos. |
| Vacio | Mensaje sin pesajes para fecha y filtros. |
| Error | Alerta reintentable; aclara que la balanza local no se afecta. |
| OP sin meta | Chip `Sin meta`, porcentaje nulo y causa visible. |
| Heartbeat atrasado | Conserva el avance con advertencia, sin afirmar apagado. |
| Fuente legacy | Chip permanente y aviso de no inventario. |

## Contrato consumido

`GET /api/monitoring/v1/production-progress`

Parametros soportados:

- `date=AAAA-MM-DD`;
- `op`;
- `machine_code`;
- `shift`.

La API agrega por OP y conserva `details` con las dimensiones reportadas por la estacion. El total de la pagina procede del mismo read model filtrado; React no recalcula kilos parciales a partir de filas ocultas.

## Responsividad

- `>= md`: tabla operativa con siete columnas y detalle colapsable;
- `< md`: tarjetas de OP con peso, bolsas, estado y detalle;
- filtros apilados hasta `lg` para respetar el ancho restante despues del sidebar;
- metricas en dos columnas moviles y cuatro columnas de escritorio;
- documento sin overflow horizontal en 390 px, 909 px y 1440 px.

## Pruebas automatizadas

La suite `ProductionProgressDashboard.spec.jsx` cubre:

- dos OP separadas;
- porcentaje con meta y `Sin meta` sin `0%` inventado;
- nueva consulta al filtrar por maquina;
- detalle que no mezcla otra OT;
- error y reintento.

## Limites pendientes

- El listado completo de estaciones, incluso las que no pesaron en la fecha, sigue perteneciendo a US-011.
- La autenticacion humana permanece diferida y el acceso debe limitarse a red interna.
- US-010D reemplazara la fuente legacy por eventos ligados a lote de salida y unidad logistica.
- US-010F permitirá separar producción de la OT, prearmado provisional abierto, armado confirmado, componentes previos y peso físico de la bolsa; el contrato legacy actual no puede reconstruir esa composición.
- Mientras continúe el contrato legacy, la interfaz debe incorporar el aviso de posible bolsa compuesta y renombrar la métrica como peso físico reportado; este ajuste todavía no está implementado.
