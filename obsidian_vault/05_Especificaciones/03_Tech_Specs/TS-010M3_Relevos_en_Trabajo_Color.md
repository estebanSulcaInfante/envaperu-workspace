---
tipo: tech-spec
estado: implementada-local-pendiente-uat
tags: [scm, trabajo-color, relevo, trabajador, asignacion, concurrencia, tdd]
relaciones:
  - "[[US-010M3_Relevos_en_Trabajo_Color]]"
  - "[[DEV-010M3_Relevos_en_Trabajo_Color]]"
  - "[[Asignacion_Trabajo_OT]]"
  - "[[Baseline_TS-010R_C_D_2026-07-24]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# TS-010M3: Relevos dentro de un Trabajo de color

## 1. Objetivo técnico

Sustituir el maquinista único copiado a la OT y sus mangas por asignaciones
auditadas, sin introducir continuidad multi-jornada ni pesaje intermedio.

## 2. Baseline

M3 comienza únicamente con M1 y M2 verdes y reejecuta la baseline integral
referenciada en [[Baseline_TS-010R_C_D_2026-07-24]]. La primera prueba RED no
modifica hardware ni autenticación.

## 3. Persistencia

### `scm_asignacion_trabajo_ot`

| Campo | Regla |
|---|---|
| `id` | UUID estable. |
| `trabajo_ot_id` | FK física al trabajo tipo `COLOR`; API visible lo presenta como Trabajo de color. |
| `trabajador_id` | Trabajador activo con capacidad operativa. |
| `estado` | `PREVISTA`, `ACTIVA`, `CERRADA` o `CANCELADA`. |
| `asignada_at`, `iniciada_at`, `finalizada_at` | Plan e intervalo real. |
| `asignada_por_id`, `finalizada_por_id` | Actores de gobierno. |
| `motivo`, `version` | Explicación y concurrencia. |

PostgreSQL impide dos responsables principales vigentes para la misma máquina
y solapamientos de intervalos del mismo trabajo. El responsable
predeterminado de OT solo propone la primera asignación.

`scm_manga.asignacion_personal_trabajo_id` relaciona cada manga del subconjunto
con `scm_asignacion_personal_trabajo_ot`. No se crea otra tabla de enlace. Una
transferencia excepcional de manga abierta se registra como evento auditado y
puede conservar `conteo_frontera`; no contiene peso ni cruza OT.

## 4. API

| Método | Ruta | Resultado |
|---|---|---|
| POST | `/trabajos-color/{id}/asignaciones` | Primera asignación, relevo y asignación/reasignación de `manga_ids` dentro del trabajo. |
| GET | `/ots` | Incluye trabajos y asignación vigente para tablero. |

El POST acepta `trabajador_id`, `manga_ids`, `motivo`, `expected_version` y,
solo para una manga abierta, `conteo_frontera` y aceptación supervisada. Toma
lock de máquina, trabajo, asignación vigente y mangas; un conflicto devuelve el
estado vigente sin sobrescribir historia.

## 5. Etiquetas y atribución

- El supervisor puede repartir subconjuntos de mangas/stickers del mismo
  trabajo entre maquinistas.
- Mangas pendientes/no iniciadas pueden reasignarse masivamente sin cambiar
  cupo ni identidad.
- Si una etiqueta impresa muestra al responsable anterior, se invalida su
  versión y se genera un reemplazo para la misma manga.
- Una manga abierta solo se transfiere dentro de la misma OT con motivo y
  control/conteo de frontera; no genera captura de peso ni postetiqueta.
- Manga pesada o recibida conserva asignación productiva inmutable.
- Al pesar, el evento snapshottea `manga_asignacion_id`, trabajador productivo e
  identidad registrada por Balanza como campos diferentes.
- Sin conteo de frontera no se distribuyen unidades por estimación.

La identidad registrada por Balanza procede de la identidad de estación/usuario;
no se sobrescribe con el responsable esperado recuperado del QR. Si se usa una
identidad técnica compartida, no constituye prueba de qué persona trasladó la
manga; una credencial personal requeriría otro incremento.

## 6. Frontera US-010K

La API rechaza una transferencia si cambia `ot_id`, fecha operativa o turno con
`MULTI_SHIFT_BAG_NOT_ENABLED`. No se crean `TramoMangaTrabajoColor`, lecturas
acumulativas ni controles de peso. Esas capacidades pertenecen a US-010K.

## 7. Mapa ATDD → pruebas

| Escenario | Nivel y evidencia |
|---|---|
| M3-01 | integración: relevo conserva trabajo/cupo |
| M3-02 | PostgreSQL concurrente: un responsable vigente |
| M3-03 | integración: subconjuntos de mangas por maquinista |
| M3-04 | integración: reasignación masiva pendiente, cupo inmutable |
| M3-05 | integración impresión: nueva versión, misma manga/cupo |
| M3-06 | integración: manga abierta, conteo y cero pesaje intermedio |
| M3-07 | contrato pesaje: asignación y actor separados |
| M3-08 | proyección: sin conteo no inventa unidades |
| M3-09 | contrato: cruce de OT bloqueado y derivado a K |

Primera prueba RED: `M3-01`, porque hoy el maquinista está fijado en la OT y se
copia a todas sus mangas.

## 8. Definition of Done

- [ ] Baseline M1/M2 verde.
- [ ] M3-01…M3-09 automatizados.
- [ ] Concurrencia validada sobre PostgreSQL real.
- [ ] Subconjuntos, reasignación masiva y reemplazo de etiqueta no consumen
  doble cupo.
- [ ] Productividad no publica unidades inventadas.
- [ ] Ninguna ruta cruza otra OT ni implementa pesaje intermedio.
