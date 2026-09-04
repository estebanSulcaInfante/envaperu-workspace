---
tipo: user-story
subtipo: historia-hija
estado: desplegada-provisional-pendiente-uat
spec_phase: story
delivery_state: deployed
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
uat_profiles:
  - "[[PERF_UAT_Estacion_Pesaje]]"
  - "[[PERF_UAT_Lector_Compartido_Tablet]]"
  - "[[PERF_UAT_Escritorio_Administrativo]]"
  - "[[PERF_UAT_Impresion]]"
  - "[[PERF_UAT_Conectividad_Contingencia]]"
epica: "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
tags: [scm, fabricacion, manga, multi-jornada, relevo, qr, pesaje, impresion, wip, atdd]
fecha_creacion: 2026-08-29
fecha_actualizacion: 2026-08-29
relaciones:
  - "[[Manga_unica_multijornada_QR_estable_y_stickers_de_control]]"
  - "[[US-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
  - "[[US-010M3_Relevos_en_Trabajo_Color]]"
  - "[[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final]]"
  - "[[2026-08-26_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
  - "[[PROTO_US-010K2_Relevo_Multijornada_y_Stickers_de_Peso]]"
  - "[[TS-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
  - "[[DEV-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
---

# US-010K2: relevo multi-jornada, QR único y stickers de control

## 1. Fuentes y estado de la decisión

Esta historia refina el Draft
[[Manga_unica_multijornada_QR_estable_y_stickers_de_control]] y la casuística
`CAS-PROD-003`. Gerencia confirmó el 2026-08-29:

- una manga con contenido debe conservarse en relevos dentro del mismo turno,
  entre turnos y durante varios días;
- el QR de la preetiqueta es la única identidad física escaneable;
- cada control aceptado imprime un sticker sin QR;
- el sticker muestra neto acumulado y aporte desde el control anterior;
- el nuevo sticker puede cubrir al anterior porque la historia completa queda
  en Central;
- se eliminan los rótulos crípticos `KG FIS.` y `KG OT` y se aumenta la fuente.

La orden “vamos a implementar la feature usando el pipeline” autoriza una
implementación local/exploratoria. No constituye validación representativa de
UX ni UAT física. Por eso se conserva `ux_validation: provisional` y
`release_constraint: no_habilitar_en_planta`.

Posteriormente, el 2026-08-29, el usuario autorizó el despliegue técnico del
candidato conjunto F3+K2 en Central y en la estación del piloto. Esa
publicación permite ejecutar una validación controlada, pero no cambia la UX ni
la UAT física pendientes y no habilita operación regular en planta.

## 2. Historia

**Como** maquinista, operador de Pesaje y Supervisor de Producción  
**Quiero** conservar una misma manga y QR durante relevos y varios días,
registrando controles acumulados con un comprobante físico legible  
**Para** continuar el llenado sin trasvasar ni duplicar producción, conocer el
peso acumulado y el aporte del último tramo, y cerrar la manga una sola vez.

## 3. Resultado observable

Una manga empieza con José, cambia a Pedro a mitad del turno y después continúa
en una OT compatible del día siguiente. En cada frontera se escanea el mismo QR
de preetiqueta, Central registra un control acumulado y la estación imprime un
sticker sin QR con `PESO NETO REAL (kg)` y `APORTE DESDE CONTROL ANTERIOR
(kg)`. Solo el final acredita unidades, crea la etiqueta final de peso y
habilita la recepción. Existe una manga, un QR, varios controles/tramos y un
solo final.

## 4. Alcance vertical

- declaración supervisada de `continúa abierta/incompleta por relevo` desde
  Central;
- relevo de una manga con contenido dentro de la misma OT sin cerrarla;
- continuidad K1 hacia una OT posterior compatible;
- QR único de preetiqueta durante controles y final;
- trabajo de impresión idempotente por cada control aceptado;
- sticker `CONTROL_PESO_TSPL_1` sin QR, 2-up, `109 × 50 mm`;
- sticker final sin QR mientras la preetiqueta vigente permanezca asociada y
  visible;
- neto acumulado, aporte desde el control anterior y peso estándar claramente
  diferenciados;
- múltiples días y controles sin sumar acumulados;
- historial de asignaciones, controles e intentos de impresión;
- recuperación ante fallo o emisión incierta sin repetir el control.

## 5. Fuera de alcance

- crear Kardex, disponibilidad o recepción desde un control;
- inferir unidades desde kg;
- mezclar máquina, corrida, salida, artículo/WIP, color, receta o empaque
  incompatibles;
- trasvasar, dividir o consolidar contenido;
- operación SCM autoritativa offline;
- acreditar como producción de una máquina el peso completo de un WIP que
  contiene componentes producidos previamente;
