---
tipo: vista_frontend
estado: implementada-local
tags: [frontend, scm, US-010R, articulos, bom, rutas, empaque]
fecha_actualizacion: 2026-08-08
---

# Vista US-010R: Ingeniería SCM

## Ruta

`/datos-maestros/ingenieria-scm`

## Objetivo

Administrar el corte R-core desde una sola vista conectada a la API central:

1. artículos unificados y alta de WIP WIP;
2. estructuras/BOM multinivel revisionadas;
3. centros de trabajo y rutas con autoridad `OP_OT` u `ORDEN_OPERACION`;
4. tipos de contenedor, perfiles empacables y reglas físicas;
5. bandeja de aprobaciones.

## Reglas de UX

- Los códigos de WIP, contenedor y perfil son automáticos.
- El código del centro de trabajo también es automático (`CT-000001`, etc.);
  el alta solicita únicamente nombre y tipo de operación.
- Los WIP pueden editarse e inactivarse/reactivarse con control de versión.
- Los borradores BOM, ruta y regla pueden reabrirse para continuar su edición.
- Centros, contenedores y perfiles permiten editar e inactivar/reactivar.
- El actor local solo sirve para pruebas y demostración; no concede permisos.
- La autoaprobación se rechaza server-side.
- El aprobador distinto del creador puede aprobar o rechazar una BOM pendiente;
  el rechazo exige motivo.
- El creador puede descartar su propio borrador con motivo; la acción conserva
  el registro y su auditoría.
- Los perfiles `JEFE_*`, `GERENCIA` y `GERENTE_GENERAL` ven **Publicar** en un
  borrador y no necesitan enviarlo a aprobación; los demás administradores ven
  **Enviar a aprobación**.
- El selector de resultado BOM solo ofrece WIP y ProductoTerminado.
- El resultado BOM no se autoselecciona: **Nueva revisión** permanece bloqueado
  hasta que el usuario elija conscientemente el artículo producido.
- En vista móvil, la etiqueta **Artículo resultado** permanece contraída sobre
  el borde del selector para no superponerse con el texto de orientación.
- El selector de componentes BOM solo ofrece PiezaColor y WIP.
- Los selectores de artículos de alta cardinalidad son buscadores reutilizables:
  filtran sin distinguir mayúsculas ni tildes por código, nombre, clase y datos
  identificadores del subtipo; cada resultado muestra su clase.
- El filtro funcional se aplica antes de la búsqueda: resultado BOM ofrece
  WIP/PT; componente BOM ofrece PiezaColor/WIP; producto de ruta ofrece PT;
  empaque admite PiezaColor/WIP/PT. Buscar nunca amplía las clases autorizadas.
- Los catálogos pequeños y cerrados —tipo, centro, perfil o estado— conservan
  selectores simples para no añadir interacción innecesaria.
- Al seleccionar una WIP como componente, el formulario muestra su revisión
  aprobada y desglosa cantidades, códigos y nombres de sus componentes. Si la
  WIP no tiene una estructura aprobada, advierte que la BOM no debe publicarse.
- Las cantidades conservan seis decimales de precisión en el dominio, pero la
  interfaz elimina ceros no significativos: `1.000000` se muestra como `1` y
  `1.500000` como `1.5`.
- Las operaciones de tipo `PREARMADO` muestran **Permite ejecución
  concurrente**. La ruta publicada identifica esta capacidad con la etiqueta
  **Concurrente** para que pueda auditarse visualmente.
- `SOPLADO` es un tipo de operación de fabricación, al mismo nivel que
  `INYECCION`; utiliza **Fabricación mediante OF y Trabajo de color** y permite declarar
  centros de trabajo y rutas sin falsear el proceso industrial.
- El campo anteriormente llamado **Autoridad** se presenta como **Forma de
  ejecución** y utiliza descripciones operativas: Fabricación mediante OF y
  Trabajo de color o
  Prearmado/armado mediante orden de operación.
- La clave estable de cada operación es interna y se genera automáticamente;
  no aparece como dato editable. Agregar una operación después de quitar otra
  conserva claves únicas.
- Los perfiles `JEFE_*`, `GERENCIA` y `GERENTE_GENERAL` pueden usar
  **Publicar** sobre su propio borrador de ruta. Los demás perfiles mantienen
  la aprobación por un segundo actor.
- Las revisiones rechazadas, retiradas y descartadas se ocultan bajo
  **Mostrar historial**; no compiten visualmente con la revisión vigente.
- Retirar una revisión aprobada exige confirmación y no permite reactivarla.
- **Crear nueva basada en esta** copia una revisión histórica a un nuevo
  borrador, salvo que ya exista otro borrador o una aprobación pendiente para
  el mismo resultado.
