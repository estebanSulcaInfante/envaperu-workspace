---
tipo: tech-spec
estado: en-refinamiento
us: "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, armado, wip, producto-terminado, mangas, genealogia, pesaje, almacen, calidad, api, frontend, atdd, tdd]
relaciones:
  - "[[Orden_Armado]]"
  - "[[Unidad_Logistica]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Tipo_Manga]]"
  - "[[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[2026-07-30_Cierre_Armado_Pesaje_PT_Recepcion_y_Calidad]]"
  - "[[2026-07-30_OT_Diaria_Comun_para_Fabricacion_y_Armado]]"
fecha_creacion: 2026-07-30
fecha_actualizacion: 2026-08-09
---

# TS-010F: Armado, genealogía, mangas PT y cierre de Armado

## 1. Objetivo

Implementar el tramo:

```text
OA liberada
  -> plan de mangas WIP/PT
  -> OT de Armado diaria + cuota
  -> preetiqueta
  -> preparación y asignación de componentes
  -> cierre de manga por Responsable de Armado
  -> pesaje obligatorio
  -> recepción de Almacén
  -> decisión posterior de Calidad
```

La autoridad de la cantidad real y de la genealogía es Armado. La autoridad del
peso físico es Balanza. La autoridad de custodia es Almacén y la autoridad de
disponibilidad es Calidad.

Esta TS sustituye para WIP/PT el comando compuesto que confirmaba armado,
consumos y peso en F2.

## 2. Alcance

Incluye:

- planificar mangas desde una OA y un perfil de empaque aprobado;
- dividir la ejecución de una OA en OT diarias de Armado;
- asignar a cada OT una cuota sin exceder el saldo de la OA;
- reservar identidad de manga sin crear stock;
- solicitar preetiquetas desde Armado;
- enrutar temporalmente la impresión a la estación de pesaje;
- registrar avance provisional opcional;
- asignar componentes exactos, candidatos o legacy contado;
- cerrar la manga con cantidad real confirmada por Armado;
- consumir componentes y acreditar el resultado por manga;
- habilitar el pesaje obligatorio con cantidad read-only;
- exponer genealogía hacia atrás y adelante por QR;
- errores, idempotencia, correcciones y permisos.

No incluye:

- recepción QR y nacimiento de Kardex: US-010I;
- decisión completa de Calidad y muestreo: TS de Calidad pendiente;
- despacho de producto terminado;
- operación offline;
- compra e instalación de impresora dedicada de Armado;
- crear automáticamente un perfil de manga sin datos físicos;
- `PartidaPT` obligatoria.

## 3. Principios e invariantes

1. Una manga PT es la unidad mínima física, inventariable y trazable.
2. Cada manga cerrada posee una sola `ConfirmacionBolsaOperacion`.
3. Cada consumo enlaza esa confirmación y su cantidad incorporada.
4. Cerrar Armado no registra peso ni crea Kardex.
5. Pesar no modifica cantidad, BOM, consumos ni genealogía.
6. Recibir en Almacén exige una manga pesada y crea Calidad `PENDIENTE`.
7. Todas las mangas PT se pesan.
8. El peso nunca determina unidades.
9. Planificar o imprimir no acredita producción.
10. Un replay exacto no duplica consumos, resultado, manga, peso ni impresión.
11. Una manga extra exige motivo y autorización del Jefe de Producción.
12. Exactamente un perfil de empaque aprobado y predeterminado debe resolver
    para el artículo de salida.
13. Un lote/partida PT, si se incorpora después, solo agrupa mangas.
14. Cada manga WIP/PT pertenece exactamente a una OT de Armado.
15. Una OA puede ejecutarse mediante varias OT; una OT nunca mezcla dos OA.
16. La suma activa de cuotas OT no excede el objetivo vigente de la OA salvo
    ampliación autorizada.

## 4. Estados

### 4.1. OA

```text
BORRADOR -> LIBERADA -> EN_EJECUCION -> COMPLETADA -> CERRADA
                \-> ANULADA
```

No puede cerrar con mangas abiertas, consumos pendientes o correcciones sin
resolver.

### 4.2. OT de Armado

