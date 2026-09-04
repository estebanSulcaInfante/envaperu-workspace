---
tipo: uat
uat_id: UAT-US-010K4
modalidades_uat: [funcional, operativa, fisica]
historia: "[[US-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]]"
tech_spec: "[[TS-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]]"
dev: "[[DEV-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]]"
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
perfiles_uat: [PES-v1, LEC-v1, CON-v1, IMP-v1]
ux_risk: high
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha: 2026-09-02
---

# UAT K4 — Estado, bloqueo y control ordinario de manga

Entrada consolidada para preparar la siguiente pasada:
[[UAT_US-010K_Modulo_Pesaje_Piloto_Kg]] y [[ACTA_UAT_Pesaje_Piloto_Kg]].
Reverificación y brechas adicionales de etiquetas/cierre:
[[REC_2026-09-02_Preparacion_UAT_Modulo_Pesaje]]. Esta instancia conserva
el alcance y la evidencia propios de K4; no equivale a migración integral kg.

Guion preparado; NO es una aceptación ni autorización para planta. El QA
funcional del incremento es independiente de la regresión global del workspace.
Resultados y límites: [[REC_2026-09-02_Feedback_Estado_Manga_y_UAT_K4]].

## 1. Identidad y alcance — BASE

| Campo | Valor |
|---|---|
| RUN físico | `UAT-K4-FIS-AAAAMMDD-01`, asignar al ejecutar |
| Resultado | Operador reconoce manga/estado, explica bloqueo y usa un botón para control o cierre. |
| Entorno/revisión | Primero desarrollo local; registrar hash/versiones Central y estación antes del ensayo físico. Nunca seleccionar producción por defecto. |
| Responsable funcional / observador | Responsable del piloto / persona designada por él; nombres pendientes. |
| Participantes | Trabajador representativo de Pesaje + supervisor autorizado de Central. |
| Fecha/ventana física | Pendiente de coordinación humana. |
| Evidencia | `outputs/uat-k4/` para QA visual; carpeta propia por RUN físico, sin secretos. |
| Repetición | Fixtures UI recargables sin persistencia; para integración usar nuevas mangas de prueba en base UAT aislada, sin borrar historia. |

Incluye K4-01…06: motivos, recuperación, un botón/F2, controles ordinarios
repetibles en kg, QR estable dentro de la misma asignación y referencias de
peso persistidas. Excluye inventario calculado por kg, relevo/transferencia
solo kg aún no implementados, nuevos diseños TSPL y despliegue.

Resultado físico: una manga de prueba conserva su preetiqueta; cada control
puede añadir sticker de control sin QR. No hay recepción ni creación de stock.
El cierre de regresión vigente registra el plan, no demuestra conteo humano.

## 2. Preparación — CONTEXTO

- Puesto: PC/balanza compartida de planta. Identificar operador, supervisor,
  quién transporta la manga, manos disponibles, postura, EPP, distancia y ritmo.
  Todos pendientes de observación, sin tolerancias ni tiempos inventados.
- Registrar modelo/protocolo/puerto de balanza y señal real de estabilidad;
  modelo/sufijo del lector; pantalla/resolución/escalado; TSC/driver/spooler y
  papel. Referencia conocida TSC 203 dpi, layout 109×50 mm: verificar físicamente.
- Dato primario: manga, NET y efecto de F2. Secundarios: datos de plan/corrida.
  La UI existente destaca lectura bruta; evaluar PES-01, no autoaceptar jerarquía.
- Fuente: Central para estado/capacidades/persona/trabajo/tara congelada;
  balanza para bruto; NET = bruto − tara; último control persistido para referencia.
- Contingencia `bloqueo-seguro` según TS K4 y perfil CON. No autoriza operar offline.
  Supervisor debe definir custodia/ubicación de manga durante interrupción larga
  antes del ensayo de contingencia; no inventar staging.
