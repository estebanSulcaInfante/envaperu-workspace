---
tipo: user-story
estado: implementada-local-pendiente-uat
tags: [scm, piloto, ot, trabajo-color, cola, atdd]
relaciones:
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[Trabajo_OT]]"
  - "[[Trabajo_Color]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-09
---

# US-010M1: OT de máquina y cola de Trabajos de color

## Historia

**Como** supervisor de Producción  
**Quiero** programar en una OT de máquina una cola ordenada de Trabajos de color  
**Para** cambiar de color o corrida sin crear otra OT visible ni mezclar los
resultados técnicos.

## Alcance

- OT canónica por máquina, fecha operativa, turno y proceso.
- Trabajo de color por OF/corrida exactas.
- cola, secuencia, estados y concurrencia de inicio;
- cambio A → B → A y evento de preparación/purga;
- proyecciones agregadas de OT;
- tablero diario por máquina, incluida la máquina todavía sin OT;
- lenguaje operativo de color sin exigir al usuario el término técnico
  `CorridaFabricacion` ni su código `Cxx`;
- migración compatible de OT monocolor existentes.

## Invariantes

1. La OT no posee OF, corrida, color, receta, cuota ni contador autoritativos.
2. Cada trabajo referencia una corrida perteneciente a su OF.
3. Un trabajo hereda color y receta; no admite equivalentes en texto libre.
4. Solo un trabajo está `EN_EJECUCION` por máquina e instante.
5. Pausar no cambia contexto ni duplica cuota.
6. Cambiar corrida, receta, molde, máquina o límite de Calidad crea otro trabajo.
7. A → B → A reanuda A solo si el contexto técnico completo continúa vigente.
8. El estado y los totales de OT se calculan desde sus trabajos.
9. Cerrar la OT exige trabajos y excepciones resueltos.
10. Los comandos críticos exigen versión e idempotency key.
11. La exclusividad `EN_EJECUCION` gobierna la máquina, no la Balanza: una
    manga cerrada de un trabajo `PAUSADO` puede pesarse mientras otro trabajo
    de la misma OT está activo.
12. `COMPLETADO` exige que sus mangas y excepciones estén resueltas.
13. El tablero consulta fecha y turno y representa todas las máquinas activas;
    una tarjeta sin OT es un estado vacío y no crea una OT implícita.
14. `CorridaFabricacion` permanece como identidad técnica interna de
    OF/color/receta. La UI muestra el nombre humano de `ColorProduccion` y el
    artículo/OF; no presenta “corrida” o `C01` como concepto que Planta deba
    conocer.

## Escenarios ATDD/BDD

### M1-01 — Dos colores en una sola OT

**Dado** una máquina, turno y dos corridas liberadas compatibles  
**Cuando** el supervisor crea la OT y agrega Verde y Azul  
**Entonces** existe una OT con dos trabajos ordenados y cada trabajo conserva su
OF, corrida, color, cuota y snapshots.

### M1-02 — Exclusión por máquina

**Dado** Verde `EN_EJECUCION`  
**Cuando** dos solicitudes concurrentes intentan iniciar Azul  
**Entonces** una sola transición puede confirmarse y nunca quedan dos trabajos
activos en esa máquina.

### M1-03 — Pausa y reanudación

**Dado** un trabajo Verde iniciado  
**Cuando** se pausa y reanuda sin cambiar su contexto  
**Entonces** conserva identidad, cuota, avance e intervalos y no crea otro
trabajo.

### M1-04 — A → B → A compatible

**Dado** Verde pausado, Azul completado y la misma corrida Verde vigente  
**Cuando** el supervisor vuelve a Verde  
**Entonces** reanuda el trabajo original y registra un nuevo intervalo y el
cambio de configuración.

### M1-05 — A → B → A incompatible

**Dado** que cambió la receta, molde o límite de Calidad de Verde  
**Cuando** se vuelve a ese color  
**Entonces** se crea un trabajo continuación y el anterior no se altera.

### M1-06 — Cierre agregado

**Dado** una OT con un trabajo completo y otro pendiente  
**Cuando** se intenta cerrar la OT  
**Entonces** se rechaza con los pendientes; al resolverlos, la OT se cierra con
totales derivados.

### M1-07 — Backfill conservador

**Dado** una OT monocolor histórica con mangas y pesajes  
**Cuando** se ejecuta la migración  
**Entonces** obtiene exactamente un trabajo hijo y conserva todos sus IDs,
códigos, payloads y hechos físicos.

### M1-08 — Pesaje diferido no reactiva ejecución

**Dado** Verde pausado con una manga cerrada pendiente de Balanza y Azul
`EN_EJECUCION` en la máquina  
**Cuando** se pesa la manga Verde al final del turno  
**Entonces** el pesaje es elegible, Verde continúa `PAUSADO`, Azul continúa
activo y no existen dos trabajos ejecutándose en la máquina.

### M1-09 — Tablero completo de la jornada

**Dado** el catálogo de máquinas activas y una fecha/turno con OT solo para un
subconjunto  
**Cuando** el supervisor abre el tablero diario  
**Entonces** ve una tarjeta por máquina, incluso “Sin OT”, y las tarjetas con
OT muestran jornada, responsable, Trabajo de color activo, progreso de mangas,
siguiente trabajo y alertas sin crear datos faltantes.

### M1-10 — Color humano y origen inequívoco

**Dado** una OF con una sola configuración técnica Verde sólido heredada de una
PiezaColor  
**Cuando** se agrega un Trabajo de color  
**Entonces** la UI muestra `VERDE SÓLIDO` como valor de solo lectura y explica
su origen; si existen varias configuraciones liberadas, permite elegirlas por
nombre humano sin exigir “corrida” ni `Cxx`.

## Dataset mínimo

| Dato | Valor |
|---|---|
| Máquina | Haitian 3000 |
| OT | `OT-000123`, 2026-08-10, turno DÍA |
| Trabajo A | `TC-000001`, OF-000042/COR-01, Verde sólido |
| Trabajo B | `TC-000002`, OF-000042/COR-02, Azul |
| Continuación | `TC-000003`, solo si cambia el contexto de A |

## Fuera de alcance

- mangas, pesaje y recepción: M2;
- relevo de trabajador: M3;
- continuidad entre OT o fechas: US-010K;
- material preparado y R1…Rn: US-010L;
- Trabajo de Armado.
- reordenamiento persistente de una cola ya creada; en el piloto la secuencia
  es append-only y la prioridad operativa se resuelve pausando/iniciando el
  Trabajo de color autorizado.

## Definición de preparada

- [x] Actores, resultado e invariantes inequívocos.
- [x] A → B → A, tablero diario y lenguaje humano de color definidos.
- [x] Dataset y errores concurrentes definidos.
- [x] Migración histórica delimitada.
- [x] Fronteras con M2, M3, K y L explícitas.
