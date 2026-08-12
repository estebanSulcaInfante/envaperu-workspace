---
tipo: user-story
estado: implementada-local-pendiente-uat
tags: [scm, piloto, trabajo-color, manga, qr, pesaje, anulacion, atdd]
relaciones:
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[TS-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# US-010M2: Mangas, pesaje y anulación por Trabajo de color

## Historia

**Como** supervisor y operador de Balanza  
**Quiero** que cada manga resuelva su Trabajo de color y salida exactos  
**Para** pesar, recibir, corregir o anular sin confundir colores ni cupos de una
misma OT.

## Alcance

- FK obligatoria desde manga de Fabricación al Trabajo de color;
- cupo normal/extra y salida por trabajo;
- contratos de preetiqueta, QR, estación y postetiqueta;
- pesaje, corrección, `ANULAR_PESAJE`, recepción, Calidad y Kardex;
- frontera explícita con material ordinario ya planificado por corrida;
- backfill sin cambiar identidades históricas.

## Invariantes

1. Una manga pertenece a un trabajo y una salida exactos.
2. No mezcla trabajos, corridas, recetas, colores o salidas incompatibles.
3. El QR conserva `manga_id`; la etiqueta conserva otro `label_id` versionado.
4. Cupo y tipo `NORMAL/EXTRA` se calculan dentro del trabajo.
5. El peso jamás infiere unidades ni permite sustituir el trabajo manualmente.
6. Anular antes de Almacén invalida QR, revierte el hecho vigente y devuelve
   exactamente el cupo una sola vez.
7. Después de recepción, `ANULAR_PESAJE` exige reversa previa.
8. El reemplazo posterior a anulación puede ser `NORMAL`.
9. Ningún perfil elimina directamente manga, etiqueta, pesaje o movimiento.
10. La OT agrega los hechos de sus trabajos sin una segunda escritura.
11. Una manga cerrada de un trabajo `PAUSADO` continúa elegible para pesaje; la
    Balanza no exige que su trabajo sea el activo de la máquina.
12. Un trabajo no pasa a `COMPLETADO` mientras conserve mangas sin pesar,
    anular o resolver según su política.

## Escenarios ATDD/BDD

### M2-01 — QR resuelve el trabajo exacto

**Dado** una OT con trabajos Verde y Azul  
**Cuando** se escanea una manga Verde  
**Entonces** la estación muestra OT, Trabajo Verde, OF, corrida, salida,
cantidad y responsable como solo lectura.

### M2-02 — Pesaje idempotente

**Dado** una manga Verde completa  
**Cuando** se confirma dos veces con la misma operación  
**Entonces** existe un solo pesaje, una postetiqueta y un débito de cupo.

### M2-03 — Separación de salidas multipieza

**Dado** un trabajo cuyo molde genera tres PiezaColor  
**Cuando** se materializan mangas  
**Entonces** cada manga selecciona una salida exacta y no mezcla cupos ni
cantidades de las otras dos.

### M2-04 — Anulación antes de Almacén

**Dado** una manga pesada aún no recibida  
**Cuando** un actor autorizado ejecuta `ANULAR_PESAJE` con motivo  
**Entonces** conserva el original, invalida QR y etiquetas vigentes, devuelve
el cupo al trabajo y permite crear un reemplazo `NORMAL`.

### M2-05 — Reversa obligatoria

**Dado** una manga pesada y recibida  
**Cuando** se solicita anular el pesaje  
**Entonces** responde `RECEIPT_REVERSAL_REQUIRED` sin modificar hechos; después
de la reversa controlada, la anulación puede continuar.

### M2-06 — Eliminación bloqueada

**Dado** cualquier perfil, incluido Gerente General  
**Cuando** intenta eliminar directamente una manga o pesaje  
**Entonces** la operación se rechaza y solo ofrece el flujo compensatorio.

### M2-07 — Material conocido sin ampliar alcance

**Dado** requerimientos y reservas de una receta aprobada ligados a la corrida  
**Cuando** el supervisor ejecuta A → B → A dentro de una OT  
**Entonces** cada Trabajo de color resuelve su corrida sin duplicar
requerimientos ni fingir un consumo, lote preparado, formulación experimental o
generaciones R1…Rn.

### M2-08 — Compatibilidad histórica

**Dado** los stickers 11213–11216 y registros legacy conservados  
**Cuando** se consulta o migra su contexto  
**Entonces** sus IDs y payloads permanecen explicables y no se reasignan a otro
trabajo por coincidencia de texto.

### M2-09 — Manga de trabajo pausado

**Dado** un Trabajo Verde pausado con manga cerrada y un Trabajo Azul activo en
la misma OT  
**Cuando** la Balanza escanea y pesa la manga Verde  
**Entonces** confirma el Trabajo Verde sin cambiar estados de ejecución ni
bloquearse por Azul.

## Fuera de alcance

- manga abierta o pesaje intermedio: US-010K;
- relevo de persona: M3;
- material preparado/experimental: US-010L;
- despacho comercial y operación offline.

## Definición de preparada

- [x] Anulación, reversa, cupo y reemplazo definidos.
- [x] Identidades QR/etiqueta/manga separadas.
- [x] Integración C/D/I y material ordinario delimitada.
- [x] Casos concurrentes, históricos y de seguridad observables.
