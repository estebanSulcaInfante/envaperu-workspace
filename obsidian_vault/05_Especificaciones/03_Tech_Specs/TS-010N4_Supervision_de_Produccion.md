---
tipo: tech-spec
estado: implementada-local-pendiente-uat
tags: [scm, control, supervision, observabilidad, read-model, frontend, backend, tdd]
relaciones:
  - "[[US-010N4_Supervision_de_Produccion_Read_Model_Operativo]]"
  - "[[2026-08-10_Supervision_de_Produccion_como_Read_Model_de_Control]]"
  - "[[DEV-010N4_Supervision_de_Produccion]]"
  - "[[Vista_US-010N4_Supervision_de_Produccion]]"
  - "[[UAT_TS-010N4_Supervision_de_Produccion]]"
  - "[[TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]]"
  - "[[US-011A_Dashboard_Gerencial_Avance_Pesajes]]"
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
---

# TS-010N4: Supervisión de producción

## 1. Objetivo técnico

Entregar un read model normalizado de OT de Fabricación y Armado y una vista de
Control que lo consuma sin mutar agregados. El contrato debe separar estados,
unidades efectivas, kg físicos, kg estándar, recepción/Calidad y alertas, con
degradación explícita por capacidades.

## 2. Fronteras obligatorias

| Superficie | Responsabilidad | Escrituras |
|---|---|---|
| `/produccion/ots-planta` | OTs operativas por recurso/fecha/turno; preparar y abrir ejecución | Contratos existentes según capacidades |
| `/control/supervision-produccion` | Buscar, resumir y explicar OT entre procesos/períodos | Ninguna |
| `/produccion/avance` y dashboard de estación | Continuidad/avance legacy rotulado | No alimenta el read model N4 |

El feature del workspace es `control.productionSupervision`, primero dentro de
Control. `/produccion/supervision` puede redirigir a la ruta canónica, pero no
renderiza otra vista.

## 3. Autorización progresiva

No se crea una capacidad nueva.

| Capacidad | Proyección permitida |
|---|---|
| `OT_VER` | Núcleo de OT, recurso, responsable, trabajos, etapa y conteos logísticos agregados por estado de manga. |
| `MANGA_PESAJE_VER` | `pesaje_resumen`, kg físico/estándar y detalle de pesaje. |
| `ALERTA_VER` | `alertas_resumen`, severidad/riesgo y detalle de alertas. |
| `RECEPCION_MANGA_VER` | Detalle de recepción y Almacén de las mangas. |
| `CALIDAD_MANGA_VER` | Decisión y detalle de Calidad de las mangas, aun si recepción no es visible. |

`visibilidad` siempre informa `{pesaje, alertas, almacen, calidad}`. Cuando
falta capacidad, el bloque sensible correspondiente es `null`/omitido; no se
devuelve un objeto con ceros. Un filtro sensible sin capacidad devuelve `403`.
La autorización server-side es obligatoria aunque el frontend oculte el filtro.
`pendientes_pesaje` pertenece al estado operativo de manga visible con
`OT_VER`; no habilita ni filtra lecturas o kg físicos.

## 4. API canónica

```http
GET /api/scm/v1/observabilidad/ots
GET /api/scm/v1/observabilidad/ots/{public_id}
GET /api/scm/v1/observabilidad/resumen?granularidad=DIA|MES
```

Los clientes del frontend usan el prefijo axios vigente `/scm/v1/...`. Las
respuestas mantienen `Cache-Control: private, no-store` y `as_of` ISO-8601 UTC.

### 4.1. Filtros comunes

