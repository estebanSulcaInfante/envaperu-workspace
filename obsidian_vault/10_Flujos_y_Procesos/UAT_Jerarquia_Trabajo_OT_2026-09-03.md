---
tipo: uat
uat_id: UAT-M1-JERARQUIA-2026-09-03
estado: preparada-pendiente-ejecucion-humana
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
ux_risk: high
modalidades_uat: [funcional, operativa]
historia: US-010M1_OT_Maquina_y_Cola_Trabajos_Color
tech_spec: TS-010M1_OT_Maquina_y_Cola_Trabajos_Color
dev: DEV-010M1_OT_Maquina_y_Cola_Trabajos_Color
contexto_operativo: CTX_PROTO_Jerarquia_Trabajo_OT_2026-09-03
perfiles_uat: [ADM-v1, CON-v1]
fecha_creacion: 2026-09-03
relaciones:
  - "[[CTX_PROTO_Jerarquia_Trabajo_OT_2026-09-03]]"
  - "[[REC_2026-09-03_Jerarquia_Trabajo_OT]]"
---

# UAT — Distinguir consultar trabajo de agregar trabajo

## Identidad y límites (BASE)

Plantilla base TPL_UAT_Fisica_SCM v2; perfiles ADM y CON v1. Modalidad funcional
y operativa de escritorio. Sin recorrido físico nuevo: no se pesa, imprime ni
transfiere custodia. La UAT física integral de pesaje permanece pendiente por
separado; not_required aplica solo a este refactor de navegación.

- Entorno: Central local 5174 / API 5100, nunca producción.
- Responsable y participante representativo Supervisor/JP: por registrar.
- Observador, fecha, RUN_ID y zoom: completar al ejecutar; no autoaprobados.
- Dispositivo QA: navegador de escritorio; viewport actual 1049×859. Puesto real,
  volumen pico y condiciones físicas pendientes de observación.
- Dataset vigente: OT-000002, TC01 Transparente, 100 unidades planificadas =
  24 kg teóricos, dos mangas planificadas. Esos datos no se reinician.
- Dataset multicolor: preparar con responsable UAT una OT de prueba separada
  con dos trabajos distinguibles y mangas propias. Las pruebas automáticas usan
  Verde/Azul aislados; no equivalen a datos multicolor reales en la OT vigente.
- Evidencia: outputs/uat-hierarchy-2026-09-03; para sesión humana crear subcarpeta
  con RUN_ID sin sobreescribir capturas previas.
- Reiniciable: consulta/abrir/cerrar no mutan negocio. Alta exitosa se prueba
  solo en la OT de prueba autorizada. No borrar historia ni usar Reset.

## Guion de observación (BDD / CONTEXTO)

Todas las filas comienzan **PENDING**; registrar resultado, ayuda y evidencia.

| ID | Preparación y acción | Resultado que debe explicar el usuario |
|---|---|---|
| J-01 | Abrir OT-000002 e identificar trabajo y mangas | TC01, OF, color y estado; no hay formulario de alta intercalado |
| J-02 | En OT de prueba, consultar Verde y luego Azul | Cambian solo sus mangas/contexto; no se inicia ni reasigna producción |
| J-03 | Desplazarse a mangas y cambiar trabajo | Navegación disponible; tarjeta «Consultando» identifica selección, no ejecución |
| J-04 | Abrir Agregar trabajo | Diálogo con OT destino; comprende que crea un nuevo trabajo |
| J-05 | Seleccionar otro color/editar kg y volver sin agregar | Sin alta; consulta original intacta; al reabrir conserva intención en la misma OT |
| J-06 | En OT de prueba con saldo, confirmar alta válida | Un envío; espera visible; tras acuse cierra y consulta el trabajo devuelto |
| J-07 | Fallo de alta simulado en entorno aislado | Error dentro del diálogo y datos conservados; nunca afirma éxito |
| J-08 | Volver y cambiar de OT | Alta cerrada; siguiente apertura muestra destino nuevo y maquinista de esa OT |
| J-09 | Perfil sin OT_CREAR | Puede consultar según permiso, sin botón de agregar |
| J-10 | OT vacía autorizada | Explica ausencia de trabajos y ofrece Agregar trabajo, sin creación implícita |

Detener ante cambio inesperado de OT/trabajo, efecto no solicitado, pérdida de
campos durante error o imposibilidad de distinguir consulta y ejecución.

## Preguntas ADM expandidas (PERFIL:ADM-v1)

