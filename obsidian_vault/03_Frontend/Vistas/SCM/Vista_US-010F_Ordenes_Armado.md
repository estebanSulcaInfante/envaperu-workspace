---
tipo: vista_frontend
estado: implementada-local
tags: [frontend, scm, US-010F, armado, prearmado, ot]
fecha_actualizacion: 2026-08-04
---

# Vista US-010F: Órdenes de armado

## Ruta

`/produccion/ordenes-armado`

## Objetivo

Crear y ejecutar OT diarias para operaciones de prearmado, armado, acabado o
empaque, conservando la BOM y la ruta aprobadas por Planificación.

## Modalidad diaria

Al crear una OT diaria, el usuario selecciona:

- **En mesa de armado:** el trabajo se ejecuta en el centro elegido y no se
  vincula a una OT de Fabricación.
- **Concurrente con fabricación:** solo está disponible si la operación de ruta
  permite concurrencia. Exige una OT de Fabricación activa de la misma fecha.

La modalidad no cambia el artículo de salida, la BOM ni la cuota. El vínculo
con Fabricación conserva contexto y separa responsabilidades; no agrega el peso
del componente incorporado a la producción acreditada a la máquina.

## Reglas de interfaz

- El selector concurrente ofrece solo OT de Fabricación planificadas o en
  ejecución y de la fecha operativa seleccionada.
- Sin una OT de contexto válida no se habilita la creación concurrente.
- El modo mesa limpia cualquier contexto de Fabricación.
- El centro, responsable, turno y cuota diaria siguen siendo obligatorios.
- Las cuotas de OT activas no pueden superar el objetivo de la OA.

## Estructura recomendada

Para el caso de la regadera se usa una sola ruta con dos operaciones:

1. `PREARMADO`: consume cuerpo y asa, produce el WIP y permite concurrencia.
2. `ENSAMBLE`: consume WIP, pico y tapa, y produce el PT en mesa.

Las BOM deben ser atómicas hasta una transformación con salida física
identificable. No se crea un WIP por cada acción manual.

## Validación

- La API rechaza modalidad desconocida, concurrencia no habilitada, contexto
  ausente, OT no activa y fecha discordante.
- Las OT de Armado anteriores a la migración se clasifican como `MESA`.
- Pruebas focalizadas aprobadas: backend 12, frontend 4 y build Vite.
- Migración aplicada en `envaperu_test`: `f67e6a2c8db4`.
