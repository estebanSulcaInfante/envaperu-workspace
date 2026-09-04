---
tipo: tech-spec
estado: desplegada-provisional-pendiente-uat
spec_phase: tech_spec
delivery_state: deployed
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
historia: "[[US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
tags: [scm, pesaje, manga, relevo, impresion, qr, postgres, estacion, tdd]
relaciones:
  - "[[TS-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
  - "[[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final]]"
  - "[[TS-010M3_Relevos_en_Trabajo_Color]]"
  - "[[PROTO_US-010K2_Relevo_Multijornada_y_Stickers_de_Peso]]"
  - "[[DEV-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
fecha_creacion: 2026-08-29
fecha_actualizacion: 2026-09-01
---

# TS-010K2: relevo multijornada, QR único y stickers de control

> [!important] Alcance sustituido parcialmente por K3
> Desde K3, el control ordinario de la estación es `AVANCE_KG`: no recibe
> conteo, no cierra el tramo y no deja la manga en `CONTINUIDAD_PENDIENTE`.
> Las secciones de esta especificación que abren un relevo desde un control
> describen exclusivamente el flujo histórico `CORTE_TURNO`, no una capacidad
> accesible desde la UI ordinaria vigente. Véase
> [[TS-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]].

## 1. Objetivo y baseline

Evolucionar K1 para que una manga física mantenga un único QR desde la
preetiqueta hasta el cierre, pueda cambiar de responsable dentro de una misma
OT y produzca un sticker legible por cada control aceptado. Los controles
siguen sin acreditar unidades, inventario ni Kardex; F2 continúa siendo el
único final.

Baseline comprobado:

- K1 ya persiste `scm_tramo_manga_trabajo` y
  `scm_control_peso_manga`, cierra el tramo al controlar y soporta continuidad
  hacia una OT posterior;
- el control responde hoy `print_job_id: null`;
- M3 bloquea una manga abierta dentro de la misma OT;
- PREPESAJE y POSTPESAJE crean artefactos `scm_etiqueta_manga` y trabajos
  `scm_trabajo_impresion_manga`;
- el renderer TSPL actual siempre espera un QR;
- el comando TSPL ya termina el último `PRINT 1,1` con `CRLF`, cubierto para
  una y dos copias.

## 2. Porción vertical K2

1. Pesaje registra un control acumulado estable.
2. Central calcula el aporte comparable, persiste el control y crea un trabajo
   inmutable `CONTROL_PESO_TSPL_1` en la misma transacción.
3. La estación reclama, renderiza e imprime el sticker sin QR y acusa el
   resultado sin repetir el control.
4. Desde Central, un supervisor puede seleccionar la misma manga controlada,
   elegir al responsable entrante y registrar un relevo en la misma OT.
5. El servicio abre un nuevo tramo sobre el mismo Trabajo, asignación de plan,
   manga y QR, y reactiva el Trabajo para continuar.
6. El procedimiento se puede repetir; K1 sigue cubriendo el salto posterior a
   otra OT compatible.
7. F2 imprime una etiqueta final sin QR con neto final y aporte del último
   tramo, y acredita una sola vez.

No se incluye habilitación operativa regular en planta, activación por familia
“orrines”, offline autoritativo, trasvase ni conciliación automática de tara
cambiada. El despliegue técnico controlado posterior se registra en
[[../../10_Flujos_y_Procesos/REC_2026-08-29_Despliegue_F3_K2_Central_y_Estacion_Pilot13]].

## 3. Persistencia y migración

Migración aditiva posterior a `f88c3e5a7b42`:

- ampliar `ck_scm_etiqueta_manga_tipo` con `CONTROL_PESO`;
- agregar a `scm_control_peso_manga`:
  - `aporte_desde_control_anterior_kg NUMERIC(15,3) NOT NULL`;
  - `etiqueta_id INTEGER NULL UNIQUE` con FK restrictiva a
    `scm_etiqueta_manga.id`;
- sembrar `MANGA_REASIGNAR_MAQUINISTA` para Supervisor, Jefe de Producción y
  Gerente General.

