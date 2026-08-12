---
tipo: modelo_bd
tabla: scm_trabajo_color
estado: implementado-local-pendiente-uat
tags: [dominio, scm, trabajo-color, corrida, fabricacion]
relaciones_padre:
  - "[[Trabajo_OT]]"
  - "[[Orden_Fabricacion]]"
relaciones:
  - "[[US-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-09
---

# Trabajo de color

Nombre de Planta para la especialización de Fabricación de un [[Trabajo_OT]].
Es la unidad atómica que ejecuta una corrida/color homogénea en una máquina.
No es una operación de ruta: soplado, inyección, pintado o armado continúan
siendo operaciones tecnológicas.

## Identidad

`scm_trabajo_color.trabajo_ot_id` es simultáneamente PK y FK 1:1 a
`scm_trabajo_ot.id`. Por eso la API visible usa el mismo UUID como
`trabajo_color_id`, mientras las FK físicas de manga, cupo, extra y asignación
se denominan `trabajo_ot_id`.

## Campos

| Campo | Regla |
|---|---|
| `trabajo_ot_id` | PK/FK al trabajo tipo `COLOR`. |
| `corrida_fabricacion_id` | Corrida exacta perteneciente a una OF liberada. |
| `molde_codigo_snapshot` | Molde congelado al despachar. |
| color snapshot | ID y nombre congelados desde la corrida. |
| receta snapshot | Revisión/hash de receta aprobada; no formulación experimental. |
| cavidades/pesos | Snapshots técnicos de ejecución. |
| `colada_inicial/final` | Frontera de contador cuando se utilice. |

La OF se resuelve mediante la corrida/orden operativa; no se escribe un texto
equivalente. Un mismo objetivo de corrida puede repartirse en varios trabajos
de distintas OT, fechas o máquinas.

La API conserva esa identidad técnica, pero la vista operativa muestra
**Color a fabricar** usando `color_identidad.nombre`. El contrato aditivo es
`{id,nombre,base,familia,hex}` y mantiene los aliases `color`, `color_nombre` y
`color_hex`. El código de corrida no se utiliza como rótulo principal ni como
dato que Planta deba interpretar.

## Reglas de cambio

- Una parada compatible pausa y reanuda el mismo trabajo.
- Cambiar corrida, receta, molde, máquina o límite de Calidad crea otro trabajo.
- A → B → A reanuda A solo si mantiene corrida, receta, molde y límite de
  Calidad; de lo contrario crea continuación.
- Preparación, limpieza, purga, tiempo y merma se conservan como eventos entre
  trabajos.

## Mangas y resultados

Toda manga de Fabricación usa físicamente `scm_manga.trabajo_ot_id`. La API la
presenta como manga del Trabajo de color. Cupo, salida, QR, pesaje, corrección,
anulación, recepción y genealogía se atribuyen al mismo UUID.

## Fuera de alcance

El trabajo no posee ni crea lote de material preparado, mezcla experimental o
generaciones `R1…Rn`. Puede recibir la referencia del consumo ordinario de una
receta aprobada. US-010L conserva cualquier evolución posterior.
