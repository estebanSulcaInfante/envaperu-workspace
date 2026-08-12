---
tipo: modelo_bd
tabla: scm_trabajo_ot
estado: aprobado-para-desarrollo
tags: [dominio, scm, ot, trabajo-color, ejecucion]
relaciones_padre:
  - "[[Registro_Diario]]"
relaciones_hijas:
  - "[[Trabajo_Color]]"
  - "[[Asignacion_Trabajo_OT]]"
  - "[[Unidad_Logistica]]"
relaciones:
  - "[[US-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# Trabajo OT

Unidad ejecutable atómica dentro de una **OT** de máquina/turno. La cabecera de
dominio OT continúa físicamente en `registro_diario_produccion`; no existe una
tabla paralela `scm_orden_trabajo` durante el cutover.

En el incremento US-010M, todo `scm_trabajo_ot` tiene `tipo=COLOR` y se presenta
al usuario como **Trabajo de color** mediante su especialización
[[Trabajo_Color]]. La abstracción permite que Armado conserve su adaptador sin
forzar todavía un `TrabajoArmado`.

## Campos

| Campo | Regla |
|---|---|
| `id` | UUID estable; la API visible puede exponerlo como `trabajo_color_id`. |
| `orden_trabajo_id` | FK a `registro_diario_produccion.id`; OT de máquina/turno. |
| `codigo` | Código humano estable del trabajo. |
| `tipo` | Solo `COLOR` en este incremento. |
| `secuencia` | Posición positiva y única dentro de la OT. |
| `estado` | `PLANIFICADO`, `EN_EJECUCION`, `PAUSADO`, `COMPLETADO` o `ANULADO`. |
| `orden_operacion_id` | Operación técnica liberada que se ejecuta. |
| `cantidad_objetivo_un` | Cuota propia del trabajo. |
| `cantidad_confirmada_un` | Proyección desde hechos confirmados; no input libre. |
| tiempos | Inicio, pausa, finalización y anulación. |
| motivos | Pausa y anulación auditadas. |
| actores | Creador y anulador cuando corresponda. |
| `version` | Control optimista, siempre positivo. |

`LISTO` y `BLOQUEADO` son proyecciones calculadas desde requisitos, estados y
excepciones; no se persisten como estados del trabajo.

## Invariantes

1. La OT padre define máquina, fecha, turno y proceso; el trabajo define la
   ejecución técnica homogénea.
2. La secuencia no se repite dentro de una OT.
3. Solo un trabajo puede estar `EN_EJECUCION` dentro de la misma OT/máquina.
4. Objetivo y confirmación no son negativos.
5. Pausar/reanudar conserva identidad, cupo y avance.
6. Una compensación no edita hechos históricos ni reabre silenciosamente un
   trabajo completado.
7. La OT deriva sus estados y métricas desde sus trabajos.

## Relaciones físicas

```text
registro_diario_produccion (OT)
└── scm_trabajo_ot
    ├── scm_trabajo_color
    ├── scm_asignacion_personal_trabajo_ot
    └── scm_manga.trabajo_ot_id
```

## Migración

Cada OT monocolor histórica recibe exactamente un trabajo tipo `COLOR`. No se
fusionan OT históricas. Las FK nuevas se completan por identidad existente, no
por nombres de color o parsing de códigos.

