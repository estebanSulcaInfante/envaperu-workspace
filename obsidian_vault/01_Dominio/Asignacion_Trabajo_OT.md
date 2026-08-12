---
tipo: modelo_bd
tabla: scm_asignacion_personal_trabajo_ot
estado: aprobado-para-desarrollo
tags: [dominio, scm, trabajo-color, trabajador, relevo, manga]
relaciones_padre:
  - "[[Trabajo_OT]]"
  - "[[Trabajador]]"
relaciones:
  - "[[US-010M3_Relevos_en_Trabajo_Color]]"
  - "[[TS-010M3_Relevos_en_Trabajo_Color]]"
  - "[[Unidad_Logistica]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# Asignación de personal a Trabajo OT

Intervalo auditado durante el cual un trabajador es responsable de ejecutar un
Trabajo de color. El trabajador no forma parte de la identidad de OT ni del
trabajo; un relevo cierra una asignación y crea/activa otra.

## Campos

| Campo | Regla |
|---|---|
| `id` | UUID estable de la asignación. |
| `trabajo_ot_id` | FK física al trabajo tipo `COLOR`. |
| `trabajador_id` | Trabajador activo y habilitado. |
| `estado` | `PREVISTA`, `ACTIVA`, `CERRADA` o `CANCELADA`. |
| `asignada_at` | Momento de planificación. |
| `iniciada_at/finalizada_at` | Intervalo real. |
| actores | Quién asignó y quién finalizó. |
| `motivo` | Relevo, ausencia, reasignación u otro motivo gobernado. |
| `version` | Control optimista. |

Solo una asignación puede estar `ACTIVA` para un trabajo. La transacción de
relevo bloquea trabajo y asignación vigente para evitar dos responsables
principales simultáneos.

## Asignación de mangas y stickers

`scm_manga.asignacion_personal_trabajo_id` fija qué asignación recibió cada
manga/sticker. El supervisor puede:

- repartir subconjuntos de mangas del mismo trabajo entre maquinistas;
- reasignar masivamente mangas pendientes o no iniciadas;
- reemplazar la versión de etiqueta si ya se imprimió el nombre anterior;
- transferir excepcionalmente una manga abierta dentro de la misma OT con
  motivo y control/conteo de frontera.

Estas acciones no crean manga, Trabajo de color ni cupo adicional. Una manga
pesada o recibida conserva su asignación histórica.

## Pesaje

`scm_pesaje_manga.asignacion_personal_trabajo_id` snapshottea la asignación de
la manga al confirmar. El trabajador productivo y el actor real de Balanza son
datos distintos. Si una manga abierta cambió de persona sin conteo de frontera,
el sistema no distribuye unidades por tiempo, peso o proporción.

## Frontera

La asignación no cruza otra OT, fecha o turno ni crea
`TramoMangaTrabajoColor`. Tampoco registra un pesaje intermedio. Esa continuidad
permanece en US-010K.