`ScmEtiquetaManga` sigue siendo un artefacto versionado de impresión; para
`CONTROL_PESO` su `public_id` es técnico y nunca se codifica físicamente. La
versión del control es secuencial por manga y tipo. La relación explícita desde
el control permite auditar y reintentar el trabajo sin buscar dentro de JSON.

Los controles K1 existentes se rellenan con
`aporte_desde_control_anterior_kg = peso_neto_kg` únicamente para migración
compatible; la UI indica que los hechos previos no fueron impresos por K2.

## 4. Cálculo y comparabilidad

Central bloquea manga, tramo y último control. Para el control `n`:

```text
neto_n = bruto_n - tara_n
aporte_n = neto_n - neto_(n-1)
neto_0 = 0
```

El aporte se acepta solo cuando `tara_kg` y `tara_fuente` coinciden con el
control anterior. Una diferencia responde `CONTROL_TARE_NOT_COMPARABLE` y no
crea control ni impresión. El neto y conteo deben avanzar; los acumulados no se
suman en proyecciones.

Al final:

```text
aporte_ultimo_tramo = neto_final - neto_ultimo_control
```

Si no hubo control, el aporte final es el neto final. El peso estándar según
unidades permanece como cálculo separado y no se llama `KG OT`.

## 5. Contratos Central–estación

### 5.1. Control

Se conserva `POST /integration/v1/manga-weighing-controls` y su idempotencia.
La respuesta cambia de manera compatible:

```json
{
  "control": {
    "peso_neto_kg": "8.950",
    "aporte_desde_control_anterior_kg": "4.150"
  },
  "produccion_confirmada_un": "0",
  "inventario_creado": false,
  "print_job_id": "<UUID>",
  "print_template_version": "CONTROL_PESO_TSPL_1",
  "qr_preservado": true,
  "continuidad_estado": "PENDIENTE_RELEVO"
}
```

El payload de la etiqueta contiene identidad textual de manga, artículo/WIP,
color, responsable/tramo, conteo, neto, aporte, fecha y el marcador
`qr_required: false`. No contiene `qr`, otro `label_id` operativo ni datos
codificables.

La estación local conserva `POST /api/local/v1/scm/weighing/controls`, y tras
la respuesta central ejecuta el mismo flujo claim/render/ack del final. Devuelve
`print_result` o un error reintentable asociado al `print_job_id`; nunca vuelve
a enviar el control para reimprimir.

### 5.2. Trabajos de impresión

Los endpoints genéricos de claim/get/ack admiten `CONTROL_PESO`. La bandeja de
Central acepta filtro `CONTROL_PESO`; la bandeja espontánea de estación puede
mostrar PREPESAJE y CONTROL_PESO pendientes de esa estación. Acusar una
etiqueta `CONTROL_PESO` no cambia el estado productivo de la manga.

Estados físicos conservados:

- `IMPRESA` completa el trabajo;
- `FALLIDA_SIN_EMISION` permite repetir el mismo trabajo;
- `EMISION_INCIERTA` bloquea reimpresión a ciegas y requiere conciliación.

### 5.3. Renderer

- PREPESAJE mantiene QR y plantilla vigente.
- CONTROL usa `CONTROL_PESO_TSPL_1`, sin QR, neto dominante y aporte
  secundario.
- POSTPESAJE evoluciona a `POSTPESAJE_TSPL_5`, sin QR, neto final dominante y
  aporte del último tramo.
- fecha/hora operativa y maquinista del tramo de cierre se muestran bajo la
  identidad de manga; no se reutiliza el maquinista de origen cuando hubo
  continuidad.
- `PESO FABRICADO TEÓRICO (kg)` aparece inmediatamente bajo el neto. Para una
  salida simple usa `kg_produccion_ot`; para WIP concurrente suma únicamente
  consumos con procedencia `PRODUCIDO_OT_ACTUAL` por su peso unitario congelado
  y excluye componentes `CONSUMIDO_STOCK_PREVIO`. El neto continúa representando
  el WIP físico total. Si no existe atribución demostrable, la fila se omite.
