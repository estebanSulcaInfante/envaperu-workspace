---
tipo: draft
estado: refinado-en-us-010k2
spec_phase: draft
delivery_state: not_started
functional_validation: untested
ux_validation: needs_context
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
uat_profiles:
  - "[[PERF_UAT_Estacion_Pesaje]]"
  - "[[PERF_UAT_Impresion]]"
  - "[[PERF_UAT_Conectividad_Contingencia]]"
tags: [scm, draft, manga, multi-jornada, relevo, qr, pesaje, impresion, wip]
fecha_creacion: 2026-08-29
fecha_actualizacion: 2026-08-29
relaciones:
  - "[[US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
  - "[[Guia_Casuisticas_Operativas_Produccion#CAS-PROD-003: Manga única multi-jornada con stickers de control]]"
  - "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
  - "[[US-010K1_Corte_Acumulado_y_Continuidad_de_Manga_entre_OT]]"
  - "[[US-010M3_Relevos_en_Trabajo_Color]]"
  - "[[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final]]"
---

# Draft: manga única multi-jornada, QR estable y stickers de control

## Evidencia y solicitud de planta

Gerencia General reportó el 2026-08-29 las siguientes situaciones y
necesidades:

1. Un relevo puede ocurrir a mitad de un turno y debe conservar la manga física
   que ya contiene producción.
2. En la familia referida como “orrines”, una sola manga puede llenarse poco a
   poco durante varios días.
3. La preetiqueta debe conservar el único QR de identidad durante toda la vida
   de la manga.
4. Cada control/pesaje debe imprimir un sticker físico porque ayuda al
   maquinista a llevar su cuenta.
5. El sticker nuevo puede pegarse sobre el anterior; el historial completo debe
   permanecer digitalmente.
6. El sticker de peso no necesita QR y debe usar el espacio para destacar el
   neto y la información de peso, especialmente para WIP y producción real de
   máquina.
7. El sticker debe mostrar también el aporte en kg desde el control anterior.
8. El Supervisor necesita declarar desde Central que una manga continúa
   abierta/incompleta por relevo, sin crear otra identidad ni pesaje final.
9. Las leyendas abreviadas `KG FIS.` y `KG OT` no se comprenden en planta; se
   solicitan nombres de peso explícitos y fuentes mayores.