```text
PLANIFICADA -> INICIADA -> PAUSADA -> INICIADA -> CERRADA
         \-> ANULADA
```

No puede cerrar con mangas abiertas o trabajos de impresión/confirmación sin
resolver.

### 4.3. Manga WIP/PT

```text
PLANIFICADA
  -> PREETIQUETADA
  -> EN_ARMADO
  -> CERRADA_ARMADO_PENDIENTE_PESAJE
  -> PESADA
  -> ETIQUETADA_FINAL
  -> PENDIENTE_RECEPCION_ALMACEN
  -> RECIBIDA_PENDIENTE_CALIDAD
  -> DISPONIBLE | BLOQUEADA | RECHAZADA
```

Transiciones laterales:

- antes del cierre: `ANULADA`;
- fallo funcional/técnico no conciliable: `CONCILIACION`;
- reapertura física autorizada: nueva versión, nunca edición destructiva.

### 4.4. Etiqueta

```text
GENERADA -> ENVIADA -> IMPRESA
                    \-> FALLIDA_SIN_EMISION
                    \-> EMISION_INCIERTA
         \-> INVALIDADA
```

Una emisión incierta exige reemplazo autorizado. El reemplazo crea otro
`label_id` para la misma manga.

## 5. Modelo de datos

### 5.1. `scm_orden_trabajo`

Cabecera común definida en [[Registro_Diario]]:

| Campo | Regla |
|---|---|
| `id`, `codigo_ot` | UUID y `OT-######` global. |
| `tipo_ot` | `ENSAMBLE`. |
| `orden_operacion_id` | OA exacta. |
| `fecha_operativa`, `turno_id` | Jornada autoritativa. |
| `centro_trabajo_id` | Celda, mesa o área de Armado. |
| `responsable_id` | Responsable de Armado obligatorio. |
| `cantidad_objetivo` | Cuota diaria positiva. |
| `cantidad_confirmada` | Proyección de sus mangas cerradas. |
| `estado`, `version`, auditoría | Gobierno y concurrencia. |

### 5.2. `scm_ot_armado`

| Campo | Regla |
|---|---|
| `orden_trabajo_id` | PK/FK 1:1; `tipo_ot=ENSAMBLE`. |
| `orden_armado_id` | OA exacta; no cambia después de iniciar. |
| `trabajo_color_contexto_id` | Obligatorio en ejecución concurrente; identifica el Trabajo de color exacto. |
| `ot_fabricacion_contexto_id` | Cabecera derivada/conservada para consulta; no sustituye el Trabajo de color cuando una OT contiene varios. |
| `modo_ejecucion` | `ESTACION_DEDICADA` o `CONCURRENTE_ENTRE_CICLOS`. |
| `equipo_version` | Control de cambios de participantes. |

`scm_ot_armado_participante` relaciona N:M trabajadores, rol contextual y
vigencia. El responsable permanece en la cabecera.

### 5.3. `scm_plan_manga_operacion`

| Campo | Regla |
|---|---|
| `id` | UUID PK central. |
| `orden_armado_id` | OA liberada. |
| `articulo_salida_id` | WIP o PT. |
| `perfil_empaque_revision_id` | Aprobado y congelado. |
| `cantidad_objetivo` | Positiva. |
| `capacidad_unidades` | Snapshot positivo. |
| `cantidad_mangas_normal` | `ceil(objetivo / capacidad)`. |
| `version` | Optimistic locking. |
| `created_by_id`, timestamps | Auditoría. |

El plan es agregado de la OA y no imprime por sí solo todas sus mangas.

### 5.4. `scm_asignacion_plan_manga_ot`

| Campo | Regla |
|---|---|
| `plan_manga_operacion_id` | Plan agregado de OA. |
| `orden_trabajo_id` | OT de Armado. |
| `cantidad_asignada` | Cuota positiva de la jornada. |
| `cantidad_mangas_normal` | Derivada del perfil y cuota. |
| `operation_id`, `version` | Idempotencia y concurrencia. |

La suma de asignaciones activas no excede el objetivo del plan.

### 5.5. Extensión de `scm_manga`