- rótulos visibles de control: `PESO NETO REAL (kg)` y
  `APORTE DESDE CONTROL ANTERIOR (kg)`.
- ninguna plantilla nueva imprime `KG FIS.`, `KG OT` ni `Producción OT`.
- el último `PRINT 1,1` conserva `CRLF` para una y dos copias.

La cantidad mostrada debe distinguir su fuente. En fabricación normal F2 no
recibe conteo: Central copia `cantidad_asignada_un`, por lo que el sticker no
debe llamarla `CONTEO FINAL`; corresponde `CANTIDAD PLANIFICADA` o `CONTEO
TEÓRICO`. En cierre parcial supervisado o después del cierre de Armado sí puede
mostrarse `CONTEO CONFIRMADO`. Ninguno se recalcula desde el peso real en este
incremento: una futura fila `CONTEO ESTIMADO POR PESO ≈` debe definir peso
unitario físico del conjunto, redondeo y tolerancias, y permanecer separada de
la cantidad que acredita producción e inventario.

## 6. Relevo dentro de la misma OT

Se amplía el contrato existente de asignación/relevo del Trabajo, sin crear
otra manga ni endpoint físico de pesaje. El payload incluye:

```json
{
  "maquinista_id": 5,
  "motivo": "SALIDA_ANTICIPADA",
  "manga_abierta": true,
  "manga_ids": ["<UUID_MANGA>"]
}
```

Bajo locks de Trabajo, asignación, manga, tramo y control, el servicio valida:

- capacidad `MANGA_REASIGNAR_MAQUINISTA`;
- Trabajo de la manga igual al Trabajo solicitado;
- manga `CONTINUIDAD_PENDIENTE`, sin final y con último tramo cerrado por un
  control vigente;
- responsable entrante distinto y habilitado;
- conteo de frontera menor que el objetivo;
- ninguna continuidad hacia otra OT ya programada.

En una sola transacción:

- cierra la asignación personal saliente si todavía está activa;
- crea la asignación personal entrante;
- abre el tramo siguiente desde el último `conteo_acumulado_un`, reutilizando
  `trabajo_ot_id` y `asignacion_plan_id`;
- deja el Trabajo `EN_EJECUCION`, la manga `EN_LLENADO` y aumenta versiones;
- crea cero mangas, cero preetiquetas, cero créditos y cero trabajos de
  impresión adicionales.

Un replay de la misma operación devuelve el mismo resultado. Si la manga ya
se vinculó o finalizó, responde estado recuperable y no abre dos tramos.

## 7. UI operativa

### Estación

- acción primaria: `Registrar control — continúa abierta`;
- antes de confirmar distingue `CONTROL` de `FINAL`;
- éxito separado: `Control guardado` y `Sticker impreso`;
- si imprime mal, presenta `Reintentar este mismo sticker`, sin volver a pesar;
- muestra `PESO NETO REAL (kg)` y aporte; elimina “sin impresión”.

### Central

- cuando el control deja `CONTINUIDAD_PENDIENTE`, presenta
  `Registrar relevo — continúa incompleta`;
- muestra manga, último control y saliente como solo lectura;
- solicita entrante y motivo;
- misma OT abre el siguiente tramo; OT posterior deriva al flujo K1;
- al éxito confirma `Misma manga y QR · nuevo responsable`.

La UI conserva estados de espera, listo, guardando, éxito, fallo, emisión
incierta y Central offline descritos en el prototipo. La evidencia visual y
observación de trabajadores siguen pendientes.

## 8. Seguridad, concurrencia y errores

| Error | Condición |
|---|---|
| `CONTROL_TARE_NOT_COMPARABLE` | Tara o fuente difiere del control anterior. |
| `CONTROL_WEIGHT_NOT_MONOTONIC` | Neto acumulado no avanza. |
| `OPEN_MANGA_RELIEF_NOT_READY` | No existe control/frontera vigente. |
| `OPEN_MANGA_RELIEF_INCOMPATIBLE` | Manga o Trabajo no coincide con la misma OT. |
| `MANGA_ALREADY_FINALIZED` | F2 ya creó el final único. |
| `PRINT_JOB_ALREADY_PROCESSED` | Se intenta reclamar un trabajo terminado. |
| `IDEMPOTENCY_CONFLICT` | Misma clave con payload distinto. |