| Dimensión | Parámetro |
|---|---|
| Período inclusivo | `fecha_desde`, `fecha_hasta` (`AAAA-MM-DD`; `desde`/`hasta` son aliases compatibles) |
| Tipo de OT | `tipo_ot=FABRICACION|ARMADO` (la implementación normaliza el alias interno `ENSAMBLE`) |
| Turno | `turno` |
| Estados | `estado_documental`, `estado_operativo`; etapas rápidas mediante `quick` |
| Recurso/persona | `recurso`, `responsable` (`*_id` son aliases compatibles) |
| Identidades | `op`, `orden` (OF/OA), `ot` y `color` |
| Búsqueda | `q` sobre códigos/nombres autorizados |
| Atajos | `quick=EN_EJECUCION|PAUSADAS|PENDIENTES_PESAJE|ATRASADAS` |
| Excepciones | `pendientes_pesaje` con `OT_VER`; `pendientes_almacen` con `RECEPCION_MANGA_VER`; `alertas` con `ALERTA_VER` |
| Orden | `sort=FECHA_DESC|FECHA_ASC` |
| Paginación de lista | `cursor`, `limit` |

La UI inicializa y envía el día local de `America/Lima`; la API no inventa un
período cuando el cliente lo omite. No existe máximo de días en v1.
`fecha_desde > fecha_hasta` responde
`400 INVALID_OBSERVABILITY_DATE_RANGE`.
La lista usa `limit=25` por defecto y admite `1..100`; cualquier otro valor
responde `400 INVALID_OBSERVABILITY_LIMIT`. Fechas inválidas y enumeraciones
desconocidas también producen error de validación y no se corrigen
silenciosamente. El backend puede añadir filtros compatibles, pero no cambiar
el significado de estos.

### 4.2. Lista

```json
{
  "items": [{
    "ot": {
      "public_id": "uuid",
      "codigo": "OT-000101",
      "tipo": "FABRICACION",
      "fecha_operativa": "2026-08-10",
      "turno": "DIA",
      "estado_documental": "PLANIFICADA",
      "estado_operativo": "EN_EJECUCION"
    },
    "upstream": {},
    "recurso": {},
    "responsable": {},
    "trabajo_actual": {},
    "trabajo_siguiente": {},
    "trabajos_resumen": {},
    "cantidades_resumen": {
      "objetivo_un": 1000.0,
      "confirmado_un": 800.0
    },
    "mangas_resumen": {},
    "pesaje_resumen": {
      "peso_fisico_neto_kg": 62.5,
      "kg_produccion_estandar": 64.0
    },
    "almacen_resumen": {},
    "alertas_resumen": {},
    "visibilidad": {
      "pesaje": true,
      "alertas": true,
      "almacen": true,
      "calidad": true
    },
    "etapa_actual": "EN_EJECUCION",
    "bloqueos": [],
    "riesgo": {
      "atrasada": false,
      "horas_sin_actividad": 1.5,
      "severidad": null
    },
    "ultimo_evento_at": "2026-08-10T15:20:00Z"
  }],
  "page": {
    "next_cursor": "opaque-or-null",
    "limit": 25,
    "has_more": false
  },
  "as_of": "2026-08-10T15:21:00Z"
}
```

Los objetos anidados pueden enriquecerse aditivamente. Los nombres y
significados anteriores no se reutilizan. `pesaje_resumen` y
`alertas_resumen` son `null` sin capacidad; `riesgo.severidad` también es
`null` sin `ALERTA_VER`.

La orden es estable por `(fecha_operativa, id)` en la dirección solicitada por
`sort`. `next_cursor` es opaco y versionado: fija `as_of`, última clave
`(fecha_operativa, id)` y huella de filtros. No expira temporalmente en v1. Un
cursor malformado o de versión desconocida responde
`400 INVALID_OBSERVABILITY_CURSOR`; reutilizarlo con filtros incompatibles
responde `409 OBSERVABILITY_CURSOR_FILTER_MISMATCH`. Cambiar filtros reinicia
explícitamente la consulta; el cliente nunca reutiliza ese cursor. Todas las
páginas del recorrido conservan el `as_of` del cursor y ninguna debe repetir u
ocultar una identidad.

### 4.3. Detalle

`GET .../ots/{public_id}` devuelve:

