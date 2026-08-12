---
tipo: tech-spec
estado: implementada-local-pendiente-uat
tags: [scm, frontend, backend, ux, jornadas, fechas, tdd]
relaciones:
  - "[[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes]]"
  - "[[2026-08-09_Jornadas_de_Planta_y_Fechas_Proyectadas_de_OF_OA]]"
  - "[[DEV-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]]"
  - "[[Vista_US-010N3_Jornadas_de_Planta]]"
  - "[[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[TS-010F_Armado_Genealogia_Mangas_PT_y_Cierre_Armado]]"
fecha_creacion: 2026-08-09
fecha_actualizacion: 2026-08-09
---

# TS-010N3: Jornadas de Planta y fechas proyectadas

## 1. Objetivo técnico

Construir una proyección temporal de OF/OA y una vista diaria unificada de
Planta reutilizando los agregados existentes. No añadir fechas editables a las
órdenes técnicas ni convertir el tablero en otra autoridad de ejecución.

## 2. Semántica y fuentes

| Dato visible | Fuente autoritativa |
|---|---|
| Necesidad mínima/máxima | `OrdenProduccionLinea.fecha_necesidad` o cabecera OP heredada, atravesando `AsignacionDemandaSuministro` |
| Primera/última jornada | `RegistroDiarioProduccion.fecha` de las OT relacionadas |
| Fecha productiva de una jornada | `RegistroDiarioProduccion.fecha` (`fecha_operativa` en API) |
| Creada/liberada/iniciada/cerrada | timestamps UTC del ciclo de vida; solo auditoría |

La proyección nunca usa `created_at` como fecha de necesidad. Para una orden sin
asignaciones OP devuelve necesidad `null` con motivo semántico
`SIN_DEMANDA_FECHADA`. Para una orden sin OT devuelve rango de ejecución `null`
y `programacion_estado=SIN_JORNADA`.

## 3. Contrato temporal aditivo

Los DTO de detalle/lista de OF y OA añaden:

```json
{
  "contexto_temporal": {
    "fecha_necesidad_min": "2026-08-12",
    "fecha_necesidad_max": "2026-08-15",
    "fecha_ot_primera": "2026-08-10",
    "fecha_ot_ultima": "2026-08-14",
    "programacion_estado": "PROGRAMADA",
    "cantidad_ot": 3
  }
}
```

Valores de `programacion_estado`: `SIN_JORNADA | PROGRAMADA | EN_EJECUCION |
CERRADA`. Es una proyección de lectura; no se persiste ni se acepta en POST,
PATCH o transiciones.

Resolución de OT:

- OF: `ScmTrabajoOt.orden_operacion_id` → OT padre. No usar la FK legacy de la
  cabecera como autoridad para OT normalizadas.
- OA: `RegistroDiarioProduccion.orden_operacion_id` con `tipo_ot=ENSAMBLE`.
- Migradas: conservar el adaptador explícito sin fusionar ni adivinar fechas.

## 4. Consulta de Jornadas de Planta

La capa UI compone por la misma `fecha_operativa` y `turno`:

- máquinas activas + `GET /api/scm/v1/ots?tipo_ot=FABRICACION`;
- centros activos de `PREARMADO`, `ENSAMBLE`, `ACABADO` o `EMPAQUE` +
  `GET /api/scm/v1/ots?tipo_ot=ENSAMBLE`.

Si el costo o el número de requests lo exige, se permite una fachada aditiva
`GET /api/scm/v1/jornadas-planta?fecha_operativa=&turno=`. La fachada solo
agrega los mismos DTO y no introduce tablas, estados ni comandos.

### Tarjeta de Fabricación

- máquina y OT;
- estado derivado de sus Trabajos de color;
- maquinista/asignación vigente;
- color, artículo y OF actuales;
- conteos del Trabajo de color actual;
- siguiente trabajo y alertas.

### Tarjeta de Armado

- centro de trabajo y OT;
- OA y artículo de salida;
- responsable;
- cuota confirmada/objetivo;
- mangas por estado;
- estado de abastecimiento;
- modalidad Mesa o Concurrente.

La relación visual es centro → `0..N` OT de Armado para el filtro. Si existen
varias OT en el mismo centro/fecha/turno, la tarjeta muestra el número, la OT en
ejecución cuando exista y una lista explícita para seleccionar las demás. No
colapsa sus cuotas, OA, mangas o estados como si fueran una sola ejecución.

Todos los recursos activos aparecen aunque no tengan OT. Un recurso inactivo
solo aparece cuando conserva una OT histórica en el filtro y nunca ofrece crear
otra jornada.

## 5. Navegación y edición contextual

`/produccion/ots-mangas` evoluciona a **Jornadas de Planta** y conserva dos
modos accesibles por tabs internas o selector segmentado:

- `modo=fabricacion` por defecto;
- `modo=armado`.

La selección se expresa en query string mediante `fecha`, `turno`, `modo` y
`ot`. Abrir una tarjeta conserva filtros y muestra/dirige al editor existente:

