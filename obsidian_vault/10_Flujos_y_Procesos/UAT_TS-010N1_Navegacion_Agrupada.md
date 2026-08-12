---
tipo: uat
estado: en-ejecucion
tags: [scm, uat, frontend, navegacion, responsive]
relaciones:
  - "[[US-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
  - "[[TS-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
  - "[[DEV-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# UAT TS-010N1: navegación agrupada

## Objetivo

Confirmar que el workspace agrupa el SCM por trabajo real sin cambiar URLs,
permisos, comandos ni fuentes de datos.

## Precondiciones

- versión N1 desplegada;
- sesión Gerente General y una sesión de alcance limitado;
- ancho de escritorio y un teléfono o emulación de 390 px;
- `VITE_SCM_SHOW_LEGACY=false` en producción.

## Recorrido

| Caso | Acción | Resultado esperado |
|---|---|---|
| N1-U01 | Abrir `/produccion/kardex` | Se activa **Almacén e inventario** y se muestran Kardex y Recepción/Calidad. |
| N1-U02 | Abrir `/materiales/preparaciones` | Se activa **Materiales**, no Producción. |
| N1-U03 | Abrir OF, Jornadas/Trabajos de color y OA | Las tres vistas permanecen en **Producción**. |
| N1-U04 | Abrir Avance, Alertas y Pesajes | Las vistas aparecen bajo **Control**. |
| N1-U05 | Abrir Datos maestros | Existe un solo hub con cinco familias; cada enlace abre el CRUD existente. |
| N1-U06 | Abrir una URL fuera del piloto | Se muestra la frontera informativa y no se monta el formulario prototipo. |
| N1-U07 | Probar un perfil limitado | Solo aparecen áreas con al menos una función permitida; la API conserva la autoridad. |
| N1-U08 | Confirmar un plan | La tabla ofrece continuar en OF u OA sin copiar controles de ejecución. |
| N1-U09 | Probar 390, 768 y 1440 px | No hay tabs globales ni scroll horizontal del shell; el drawer es utilizable por teclado. |
| N1-U10 | Usar un marcador con URL histórica | La página abre y queda clasificada en el área nueva correspondiente. |

## Criterio de aceptación

- todos los casos aprobados;
- cero acceso productivo a mocks o prototipos;
- cero pérdida de accesos legítimos por rol;
- cero cambio de endpoint o dato operativo;
- cualquier defecto de tabla interna no se confunde con desborde del shell.

## Evidencia automática previa

- 44 archivos / 190 pruebas verdes en el hardening N1.1 local;
- build productivo verde;
- lint sin errores, con una advertencia preexistente aceptada.

## Ejecución remota — 2026-08-08

Versión: frontend `6df4d28`, bundle `assets/index-Amrktyas.js`.

| Caso | Estado | Evidencia |
|---|---|---|
| N1-U01 | APROBADO | `/produccion/kardex` activa Almacén y muestra Recepción/Calidad + Kardex. |
| N1-U02 | APROBADO | Usuario confirmó que Preparación activa Materiales y muestra sus secciones. |
| N1-U03 | AUTOMATIZADO | OF, Trabajo de color y OA permanecen en Producción. |
| N1-U04 | AUTOMATIZADO | Avance, Alertas y Pesajes resuelven Control. |
| N1-U05 | PENDIENTE HUMANO | Revisar los cinco grupos y abrir un maestro real. |
| N1-U06 | APROBADO | URL de recepción externa muestra frontera; Administración y prototipos están ocultos. |
| N1-U07 | PENDIENTE HUMANO | Requiere sesión de alcance limitado. |
| N1-U08 | PENDIENTE HUMANO | Requiere un plan confirmado con OF/OA. |
| N1-U09 | APROBADO | 390 px sin overflow, con drawer y sin `tablist` global. |
| N1-U10 | APROBADO | La URL histórica de Kardex abre la vista canónica sin redirección destructiva. |

La UAT no se cierra todavía: faltan N1-U05, N1-U07, N1-U08 y la confirmación
humana de N1-U03/N1-U04.

## Hallazgo N1-H01 — semántica del recorrido operativo

Durante N1-U03 se detectó que `ProcessJourney` mostraba “OP aprobada” y “OF
liberada” como texto estático aunque esos documentos no existieran. El resaltado
solo indicaba la pantalla activa, por lo que podía confundirse con el estado real
mostrado en Planificación.

Resolución desplegada:

- commit frontend `596ba2d`;
- rótulo **Recorrido operativo / Navegación entre etapas**;
- textos neutrales de acción: definir, configurar, programar, registrar y recibir;
- `aria-current="step"` expresa ubicación, no cumplimiento;
- los estados aprobada/liberada permanecen exclusivamente en OP/OF/OA;
- bundle productivo verificado: `assets/index-CJQ-96rS.js`;
- 41 archivos / 174 pruebas verdes.

Estado: **RESUELTO Y VERIFICADO EN RENDER**.

### Refinamiento por consistencia OF/OA

El usuario detectó que el paso 2 seguía cambiando entre “Fabricación” y
“Armado” según la pantalla, mientras Planificación mostraba únicamente OF. El
recorrido global no puede mutar y una OP puede generar ambas familias.

- commit `6a7beeb`;
- paso estable: **2. Órdenes técnicas · OF y OA**;
- el paso agrupador no navega a una familia arbitraria; OF y OA se eligen en el
  submenú de Producción;
- Planificación, Fabricación y Armado muestran exactamente el mismo rótulo;
- verificación Render: cero “2. Fabricación” y cero “2. Armado” en las tres
  vistas;
- bundle `assets/index-eMik2xsT.js`, 174 pruebas verdes.

## Hardening N1.1 local previo a N2 — 2026-08-08

Se corrigieron los riesgos estructurales detectados durante la revisión UX/UI:

| Caso | Estado local | Evidencia |
|---|---|---|
| N1-H02 | AUTOMATIZADO | Un perfil con solo OA, Calidad o Molienda aterriza en su primera función visible y no en OF/Kardex/Preparación por defecto. |
| N1-H03 | AUTOMATIZADO | La identidad en carga o error no monta vistas ni habilita capacidades; existe reintento explícito. |
| N1-H04 | AUTOMATIZADO | Todas las rutas canónicas consumen capacidad y madurez desde el registro por `feature_key`. |
| N1-H05 | VERIFICADO LOCAL | 390, 768, 899, 901, 1200 y 1440 px sin discontinuidad del shell ni overflow global. |
| N1-H06 | VERIFICADO LOCAL | OA móvil, recorrido operativo y Datos maestros no ocultan controles; el catálogo usa tarjetas en móvil. |
| N1-H07 | AUTOMATIZADO | Navegación anidada semántica, único `aria-current`, salto al contenido, foco al cambiar ruta y búsqueda con nombre accesible. |
| N1-H08 | AUTOMATIZADO | OF y OA sin documentos muestran estado vacío explicativo y acceso a Planificación cuando corresponde. |
| N1-H09 | VERIFICADO LOCAL | Los padres desplegables y sus hijos ocupan el mismo ancho clicable. Producción y su hijo activo midieron `231.33 px`; el extremo derecho del padre expandió y contrajo el área. |

Resultado automático final: **44 archivos / 190 pruebas**, lint sin errores y
build productivo verde.

Despliegue Render:

- commit frontend `dddf169`;
- deploy `dep-d9rq4pifngtc73dv7fag` en estado `live`;
- respuesta HTTP 200 y bundle `assets/index-Qp1CyoBG.js`;
- queda pendiente la confirmación humana remota de N1-U05, N1-U07 y N1-U08.
