---
tipo: draft
estado: promovido-a-user-story
tags: [scm, pesaje, manga, pesaje-intermedio, avance-color, planta]
relaciones:
  - "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
  - "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]]"
fecha_creacion: 2026-08-07
fecha_actualizacion: 2026-08-07
---

# Draft: pesaje intermedio, cierre explícito y avance por color

## Solicitud de planta

La operación normalmente pesa las mangas al final del turno, pero necesita un
corte adicional a mitad del día. Una manga puede llegar incompleta a ese corte
y debe conservar el mismo QR para regresar a la máquina, continuar llenándose y
pesarse nuevamente. Algunas mangas de baja rotación pueden tardar hasta tres
días en completar su objetivo.

La propuesta inicial fue mostrar en Balanza un checkbox `Manga incompleta` y
exigir que el maquinista marque después que terminó la bolsa. La misma vista
debería comunicar cuántas mangas faltan para cubrir la meta del color, de modo
que Producción sepa si debe seguir trabajando esa corrida o avisar que está
lista para el cambio de color.

## Problema que debe resolver el refinamiento

El sistema vigente interpreta cada F2 como el único pesaje final de la manga:
confirma toda su cantidad asignada, genera postetiqueta y la deja pendiente de
recepción. Repetir ese comportamiento con una bolsa abierta duplicaría o
cerraría prematuramente producción.

El caso tampoco es solamente visual. Una manga que permanece abierta tres días
atraviesa varias OT diarias, posibles relevos de maquinista y varios controles
acumulados. Es necesario conservar su identidad física sin atribuir todo el
resultado al primer o al último turno.

## Hipótesis de solución a validar

- distinguir `PESAJE_CONTROL`, repetible e informativo, de un único
  `PESAJE_FINAL`;
- conservar el mismo QR mientras la manga continúe abierta;
- no sumar lecturas acumuladas: el último peso representa el contenido físico
  observado y el delta solo explica el avance desde el control anterior;
- reemplazar el checkbox aislado por dos decisiones explícitas y mutuamente
  excluyentes: `Registrar avance; sigue abierta` y `Completar manga; cerrar e
  imprimir`;
- no imprimir postetiqueta, confirmar unidades, habilitar Almacén ni mover
  Kardex durante un control;
- mostrar meta de la corrida/color con mangas cerradas, abiertas, sin iniciar y
  faltantes, separando extras y anuladas;
- registrar la continuidad de la manga por OT, turno y maquinista cuando cruce
  jornadas;
- mostrar `Meta alcanzada; avise al supervisor`, sin ordenar automáticamente al
  maquinista que cambie de color.

## Riesgos detectados

1. Un checkbox olvidado puede convertir accidentalmente un control en cierre
   final o viceversa.
2. Sumar pesos acumulados infla los kg producidos.
3. El peso no demuestra el número exacto de unidades y no debe inferirlo.
4. Una manga abierta no puede ingresar a Almacén ni nacer en Kardex.
5. Una misma manga no puede mezclar colores, corridas o lotes incompatibles.
6. El cierre accidental necesita reapertura compensatoria; anular por completo
   la manga no equivale a continuar llenándola.
7. En moldes con varias salidas, completar una pieza no significa que toda la
   corrida esté lista para cambiar de color.

## Salida del refinamiento

Este draft se promueve a
[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]. La historia
permanece `en-refinamiento` hasta validar con Planta la atribución por OT de una
manga multi-jornada, la autoridad de cierre parcial y el alcance exacto de la
meta visible.
