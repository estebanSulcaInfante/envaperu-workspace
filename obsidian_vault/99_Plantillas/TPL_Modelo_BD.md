---
tipo: plantilla
uso: modelo_bd
tags: [plantilla, modelo, base-datos]
---

# {{Nombre del Modelo}}

## Metadata
- **Tabla BD:** `{{nombre_tabla}}`
- **Estado:** activo | deprecado
- **Fecha creación:** {{fecha}}

## Descripción
{{Descripción breve del propósito de esta entidad en el sistema}}

## Campos de la Tabla

| Atributo | Tipo / Origen | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **campo_1** | {{tipo}} | {{descripción}} | {{fórmula o "-"}} |

## Validaciones
- {{Regla de validación 1}}

## Estructura JSON (Referencia API)
```json
{}
```

## Relaciones
- **Padre:** [[{{Entidad_Padre}}]]
- **Hijos:** [[{{Entidad_Hija}}]]
- **FK:** `{{tabla_referenciada}}`
