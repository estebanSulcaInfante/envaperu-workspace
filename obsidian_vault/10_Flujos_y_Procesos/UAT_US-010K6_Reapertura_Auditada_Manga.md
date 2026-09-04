---
tipo: uat
uat_id: UAT-US-010K6-REAPERTURA-20260903
estado: ejecucion-parcial-brecha-control-reincidente
modalidades_uat: [funcional, operativa, fisica]
historia: "[[US-010K6_Reapertura_Auditada_de_Manga_por_Cierre_Accidental]]"
tech_spec: "[[TS-010K6_Reapertura_Auditada_de_Manga_por_Cierre_Accidental]]"
dev: "[[DEV-010K6_Reapertura_Auditada_de_Manga_por_Cierre_Accidental]]"
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
perfiles_uat: [ADM-v1, PES-v1, LEC-v1, IMP-v1]
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: rejected
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
fecha_preparacion: 2026-09-03
fecha_ejecucion_parcial: 2026-09-03
---

# UAT K6 — reapertura auditada de una manga cerrada por error

Este guion valida la recuperación descubierta durante la UAT de Pesaje: se
pulsó F2 sin marcar **Control de peso** y M001 quedó cerrada. Reabrir debe
continuar la misma unidad física; **no crea M003, no cambia el QR, no devuelve
cupo y no borra el cierre accidental**.

## 1. Identidad, alcance y estado inicial

| Campo | Valor |
|---|---|
| UAT / RUN | `UAT-US-010K6-REAPERTURA-20260903` / asignar al ejecutar |
| Entorno | UAT local aislada; Central `5174`, API `5100`, Pesaje `5051` |
| Escenario | `jarra-real-6l-pesaje-piezas`; no ejecutar Reset |
| Actor de excepción | María José / Jefa de Producción, actor UAT `3` |
| Actor de estación | operador de Pesaje UAT `4` |
| Unidad | `OF000001-OT002-M001` |
| `manga_id` | `cc2319c4-a157-4b6e-925a-0fe2489efeaf` |
| preetiqueta / QR vigente | `ba676a92-97ba-40d6-a8a3-6331e1e83a7f` |
| cierre accidental | NET `8.950 kg`; final activo antes de reabrir |
| control previo que debe persistir | NET `4.790 kg`, `AVANCE_KG` |
| estado leído al preparar | `PENDIENTE_RECEPCION_ALMACEN`, versión `5`, no recibida |

Incluye reapertura administrativa, auditoría, misma identidad, reescaneo en
Pesaje, nuevo control/final y los bloqueos de autoridad/recepción. Excluye
Armado, cierre parcial, conciliación kg de retornos y despliegue productivo.
No acredita hardware físico mientras lector, balanza e impresora sean simulados.

Dato primario en Central: código M001 y efecto **conservar QR/cupo**. Acción
primaria: `Reabrir manga y continuar con el mismo QR`. En Pesaje, NET vuelve a
ser dominante y F2 sigue siendo la única confirmación.

## 2. Invariantes observables

- El cierre accidental queda append-only con estado `REABIERTO`, actor, fecha,
  motivo, evidencia e `operation_id`.
- M001 vuelve a `EN_LLENADO`; su preetiqueta IMPRESA, QR, controles, OT,
  Trabajo, maquinista y cupo permanecen.
- Toda postetiqueta del cierre invalidado deja de ser vigente y debe retirarse
  del objeto físico. No se imprime una preetiqueta nueva.
- El Trabajo pierde solo la atribución confirmada por el cierre invalidado; el
  objetivo/asignación del plan no cambia.
- Solo puede existir un cierre `VIGENTE`; el mismo QR puede producir uno nuevo.
- Si ya existe custodia de Almacén distinta de `REVERSADA`, la reapertura se
  bloquea y exige primero la reversa de recepción.
- `Anular pesaje definitivamente` sigue siendo otra acción: anula la identidad
  y devuelve cupo. No usarla en este recorrido.

