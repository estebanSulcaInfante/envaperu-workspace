---
tipo: decision
estado: aceptada
tags: [scm, orden-trabajo, fabricacion, armado, fecha-operativa, turno, trazabilidad]
relaciones:
  - "[[Orden_Operacion]]"
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Armado]]"
  - "[[Registro_Diario]]"
  - "[[TS-010P_OP_Demanda_OF_OA_y_Migracion_Documental]]"
  - "[[TS-010F_Armado_Genealogia_Mangas_PT_y_Cierre_Armado]]"
fecha_creacion: 2026-07-30
fecha_actualizacion: 2026-07-30
sustituida_parcialmente_por:
  - "[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]"
  - "[[2026-08-09_Jornadas_de_Planta_y_Fechas_Proyectadas_de_OF_OA]]"
---

# OT diaria común para Fabricación y Armado

## Decisión

La Orden de Trabajo es el documento diario de ejecución de una orden técnica.
Se modela como un agregado común con dos especializaciones:

```text
OrdenTrabajo
├─ OT_FABRICACION -> OrdenFabricacion + Corrida + Máquina + Molde
└─ OT_ENSAMBLE    -> OrdenArmado + Centro/Celda + Responsable + Equipo
```

No se crea un documento paralelo llamado “Registro Diario de Armado”. La misma
identidad `OT-######`, máquina de estados y fecha operativa se reutilizan para
ambos procesos.

## Cardinalidades

> [!important] Vigencia
> Los puntos 1 y 3 quedan sustituidos para Fabricación normalizada: una OT de
> máquina contiene N Trabajos de color y cada trabajo referencia su OF/corrida;
> por eso una misma OT puede agregar varias OF compatibles. Los puntos de
> Armado permanecen vigentes: una OT de Armado ejecuta exactamente una OA.

1. Una OF puede ejecutarse mediante muchas OT de Fabricación.
2. Una OA puede ejecutarse mediante muchas OT de Armado.
3. Cada OT ejecuta exactamente una OF o una OA, nunca ambas.
4. Una OT pertenece a una sola fecha operativa, turno y centro de trabajo.
5. Una OT de Armado tiene un responsable de Armado obligatorio y un equipo
   opcional N:M.
6. Una manga WIP/PT pertenece exactamente a una OT de Armado.
7. Si un equipo trabaja en dos OA durante el mismo día, se abren dos OT.

## Separación de responsabilidades

| Documento | Responde |
|---|---|
| OP | Qué productos terminados requiere el negocio. |
| OF | Qué debe fabricarse mediante molde y con qué configuración técnica. |
| OA | Qué WIP/PT debe armarse y con qué BOM/ruta. |
| OT | Qué porción se ejecutará en una fecha, turno, centro y equipo concretos. |
| Manga | Qué unidad física concreta fue cerrada, pesada y movida. |

## Planificación de mangas

La OA conserva el plan agregado. Cada OT de Armado recibe una cuota diaria y
materializa solo sus mangas asignadas.

```text
OA-000025: 1,000 unidades
├─ OT-000141: 400 unidades -> 4 mangas
├─ OT-000148: 500 unidades -> 5 mangas
└─ OT-000153: 100 unidades -> 1 manga
```

La preimpresión se solicita desde la OT de Armado. Esto evita imprimir todas
las mangas de una OA antes de conocer la jornada real.

## Código visible

- OT: `OT-######`, correlativo global común.
- Manga de Fabricación: `OF000042-OT000123-M001`.
- Manga de Armado: `OA000025-OT000141-M001`.

Los códigos son ayudas humanas. Las relaciones usan UUID estables.

## Modelo de transición

La tabla legacy `registro_diario_produccion` contiene campos exclusivos de
inyección y no debe convertirse en una tabla única llena de columnas nulas.

La evolución será:

```text
scm_orden_trabajo
├─ registro_diario_produccion  (adaptador/subtipo Fabricación)
└─ scm_ot_armado             (subtipo Armado)
```

`scm_orden_trabajo` contiene identidad, código, tipo, orden ejecutada, fecha
operativa, turno, centro, responsable, objetivo, estado, versión y auditoría.
Las extensiones contienen únicamente datos específicos.

Durante la migración:

- las OT de Fabricación nuevas crean cabecera común y fila compatible de
  `registro_diario_produccion`;
- las filas legacy se enlazan por backfill sin inventar una OA;
- una OT de Armado crea cabecera común y `scm_ot_armado`;
- los pesajes históricos permanecen asociados al registro legacy original.

## Consecuencias

- La productividad diaria de Armado puede medirse sin mezclar jornadas.
- Una OA puede durar varios días sin perder responsabilidad ni fecha operativa.
- Las mangas y etiquetas muestran una estructura coherente OF/OA–OT–Manga.
- El responsable de Armado confirma cantidades dentro de su OT.
- Máquina, molde y corrida no se vuelven obligatorios para Armado.
- La UI puede mostrar “Mi jornada de Armado” sin exponer la complejidad de la
  OA completa.
