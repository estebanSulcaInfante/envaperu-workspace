---
tipo: decision
estado: aceptada-para-incremento-controlado
spec_phase: approved
delivery_state: implemented
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
fecha_creacion: 2026-08-31
fecha_actualizacion: 2026-08-31
tags: [scm, pesaje, avance-kg, manga-incompleta, lector-qr, ux]
relaciones:
  - "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
  - "[[US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
  - "[[US-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
  - "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
  - "[[UAT_US-010K3_Control_Avance_Kg_y_Contexto_Visible]]"
  - "[[REC_2026-08-31_Control_Avance_Kg_y_Contexto_Visible_Estacion]]"
  - "[[2026-09-03_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
---

# Control de avance en kg, sin conteo, y una sola acción de pesaje

## Evidencia que origina la decisión

Durante una prueba operativa del 2026-08-31 se intentó registrar avance de una
manga dentro del mismo turno. La estación solicitó conteo y motivo, pero envió
la operación como `CORTE_TURNO / CAMBIO_TURNO`; Central cerró el tramo, pausó
el Trabajo y dejó la manga en `CONTINUIDAD_PENDIENTE`. El operador no pudo
volver a escanearla para agregar más peso.

El responsable funcional validó además que el conteo durante Fabricación no es
confiable en este momento. Por tanto, un control de avance no puede solicitar,
persistir ni presentar unidades declaradas como si fueran evidencia exacta.

La misma prueba identificó fricción adicional: dos botones de pesaje, pérdida
del foco del lector después de usar el mouse, código de manga demasiado pequeño,
cambio de contexto poco perceptible y ausencia de la foto disponible de la
pieza.

## Decisión

### 1. Avance únicamente físico

El control ordinario de una manga incompleta es `AVANCE_KG`:

- registra bruto, tara, neto acumulado, aporte desde el control anterior,
  actor, estación y momento;
- `conteo_acumulado_un` es nulo y no se infiere desde peso, ciclos o tiempo;
- confirma `0 UN`, no acredita producción y no crea recepción, existencia ni
  Kardex;
- no pausa el Trabajo, no cierra el tramo y no cambia la manga a
  `CONTINUIDAD_PENDIENTE`;
- conserva la manga `EN_LLENADO`, el mismo QR y la posibilidad de registrar
  otros avances o el pesaje final.

El total de unidades se confirma únicamente al cierre final desde la cantidad
asignada o mediante el cierre parcial supervisado vigente.

### Clarificación de implementación — 2026-09-01

En la estación vigente, “confirmar desde la cantidad asignada” significa que
F2 no envía conteo en un cierre normal y Central copia
`manga.cantidad_asignada_un` con fuente `PLAN_CONFIRMADO_POR_PESAJE`. No es un
conteo capturado por el módulo, no se deriva de bruto/neto y no demuestra por sí
solo que alguien haya contado las piezas. Solo el cierre parcial supervisado y
el cierre previo de Armado aportan una cantidad declarada explícitamente.

Por ello, una etiqueta no debe denominar `CONTEO FINAL` a la cantidad del cierre
normal sin distinguir su fuente. Mientras no se apruebe otra regla, debe
presentarse como cantidad planificada/teórica; cualquier cociente entre peso
real y peso unitario sería una estimación separada y nunca una confirmación para
inventario.

### 2. Atribución por trabajador o turno

Mientras no exista una fuente confiable de conteo, los kg delimitados por
controles pueden observar aporte físico, pero no demuestran unidades exactas
por trabajador u OT. El piloto no debe publicar una partición exacta en
unidades derivada de estos avances.

El `CORTE_TURNO` histórico se conserva para compatibilidad y auditoría. No se
presenta como el control ordinario de la estación. La redefinición completa del
relevo multijornada sin conteo queda fuera de este incremento y requiere una
decisión supervisada separada.

### 3. Una acción física de pesaje

La estación ofrece un único botón y F2 ejecuta exactamente la misma acción:

- checkbox `Manga incompleta` apagado: pesaje final y cierre;
- checkbox encendido: `AVANCE_KG` y la manga continúa abierta.

La pantalla debe expresar el efecto seleccionado junto al botón. El checkbox
se limpia al resolver otro QR y después de una operación aceptada para evitar
heredar la intención a la siguiente manga. El cierre final parcial continúa
como excepción supervisada, claramente separado y mutuamente excluyente.

> [!warning] Sustituido el 2026-09-03
> La UAT mostró dos cierres accidentales por omitir el checkbox. El valor por
> defecto y la confirmación pasan a regirse por
> [[2026-09-03_Control_por_Defecto_y_Cierre_Final_Deliberado]]: Control por
> defecto y cierre mediante selección más confirmación explícitas.

### 4. Foco y cambio de contexto

Después de usar el botón, la estación devuelve el foco al input del lector.
Cada resolución anuncia mediante texto, no solo color:

- `QR leído · manga <código>` para el primer contexto;
- `Cambio de manga · <anterior> → <actual>` cuando cambia la identidad.

El código/correlativo de la manga es información primaria y se muestra en una
cabecera grande `MANGA ACTIVA`. Ningún nuevo QR puede confirmarse sobre el
contexto anterior sin que el cambio sea visible.

### 5. Imagen contextual

Si el artículo resuelto posee una imagen de catálogo, la estación la muestra
junto a la identidad. Si no existe o no carga, presenta un placeholder textual
sin bloquear el pesaje. La imagen es ayuda de reconocimiento, nunca autoridad
para elegir artículo, color, cantidad o cierre.

## Sustituciones explícitas

Esta decisión sustituye para el control ordinario:

- la exigencia de `conteo_acumulado_un` de K1/K2;
- el default silencioso `CAMBIO_TURNO`;
- las dos acciones principales separadas de Pesaje descritas en el prototipo
  K2;
- la recomendación anterior de no usar checkbox como selector de intención.

No sustituye el cierre final único, la idempotencia, la tara congelada, el QR
estable, la impresión de control sin QR ni la separación de Kardex.

## Criterios de aceptación

- `DEC-K3-01`: un avance en kg deja manga y tramo activos y admite reescaneo.
- `DEC-K3-02`: el payload, la UI y el sticker de avance no solicitan ni
  presentan conteo.
- `DEC-K3-03`: botón y F2 respetan el checkbox y producen un solo efecto.
- `DEC-K3-04`: después de pesar, el lector recibe foco sin usar mouse.
- `DEC-K3-05`: el cambio entre dos QR anuncia ambos códigos y el actual domina.
- `DEC-K3-06`: una imagen existente aparece; ausencia/error no bloquea.

## Restricción

### Aclaración 2026-09-02 — K4

El checkbox se denomina ahora `Control de peso — la manga continuará abierta`.
No implica relevo de maquinista ni turno. [[US-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]]
añade causas/recuperación de bloqueo y conserva la referencia del último NET
al reescanear. No modifica las fronteras históricas en unidades de K1/K2.
La decisión integral pendiente está en [[Feedback_Pesaje_y_Cierre_Kg_sin_Conteo]].

La decisión autoriza implementación local y QA. Por involucrar balanza,
lector, impresión y una acción difícil de revertir, permanece
`no_habilitar_en_planta` hasta UAT física y observación con trabajador
representativo.
