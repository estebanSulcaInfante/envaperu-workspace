---
tipo: modelo_bd
uso: modelo_bd
tags: [dominio, trabajador, catalogo, roles, capacidades, TS-009, US-010]
relaciones:
  - "[[RolOperativo]]"
  - "[[Matriz_Roles_Capacidades_SCM_Produccion]]"
---

# Trabajador

## Metadata
- **Tabla BD:** `trabajador`
- **Estado:** activo
- **Fecha creación:** 2026-07-12

## Descripción
Catálogo maestro de las personas (operativos/maquinistas). Implementado en TS-009 para asegurar trazabilidad end-to-end de quién produce, mediante un código inmutable de empleado y el uso de snapshots en registros históricos.

## Campos de la Tabla

| Atributo | Tipo / Origen | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **id** | Integer | PK auto-incremental | - |
| **codigo** | String | Código interno y estable del trabajador (ej. TR-001) | - |
| **nombres** | String | Nombres del empleado | - |
| **apellidos** | String | Apellidos del empleado | - |
| **nombre_corto** | String | Nombre visible en interfaces rápidas (ej. Juan P.) | - |
| **activo** | Boolean | Determina si puede ser seleccionado en nuevos reportes | - |
| **capacidades_efectivas** | Derivada | Unión de capacidades activas de sus roles activos | Nunca se acepta desde el frontend |
| **rol_principal** | Derivada de `trabajador_rol.es_principal` | Rol que define foco y orden visual | Debe estar activo y asignado; no limita la unión de capacidades |
| **rol_principal_pendiente** | Derivada | Indica que falta una selección principal válida | No bloquea accesos legítimos derivados de capacidades |

## Validaciones
- `codigo` debe ser único y no reutilizable, incluso si el trabajador se va.
- Un trabajador puede tener N `RolOperativo`.
- Como máximo una asociación se marca `es_principal` por trabajador.
- Alta o edición sin principal autoasigna únicamente cuando el resultado tiene
  exactamente un rol activo. Nunca elige entre dos roles activos.
- Retirar el principal lo limpia de forma auditada y no selecciona sustituto.
- Un trabajador inactivo no posee capacidades efectivas.
- Las asignaciones de roles a personas son configuración de puesta en marcha, no seeds de migración.

## Relaciones
- **Padre:** N/A
- **Hijos:** `Detalle_Produccion_Hora` (vía FK y snapshot)
- **Asociaciones:** `trabajador_rol` (N:M con `RolOperativo`, atributo
  `es_principal`)