La creación de control, etiqueta y trabajo es atómica. El envío físico ocurre
después del commit. Dos controles, dos relevos o control/F2 concurrentes se
serializan por la manga; solo un cambio puede ganar.

## 9. Mapa ATDD

| Historia | Prueba obligatoria |
|---|---|
| K2-01/K2-10 | contrato: PREPESAJE es único QR; CONTROL/FINAL no contienen QR |
| K2-02/K2-08 | integración: control crea un job; replay/reintento no duplica |
| K2-03/K2-12 | renderer TSPL/SVG: jerarquía, textos, sin QR y CRLF |
| K2-04/K2-07 | servicio: aporte `4.150`; tara distinta revierte todo |
| K2-05 | integración Central: mismo Trabajo/manga/QR, nuevo tramo/responsable |
| K2-06 | regresión K1: continuidad a OT posterior y varios controles |
| K2-09 | ack: fallido reintentable e incierto sin transición productiva |
| K2-11 | contrato: estándar técnico separado de neto/aporte |

## 10. Migración, liberación y rollback

1. [x] Aplicar Central y contrato antes de estación.
2. [x] Publicar `1.2.0-pilot.13` para validación controlada y ejecutar preflight.
3. [ ] Validar render 109 × 50 mm, impresión 2-up y superposición física.
4. [ ] Ejecutar UAT con maquinista, supervisor y operador de Pesaje.
5. Solo una aprobación humana posterior puede retirar
   `no_habilitar_en_planta`.

Rollback de aplicación deja los controles y artefactos legibles; no borra ni
reabre mangas. Una estación anterior no debe recibir trabajos de las plantillas
nuevas hasta tener renderer compatible.

## 11. Definition of Done

- [x] K2-01…K2-12 verdes en sus niveles automáticos asignados.
- [x] Upgrade PostgreSQL real y upgrade/downgrade automatizado verificados.
- [x] Un control crea exactamente un trabajo y cero crédito/inventario.
- [x] Relevo misma OT abre un solo tramo y conserva manga/QR.
- [x] Control y final se renderizan sin QR y con fuente dominante del neto.
- [x] Fallo/replay no repite control ni trabajo lógico.
- [x] Regresión K1, F2, recepción y preetiqueta verde.
- [ ] Evidencia visual en viewport y etiqueta física registrada.
- [ ] UAT física aprobada antes de habilitar en planta.

## 12. Resultado de implementación, despliegue y verificación

- [x] K2-01..K2-12 verdes en pruebas focalizadas de Central y estación.
- [x] Migración aplicada en PostgreSQL productivo; upgrade/downgrade
      automatizado comprobado y cabeza conjunta única `f92c7d9e1f86`.
- [x] Control crea un job y cero crédito/Kardex; replay no duplica.
- [x] Relevo misma OT conserva manga/QR y abre un solo tramo.
- [x] CONTROL y FINAL se renderizan sin QR; PREPESAJE conserva la identidad.
- [x] SVG/TSPL 2-up inspeccionado; el último `PRINT 1,1` conserva CRLF.
- [x] UAT preparada en
      [[UAT_US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]].
- [ ] Impresión real, superposición, lectura del QR y observación humana.
- [x] Central y estación `1.2.0-pilot.13` desplegados para validación
      controlada; sin habilitación regular en planta.

La regresión global de frontend, estación y contratos está verde. En el corte
local inicial, backend alcanzó `470 passed` y un fallo ajeno a K2 en apertura
de inventario; el candidato aislado posterior resolvió esa interferencia y
cerró con `468 passed`, `2 skipped` y `26 deselected`, además de las pruebas
focales K2 verdes.
