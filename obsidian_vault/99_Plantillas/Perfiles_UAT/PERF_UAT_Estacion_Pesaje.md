---
tipo: perfil_uat
id_perfil: PES
estado: activo
version: 1
tags: [uat, ux, pesaje, balanza, planta]
relaciones:
  - "[[10_Flujos_y_Procesos/Estandar_UAT_Fisica_SCM]]"
  - "[[04_Modulo_Pesaje/UI_Pesaje_Operario]]"
  - "[[10_Flujos_y_Procesos/UAT_TS-010C_D_OT_Mangas_Pesaje]]"
---

# Perfil UAT — Estación de pesaje

## Cuándo aplica

Seleccionar cuando una balanza aporta bruto, tara o NET y una persona confirma
un hecho físico. Combinar normalmente con [[PERF_UAT_Impresion|IMP]] y
[[PERF_UAT_Conectividad_Contingencia|CON]].

Este perfil no fija tamaños universales. La distancia, monitor, resolución,
postura, EPP y tiempo objetivo proceden del contexto operativo observado.

## Entradas obligatorias de la instancia

- Modelo de balanza, puerto/protocolo y criterio de lectura estable.
- Pantalla, resolución, escalado, distancia y ángulo de lectura.
- Persona que pesa, objetos que sostiene, postura y manos disponibles.
- Tipo de unidad, tara autorizada y fuente autoritativa.
- Contexto/QR, operación idempotente y siguiente destino físico.
- Política autorizada cuando Central, balanza o impresora no responde.

## Preguntas que deben instanciarse

| ID | Pregunta a convertir en criterio concreto | Evidencia mínima |
|---|---|---|
| `PES-01` | ¿NET y su unidad son el elemento visual dominante desde la distancia y postura reales? | Foto desde el punto de operación y captura en resolución objetivo. |
| `PES-02` | ¿Se distinguen balanza desconectada, lectura inestable, estable, bloqueada y confirmada? | Captura de cada estado y explicación del trabajador. |
| `PES-03` | ¿Contexto activo y siguiente acción son visibles sin competir con el peso? | Captura completa sin scroll para el recorrido primario. |
| `PES-04` | ¿Bruto, tara y NET se diferencian y usan unidad/precisión correctas? | Lectura observada y comparación con fuente física. |
| `PES-05` | ¿Enter resuelve sin mutar y F2 confirma solo con contexto y lectura válidos? | IDs/estados antes y después. |
| `PES-06` | ¿Cuando F2 está bloqueado se explica la causa y la recuperación? | Casos de contexto ausente, inestabilidad y periférico desconectado. |
| `PES-07` | ¿Doble F2, tecla sostenida o respuesta perdida conservan un solo hecho? | `operation_id`/clave y conteo central. |
| `PES-08` | ¿QR vencido, inválido, reemplazado o de otro módulo deja un estado seguro? | Rechazo visible y ausencia de mutación. |
| `PES-09` | ¿El trabajador completa la tarea con la postura, manos, EPP y ritmo reales? | Observación de ayuda, duda, casi-error y tiempo. |
| `PES-10` | ¿Tras confirmar se reconocen resultado, identificador, NET, estado y siguiente acción? | Captura final y relato operativo sin asistencia. |
| `PES-11` | ¿El cambio de contexto o de trabajador evita confirmar sobre la unidad anterior? | Prueba consecutiva con dos contextos/personas. |
| `PES-12` | ¿Un fallo después de capturar peso evita comunicar disponibilidad o éxito falsos? | Estado visible, efecto central y tratamiento del objeto físico. |

## Casos mínimos

1. Resolver contexto válido, esperar estabilidad y confirmar una vez.
2. Intentar confirmar con peso inestable, NET no válido o contexto ausente.
3. Escanear QR incorrecto, vencido y reemplazado.
4. Repetir F2 y simular respuesta incierta.
5. Desconectar/reconectar balanza y Central según el modo de contingencia.
6. Ejecutar dos capturas consecutivas y comprobar foco/contexto limpio.
7. Observar el recorrido completo con un trabajador representativo sin guiarlo.

## Puerta del perfil

- El peso principal se reconoce en las condiciones reales definidas por el contexto.
- **Enter resuelve; F2 confirma.** Ningún escaneo acredita el hecho.
- Estados, bloqueos y recuperaciones son inequívocos.
- Reintentos producen un solo efecto.
- No queda P0/P1 ni casi-error crítico sin resolver.
- El hardware representativo fue probado antes de `physical_uat: accepted`.
