---
tipo: plan_operativo
estado: en_ejecucion
fecha: 2026-08-07
fecha_actualizacion: 2026-08-10
responsables: [Esteban, Renato]
tags: [scm, piloto, uat, marcha-blanca, datos-maestros, alcancia-pablo]
relaciones:
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[UAT_TS-010M_OT_y_Trabajos_Color]]"
  - "[[UAT_02_Maestros_e_Imagenes]]"
  - "[[UAT_TS-010P_Flujo_Demanda_Fabricacion_Armado]]"
  - "[[UAT_TS-010C_D_OT_Mangas_Pesaje]]"
  - "[[UAT_TS-010I_Recepcion_Mangas_Kardex]]"
  - "[[UAT_TS-010E_J_Merma_Molienda_Alertas]]"
  - "[[US-010N_Navegacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[US-010N4_Supervision_de_Produccion_Read_Model_Operativo]]"
  - "[[UAT_TS-010N4_Supervision_de_Produccion]]"
---

# Plan de cierre UAT y marcha blanca SCM

## Objetivo

Completar las UAT del piloto SCM usando **Alcancía Pablo Grande** como producto
trazador, recopilar y cargar los maestros faltantes, y ejecutar una marcha
blanca controlada contra el sistema anterior sin establecer dos fuentes de
verdad.

## Punto de partida

- Participantes, autenticación y vistas por rol ya fueron probados.
- Los maestros base y la ingeniería SCM fueron recorridos durante la UAT.
- Para Alcancía Pablo ya existen la PiezaColor y el ProductoTerminado.
- El siguiente cierre funcional es validar y publicar BOM, ruta y empaque;
  después continúa OP, cobertura y ejecución extremo a extremo.
- La sigla vigente es **OA: Orden de Armado**.
- El refactor [[US-010M_OT_de_Maquina_y_Trabajo_de_Color|US-010M]] forma parte
  del piloto: OT es la jornada de máquina/turno y Trabajo de color es la unidad
  atómica. M1–M3 están implementadas localmente y sus suites están verdes; aún
  deben migrarse al entorno UAT y aprobarse con hardware real antes del pesaje
  productivo.
- [[US-010N_Navegacion_SCM_y_Workspace_por_Capacidades|US-010N]] reorganiza la
  experiencia sin cambiar el dominio: Planificación proyecta OF/OA,
  Producción ejecuta, Materiales prepara, Almacén custodia y Control concentra
  excepciones. N1/N2 deben revalidarse con los perfiles UAT antes del recorrido
  integral. N1/N2 están desplegados; [[UAT_TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades|UAT-N2]]
  conserva pendientes solo para perfil limitado, multirrol y confirmación táctil.
- [[US-010N4_Supervision_de_Produccion_Read_Model_Operativo|US-010N4]] añade en
  Control una consulta transversal de Fabricación y Armado. Está implementada
  localmente con suites backend/frontend, lint y build verdes; el smoke visual
  y su UAT humana permanecen pendientes. No sustituye Jornadas ni convierte el
  read model en fuente de comandos.

## Responsabilidades

| Responsable | Función |
|---|---|
| Renato | Recopilar evidencia, cargar maestros, ejecutar pasos UAT y registrar resultados. |
| Esteban | Resolver decisiones de dominio, desbloquear defectos, aprobar baseline y firmar go/no-go. |
| Producción / Almacén | Confirmar datos físicos, reglas operativas, pesos, capacidades y diferencias. |

Renato debe ser invitado a ClickUp para recibir asignaciones directas. Hasta
entonces las tareas permanecen asignadas a Esteban e indican a Renato como
responsable operativo.

## Agenda recomendada para el 8 de agosto

| Bloque | Trabajo | Salida |
|---|---|---|
| 09:00-09:30 | Acceso, alcance, producto trazador y reglas de evidencia | Sesión lista y responsables confirmados |
| 09:30-11:00 | Dataset mínimo de Alcancía Pablo | Maestros sin bloqueos conocidos |
| 11:00-12:30 | BOM, ruta, centro y empaque | Ingeniería publicada |
| 13:30-15:00 | UAT de maestros e imágenes | UAT 02 cerrada o incidencias registradas |
| 15:00-16:00 | Plantilla para recopilar maestros restantes | Matriz lista para trabajo por lotes |
| 16:00-17:00 | Triage y preparación de OP/cobertura | Decisión continuar, repetir o detener |

