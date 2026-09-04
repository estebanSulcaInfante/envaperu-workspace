---
tipo: user-story
subtipo: historia-hija
estado: implementada-local-qa-green
spec_phase: story
delivery_state: review
functional_validation: qa_green
ux_validation: rejected
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
epica: "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
uat_profiles:
  - "[[PERF_UAT_Estacion_Pesaje]]"
  - "[[PERF_UAT_Lector_Compartido_Tablet]]"
  - "[[PERF_UAT_Impresion]]"
  - "[[PERF_UAT_Conectividad_Contingencia]]"
fecha_creacion: 2026-08-31
fecha_actualizacion: 2026-09-03
tags: [scm, pesaje, avance-kg, manga-incompleta, qr, imagen, foco, atdd]
relaciones:
  - "[[2026-08-31_Control_Avance_en_Kg_sin_Conteo_y_Accion_Unica_Pesaje]]"
  - "[[US-010K2_Relevo_Multijornada_QR_Unico_y_Stickers_de_Control]]"
  - "[[TS-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
  - "[[PROTO_US-010K3_Pesaje_Unico_y_Contexto_Visible]]"
  - "[[UAT_US-010K3_Control_Avance_Kg_y_Contexto_Visible]]"
  - "[[REC_2026-08-31_Control_Avance_Kg_y_Contexto_Visible_Estacion]]"
  - "[[US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]"
---

# US-010K3: control de avance en kg y contexto visible en estación

## Historia

**Como** operador de la estación compartida de Pesaje  
**Quiero** pesar con un solo botón, marcar únicamente si la manga seguirá
incompleta y reconocer inequívocamente qué manga/pieza está activa  
**Para** registrar avances físicos sin inventar conteos, continuar llenando la
misma manga y encadenar escaneos sin mouse ni riesgo de pesar el QR anterior.

## Resultado observable

El operador escanea `M001`, ve su código en grande y la foto cuando existe.
Marca `Manga incompleta` y pulsa el único botón/F2. Central guarda solo kg,
mantiene manga y tramo activos e imprime el comprobante sin QR. El foco vuelve
al lector. Al escanear `M002`, la estación anuncia `M001 → M002`, cambia foto y
contexto, y permite otro avance o el cierre final.

## Invariantes

1. Un `AVANCE_KG` posee bruto, tara, neto y aporte; no posee conteo.
2. El peso no infiere unidades ni atribución exacta por trabajador/turno.
3. El avance confirma cero unidades y no crea Kardex.
4. El avance conserva `EN_LLENADO`, tramo activo, Trabajo activo/pausado,
   manga y QR.
5. `0..N` avances pueden existir en el mismo tramo.
6. El pesaje final sigue siendo único y confirma la cantidad asignada.
7. Checkbox apagado y encendido son estados mutuamente visibles; botón y F2
   ejecutan el mismo modo.
8. Resolver otro QR limpia intención/resultados anteriores y anuncia el cambio.
9. La imagen es opcional y no condiciona la operación.
10. Reintento con la misma operación no duplica control ni impresión.
11. La identidad del contenido mantiene el nombre de color visible y usa la
    referencia visual maestra cuando existe; la familia `TRANSPARENTE` se
    representa con patrón cuadriculado y no como blanco sólido.

## Alcance

- tipo de control `AVANCE_KG` repetible y sin unidades;
- un único botón/F2 para control o final;
- checkbox de intención `Manga incompleta`;
- foco automático al input QR después de la acción;
- código de manga dominante y anuncio textual de contexto;
- imagen opcional de PiezaColor/PT mediante URL cacheable, sin base64;
- identidad visual de color accesible mediante `{id,nombre,base,familia,hex}`;
- sticker de control sin conteo ni peso estándar por unidades;
- contratos, migración, pruebas y UAT concreta.

## Fuera de alcance

- atribuir unidades exactas entre trabajadores/OT;
- rediseñar la transferencia multi-OT sin conteo;
- corregir automáticamente controles `CORTE_TURNO` históricos;
- inferir artículo o color por la imagen;
- habilitación regular en planta o despliegue productivo.

