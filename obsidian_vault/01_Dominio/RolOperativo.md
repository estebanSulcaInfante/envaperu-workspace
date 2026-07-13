---
tipo: modelo_bd
uso: modelo_bd
tags: [dominio, rol, trabajador, TS-009]
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

## Validaciones
- `codigo` debe ser único y no nulo.

## Relaciones
- **Padre:** N/A
- **Hijos:** N/A
- **Asociaciones:** `trabajador_rol` (N:M con `Trabajador`)
