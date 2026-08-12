---
tipo: vista_frontend
estado: implementada-local-pendiente-uat
ruta: /control/supervision-produccion
feature_key: control.productionSupervision
tags: [frontend, scm, control, supervision, responsive, accesibilidad]
relaciones:
  - "[[US-010N4_Supervision_de_Produccion_Read_Model_Operativo]]"
  - "[[TS-010N4_Supervision_de_Produccion]]"
  - "[[2026-08-10_Supervision_de_Produccion_como_Read_Model_de_Control]]"
  - "[[Vista_US-010N3_Jornadas_de_Planta]]"
  - "[[Vista_US-011A_Dashboard_Avance_Pesajes]]"
  - "[[Guia_Operativa_SCM_US-010]]"
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
---

# Vista US-010N4: Supervisión de producción

## Propósito

Permitir que una jefatura consulte el estado transversal de OT de Fabricación
y Armado sin abrir una por una y sin convertir Control en otra superficie de
ejecución.

## Ubicación

- área: **Control**;
- primer item: **Supervisión de producción**;
- feature: `control.productionSupervision`;
- ruta canónica: `/control/supervision-produccion`;
- capacidad base: `OT_VER`;
- alias `/produccion/supervision` solo redirige.

La vista no aparece sin `OT_VER`. Las columnas y filtros sensibles se adaptan
por separado a `MANGA_PESAJE_VER`, `ALERTA_VER`, `RECEPCION_MANGA_VER` y
`CALIDAD_MANGA_VER`; ver recepción no concede Calidad ni viceversa.

## Arquitectura de información

```text
Supervisión de producción                         Actualizado 10:21:00 [Pausar]
Lectura de Control · No modifica la ejecución                         [Actualizar]

[Hoy] [Desde ▾] [Hasta ▾] [Turno ▾] [Fabricación y Armado ▾]
[Etapa ▾] [Recurso ▾] [Responsable ▾] [Buscar OP/OF/OA/OT/color...]
[+ Filtros] [Limpiar]

┌ OT 3 ┐ ┌ Objetivo 2,000 un ┐ ┌ Confirmado 1,100 un ┐
┌ Pend. pesaje 1 ┐ ┌ Pend. recepción 1 ┐ ┌ Recibidas 2 ┐
┌ Kg físico 84.600 ┐ ┌ Kg estándar 85.000 ┐

OT         Proceso       Recurso       Etapa                 Unidades
OT-000101 Fabricación   MAQ-01        En ejecución          800 / 1,000
           Carne completado · Azul actual
           Kg físico 62.500 · Kg estándar 64.000        [Ver detalle]

OT-000102 Armado        MESA-01       Pendiente recepción   300 / 500
           OA-000020 · 1 manga pendiente                 [Ver detalle]

[Cargar más]
```

El resumen nunca muestra una tarjeta “kg producidos” que mezcle físico y
estándar. Una métrica no autorizada se oculta y no deja una tarjeta cero.

## Diferencia respecto de Jornadas

| Jornadas de Planta | Supervisión de producción |
|---|---|
| Organiza un día/turno por máquina o centro | Busca OT entre tipos, recursos y períodos |
| Muestra también recursos sin OT | Lista únicamente OT existentes |
| Prepara/abre ejecución autorizada | Solo consulta y enlaza |
| Prioriza cola y formulario operativo | Prioriza etapa, bloqueos, métricas y trazabilidad |
| Fuente para actuar | Read model para decidir dónde revisar |

**Abrir en Jornadas** conserva fecha/turno/OT y se muestra solo cuando la ruta
es visible. No replica botones de iniciar, cerrar, corregir o anular.

## Filtros

### Barra rápida

- preset Hoy;
- desde/hasta;
- turno;
- Fabricación/Armado;
- etapa actual;
- búsqueda por identidades autorizadas.

### Panel avanzado

- estado documental y operativo;
- recurso y responsable;
- OP, OF, OA, OT y color;
- con/pendiente de pesaje, pendiente de recepción, con alertas, atrasadas o
  riesgo cuando el actor puede consultar la dimensión.

Aplicar un filtro reinicia el cursor. **Limpiar** vuelve al día local y ambos
tipos. Un filtro sensible rechazado por API conserva la selección anterior y
explica el permiso; no lo traduce a lista vacía.

## Lista y tarjetas

Una fila/tarjeta representa una OT. Para Fabricación multicolor:

- rótulo principal: OT y máquina;
- muestra Trabajo de color actual y siguiente;
- resume cantidad de trabajos sin duplicar la OT;
- el detalle conserva trabajos completados, pausados y anulados.

Para Armado:

- rótulo principal: OT, centro y OA;
- usa cantidades confirmadas por cierre;
- no muestra avances provisionales como producción adicional;
- no adopta color como identidad de la OT de Armado.

Columnas esenciales: OT, proceso/documento superior, recurso, responsable,
etapa, unidades, mangas, actividad y riesgo. Kg, recepción/Calidad y alertas son
enriquecimientos progresivos.

## Detalle de solo lectura

Se abre en drawer en escritorio y pantalla completa en móvil:

1. identidad y estados documental/operativo;
2. recurso, responsable, fecha y turno;
3. OF/corrida o OA según proceso;
4. Trabajos de color o contexto de Armado;
5. mangas con estado operativo y logístico;
6. etiqueta y pesaje cuando son visibles;
7. recepción, inventario y Calidad cuando son visibles;
8. bloqueos, riesgo, alertas y última actividad.

