---
tipo: decision-arquitectura
estado: aceptada
fecha_decision: 2026-08-10
fecha_actualizacion: 2026-08-10
tags: [scm, control, supervision, produccion, read-model, permisos, ux]
relaciones:
  - "[[US-010N4_Supervision_de_Produccion_Read_Model_Operativo]]"
  - "[[TS-010N4_Supervision_de_Produccion]]"
  - "[[Vista_US-010N4_Supervision_de_Produccion]]"
  - "[[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes]]"
  - "[[2026-08-09_Jornadas_de_Planta_y_Fechas_Proyectadas_de_OF_OA]]"
  - "[[US-011A_Dashboard_Gerencial_Avance_Pesajes]]"
  - "[[Registro_Diario]]"
---

# Supervisión de producción como read model de Control

## Contexto

**Jornadas de Planta** organiza y abre la ejecución de una fecha y turno por
máquina o centro. Esa superficie debe conservar formularios, preparación de OT
y navegación hacia el agregado operativo exacto.

Una jefatura necesita otra pregunta: qué OT requieren atención en un día o
rango, qué etapa alcanzaron y qué cantidades, pesajes, recepciones, inventario,
Calidad o alertas las respaldan. Resolverla dentro de Jornadas haría crecer la
vista operativa, ocultaría recursos y mezclaría autoridad de escritura con una
proyección transversal.

Las vistas de avance y pesajes legacy tampoco pueden ser esa autoridad: sus
snapshots locales no crean inventario normalizado y los kg físicos no equivalen
a kg estándar atribuibles a la transformación.

## Decisión

### 1. Dos superficies, dos intenciones

- **Producción / Jornadas de Planta** conserva la operación diaria: recurso,
  fecha, turno, preparación y apertura de la OT o OA exacta.
- **Control / Supervisión de producción** es un read model sin comandos que
  consulta Fabricación y Armado juntos, permite rango y filtros, y abre un
  detalle de solo lectura.
- Supervisión no crea, inicia, pausa, cierra, corrige, anula, recibe ni libera.
  Enlaza a la vista autoritativa únicamente cuando la persona tiene capacidad.

### 2. Identidad de navegación y autorización

- `featureKey`: `control.productionSupervision`.
- ruta canónica: `/control/supervision-produccion`.
- alias compatible permitido: `/produccion/supervision`, con redirección a la
  canónica y sin una segunda implementación.
- capacidad base: `OT_VER`.
- no se crea `PRODUCCION_SUPERVISAR` en este corte.

Los enriquecimientos se gobiernan por capacidades ya existentes:
`MANGA_PESAJE_VER`, `ALERTA_VER`, `RECEPCION_MANGA_VER` y
`CALIDAD_MANGA_VER`. Almacén y Calidad se degradan independientemente. Un campo
no autorizado se omite o queda `null` y `visibilidad` explica la degradación.
Un filtro sobre una dimensión sensible responde `403`; no revela por conteos la
existencia de hechos ocultos.

### 3. Contrato de lectura

La API canónica es:

- `GET /api/scm/v1/observabilidad/ots`;
- `GET /api/scm/v1/observabilidad/ots/{public_id}`;
- `GET /api/scm/v1/observabilidad/resumen?granularidad=DIA|MES`.

Lista, detalle y resumen comparten filtros, semántica, `as_of` UTC y reglas de
autorización. El cursor es opaco, estable para los filtros originales y no es
un número de página inventado por el cliente.

La lista usa `limit=25` por defecto y admite de 1 a 100. No se fija un máximo
de días en v1; `desde > hasta` es inválido. El cursor versionado conserva el
`as_of`, la última clave `(fecha_operativa, id)` y la huella de filtros: no
expira por tiempo en v1, un cursor inválido se rechaza y uno reutilizado con
otros filtros produce conflicto. La página siguiente conserva el mismo
snapshot, no remezcla hechos nuevos a mitad del recorrido.

### 4. Métricas que no se fusionan

- **Unidades efectivas:** hechos productivos vigentes de la OT, después de
  correcciones y anulaciones. Avance provisional no se suma al confirmado.
- **Kg estándar de salida:** unidades efectivas por pesos técnicos congelados;
  expresa atribución estándar, no lectura de balanza.
- **Kg físicos pesados:** netos vigentes medidos en mangas de la OT. Una manga
  armada puede incluir componentes anteriores y no se atribuye íntegramente a
  la máquina actual.
- **Inventario y Calidad:** nacen de recepción, movimientos y decisión de
  Calidad; pesar no vuelve disponible una manga.

