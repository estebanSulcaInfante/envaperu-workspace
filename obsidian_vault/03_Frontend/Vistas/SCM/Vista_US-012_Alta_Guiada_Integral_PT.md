---
tipo: vista_frontend
estado: implementada-local-pendiente-uat
tags: [frontend, catalogo, wizard, producto-terminado, ux-premium]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
relaciones:
  - "[[../../../05_Especificaciones/02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
  - "[[../../../05_Especificaciones/03_Tech_Specs/TS-017A_Sesion_Durable_y_Shell_de_Alta_Guiada]]"
---

# Vista US-012: Alta guiada integral de PT

## Rutas

- canónica propuesta: `/datos-maestros/alta-producto`;
- alias de transición: `/datos-maestros/configuracion-guiada`, `/datos-maestros/configurar` y `/catalogo/configurar`.

## Lugar en la arquitectura de información

**Datos maestros > Alta guiada de producto** será la acción principal para crear un PT nuevo. **Productos**, **Piezas**, **Moldes**, **Colores y formulaciones** e **Ingeniería SCM** permanecen como vistas de consulta y mantenimiento especializado.

## Estructura de escritorio

```text
┌ Alta guiada · COLADOR #3       BORRADOR · Guardado hace 8 s ┐
├──────────────┬──────────────────────────────┬─────────────────┤
│ 1 Identidad  │                              │ Ayuda del paso  │
│ 2 Componentes│       Formulario activo      │ mascota mínima  │
│ 3 Colores    │                              │ bloqueos/fuente │
│ 4 Estructura │                              │                 │
│ 5 Ruta/Emp.  │                              │                 │
│ 6 Revisión   │                              │                 │
├──────────────┴──────────────────────────────┴─────────────────┤
│ Atrás               Guardar              Guardar y continuar │
└───────────────────────────────────────────────────────────────┘
```

## Comportamientos esenciales

- el rail muestra progreso real, no sólo el número de pantalla;
- cualquier paso visitado puede reabrirse;
- los pasos futuros se pueden inspeccionar, pero **Aplicar** permanece bloqueado con el prerequisito visible hasta que la fase anterior esté materializada;
- el encabezado diferencia **borrador de sesión**, **dato aplicado** y **revisión publicada**;
- el título del encabezado se deriva del PT resuelto en IDENTIDAD y usa el título provisional sólo mientras todavía no hay producto;
- salir ofrece **Guardar y salir** persistente; no usa un diálogo alarmista si el autosave está al día;
- **Altas en curso** lista `BORRADOR`, `CON_BLOQUEOS` y `LISTA_PARA_PUBLICAR`, y reabre cada sesión en su `paso_actual`;
- errores de campo se resumen también al inicio y enfocan el primer campo inválido;
- la revisión final agrupa bloqueos, advertencias y opcionales con acción **Ir al paso**;
- una fase ya aplicada se recarga desde `application_status`, muestra IDs/resultados en modo consulta y ofrece **Editar maestro** o **Crear revisión**; no deja editar un formulario para fallar recién al final ni crear un reemplazo silencioso;
- una fase parcial reanuda con la clave de aplicación informada por el servidor, incluso desde otro navegador;
- cada selector de alta cardinalidad permite buscar y reutilizar antes de crear;
- la creación de Familia explica “Se asociará a la Línea HOGAR” antes de confirmar, usa el alta contextual atómica y autoselecciona la respuesta; nunca invoca el POST global de Familia.

## Responsive

En móvil, el rail lateral se convierte en una barra de progreso y un drawer **Ver los 6 pasos**. La ayuda contextual se muestra colapsada debajo del título del paso. El footer usa dos niveles: Atrás/Salir como acciones secundarias y Guardar/Aplicar apiladas a ancho completo. Ningún CTA queda cortado a 390 px ni cubre el último campo.

## Lenguaje

- **Formulación de material**, no “receta de color”, cuando incluye resina y aditivos.
- **Sin pigmento**, distinto de **Formulación pendiente**.
- **Clasificación comercial del producto** para Línea/Familia.
- **Clasificación técnica (opcional)** sólo en mantenimiento avanzado de Pieza.
- **Publicar** o **Enviar a aprobación**, nunca “Guardar todo” para objetos revisionados.

## Experiencia premium y mascota

La mascota es un pequeño asesor visual de planta y aparece en el panel de ayuda. En el piloto usa un SVG propio, mensajes deterministas y transiciones sutiles. No flota sobre inputs, no repite cada validación, no emite sonido y puede ocultarse por sesión. El aspecto premium depende además de espaciado, jerarquía, skeletons, previews, microtransiciones y estados de guardado coherentes.

## Estados a diseñar y probar

`CARGANDO`, `VACÍA`, `BORRADOR`, `GUARDANDO`, `GUARDADA`, `CONFLICTO`, `PASO_BLOQUEADO`, `INVALIDADO`, `CON_BLOQUEOS`, `LISTA_PARA_PUBLICAR`, `FINALIZADA`, `ERROR_RECUPERABLE` y `SIN_PERMISO_PARCIAL`.

## Reemplazo del asistente vigente

La vista actual `ConfigurarProducto` se mantiene sólo hasta que A/B/C estén verdes. No se la renombra y expande indefinidamente: el nuevo shell consume componentes extraídos y contratos de sesión. Tras UAT, los aliases resuelven a la nueva vista y la anterior se retira.