Los valores ausentes usan **No informado** o **Por asignar**. No existe un badge
“Todo bien” derivado de que alertas estén ocultas.

## Estados y copy

| Estado | Mensaje/acción |
|---|---|
| carga inicial | skeleton de resumen y filas; filtros visibles |
| vacío | “No hay OT para este período y filtros.” + Limpiar filtros |
| error total | explicación y Reintentar; no muestra ceros |
| error de resumen | lista visible + “No se pudo actualizar el resumen” |
| refresh fallido | conserva datos + “La última actualización no pudo completarse” |
| pausado | “Actualización automática pausada” + Reanudar |
| campo nulo | No informado / Por asignar |
| dimensión oculta | no renderiza métrica; explicación de visibilidad en detalle |
| sin siguiente cursor | no renderiza Cargar más |

Encabezado permanente: **Lectura de Control. Para ejecutar o corregir, abra la
jornada o documento autoritativo.**

## Freshness

- auto-refresh cada 30 s cuando la pestaña está visible;
- botón Actualizar y control Pausar/Reanudar;
- timestamp accesible **Actualizado a…** desde `as_of`;
- la hora de último evento se rotula **Última actividad**, no **Última
  sincronización**;
- si el refresh falla, `as_of` anterior continúa visible para evitar falsa
  actualidad;
- N4 no promete “tiempo real” ni inventa un SLA de entrega de eventos.

## Responsive y accesibilidad

| Ancho | Presentación |
|---|---|
| ≥1200 | tabla, resumen horizontal y drawer lateral |
| 768–1199 | tabla compacta o dos columnas de tarjetas según ancho real |
| <768 | tarjetas una columna, filtros en bottom sheet y detalle full-screen |

- sin scroll horizontal global en 390/768/1440;
- orden de foco: encabezado → filtros → resumen → resultados → paginación;
- el drawer recibe foco en su título y lo devuelve al disparador;
- iconos y colores siempre tienen texto;
- actualización automática no roba foco ni anuncia toda la tabla;
- conteo de resultados y errores usan anuncio cortés;
- targets táctiles mínimos y filtros utilizables sin hover.

## Paginación

El cliente conserva `next_cursor` y agrega resultados con **Cargar más**. No
calcula `offset`, número total o páginas si la API no los entrega. Cambiar un
filtro descarta items y cursor previos. Un cursor inválido produce error de
filtro, nunca un reinicio silencioso. La carga inicial pide 25 resultados; el
contrato admite de 1 a 100. Cada página conserva el `as_of` fijado por el cursor.
Un conflicto cursor/filtros solicita aplicar la consulta desde el inicio sin
mezclar las filas ya visibles con otro universo.

## Legacy y backlog

`/produccion/avance` y [[Vista_US-011A_Dashboard_Avance_Pesajes]] continúan
rotulados como fuente legacy/local. No se ofrecen tabs para sumarlos a N4.

Fuera de la vista aprobada: tendencias avanzadas, exportación, vistas
guardadas, suscripciones y pronóstico. Una serie diaria/mensual del resumen no
convierte la vista en analítica avanzada.

## Estado de disponibilidad

Implementada localmente con focales, suite frontend completa, lint y build
verdes. El smoke desktop local verificó Fabricación, Armado, filtros, modo
Recursos y drawer jerárquico contra datos mock. Esto no marca la ruta como
desplegada ni la UAT como aprobada; el smoke visual 390/768/1440 permanece pendiente. Ver
[[UAT_TS-010N4_Supervision_de_Produccion]].

## N4.1 - perspectiva Mangas

El selector de modo ofrece:

1. **Lista de OT:** seguimiento documental y operativo por orden diaria.
2. **Recursos del turno:** lectura agrupada por maquina o centro.
3. **Mangas:** indice global de unidades logisticas, incluyendo planificadas,
   preetiquetadas, abiertas, cerradas, pesadas, pendientes de recepcion,
   recibidas y anuladas.

En Mangas, la barra principal cambia su ayuda a `Buscar codigo de manga,
articulo, color, OT, OP u OF/OA`. Los filtros avanzados agregan estado, codigo
de manga y articulo. La tabla desktop muestra identidad/estado, articulo/color,
OT/origen, recurso/responsable, cantidad/pesos, etiqueta/almacen y consulta. En
viewport menor a `lg` se presentan tarjetas con las mismas decisiones.

`Ver trazabilidad` abre el drawer de la OT padre. `Abrir jornada` es un enlace
contextual, no una mutacion. La Recepcion sigue en Almacen y el Kardex sigue
siendo el registro de movimientos: esta perspectiva no los reemplaza.

### Disponibilidad

Implementada solamente en la sesion local. No esta desplegada en Render. La
UAT, el smoke responsive y el smoke remoto permanecen pendientes.

## N4.2 - superficies hermanas

### Produccion / OTs de planta

1. Encabezado y filtros comunes de fecha/turno.
2. Perspectivas Fabricacion por maquina y Armado por centro.
3. Recurso sin OT: **Preparar OT**.
4. Recurso con OT: abre el espacio de trabajo de esa OT.
5. El espacio de trabajo muestra cola de colores, responsable y mangas, sin
   repetir tarjetas de todos los recursos.

### Control / Impresion y etiquetas

- tarjetas responsivas con manga, tipo, cantidad de etiquetas, estado, fecha y
  asignacion de estacion;
- filtros de estado y tipo, busqueda por manga/etiqueta;
- CTA **Abrir vista previa en estacion** solo para prepesaje pendiente;
- copy permanente: abrir no imprime y Control es solo lectura.