- definir automáticamente qué artículos se denominan “orrines”; la activación
  por perfil queda separada de esta lógica genérica;
- habilitar el flujo para operación regular en planta o declararlo
  `LISTO_PARA_PLANTA` antes de UAT física.

## 6. Lenguaje e invariantes

### Manga abierta/incompleta

Una manga física con contenido cuyo total final aún no fue confirmado. No es
una segunda clase de manga ni una identidad nueva. `relevo` es un evento que
cierra una asignación/tramo y abre otro; la manga continúa `EN_LLENADO` o queda
`CONTINUIDAD_PENDIENTE` si espera vínculo a otra OT.

### Control acumulado

Observación completa de bruto, tara, neto y conteo presentes en la manga en un
momento. No representa el incremento aislado ni un pesaje final.

### Aporte desde control anterior

```text
aporte_control_kg = neto_acumulado_actual - neto_acumulado_anterior
```

Solo se publica cuando ambos controles son vigentes y físicamente comparables:
misma manga/envase y misma tara efectiva o una conciliación autorizada.

### Pesos visibles

- `PESO NETO REAL (kg)`: `peso_bruto_kg - tara_kg`; medición física.
- `APORTE DESDE CONTROL ANTERIOR (kg)`: delta físico válido entre controles.
- `PESO ESTÁNDAR SEGÚN UNIDADES (kg)`: unidades confirmadas por peso unitario
  snapshot; cálculo técnico, no tara ni lectura de balanza.

### Invariantes

1. Una manga conserva un solo `manga_id`, código y QR operativo.
2. Los stickers de control/final no contienen QR ni crean identidad física.
3. Una manga admite `0..N` controles y `0..1` final vigente.
4. Cada control aceptado crea exactamente un trabajo de impresión lógico.
5. Replay del control o impresión no duplica controles, créditos ni trabajos.
6. Un control confirma `0 UN`, no consume cupo, no crea Kardex y no habilita
   recepción.
7. Los netos acumulados no se suman; el aporte es una diferencia.
8. Un relevo dentro de la misma OT preserva OT, Trabajo, manga y QR, y cambia
   únicamente el intervalo de responsabilidad.
9. Un relevo hacia otra OT reutiliza el último control como frontera y exige
   compatibilidad K1.
10. El QR de preetiqueta permanece resoluble después de controles y final,
    salvo invalidación/reemplazo autorizado del soporte.
11. Cubrir un sticker anterior no borra el control ni su evidencia de impresión.
12. Solo F2 cierra y confirma una vez el total final.
13. Para WIP, el neto mide el conjunto físico; la atribución por OT/componente
    usa genealogía y estándar explícito.

## 7. Contexto operativo y contrato de interacción

- **Lugar:** estación compartida de Pesaje y Central de Producción.
- **Objetos físicos:** manga abierta, preetiqueta con QR, balanza, lector,
  impresora y stickers superpuestos.
- **Información primaria en estación:** `CONTROL` o `FINAL`, código de manga,
  `PESO NETO REAL (kg)` y estabilidad.
- **Acción primaria de control:** `Registrar control — continúa abierta`.
- **Información primaria en Central:** manga exacta, responsable saliente,
  responsable entrante, OT/Trabajo/tramo y última frontera.
- **Acción primaria en Central:** `Registrar relevo — continúa incompleta` o
  vincular a OT compatible.
- **Información secundaria:** aporte desde control anterior, conteo, estándar,
  artículo/WIP, color, fecha/hora e impresión.
- **Recuperación:** reintentar el mismo trabajo de impresión sin repetir lectura
  ni control; conciliar emisión incierta; reemplazar solo el soporte QR dañado.

Estados mínimos:

1. esperando QR;
2. manga resuelta y lectura inestable;
3. lista para control/final;
4. confirmando control;
5. control guardado e impresión pendiente;
6. control impreso;
7. impresión fallida reintentable;
8. emisión incierta;
9. Central desconectada;
10. relevo pendiente de supervisor;
11. continuidad vinculada;
12. final confirmado.

El wireflow y la jerarquía propuesta están en
[[PROTO_US-010K2_Relevo_Multijornada_y_Stickers_de_Peso]].

## 8. Criterios funcionales BDD

### K2-01 — QR único durante toda la vida

**Dado** una manga con preetiqueta vigente  
**Cuando** atraviesa controles, relevos y cierre final  
**Entonces** todos los eventos referencian el mismo `manga_id` y el QR de
preetiqueta  
**Y** ningún sticker de peso contiene un segundo QR.

### K2-02 — Control imprime sin acreditar

**Dado** una manga abierta con lectura estable y `20 UN` acumuladas  
**Cuando** se registra el control  
**Entonces** Central confirma `0 UN`, conserva la manga abierta y crea un único
trabajo de impresión de control  
**Y** no crea pesaje final, recepción ni Kardex.

