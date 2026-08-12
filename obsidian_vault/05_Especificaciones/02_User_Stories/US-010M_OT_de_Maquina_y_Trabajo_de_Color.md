---
tipo: user-story
subtipo: epic
estado: implementada-local-pendiente-uat
tags: [scm, piloto, ot, trabajo-color, isa95, epic]
relaciones:
  - "[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]"
  - "[[US-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[US-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color]]"
  - "[[US-010M3_Relevos_en_Trabajo_Color]]"
  - "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# US-010M: OT de máquina y Trabajo de color

## Propósito

**Como** Jefe de Producción o supervisor  
**Quiero** despachar una sola OT por máquina y turno con una cola de Trabajos
de color atómicos  
**Para** conservar el lenguaje de Planta, ejecutar cambios de color y mantener
la trazabilidad exacta de mangas, pesajes y responsables.

Esta nota organiza el refactor aprobado en
[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]. Es una épica y no
habilita una Tech Spec monolítica ni implementación directa.

## Resultado observable

```text
OT-000123 · Haitian 3000 · 2026-08-10 · Turno día
├── TC-001 · Verde sólido · OF-000042/COR-01 · COMPLETADO
├── TC-002 · Azul         · OF-000042/COR-02 · EN EJECUCIÓN
└── TC-003 · Rojo         · OF-000057/COR-01 · PLANIFICADO
```

El supervisor opera la cola. El maquinista recibe mangas identificadas,
escanea el QR y pesa sin seleccionar OT, OF, color, artículo ni cantidad.

## Historias hijas

| Historia | Entrega vertical | Dependencia |
|---|---|---|
| [[US-010M1_OT_Maquina_y_Cola_Trabajos_Color|M1]] | OT de máquina, cola, Trabajo de color, estados y migración base | Decisión aprobada |
| [[US-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color|M2]] | Manga → trabajo → pesaje → recepción/corrección/anulación | M1 y contratos C/D/I |
| [[US-010M3_Relevos_en_Trabajo_Color|M3]] | Asignaciones por intervalo y relevo dentro de la misma OT | M1 y M2 |

## Invariantes transversales

1. OT es la envolvente por máquina, fecha, turno y proceso.
   Su tabla física continúa siendo `RegistroDiarioProduccion` durante el
   cutover; el nombre de dominio es OT.
2. Trabajo de color es la unidad atómica de una OF/corrida.
3. Solo un trabajo puede ejecutarse en una máquina a la vez.
4. La OT agrega estados y métricas; no duplica hechos editables.
5. La manga pertenece a un trabajo y una salida exactos.
6. El trabajador se asigna por intervalo y no integra la identidad del trabajo.
7. QR, etiqueta, manga y pesaje conservan identidades separadas y auditables.
8. Toda compensación conserva el hecho original; ninguna eliminación directa
   forma parte del flujo.

## Fuera de alcance de la épica piloto

- manga que continúa en otra OT, turno o fecha;
- pesaje o control intermedio de manga abierta;
- `TramoMangaTrabajoColor`;
- `TrabajoArmado`; las OT de Armado usan el adaptador vigente;
- material preparado almacenable, R1…Rn o formulación experimental;
- operación offline y OCR del talonario.

Las tres primeras capacidades continúan en US-010K. El dominio de material
preparado continúa exclusivamente en US-010L.

## Secuencia de entrega

1. M1 introduce el agregado y migra cada OT monocolor a un único trabajo hijo.
2. M2 corta mangas y pesaje al nuevo padre atómico.
3. M3 sustituye el maquinista único por asignaciones temporales.
4. Se ejecutan regresiones US-010B/C/D/I y el E2E QR físico.
5. La UAT de M es puerta previa para retomar la UAT completa del piloto.

## Definición de completada de la épica

- [ ] M1, M2 y M3 aprobadas e implementadas.
- [ ] Migración repetible y sin pérdida de IDs o hechos históricos.
- [ ] Suites central, estación, frontend, PostgreSQL y E2E verdes.
- [ ] UAT con dos colores y un relevo aprobada.
- [ ] US-010K y US-010L continúan fuera sin implementaciones implícitas.
