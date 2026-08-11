---
tipo: uat
estado: pendiente
tags: [uat, catalogo, producto-terminado, wizard, TS-017]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
relaciones:
  - "[[../05_Especificaciones/02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
  - "[[../05_Especificaciones/03_Tech_Specs/TS-017A_Sesion_Durable_y_Shell_de_Alta_Guiada]]"
  - "[[../05_Especificaciones/03_Tech_Specs/TS-017B_Configuracion_Fisica_Formulaciones_y_UX_Premium]]"
  - "[[../05_Especificaciones/03_Tech_Specs/TS-017C_Ingenieria_Readiness_y_Publicacion_Guiada]]"
---

# UAT TS-017 — Alta guiada integral de PT

## Objetivo

Validar que una persona con experiencia de planta puede llevar un producto nuevo desde fuentes dispersas hasta una evaluación honesta de readiness sin abandonar la vista ni crear duplicados.

## Precondiciones

- ambiente local o UAT sin datos productivos irreversibles;
- usuario `GESTOR_MAESTROS` y otro usuario sin publicación directa;
- Línea `HOGAR` disponible;
- materiales y colores suficientes para un caso completo y al menos un ingrediente deliberadamente faltante;
- pruebas automáticas TS-017A/B/C verdes antes de la ejecución humana.

## Dataset

1. **COLADOR #3 UAT:** una salida, varios colores y formulaciones por 25 kg.
2. **PORTAVAJILLAS UAT:** varias piezas, al menos una transparente sin pigmento, una operación de armado y empaque de PT.

Los nombres se sufijan `UAT` y se inactivan al cerrar la prueba; no se reutilizan identidades reales sin autorización.

## Recorrido principal

### UAT-AGP-01 — Crear y reanudar

1. Crear sesión `COLADOR #3 UAT` y registrar el Excel como fuente textual.
2. Completar parcialmente IDENTIDAD.
3. Usar **Guardar y salir**.
4. Volver desde **Altas en curso** y recargar.
5. Confirmar título derivado del producto si ya fue resuelto, campos, `paso_actual`, estado abierto y timestamp de autosave.

**Esperado:** no existe PT antes de completar IDENTIDAD; no se pierde información. El caso se repite para `BORRADOR`, `CON_BLOQUEOS` y `LISTA_PARA_PUBLICAR`.

### UAT-AGP-02 — Clasificación en contexto

1. Seleccionar `HOGAR`.
2. Crear `COLADORES UAT` desde Familia.
3. Confirmar que el diálogo anuncia la asociación y que la petición usa `POST /api/catalogo/lineas/{linea_id}/familias` con el objeto `familia`.
4. Confirmar que no se invoca `POST /api/catalogo/familias`.
5. Completar IDENTIDAD.

**Esperado:** Familia seleccionada, asociación activa y PT con SKU automático. La Pieza todavía no existe.

Repetir con una Familia global existente sin vínculo y con otra Familia inactiva. En ambos casos se reutiliza/reactiva la misma identidad, se crea/reactiva `LineaFamilia` y el conteo de Familias no aumenta.

### UAT-AGP-03 — Volver atrás

1. Entrar a COMPONENTES.
2. Volver a IDENTIDAD y corregir la descripción de fuente.
3. Regresar a COMPONENTES.

**Esperado:** datos conservados, versión incrementada y ningún duplicado. Atrás/Adelante del navegador guarda antes de cambiar de fase. Si la fase ya fue aplicada, reaparece en modo consulta con sus IDs y una acción explícita de mantenimiento; no permite crear un sustituto silencioso.

### UAT-AGP-04 — Configuración física y color

1. Crear/reutilizar molde y pieza.
2. Informar cavidades y peso.
3. Seleccionar dos colores.
4. Revisar la matriz previa y aplicar.

**Esperado:** dos PiezaColor completas; repetir el paso devuelve `reused`, no otras identidades. Pieza no hereda clasificación comercial.

### UAT-AGP-05 — Formulación y pendiente confiable

1. Crear una formulación completa con resina/pigmentos confirmados.
2. Intentar otra con un pigmento ambiguo del Excel.
3. Registrar el segundo como pendiente.

**Esperado:** primera publicable; segunda no crea un material aproximado y bloquea sólo el color afectado.

### UAT-AGP-06 — Sin pigmento

1. En `PORTAVAJILLAS UAT`, seleccionar una salida transparente.
2. Elegir **Sin pigmento** y la resina confirmada.

**Esperado:** materia prima fracción 1, cero colorantes y mensaje “Formulación completa”.

### UAT-AGP-07 — Ingeniería y empaque

1. Crear WIP/BOM si aplica.
2. Crear ruta con terminal PT.
3. Asociar perfiles y reglas a salidas embolsables.

**Esperado:** los editores muestran el PT preseleccionado, pero conservan sus validaciones y revisiones canónicas.

### UAT-AGP-08 — Readiness y capacidades

1. Ejecutar readiness con una regla pendiente.
2. Usar **Ir al paso**, resolverlo y recalcular.
3. Publicar con Gestor de Maestros.
4. Repetir con el actor sin publicación directa.

**Esperado:** primer caso `READY`; segundo `PENDING_APPROVAL`, nunca falso `READY`.

### UAT-AGP-09 — Concurrencia

1. Abrir una sesión en dos pestañas.
2. Guardar cambios distintos sin recargar.

**Esperado:** la segunda pestaña muestra conflicto recuperable y no pisa la primera.

### UAT-AGP-10 — UX y accesibilidad

1. Recorrer sólo con teclado.
2. Activar reduced-motion.
3. Ocultar/mostrar la mascota.
4. Probar ancho móvil.

**Esperado:** foco visible, orden estable, sin información exclusiva en animación, sin overlay que cubra campos ni acciones.

