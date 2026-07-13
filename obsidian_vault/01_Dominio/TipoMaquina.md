---
tipo: modelo_bd
uso: modelo_bd
tags: [dominio, maquina, tipo, TS-009]
---

# TipoMaquina

## Metadata
- **Tabla BD:** `tipo_maquina`
- **Estado:** activo
- **Fecha creación:** 2026-07-12

## Descripción
Catálogo de los tipos de máquina disponibles en la planta (ej. INYECCION, SOPLADO). Implementado en TS-009 para normalizar el atributo de tipo de la máquina.

## Campos de la Tabla

| Atributo | Tipo / Origen | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **id** | Integer | PK auto-incremental | - |
| **codigo** | String | Código único (ej. INY) | - |
| **nombre** | String | Nombre visible del tipo (ej. Inyectora) | - |
| **proceso** | String | El proceso asociado (PRODUCCION, etc.) | - |

## Validaciones
- `codigo` debe ser único y no nulo.

## Relaciones
- **Padre:** N/A
- **Hijos:** `Maquina`