| Campo | Regla |
|---|---|
| `orden_armado_id` | Obligatorio en WIP/PT. |
| `orden_trabajo_id` | OT de Armado obligatoria. |
| `articulo_salida_id` | Contenido principal. |
| `confirmacion_operacion_id` | Nulo hasta cerrar Armado; unique al existir. |
| `cantidad_planificada` | Snapshot; nunca se sobrescribe. |
| `cantidad_confirmada` | Nula hasta cerrar; real positiva. |
| `cantidad_confirmada_por_id/at` | Responsable de Armado. |
| `diferencia_cantidad`, `motivo_diferencia_id/texto` | Auditables. |
| `estado_manga` | Máquina de estados anterior. |
| `estado_calidad` | Nulo antes de recepción; luego `PENDIENTE` o decisión. |
| `partida_pt_id` | Nullable; no participa de invariantes operativas. |

El código visible usa `OA{n}-OT{n}-M{n}`. La secuencia se asigna dentro de la
OT, pero la unicidad real es el UUID de manga.

### 5.6. `scm_confirmacion_bolsa_operacion`

| Campo | Regla |
|---|---|
| `id` | UUID PK. |
| `manga_id` | Unique, FK bloqueada. |
| `orden_armado_id` | FK. |
| `orden_trabajo_id` | OT diaria a la que se acredita la cantidad. |
| `articulo_salida_id` | Igual al snapshot de manga. |
| `cantidad_planificada` | Snapshot. |
| `cantidad_provisional_corte` | `>= 0`. |
| `cantidad_real_confirmada` | `> 0`. |
| `provisional_cutoff_seq` | Corte idempotente. |
| `estructura_revision_id/hash` | BOM congelada. |
| `operation_id`, `payload_hash` | Idempotencia. |
| `confirmado_por_id/at` | Responsable de Armado. |

No contiene bruto, tara ni neto.

### 5.7. `scm_consumo_componente_operacion`

| Campo | Regla |
|---|---|
| `confirmacion_id` | Resultado de manga exacto. |
| `articulo_componente_id` | Línea BOM congelada. |
| `cantidad_incorporada` | `cantidad_real * cantidad_por_salida`. |
| `cantidad_merma` | Separada de lo incorporado. |
| `nivel_genealogia` | `EXACTA`, `CONJUNTO_CANDIDATOS`, `LEGACY_SIN_ORIGEN`. |
| `base_peso_tipo/valor/referencia/version` | Atribución estándar auditable. |
| `line_key`, `effect_id` | Únicos y determinísticos. |

### 5.8. `scm_asignacion_origen_consumo`

Para `EXACTA`, registra unidad/lote de origen y cantidad. Su suma coincide con
`cantidad_incorporada + cantidad_merma` aplicable.

Para `CONJUNTO_CANDIDATOS`, la confirmación debita un pool contado y una tabla
N:M registra todos los candidatos sin inventar reparto.

`LEGACY_SIN_ORIGEN` referencia una apertura contada, actor y motivo.

### 5.9. `scm_trabajo_impresion`

| Campo | Regla |
|---|---|
| `id` | UUID PK. |
| `tipo` | `PREENSAMBLE` o `FINAL_PT`. |
| `origen_modulo` | `ARMADO` o `PESAJE`. |
| `destino_estacion_id` | Impresora/estación configurada. |
| `label_id` | Versión concreta. |
| `estado` | Estado de etiqueta/trabajo. |
| `requested_by_id/at` | Actor solicitante. |
| `printed_by_station_id/at` | Evidencia física. |
| `operation_id`, `payload_hash` | Idempotencia. |

## 6. Comando `CERRAR_MANGA_ARMADO`

### 6.1. Request

```json
{
  "operation_id": "uuid",
  "version_manga": 3,
  "cantidad_real_confirmada": "98",
  "provisional_cutoff_seq": 12,
  "motivo_diferencia_id": "FALTANTE_COMPONENTE",
  "consumos": [
    {
      "articulo_componente_id": "uuid",
      "cantidad_incorporada": "98",
      "cantidad_merma": "0",
      "nivel_genealogia": "EXACTA",
      "origenes": [
        {"unidad_logistica_id": "uuid", "cantidad": "98"}
      ]
    }
  ]
}
```

El actor se obtiene de la sesión; no se confía en un `actor_id` del payload.

