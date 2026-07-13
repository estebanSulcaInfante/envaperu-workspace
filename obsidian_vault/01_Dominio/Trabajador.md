---
tipo: modelo_bd
uso: modelo_bd
tags: [dominio, trabajador, catalogo, TS-009]
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

## Validaciones
- `codigo` debe ser único y no reutilizable, incluso si el trabajador se va.
- Un trabajador puede tener N `RolOperativo`.

## Relaciones
- **Padre:** N/A
- **Hijos:** `Detalle_Produccion_Hora` (vía FK y snapshot)
- **Asociaciones:** `trabajador_rol` (N:M con `RolOperativo`)