```json
{
  "item": {
    "ot": {},
    "upstream": {},
    "recurso": {},
    "responsable": {},
    "trabajos": [{
      "trabajo": {},
      "mangas": [{
        "manga": {
          "estado_operativo": "PESADA",
          "estado_logistico": "PENDIENTE_RECEPCION"
        },
        "etiqueta": {},
        "pesaje": {},
        "almacen": {}
      }]
    }],
    "visibilidad": {},
    "etapa_actual": "PENDIENTE_RECEPCION",
    "bloqueos": [],
    "riesgo": {},
    "ultimo_evento_at": "2026-08-10T15:20:00Z"
  },
  "as_of": "2026-08-10T15:21:00Z"
}
```

Toda relación faltante se representa con `null`, arreglo vacío o rótulo
estable según su tipo. El frontend muestra **No informado** o **Por asignar**;
no inventa `calidad_dato`, cero, estado ni porcentaje.

### 4.4. Resumen

```json
{
  "granularidad": "DIA",
  "periodo": {
    "fecha_desde": "2026-08-10",
    "fecha_hasta": "2026-08-10"
  },
  "totales": {
    "ots": 3,
    "objetivo_un": 2000.0,
    "confirmado_un": 1100.0,
    "mangas_total": 7,
    "mangas_pendientes_pesaje": 1,
    "mangas_pendientes_recepcion": 1,
    "mangas_recibidas": 2,
    "peso_fisico_neto_kg": 84.6,
    "kg_produccion_estandar": 85.0,
    "alertas_abiertas": 1,
    "por_estado_documental": {},
    "por_estado_operativo": {}
  },
  "series": [{"periodo": "2026-08-10"}],
  "as_of": "2026-08-10T15:21:00Z"
}
```

Cada elemento de `series` repite las métricas cuantitativas de `totales` para
su período; las distribuciones por estado permanecen en el total. En
`MES`, el período agrupa por mes calendario de `America/Lima`; no suma snapshots
acumulativos diarios. Si falta capacidad, las métricas sensibles son `null` y
`visibilidad`/autorización conservan la misma regla que lista/detalle.

## 5. Semántica de estados

`etapa_actual` admite:

```text
PLANIFICADA | EN_EJECUCION | PAUSADA | PENDIENTE_PESAJE |
PENDIENTE_RECEPCION | RECIBIDA | CERRADA | ANULADA
```

Es derivada para orientación. No sustituye:

- `ot.estado_documental` y `ot.estado_operativo`;
- estado operativo/logístico de manga;
- condición de recepción, inventario o Calidad;
- estado de OF/OA superior.

La UI presenta badges separados. Un rótulo general nunca convierte
`PENDIENTE_RECEPCION` en disponible ni una OT `CERRADA` en Calidad liberada.

## 6. Autoridad de métricas

| Métrica | Autoridad/regla |
|---|---|
| `confirmado_un` | Unidades efectivas vigentes acreditadas a la OT. Fabricación suma salidas confirmadas por sus Trabajos de color; Armado usa cierres confirmados. No suma provisional conciliado. |
| `kg_produccion_estandar` | Unidades efectivas × peso técnico congelado atribuible a la salida de la OT. Nunca usa la balanza como fallback. |
| `peso_fisico_neto_kg` | Neto efectivo de la última corrección aplicada por manga, excluyendo pesajes/mangas anulados. Nunca se atribuye íntegramente a Fabricación cuando contiene componentes previos. |
| conteos logísticos | Estados vigentes de manga/recepción; visibles agregados con `OT_VER`. |
| detalle Almacén | Recepción e inventario normalizados, visible con `RECEPCION_MANGA_VER`. |
| detalle Calidad | Decisión normalizada, visible independientemente con `CALIDAD_MANGA_VER`. |
| alertas/riesgo | Alertas reales visibles con `ALERTA_VER`; no se infiere severidad desde horas sin actividad. |

