---
tipo: plantilla_uat
estado: activo
tags: [uat, recorrido-fisico, trazabilidad, scm]
version_plantilla: 2
uat_id: ""
modalidades_uat: []
historia: ""
tech_spec: ""
dev: ""
ux_risk: ""
functional_validation: untested
ux_validation: needs_context
physical_uat: pending
release_constraint: no_habilitar_en_planta
contexto_operativo: ""
perfiles_uat: []
---

# UAT física — {{nombre_del_recorrido}}

> [!important] Regla de instanciación
> Esta plantilla es el núcleo común. Una UAT ejecutable debe enlazar un
> [[99_Plantillas/TPL_Contexto_Operativo_UI|contexto operativo]] concreto,
> seleccionar todos los perfiles aplicables desde
> [[99_Plantillas/Perfiles_UAT/README|Perfiles UAT]] y **copiar/adaptar sus
> preguntas** en la matriz de criterios de esta instancia. Enlazar perfiles sin
> convertir sus preguntas en resultados verificables no completa la UAT.
> Al crear la instancia, cambia `tipo: plantilla_uat` por `tipo: uat` y completa
> `uat_id`, fuentes, modalidades, contexto y perfiles en el frontmatter.

## 1. Identidad, objetivo y alcance

| Campo | Valor |
|---|---|
| UAT / `RUN_ID` | |
| Modalidades | `funcional`, `operativa`, `fisica` o combinación justificada. |
| Resultado de negocio | |
| Historia / Tech Spec / DEV | |
| Entorno, versión y revisión | |
| Fecha y ventana | |
| Responsable UAT | |
| Trabajadores participantes | |
| Observador | |
| Carpeta de evidencia | |
| Escenario reiniciable | Cómo repetir sin borrar historia ni usar datos productivos irreversibles. |

### Alcance

- **Incluye:**
- **Excluye:**
- **Riesgo operativo:** `low`, `medium` o `high`.
- **Resultado físico que debe quedar:**
- **Fuente autoritativa de cada dato crítico:**

## 2. Estados de validación y liberación

Los cuatro campos de frontmatter son independientes:

| Campo | Pregunta que responde | Valores |
|---|---|---|
| `functional_validation` | ¿Las reglas, contratos y efectos son correctos? | `untested`, `qa_green`, `uat_accepted`, `rejected` |
| `ux_validation` | ¿El trabajador entiende y completa el recorrido sin ayuda crítica? | `not_applicable`, `needs_context`, `provisional`, `ux_ready`, `rejected` |
| `physical_uat` | ¿El recorrido funciona en el puesto, dispositivo y hardware representativos? | `not_required`, `pending`, `accepted`, `rejected` |
| `release_constraint` | ¿Qué limita la liberación? | `none`, `no_habilitar_en_planta` |

`functional_validation: qa_green` no implica `ux_validation: ux_ready` ni
`physical_uat: accepted`. No usar `not_applicable` o `not_required` sin una justificación explícita.
Una interfaz destinada a planta conserva
`release_constraint: no_habilitar_en_planta` hasta completar las puertas humana
y física requeridas.

## 3. Contexto operativo y perfiles

- **Contexto operativo instanciado:** [[CTX-AREA-NNN]]
- **Puesto, dispositivo y viewport objetivo:**
- **Distancia, postura, manos/EPP y condiciones relevantes:**
- **Dato que debe percibirse primero:**
- **Acción primaria y condición para habilitarla:**
- **Información secundaria que no debe competir:**

| Perfil | ¿Aplica? | Motivo | IDs que se instancian |
|---|---|---|---|
| [[99_Plantillas/Perfiles_UAT/PERF_UAT_Estacion_Pesaje|Estación de pesaje]] | | | |
| [[99_Plantillas/Perfiles_UAT/PERF_UAT_Lector_Compartido_Tablet|Lector compartido / tablet]] | | | |
| [[99_Plantillas/Perfiles_UAT/PERF_UAT_Almacen_MultiQR|Almacén multi-QR]] | | | |
| [[99_Plantillas/Perfiles_UAT/PERF_UAT_Escritorio_Administrativo|Escritorio administrativo]] | | | |
| [[99_Plantillas/Perfiles_UAT/PERF_UAT_Impresion|Impresión]] | | | |
| [[99_Plantillas/Perfiles_UAT/PERF_UAT_Conectividad_Contingencia|Conectividad y contingencia]] | | | |

## 4. Preparación

- **Actores y roles:**
- **Datos y documentos de prueba:**
- **Estado físico inicial:**
- **Equipos físicos aplicables:** balanza, lector compartido, impresora, estación o tablet.
- **Modelo/configuración verificados:**
- **Conectividad y contingencia autorizada:** por defecto `bloqueo-seguro`.
- **Baseline de saldos/estados:**
- **Condiciones para detener la ejecución:**

## 5. Contrato transversal de estación

> **Escanear o presionar Enter identifica y resuelve contexto; nunca registra un movimiento. F2 o un botón explícito confirma el hecho físico.**

