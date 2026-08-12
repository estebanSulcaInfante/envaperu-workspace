---
tipo: guia-uat
estado: en-ejecucion
fecha_creacion: 2026-08-04
fecha_actualizacion: 2026-08-10
base_datos: envaperu_test
revision_minima: f64b3d9e5a81
run_id: UAT-PILOTO-2026-08-04-02
tags: [uat, maestros, piezas, pieza-color, moldes, imagenes]
---

# UAT 02 — Maestros e imágenes

## Objetivo

Validar la clasificación, las máquinas, los moldes de varias salidas y el catálogo físico por color antes de crear productos, estructuras y rutas.

## Regla de integridad principal

`Pieza` es una forma abstracta. `PiezaColor` es la identidad física fabricable y posee SKU, color e imagen. En un molde de varias salidas, un color se habilita para el tiro completo: el sistema debe crear o reutilizar las variantes de todas las piezas activas del molde.

## Datos creados durante la UAT

| Maestro | Registro |
|---|---|
| Línea | `LIN-000001 · Hogar` |
| Familia | `FAM-000002 · JARDIN` |
| Máquina | `MAQ-000001 · Haitian 3000` |
| Molde | `ML-000001 · Molde Jarra Regadera` |
| Salidas | `PZ-000001` Tapa, `PZ-000002` Pico y `PZ-000003` Cuerpo |

El serial temporal `9999999` de la máquina debe reemplazarse por el dato real antes de aprobar el maestro para operación.

## M-01 — Clasificación

0. Abrir **Datos maestros** desde el sidebar y confirmar que conduce al hub
   `/datos-maestros`, no directamente a Productos terminados. El hub debe
   mostrar todos los catálogos autorizados para el perfil.

1. Confirmar que Línea y Familia están activas y asociadas.
2. Verificar que las tres piezas utilizan la misma clasificación válida.

Resultado actual: aprobado.

## M-02 — Máquina y molde

1. Confirmar máquina, tipo de máquina y estado.
2. Abrir el molde y comprobar sus tres salidas, cavidades y pesos operativos.
3. Confirmar peso neto del tiro y colada.

Resultado actual: estructura creada; pendiente sustituir el serial temporal.

## M-03 — Pieza abstracta y catálogo desplegable

1. Abrir **Datos maestros → Piezas y SKU**.
2. Desplegar una pieza.
3. Confirmar que la fila principal muestra forma, clasificación, peso nominal y moldes.
4. Confirmar que el nivel desplegado muestra los SKU físicos por color.
5. Confirmar que la Pieza abstracta no solicita imagen.

Resultado actual: validado automáticamente y en navegador.

## M-04 — Habilitación atómica de color

Requisito: crear al menos un Color de producción real.

1. Desde cualquiera de las tres piezas, elegir **Habilitar color**.
2. Seleccionar `ML-000001` y el color.
3. Confirmar la advertencia de que se aplicará al tiro completo.
4. Guardar.
5. Desplegar las tres piezas y comprobar una PiezaColor por cada salida, todas del mismo color y con SKU diferente.
6. Repetir la habilitación y confirmar que no se crean duplicados.

Resultado esperado: tres variantes creadas la primera vez y tres reutilizadas al repetir.

### Evidencia de ejecución — 2026-08-04

| Maestro/variante | Resultado |
|---|---|
| Familia de color | `FC-000001 · SÓLIDO` activa |
| Color de producción | `VERDE SÓLIDO`, ID 1, sin HEX inventado |
| `PC-000001` | `PZ-000001 · Tapa De Jarra Regadera`, `EN_REVISION` |
| `PC-000002` | `PZ-000002 · Pico De Jarra Regadera`, `EN_REVISION` |
| `PC-000003` | `PZ-000003 · Cuerpo De Jarra Regadera`, `EN_REVISION` |

La interfaz mostró una variante en cada una de las tres piezas y PostgreSQL confirmó exactamente tres filas para la combinación. La idempotencia y reutilización sin duplicados también permanecen cubiertas por la prueba automática del comando.

