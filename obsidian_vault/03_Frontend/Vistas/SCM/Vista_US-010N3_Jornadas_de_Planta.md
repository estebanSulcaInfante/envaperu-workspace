---
tipo: vista_frontend
estado: implementada-local-pendiente-uat
ruta: /produccion/ots-mangas
tags: [frontend, scm, ux, jornadas, fabricacion, armado, responsive]
relaciones:
  - "[[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes]]"
  - "[[TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]]"
  - "[[Vista_US-010M_OT_y_Trabajos_Color]]"
  - "[[Guia_Operativa_SCM_US-010]]"
fecha_creacion: 2026-08-09
fecha_actualizacion: 2026-08-09
---

# Vista US-010N3: Jornadas de Planta

## Propósito

Dar una lectura diaria completa de Planta sin mezclar agregados: Fabricación se
consulta por máquina y Armado por centro. El tablero orienta y enlaza; cada
proceso conserva su editor y contratos actuales.

## Arquitectura de información

```text
Jornadas de Planta
[Fecha operativa] [Turno] [Actualizar]

[ Fabricación por máquina ] [ Armado por centro ]

FABRICACIÓN
┌ Haitian 3000 · OT-000123 · Produciendo ┐  ┌ Sopladora 02 · Sin OT ┐
│ Verde sólido · OF-000042 · Renato      │  │ [Preparar OT]          │
│ Manga 3/5 · siguiente Azul sólido      │  └────────────────────────┘
└ [Abrir jornada] ───────────────────────┘

ARMADO
┌ Mesa 1 · OT-000141 · En ejecución ─────┐  ┌ Mesa 2 · Sin OT ──────┐
│ OA-000025 · Alcancía Pablo             │  │ [Preparar OT]          │
│ 400/500 un · Abastecimiento recibido   │  └────────────────────────┘
└ [Abrir jornada] ───────────────────────┘
```

Los modos son pares del mismo tablero, no estados de una sola OT. Cambiar de
modo conserva fecha y turno.

## Tarjeta de Fabricación

Reutiliza las reglas de [[Vista_US-010M_OT_y_Trabajos_Color]]:

- recurso principal: máquina;
- actual: Trabajo de color hijo, artículo y OF;
- estado **Produciendo** solo con hijo `EN_EJECUCION`;
- conteos del trabajo actual, no de toda la OT;
- tarjeta sin OT visible para preparar jornada;
- click abre la OT y cola existentes.

## Tarjeta de Armado

- recurso principal: mesa/celda/centro;
- OT y OA exactas;
- artículo WIP/PT de salida;
- responsable y modalidad Mesa/Concurrente;
- cuota confirmada/objetivo;
- mangas y abastecimiento;
- click abre el contexto de la OA/OT existentes.

Una tarjeta de centro puede contener `0..N` OT de Armado en la fecha/turno. Si
hay más de una, muestra la OT activa y un selector/lista para las demás; nunca
combina dos OA en una OT visual ficticia ni descarta coincidencias.

No muestra color como identidad del Armado ni crea `TrabajoArmado`. Cuando la
modalidad es Concurrente, muestra como contexto el Trabajo de color exacto sin
atribuirle el resultado de Armado.

## Fechas en OF/OA

Las tarjetas y detalles de órdenes técnicas usan un bloque read-only:

```text
Necesidad: 12–15 ago 2026
Jornadas programadas: 10–14 ago 2026 · 3 OT
```

Casos vacíos: **Sin fecha de necesidad** y **Sin jornada programada**. Los
timestamps de creación/liberación pueden aparecer en auditoría, nunca como
plazo operativo.

## Edición contextual

- **Abrir jornada** selecciona la OT; no guarda datos.
- **Preparar OT** lleva el recurso ya seleccionado al formulario autorizado.
- Fabricación expande/abre su cola y mangas.
- Armado abre `/produccion/ordenes-armado?oa=&ot=`.
- volver al tablero conserva `fecha`, `turno` y `modo`.
- una acción sin capacidad no se renderiza; la API conserva autoridad.

## Armado concurrente

El selector presenta opciones con:

```text
VERDE SÓLIDO · Alcancía Pablo · OF-000042 · OT-000123 · Haitian 3000
```

Si una OT tiene varios trabajos no existe opción genérica “OT-000123”. Guardar
requiere el Trabajo de color exacto y el backend deriva la OT padre.

## Responsive y accesibilidad

- escritorio: cuadrícula de tarjetas y panel de detalle;
- tablet: dos columnas cuando exista ancho real;
- móvil: una columna, acción primaria visible y secundarias en menú;
- tabs/selector con nombre accesible y foco conservado;
- ningún control esencial depende de hover;
- sin scroll horizontal global.

## Estados

- carga con skeleton por recurso;
- recurso activo sin OT;
- recurso inactivo con histórico, solo consulta;
- error parcial por catálogo o jornadas;
- sin capacidad de edición;
- conflicto de versión al ejecutar desde el detalle;
- múltiple OT legacy en un recurso, ninguna se oculta.

## Estado de disponibilidad

N3 está implementada localmente en `/produccion/ots-mangas`: comparte fecha y
turno entre Fabricación y Armado, conserva el contexto en la URL y enlaza cada
OT de Armado con su OA exacta. La edición especializada continúa en
`/produccion/ordenes-armado`.

El despliegue, el smoke visual en 390/768/1440 px y la aceptación humana siguen
pendientes en [[UAT_TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]].
