---
tipo: endpoint-api
estado: activo
tags: [scm, api, roles, capacidades, workspace, autorizacion, us-010n2]
relaciones:
  - "[[RolOperativo]]"
  - "[[Trabajador]]"
  - "[[Preferencia_Workspace_Rol]]"
  - "[[Autenticacion_Supabase_SCM]]"
  - "[[TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# Catálogo de roles, capacidades y workspace

## Metadata

- **Módulo:** `app/api/rutas_trabajadores.py`
- **Servicio:** `app/services/scm_workspace_role_service.py`
- **Autenticación:** humana obligatoria
- **Capacidad administrativa:** `AUTORIZACION_SCM_ADMINISTRAR`

## Endpoints

| Método y ruta | Propósito |
| :--- | :--- |
| `GET /api/catalogo/capacidades` | Lista capacidades activas e inactivas para administración. |
| `GET /api/catalogo/roles-operativos` | Lista roles con capacidades, preferencias y versión. |
| `POST /api/catalogo/roles-operativos` | Crea un rol operativo versionado. |
| `PUT /api/catalogo/roles-operativos/{id}` | Actualiza el rol con concurrencia optimista. |
| `PATCH /api/catalogo/trabajadores/{id}/rol-principal` | Define el rol principal entre los roles activos asignados. |
| `GET /api/auth/me` | Devuelve capacidades efectivas y metadata del principal. |

## Contrato de rol

```json
{
  "codigo": "AUDITOR_INVENTARIO",
  "nombre": "Auditor de inventario",
  "activo": true,
  "capacidad_codigos": ["INVENTARIO_VER"],
  "workspace_focus": "Revisar existencias y movimientos trazables.",
  "workspace_start_feature": "warehouse.kardex",
  "workspace_preferencias": [
    {
      "feature_key": "warehouse.kardex",
      "prioridad": 10,
      "fijada": true
    }
  ],
  "expected_version": 1
}
```

`expected_version` se omite al crear y es obligatorio al actualizar. El código
estable es inmutable; `PUT` conserva compatibilidad con los campos históricos y
reemplaza los conjuntos de capacidades/preferencias que recibe.

## Identidad actual

`GET /api/auth/me` conserva roles y `capacidades_efectivas` y agrega:

```json
{
  "rol_principal": {
    "id": 7,
    "codigo": "AUDITOR_INVENTARIO",
    "nombre": "Auditor de inventario",
    "activo": true,
    "workspace_focus": "Revisar existencias y movimientos trazables.",
    "workspace_start_feature": "warehouse.kardex",
    "workspace_preferencias": []
  },
  "rol_principal_pendiente": false
}
```

La respuesta mantiene `Cache-Control: private, no-store`. Un rol inactivo no se
proyecta como principal activo ni aporta capacidades.

## Errores gobernados

| Código | Descripción |
| :--- | :--- |
| `CAPABILITY_REQUIRED` | El actor no administra autorizaciones SCM. |
| `INVALID_CAPABILITY` | Capacidad inexistente o inactiva. |
| `DUPLICATE_WORKSPACE_PREFERENCE` | Una función aparece más de una vez. |
| `VERSION_CONFLICT` | Otra sesión actualizó el rol. |
| `IMMUTABLE_ROLE_CODE` | Se intentó cambiar el código estable. |
| `PRIMARY_ROLE_NOT_ASSIGNED` | El rol no pertenece al trabajador. |
| `PRIMARY_ROLE_INACTIVE` | El rol elegido está inactivo. |

## Reglas de seguridad

- En Supabase, el JWT determina al actor; `X-Actor-Id` no sustituye al token.
- En UAT local, `X-Actor-Id` selecciona un actor real y el servicio verifica la
  misma capacidad administrativa.
- Preferencias desconocidas pueden persistirse para tolerar evolución de UI,
  pero nunca conceden acceso.
- Crear, actualizar y definir principal generan eventos auditables sin guardar
  JWT ni correo.