- Fabricación: detalle de OT y cola de Trabajo de color;
- Armado: `/produccion/ordenes-armado?oa={id}&ot={public_id}`.

La URL de Armado sigue siendo canónica para el agregado OA. El tablero no
duplica liberar OA, abastecer, cerrar manga o corregir genealogía.

## 6. Armado concurrente por Trabajo de color

El formulario envía `trabajo_color_contexto_id`. El backend:

1. carga el Trabajo de color exacto;
2. valida que pertenece a una OT de Fabricación activa;
3. valida misma fecha operativa que la OT de Armado;
4. valida estado `PLANIFICADO`, `EN_EJECUCION` o `PAUSADO`;
5. deriva y conserva `ot_fabricacion_contexto_id`;
6. rechaza una OT con varios trabajos si falta el ID exacto.

El selector muestra `color_identidad.nombre`, artículo, OF, OT y máquina. Los
códigos de corrida quedan en detalle técnico, no como rótulo principal.

## 7. Capacidades

- `OT_VER`: consultar jornadas y detalle permitido.
- `OT_CREAR`: preparar una OT desde tarjeta sin jornada.
- `OT_INICIAR` / `OT_CERRAR`: comandos de Fabricación existentes.
- `OA_VER`: abrir contexto de Armado.
- `OA_EJECUTAR`, `ENSAMBLE_PLANIFICAR` y capacidades de abastecimiento:
  acciones especializadas existentes.

El frontend no interpreta nombres de rol. La ausencia de un comando no
sustituye la autorización server-side.

## 8. Estados UX y accesibilidad

- skeleton de tarjetas durante carga;
- vacío por recurso sin OT;
- error parcial distingue catálogo de recursos y jornadas;
- estado seleccionado inequívoco y foco al encabezado del detalle;
- `aria-current` solo en el modo activo;
- 390, 768 y 1440 px sin scroll horizontal global;
- tarjetas apiladas en móvil y cuadrícula en escritorio.

## 9. Mapa ATDD → pruebas

| Escenario | Evidencia automática |
|---|---|
| N3-01 | servicio/contrato: rango de necesidad y rechazo de fecha en escritura |
| N3-02 | servicio: rango de OT y estado sin jornada |
| N3-03 | UI: máquina con/sin OT y métricas del trabajo actual |
| N3-04 | UI: centro con/sin OT y datos exclusivos de Armado |
| N3-05 | routing/UI: filtros y selección preservados; sin comando duplicado |
| N3-06 | integración/UI: selección exacta y rechazo ambiguo |
| N3-07 | capacidades UI + regresión API |
| N3-08 | UI responsive y accesibilidad |

Primera prueba RED: una OA con tres OT devuelve primera/última fecha, y una OF
con dos líneas de demanda devuelve mínimo/máximo sin aceptar fecha editable.

## 10. Archivos previstos

- servicio de proyección de órdenes técnicas;
- serializadores OF/OA;
- contratos/API de OT y Armado concurrente;
- `workspaceRegistry.js` y sidebar;
- `OtMangasScm.jsx` o un contenedor `PlantJourneysScm.jsx`;
- `AssemblyOrdersScm.jsx` para selección contextual exacta;
- pruebas de servicio, contrato, componentes, routing y responsive;
- guía visible y vault.

## 11. Restricciones

- no añadir `fecha_inicio`, `fecha_fin` o `fecha_necesidad` editable a OF/OA;
- no persistir `contexto_temporal`;
- no fusionar OT legacy;
- no presentar una OT de Armado como Trabajo de color;
- no permitir que una OT de Armado mezcle OA;
- no reimplementar acciones de OA dentro del tablero;
- no declarar planificación finita.

## 12. Definition of Done

- [x] N3-01…N3-08 verdes en evidencia automática focal.
- [x] OF/OA muestran necesidad y rango OT derivados.
- [x] Escrituras de OF/OA no aceptan fecha productiva duplicada.
- [x] Jornadas muestra Fabricación por máquina y Armado por centro.
- [x] Recursos activos sin OT permanecen visibles.
- [x] Edición contextual conserva filtros e identidad.
- [x] Armado concurrente exige Trabajo de color exacto.
- [x] Cardinalidad de Fabricación y Armado cubierta por pruebas.
- [x] Suite focal, lint y build verdes.
- [ ] Smoke local responsive completado.
- [ ] UAT humana permanece pendiente hasta ejecución real.

## 13. Evidencia automática local — 2026-08-09

- backend focal N3 y regresión de planificación/OT/Armado: **43 aprobadas**;
- frontend focal de Jornadas, OF/OA, permisos, guía y fecha Lima:
  **69 aprobadas**;
- lint frontend: **0 errores** y una advertencia preexistente fuera del corte;
- build Vite productivo: correcto;
- auditoría ADR/US/TS/Vista/UAT: sin divergencias P0/P1.

Esta evidencia confirma implementación local; no sustituye el smoke visual ni
aprueba casos humanos de UAT.
