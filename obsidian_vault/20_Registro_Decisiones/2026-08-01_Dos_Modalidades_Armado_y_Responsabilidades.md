---
tipo: decision
estado: aceptada
tags: [scm, armado, prearmado, mesa-de-armado, ot, responsabilidades, trazabilidad]
relaciones:
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
  - "[[2026-07-30_OT_Diaria_Comun_para_Fabricacion_y_Armado]]"
fecha_creacion: 2026-08-01
fecha_actualizacion: 2026-08-04
---

# Dos modalidades de armado y responsabilidades

## Contexto

En la planta existen dos actividades que antes se estaban describiendo como si
fueran la misma:

1. **Prearmado concurrente en máquina:** durante los tiempos muertos de una
   máquina se une la pieza recién producida con otra pieza ya disponible (por
   ejemplo, cuerpo + asa). La bolsa puede contener ambos componentes y su peso
   físico no representa exclusivamente la producción de la máquina.
2. **Armado en mesa:** en la zona de mesas se realiza la mayor parte del
   armado y, normalmente, la última transformación que convierte las piezas
   en producto terminado antes de Almacén.

Ambas son operaciones de armado y conservan genealogía, consumos, mangas y
pesaje propios, pero no exigen la misma interacción de usuario.

## Decisión

- El **maquinista** registra ciclos, producción de la máquina y sus incidencias.
  No debe detener su tarea para digitar cada conjunto armado.
- El **prearmador u operador de línea** puede ejecutar físicamente el armado
  concurrente. Puede ser la misma persona que el maquinista, pero el sistema
  distingue la responsabilidad de Fabricación de la de Armado.
- El **responsable de Armado** es quien confirma la cantidad real de una manga
  de armado antes del pesaje. La identidad y el rol se toman de la OT de
  Armado; no se infieren desde la balanza.
- `AvanceArmado` es **opcional**. Sirve para registrar checkpoints de una
  manga abierta cuando el responsable necesita visibilidad intermedia, pero no
  es requisito para operar el prearmado concurrente.
- La confirmación obligatoria es `CERRAR_MANGA_ARMADO`: reconcilia la cantidad
  real, aplica consumos y acredita WIP o ProductoTerminado según la ruta. El
  pesaje posterior solo registra el peso físico.

## Interacción por modalidad

| Modalidad | Ejecutor físico | Registro mínimo | Resultado habitual |
|---|---|---|---|
| Concurrente en máquina | Prearmador/maquinista/ayudante asignado a la OT de Armado | Cierre de manga con conteo real; checkpoints opcionales | WIP (por ejemplo cuerpo + asa) o PT si la ruta ya queda completa |
| Mesa de armado | Responsable y equipo de la OT de Armado | Cierre de cada manga con conteo real; checkpoints opcionales | Normalmente ProductoTerminado, o WIP si aún faltan operaciones |

La misma operación puede dividirse entre ambas modalidades. La cuota de la OA
se reparte entre OT de Armado y mangas; no se crean dos productos ni se
duplica el consumo por cambiar de ubicación.

La OT diaria persiste `modo_ejecucion_armado=MESA|CONCURRENTE`. En modo
concurrente exige `ot_fabricacion_contexto_id`, correspondiente a una OT de
Fabricación activa de la misma fecha; en modo mesa ese vínculo queda vacío.
La operación debe declarar `permite_concurrente=true` para habilitar la primera
modalidad.

## Granularidad de BOM y ruta

La BOM se divide hasta una **salida física con identidad operativa**, no hasta
cada gesto manual. Un WIP se justifica cuando el resultado puede contarse,
embolsarse, trasladarse, almacenarse o terminarse después. Por ello
`cuerpo + asa` es un WIP válido; unir pico y tapa en la mesa forma parte de la
BOM del PT. La ruta del PT conserva dos operaciones secuenciales y la modalidad
diaria del prearmado no obliga a eliminar ni recrear estructuras.

## Flujo concurrente corregido

1. La OT de Fabricación continúa registrando ciclos y unidades buenas del
   cuerpo.
2. La OT de Armado concurrente conserva la cuota y las reservas de asas u
   otros componentes.
3. El trabajador realiza el prearmado entre ciclos y coloca los conjuntos en
   la manga preetiquetada.
4. No se exige un registro por ciclo ni por unidad. Si se requiere visibilidad,
   el responsable registra un checkpoint agregado (`AvanceArmado`) desde el
   módulo de Armado.
5. El responsable cuenta y cierra la manga con la cantidad real. Central
   consume componentes y acredita el resultado de forma idempotente.
6. La manga se pesa en la estación de balanza y continúa al flujo de Almacén.

## Flujo de mesa

El responsable abre la OT diaria de Armado, recibe componentes mediante el
flujo de abastecimiento, registra opcionalmente checkpoints y cierra las
mangas conforme termina lotes de trabajo. La confirmación de cantidad y el
pesaje siguen siendo dos hechos separados.

## Invariantes de UX y datos

1. La pantalla de Fabricación no muestra un campo obligatorio para “avance de
   armado”.
2. La pantalla de Armado muestra por separado `provisional abierto` y
   `confirmado`; no presenta el peso como sustituto de unidades.
3. La estación de Balanza nunca permite editar cantidad, BOM, consumo ni
   responsable; solo captura bruto, tara y neto.
4. Si el mismo trabajador desempeña dos funciones, el sistema registra dos
   responsabilidades auditables en sus respectivas OT; no mezcla los avances.
5. Cerrar la OT de Fabricación no cierra automáticamente la OT de Armado
   concurrente, ni viceversa.

## Criterios de aceptación

- **ARM-01:** crear una OT concurrente sin registrar `AvanceArmado` y cerrar
  una manga con cantidad real; el sistema consume y acredita correctamente.
- **ARM-02:** el maquinista registra ciclos sin que aparezca una tarea de
  digitación de armado en la estación de Fabricación.
- **ARM-03:** registrar un checkpoint desde Armado actualiza la proyección
  provisional, pero no consume stock ni acredita WIP/PT hasta cerrar la manga.
- **ARM-04:** una manga cerrada en mesa y otra cerrada en línea conservan el
  mismo artículo/ruta y distinta OT, responsable, centro y contexto físico.
