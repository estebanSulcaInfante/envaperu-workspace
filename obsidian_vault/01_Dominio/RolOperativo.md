---
tipo: modelo_bd
uso: modelo_bd
tags: [dominio, rol, trabajador, capacidades, TS-009, US-010]
relaciones:
  - "[[Trabajador]]"
  - "[[Preferencia_Workspace_Rol]]"
  - "[[Matriz_Roles_Capacidades_SCM_Produccion]]"
---

# RolOperativo

## Metadata
- **Tabla BD:** `rol_operativo`
- **Estado:** activo
- **Fecha creación:** 2026-07-12

## Descripción
Catálogo de roles o puestos de trabajo que un empleado puede ejercer (ej. MAQUINISTA, OPERADOR_PESAJE). Implementado en TS-009.

## Campos de la Tabla

| Atributo | Tipo / Origen | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **id** | Integer | PK auto-incremental | - |
| **codigo** | String | Código único del rol (ej. MAQUINISTA) | - |
| **nombre** | String | Nombre visible del rol | - |
| **activo** | Boolean | Si el rol está disponible | - |
| **capacidades** | N:M `scm_rol_capacidad` | Acciones SCM autorizables para el rol | Solo capacidades activas producen permisos efectivos |
| **workspace_focus** | Text nullable | Propósito breve mostrado en Inicio | No promete comandos ni contadores |
| **workspace_start_feature** | `VARCHAR(80)` nullable | Clave estable del acceso principal | Se usa solo si la función es elegible |
| **version** | Integer | Concurrencia optimista de la configuración | Inicia en `1` y siempre es positiva |

## Validaciones
- `codigo` debe ser único, no nulo e inmutable después de crear el rol.
- `workspace_start_feature` no es una URL ni concede autorización.
- La actualización administrativa exige la versión vigente.

## Relaciones
- **Padre:** N/A
- **Hijos:** N/A
- **Asociaciones:** `trabajador_rol` (N:M con `Trabajador`),
  `scm_rol_capacidad` (N:M con `ScmCapacidad`) y
  [[Preferencia_Workspace_Rol]].

## Gobierno SCM

- Las capacidades efectivas se derivan en backend desde roles y capacidades activas.
- Todos los roles activos asignados aportan capacidades; solo el principal
  explícito aporta foco y preferencias de workspace.
- Una preferencia organiza funciones ya elegibles y nunca habilita una ruta o
  comando.
- La asignación final de roles a trabajadores se realiza al cierre del desarrollo.
- Las migraciones pueden crear roles y capacidades semilla, pero no asignarlos a personas.
- Véase [[Matriz_Roles_Capacidades_SCM_Produccion]].