En cada fila: capturar pantalla/acción y anotar respuesta, ayuda requerida y
resultado. Estado inicial de todas: PENDING.

| Origen | Preparación / pregunta concreta | Resultado esperado / evidencia |
|---|---|---|
| ADM-01 | Pedir «consulta las mangas del segundo trabajo» sin dictar botones | Identifica Trabajos de esta OT y selecciona; recorrido observado |
| ADM-02 | OT con dos colores: ¿qué OT, trabajo y OF estás consultando? | Identidad correcta antes de operar; captura y respuesta |
| ADM-03 | Bajar hasta la tabla: ¿puedes cambiar trabajo sin buscar el formulario? | Navegación disponible, mangas legibles; captura y retrocesos |
| ADM-04 | Repetir en viewport actual y escritorio representativo | Sin overflow global; desplazamiento local de tarjetas/tabla si hace falta |
| ADM-05 | Comparar OT vacía y OT con trabajo/saldo de alta cero | No confunde «sin trabajos» con «sin saldo para agregar» |
| ADM-06 | Simular consulta de plan lenta y fallida, dentro del alta | Carga/error explícitos; confirmar no usa propuesta de otra OF |
| ADM-07 | Comparar Supervisor y perfil sin OT_CREAR | El segundo no ve alta; consulta no concede permisos |
| ADM-08 | Preparar alta y elegir Volver sin agregar | No crea, anula ni inicia; cotejar trabajos antes/después |
| ADM-09 | Abrir con teclado, recorrer Tab/Shift+Tab y volver/Escape | Foco contenido en diálogo y regreso al disparador; registrar observación |
| ADM-10 | Editar kg, volver/reabrir y luego cambiar de OT | Conserva borrador dentro de misma OT; no arrastra edición kg/persona a otra |
| ADM-11 | Seleccionar trabajo planificado: ¿«Consultando» indica fabricación? | Usuario distingue navegación del estado PLANIFICADO/EN EJECUCIÓN |
| ADM-12 | Abrir Ver OF desde alta | Nueva pestaña de OF correcta; formulario conserva contexto y no envía alta |

## Preguntas CON expandidas (PERFIL:CON-v1)

Modo **bloqueo-seguro** según TS-010M1. Sin outbox/offline nuevo. Las pruebas de
red se ejecutan en entorno aislado sin detener servicios de la UAT compartida.

| Origen | Preparación / criterio concreto | Resultado esperado / evidencia |
|---|---|---|
| CON-01 | Identificar qué confirma la creación | Solo respuesta autoritativa de Central, no seleccionar color ni cerrar diálogo |
| CON-02 | GET de propuesta falla antes de asignar | Mensaje y Reintentar consulta; no habilita alta con plan ajeno |
| CON-03 | Con plan cargado, POST devuelve error | Error dentro del diálogo; kg y maquinista conservados; sin éxito falso |
| CON-04 | Respuesta de alta perdida | No afirmar alta ni pulsar repetidamente; volver y consultar OT antes de decidir; registrar ID/estado central |
| CON-05 | Recargar navegador tras borrador no enviado | No prometer persistencia durable del borrador; trabajos reales consultados desde Central |
| CON-07 | Durante POST pendiente, repetir click/Escape | Confirmación y cierre bloqueados; una llamada desde esa interacción; idempotencia servidor sin cambios |
| CON-09 | Observar alta pendiente frente a acuse | «Agregando trabajo…» no es trabajo confirmado; éxito solo tras acuse |
| CON-10 | Abrir/cerrar/cambiar selección y simular error | No se generan ni imprimen preetiquetas automáticamente |
| CON-11 | Leer error de consulta | Reintento explícito de consulta; si POST es incierto verificar Central antes de repetir |
| CON-12 | Adjuntar logs y capturas | Sin secretos, tokens ni configuración de base productiva |

Descartes justificados: CON-06 no hay objeto físico en este refactor; CON-08 no
se modifica reserva/conciliación de stock. PES/LEC/MQR/IMP no se seleccionan:
no hay nuevo escaneo, pesaje, multi-QR ni salida impresa. Los contratos existentes
de etiquetas/relevos se regresan automáticamente, su UAT física no se sustituye.

## Cierre humano

Registrar por separado: aceptación funcional, operabilidad, participante/rol,
fecha, dispositivo, dudas/retrocesos/ayudas, desvíos y decisión. No marcar
uat_accepted ni ux_ready a partir de tests automáticos o revisión del agente.
Mantener no_habilitar_en_planta mientras falten gates integrales aplicables.
