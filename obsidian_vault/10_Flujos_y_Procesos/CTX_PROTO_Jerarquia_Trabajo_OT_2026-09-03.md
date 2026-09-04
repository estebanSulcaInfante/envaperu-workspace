---
tipo: contexto-y-wireflow
estado: refactor-local-autorizado
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
ux_risk: high
uat_profiles: [ADM, CON]
fecha_creacion: 2026-09-03
relaciones:
  - "[[US-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[DEV-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[UAT_Jerarquia_Trabajo_OT_2026-09-03]]"
---

# Contexto y contrato del refactor — Consultar trabajo frente a agregar trabajo

## Entrada y autorización

El usuario reportó durante la UAT local que el formulario «Agregar Trabajo de
color» intercalado entre la cola y las mangas hace parecer que su color gobierna
toda la página. El DOM y OtMangasScm confirman dos estados independientes:
selectedWorkId (consulta) y workForm.runId (alta). Autorización explícita:
«Vale implementemos esta mejora siguiendo el pipeline» después de proponer
separar el alta y hacer inequívoco el trabajo consultado.

Refactor acotado de interacción de DEV-010M1, bajo la autorización directa
prevista en implement-feature.md. Se mantiene el entorno exploratorio de UAT
local y la restricción previa; no es una aprobación UX-READY ni autorización de
despliegue. No se crea un nuevo flujo de negocio ni se amplía la excepción local
a producción. Validación representativa pendiente.

## Contexto operativo (TPL_Contexto_Operativo_UI v1)

- Hecho observado: Central local, perfil Said/Supervisor, OT-000002, un trabajo
  Transparente y dos mangas planificadas. Navegador de escritorio.
- Reporte: no se distingue qué selector controla las mangas; volver arriba para
  cambiar de trabajo rompe la continuidad de consulta.
- Tarea: identificar trabajo/OF/color y operar solo sus mangas; preparar otro
  trabajo como intención separada.
- No medidos: monitor físico, zoom, distancia, ruido, EPP, frecuencia y volumen
  pico. No se infieren del perfil de sesión.
- QA propuesta: viewport actual y escritorio 1440×900; datos multicolor en
  fixtures aislados, nunca crear colores de prueba en la OT de la UAT en curso.
- Sin balanza, impresora, QR físico ni cambios de custodia en este incremento.
  Se conserva riesgo high por proximidad a acciones de etiquetas y relevos.

## Cuatro contratos / wireflow (TPL_Prototipo_Operativo_UI v1)

**Dominio:** OT → trabajos → mangas. Consultar un trabajo no inicia, modifica
ni reasigna nada. La corrida del formulario solo determina el nuevo trabajo.
Estados, permisos, cantidades, QR, identidades y secuencias no cambian.

**API:** sin endpoints, payloads ni migraciones nuevos. Se mantienen las
validaciones de kg/discretización y las llamadas existentes. No se implementa
offline ni se promete idempotencia adicional a la vigente.

**Presentación:** contexto OT arriba; navegación de trabajos adyacente al detalle
y disponible durante el desplazamiento; color humano, código de trabajo, OF y
estado identifican la selección. «Consultando» no equivale a «En ejecución».
Alta en diálogo independiente, accesible por «Agregar trabajo». Sin formulario
de alta intercalado. Información diagnóstica y reglas de kg no se duplican.

| Estado | Información / acción primaria | Recuperación |
|---|---|---|
| Consulta | Trabajos de esta OT; selección marcada; detalle y mangas propios | Cambiar trabajo solo navega |
| Sin trabajos | OT sin hijos; Agregar trabajo si tiene permiso | Volver al tablero |
| Alta abierta | Agregar Trabajo de color; OT destino, OF, color, kg, maquinista | Volver sin agregar conserva borrador en memoria de esta OT |
| Cargando plan | Espera y confirmación bloqueada según contrato existente | Esperar / reintentar consulta |
| Alta lista | Agregar a la cola de esta OT, validaciones previas intactas | Editar kg/color sin cambiar trabajo consultado |
| Enviando | Botón protegido; no cerrar mientras se envía | Esperar respuesta |
| Éxito | Cerrar diálogo; consultar trabajo devuelto por Central | Ver sus mangas |
| Error | Mensaje dentro del diálogo; campos conservados | Revisar estado si respuesta incierta; no inventar éxito |
| Otra OT | Cerrar alta y descartar contexto de alta anterior | Abrir alta explícitamente para la nueva OT |

Teclado: diálogo con nombre, foco contenido y devolución al botón al volver;
selección de trabajos con estado accesible y rótulo humano; sin atajos F2 nuevos.
No ocultar el error detrás de la ventana modal.

## Verificación prevista

BASELINE: scripts/test.ps1 -Component frontend y suite focal OtMangasScm.
Primera RED: el formulario no debe estar visible al consultar una OT con trabajos.
Casos: separación de alta/consulta, navegación multicolor sin mutación, borrador
conservado al volver, error visible, éxito selecciona hijo, cambio de OT, permisos,
regresión de kg, etiquetas y relevo. Build y capturas sin mutar datos UAT.

Fuera de alcance: cambiar métricas de cola de unidades a kg, cálculos de pesaje,
inventario, contratos, roles, seed/reset y despliegue. Las unidades legacy de la
cola siguen pendientes; no se presentan como kg medidos.

Rollback: revertir únicamente el refactor y sus pruebas; sin rollback de datos.
Aceptación humana y condiciones representativas: pendientes en la UAT enlazada.
