---
tipo: tech-spec
estado: implementada-local-qa-green
spec_phase: tech_spec
delivery_state: review
functional_validation: qa_green
ux_validation: rejected
physical_uat: pending
release_constraint: no_habilitar_en_planta
historia: "[[US-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
fecha_creacion: 2026-08-31
fecha_actualizacion: 2026-09-03
tags: [scm, pesaje, avance-kg, postgres, estacion, ui, tdd]
relaciones:
  - "[[2026-08-31_Control_Avance_en_Kg_sin_Conteo_y_Accion_Unica_Pesaje]]"
  - "[[TS-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
  - "[[PROTO_US-010K3_Pesaje_Unico_y_Contexto_Visible]]"
  - "[[DEV-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
  - "[[UAT_US-010K3_Control_Avance_Kg_y_Contexto_Visible]]"
  - "[[TS-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
---

# TS-010K3: control de avance en kg y contexto visible en estación

## 1. Objetivo y baseline

Corregir la colisión entre un control ordinario y un corte de turno. El
baseline tiene un único tipo `CORTE_TURNO`, exige conteo, restringe un control
por tramo, cierra el tramo, pausa el Trabajo y deja
`CONTINUIDAD_PENDIENTE`. La estación presentaba un botón separado y su texto
afirma incorrectamente que la manga continúa abierta.

K3 añade `AVANCE_KG`, repetible en el mismo tramo y sin conteo, y reconstruye
la interacción en una sola acción de Pesaje.

## 2. Contrato de dominio

### `ScmControlPesoManga`

- `tipo IN ('CORTE_TURNO', 'AVANCE_KG')`;
- `conteo_acumulado_un` pasa a nullable;
- check condicional: `CORTE_TURNO` exige conteo positivo;
  `AVANCE_KG` exige conteo nulo;
- se elimina la unicidad de `tramo_id`; persisten unicidades por
  `operation_id`, `(source_system,capture_id)` y `etiqueta_id`;
- relación tramo-control pasa de `1:0..1` a `1:0..N`;
- `segment.control_peso` continúa proyectando únicamente el último
  `CORTE_TURNO` para compatibilidad K1/K2;
- `manga.controles_peso` conserva todos los hechos ordenados.

### Transición `AVANCE_KG`

- crea/usa un tramo `ACTIVO` del Trabajo vigente;
- valida lectura estable, tara, límite físico, monotonicidad y comparabilidad;
- persiste control+etiqueta+job atómicamente;
- deja manga `EN_LLENADO`, tramo `ACTIVO` y Trabajo sin pausa/cierre;
- responde `continuidad_estado: ACTIVA` y capacidades para otro avance o
  final;
- no cambia cantidades confirmadas ni atribuciones de unidades.

`CORTE_TURNO` conserva su comportamiento previo para replay/histórico, pero no
es la acción ordinaria de la estación K3.

## 3. Contrato API Central–estación

`POST /integration/v1/manga-weighing-controls` admite de forma aditiva:

```json
{
  "label_id": "uuid",
  "capture_id": "uuid",
  "control_type": "AVANCE_KG",
  "peso_bruto_kg": "7.630",
  "tara_kg": "0.030",
  "tara_fuente": "TIPO_MANGA",
  "pesada_at": "2026-08-31T20:30:00Z",
  "pesado_por_id": 12,
  "reading_stable": true
}
```

No envía `conteo_acumulado_un` ni motivo digitado. Central fija el motivo
auditable `MANGA_INCOMPLETA`.

La resolución de QR agrega:

```json
{
  "can_register_weight_control": true,
  "manga": {
    "imagen_path": "/api/piezas-color/PC-000123/imagen"
  }
}
```

La manga resuelta expone además la identidad humana de color ya utilizada por
OF/OT, sin que la estación infiera colores desde nombres:

```json
{
  "manga": {
    "color": "TRANSPARENTE",
    "color_hex": "#EAF7F7",
    "color_identidad": {
      "id": 1,
      "nombre": "TRANSPARENTE",
      "base": {"id": 1, "nombre": "TRANSPARENTE"},
      "familia": {"id": 1, "nombre": "TRANSPARENTE"},
      "hex": "#EAF7F7"
    }
  }
}
```

`familia.nombre` determina la representación cuadriculada de Transparente;
los colores sólidos usan `hex` solo cuando el maestro lo informa. El nombre
permanece visible y accesible. Cuando base y familia son ambas
`TRANSPARENTE`, la proyección de Pesaje evita el rótulo duplicado sin alterar
el snapshot histórico.

`imagen_path` solo existe si el maestro tiene imagen. La estación convierte
únicamente paths `/api/` del origen Central en URL absoluta; no acepta URLs
arbitrarias ni base64.

Se conserva `can_register_shift_cut` por compatibilidad. El cliente K3 decide
por `can_register_weight_control` y envía `control_type=AVANCE_KG`.
La estación anuncia adicionalmente la capacidad
`scm-manga-weight-progress-v2`; mantiene
`scm-manga-weighing-control-v1` para consumidores previos.