Los horarios pueden ajustarse; el orden y los entregables no deben cambiar.

## Recopilación de datos faltantes

La hoja de cálculo puede funcionar como bandeja de recopilación, pero SCM será
la fuente oficial una vez que el dato esté validado y cargado.

### Columnas obligatorias

- entidad o catálogo;
- código o SKU;
- campo requerido y unidad;
- valor;
- fuente o evidencia;
- persona que confirma;
- estado: `PENDIENTE`, `RECOPILADO`, `VALIDADO`, `CARGADO` o `RECHAZADO`;
- fecha de validación;
- observaciones.

### Lotes de recopilación

1. Piezas, PiezaColor, imágenes y moldes.
2. ProductosTerminados y presentaciones comerciales.
3. Líneas, familias, colores y recetas.
4. Materiales, proveedores y políticas.
5. Máquinas y centros de trabajo.
6. BOM, WIP y rutas.
7. Contenedores, perfiles empacables y reglas de empaque.

No deben inventarse datos para completar formularios. Un dato desconocido se
marca pendiente y se escala con la fuente que falta.

## Secuencia UAT

| Fecha objetivo | UAT | Resultado mínimo |
|---|---|---|
| 8 ago | 01 Acceso y perfiles | Identidad real, vistas correctas y usuario desactivado bloqueado |
| 8-9 ago | N Navegación e Inicio por capacidades | Kardex, Preparación y ejecución encontrables; rol nuevo proyectado sin código específico |
| 8 ago | 02 Maestros, imágenes e ingeniería | Alcancía Pablo lista para planificación |
| 8 ago | 03 OP, cobertura y planificación | OP aprobada y plan confirmado para producir el lunes |
| 9 ago | 04 Materiales, reserva, emisión y premezcla | Disponibilidad y preparación verificadas |
| 8-9 ago | M Refactor OT/Trabajo de color | M1–M3 automáticas verdes y UAT-M con dos colores/relevo aprobada |
| 9 ago | 05 OF, OA y OT | Documentos liberados; OT única del lunes con cola y cuotas por Trabajo de color |
| 9 ago | 06 Mangas y preetiquetas | Mangas planificadas, QR únicos y preetiquetas listas |
| 10 ago | 07 Pesaje y postetiqueta | Registrar pesajes reales desde el inicio del turno y emitir postetiqueta trazable |
| 10-11 ago | 09 Recepción, Calidad y Kardex | Existencia creada una sola vez |
| 11 ago | 08 Corrección y ANULAR_PESAJE | Cupo restituido y manga de reemplazo permitida |
| 11 ago | 10 Reversa y stickers 11213-11216 | Toda etiqueta explicada |
| 12 ago | 11 Merma, molienda, reproceso y alertas | Genealogía sin doble uso |
| 12-13 ago | 12 Repetición E2E limpia | Ejecución sin intervención técnica y decisión de continuidad |
| 12-13 ago | N4 Supervisión de producción | Lista/detalle y resumen DIA/MES conciliados, permisos parciales y cero mutaciones; UAT humana firmada |

## Corte operativo para iniciar pesajes el lunes 10 de agosto

El domingo 9 de agosto, antes de cerrar la preparación, deben cumplirse todos
los siguientes puntos:

1. BOM, ruta y reglas de empaque aplicables están publicadas.
2. La OP de Alcancía Pablo Grande está aprobada y su plan está confirmado.
3. M1, M2 y M3 están implementadas; migración, E2E y UAT-M están verdes.
4. Las OF/OA necesarias están liberadas y la OT del lunes está creada con sus
   Trabajos de color.
5. Las mangas y preetiquetas del primer lote están preparadas, asignadas por
   subconjuntos a maquinistas y sus QR son
   únicos.
6. Usuario, perfil, balanza, impresora, red y estación de pesaje fueron
   verificados con una prueba de humo que no altera inventario.
7. El responsable del turno conoce el RUN_ID y el procedimiento de
   contingencia.

Si falla cualquiera de los puntos 1 a 6, no se registra un pesaje productivo
en SCM hasta corregirlo. No se improvisan maestros ni se borran registros para
desbloquear la operación.

## Evidencia y severidad

Cada ejecución registra UAT, RUN_ID, actor, entorno, pasos, resultado esperado,
resultado real, evidencia, datos afectados y criterio de revalidación.