### K2-03 — Sticker de control legible

**Dado** el primer control de `4.800 kg` netos  
**Cuando** la estación renderiza `CONTROL_PESO_TSPL_1`  
**Entonces** imprime `PESO NETO REAL (kg): 4.800` como dato dominante  
**Y** muestra `APORTE DESDE CONTROL ANTERIOR (kg): 4.800`, manga, artículo/WIP,
responsable/tramo y fecha  
**Y** no imprime QR, `KG FIS.` ni `KG OT`.

### K2-04 — Segundo control calcula aporte

**Dado** un control vigente de `4.800 kg` y una nueva lectura comparable de
`8.950 kg`  
**Cuando** se acepta el segundo control  
**Entonces** conserva `8.950 kg` como neto acumulado y `4.150 kg` como aporte
desde el control anterior  
**Y** no suma `4.800 + 8.950` como producción.

### K2-05 — Relevo a mitad de la misma OT

**Dado** una manga con contenido asignada a José en una OT en ejecución  
**Cuando** el Supervisor registra a Pedro, motivo y frontera acumulada mediante
`Registrar relevo — continúa incompleta`  
**Entonces** cierra el intervalo de José y abre el de Pedro sobre la misma OT,
Trabajo, manga y QR  
**Y** no imprime otra preetiqueta ni ejecuta cierre final.

### K2-06 — Relevo entre turnos y días

**Dado** una manga con último control válido y una OT posterior compatible  
**Cuando** el Supervisor la vincula al nuevo Trabajo/maquinista  
**Entonces** reutiliza la frontera, conserva manga/QR y abre el tramo siguiente  
**Y** puede repetir el procedimiento durante varios días.

### K2-07 — Cambio de tara bloquea aporte automático

**Dado** un control anterior y una nueva lectura con tara/envase no comparable  
**Cuando** se intenta publicar el aporte  
**Entonces** el sistema exige conciliación y no imprime un delta engañoso  
**Y** conserva ambas lecturas sin corrección destructiva.

### K2-08 — Fallo de impresión no repite control

**Dado** un control central aceptado cuyo sticker falló sin emisión  
**Cuando** el operador reintenta  
**Entonces** reutiliza el mismo `print_job_id`, payload y control  
**Y** no registra otra lectura ni otro aporte.

### K2-09 — Emisión incierta es visible

**Dado** que la estación no puede demostrar si el sticker salió  
**Cuando** reporta `EMISION_INCIERTA`  
**Entonces** el control permanece vigente, se muestra la contingencia y el
reemplazo exige la autoridad definida  
**Y** no se imprime a ciegas otra identidad.

### K2-10 — Cierre final sin segundo QR

**Dado** varios controles y tramos sobre una manga  
**Cuando** F2 confirma el total final  
**Entonces** existe un único pesaje final, crédito y sticker final sin QR  
**Y** la preetiqueta continúa como identidad para recepción.

### K2-11 — WIP no atribuye masa ajena a la máquina

**Dado** un WIP que incorpora piezas producidas previamente  
**Cuando** se imprime un control  
**Entonces** muestra el neto real del conjunto y el aporte físico desde el
control anterior  
**Y** cualquier peso estándar atribuible a la OT se identifica como cálculo y
no como masa física aislada.

### K2-12 — TSPL conserva terminador físico

**Dado** un trabajo de una o dos etiquetas de control  
**Cuando** la estación genera el TSPL  
**Entonces** el último `PRINT 1,1` termina en `CRLF`.

## 9. Criterios de operabilidad

- El operador reconoce `CONTROL` frente a `FINAL` antes de confirmar.
- El valor numérico del neto se puede identificar primero en pantalla y papel.
- El QR de preetiqueta permanece visible después de superponer stickers.
- El maquinista puede distinguir neto acumulado de aporte sin conocer siglas
  internas.
- La estación informa por separado `guardado`, `impresión pendiente`,
  `impreso`, `fallido` e `incierto`.
- Un reintento no obliga a volver a colocar la manga en la balanza.
- Central permite localizar la manga por código, QR, OT origen, OT vigente y
  responsable actual.

## 10. Dataset reproducible

| Dato | Valor |
|---|---|
| Manga | `OF0021-OT0410-M007`, `50 UN`, tara `0.030 kg` |
| Preetiqueta | un QR `SCM_MANGA_LABEL`, `manga_id` estable |
| Día 1 / José | control `4.830 - 0.030 = 4.800 kg`, `20 UN`, aporte `4.800 kg` |
| Mismo turno / Pedro | relevo dentro de OT en frontera `20 UN` |
| Día 2 / Pedro | control `8.980 - 0.030 = 8.950 kg`, `35 UN`, aporte `4.150 kg` |
| Día 3 / Ana | control/final `12.030 - 0.030 = 12.000 kg`, `50 UN`, aporte `3.050 kg` |
| Resultado | `1 manga / 1 QR / 2 controles + 1 final / 3 stickers de peso` |
| Crédito/Kardex antes del final | `0 / 0` |
| Crédito final | `50 UN` una sola vez |

