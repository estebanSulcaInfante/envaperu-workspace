---
tipo: vista_frontend
estado: implementada-local-pendiente-uat
ruta: /produccion/ots-mangas
tags: [frontend, scm, piloto, ot, trabajo-color, mangas, relevos]
relaciones:
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[TS-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color]]"
  - "[[TS-010M3_Relevos_en_Trabajo_Color]]"
  - "[[Guia_Operativa_SCM_US-010]]"
  - "[[Vista_US-010N3_Jornadas_de_Planta]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-09
---

# Vista US-010M: OT y Trabajos de color

## Propósito

Presentar la jornada de cada máquina como una sola OT y una cola comprensible
de Trabajos de color, sin exponer al usuario la tabla física
`RegistroDiarioProduccion` ni pedir al maquinista que use esta pantalla.

Con N3, esta experiencia pasa a ser el modo **Fabricación por máquina** dentro
de **Jornadas de Planta**. Sus reglas de tarjeta, cola, mangas y estados no se
mezclan con Armado; el modo hermano proyecta las OT de Armado por centro y abre
su editor especializado.

## Actores

| Actor | Uso |
|---|---|
| Supervisor | Crea OT, agrega trabajos, inicia/pausa/reanuda, asigna mangas y releva. |
| Jefe de Producción | Mismas acciones, anulación y excepciones gobernadas. |
| Planificación | Consulta OT/cola y agrega colores de OF según capacidades. |
| Operador de Balanza | Consulta contexto; pesa desde la estación. |
| Maquinista | No usa la vista; recibe hoja y stickers QR. |

## Arquitectura de información

```text
[Fecha] [Turno] [Actualizar]                  13 máquinas · 8 produciendo

┌ Haitian 3000 ─ OT-000123 ─ EN EJECUCIÓN ┐ ┌ Sopladora 02 ─ SIN OT ┐
│ Actual: VERDE SÓLIDO · OF-000042          │ │ Jornada no programada │
│ Renato Peña · 4 cerradas · 1 con sticker │ │ [Crear OT]             │
│ Siguiente: AZUL SÓLIDO                    │ └────────────────────────┘
└───────────────────────────────────────────┘

[Máquina seleccionada: detalle de OT y cola]
1. VERDE SÓLIDO · OF-000042 · COMPLETADO
2. AZUL SÓLIDO  · OF-000042 · EN EJECUCIÓN
3. ROJO SÓLIDO  · OF-000057 · PLANIFICADO
```

La tarjeta representa la máquina en la fecha/turno, no cada color. Toda
máquina activa aparece aunque aún no posea OT. El click selecciona la jornada y
desplaza/expande su detalle sin crear ni modificar registros.

La tarjeta no deduce que una manga está abierta a partir de su preetiqueta.
`PREETIQUETADA` se muestra como **Con sticker**; **Abierta/En llenado** solo
aparece cuando exista un estado físico explícito definido por US-010K.
Tampoco deduce que una máquina está produciendo desde la cabecera OT:
**Produciendo** exige un Trabajo de color hijo `EN_EJECUCION`; un hijo
`PAUSADO` se rotula **Trabajo pausado**.
Los conteos de mangas pertenecen a ese mismo Trabajo de color; los colores
completados y siguientes no se suman en la tarjeta y se consultan en el detalle
de la OT.

`LISTO` y `BLOQUEADO` pueden mostrarse como condiciones derivadas, pero no se
presentan como estados persistidos equivalentes a
`PLANIFICADO/EN_EJECUCION/PAUSADO/COMPLETADO/ANULADO`.

## Comandos y contratos