### 6.2. Transacción

1. Resolver idempotencia y bloquear manga, OT, OA, reservas y saldos de origen.
2. Validar estado/versiones, actor, capacidad y cuota de la OT.
3. Validar la BOM congelada y la ecuación de cantidades.
4. Validar Calidad y disponibilidad de cada origen.
5. Conciliar avances hasta el corte.
6. Debitar reservas/saldos y registrar consumos.
7. Acreditar la confirmación de salida.
8. Actualizar las proyecciones confirmadas de OT y OA.
9. Registrar diferencia y motivo.
10. Cambiar manga a `CERRADA_ARMADO_PENDIENTE_PESAJE`.
11. Emitir evento y guardar respuesta idempotente.

Si cualquier paso falla, no queda consumo ni salida parcial.

### 6.3. Errores estables

- `MANGA_NOT_READY_FOR_ASSEMBLY_CLOSE`
- `ASSEMBLY_QUANTITY_REQUIRED`
- `ASSEMBLY_QUANTITY_EXCEEDS_AUTHORIZATION`
- `BOM_QUANTITY_MISMATCH`
- `COMPONENT_RESERVATION_MISSING`
- `COMPONENT_STOCK_INSUFFICIENT`
- `COMPONENT_QUALITY_NOT_RELEASED`
- `ORIGIN_ASSIGNMENT_MISMATCH`
- `PACKAGING_PROFILE_NOT_RESOLVED`
- `WORK_ORDER_NOT_READY`
- `WORK_ORDER_QUOTA_EXCEEDED`
- `VERSION_CONFLICT`
- `IDEMPOTENCY_CONFLICT`

## 7. Adaptación de pesaje

Resolver el QR de una manga WIP/PT devuelve:

```json
{
  "ui_mode": "PRODUCTO_TERMINADO",
  "estado": "CERRADA_ARMADO_PENDIENTE_PESAJE",
  "cantidad_confirmada": "98",
  "cantidad_fuente": "RESPONSABLE_ARMADO",
  "cantidad_editable": false,
  "weighing_required": true
}
```

`CONFIRMAR_PESAJE_MANGA` solo acepta ese estado, registra peso y conserva
`confirmacion_operacion_id`. No crea consumos ni altera cantidad.

## 8. API humana

| Método y ruta | Capacidad |
|---|---|
| `GET /api/scm/v1/ordenes-armado` | `ENSAMBLE_VER` |
| `GET /api/scm/v1/ordenes-armado/{id}` | `ENSAMBLE_VER` |
| `POST /api/scm/v1/ordenes-armado/{id}/plan-mangas` | `ENSAMBLE_PLANIFICAR` |
| `POST /api/scm/v1/ordenes-armado/{id}/ordenes-trabajo` | `OT_ENSAMBLE_CREAR` |
| `GET /api/scm/v1/ordenes-armado/{id}/ordenes-trabajo` | `OT_VER` |
| `POST /api/scm/v1/ordenes-trabajo/{id}/iniciar` | `OT_INICIAR` |
| `POST /api/scm/v1/ordenes-trabajo/{id}/asignar-plan-mangas` | `OT_ENSAMBLE_PLAN_ASIGNAR` |
| `POST /api/scm/v1/ordenes-trabajo/{id}/cerrar` | `OT_CERRAR` |
| `POST /api/scm/v1/mangas/{id}/preetiquetas` | `ENSAMBLE_PREETIQUETA_SOLICITAR` |
| `POST /api/scm/v1/mangas/{id}/avances` | `ENSAMBLE_AVANCE_REGISTRAR` |
| `POST /api/scm/v1/mangas/{id}/cerrar-armado` | `ENSAMBLE_MANGA_CERRAR` |
| `GET /api/scm/v1/mangas/{id}/genealogia` | `GENEALOGIA_VER` |
| `POST /api/scm/v1/mangas/{id}/correcciones-cantidad` | `ENSAMBLE_CORREGIR_SOLICITAR` |
| `POST /api/scm/v1/correcciones-armado/{id}/aprobar` | `ENSAMBLE_CORREGIR_APROBAR` |

## 9. API de impresión

