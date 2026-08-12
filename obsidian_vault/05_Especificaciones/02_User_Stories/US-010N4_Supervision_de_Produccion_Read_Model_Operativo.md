---
tipo: user-story
estado: implementada-local-pendiente-uat
tags: [scm, control, supervision, produccion, fabricacion, armado, atdd]
relaciones:
  - "[[2026-08-10_Supervision_de_Produccion_como_Read_Model_de_Control]]"
  - "[[TS-010N4_Supervision_de_Produccion]]"
  - "[[Vista_US-010N4_Supervision_de_Produccion]]"
  - "[[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes]]"
  - "[[US-011A_Dashboard_Gerencial_Avance_Pesajes]]"
  - "[[Registro_Diario]]"
  - "[[Control_Peso]]"
  - "[[Inventario_SCM]]"
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
---

# US-010N4: Supervisión de producción

## Historia

**Como** jefatura, supervisión o persona autorizada de consulta \
**Quiero** revisar en una sola vista el estado y avance trazable de las OT de
Fabricación y Armado \
**Para** detectar qué requiere atención sin entrar máquina por máquina, sin
modificar la ejecución y sin confundir peso físico, producción estándar,
recepción, inventario o Calidad.

## Resultado observable

Desde **Control / Supervisión de producción**, una persona con `OT_VER` puede
consultar una fila por OT, filtrar el período y abrir su detalle. La vista
declara cuándo fue calculada, qué dimensiones puede ver y qué datos están
incompletos. Ninguna interacción de esta historia muta Producción.

## Alcance

### P0 incluido

- fecha operativa y turno, con valor inicial del día local `America/Lima`;
- Fabricación y Armado en la misma lista, sin fusionar sus métricas;
- una fila por OT, aunque tenga varios Trabajos de color;
- resumen esencial del período visible;
- búsqueda y filtros rápidos por tipo, etapa, recurso, responsable y riesgo;
- detalle de solo lectura con documentos superiores, trabajos, mangas,
  pesajes, recepción y alertas según permisos;
- autoactualización cada 30 segundos, pausa, `as_of` y estado de recencia;
- tabla en escritorio, tarjetas en móvil y panel/drawer de detalle;
- carga, vacío, error total, error parcial y datos incompletos.

### P1 incluido

- rango validado y granularidad diaria o mensual, sin máximo temporal
  inventado en v1;
- filtros completos por estados, códigos, color y dimensiones sensibles;
- paginación por cursor opaco versionado, `limit=25` por defecto y rango
  permitido de 1 a 100;
- resumen consistente con el mismo universo filtrado;
- degradación progresiva según capacidades, sin revelar dimensiones ocultas.

## Fuera de alcance y backlog

- crear, iniciar, pausar, cerrar, corregir o anular OT/mangas;
- recibir en Almacén o resolver Calidad;
- reemplazar Jornadas de Planta;
- OEE, capacidad finita, promesa automática o pronóstico;
- tendencias avanzadas, comparación predictiva o detección estadística;
- exportar CSV/Excel/PDF;
- vistas guardadas, favoritos o suscripciones;
- unir el snapshot `LOCAL_REPORTED_LEGACY` con hechos SCM normalizados;
- persistir un nuevo estado “global” de producción.

## Definiciones

| Término | Significado en N4 |
|---|---|
| Unidad efectiva | Cantidad productiva vigente confirmada para la OT; una corrección reemplaza/compensa y una anulación resta. |
| Kg estándar | Cantidad efectiva por peso técnico congelado de la salida atribuible; no proviene de balanza. |
| Kg físico | Neto vigente medido por balanza en mangas; puede incluir componentes producidos antes. |
| Estado documental | Ciclo de vida del documento OT/OF/OA. |
| Estado operativo | Ejecución de OT, Trabajo de color o manga. |
| Estado logístico | Pendiente de recepción, recibida, ubicada u otra condición logística de la manga. |
| Calidad | Condición independiente que decide disponibilidad; nunca se infiere del pesaje. |
| `as_of` | Momento UTC en que se calculó la respuesta de lectura. |
| Último evento | Última actividad de negocio conocida; no es por sí sola salud de sincronización. |

## Reglas e invariantes

1. Jornadas ejecuta; Supervisión consulta.
2. Cada OT aparece una vez en la lista. Sus N Trabajos de color viven en el
   resumen y detalle, no como filas OT duplicadas.
3. Fabricación y Armado comparten filtros y estructura visual, pero conservan
   fórmulas y rótulos propios.
4. Avance provisional y cantidad confirmada nunca se suman como dos
   producciones.
5. Una corrección o anulación conserva el hecho original, pero el total
   efectivo usa el efecto vigente una sola vez.
6. Kg físico y kg estándar se muestran separados y con unidad/fuente.
7. Pesaje no equivale a recepción; recepción no equivale a liberación de
   Calidad; liberación no equivale a consumo.