- Detener ante efecto duplicado, pérdida de identidad, cierre involuntario,
  permiso inesperado, QR de producción o discrepancia de tara.
- Perfiles aplicables: PES, LEC, CON, IMP v1, instanciados abajo.
  ADM no seleccionado: no hay UI nueva de Central en K4. ALM no seleccionado:
  no se reciben ni mueven existencias. Los futuros vínculos requieren UAT ADM.

## 3. Datos y arranque reproducible

### QA visual aislado (no sustituye integración)

Desde `modulo-pesaje/frontend`: `npm.cmd run dev -- --host 127.0.0.1 --port 5186 --strictPort`.
Abrir `http://127.0.0.1:5186/qa/k4.html`. La página usa el componente real y
respuestas en memoria, no conecta con Central ni impresora; no entra al build.
Elegir escenario, escribir `qa` en QR y Enter. `invalido` simula rechazo.
Peso inicial ficticio 7.600 kg, tara 0.020, NET 7.580; otro control 8.000 bruto
→ 7.980 NET → aporte 0.400 kg. Son datos de prueba, NO estándar de Embudo.

### Integración/ensayo físico

Preparar en UAT, desde Central, mangas con preetiqueta impresa:

| Alias | Precondición verificable | Uso |
|---|---|---|
| A | NORMAL, Trabajo EN_EJECUCION, sin pesaje final | Dos controles ordinarios. |
| B | NORMAL, Trabajo PLANIFICADO | Motivo sin iniciar y recuperación desde Central. |
| C | PESADA / pendiente recepción, pesaje final vigente | Rechazo de nuevo pesaje. |
| D | CONTINUIDAD_PENDIENTE histórica K1/K2, fixture aislado | Solo diagnóstico; no probar traslado solo kg como si existiera. |
| E | Preetiqueta invalidada/reemplazada y su versión vigente | Rechazo/recuperación. |
| F | Segunda manga válida, contenido diferente | Cambio inequívoco de contexto. |

Anotar public_id manga/label, OT/Trabajo/asignación/tramo, operation_id,
bruto/tara/neto, controles/pesajes antes/después y conteo de eventos. No tokens.
Baseline: A sin cierre, B planificado, C un único cierre. Copiar lecturas reales
al acta; no imponer los kg del fixture a una manga física.

## 4. Secuencia — BDD K4 / BASE

| Paso | Actor/lugar/objeto | Acción | Percepción y efecto esperado | Evidencia |
|---|---|---|---|---|
| 1 | Operador, Pesaje, manga C identificada | Escanear + Enter, intentar F2 | Manga cerrada, motivo y Central como recuperación; cero pesajes nuevos. | Pantalla, estado y eventos. |
| 2 | Operador con B | Escanear | Trabajo de la OT sin iniciar; F2 deshabilitado. | Pantalla y Trabajo PLANIFICADO. |
| 3 | Supervisor en Central | Iniciar Trabajo B, operador reescanea B | Se actualiza capacidad; no crear otra manga ni cambiar QR. | IDs antes/después. |
| 4 | Operador con A sobre balanza | Marcar Control de peso y F2 | Registra bruto/tara/neto, no conteo; manga/tramo/Trabajo siguen activos. | Control AVANCE_KG, sticker, ausencia de Kardex/cierre. |
| 5 | Misma persona, OT, manga | Reescanear; alternar checkbox con mismo peso | Sin aumento; no se habilita otro registro. | Pantalla y número de controles. |
| 6 | Misma manga, nuevo avance físico | Nuevo control con mayor NET | Segundo control, mismo tramo/persona/OT; delta correcto, no suma de acumulados. | Dos controles y un tramo. |
| 7 | Operador, manga final de regresión dedicada | Sin marcar control, F2 | Un cierre; no afirmar conteo humano del plan. | Pesaje final/fuente e impresión. |
| 8 | Operador con F y luego QR E inválido | Escanear ambos en secuencia | Cambio visible; rechazo limpia manga anterior y deja F2 bloqueado. | Pantallas/IDs, cero mutaciones por Enter. |
| 9 | Operador/supervisor, manga de prueba | Fallos autorizados de conexión/impresión | No éxito falso; recuperación y custodia documentadas. | Logs saneados, IDs y objeto físico. |