## 3. Preparación y condiciones de parada

1. Confirmar los tres servicios locales en LISTO y periféricos simulados.
2. Conservar una captura de Central y de Pesaje antes de mutar M001.
3. Tener disponible la preetiqueta M001 ya usada; el comprobante final anterior
   se marca físicamente como inválido y se retira al reabrir.
4. Detener ante identidad diferente, existencia de Almacén no esperada,
   capacidad visible a un rol no autorizado, cambio de cupo o segundo QR.
5. No editar base, no reutilizar otro `operation_id` para recuperar una respuesta
   incierta y no ejecutar Reset para repetir.

## 4. Secuencia física y digital

| Paso | Actor / lugar | Acción | Qué debe percibir | Efecto y evidencia |
|---|---|---|---|---|
| 1 | JP / Central | Abrir OT-000002, Trabajo TC01, M001 y `Ver pesaje` | Cierre vigente; tarjetas Reabrir y Anular claramente distintas | Captura antes; M001 v5 |
| 2 | JP / Central | Escribir motivo y evidencia; primero cancelar/cerrar sin confirmar | Nada cambia | Consulta conserva final vigente |
| 3 | JP / Central | Confirmar `Reabrir manga y continuar con el mismo QR` | Éxito textual: conserva QR/cupo y pide retirar final | M001 `EN_LLENADO`, v6; cierre `REABIERTO`; evento/auditoría |
| 4 | JP / objeto | Retirar o marcar inválido el comprobante final anterior | No queda un final aparente vigente | Foto o captura simulada |
| 5 | Operador / Pesaje | Escanear **la misma** preetiqueta M001 | Contexto M001 habilitado; control anterior NET 4.790 visible | Cero mutación por Enter |
| 6 | Operador / Pesaje | Con bruto mayor al control anterior, marcar Control y F2 | Un nuevo control; sigue `EN_LLENADO`; sin final ni otro QR | Control, mismo manga/tramo/Trabajo |
| 7 | Operador / Pesaje | Cuando corresponda, desmarcar Control y cerrar con lectura acumulada válida | Un nuevo final, comprobante y pendiente de Almacén | Dos cierres históricos, exactamente uno `VIGENTE` |

## 5. Matriz de perfiles instanciados

| IDs fuente | Criterio concreto | Evidencia | Estado |
|---|---|---|---|
| `ADM-01`–`ADM-03` | JP encuentra la recuperación desde OT → Trabajo → M001; código/efecto dominan y no se confunde con corrección o anulación. | Captura y observación sin URL dictada | PENDING |
| `ADM-04`–`ADM-06` | En viewport/zoom objetivo no hay overflow global; carga/error y datos refrescados no parecen éxito. | Capturas completa, carga y error | PENDING |
| `ADM-07`–`ADM-08` | JP/GG ven Reabrir; Supervisor/Operador no. Cancelar no muta; confirmar exige motivo y explica alcance. | Comparación de perfiles y auditoría | PENDING |
| `ADM-09`–`ADM-12` | Teclado/foco accesibles; conflicto de versión pide actualizar; cerrar detalle conserva contexto OT/Trabajo y la consulta distingue vigente/histórico. | Recorrido teclado, conflicto y retorno | PENDING |
| `PES-01`–`PES-04` | Tras reabrir, el mismo QR recupera M001; NET/bruto/tara y estados siguen legibles y con precisión correcta. | Captura y lectura simulada/física | PENDING |
| `PES-05`–`PES-08` | Enter no muta; F2 registra control/final solo válido; cierre anterior/QR inválido no habilitan acción y muestran recuperación. | Estados/eventos antes-después | PENDING |
| `PES-09`–`PES-12` | Operador completa continuidad sin ayuda crítica; éxito identifica M001/NET/siguiente paso; reintento o fallo no duplica. | Observación, tiempo y operación | PENDING |
| `LEC-01`–`LEC-03` | Lector/sufijo/foco real resuelven la preetiqueta conservada sin mouse y mantienen M001 visible. | Configuración y recorrido | PENDING |
| `LEC-04`–`LEC-06` | QR incorrecto no muta; cambio de contexto es explícito; abandono no permite usar silenciosamente otra manga. | Secuencia M001/M002/error | PENDING |
| `LEC-07`–`LEC-09` | Operador no hereda permiso de reapertura; estados usan texto además de color; éxito/error se comprenden. | Dos perfiles y capturas | PENDING |
| `LEC-10`–`LEC-12` | Duplicados, ráfaga y reconexión conservan una identidad y una operación; recuperación exige revalidar. | IDs/log saneado | PENDING |
| `IMP-01`–`IMP-03` | En hardware real, soporte/layout siguen legibles; el comprobante anterior se reconoce como inválido. | Configuración, preview y papel | PENDING |
| `IMP-04`–`IMP-06` | La preetiqueta M001 pegada sigue leyendo; no se crea otra identidad ni se mezclan copias. | Lectura y fotos | PENDING |
| `IMP-07`–`IMP-09` | Fallo/reintento no cambia reapertura ni duplica pesaje/QR; historial diferencia trabajo de impresión y hecho. | Job/labels/eventos | PENDING |
| `IMP-10`–`IMP-12` | La unidad solo continúa con preetiqueta vigente; el final invalidado se retira y el código/estado siguen dominantes. | Secuencia física observada | PENDING |