- La carga por dominios es parcial: un permiso faltante no borra información autorizada de otro dominio.
- Los estados se muestran como `BORRADOR`, `PENDIENTE_APROBACION`, `APROBADA`,
  `RETIRADA`, `RECHAZADA` o `DESCARTADA`.
- La configuración guiada ya no crea KIT. Remite a Artículo WIP + BOM.

## Compatibilidad legacy

El contract local ya fue aplicado. Ninguna pantalla permite crear o leer
`PiezaColor.tipo=KIT`, `COMPONENTE` ni `componentes`; el formulario PiezaColor
tampoco presenta un selector “Tipo”. La API todavía rechaza esos campos con
`LEGACY_KIT_NOT_SUPPORTED` para que clientes antiguos fallen explícitamente.

La tabla `pieza_componente` y la columna `pieza_color.tipo` ya no existen en
`enva_test`. Cualquier otro ambiente debe ejecutar su propia precondición antes
de aplicar la revisión.

Un ProductoTerminado legacy con clave vacía se rescata bajo un código SCM estable
para no perderlo del catálogo, pero queda excluido del selector y de las consultas
de rutas hasta sanear su identidad legacy.

## Validación

- Vitest: vista, carga API, alta, edición e inactivación WIP y exclusión de
  productos legacy sin identidad enrutable.
- Suite frontend completa: `93 passed`.
- Build Vite y ESLint verdes.
- Revisión visual local de navegación, cinco áreas, formulario WIP, permisos
  parciales y ausencia del `404` por SKU vacío.

### Continuación UAT 2026-08-04

- 8 pruebas Vitest de Ingeniería SCM aprobadas.
- Build Vite aprobado.
- Navegador confirmó PT/WIP como únicos resultados de BOM.
- Navegador confirmó acciones **Aprobar** y **Rechazar** para Jefe de
  Producción sobre una revisión ajena.
- Navegador confirmó selección inicialmente vacía, orientación al usuario y
  bloqueo de **Nueva revisión** hasta elegir el artículo resultado.
- Revisión responsive confirmó el selector sin superposición entre etiqueta y
  placeholder en el ancho móvil de la UAT.
- La publicación directa de rutas usa una sola acción compartida: los perfiles
  de jefatura o gerencia ven **Publicar** tanto en la tarjeta de **Rutas** como
  en **Aprobaciones**. La regla y el llamado al backend son idénticos en ambas
  ubicaciones.
- La asociación de perfiles empacables admite las tres clases operativas de
  Artículo SCM: PiezaColor, WIP y ProductoTerminado. Se retiró la exclusión de
  PT que existía solamente en el selector del frontend y contradecía el modelo
  de dominio y el flujo de mangas de Armado.
- **Asignaciones actuales** consulta las asociaciones persistidas y muestra
  artículo, clase, código/nombre del perfil, descripción física y condición
  predeterminada. La acción **Cambiar** precarga la asignación vigente para
  sustituirla sin depender del mensaje temporal de guardado.
- Los campos de artículo en Estructuras, Rutas y Empaque dejaron de ser listas
  extensas: ahora permiten buscar por código, nombre o clase y conservan los
  filtros funcionales de cada contexto.

## Implementado: salida terminal guiada y editor de pasos

Desde 2026-08-08, la vista guía la construcción de una ruta válida sin esperar
al rechazo del backend:

- la salida de un paso intermedio se limita a PiezaColor o WIP;
- el último paso siempre produce el PT seleccionado y su salida está bloqueada;
- al agregar, mover o eliminar se recalcula la terminal y se pide corregir una
  salida intermedia que haya quedado vacía;
- cada tarjeta muestra **Paso N** y el resumen
  `entrada → transformación → salida`, además de su continuidad;
- **Mover paso** usa acciones textuales **Antes/Después** y **Eliminar paso**
  exige confirmación cuando existen datos;
- el paso terminal usa borde y distintivo propios, y explica
  **Esta operación termina la ruta y produce [código PT]**;
- la tabla de una revisión comunica tipo industrial, forma de ejecución, centro,
  salida y precedencia, e identifica el terminal.

La forma visible utiliza **Fabricación mediante OF y Trabajo de color**. La clave
interna `OP_OT` continúa únicamente como alias de compatibilidad; su eventual
migración física corresponde al pendiente P2 separado y no se mezcló con este
incremento de UX.

### Evidencia

- 20/20 escenarios de `ScmEngineeringAdmin.spec.jsx` aprobados.
- Cobertura específica de creación, adición, reordenamiento, eliminación con
  confirmación y lectura de la tabla publicada.
- ESLint focal sin errores.
- Navegador local contra `envaperu_test`: editor, filtro de salidas,
  reordenamiento, eliminación y tabla verificados; responsive `860 × 900` sin
  desbordes.
- Compatibilidad confirmada para precedencias API
  `anterior_id`/`siguiente_id` y aliases internos históricos.