## 11. Permisos, errores y concurrencia

- `MANGA_CONTROL_PESO_REGISTRAR`: registrar control.
- `MANGA_REASIGNAR_MAQUINISTA`: relevo dentro de la misma OT.
- `MANGA_TRANSFERIR_OT`: continuidad hacia OT posterior compatible.
- `MANGA_FINALIZAR_COMPLETA`: cierre final.
- `MANGA_ETIQUETA_REEMPLAZAR`: resolver emisión incierta o soporte dañado.

Central toma lock/version de manga, tramo, asignación, último control y trabajo
de impresión. Dos controles concurrentes no pueden crear dos secuencias ni dos
aportes. Un control concurrente con F2 produce un único ganador y el perdedor
recibe el estado vigente recuperable.

Errores observables mínimos:

- `OPEN_MANGA_RELIEF_INCOMPATIBLE`;
- `CONTROL_ALREADY_EXISTS` o replay idempotente;
- `CONTROL_TARE_NOT_COMPARABLE`;
- `CONTROL_PRINT_FAILED`;
- `CONTROL_PRINT_UNCERTAIN`;
- `MANGA_ALREADY_FINALIZED`;
- `CENTRAL_UNAVAILABLE`.

## 12. Dependencias y riesgos

- Evoluciona K1 y sustituye su regla `cero impresiones por control`.
- Evoluciona TS-010D y sustituye el segundo QR de `POSTPESAJE`.
- Evoluciona M3 para admitir manga con contenido dentro de la misma OT.
- Requiere contrato Central–Pesaje, migración aditiva y renderer TSPL/SVG.
- Riesgo físico: cubrir el QR único o confundir un control con el final.
- Riesgo contable: sumar acumulados o atribuir el WIP completo a la máquina.
- Riesgo de impresión: control aceptado con soporte fallido/incierto.

## 13. Prototipo, validación y UAT

Perfiles propuestos:

- `PERF_UAT_Estacion_Pesaje`;
- `PERF_UAT_Lector_Compartido_Tablet`, porque la única estación cambia entre
  trabajadores y mangas;
- `PERF_UAT_Escritorio_Administrativo`, por la declaración supervisada del
  relevo en Central;
- `PERF_UAT_Impresion`;
- `PERF_UAT_Conectividad_Contingencia`.

La UAT debe incluir maquinista saliente/entrante, Supervisor y operador de
Pesaje con manga, lector, balanza e impresora reales. Debe demostrar QR visible
tras superposición, controles de varios días, reintentos y un único final.

## 14. READY-FOR-DESIGN

- [x] Actor, resultado, alcance y exclusiones definidos.
- [x] Identidad, control, aporte, cierre y WIP diferenciados.
- [x] Relevo dentro de OT y entre OT cubiertos.
- [x] Dataset y escenarios funcionales/operativos identificados.
- [x] Errores, reintentos, concurrencia y permisos declarados.
- [x] Contradicciones con K1/M3/D registradas como sustituciones explícitas.
- [x] Autorización humana para implementación local registrada.

## 15. UX-READY

- [x] Información y acciones primarias declaradas.
- [x] Wireflow/prototipo provisional preparado.
- [ ] Evidencia visual a tamaño físico revisada por trabajadores.
- [ ] Superposición y lectura QR probadas en hardware real.
- [ ] Hallazgos críticos corregidos.

Se autorizó pasar a Tech Spec, implementación y despliegue técnico controlado
bajo excepción explícita; no se autoriza habilitación regular en planta.

## 16. Evidencia de implementación y despliegue técnico

- UAT instanciada: [[UAT_US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]].
- Contratos, migración SQLite, servicios Central/estación, renderer y UI tienen
  pruebas automáticas verdes para K2-01..K2-12.
- El renderer real fue inspeccionado en SVG `109 × 50 mm`, 2-up, sin QR y con
  el neto dominante.
- Central y `PESAJE-PLANTA-01` quedaron desplegados; la estación reporta
  `1.2.0-pilot.13`, READY y Central ONLINE. Evidencia consolidada en
  [[../../10_Flujos_y_Procesos/REC_2026-08-29_Despliegue_F3_K2_Central_y_Estacion_Pilot13]].
- No se ejecutaron impresión física, observación con trabajadores ni UAT en
  hardware; se conservan `ux_validation: provisional`, `physical_uat: pending`
  y `no_habilitar_en_planta`.