## 6. Casos mínimos y resultados

| ID | Caso | Resultado esperado | Estado |
|---|---|---|---|
| K6-01 | Cancelar diálogo/formulario | Cero cambios | PENDING |
| K6-02 | Reabrir M001 con JP y motivo | Misma M001/QR/cupo; cierre histórico; `EN_LLENADO` | PASS PARCIAL — estado, auditoría y mismo QR confirmados; cupo por observar |
| K6-03 | Reescanear preetiqueta M001 | Puede registrar Control; no existe final vigente | PASS UAT LOCAL — el QR original resolvió M001 como abierta |
| K6-04 | Nuevo control y nuevo final | Controles preservados; dos finales históricos y uno vigente | INTERRUMPIDO / UX REJECTED — sustituido para repetición por UAT K7 tras la segunda reapertura |
| K6-05 | Supervisor u Operador en Central | Acción no visible y API rechaza capacidad | PENDING |
| K6-06 | Dos pestañas con versión obsoleta | Conflicto; actualizar y revisar antes de actuar | PENDING |
| K6-07 | Manga recibida en dataset dedicado | Bloqueo `RECEIPT_REVERSAL_REQUIRED`; cero cambios | PENDING |
| K6-08 | Repetir la misma confirmación/clave | Una reapertura y un evento | PENDING |
| K6-09 | Intentar reabrir parcial, Armado o ya abierta | Rechazo explícito; cero cambios | PENDING |

## 7. Evidencia técnica disponible y salida

### Ejecución parcial real — 2026-09-03

El responsable UAT ejecutó la reapertura de `OF000001-OT002-M001` como María
José / Jefa de Producción. La lectura API inmediatamente posterior confirmó:

| Evidencia | Resultado observado |
|---|---|
| manga | mismo `manga_id` `cc2319c4-a157-4b6e-925a-0fe2489efeaf`; `EN_LLENADO`; versión `6` |
| cierre accidental | pesaje `01687635-538c-463b-b403-09717c8d9a36` en `REABIERTO`; ya no existe cierre vigente |
| postetiqueta anterior | `4eb857b1-a7b6-4726-8444-afbaa26934e3` en `INVALIDADA` |
| inventario | `NO_INGRESADA`; no había recepción que revertir |
| auditoría | reapertura `c9c9a471-3cb9-42eb-adb9-d8c18ae86a15`; operación `3f8e6511-6280-4f55-bbe4-251e4c41f1b6`; actor `3`; `2026-09-03T16:59:56.498738-05:00` |
| motivo | `Cierre accidental en UAT: se pulsó F2 sin marcar Control de peso` |

