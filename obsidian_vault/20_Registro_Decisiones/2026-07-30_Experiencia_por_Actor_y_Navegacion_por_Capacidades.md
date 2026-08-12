---
fecha: 2026-08-01
estado: APLICADA_EN_PILOTO_EXTENDIDA
alcance:
  - US-010A
  - US-010P
  - US-010C
  - US-010D
---

# Experiencia por actor y navegación por capacidades

> [!note] Extensión vigente desde 2026-08-08
> [[2026-08-08_Arquitectura_de_Informacion_SCM_y_Workspace_por_Capacidades]]
> conserva la API como autoridad y sustituye la experiencia/prioridad estática
> por un workspace derivado de capacidades, rol principal explícito y un
> registro único de funciones.

## Problema observado

El piloto exponía casi la misma interfaz a todos los trabajadores. El usuario
tenía que recordar qué documento estaba tratando, qué actor numérico había
configurado y qué botones podía usar. Varias acciones improcedentes solo se
descubrían después de recibir un `403`, lo que generaba pérdida de contexto,
prueba y error y baja confianza.

## Decisión

La API continúa siendo la autoridad de permisos. El frontend usa las
`capacidades_efectivas` del trabajador para adaptar la experiencia antes de la
acción:

1. existe un único perfil de trabajo visible para todo el frontend;
2. el perfil se selecciona por nombre y rol, no por un número de actor;
3. navegación, pestañas, tareas y acciones se filtran por capacidades;
4. una vista de consulta conserva el estado y la evidencia, pero no presenta
   controles que el actor no puede ejecutar;
5. los documentos del piloto se presentan como un recorrido:
   demanda → fabricación/armado → OT y mangas → pesaje → almacén;
6. un error al cargar permisos falla de forma cerrada para las acciones. La API
   sigue validando cada solicitud.

## Lectura empática por actor

| Actor | Necesidad principal | Presentación prioritaria | Evitar |
|---|---|---|---|
| Gerencia | decidir y aprobar con contexto | excepciones, estado, cumplimiento y aprobaciones | formularios técnicos y acciones de jornada |
| Jefe de Producción | mantener el flujo y resolver bloqueos | liberaciones, OT, mangas extra, anulaciones y correcciones | navegar entre catálogos irrelevantes |
| Supervisor | preparar la jornada | OF liberadas, OT, maquinista, mangas y preetiquetas | parámetros de ingeniería no necesarios |
| Planificación | convertir demanda en trabajo | OP, cobertura y propuesta OF/OA | controles de pesaje |
| Ingeniería SCM | asegurar validez técnica | artículos, BOM, rutas y empaque con revisiones | operación diaria de planta |
| Compras | asegurar abastecimiento | OC, proveedores y documentos | controles de fabricación |
| Almacén/Calidad | resolver recepción y disponibilidad | recepción, identificación, estado de calidad y lotes | planificación de demanda |
| Maquinista | ejecutar sin digitar | asignación, identificación de manga e instrucciones | códigos internos y formularios extensos |
| Operador de pesaje | pesar con mínima decisión | lectura QR, estabilidad, bruto/tara/neto y etiqueta final | reconstruir OP, OT o receta |

## Aplicación inicial

- Barra global “Trabajando como” con nombre, rol y foco del actor.
- Inicio personalizado con próximas tareas permitidas.
- Menú lateral y pestañas de módulo filtrados por capacidades.
- Mensaje explícito cuando la página es de consulta.
- Acciones de OP, OF, OA, OT y mangas visibles solo al responsable.
- Campos técnicos bloqueados para actores de lectura.
- Flujo visual persistente para conservar orientación documental.
- Maquinista limitado a trabajadores activos con rol `MAQUINISTA`.
- Datos maestros listados según el alcance real del actor.
- No se presupone una pantalla en máquina: la hoja de OT y las preetiquetas son
  la interfaz física del maquinista hasta que escanea la manga en Balanza.

## Regla de autorización

La adaptación del frontend mejora comprensión y previene errores, pero no
reemplaza autorización. Todos los comandos mantienen la validación de capacidad
en el backend y la segregación creador/aprobador.

## Próximas iteraciones

- Sustituir el selector local de UAT por autenticación real sin cambiar el
  contrato de capacidades.
- Medir tiempo por tarea, errores evitables, abandonos de formulario y ayuda
  solicitada durante la UAT.
- Diseñar la estación de pesaje para maquinista/operador con el mismo modelo de
  perfil, pero priorizando interacción por QR y balanza.
- Agregar bandejas de “pendiente de mí” y contadores de excepción cuando existan
  suficientes datos reales.
