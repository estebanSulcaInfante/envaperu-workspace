---
tipo: documentacion_backend
estado: implementado-local-pendiente-uat
tags: [scm, pesaje, mangas, integracion, etiquetas]
fecha_actualizacion: 2026-09-04
---

# SCM: pesaje de mangas y etiqueta final

## Contratos centrales de estación

| Método | Ruta | Resultado |
|---|---|---|
| `GET` | `/api/integration/v1/manga-labels/{label_id}/resolve` | Contexto solo lectura, capacidades y `bloqueos_pesaje` por acción. |
| `POST` | `/api/integration/v1/manga-weighings` | Pesaje idempotente y trabajo `POSTPESAJE`. |
| `POST` | `/api/integration/v1/manga-weighing-controls` | Control `AVANCE_KG` sin conteo; `CORTE_TURNO` histórico conserva su contrato. |
| `GET` | `/api/integration/v1/operations/{operation_id}` | Recuperación del acuse central. |
| `GET` | `/api/integration/v1/labels/{label_id}/print-payload` | Payload inmutable de una etiqueta. |

La confirmación requiere token de estación, `Idempotency-Key`, actor central
configurado, `capture_id`, lectura estable, bruto, tara y timestamp con zona.
En cierre normal Central copia la cantidad asignada con fuente
`PLAN_CONFIRMADO_POR_PESAJE`; no observa conteo ni deriva unidades desde kg.
El parcial vigente pide cantidad/motivo y capacidad `MANGA_FINALIZAR_PARCIAL`.
No equivale al futuro cierre exclusivamente en kg.

K4 añade `bloqueos_pesaje.completar_final` y `registrar_avance_kg`: nulo si la
acción está habilitada o `{codigo, mensaje, recuperacion, responsable}`. Las
capacidades y guardas de escritura siguen siendo la autoridad; el estado de
cabecera OT se informa como contexto, no sustituye el inicio del Trabajo.

K8 añade `manga.peso_fabricado_teorico_kg` y
`continuidad.ultima_referencia_peso={fuente,peso_neto_kg,tara_kg,tara_fuente,pesado_at}`.
La referencia puede ser `CONTROL_PESO` o `CIERRE_REABIERTO`; permite presentar
último NET y diferencia sin convertir kg a unidades.

La resolución incluye de forma aditiva `manga.color`, `manga.color_hex` y
`manga.color_identidad={id,nombre,base,familia,hex}`. La estación usa
`familia.nombre` para reconocer Transparente y `hex` para colores sólidos; si
no existe referencia visual conserva el nombre y no inventa un color.

## Flujo local

| Método | Ruta local | Uso |
|---|---|---|
| `POST` | `/api/local/v1/scm/weighing/resolve` | Parsea QR versionado y consulta central. |
| `POST` | `/api/local/v1/scm/weighing/confirm` | Toma el último ticket NET, confirma central e imprime. |
| `POST` | `/api/local/v1/scm/weighing/controls` | Captura real y envía `AVANCE_KG`; no recibe conteo ni produce relevo. |
| `GET` | `/api/local/v1/scm/weighing/operations/{id}` | Recupera una operación anterior. |

El frontend no envía el peso visual como autoridad. El backend local toma el
último valor entregado por la balanza y aplica la tara congelada recibida de
central. Si central no responde, no se crea un `Pesaje` SCM local. En la UI K8,
un QR resuelto habilita exactamente un acuse exitoso; después se exige otro
escaneo, aun para la misma manga. Un rechazo conserva el reintento idempotente.

## Etiqueta

Las emisiones nuevas usan `PREPESAJE_TSPL_5`, `POSTPESAJE_TSPL_5` y, para avance,
`CONTROL_PESO_TSPL_2`. Solo PREPESAJE imprime QR compacto `{v: 1, label_id}`.
Final y control son comprobantes sin QR; la preetiqueta continúa vigente.
Cada identidad ocupa una hoja 109 × 50 mm con dos copias. Campos, semántica,
compatibilidad y brechas: [[Etiqueta_Manga]].

El control mantiene manga `EN_LLENADO`, tramo activo y Trabajo sin cambio;
no acredita unidades ni crea inventario. Se conserva el último NET al resolver.
El final vigente también exige superar el último control. Relevo y continuidad
solo kg, inventario kg y retorno repesado siguen pendientes, no se habilitan por
el endpoint de control. Ver [[Feedback_Pesaje_y_Cierre_Kg_sin_Conteo]].

## Consulta y corrección humana

| Método | Ruta central | Uso |
|---|---|---|
| `GET` | `/api/scm/v1/mangas/{manga_id}/pesaje` | Devuelve captura original, proyección vigente, etiquetas finales e historial. |
| `POST` | `/api/scm/v1/pesajes/{pesaje_id}/correcciones` | Registra valores propuestos y motivo sin editar el pesaje. |
| `POST` | `/api/scm/v1/correcciones-pesaje/{correccion_id}/aprobar` | Aplica cuatro ojos, invalida la etiqueta anterior y genera una nueva. |
| `POST` | `/api/scm/v1/mangas/{manga_id}/reabrir` | Reclasifica un cierre como histórico y devuelve la misma manga a llenado. |

La aprobación actualiza la proyección de la manga, pero mantiene intacta la
fila original de `scm_pesaje_manga`. Mientras US-010I no reciba la manga,
`estado_inventario` sigue siendo `NO_INGRESADA` y no existe movimiento Kardex.

La reapertura requiere `MANGA_REABRIR`, `Idempotency-Key`, versión de manga,
`tipo_reapertura` y motivo. Los tipos nuevos son `CIERRE_ACCIDENTAL`, cuyo NET
queda solo en historial, y `CONTINUAR_LLENADO`, cuyo NET se conserva como
`peso_base_neto_kg` y debe ser superado por el siguiente control/final. La
omisión del tipo se interpreta como `CIERRE_ACCIDENTAL` para compatibilidad con
clientes K6. Solo admite manga NORMAL de Fabricación, cierre con fuente
`PLAN_CONFIRMADO_POR_PESAJE` y ausencia de custodia de Almacén vigente. El
cierre pasa a `REABIERTO`, las postetiquetas se invalidan, la manga vuelve a
`EN_LLENADO` y conserva preetiqueta/QR, controles, Trabajo, maquinista y cupo.
Un cierre posterior crea otra fila; el índice parcial permite exactamente una
con estado `VIGENTE`. `ANULAR_PESAJE` continúa siendo el descarte definitivo
que devuelve cupo e invalida todos los QR.