Resultado actual: **aprobado**.

## M-05 — Imagen por PiezaColor

1. Abrir una variante desde el nivel desplegado.
2. Cargar JPG, PNG o WebP de hasta 2 MB.
3. Guardar, recargar y confirmar la imagen.
4. Cambiarla y luego quitarla para validar el ciclo completo.

No usar una imagen genérica en la Pieza abstracta. La fotografía debe representar la variante física y su color.

Resultado actual: pendiente de fotografías representativas de tapa, pico y cuerpo en VERDE SÓLIDO.

## Evidencia automática

- Backend: 26 pruebas de catálogo, molde e integridad aprobadas.
- Frontend: 10 pruebas de catálogo jerárquico e imágenes aprobadas.
- Compilación de producción aprobada.
- Migración aplicada en `envaperu_test`: `f63a2c8d4e70`.

## M-06 — ProductoTerminado y política de conservación

1. Crear únicamente la identidad comercial; la composición debe permanecer en Ingeniería SCM.
2. Confirmar SKU automático e inmutable.
3. Confirmar que la tabla ofrece **Desactivar/Reactivar**, nunca eliminación física.
4. Invocar técnicamente `DELETE /api/productos/{sku}` y comprobar `409` con `ELIMINACION_DIRECTA_BLOQUEADA`.

Evidencia del 2026-08-04:

- creado `PT-000001 · Jarra Regadera`, Línea Hogar y Familia JARDIN;
- referencias logísticas e imagen dejadas vacías por falta de datos aprobados;
- regresión visual y de backend de eliminación directa detectada y corregida;
- 21 pruebas de contrato backend y 6 pruebas frontend aprobadas;
- navegador confirmado con acción `Desactivar PT-000001`.

Resultado actual: **aprobado**.

## M-07 — Estructura BOM revisionada

1. Seleccionar `PT-000001 · Jarra Regadera` como artículo resultado.
2. Crear una revisión con una unidad de cada PiezaColor confirmada.
3. Enviar el borrador a aprobación con su autor.
4. Aprobar con una identidad diferente que posea `ESTRUCTURA_APROBAR`.
5. Confirmar que la revisión aprobada conserva composición y hash de contenido.

Evidencia del 2026-08-04:

- revisión 1 creada por actor 1, Gerente General;
- componentes `PC-000001`, `PC-000002` y `PC-000003`, cada uno `1 UN`, merma técnica `0 %`;
- revisión enviada y aprobada por actor 3, María José — Jefe de Producción;
- estado final `APROBADA`, versión 3;
- pantalla verificada mostrando los tres componentes y sus cantidades.

Resultado actual: **aprobado**.

## M-08 — WIP multinivel y rechazo de una BOM incorrecta

Durante la ampliación de la UAT se registraron:

- `PZ-000004 · Asa de Jarra Regadera`, peso nominal 7 g;
- `ML-000002 · Molde Asas de Jarra Regadera`, 10 cavidades, 70 g netos por
  golpe y 100 g de tiro completo;
- `PC-000004 · Asa de Jarra Regadera VERDE SÓLIDO`;
- `WIP-000001 · Jarra Regadera VERDE SÓLIDO prearmada`.

La BOM esperada para `WIP-000001` incorpora una unidad de `PC-000001`,
`PC-000002`, `PC-000003` y `PC-000004`, con merma técnica 0 %. La merma de
inyección no forma parte de esta BOM discreta.

### Hallazgo bloqueante

Por selección incorrecta del artículo resultado se creó una revisión sobre
`PC-000001`. La interfaz excluyó correctamente `PC-000001` de sus propios
componentes, pero permitió que una PiezaColor fuera resultado de una BOM.

La revisión se envió a aprobación para probar su salida controlada:

- Gerente General, como creador, fue bloqueado correctamente por segregación;
- Jefe de Producción pudo aprobar, pero no rechazar;
- el modelo declara el estado `RECHAZADA`, pero la API y la interfaz no
  implementan la transición;