## 4. Contrato de interacción

- `incomplete=true` → `recordControl(AVANCE_KG)`;
- `incomplete=false` → `confirm(final)`;
- un handler compartido alimenta botón y F2;
- el botón conserva texto y posición estables; el estado previo explica si
  registrará avance o cierre final;
- intención y cierre parcial son mutuamente excluyentes;
- tras `finally`, el input QR recibe foco sin borrar una operación reintentable;
- después de éxito se limpia el checkbox;
- al resolver QR se limpian resultados/operaciones y se anuncia primer/cambio
  de código mediante `aria-live`;
- `MANGA ACTIVA` usa el código como texto dominante;
- imagen `alt` describe el artículo; `onError` activa fallback no bloqueante.
- la identidad principal reúne artículo y color; la muestra visual nunca
  sustituye el nombre textual;
- Transparente usa patrón CSS cuadriculado en una muestra acotada, no como
  fondo de toda la tarjeta.

## 5. Contrato de presentación

`CONTROL_PESO_TSPL_2`:

- `CONTROL · MANGA CONTINÚA ABIERTA`;
- código de manga, artículo, neto acumulado y aporte;
- responsable y fecha/hora;
- sin QR, conteo, unidades atribuidas ni peso estándar según unidades;
- `PRINT 1,1\r\n` permanece.

El final conserva la cantidad almacenada, pero distingue su procedencia:
`CONTEO TEÓRICO` para el cierre normal que copia la cantidad asignada y
`CONTEO CONFIRMADO` para Armado, cierre parcial supervisado o corrección
autorizada. No se presenta como conteo físico cuando F2 solo recibió kg.

## 5.1. Brecha multijornada confirmada — 2026-09-01

El dominio Central ya puede conservar una única `ScmManga`, su `public_id`,
código de origen y QR al vincularla con una OT posterior compatible mediante
varios `ScmTramoMangaTrabajo`. El código físico `OF…-OT…-M…` identifica el
origen y no se regenera en el relevo; la OT vigente debe leerse desde el último
tramo.

Sin embargo, la estación K3 solo emite `AVANCE_KG`. Ese evento mantiene el
tramo activo y, por diseño, no crea la frontera `CONTINUIDAD_PENDIENTE` que la
UI Central exige para adjuntar la manga a la siguiente OT. Por tanto, el caso
“una manga de orrines durante dos días con cambio de OT” no está completo de
extremo a extremo en la UI vigente, aunque la reutilización de identidad ya
exista en backend.

Resolverlo no es solo volver a mostrar `CORTE_TURNO`: la continuidad actual
abre y cierra tramos con fronteras exactas en unidades. Si el nuevo evento solo
captura kg, no puede inventar `cantidad_fin_un` ni repartir unidades exactas
entre OT/turnos. Se requiere una decisión funcional separada para una frontera
multijornada en kg, con atribución de unidades nullable/no autoritativa y la
misma manga/QR.

## 6. Seguridad, idempotencia y concurrencia

- capacidad `MANGA_CONTROL_PESO_REGISTRAR` sigue obligatoria;
- actor y estación proceden de identidad configurada, no del frontend;
- lock de etiqueta, manga, tramos y último control;
- replay de la misma operación devuelve el mismo control/job;
- dos avances concurrentes serializan y el perdedor recibe conflicto/replay;
- control y final concurrentes producen un único ganador;
- imagen es una ayuda de catálogo pública existente; nunca contiene secretos ni
  determina autorización.

## 7. Migración y rollback

Migración Alembic posterior a `f90a1c3e5b72`:

1. retirar checks/unicidad afectados;
2. permitir nullable en conteo;
3. recrear checks condicionales y conservar índices/unicidades restantes;
4. downgrade bloquea si existen `AVANCE_KG`, para evitar pérdida silenciosa;
   el rollback de aplicación puede convivir con el esquema nuevo.

No se aplica la migración a producción ni se corrigen los tres controles de
prueba sin una autorización posterior explícita.

## 8. Mapa ATDD

| Historia | Prueba |
|---|---|
| K3-01/K3-02 | servicio Central: dos `AVANCE_KG`, mismo tramo activo, sin conteo |
| K3-03/K3-04 | componente estación: handler único, F2 y foco QR |
| K3-05 | componente: anuncio y manga dominante al cambiar QR |
| K3-06 | contrato/resolución + render de imagen/fallback |
| K3-07 | renderer TSPL/SVG sin conteo/estándar/QR |
| K3-08 | integración local/central: replay no duplica control/job |
| K3-09 | contrato/UI: color estructurado, HEX sólido y patrón Transparente |
| Migración | upgrade/downgrade SQLite y PostgreSQL acordado |

## 9. Liberación

Orden técnico futuro: migración+Central, luego estación compatible. Hasta
completar UAT física y decisión de rollback sobre datos reales:

```yaml
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```