El resumen presenta kg físico y estándar como series separadas. Nunca calcula
uno como fallback del otro ni suma datos legacy y normalizados.

### 5. Estados separados

La proyección conserva, sin inventar un estado totalizador:

- estado documental de OT y documento superior;
- estado operativo de OT, Trabajo de color o manga;
- estado logístico de manga/recepción;
- estado de Calidad/inventario cuando es visible;
- `etapa_actual` como rótulo derivado para orientar, no como transición.

### 6. Recencia y datos parciales

Cada respuesta incluye `as_of`. La UI actualiza cada 30 segundos mientras la
pestaña está activa y permite pausar explícitamente. La antigüedad del snapshot
se muestra; `ultimo_evento_at` representa actividad de negocio y no se usa para
afirmar que una fuente está caída.

Los datos faltantes o no autorizados no se transforman en cero. La fila y el
detalle declaran visibilidad, riesgo y campos incompletos; la supervisión puede
seguir consultándose sin fingir completitud.

### 7. Alcance incremental

P0 y P1 forman un solo incremento aprobable:

- **P0:** día/turno, una fila por OT, resumen esencial, filtros rápidos,
  detalle, tarjetas móviles, recencia, permisos y estados vacíos/error.
- **P1:** rangos validados, resumen diario/mensual, filtros
  completos, paginación por cursor y enriquecimientos progresivos.

Tendencias avanzadas, pronóstico, exportación, vistas guardadas y constructor
de indicadores quedan fuera o en backlog. No se introducen silenciosamente en
P1.

## Consecuencias

- Jornadas permanece comprensible para quien ejecuta.
- Control obtiene una consulta transversal sin una nueva fuente de verdad.
- Las métricas conservan trazabilidad semántica y permisos sin side channels.
- Backend puede optimizar el read model sin crear comandos ni cambiar los
  agregados productivos.
- La pantalla legacy de avance por estación continúa separada y rotulada como
  tal hasta su retiro explícito.

## Alternativas descartadas

1. **Agregar todos los indicadores a Jornadas:** mezcla consulta con ejecución
   y vuelve a esconder el tablero bajo formularios.
2. **Reutilizar el dashboard legacy:** confunde snapshot local con hechos SCM.
3. **Crear una capacidad nueva en este corte:** rompe roles y despliegue sin
   aportar una frontera de seguridad adicional a `OT_VER` más enriquecimientos.
4. **Exportar o guardar vistas en P1:** amplía retención, seguridad y soporte
   antes de validar el read model básico.

## Addendum N4.1 - indice global de mangas

Se acepta una tercera perspectiva dentro de **Control > Supervision de
produccion**: `Mangas`. No es una recepcion ni un Kardex alterno. Es un indice
de solo lectura para encontrar una unidad logistica en cualquier estado y
recorrer su trazabilidad hacia OT, Trabajo de color, OF/OA y OP.

Decisiones congeladas:

- la busqueda admite codigo completo o parcial de manga, articulo y color;
- los filtros y el cursor se conservan en la URL, pero el cursor se reinicia al
  cambiar entre `Lista de OT`, `Recursos` y `Mangas`;
- cada fila distingue cantidad, peso fisico efectivo, kg estandar, etiqueta y
  estado logistico sin sumar hechos incompatibles;
- la visibilidad de pesaje, almacen, Calidad y alertas sigue siendo progresiva
  por capacidades; `OT_VER` habilita la identidad y genealogia base;
- no se crea tabla ni migracion: el indice deriva del read model normalizado;
- el incremento queda local y pendiente de UAT/despliegue; no esta en Render.

## Addendum N4.2 - OTs de planta e impresion central

- **Produccion / OTs de planta** es la entrada operativa. La ruta canonica es
  `/produccion/ots-planta`; prepara OT por recurso y abre un espacio separado
  `/produccion/ots-planta/trabajo` para Trabajo de color, responsables y mangas.
- `/produccion/ots-mangas` queda como alias de compatibilidad y no como nombre
  visible ni ruta producida por enlaces nuevos.
- **Control / Impresion y etiquetas** es solo lectura sobre la bandeja de salida
  persistida en la central. No reclama ni imprime trabajos.
- La estacion sigue consultando remotamente su bandeja al abrir o actualizar;
  el heartbeat no transporta ni almacena trabajos de impresion.
- Prepesaje requiere vista previa y confirmacion manual en estacion. Postpesaje
  conserva su impresion automatica posterior al pesaje confirmado.