Correcciones y anulaciones se resuelven por efectos vigentes: el hecho original
continúa auditable, pero el resumen no suma original y compensación como dos
resultados.

## 7. Recencia y continuidad visual

- consulta automática cada 30 s mientras esté activa y no pausada;
- al ocultar la pestaña puede suspenderse; al volver solicita una actualización;
- **Actualizado a {hora}** procede de `as_of`, no del reloj cliente;
- `ultimo_evento_at` y `horas_sin_actividad` se muestran como actividad, no
  como SLA de sincronización;
- el piloto no promete “tiempo real” ni fija un SLA de entrega de eventos no
  aprobado. La UI declara la antigüedad y conserva la última respuesta si una
  actualización falla;
- durante el desarrollo se registra latencia de lista/detalle/resumen. Un SLA
  numérico requiere aprobación operativa posterior, no se inventa en N4.

## 8. UI

### Escritorio/tablet

- encabezado y resumen compacto;
- barra sticky de período, turno, tipo, etapa, búsqueda y filtros;
- tabla una fila/OT con columnas esenciales configuradas por permiso;
- panel lateral de detalle sin navegación destructiva;
- paginación **Cargar más** por cursor; no números de página falsos.

### Móvil

- tarjetas una por OT;
- identidad, etapa, recurso, unidades y próxima acción logística primero;
- filtros en drawer/bottom sheet con contador y botón limpiar;
- detalle full-screen con retorno de foco a la tarjeta.

### Accesibilidad

- nombre accesible de filtros y resumen;
- `aria-live=polite` para recencia/resultado, no para cada auto-refresh;
- foco al título del detalle y retorno al disparador;
- estados no dependen solo de color;
- 390, 768 y 1440 px sin scroll horizontal global;
- tabla semántica en escritorio y tarjetas con encabezados equivalentes en móvil.

## 9. Errores y estados

