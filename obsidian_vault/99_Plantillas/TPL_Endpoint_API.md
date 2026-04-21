---
tipo: plantilla
uso: endpoint_api
tags: [plantilla, endpoint, api, backend]
---

# {{Método}} {{Ruta}}

## Metadata
- **Módulo:** {{módulo_backend}}
- **Autenticación:** {{requerida | pública}}
- **Estado:** activo | deprecado

## Descripción
{{Qué hace este endpoint}}

## Request

### Parámetros de Ruta
| Parámetro | Tipo | Descripción |
| :--- | :--- | :--- |
| `{{param}}` | {{tipo}} | {{descripción}} |

### Body (si aplica)
```json
{}
```

## Response

### Éxito (200)
```json
{}
```

### Errores
| Código | Descripción |
| :--- | :--- |
| 404 | {{recurso}} no encontrado |

## Entidades Involucradas
- [[{{Entidad_1}}]]

## Reglas de Negocio
- {{Regla 1}}