| Método y ruta | Uso |
|---|---|
| `GET /api/integration/v1/print-jobs?station_id=...&state=PENDING` | La estación obtiene trabajos dirigidos. |
| `POST /api/integration/v1/print-jobs/{id}/claim` | Reclamo exclusivo con lease. |
| `GET /api/integration/v1/print-jobs/{id}/payload` | TSPL y metadatos versionados. |
| `PUT /api/integration/v1/print-jobs/{id}/result` | `SUCCEEDED`, `FAILED` o `UNCERTAIN`. |

La cola no transporta autoridad para editar la OA o la manga.

## 10. UX por actor

### Planificación / Jefe de Producción

- objetivo OA, capacidad, número de mangas y saldo por plan;
- distribución por fecha, turno, centro y OT;
- bloqueo claro cuando falta perfil de empaque;
- extras separados, con motivo y autorización;
- estado agregado: por imprimir, en armado, cerradas, por pesar y recibidas.

### Responsable de Armado

- pantalla de trabajo, no de administración;
- entrada “Mi jornada de Armado” con la OT vigente;
- OA, cuota diaria y saldo de jornada visibles;
- escaneo/búsqueda de manga;
- cantidad planificada y progreso visibles;
- componentes requeridos y asignados;
- conteo real editable y responsable explícito;
- resumen antes de cerrar: “se consumirán X y se acreditarán Y”;
- confirmación bloqueada con errores accionables por campo.

### Operador de Balanza

- QR, PT, OA, cantidad real y responsable como solo lectura;
- solo peso y estabilidad como tarea;
- mensaje claro si Armado todavía no cerró la manga.

### Almacén y Calidad

- Almacén recibe solo mangas pesadas;
- Calidad trabaja sobre mangas ya recibidas;
- disponibilidad y ubicación se muestran como dimensiones separadas.

## 11. Preetiqueta y etiqueta final

### PREENSAMBLE

- QR y código de manga;
- OA;
- OT y fecha operativa;
- PT/WIP;
- presentación o color cuando aplique;
- cantidad planificada/capacidad;
- número de manga;
- fecha planificada;
- responsable/equipo previsto;
- `NORMAL` o `EXTRA`.

No imprime cantidad real, peso, estado de Calidad ni ubicación.

### FINAL_PT

- misma identidad de manga;
- OA, OT y fecha operativa;
- cantidad real y responsable de Armado;
- fecha/hora de cierre;
- bruto, tara y neto;
- fecha/hora de pesaje;
- `NORMAL` o `EXTRA`;
- QR de la versión vigente.

Calidad y ubicación se consultan en línea; no se congelan como “liberado” antes
de la recepción.

## 12. Correcciones

- Cantidad/BOM: evento compensatorio de Armado. Si la manga ya fue recibida,
  exige coordinación con Inventario y Calidad.
- Peso: corrección o repesaje de TS-010D; no altera consumos.
- Etiqueta: reemplazo autorizado; invalida versión anterior.
- Reapertura física: comando distinto con custodia controlada.

No existe edición directa de una confirmación aplicada.

## 13. Pruebas

### Primera prueba RED

`test_cerrar_manga_armado_acredita_resultado_sin_crear_pesaje_ni_kardex`

- OA liberada, manga preetiquetada y componentes reservados;
- OT de Armado iniciada con cuota suficiente;
- cerrar 98 unidades;
- existen confirmación, consumos y genealogía;
- no existe pesaje ni movimiento de Kardex;
- estado `CERRADA_ARMADO_PENDIENTE_PESAJE`.

Debe fallar antes de implementar porque el corte actual acredita armado desde
el comando de pesaje.

### Mapeo ATDD mínimo

| Escenario | Nivel |
|---|---|
| ASM-01, 04, 05, 06, 19, 20, 21 | Integración PostgreSQL de genealogía y saldos. |
| ASM-07, 13, 14, 16, 18 | Integración de idempotencia, locks y rollback. |
| ASM-08, 22 | Integración de compensaciones. |
| ASM-12, 23, 24 | Servicio + UI de Armado. |
| ASM-25 | Contrato US-010I. |
| ASM-26 | Contrato central–estación e impresión simulada. |
| ASM-27 | Contrato US-010I/Calidad. |