Fuente operativa detallada: [[Guia_Casuisticas_Operativas_Produccion#CAS-PROD-003: Manga única multi-jornada con stickers de control|CAS-PROD-003]].

## Clasificación inicial

Este Draft es una ampliación de alcance con al menos tres porciones verticales,
no una corrección aislada:

1. relevo de manga abierta dentro de la misma OT y a mitad de turno;
2. identidad QR única y estable entre preetiqueta, controles y cierre;
3. impresión y rediseño de stickers de control/final con peso dominante y datos
   WIP.

Debe dividirse en historias hijas antes de Tech Spec. No se autoriza todavía
implementación ni despliegue.

## Hechos confirmados

- La misma manga física puede atravesar varios trabajadores, turnos y días.
- Cambiar responsable no debe obligar a cerrar, trasvasar ni crear otra manga.
- La preetiqueta es el soporte del único QR de identidad de la manga.
- Cada control aceptado necesita un comprobante impreso sin QR.
- Es aceptable cubrir físicamente el comprobante anterior.
- El peso debe tener mayor jerarquía visual que en la plantilla vigente.
- Cada sticker muestra el neto acumulado y el aporte desde el control anterior.
- Central debe ofrecer una declaración supervisada de manga abierta/incompleta
  por relevo, incluso cuando ocurre a mitad del turno.

## Reglas que permanecen vigentes salvo decisión posterior

- Los controles acumulados no se suman como si fueran incrementos.
- Un control no acredita producción final, no crea Kardex y no habilita
  recepción.
- La manga conserva `manga_id`, salida, artículo/WIP, color, corrida y empaque
  compatibles.
- El peso no infiere unidades.
- Solo el cierre definitivo confirma el total y existe una sola recepción de
  inventario.
- Los controles, impresiones y correcciones son idempotentes y auditables.

## Conflictos con especificaciones vigentes

| Fuente vigente | Regla actual | Nueva necesidad |
|---|---|---|
| `US/TS/DEV-010K1` | Un control imprime cero etiquetas. | Cada control imprime un sticker de peso. |
| `TS-010D` | `POSTPESAJE` incluye otro QR versionado. | La preetiqueta conserva el único QR; stickers de peso sin QR. |
| Implementación M3 | Una manga con contenido no se transfiere dentro de la misma OT. | Un relevo a mitad de turno conserva la misma manga. |
| Plantilla vigente | El peso aparece como una línea secundaria. | El neto debe ser la información primaria, grande y legible. |
| Terminología vigente | `KG FIS.` y `KG OT` son abreviaturas no comprendidas. | Usar nombres explícitos que distingan medición real de estándar calculado. |

Estos conflictos bloquean `READY-FOR-DESIGN` hasta que las reglas sucesoras se
aprueben expresamente. No se modifican retroactivamente las decisiones
anteriores desde este Draft.

## Resultado observable propuesto

Una manga inicia el lunes con un QR de preetiqueta, recibe controles impresos
sin QR durante varios relevos y días, y finaliza una sola vez. Cada control deja
un evento digital y un sticker físico reemplazable; el QR sigue resolviendo la
misma manga. El cierre confirma el total y las atribuciones reconciliadas sin
duplicar producción ni Kardex.

## Semillas BDD

### DMQ-01 — Relevo a mitad del turno conserva manga

**Dado** una manga abierta con contenido y QR vigente dentro de una OT en
ejecución  
**Cuando** el Supervisor la declara en Central como abierta/incompleta por
relevo y registra la frontera acumulada  
**Entonces** se cierra la asignación saliente y se abre la entrante sobre la
misma manga, OT, Trabajo y QR  
**Y** no se genera final, Kardex ni otra manga.

### DMQ-02 — Control imprime comprobante sin QR

**Dado** una manga abierta con una lectura estable  
**Cuando** el operador registra un control acumulado  
**Entonces** persiste un único evento idempotente e imprime un sticker sin QR
con `PESO NETO REAL (kg)` acumulado como información primaria y `APORTE DESDE
CONTROL ANTERIOR (kg)` como referencia secundaria  
**Y** la manga continúa abierta sin producción final ni Kardex.

### DMQ-03 — Varios días conservan identidad

**Dado** una manga compatible que se llena durante tres días  
**Cuando** se registran controles y relevos sucesivos  
**Entonces** todos resuelven el mismo `manga_id` y QR de preetiqueta  
**Y** existe como máximo un cierre final vigente.

### DMQ-04 — Superposición no borra historia

**Dado** un sticker físico de control anterior  
**Cuando** el siguiente se pega encima  
**Entonces** Central conserva ambos controles, lecturas, responsables y
resultados de impresión  
**Y** el QR de preetiqueta permanece visible y escaneable.

### DMQ-05 — WIP presenta peso real sin inferir unidades

**Dado** una manga WIP con controles acumulados comparables  
**Cuando** se genera el sticker de control  
**Entonces** muestra de forma prominente el peso neto físico y el contexto WIP
acordado  
**Y** no convierte kg en unidades ni consumo sin una fuente autorizada.

## Contexto operativo y contrato preliminar de interacción

- **Tarea inmediata:** escanear la manga correcta, distinguir control de final
  y obtener un comprobante legible sin cerrar producción por error.
- **Objeto físico:** manga abierta, preetiqueta con QR y stickers de control
  superpuestos.
- **Información primaria:** tipo `CONTROL` o `FINAL` y `PESO NETO REAL (kg)`
  acumulado, con tipografía grande.
- **Información secundaria:** `APORTE DESDE CONTROL ANTERIOR (kg)`, conteo,
  artículo/WIP, tramo y `PESO ESTÁNDAR SEGÚN UNIDADES (kg)` cuando corresponda.
- **Acción primaria:** `Registrar control — continúa abierta` o cierre final,
  visualmente inequívocas.
- **Estados mínimos:** esperando QR, manga resuelta, peso inestable, listo,
  registrando, control guardado/impresión pendiente, impreso, emisión incierta,
  desconectado y error recuperable.
- **Recuperación:** reintento idempotente del trabajo de impresión sin repetir
  la captura física ni crear otro control.
- **Contexto faltante:** dimensiones reales, impresora, colocación física,
  visibilidad del QR tras superposición y prueba con maquinistas.

`ux_risk: high`: balanza, QR, impresión repetida, producción física y una acción
de cierre difícil de revertir.

## Preguntas humanas pendientes

1. Confirmar si “datos del QR del pesaje” se refería a los datos visibles del
   sticker, porque el mismo requerimiento elimina ese QR.
2. ¿Qué campos WIP son imprescindibles para el maquinista y cuáles deben quedar
   solo en Central?
3. ¿El sticker final también carece de QR y cubre al último control?
4. ¿Qué artículo/PiezaColor identifica exactamente la denominación “orrines”?
5. ¿Qué perfil o regla autoriza una manga a permanecer abierta varios días y
   cuándo debe alertarse por antigüedad?
6. ¿Dónde se pega cada sticker para mantener siempre visible y legible el QR de
   la preetiqueta?

## Semántica de peso confirmada para el diseño

- `PESO NETO REAL (kg)`: medición física acumulada de la manga; equivale a
  `peso_bruto_kg - tara_kg`.
- `PESO ESTÁNDAR SEGÚN UNIDADES (kg)`: masa técnica calculada como
  `cantidad_confirmada × peso_unitario_snapshot_g / 1000`; no es la tara ni una
  segunda lectura de balanza.
- `APORTE DESDE CONTROL ANTERIOR (kg)`: diferencia entre dos pesos netos reales
  acumulados válidos y comparables. No se muestra si cambió la tara o el
  recipiente sin conciliación.

Para WIP, el peso neto real mide el conjunto físico completo. El peso estándar
atribuible a una OT o componente se mantiene identificado como cálculo y no
pretende aislar físicamente piezas incorporadas previamente.

## Evidencia y UAT requerida

- wireflow/prototipo de control, relevo y final;
- comparación visual del sticker vigente y propuestas a tamaño físico;
- UAT con maquinista, supervisor y operador de Pesaje;
- balanza, impresora y lector reales;
- manga real multi-jornada y fotografías autorizadas de superposición;
- fallos antes/después de emisión y reintento sin duplicados;
- conciliación de controles acumulados, aportes por tramo y único final.

## Gates

### READY-FOR-DESIGN

- [x] Necesidad, actores y resultado inicial identificados.
- [x] Conflictos con K1, M3 y TS-010D registrados.
- [x] Riesgo UX y objetos físicos declarados.
- [ ] Preguntas de semántica de etiqueta y WIP resueltas.
- [ ] Perfil multi-jornada y familia técnica exacta identificados.
- [ ] Draft dividido en historias verticales.

### UX-READY

- [ ] Contexto físico completado con evidencia representativa.
- [ ] Prototipo de estados y etiquetas a tamaño real.
- [ ] Validación temprana con trabajadores.
- [ ] Hallazgos críticos corregidos.

Mientras estas puertas permanezcan abiertas:

```yaml
ux_validation: needs_context
physical_uat: pending
release_constraint: no_habilitar_en_planta
```
