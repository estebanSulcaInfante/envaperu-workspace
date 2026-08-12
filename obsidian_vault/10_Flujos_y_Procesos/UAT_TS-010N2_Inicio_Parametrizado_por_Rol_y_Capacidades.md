---
tipo: uat
estado: en-ejecucion
tags: [scm, uat, frontend, backend, roles, capacidades, workspace]
relaciones:
  - "[[US-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[DEV-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[UAT_TS-010N1_Navegacion_Agrupada]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# UAT TS-010N2: Inicio parametrizado por rol y capacidades

## Objetivo

Confirmar que cada persona recibe una portada comprensible según sus
capacidades y su rol principal, sin perder accesos legítimos ni obtener
permisos por configuración visual.

## Precondiciones

- migración N2 aplicada en PostgreSQL/Supabase;
- backend y frontend N2 desplegados en Render;
- un Gerente General con `AUTORIZACION_SCM_ADMINISTRAR`;
- un perfil limitado con una sola función visible;
- un trabajador con dos roles activos y rol principal explícito;
- selector de perfil oculto en producción.

## Casos

| Caso | Acción | Resultado esperado |
|---|---|---|
| N2-U00 | Cargar la aplicación con identidad pendiente o error | No se monta contenido operativo ni se asumen capacidades; Reintentar es fail-closed. |
| N2-U01 | Abrir Inicio con un rol configurado | Se muestran foco, acceso principal como CTA, fijados y Más funciones agrupadas. No hay redirección automática. |
| N2-U02 | Configurar más de seis funciones elegibles | Ninguna desaparece; las no fijadas aparecen en listas compactas por área. |
| N2-U03 | Fijar una función sin capacidad o retirada del registro | Se excluye, aparece advertencia estructurada y puede eliminarse desde Administración. |
| N2-U04 | Asignar dos roles y elegir uno como principal | Las capacidades son la unión; solo el principal controla foco, inicio y orden visual. |
| N2-U05 | Quitar el principal de una persona multirrol | Se muestra experiencia genérica y principal pendiente; no se elige otro en silencio. |
| N2-U06 | Crear un rol nuevo con una sola función y asignarlo | Inicio se genera desde metadatos; no requiere programar una portada nueva. |
| N2-U07 | Previsualizar un rol desde Administración | La vista previa coincide con Inicio, pero no cambia la sesión ni concede permisos. |
| N2-U08 | Intentar editar roles sin capacidad administrativa | La UI oculta el acceso y el backend rechaza la llamada. |
| N2-U09 | En Supabase, enviar `X-Actor-Id` de otro usuario | La cabecera se ignora; la identidad JWT conserva la autoridad. |
| N2-U10 | Desactivar el rol principal | El rol deja de aportar capacidades/preferencias y se señala regularización pendiente. |
| N2-U11 | Probar móvil y escritorio | La administración y el Inicio no desbordan; búsqueda, grupos y acciones son accesibles por teclado. |

## Evidencia automática previa

- backend: 324 pruebas aprobadas y cero fallos;
- frontend: 50 archivos / 212 pruebas verdes;
- build verde y lint sin errores;
- PostgreSQL real cubre migración, restricciones, RLS/ACL y conflicto de versión;
- autenticación focal cubre denegación por prefijo y no suplantación Supabase.

## Criterio de aceptación

- todos los casos aplicables aprobados;
- cero acceso ampliado por preferencias;
- cero función elegible perdida;
- cero selector/suplantación de actor en producción;
- migración observada en `HEAD` y API sana antes de abrir la UAT integral.

## Ejecución remota — 2026-08-08

Versión: backend `6f5f488` (`HEAD f80c9d5e1a42`) y frontend `51a7785`.

| Caso | Estado | Evidencia |
|---|---|---|
| N2-U00 | APROBADO | Durante recarga se observó navegación mínima y “Cargando permisos”; el contenido apareció solo después de resolver identidad/capacidades. |
| N2-U01 | APROBADO | Gerente General ve acceso principal **Avance de planta**, CTA **Abrir** y Más funciones agrupadas sin redirección. |
| N2-U02 | AUTOMATIZADO | 212 pruebas frontend cubren lista sin truncamiento. |
| N2-U03 | AUTOMATIZADO | Preferencias desconocidas/inelegibles quedan excluidas, advertidas y saneables. |
| N2-U04 | PENDIENTE HUMANO | Requiere una identidad con dos roles activos y principal explícito. |
| N2-U05 | PENDIENTE HUMANO | El entorno no posee actualmente personas sin principal para recorrer la regularización. |
| N2-U06 | AUTOMATIZADO | Rol nuevo se proyecta por metadatos; no se creó un rol ficticio en producción. |
| N2-U07 | APROBADO | Administración carga 16 roles y la preview “Así verá este rol” sin cambiar la sesión Gerente General. |
| N2-U08 | AUTOMATIZADO | Guardia UI/API y denegación sin capacidad cubiertas; catálogo anónimo devuelve 401. |
| N2-U09 | AUTOMATIZADO | Contrato Supabase confirma que `X-Actor-Id` no suplanta el JWT. |
| N2-U10 | AUTOMATIZADO | Rol inactivo deja de aportar capacidad/preferencia y principal queda pendiente. |
| N2-U11 | PENDIENTE HUMANO | Responsive cubierto automáticamente; falta confirmación táctil remota. |

Hallazgo remoto resuelto: los nombres históricos de roles/capacidades contenían
mojibake. `f80c9d5e1a42` reparó los textos sin cambiar autoridad; se verificaron
“Almacén / Recepción”, “Auditoría / Consulta” y “Configuración SCM”.

La UAT permanece abierta por N2-U04, N2-U05 y N2-U11.