### Propiedades

- `cantidad_incorporada = cantidad_real * cantidad_bom`;
- suma exacta de orígenes = consumo total;
- replay no cambia saldos;
- peso no cambia cantidad;
- manga PT no puede recibirse sin pesaje;
- Calidad pendiente no participa del saldo libre.
- suma de cuotas OT activas no excede el objetivo OA;
- una manga no puede cambiar de OT después de imprimirse.

## 14. Migración y compatibilidad

1. Añadir estados y tablas sin reinterpretar pesajes legacy.
2. Mantener lectura del comando compuesto previo solo para datos de prueba
   existentes; no usarlo para nuevas mangas WIP/PT.
3. Backfill de mocks locales como `LEGACY_NO_CONCILIADO` o eliminarlos cuando
   sean explícitamente descartables.
4. No crear `PartidaPT` durante el backfill.
5. Crear perfiles de manga reales antes de la primera OA productiva.
6. Crear la cabecera `scm_orden_trabajo`, enlazar OT de Fabricación actuales y
   añadir `scm_ot_armado` sin reinterpretar pesajes legacy.

## 15. Observabilidad

Eventos:

- `ASSEMBLY_BAG_PLANNED`
- `ASSEMBLY_WORK_ORDER_CREATED`
- `ASSEMBLY_WORK_ORDER_STARTED`
- `ASSEMBLY_WORK_ORDER_CLOSED`
- `PREASSEMBLY_LABEL_REQUESTED`
- `ASSEMBLY_BAG_CLOSED`
- `ASSEMBLY_CLOSE_REPLAYED`
- `ASSEMBLY_BAG_WAITING_WEIGHING`
- `PT_BAG_WEIGHED`
- `PT_BAG_RECEIVED_PENDING_QUALITY`
- `PT_BAG_QUALITY_DECIDED`

Métricas:

- mangas por estado y antigüedad;
- OA por número de OT, fecha, turno, equipo y productividad diaria;
- tiempo cierre Armado → pesaje;
- tiempo pesaje → recepción;
- diferencias plan vs real;
- genealogía exacta/candidata/legacy;
- trabajos de impresión fallidos o inciertos;
- mangas recibidas pendientes de Calidad.

## 16. Puerta para aprobación

- [x] Actor que confirma cantidad definido.
- [x] Pesaje obligatorio de todas las mangas PT definido.
- [x] Impresión temporal en estación de pesaje definida.
- [x] Calidad posterior a recepción definida.
- [x] Manga como unidad PT primaria definida.
- [x] Separación de comandos e idempotencia definida.
- [x] OT diaria común y especialización de Armado definidas.
- [x] API, estados, UX y estrategia de pruebas definidas.
- [ ] Planta valida política `USO_EN_PROCESO`.
- [ ] Planta valida selección de orígenes y tratamiento de scrap/excedentes.
- [ ] Se crea un Tipo de manga y Perfil de empaque real para PT.
- [ ] Se valida una BOM, OA y manga reales anonimizadas.
- [ ] Se aprueba expresamente esta TS para desarrollo.

## 17. Estado de implementación local

El 2026-08-03 se implementó el incremento [[DEV-010F1_Cierre_Exacto_Armado]]:
plan y asignación de mangas PT, cierre atómico con abastecimiento exacto,
genealogía, cantidad read-only en Balanza y experiencia conectada de Armado.

También se implementó [[DEV-010F2_Excepciones_y_Correcciones_Armado]]:

- pool N:M para `CONJUNTO_CANDIDATOS`, sin reparto ficticio por manga;
- apertura contada `LEGACY_SIN_ORIGEN`, exclusiva del Jefe de Producción;
- reserva, traslado, recepción y consumo agregado conservando el nivel de certeza;
- corrección de cantidad como solicitud y evento compensatorio con cuatro ojos;
- bloqueo de la corrección simple después del pesaje, dejando explícito el
  requerimiento de reapertura física coordinada.

El modo exacto continúa siendo el predeterminado. Esto no cambia el estado
global de la TS: siguen pendientes las validaciones físicas de planta, el perfil
real de manga PT y una UAT completa con BOM/OA/mangas reales anonimizadas.