- tampoco existe una acción para descartar un borrador antes de enviarlo.

El incremento `f64b3d9e5a81` implementó:

1. rechazo por un actor distinto con `ESTRUCTURA_APROBAR`;
2. motivo obligatorio, fecha, actor y evento auditable;
3. descarte controlado de borradores sin eliminación física;
4. restricción frontend y backend: PiezaColor no puede ser resultado de BOM;
5. selector de componentes ajustado al alcance del piloto, conservando WIP
   como componente válido para estructuras multinivel.

Evidencia automática: 17 pruebas backend relacionadas con artículos,
estructuras y rutas; 6 pruebas de la vista; build Vite aprobado. Navegador UAT
confirmó que el selector de resultado solo muestra PT/WIP y que Jefe de
Producción ve **Aprobar** y **Rechazar**.

Resultado actual: **incremento aprobado; pendiente ejecutar el rechazo manual
de la revisión incorrecta y crear la BOM de `WIP-000001`**.

## M-09 — Retiro e historial de revisiones BOM

Durante la continuación se descartó `PT-000001` revisión 2 y se retiró su
revisión 1. El retiro no se revierte: una revisión publicada y retirada es un
hecho histórico inmutable. Para recuperar su composición se crea una revisión
nueva basada en ella y se repite la aprobación.

La interfaz quedó ajustada para evitar nuevas selecciones accidentales:

1. no preselecciona ningún resultado; el usuario debe elegir explícitamente un
   WIP o ProductoTerminado;
2. separa las revisiones vigentes/en preparación del historial rechazado,
   retirado o descartado;
3. exige confirmación antes de retirar y explica que no habrá reactivación;
4. ofrece **Crear nueva basada en esta** para copiar notas y componentes de una
   revisión histórica a un nuevo borrador;
5. bloquea esa copia cuando ya existe un borrador o una revisión pendiente para
   el mismo resultado.

Evidencia automática: 8 pruebas Vitest de Ingeniería SCM y build Vite
aprobados. Verificación visual local confirmó el selector vacío, la instrucción
explícita y el botón **Nueva revisión** deshabilitado hasta escoger el resultado.
La revisión móvil posterior corrigió la superposición entre la etiqueta
**Artículo resultado** y su placeholder, sin alterar dichas validaciones.

Estado de datos al cierre: `PC-000001` revisión 1 `RECHAZADA`; `PT-000001`
revisión 1 `RETIRADA`; `PT-000001` revisión 2 `DESCARTADA`. Aún corresponde
crear y aprobar primero la BOM de `WIP-000001` y luego una nueva revisión de
`PT-000001` que consuma ese WIP.

### Comprobación posterior de aprobación

La consulta directa en `envaperu_test` confirmó:

- `WIP-000001` revisión 1 `APROBADA`, con `PC-000001`, `PC-000002`,
  `PC-000003` y `PC-000004`, una unidad de cada uno: composición correcta;
- `PT-000001` revisión 3 `APROBADA`, pero conserva como componentes directos
  `PC-000001`, `PC-000002` y `PC-000003`: no consume `WIP-000001`.

Por tanto, la aprobación técnica funciona, pero la estructura multinivel aún
no está cerrada. Debe crearse `PT-000001` revisión 4 con un único componente
`1 × WIP-000001`; una jefatura o Gerencia puede publicarla directamente. Al
publicarla, el servicio retirará automáticamente la revisión 3 anterior. No
iniciar la UAT de rutas hasta completar esta corrección.

### Ajuste de gobierno aprobado por negocio

Se reemplazó la segregación obligatoria para publicación de BOM por una
capacidad explícita de jefatura. `GERENTE_GENERAL`, `GERENCIA`,
`JEFE_PRODUCCION`, `JEFE_ENSAMBLE` y futuros roles `JEFE_*` pueden crear y
publicar directamente un borrador. Los demás administradores deben enviarlo a
aprobación. La publicación directa mantiene validaciones, evento auditable e
inmutabilidad del historial.