Para cada paso registrar permiso/persona/lugar/objeto, dato y acción primaria,
fuente de medición, efecto físico/digital, recuperación y si necesitó ayuda.
Enter consulta; únicamente el botón/F2 materializa el hecho.

## 5. Criterios instanciados por perfil

Todos los criterios físicos/operativos comienzan `PENDING`. Los screenshots
solo acreditan QA visual. Registrar PASS/FAIL/NO_APLICA justificado al ejecutar.

| Origen | Criterio concreto / preparación | Resultado y evidencia exigida |
|---|---|---|
| PES-01 | A desde postura/distancia registradas | Operador identifica NET/unidad y no confunde bruto; foto desde puesto. Jerarquía por validar. |
| PES-02 | A, C, B; desconectar balanza e inducir lectura no válida en UAT | Distingue espera, desconexión, bloqueo, listo y registrado; capturas y relato. Estabilidad física no se infiere del número. |
| PES-03 | A con texto largo en monitor real | Manga, peso, efecto y F2 visibles; registrar scroll. QA estrecho tiene scroll, no aceptado para tablet. |
| PES-04 | A con tara snapshot conocida | Bruto − tara = NET, precisión del contrato y balanza concordantes; foto/registro. |
| PES-05 | Enter/F2 con B y A | Enter no crea hechos; F2 solo captura válido; IDs antes/después. |
| PES-06 | B/C/D, sin red y bruto≤tara | Motivo específico + siguiente paso sin depender del color; trabajador explica quién resuelve. |
| PES-07 | Doble F2 y respuesta perdida | Una operación y una impresión lógica; registrar claves/eventos. |
| PES-08 | E, QR inválido y de otro módulo | Rechazo seguro sin pesaje; pantalla y eventos. |
| PES-09 | Dos controles con objetos/manos reales | Tarea sin ayuda crítica; registrar dudas, tiempo observado y casi-error. |
| PES-10 | Control/cierre e impresión fallida | Reconoce registro vs impresión y siguiente acción; relato sin asistencia. |
| PES-11 | A→F y cambio de operador autorizado | Contexto y persona de Central visibles; no heredar intención del checkbox. |
| PES-12 | Fallo durante captura | Sin falso confirmado/disponible; conciliación antes de mover manga. |
| LEC-01 | Lector real configurado con sufijo observado | Enter solo resuelve; foto modelo/configuración saneada. |
| LEC-02 | Antes de cada F2 | Identifica manga, artículo/color, OT y persona; captura. |
| LEC-03 | Control con botón, luego lector | Foco vuelve al QR; recorrido sin clic para reenfocar. |
| LEC-04 | QR E después de A | Adaptación K4: contexto es la propia manga; el rechazo lo limpia para impedir pesar A por error. No hay contexto de máquina independiente que conservar. |
| LEC-05 | A→F | Acción explícita de escaneo, código cambia y checkbox se limpia; no traslada datos. |
| LEC-06 | Dejar contexto abierto entre operadores | No se implementa timeout nuevo; comprobar procedimiento de reescaneo/revalidación. Riesgo abierto si permite identidad equivocada. |
| LEC-07 | Segundo operador en estación compartida | No cambia atribución solo por quien pulsa; persona viene de Central. Relevo solo kg fuera de alcance. |
| LEC-08 | Pantalla/escalado real; tablet si se incorpora | Acción/contexto no ocultos por teclado/barras. Ensayo tablet NO_APLICA solo si supervisor confirma que no es puesto objetivo. |
| LEC-09 | Control, repetición y QR E | Estados expresados en texto; trabajador distingue error/éxito. |
| LEC-10 | Ráfaga/doble/incompleto | Sin mutación al resolver ni sobre manga anterior; IDs aceptados/rechazados. |
| LEC-11 | Lector + F2, manos reales | Recorrido completo sin ayuda crítica; observación. |
| LEC-12 | Suspensión/reconexión | Reescanear y comprobar último control/estado; no falso éxito. |
| CON-01 | Modo TS K4 | Bloqueo-seguro, sin operación offline autorizada. |
| CON-02 | Central caída antes de Enter | Bloqueo explícito, cero hechos; captura. |
| CON-03 | Central cae después de resolver | F2 bloqueado al detectarse o rechazo explícito; no confirmar silenciosamente. |
| CON-04 | Respuesta perdida de AVANCE_KG | Mensaje sin confirmar; conservar clave en reintento; consultar evento central. |
| CON-05 | Reiniciar tras respuesta incierta | Reescanear recupera estado/último control; cotejar evento, no asumir conservación de clave del navegador. |
| CON-06 | Interrupción larga | Supervisor define custodia antes del ensayo; manga no mezclada ni disponible por suposición. |
| CON-07 | Replay misma clave | Un solo hecho; evidencia de clave/control/sticker. |
| CON-08 | Estado cambiado remotamente después del QR | Rechazo y nueva consulta, nunca stock liberado ni segunda manga para evitar bloqueo. |
| CON-09 | Espera/error/acuse | No presenta captura-pendiente-sync como si el contrato la autorizara. |
| CON-10 | Impresión incierta | No afirmar IMPRESA ni disponibilidad sin acuse; evidencia del estado. |
| CON-11 | Timeout/reintento | Operador comprende repetir misma acción o reescanear para consultar; no cambia modo durante incertidumbre. |
| CON-12 | Diagnóstico por soporte | Solo IDs, estados y lecturas; excluir credenciales, .env y base productiva. |
| IMP-01 | TSC y papel reales | Registrar modelo/driver/DPI/ancho/alto/columnas; foto y config. |
| IMP-02 | Control vs final | Preview y papel coinciden, sin recortes; fotos pareadas. |
| IMP-03 | Manga lenta/código largo | Identidad/estado/kg legibles y completos; revisar texto de cantidad teórica según fuente. |
| IMP-04 | QR compacto pegado | Reescanea misma manga después del control; sin nueva identidad. |
| IMP-05 | A y F alternadas | Cada sticker se asocia al objeto correcto; observar retiro/pegado. |
| IMP-06 | Una etiqueta y última columna | Sin desplazamiento ni mezcla; muestras físicas. |
| IMP-07 | Papel agotado/spool detenido | Control guardado no se confunde con impresión exitosa; recuperación existente. |
| IMP-08 | Etiqueta dañada | Reemplazo versionado conforme a Etiqueta_Manga, con auditoría; no copia silenciosa. |
| IMP-09 | Reintentar trabajo de impresión | No vuelve a pesar ni crea otro QR vigente; comparar print_job_id/eventos. |
| IMP-10 | Salida de estación | Manga conserva preetiqueta vigente y sticker exigido según operación; observación. |
| IMP-11 | Etiqueta perdida/entregada | Recuperación supervisada y versión anterior invalidada cuando corresponda. |
| IMP-12 | Contenido secundario | No impide leer código/estado/QR; trabajador reconoce correctamente. |