8. Un `null` por ausencia, dato incompleto o permiso no se muestra como cero.
9. `OT_VER` habilita el núcleo. Cada enriquecimiento sensible requiere su
    capacidad específica y la API conserva la misma regla.
   Pesaje usa `MANGA_PESAJE_VER`, alertas `ALERTA_VER`, recepción/Almacén
   `RECEPCION_MANGA_VER` y Calidad `CALIDAD_MANGA_VER`; las dos últimas se
   degradan independientemente.
10. Filtrar por una dimensión sin permiso devuelve `403`; no entrega cero
    coincidencias que confirme indirectamente su existencia.
    `pendientes_pesaje` es una excepción explícita: representa estado operativo
    de manga visible con `OT_VER`, no lectura ni kg físicos.
11. Repetir una consulta no modifica versiones ni crea eventos de dominio.
12. El cursor solo continúa el filtro y snapshot con que fue emitido. Conserva
    `as_of`, última clave y huella de filtros; no expira por tiempo en v1.
13. La recencia describe antigüedad de la respuesta, no actividad de la OT.
14. Datos legacy permanecen en una superficie rotulada y nunca se suman al
    read model normalizado.
15. `desde > hasta`, `limit < 1`, `limit > 100`, cursor malformado o de versión
    desconocida se rechazan; un cursor con filtros distintos produce conflicto.

## Dataset ATDD canónico

Para el `2026-08-10`, turno `DIA`:

- `OT-000101`, Fabricación, máquina `MAQ-01`, dos Trabajos de color:
  Carne completado con 600 unidades efectivas y Azul en ejecución con 200;
  total OT 800 unidades y 64.000 kg estándar.
- La misma OT posee dos mangas válidas por 62.500 kg físicos, una lectura
  corregida de 31.000 a 30.500 kg y una manga anulada de 10.000 kg que no suma.
- `OT-000102`, Armado, centro `MESA-01`, `OA-000020`, 300 unidades confirmadas,
  21.000 kg estándar y 22.100 kg físicos; una manga está pendiente de recepción.
- `OT-000103`, Armado, tiene una manga recibida, Calidad `BLOQUEADA` y saldo no
  disponible.
- `OT-LEGACY-7` existe en la marcha blanca y no entra en los totales N4.

En agosto existen 22 días con OT para probar resumen mensual. El total mensual
se obtiene de hechos vigentes, no de sumar snapshots diarios ya acumulados.

## Escenarios ATDD/BDD

### N4-01 — Lista diaria completa y sin duplicar OT

**Dado** el dataset diario con tres OT y una OT de Fabricación multicolor \
**Cuando** se consulta Supervisión para fecha `2026-08-10`, turno `DIA` \
**Entonces** aparecen exactamente `OT-000101`, `OT-000102` y `OT-000103`, una
vez cada una, y `OT-LEGACY-7` permanece fuera.

### N4-02 — Jornadas y Supervisión conservan fronteras

**Dado** una persona con capacidades operativas \
**Cuando** abre Supervisión y el detalle de `OT-000101` \
**Entonces** no encuentra comandos de crear/iniciar/cerrar/corregir y puede
seguir un enlace a Jornadas sin que Supervisión duplique el formulario.

### N4-03 — Fabricación multicolor agrega hechos, no filas

**Dado** `OT-000101` con 600 unidades Carne y 200 Azul vigentes \
**Cuando** se consulta la fila y el detalle \
**Entonces** la fila informa 800 unidades efectivas, el detalle separa ambos
trabajos y el color actual es Azul sin ocultar Carne.

### N4-04 — Armado usa confirmaciones de salida

**Dado** `OT-000102` con avances provisionales y 300 unidades confirmadas \
**Cuando** se consulta su avance \
**Entonces** muestra 300 unidades efectivas; no suma nuevamente los avances
provisionales conciliados.

### N4-05 — Kg físico y estándar permanecen separados

**Dado** `OT-000101` con 64.000 kg estándar y 62.500 kg físicos vigentes \
**Cuando** se consulta la métrica \
**Entonces** se muestran ambos valores, fuentes y diferencia descriptiva; uno
no sustituye al otro.

### N4-06 — Corrección y anulación no duplican

**Dado** una lectura corregida y una manga anulada \
**Cuando** se recalcula el read model \
**Entonces** solo suma la lectura vigente y excluye el efecto anulado,
conservando enlaces auditables en el detalle.

### N4-07 — Recepción, inventario y Calidad son independientes

**Dado** una manga pesada pendiente de recepción y otra recibida/bloqueada \
**Cuando** se consulta logística \
**Entonces** la primera no aparece como inventario y la segunda aparece
recibida pero no disponible.

### N4-08 — Permiso base con enriquecimiento parcial

**Dado** un actor con `OT_VER` y sin permisos de pesaje, alertas, inventario ni
Calidad \
**Cuando** consulta lista y detalle \
**Entonces** ve el núcleo operativo, `visibilidad` declara las dimensiones
ocultas y los campos sensibles quedan omitidos o `null`, nunca en cero.

### N4-09 — Filtro sensible no crea side channel