### Alcance corregido del WIP

Negocio aclaró que el prearmado concurrente en máquina une únicamente
`cuerpo + asa`. Pico y tapa permanecen separados hasta el armado en mesa. Por
tanto, el WIP no debe agrupar las cuatro PiezaColor:

- nueva revisión de `WIP-000001`: `1 × PC-000003 cuerpo` +
  `1 × PC-000004 asa`;
- nueva revisión de `PT-000001`: `1 × WIP-000001` +
  `1 × PC-000001 tapa` + `1 × PC-000002 pico`.

La ruta debe distinguir `PREARMADO_CONCURRENTE`, con salida WIP y permiso de
concurrencia, de `ENSAMBLE_MESA`, con salida PT. Esta aclaración reemplaza la
confirmación anterior que agrupaba las cuatro piezas dentro del WIP.

#### Variación diaria de ejecución

La BOM no cambia si un día `cuerpo + asa` se prearma entre ciclos y otro día se
ejecuta completamente en mesa. La misma operación produce el mismo
`WIP-000001`; la OT diaria selecciona modalidad y centro de ejecución. No se
eliminan ni alternan estructuras.

Brecha cerrada el 2026-08-04: al crear una OT diaria de Armado se selecciona
explícitamente **En mesa de armado** o **Concurrente con fabricación**. La
segunda opción solo aparece cuando la operación de ruta permite concurrencia y
exige vincular una OT de Fabricación activa de la misma fecha operativa. El
sistema conserva `modo_ejecucion_armado` y
`ot_fabricacion_contexto_id`; el vínculo aporta contexto y responsabilidad,
pero no acredita el peso del asa como producción de máquina.

Validación automática: 12 pruebas backend focalizadas, 4 pruebas de la vista de
Armado y build de frontend aprobados. Migración `f67e6a2c8db4` aplicada en
`envaperu_test`.

Pendiente manual de esta UAT: publicar las revisiones corregidas de WIP y PT,
y definir una sola ruta del PT con dos operaciones secuenciales:
`PREARMADO` (salida WIP, permite concurrencia) y `ENSAMBLE` (salida PT en mesa).

QoL validado durante la corrección del PT: el editor de BOM muestra debajo de
una WIP seleccionada su composición aprobada vigente. Para `WIP-000001`, la
revisión 2 aprobada muestra `1 × PC-000003 cuerpo + 1 × PC-000004 asa`.

Resultado manual posterior: `PT-000001` revisión 5 fue publicada con
`1 × WIP-000001 + 1 × PC-000001 tapa + 1 × PC-000002 pico`. El editor de ruta
ya expone la concurrencia para operaciones `PREARMADO`. Antes de crear la ruta
queda crear el centro activo `Prearmado en línea`, tipo `PREARMADO`.

Continuación de rutas: se creó `CT-000002 · Prearmado en Maquina`, tipo
`PREARMADO`. Las claves de operación pasan a ser internas y automáticas. Se
incorporó `RUTA_PUBLICAR_DIRECTO` para `JEFE_*`, `GERENCIA` y
`GERENTE_GENERAL`; la migración `f68a7b3d9ec5` quedó aplicada en
`envaperu_test`.

Incidencia de interfaz cerrada: la tarjeta de una ruta en borrador dentro de
**Rutas** ahora ofrece la misma acción **Publicar** que **Aprobaciones** para
jefaturas y gerencia. Una prueba automática valida que la publicación se pueda
ejecutar desde la propia tarjeta.

Incidencia de empaque cerrada: el selector **Artículo empacable** ya incluye
ProductoTerminado además de PiezaColor y WIP. La exclusión era únicamente de
frontend; backend, dominio y ejecución de Armado ya admitían perfiles para PT.
La asociación de un PT con su perfil predeterminado quedó cubierta por prueba
automática.