## Escenarios BDD

### K3-01 — Avance solo en kg no bloquea

**Dado** una manga normal con QR vigente, Trabajo activo y lectura estable  
**Cuando** se pesa con `Manga incompleta` marcada  
**Entonces** se crea `AVANCE_KG` sin `conteo_acumulado_un`  
**Y** manga/tramo permanecen activos y el mismo QR admite otro avance/final.

### K3-02 — Controles repetibles en el mismo tramo

**Dado** un avance neto de `3.600 kg`  
**Cuando** la manga se vuelve a escanear y llega a `7.600 kg`  
**Entonces** crea otro avance en el mismo tramo con aporte `4.000 kg`  
**Y** no suma ambos netos como contenido ni producción.

### K3-03 — Una acción, dos intenciones visibles

**Dado** contexto y lectura válidos  
**Cuando** el checkbox está apagado  
**Entonces** botón/F2 ejecutan el final  
**Y cuando** está encendido ejecutan `AVANCE_KG`, nunca ambos.

### K3-04 — El lector recupera foco

**Dado** que se pulsó el botón con el mouse  
**Cuando** termina la respuesta aceptada o recuperable  
**Entonces** el foco está en `QR de manga SCM` y el siguiente escaneo+Enter se
resuelve sin otro click.

### K3-05 — Cambio de manga inequívoco

**Dado** que `M001` era la manga activa  
**Cuando** se resuelve el QR de `M002`  
**Entonces** aparece `Cambio de manga · M001 → M002` en una región anunciable  
**Y** `M002` se muestra como `MANGA ACTIVA` con jerarquía dominante.

### K3-06 — Foto opcional

**Dado** un artículo con imagen de catálogo  
**Cuando** se resuelve su QR  
**Entonces** aparece la imagen con texto alternativo de la pieza  
**Y** una imagen ausente/fallida muestra fallback y no bloquea pesar.

### K3-07 — Sticker de avance sin unidades

**Dado** un `AVANCE_KG` aceptado  
**Cuando** se renderiza `CONTROL_PESO_TSPL_2`  
**Entonces** muestra manga, neto acumulado, aporte, responsable y hora  
**Y** no contiene QR, conteo acumulado ni peso estándar según unidades.

### K3-08 — Replay seguro

**Dado** un avance aceptado cuya respuesta se perdió  
**Cuando** la estación recupera la misma `operation_id`  
**Entonces** devuelve el mismo control/job y no vuelve a capturar ni imprimir
automáticamente un soporte ya confirmado.

## Contexto de interacción

- Información primaria: NET, `MANGA ACTIVA`, artículo/foto y modo del botón.
- Acción primaria: `Pesar (F2)`; el texto explica si cerrará o seguirá abierta.
- Inicial: input QR enfocado.
- Listo: lectura estable y efecto del checkbox visible.
- Guardando: botón bloqueado contra doble submit.
- Éxito: resultado del control/final y foco de nuevo en QR.
- Error recuperable: mensaje textual, contexto conservado y foco accesible.
- Desconectado: pesar bloqueado con causa.

## READY-FOR-DESIGN / excepción UX

- [x] Problema observado y tres controles erróneos trazados.
- [x] Regla de conteo no confiable validada por responsable funcional.
- [x] Acción, estados y recuperación definidos.
- [x] Dataset y escenarios identificados.
- [ ] Validación representativa con operador, balanza, lector e impresora.

Se autoriza implementación controlada por evidencia directa de la prueba, con
`ux_validation: provisional` y `no_habilitar_en_planta`.

La UAT del 2026-09-03 rechazó el selector original después de dos cierres
accidentales por omisión. [[US-010K7_Control_por_Defecto_y_Cierre_Final_Deliberado]]
sustituye únicamente el contrato de intención de K3; sus contratos de kg,
identidad, foco, control e impresión permanecen.
