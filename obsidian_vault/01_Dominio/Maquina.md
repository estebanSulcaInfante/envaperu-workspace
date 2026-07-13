---
tipo: modelo_bd
uso: modelo_bd
tags: [dominio, maquina, catalogo, TS-009]
---

# Maquina

## Metadata
- **Tabla BD:** `maquina`
- **Estado:** activo
- **Fecha creación:** 2026-07-12

## Descripción
Catálogo maestro de las máquinas de inyección y soplado en la planta. Normalizado según TS-009 para utilizar un código único, tener un estado físico y relacionarse con `tipo_maquina`.

## Campos de la Tabla

| Atributo | Tipo / Origen | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **id** | Integer | PK auto-incremental | - |
| **codigo** | String | Código único de la máquina (ej. INY-01) | - |
| **nombre** | String | Nombre descriptivo (ej. Inyectora 1) | - |
| **tipo_maquina_id** | Integer (FK) | Relación a `tipo_maquina` (Inyección, Soplado) | - |
| **estado** | String | OPERATIVA, MANTENIMIENTO, INACTIVA | - |
| **activo** | Boolean | Si está visible para asignarse a órdenes | - |
| **numero_serie** | String | Número de serie físico de la máquina | - |
| **observaciones** | String | Notas adicionales | - |

## Validaciones
- `codigo` debe ser único y no nulo.
- `tipo_maquina_id` debe referenciar a un tipo válido.

## Relaciones
- **Padre:** `TipoMaquina`
- **Hijos:** `Orden_Produccion`, `Registro_Diario_Produccion`
- **FK:** `tipo_maquina`