| Caso | Comportamiento |
|---|---|
| 401 | sesión no válida; flujo de autenticación existente |
| 403 base | no renderiza el feature ni datos de OT |
| 403 filtro sensible | conserva filtros previos y explica qué dimensión no está autorizada |
| 404 detalle | cierra/neutraliza el panel y ofrece actualizar lista |
| `400 INVALID_OBSERVABILITY_LIMIT` | marca límite inválido; no corrige ni recorta silenciosamente |
| `400 INVALID_OBSERVABILITY_DATE_RANGE` | marca rango invertido; conserva selección para corregirla |
| `400 INVALID_OBSERVABILITY_CURSOR` | invalida la continuación y ofrece reinicio explícito, nunca automático |
| `409 OBSERVABILITY_CURSOR_FILTER_MISMATCH` | descarta mezcla de universos y pide aplicar filtros desde el inicio |
| otro 400/422 de filtro | marca el filtro; no cae a “sin resultados” |
| error de resumen con lista válida | muestra lista y alerta parcial; no sustituye totales por cero |
| error de refresh | conserva snapshot previo, marca antigüedad y permite reintentar |
| campos `null` | **No informado**/**Por asignar**, nunca cero |
| lista vacía | explica período/filtros y permite limpiar |

## 10. Mapa ATDD → pruebas

| Escenario | Evidencia mínima |
|---|---|
| N4-01/N4-03 | integración de read model + UI lista única por OT multicolor |
| N4-02 | UI/routing sin comandos y enlace a Jornadas |
| N4-04 | servicio Armado: provisional vs confirmado |
| N4-05 | contrato/UI: kg físico y estándar separados |
| N4-06 | integración PostgreSQL: corrección/anulación efectiva |
| N4-07 | integración de recepción/inventario/Calidad |
| N4-08/N4-09 | autorización API + UI con matrices parciales y 403 |
| N4-10 | contrato/integración cursor, filtros y 65 identidades |
| N4-11 | servicio/contrato resumen DIA/MES |
| N4-12 | UI con timers controlados, pausa, visibilidad y refresh fallido |
| N4-13 | contrato/UI nulls, demora y última respuesta válida |
| N4-14 | componente/a11y + smoke 390/768/1440 |
| N4-15 | regresión: fuente legacy no entra en read model |

Primera prueba RED: una OT de Fabricación con dos Trabajos de color debe
aparecer una vez, sumar 800 unidades efectivas y mantener 62.500 kg físicos
separados de 64.000 kg estándar. Antes de N4 no existe ese contrato unificado.

## 11. Secuencia P0/P1

1. P0 contrato de lista/detalle, una fila por OT y semántica de métricas.
2. P0 permisos parciales y estados `null`/error/freshness.
3. P0 UI diaria/turno, tabla/tarjetas y detalle.
4. P1 filtros/rango y cursor estable.
5. P1 resumen `DIA|MES` y conciliación con lista.
6. P1 smoke responsive/a11y y regresión legacy.

P0 y P1 están incluidos en DEV-010N4. Tendencias avanzadas, exportación y
vistas guardadas no bloquean ni se implementan en esta secuencia.

## 12. Restricciones

- sin migración o tabla nueva salvo que una optimización aditiva demuestre ser
  necesaria y se apruebe por separado;
- sin endpoint de comando bajo `/observabilidad`;
- sin capacidad nueva;
- sin sumar datos legacy/normalizados;
- sin total “kg producidos” ambiguo;
- sin inferir Calidad, inventario o disponibilidad;
- sin reutilizar `as_of` como hora del último hecho productivo;
- sin exportar ni persistir filtros/vistas.

## 13. Definition of Done aprobable

- [x] N4-01…N4-15 verdes en los niveles acordados.
- [x] lista, detalle y resumen comparten universo/filtros/autorización.
- [x] Fabricación multicolor y Armado cubiertos con datos normalizados.
- [x] correcciones, anulaciones, recepción, inventario y Calidad concilian.
- [x] permisos parciales no filtran información por campos ni conteos.
- [x] cursor no duplica identidades.
- [x] recencia, nulls y error parcial son explícitos.
- [ ] 390/768/1440 y a11y automatizada/smoke pasan.
- [x] suite focal, regresión relevante, lint y build verdes.
- [x] guía y UAT actualizadas con evidencia real.
- [ ] UAT humana continúa pendiente hasta ejecución firmada.

## 14. Evidencia documental de entrada — 2026-08-10

- ID N4 auditado: no existía otra historia o Tech Spec con ese identificador;
- contratos backend/frontend coordinados: feature, ruta, capacidad y tres GET
  confirmados;
- shape de lista/detalle/resumen, `visibilidad`, `riesgo`, métricas y `as_of`
  congelados con los carriles técnicos;
- estado de implementación al crear esta TS: **en desarrollo**, todavía sin
  declarar suites automáticas ni UAT aprobadas.

Las adiciones compatibles que aterricen durante TDD se registran aquí y en
DEV/UAT; no pueden cambiar silenciosamente las invariantes funcionales.

## 15. Evidencia técnica de cierre local — 2026-08-10

| Carril | Comando/evidencia reproducible | Resultado |
|---|---|---|
| Backend focal | `.venv/Scripts/python.exe -m pytest -q tests/scm/test_scm_production_observability.py` desde `backend/` | 8/8 verdes |
| Backend completa | `.venv/Scripts/python.exe -m pytest -q` desde `backend/` | 351 passed, 1 skipped OCR, 21 deselected, 0 fallos |
| Frontend focal | `npm test -- --run src/tests/scmProductionObservabilityApi.spec.js src/tests/ProductionSupervisionScm.spec.jsx src/tests/workspaceRegistry.spec.js src/tests/WorkspaceFeatureRoute.spec.jsx src/tests/WorkspaceNavigationShell.spec.jsx src/tests/RoleHome.spec.jsx src/tests/ActorWorkspaceBar.spec.jsx src/tests/workspaceProjection.spec.js` desde `frontend/` | 8 archivos, 55/55 verdes |
| Frontend completa | `npm run test -- --run` desde `frontend/` | 57 archivos, 295/295 verdes |
| Calidad frontend | `npm run lint` y `npm run build` desde `frontend/` | verdes; build conserva únicamente warning no bloqueante de chunk mayor a 500 kB |

El backend focal incluye lista/detalle/resumen, permisos, cursor, Fabricación,
Armado, corrección/anulación, recepción y Calidad. La regresión además cubrió
un resumen de 103 OT sin truncarlo por la paginación de lista y mantuvo acotado
el número de consultas por página. No se ejecutó migración ni se modificó una
base remota. Esta evidencia automática habilita el estado local; no reemplaza
el smoke visual pendiente ni [[UAT_TS-010N4_Supervision_de_Produccion|UAT-N4]].

## 16. Addendum N4.1 - read model de mangas

### Contrato HTTP

`GET /api/scm/v1/observabilidad/mangas`

Reutiliza `fecha_desde`, `fecha_hasta`, `tipo_ot`, `turno`, `recurso`,
`responsable`, `op`, `orden`, `ot`, `color`, `q`, `quick`, `cursor` y `limit`.
Agrega filtros aditivos `manga`, `estado_manga` y `articulo`.

Respuesta:

```json
{
  "items": [{
    "manga": {}, "ot": {}, "recurso": {}, "upstream": {}, "trabajo": {},
    "visibilidad": {}, "alertas_resumen": {}, "ultimo_evento_at": null
  }],
  "page": {"next_cursor": null, "limit": 25, "has_more": false},
  "as_of": "2026-08-10T14:30:00Z"
}
```

La consulta pagina por `OT.fecha_operativa + Manga.id`, fija `as_of`, hidrata
por lote las OT seleccionadas y no ejecuta una consulta por manga. El articulo,
color, cantidad y empaque salen de los snapshots de la propia manga. El pesaje
efectivo respeta correcciones/anulaciones del read model N4.

### Contrato frontend

- `vista=MANGAS` es direccionable por URL.
- cambiar `vista` elimina el cursor anterior;
- desktop renderiza tabla y `<lg` tarjetas;
- `Ver trazabilidad` reutiliza `GET /observabilidad/ots/{public_id}`;
- los KPIs siguen resumiendo las OT del periodo y no se recalculan sumando filas
Regresion ampliada N4.1: 8 archivos y 57/57 pruebas frontend; lint y build
verdes. El build conserva el warning no bloqueante de chunk mayor a 500 kB.
Smoke visual, UAT y Render continuan pendientes.
  de mangas paginadas;
- el endpoint y la vista son read-only y no requieren migracion.

Evidencia N4.1: backend observabilidad 10/10; frontend componente+API 23/23.
La suite final, lint/build y UAT humana se registran al cerrar el incremento.

## 17. Addendum N4.2 - OTs de planta y cola de impresion

### Rutas UI

| Ruta | Responsabilidad |
|---|---|
| `/produccion/ots-planta` | Entrada por recurso, fecha y turno; alta de OT. |
| `/produccion/ots-planta/trabajo?fecha=&turno=&modo=fabricacion&ot=` | Trabajo de color, personas y mangas de una OT. |
| `/produccion/ots-mangas` | Alias temporal de compatibilidad. |
| `/control/impresion-etiquetas` | Observacion de la cola central. |

### Read model de impresion

`GET /api/scm/v1/observabilidad/trabajos-impresion`

Filtros: `status=PENDING|PARTIAL|PRINTED|FAILED|ALL`,
`tipo=PREPESAJE|POSTPESAJE|ALL`, `q` y `limit` de 1 a 100. Requiere `OT_VER`.
Devuelve `{items,count,as_of}`. Cada item conserva `print_job_id`, estado
normalizado, estacion asignada, fechas y etiquetas con codigo de manga.
El endpoint es estrictamente de lectura: no hace claim, ACK ni impresion.