QoL de comprobación: la pestaña Empaque muestra una tabla **Asignaciones
actuales** alimentada por `GET /articulos/{id}/perfiles-empaque`. La UAT puede
verificar la persistencia de WIP y PT después de asignarlos y usar **Cambiar**
para precargar la relación vigente.

QoL de catálogos de alta cardinalidad: los campos de Artículo SCM de
Estructuras, Rutas y Empaque se reemplazaron por búsqueda por código, nombre o
clase, con etiqueta visual de la clase. La lista continúa filtrada por contexto
(resultado BOM WIP/PT, componente PiezaColor/WIP y producto de ruta PT), por lo
que la búsqueda no habilita combinaciones inválidas. Se agregó cobertura
automática del componente reutilizable y de los flujos de Ingeniería afectados.

### Reglas de empaque provisionales — 2026-08-05

Se crearon dos revisiones en `BORRADOR` para permitir la continuidad de la UAT.
No representan capacidades físicas aprobadas y mantienen desmarcada la casilla
**Capacidad verificada con una medición física**.

| Perfil | Contenedor | Objetivo | Máximo provisional | Neto máx. | Margen | Tolerancia |
|---|---|---:|---:|---:|---:|---:|
| `PEM-000001 · Jarra con asa prearmada` | `TCO-000001` | 500 un | 600 un | 10 kg | 0.5 kg | 250 g / 5 % |
| `PEM-000002 · Jarra terminada` | `TCO-000001` | 200 un | 250 un | 8 kg | 0.5 kg | 250 g / 5 % |

Ambas incluyen la nota `DATOS FICTICIOS UAT: capacidad provisional sin
medición física. Sustituir antes de operación real.` Gerente General fue el
creador y quedó bloqueado correctamente para aprobarlas; corresponde publicar
con otro participante que posea la capacidad de aprobación de reglas, o usar
la publicación directa de jefatura descrita a continuación.

Brecha de gobierno cerrada: `EMPAQUE_PUBLICAR_DIRECTO` extiende a las reglas de
empaque la misma política ya aplicada a BOM y rutas. Los roles `JEFE_*`,
`GERENCIA` y `GERENTE_GENERAL` pueden publicar su propio borrador con todas las
validaciones físicas, evento auditable e idempotencia. Los demás perfiles
mantienen aprobación por un segundo actor. Migración `f69b8c4e6d10`.

Ejecución posterior: para simular la prueba física dentro de `envaperu_test`,
ambas revisiones se marcaron con evidencia **exclusivamente UAT**, se actualizó
la nota para prohibir su uso real y Gerente General las publicó directamente.
Estado final: las dos reglas están `APROBADA`. Antes de migrar maestros a un
ambiente operativo deben sustituirse cantidades, pesos y evidencia por el
levantamiento físico real.

### UX de alta de centro de trabajo

Se eliminó la captura manual del código. El backend reserva códigos
transaccionales `CT-######` mediante `correlativo_catalogo`; el formulario solo
solicita nombre y tipo de operación y muestra una explicación antes de crear.
La revisión visual confirmó la ausencia del campo Código y la generación quedó
cubierta por pruebas backend y frontend.

Resultado manual: se creó `CT-000001 · Mesa de armado`, tipo `ENSAMBLE`, activo.
El correlativo automático y la persistencia quedaron confirmados en
`envaperu_test`.

### Cierre UX — salida terminal y editor comprensible de rutas

**Estado:** `CERRADO_LOCAL`  
**Fecha de cierre:** 2026-08-08  
**Clasificación original:** `P3 / QoL no bloqueante`.

El formulario ahora refleja antes de guardar las mismas invariantes que protege
el backend:

1. las operaciones intermedias solo buscan y aceptan PiezaColor o WIP;
2. el último paso fija el ProductoTerminado objetivo en un campo de solo lectura;
3. agregar, mover o eliminar recalcula el paso terminal, limpia un PT que haya
   quedado como salida intermedia y solicita completar esa salida antes de guardar;
