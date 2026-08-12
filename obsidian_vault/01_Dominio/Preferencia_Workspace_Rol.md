---
tipo: dominio
estado: activo
tags: [scm, rol, workspace, preferencias, seguridad, us-010n2]
relaciones:
  - "[[RolOperativo]]"
  - "[[Trabajador]]"
  - "[[US-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# Preferencia de workspace por rol

## Metadata

- **Tabla BD:** `scm_rol_workspace_preferencia`
- **Estado:** activo
- **Autoridad de escritura:** API SCM con `AUTORIZACION_SCM_ADMINISTRAR`

## Descripción

Ordena y fija accesos elegibles en el Inicio de un [[RolOperativo]]. Es una
preferencia de presentación: no concede capacidades, no habilita rutas y no
reemplaza las validaciones de cada comando.

## Campos de la tabla

| Atributo | Tipo / origen | Descripción | Regla |
| :--- | :--- | :--- | :--- |
| **rol_operativo_id** | FK `rol_operativo.id` | Rol propietario | Parte de la PK; `ON DELETE RESTRICT` |
| **feature_key** | `VARCHAR(80)` | Clave estable del registro frontend | Parte de la PK; una clave retirada se conserva y se ignora al proyectar |
| **prioridad** | `SMALLINT` | Orden relativo dentro del rol | Entero `0..999` |
| **fijada** | booleano | Destaca la función en Inicio | No vuelve elegible una función sin capacidad |
| **created_at / updated_at** | timestamp con zona | Auditoría temporal | Gestionada por servidor |
| **created_by_id / updated_by_id** | FK `trabajador.id` | Actor administrador | Indexadas; `ON DELETE RESTRICT` |

## Validaciones e invariantes

- La PK compuesta impide repetir una función dentro del mismo rol.
- La proyección intersecta cada preferencia con capacidades efectivas y madurez.
- `workspace_start_feature` vive en el rol y solo se acepta si la función es
  elegible; de lo contrario se aplica un fallback seguro y se emite advertencia.
- Todos los roles activos aportan capacidades. Solo el rol principal explícito
  aporta foco, acceso principal y preferencias visuales.
- La tabla tiene RLS habilitado y no concede acceso directo a `anon` ni
  `authenticated`; Flask conserva la autoridad.
- Una actualización reemplaza el conjunto declarado dentro de la misma
  transacción y aumenta la versión del rol.

## Estructura JSON de referencia

```json
{
  "feature_key": "warehouse.kardex",
  "prioridad": 10,
  "fijada": true
}
```

## Relaciones

- **Padre:** [[RolOperativo]]
- **Actor de auditoría:** [[Trabajador]]