## 6. Casos negativos / idempotencia

| ID | Condición | Resultado esperado | Estado físico |
|---|---|---|---|
| NEG-01 | C cerrada/B planificada/D pendiente | Motivo específico; botón y F2 bloqueados. | PENDING |
| NEG-02 | Bruto≤tara/no finito/supera máximo snapshot | No registrar; mensaje de lectura/límite correcto. | PENDING |
| NEG-03 | Mismo o menor NET que último control, alternar modo y reescanear | Sigue bloqueado; no borrar referencia. | PENDING |
| NEG-04 | QR invalidado tras manga válida | Sin contexto anterior habilitado ni éxito falso. | PENDING |
| IDEM-01 | F2 sostenido o doble | Un solo hecho/clave; ver backend, no solo pantalla. | PENDING |
| IDEM-02 | Respuesta perdida, reintentar mismo modo | Conserva clave y no permite mutar intención incierta; un evento. | PENDING |
| OFF-01 | Caída antes/después de resolver y durante confirmar | Bloqueo/acuse honesto + conciliación. | PENDING |
| IMP-NEG | Registro confirmado, impresión fallida | No repetir pesaje para imprimir; recuperación controlada. | PENDING |

## 7. Escenarios condicionados — NO ejecutables como flujo nuevo solo kg