### UAT-AGP-11 — Reanudación parcial sin duplicados

1. Forzar una falla después de materializar la primera unidad de COMPONENTES o COLORES.
2. Cerrar el navegador o limpiar su almacenamiento local.
3. Reabrir la sesión y corregir únicamente la unidad pendiente.
4. Reintentar.

**Esperado:** el servidor restituye `application_status` y la misma `application_key`; las unidades resueltas aparecen bloqueadas, la pendiente es editable y los IDs/conteos anteriores no cambian.

### UAT-AGP-12 — Imágenes del PT y sus variantes

1. Seleccionar una imagen JPEG/PNG/WEBP válida para el PT.
2. Aplicar IDENTIDAD y cargarla desde la misma sesión.
3. Repetir para una PiezaColor resuelta.
4. Probar un archivo mayor a 2 MB y otro cuyo MIME declarado no coincide con su contenido.

**Esperado:** preview y estado por entidad; archivos válidos quedan asociados al SKU correcto y sobreviven una recarga; inválidos se rechazan sin base64 en el borrador ni referencia falsa.

### UAT-AGP-13 — Atomicidad de Ingeniería

1. Aplicar RUTA_EMPAQUE con ruta y perfil válidos, pero provocar una falla gobernada en la regla.
2. Consultar ruta, perfiles, asociaciones, regla, sesión y auditoría.
3. Corregir y repetir con una clave HTTP nueva.

**Esperado:** la primera petición no deja ningún maestro, vínculo, evento u operación incompleta; la segunda crea una sola vez ruta, perfil, asignación, regla y checkpoint de sesión. Una referencia de estructura/ruta/regla perteneciente a otro PT se rechaza antes de escribir.

### UAT-AGP-14 — Captura completa pendiente de aprobación

1. Aplicar ESTRUCTURA y RUTA_EMPAQUE con un actor sin publicación directa.
2. Ejecutar Validar y Finalizar captura.

**Esperado:** las fases aparecen completas como captura, readiness devuelve `PENDING_APPROVAL`, la sesión puede cerrar sin afirmar **Listo para planificar** y no se crea ninguna OP. Tras la aprobación canónica, una nueva validación refleja `READY`.

### UAT-AGP-15 — WIP y empaque de todas las salidas

1. En `PORTAVAJILLAS UAT`, crear un WIP contextual desde la fase BOM.
2. Usar su `client_id` como componente antes de que exista el ID canónico.
3. Crear una ruta con salida PiezaColor/WIP y salida PT.
4. Configurar perfil y regla para cada salida; usar **Aplicar el mismo perfil** sólo cuando la geometría física sea compatible.

**Esperado:** WIP y BOM se confirman en una sola unidad; la ruta exige cobertura exacta sin duplicados; cada salida conserva su perfil/regla y los perfiles alternativos preexistentes no se eliminan.

### UAT-AGP-16 — Reaplicación explícita al volver atrás

1. Aplicar ESTRUCTURA en BORRADOR.
2. Volver a la fase y elegir **Reabrir borrador**.
3. Guardar el cambio con la aplicación anterior como `supersedes_application_key`.
4. Repetir con una revisión pendiente y otra aprobada.

**Esperado:** el BORRADOR conserva el mismo maestro/versionado y el journal anterior; la pendiente exige retiro canónico; la aprobada exige clonar/adoptar explícitamente. Nunca se crea un sustituto silencioso.

### UAT-AGP-17 — Confirmación final obsoleta

1. Validar readiness y confirmar REVISION.
2. En otra pestaña, modificar una revisión de ruta o regla incluida en `readiness.revision_snapshot`.
3. Intentar finalizar con la confirmación anterior.

**Esperado:** el cierre se rechaza como confirmación obsoleta, la sesión permanece mutable y solicita volver a revisar; no crea OP ni afirma READY con contenido que el usuario no revisó.

### UAT-AGP-18 — Colores aplicados con receta pendiente

1. Crear un ColorProducción nuevo y dejar su formulación como **Pendiente** con motivo.
2. Aplicar y continuar; volver a la fase **Colores, recetas y SKU**.
3. Elegir **Completar fase**, editar la formulación pendiente, añadir otro color y quitar una asociación existente.
4. Para el nuevo color, crear un **Acabado / tipo de color** contextual y escoger el HEX desde la paleta.
5. Cancelar la corrección y comprobar que no hubo cambios; repetir y usar **Aplicar corrección**.

**Esperado:** la fase permanece `EN_PROGRESO`, pero no queda bloqueada; la reaplicación declara `supersedes_application_key`, conserva los maestros compartidos, no duplica el color original y sólo quita su asociación de esta alta. El acabado recién creado queda seleccionado y la paleta mantiene sincronizado `#RRGGBB`.

**Hallazgo 2026-08-11:** una aplicación `APPLIED` con formulación pendiente se mostraba completamente bloqueada. También faltaban el alta contextual del acabado, el selector visual HEX y una ruta válida para enlaces de sesión sin fase. Corregido localmente; UAT humana de este escenario continúa pendiente.

## Evidencia a adjuntar

- capturas de los seis pasos y matriz final;
- IDs/códigos creados y reutilizados;
- payload de readiness sin datos sensibles;
- resultado de suites y build;
- tiempos aproximados comparados con la carga manual anterior;
- hallazgos con severidad, responsable y decisión.

## Criterio de cierre

Este documento permanece `pendiente` hasta ejecutar A/B/C. Sólo entonces podrá cerrarse si todos los escenarios principales están aprobados, no existe P0/P1 abierto, el alias de la configuración anterior fue verificado, la guía está actualizada y el trabajador UAT puede explicar por qué el producto está READY o qué falta sin visitar otro módulo.