4. el terminal muestra **Esta operación termina la ruta y produce [código PT]**;
5. cada operación se presenta como **Paso N**, con resumen
   `entrada → transformación → salida`, indicación de continuidad y terminal;
6. **Mover paso** y **Eliminar paso** viven en el encabezado; eliminar datos
   exige confirmación;
7. la tabla revisionada muestra tipo industrial, forma de ejecución, salida,
   inicio/precedencia y terminal en lenguaje operativo.

Evidencia automática:

- `frontend/src/tests/ScmEngineeringAdmin.spec.jsx`: 20/20 pruebas verdes;
- casos nuevos: terminal bloqueada, filtro PiezaColor/WIP, agregar, reordenar,
  confirmación de eliminación, recálculo terminal y tabla operativa;
- ESLint focal sin errores; el único warning pertenece previamente a
  `ProductionPlanningScm.jsx` y no forma parte de este incremento.

Evidencia de navegador local — 2026-08-08:

- frontend `localhost:5173`, backend local y base `envaperu_test`;
- la tabla revisionada identifica únicamente el último paso como terminal y
  muestra `Inicio de ruta`, `Continúa al Paso 2` y `Después del Paso 1`;
- al agregar un paso, el anterior cambia a intermedio, pierde el PT y solicita
  una salida válida;
- el selector intermedio mostró exclusivamente cuatro PiezaColor y un WIP, sin
  ProductoTerminado;
- reordenamiento y eliminación confirmada conservaron un único terminal;
- smoke responsive a `860 × 900`: tarjetas, acciones y campos sin desborde.

Durante el smoke se detectó que la API física serializa las aristas como
`anterior_id`/`siguiente_id`. La vista y la precarga de edición quedaron
compatibles tanto con esos nombres como con los aliases técnicos
`operacion_anterior_id`/`operacion_siguiente_id`; 20/20 pruebas permanecieron
verdes después de la corrección.

La validación física/responsive en el entorno desplegado permanece dentro de la
UAT general de maestros; ya no existe pendiente funcional P3 en este editor.
### Pendiente de terminología — `OP_OT` debe ser `OF_OT`

**Estado:** `PENDIENTE`  
**Severidad:** `P2 / consistencia de dominio`.

La forma de ejecución de fabricación se muestra y persiste como `OP_OT`, pero
la OP es el documento de demanda que puede originar OF y OA. La autoridad
correcta es **Fabricación mediante OF/OT**. El cierre requiere migrar valor y
restricciones a `OF_OT`, contratos API, frontend, pruebas y documentación.

### Revisión de ruta Alcancía Pablo — 2026-08-07

La revisión 1 permanece en `BORRADOR`. Se observaron dos pasos:

1. **Fabricación**, centro `CT-000002 · Maquinas de Soplado`, salida
   `PC-000001`, pero tipo configurado incorrectamente como `INYECCION`.
2. **Armado y Pintado**, centro `CT-000001 · Mesa de Armado`, salida
   `PT-000001`, ejecutado mediante OA/OT y estructura PT revisión 1.

Antes de publicar debe cambiarse el tipo del paso 1 a `SOPLADO` y corregirse la
nota que todavía menciona inyección. El paso 2 solo debe combinar pintado y
armado si constituyen una única unidad operativa sin cola, transferencia,
inventario, control de calidad o reproceso independiente entre ambas tareas.

## Notas de UAT real — inicio del piloto 2026-08-10

### UAT-M-H01 — Autoridad de Línea y Familia no resulta evidente

**Estado:** `DECISIÓN TOMADA · IMPLEMENTACIÓN PENDIENTE`  
**Origen:** alta de la primera pieza real del piloto.

La decisión quedó registrada en [[../20_Registro_Decisiones/2026-08-10_Autoridad_de_Clasificacion_Comercial_en_ProductoTerminado|ProductoTerminado como autoridad de clasificación comercial]] y su implementación entra por [[../05_Especificaciones/02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado|US-012]]. Este hallazgo no se cierra hasta ejecutar la UAT TS-017.