**Dado** un actor con `OT_VER`, sin `ALERTA_VER` ni `RECEPCION_MANGA_VER` \
**Cuando** filtra `alertas=true` o `pendientes_almacen=true` \
**Entonces** recibe `403` y la pantalla explica falta de permiso sin revelar
cuántas OT coinciden. En cambio puede filtrar `pendientes_pesaje=true` porque
solo consulta el estado operativo, sin recibir lecturas ni kg físicos.

### N4-10 — Cursor estable

**Dado** 65 OT, límite 25 y filtros definidos \
**Cuando** recorre tres páginas usando `next_cursor` \
**Entonces** ve las 65 identidades una sola vez. Reusar el cursor con otro
filtro se rechaza y no reinicia silenciosamente desde la primera página. Las
tres páginas conservan el mismo `as_of`; un cursor malformado o un límite fuera
de 1…100 también se rechazan explícitamente.

### N4-11 — Resumen diario y mensual consistente

**Dado** el período agosto 2026 \
**Cuando** consulta `granularidad=MES` y luego el detalle diario de agosto \
**Entonces** universo, unidades y kg por métrica concilian bajo los mismos
filtros, sin sumar valores físicos y estándar entre sí.

### N4-12 — Recencia, pausa y recuperación

**Dado** actualización automática activa \
**Cuando** transcurren 30 segundos \
**Entonces** se renueva `as_of`; al pausar no se consulta y la antigüedad queda
visible. Al reanudar se solicita una nueva respuesta sin perder filtros.

### N4-13 — Datos incompletos y SLA

**Dado** una OT histórica normalizada sin responsable o sin peso técnico \
**Cuando** aparece en una respuesta y se observa su latencia sin asumir un SLA
numérico todavía no aprobado \
**Entonces** permanece visible, declara los campos faltantes y no calcula cero
o porcentaje engañoso. Una demora muestra estado de carga sin borrar la última
respuesta válida.

### N4-14 — Responsive y accesibilidad

**Dado** anchos 390, 768 y 1440 px, teclado y lector de pantalla \
**Cuando** se filtra, pagina y abre detalle \
**Entonces** no hay desborde global, tabla cambia a tarjetas en móvil, el foco
entra y retorna de forma predecible y estados/valores no dependen solo del color.

### N4-15 — Fuente legacy separada

**Dado** snapshots `LOCAL_REPORTED_LEGACY` y hechos SCM de la misma fecha \
**Cuando** se abre Supervisión \
**Entonces** solo se muestran hechos SCM. El acceso legacy conserva su rótulo y
no se ofrece una suma combinada.

## Definición de preparada

- [x] ID N4 auditado y libre dentro de la épica N.
- [x] Frontera Jornadas/Supervisión aprobada.
- [x] Ruta, feature key y capacidad base congeladas.
- [x] Lista, detalle, resumen, filtros, cursor y freshness definidos.
- [x] Autoridad de unidades, kg, inventario y Calidad diferenciada.
- [x] Permisos parciales y rechazo de filtros sensibles definidos.
- [x] P0, P1 y backlog delimitados.
- [x] Dataset diario/mensual y escenarios automatizables disponibles.
- [x] Tech Spec disponible.

## Incremento N4.1 - encontrar y supervisar mangas

**Como** supervisor de Produccion o Almacen,
**quiero** buscar una manga por codigo, articulo o color desde Control,
**para** conocer su estado y abrir su trazabilidad sin recorrer formularios de
creacion ni confundir la consulta con Recepcion o Kardex.

Criterios de aceptacion aditivos:

1. `Mangas` aparece como tercera perspectiva de la misma vista N4.
2. Lista mangas de Fabricacion y Armado en cualquier estado del ciclo de vida.
3. La omnibusqueda y los filtros de codigo, articulo, color y estado se envian
   al servidor; no filtran solamente la pagina visible.
4. La fila muestra manga, articulo, color, OT/origen, recurso, responsable,
   cantidades, peso fisico, kg estandar, etiqueta y estado logistico permitido.
5. `Ver trazabilidad` abre el detalle de la OT padre sin ejecutar comandos.
6. La paginacion usa cursor y `as_of`; cambiar de perspectiva invalida el cursor.
7. La UI movil usa tarjetas y la de escritorio una tabla densa accesible.
8. No se agrega recepcion manual, movimiento Kardex ni mutacion de inventario.
9. Estado de entrega: implementado local, UAT y despliegue Render pendientes.

## Incremento N4.2 - separar operacion e impresion

Como supervisor o responsable de planta quiero entrar por **OTs de planta**,
abrir una OT concreta sin recorrer formularios generales y consultar en Control
la salida de etiquetas, para distinguir claramente preparar, ejecutar y observar.

Criterios:

1. La entrada lista recursos del turno y permite preparar OT; una OT existente
   abre el detalle separado conservando fecha, turno y OT.
2. El detalle contiene cola de Trabajos de color, asignaciones y mangas; no
   repite el tablero general.
3. Control muestra trabajos de impresion por estado y tipo, permite buscar por
   manga o etiqueta y no ofrece comandos de impresion central.
4. Abrir una preetiqueta lleva al modulo de pesaje; no cambia su estado.
5. La ruta historica sigue resolviendo durante la transicion.