- El QR de contexto abre una sesión o intención temporal y normalmente no se imprime.
- El QR de unidad logística identifica una bolsa física; debe imprimirse y pegarse.
- Toda resolución debe mostrar datos comprensibles antes de permitir F2.
- La confirmación debe devolver identificador, peso NET, estado y siguiente acción.
- Repetir una confirmación con la misma clave no debe duplicar el hecho.
- Espera, bloqueo, listo, confirmando, confirmado y error deben distinguirse sin depender solo de color o sonido.
- Si Central no está disponible, la ausencia de respuesta nunca se presenta como confirmación.

## 6. Secuencia física y digital

| Paso | Actor y lugar | Objeto / manos | Escaneo, lectura o acción | Qué debe percibir | Confirmación | Efecto físico y digital | Siguiente acción / evidencia |
|---|---|---|---|---|---|---|---|
| 1 | | | | | | | |

## 7. Preguntas obligatorias por paso

1. ¿Qué persona está actuando y con qué permiso?
2. ¿Dónde ocurre físicamente?
3. ¿Qué objeto tiene en las manos?
4. ¿Qué QR identifica el contexto y cuál identifica la unidad?
5. ¿Qué debe ver tras Enter, antes de confirmar?
6. ¿Cuál es el dato primario, cuál la acción primaria y qué información debe quedar secundaria?
7. ¿Qué medición se captura —por ejemplo bruto, tara y NET— y cuál es su fuente autoritativa?
8. ¿Qué botón materializa el hecho y qué condición lo habilita?
9. ¿Qué documento, saldo, custodia, estado u objeto físico cambia?
10. ¿Cómo reconoce espera, bloqueo, listo, envío, éxito y error?
11. ¿Qué debe ocurrir si se repite, concurre otra sesión, se usa un QR equivocado o Central no responde?
12. ¿Cómo se recupera el trabajador y cuál es la siguiente acción segura?
13. ¿Puede completar el paso sin explicación, desplazamiento innecesario ni ayuda crítica?

## 8. Matriz de criterios instanciados

Copiar aquí las preguntas aplicables de cada perfil y transformarlas en
criterios concretos con valores del contexto. No dejar únicamente el wikilink
al perfil y no conservar preguntas genéricas sin respuesta.

| ID fuente | Criterio concreto para este puesto/recorrido | Preparación | Resultado esperado | Evidencia | Estado / hallazgo |
|---|---|---|---|---|---|
| `PERF-XX` | | | | | `PENDING` |

## 9. Casos de prueba

### Camino feliz

| ID | Preparación | Acción física | Resultado esperado | Evidencia | Estado |
|---|---|---|---|---|---|

### Negativos, reintentos e idempotencia

| ID | Condición | Resultado esperado | Evidencia | Estado |
|---|---|---|---|---|
| NEG-01 | QR de otro módulo | Rechazo sin movimiento | | |
| NEG-02 | Contexto vencido o cerrado | Rechazo sin movimiento | | |
| NEG-03 | Peso inestable o NET ≤ 0, cuando aplique | No permite confirmar | | |
| IDEM-01 | Reintento de la misma confirmación | Un solo hecho físico | | |
| OFF-01 | Central no disponible | No inventa confirmación; aplica la contingencia autorizada | | |

### Observación de usabilidad operativa

Entregar la tarea al trabajador sin indicarle dónde pulsar. Registrar hechos,
no solo opiniones.

| Tarea | Completó | Ayuda requerida | Duda / retroceso / casi-error | Tiempo observado | Evidencia |
|---|---|---|---|---|---|
| | | | | | |

## 10. Evidencia y hallazgos

- Capturas en el viewport objetivo y fotos desde la posición normal de trabajo.
- Modelos de hardware, método de entrada y condiciones físicas observadas.
- Identificadores, saldos y estados antes/después, sin secretos.
- Tiempos, ayudas, dudas, errores y decisiones de recuperación.
- Diferencias entre prototipo, implementación y comportamiento observado.

| ID | Severidad `P0`–`P3` | Hallazgo | Impacto operativo | Responsable | Revalidación |
|---|---|---|---|---|---|

## 11. Criterio de salida

### Funcional

- [ ] Cada Enter produce feedback inequívoco.
- [ ] Ningún escaneo por sí solo cambia inventario o producción.
- [ ] Reintentos y concurrencia no duplican el hecho.
- [ ] Los saldos y estados coinciden con las evidencias físicas.

### UX operativa

- [ ] El trabajador representativo completa el recorrido sin ayuda crítica.
- [ ] El dato y la acción primarios dominan sobre la información secundaria.
- [ ] Los estados y recuperaciones se entienden sin depender solo de color o sonido.
- [ ] Los desvíos críticos fueron corregidos o bloquean explícitamente la liberación.

### Física

- [ ] Cada bolsa creada termina identificada con sticker QR, cuando aplica.
- [ ] Dispositivo, lector, balanza e impresora aplicables fueron probados físicamente.
- [ ] Los desvíos y recuperaciones fueron probados en condiciones representativas.
- [ ] El escenario puede reiniciarse y repetirse.

### Veredicto

| Campo | Valor final | Evidencia / justificación |
|---|---|---|
| `functional_validation` | | |
| `ux_validation` | | |
| `physical_uat` | | |
| `release_constraint` | | |

La firma funcional por sí sola no autoriza uso normal en planta.