| Acción UI | Contrato |
|---|---|
| Nueva OT de Fabricación | `POST /api/scm/v1/ots/fabricacion` |
| Consultar tablero | `GET /api/scm/v1/ots` con `trabajos_color[]` |
| Agregar Trabajo de color | `POST /api/scm/v1/ots/{ot_id}/trabajos-color` |
| Iniciar/pausar/reanudar/completar/anular | `POST /api/scm/v1/trabajos-color/{id}/{accion}` |
| Asignar/relevar y mangas seleccionadas | `POST /api/scm/v1/trabajos-color/{id}/asignaciones` |
| Crear mangas | `POST /api/scm/v1/trabajos-color/{id}/mangas` |
| Preetiqueta | `POST /api/scm/v1/mangas/{id}/etiquetas-prepesaje` |

La fachada legacy por OF puede coexistir, pero la UI nueva no crea una segunda
cabecera ni deriva el color directamente desde la OT.

## Lenguaje visible de color

`ScmCorridaFabricacion` continúa como identidad técnica interna que congela la
combinación homogénea de OF, color y receta. Planta no necesita conocer ese
nombre ni el sufijo `C01`:

- el formulario usa **Color a fabricar**;
- una sola opción aparece como resumen de solo lectura;
- varias opciones se eligen por `ColorProduccion.nombre`, artículo y OF;
- el texto explica “Definido por la PiezaColor demandada” cuando corresponda;
- “corrida” y `Cxx` quedan disponibles únicamente en detalle técnico/auditoría.

## Modal “Asignar mangas”

Debe permitir:

1. seleccionar un maquinista activo;
2. ver mangas del trabajo agrupadas por estado y versión de etiqueta;
3. seleccionar un subconjunto o “todas las pendientes/no iniciadas”;
4. ingresar motivo obligatorio si es un relevo;
5. advertir que un sticker ya impreso con otro nombre exige reemplazo;
6. para manga abierta dentro de la misma OT, exigir supervisor, motivo y
   conteo de frontera si se declararán unidades por persona;
7. bloquear manga pesada/recibida y cualquier cruce de OT/turno/fecha.

La confirmación muestra cuántas mangas cambian, cuáles requieren nueva versión
de etiqueta y cuáles quedan fuera. Nunca modifica cupo ni crea mangas extras.

## Estados de pantalla

- **Carga:** skeleton por máquina sin acciones prematuras.
- **Vacío:** explica cómo crear la OT o ajustar filtros.
- **Sin trabajos:** OT creada con acción “Agregar Trabajo de color”.
- **Máquina sin OT:** tarjeta neutra y acción permitida para crear la jornada.
- **Máquina inactiva con OT histórica:** tarjeta conservada con alerta; no se
  ofrece el recurso para crear otra jornada.
- **Conflicto de versión:** conserva selección y permite recargar.
- **Trabajo concurrente:** identifica el trabajo ya activo y bloquea el segundo.
- **API no disponible:** lectura previa visible, escrituras bloqueadas; el
  piloto no simula éxito offline.
- **Permiso insuficiente:** acción ausente/bloqueada y respuesta server-side.

## Responsive y comprensión de novato

- En escritorio, cuadrícula compacta de tarjetas por máquina y detalle de la
  máquina seleccionada; se conserva una alternativa de lista para auditoría.
- En ancho intermedio, acciones secundarias pasan a menú sin desbordarse.
- En móvil, tarjetas apiladas; estado, color y acción primaria permanecen
  visibles.
- Color, artículo y OF poseen rótulos humanos; el código técnico se reserva al
  detalle auditable.
- La cola es append-only en este piloto. La secuencia se consulta, pero no se
  arrastra ni sobrescribe; cambiar prioridad se ejecuta mediante pausa/inicio
  gobernados. El reordenamiento persistente queda en backlog.

## Escenarios representados

- M1-01, M1-03…M1-06: cola y estados.
- M2-01, M2-04…M2-06: mangas, anulación y restricciones.
- M3-01, M3-03…M3-09: relevo, subconjuntos, reemplazo y fronteras.

## Fuera de alcance visible

La vista no ofrece material preparado, R1…Rn, formulación experimental,
pesaje intermedio, continuidad multi-jornada ni migración de Armado a Trabajo
de color.