La evidencia opcional quedó vacía. Esta lectura confirmó la mutación
administrativa y su trazabilidad. La continuidad operativa del QR se comprobó
después mediante el reescaneo descrito a continuación. K6-04 y la UAT física
permanecen pendientes; por ello `ux_validation` continúa `provisional` y
`physical_uat` continúa `pending`.

Posteriormente, el responsable UAT reescaneó el QR original y confirmó que la
estación mostró la manga como **abierta**. Con ello K6-03 queda aprobado en UAT
local para continuidad de identidad y estado. La siguiente mutación pendiente
es K6-04: registrar un nuevo control de peso y, después, comprobar que la manga
puede cerrarse nuevamente sin perder el historial previo.

En el intento siguiente se simuló `5.000 kg` bruto con tara `0.030 kg` y se
pulsó F2. Contra el resultado esperado de un control `AVANCE_KG`, la lectura API
posterior mostró un segundo cierre final vigente:

| Evidencia | Resultado observado |
|---|---|
| manga | M001 en `PENDIENTE_RECEPCION_ALMACEN`, versión `8` |
| segundo cierre | `c0937d59-9a3d-4362-8ad6-f2fc1ae1f823`, `VIGENTE`, NET `4.970 kg` |
| segunda postetiqueta | `e304d059-c8b1-4455-98a6-b35d57182e6f`, `IMPRESA` |
| cierre accidental anterior | permanece histórico en `REABIERTO` |
| control esperado | no registrado en este intento |

El usuario confirmó que la casilla **Control de peso** no estaba marcada. El
contrato funcional actuó correctamente: el modo sin marcar representa cierre
final. K6-04 queda interrumpido, no fallido por backend. Sin embargo, el mismo
error operativo ocurrió dos veces durante el recorrido guiado y produjo dos
cierres que requirieron recuperación administrativa. Esto rechaza la UX actual:
una omisión fácil de cometer dispara una mutación de alto impacto sin una
confirmación diferenciada.

QA automático: dominio mismo QR/nuevo final, autoridad, versión e idempotencia;
migración SQLite; 42 pruebas de interfaz; build Central. La migración PostgreSQL
se aplicó en UAT local sin reset y la lectura posterior confirmó M001 v5 con
cierre `VIGENTE`. Eso prepara la UAT, no aprueba los resultados humanos.

| Campo | Valor actual | Puerta pendiente |
|---|---|---|
| `functional_validation` | `qa_green` | ejecutar K6-01–09 aplicables |
| `ux_validation` | `rejected` | rediseñar la intención control/cierre y repetir con usuario representativo |
| `physical_uat` | `pending` | repetir con lector/balanza/impresora reales |
| `release_constraint` | `no_habilitar_en_planta` | aceptación humana y física |

## 8. Segunda recuperación y transferencia a UAT K7

Tras implementar [[US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]],
M001 fue reabierta nuevamente por Jefa de Producción UAT `3`:

| Evidencia | Resultado |
|---|---|
| operación | `a3afda06-ff5f-4f2f-8db2-03a3f694dd76` |
| reapertura | `c47c63a4-2875-4254-a520-3d03464305ea` |
| cierre invalidado | `c0937d59-9a3d-4362-8ad6-f2fc1ae1f823` en `REABIERTO` |
| postetiqueta invalidada | `e304d059-c8b1-4455-98a6-b35d57182e6f` |
| estado de salida | misma M001 y QR, `EN_LLENADO`, versión `9` |
| control preservado | NET `4.790 kg`, `AVANCE_KG` |

K6 conserva `ux_validation: rejected` como evidencia del hallazgo. La nueva
interacción y su eventual aceptación se evalúan exclusivamente en
[[UAT_US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]].