| Severidad | Definición | Regla |
|---|---|---|
| P0 | Seguridad, corrupción o pérdida de datos | Detener inmediatamente |
| P1 | Bloquea el flujo sin workaround aceptable | Corregir antes de continuar |
| P2 | Defecto parcial con workaround | Corregir o aceptar explícitamente antes del go-live |
| P3 | Presentación, texto o QoL | Backlog priorizado |

Los defectos de trazabilidad, inventario, pesaje, permisos y migraciones deben
tener prueba automática además de revalidación manual.

## Marcha blanca

### Principio de control

Durante la marcha blanca el **sistema anterior es la fuente operativa oficial**
y SCM funciona como sistema sombra. Esto evita dos fuentes de verdad.

Supervisión N4, cuando esté disponible, sirve para consulta y conciliación del
universo SCM normalizado. No cambia cuál sistema es la fuente oficial durante
la marcha blanca y no incorpora los snapshots legacy dentro de sus totales.

La OP de Alcancía Pablo Grande inicia una **captura productiva controlada** en
SCM el lunes 10 de agosto. Como las UAT posteriores al pesaje todavía estarán
en curso, este arranque anticipado no equivale al go-live: el sistema anterior
continúa siendo el respaldo oficial hasta cerrar la conciliación y los
criterios de salida.

- La misma operación utiliza una referencia o RUN_ID común.
- El registro sombra se completa dentro de 15 minutos.
- Las diferencias se corrigen, anulan o revierten; nunca se borran.
- Los stickers SCM se identifican como piloto y no habilitan por sí solos el
  despacho comercial.
- La conciliación se realiza al cierre de cada jornada.

### Calendario

| Fecha | Jornada |
|---|---|
| 9 ago | Preparar protocolo, baseline, responsables, OT, mangas y plantilla de conciliación |
| 10 ago | Jornada 1: pesaje real y postetiqueta desde el inicio del turno; recepción controlada |
| 11 ago | Jornada 2: continuidad, corrección, anulación, reversa y reemplazo |
| 12 ago | Jornada 3: continuidad, merma/reproceso y conciliación operativa |
| 13 ago | Conciliación acumulada y decisión de ampliar, corregir o detener la marcha blanca |

### Conciliación diaria

1. OP, OF, OA, OT y Trabajos de color equivalentes.
2. Cantidades objetivo, producidas, pesadas y recibidas.
3. Peso bruto, tara y neto.
4. QR y stickers: emitido, vigente, anulado o reemplazado.
5. Inventario y Kardex.
6. Correcciones, devoluciones y reversas.
7. Diferencia, causa, responsable y resolución.
8. En Supervisión N4: una fila por OT, unidades efectivas, kg físico y kg
   estándar separados, `as_of` y dimensiones ocultas por permiso documentadas.

### Criterios de entrada

- corte operativo del domingo aprobado;
- UAT 01 a 06 aprobadas para la OP trazadora;
- UAT-M aprobada, sin cruce de manga a otra OT ni material preparado;
- cero P0/P1 abiertos;
- baseline de maestros de Alcancía Pablo congelada;
- usuarios, impresora, balanza y conectividad disponibles;
- plan de contingencia confirmado.

### Criterios de salida

- tres jornadas completas conciliadas;
- 100 % de stickers explicados;
- cero diferencias de inventario sin causa;
- cero pérdida de trazabilidad;
- P2 corregidos o aceptados explícitamente;
- UAT-N4 diaria/mensual aprobada, sin P0/P1, doble conteo, fuga de permisos ni
  mutaciones desde la vista;
- firma de Gerencia y Producción.

## Enlaces ClickUp

- [Datos maestros y preparación](https://app.clickup.com/90171442446/v/l/li/901715903489)
- [Ejecución UAT extremo a extremo](https://app.clickup.com/90171442446/v/l/li/901715903487)
- [Incidencias y correcciones](https://app.clickup.com/90171442446/v/l/li/901715903486)
- [Marcha blanca y conciliación](https://app.clickup.com/90171442446/v/l/li/901715903488)

ClickUp alcanzó su cuota de escritura al crear el proyecto. Las fechas
comprimidas para iniciar pesajes el 10 de agosto todavía no están sincronizadas
allí. Al renovarse la cuota deben actualizarse las UAT 03 a 12 y crearse las
tareas diarias de marcha blanca usando este documento como cronograma vigente.