| Caso | Regla objetivo | Dependencia abierta |
|---|---|---|
| Relevo misma OT | Central cambia persona, conserva manga y QR; frontera real y trazabilidad de ambos. | Modelo vigente requiere unidades por tramo; definir política antes de migrar. |
| Nueva OT compatible | Central vincula sin generar otra manga; historial OT/persona/fechas/control de frontera. | Redistribución de asignaciones UN y atribución sin conteo. |
| Cierre anticipado solo kg | Autorización Central, mismo botón físico; cantidad no se llama confirmada sin fuente. | Diseñar e implementar la transición a kg; UN solo referencia, sin dar por migrados plan ni consumos. |
| Manga de dos días | Muchos controles ordinarios ≠ muchos turnos; no sumar acumulados ni inventar reparto sin fronteras. | Validar solución integral posterior, no dar K1/K2 por migrado. |

Fuente: [[Feedback_Pesaje_y_Cierre_Kg_sin_Conteo]]. La excepción parcial histórica
que pide unidades NO satisface la futura política de cero conteos. Ningún PASS
de K4 certifica estos casos.

Actualización de alcance 2026-09-02: el responsable difirió el control detallado
de conciliación de Armado; ver [[Conciliacion_Consumo_Armado_en_Kg_Pendiente]].
No bloquea el desarrollo básico de pesaje/inventario en kg, ni cambia el alcance
o los resultados de K4. No se añade como condición de aprobación de esta UAT;
tampoco se certifica consumo exacto o inventario global conciliado mediante K4.

## 8. Observación, evidencia y salida

Entregar al trabajador: «Revisa estas mangas, registra un control de la que
seguirá abierta y explica qué harías con las bloqueadas». No indicar dónde pulsar.

| Participante/tarea | Completó | Ayuda | Duda/retroceso/casi-error | Tiempo | Evidencia |
|---|---|---|---|---|---|
| Pendiente de ejecución | — | — | — | — | — |

| Hallazgo | Riesgo/impacto | Responsable/revalidación |
|---|---|---|
| Dispositivo y condiciones no confirmadas | No hay aceptación ergonómica; pantalla estrecha exige scroll. | Responsable UAT, antes de física. |
| Lectura bruta visualmente dominante en UI existente | PES-01 requiere observación/ajuste si confunde NET. | UX + operador. |
| Flujo solo kg de relevo/cierre aún incompleto | No certificar partición UN ni inventario estimado. | Responsable funcional. |

Salida exige: motivos comprendidos sin ayuda crítica, cero mutaciones por Enter,
un hecho por clave, referencias conservadas, hardware/QR/papel comprobados,
recuperación observada, cero P0/P1 sin resolver y datos/firmas del RUN.
Responsable funcional: ______ Fecha: ______ Veredicto: ______
Operador/observador: ______ Hardware/revisión: ______ Evidencia: ______

`qa_green` es QA del incremento; `ux_validation: provisional`,
`physical_uat: pending`, `release_constraint: no_habilitar_en_planta` permanecen
hasta aceptación humana documentada. No firmar por inferencia del agente.