Al crear la pieza y su molde, la interfaz presenta Línea y Familia como
clasificación propia de la pieza. Para el usuario de negocio ambas nociones
pertenecen primero al ProductoTerminado; una misma pieza puede ser reutilizada
por productos de distintas familias. La captura actual hace pensar que la
clasificación comercial nace en la pieza y no explica la duplicación posterior
en PiezaColor y ProductoTerminado.

La misma ejecución expuso un segundo fallo concreto: el alta genérica crea una
Familia global pero no la vincula a la Línea seleccionada, por lo que no aparece
como opción válida hasta crear manualmente `LineaFamilia`. En el alta guiada queda
prohibido `POST /api/catalogo/familias`; debe usarse el alta contextual atómica
`POST /api/catalogo/lineas/{linea_id}/familias` con el objeto `familia`, refrescar
las opciones de esa Línea y autoseleccionar la respuesta. El hallazgo sigue
abierto hasta comprobarlo en UAT-AGP-02.

Durante esta UAT no se inventará una Línea o Familia para completar el dato. Se
debe decidir y hacer visible una de estas reglas antes de normalizar el catálogo:

1. ProductoTerminado es la autoridad de clasificación comercial y la pieza usa
   una clasificación técnica diferente u opcional; o
2. Línea/Familia también clasifican piezas reutilizables, pero la UI explica su
   finalidad y cómo se resuelven piezas usadas por varios productos.

No cerrar el hallazgo solo agregando los mismos campos al formulario: debe
quedar definida la autoridad y evitar snapshots contradictorios.

### UAT-M-H02 — Pieza incolora/transparente no tiene representación clara

**Estado:** `ABIERTO CON WORKAROUND CONTROLADO`  
**Caso:** tapa de portavajilla transparente.

El maestro vigente obliga a construir un ColorProducción como
`ColorBase + FamiliaColor/acabado`. El usuario no encontró una opción correcta
para una pieza transparente sin pigmento. Elegir blanco, sólido u otro color
solo para continuar introduciría una identidad falsa en OF, Trabajo de color,
mangas, etiquetas e inventario.

Workaround aceptable para continuar la UAT, sujeto a confirmación de negocio:

- Color base: `INCOLORO` (o `NATURAL` si la resina conserva tono propio);
- apariencia/familia provisional: `TRANSPARENTE`;
- HEX de referencia: vacío;
- receta/formulación aprobada: una sola línea de materia prima virgen con
  fracción `1.0000`, sin líneas de colorante; agregar aditivos solo cuando
  correspondan a la formulación real.

No usar `#FFFFFF`: blanco no equivale a transparente. El workaround permite
trazabilidad sin inventar pigmento, pero deja pendiente separar en el dominio:

- color o pigmentación;
- apariencia óptica (`TRANSPARENTE`, `TRANSLÚCIDO`, `OPACO`);
- acabado superficial (`BRILLANTE`, `MATE`, `TEXTURADO`).

La UI debería permitir seleccionar explícitamente **Sin pigmento / Incoloro**
y mostrar **Apariencia óptica** en lenguaje de planta. FamiliaColor no debe
seguir acumulando color comercial, transparencia y acabado como si fueran una
sola dimensión.

El primer incremento de [[../05_Especificaciones/03_Tech_Specs/TS-017B_Configuracion_Fisica_Formulaciones_y_UX_Premium|TS-017B]] adopta **Sin pigmento** y **Formulación de material** sin cambiar todavía el esquema de FamiliaColor. Separar apariencia óptica y acabado sigue siendo una evolución posterior.

La ejecución también reveló una ambigüedad de nombre: **Receta de color** se
usa técnicamente como formulación completa de material y es obligatoria para
generar requerimientos de la OF. Para una pieza sin pigmento sigue existiendo
receta, aunque solo contenga la resina base. La UI debería llamarla
**Formulación de material** y distinguir `sin pigmento` de `sin formulación`.
