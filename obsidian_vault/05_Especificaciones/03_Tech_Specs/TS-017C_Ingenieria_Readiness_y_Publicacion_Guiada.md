---
tipo: tech_spec
id: TS-017C
titulo: "Ingeniería, readiness y publicación guiada"
estado: implementada-local-pendiente-uat
tags: [catalogo, bom, ruta, empaque, readiness, aprobacion]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
user_story: "[[../02_User_Stories/US-012C_Ingenieria_Readiness_y_Publicacion]]"
relaciones:
  - "[[TS-010R_Articulos_BOM_Rutas_WIP_y_Perfiles_Empaque]]"
  - "[[TS-017A_Sesion_Durable_y_Shell_de_Alta_Guiada]]"
  - "[[TS-017B_Configuracion_Fisica_Formulaciones_y_UX_Premium]]"
---

# TS-017C: Ingeniería, readiness y publicación guiada

## 1. Objetivo técnico

Integrar `ESTRUCTURA`, `RUTA_EMPAQUE` y `REVISION` con los servicios y editores de Ingeniería SCM. El asistente aporta contexto, secuencia y readiness; no crea una segunda implementación de BOM, ruta o empaque.

## 2. Composición de UI

Extraer de `ScmEngineeringAdmin` editores reutilizables con contratos controlados:

- `StructureRevisionEditor` para PT/WIP;
- `RouteRevisionEditor` con salida terminal fijada al PT de la sesión;
- `PackagingProfileEditor` y `PackagingRuleEditor`;
- `ApprovalActionPanel` común.

La vista Ingeniería SCM sigue usando los mismos componentes de forma independiente. El asistente los monta con `sessionId`, artículo objetivo preseleccionado y callbacks de resultado. No se duplican formularios ni validaciones en un segundo árbol de React.

Los editores producen drafts controlados; no ejecutan «crear maestro» y luego `PUT` de referencia. `POST /api/scm/v1/altas-producto/{id}/pasos/ESTRUCTURA/aplicar` y el mismo comando para `RUTA_EMPAQUE` llaman los servicios canónicos y guardan sesión, referencias, auditoría y resultado bajo una única unidad de trabajo.

Los servicios canónicos aceptan ejecución sin `commit` cuando los compone el alta guiada. Ningún subcomando confirma por su cuenta. Si falla ESTRUCTURA o cualquier unidad de RUTA_EMPAQUE, se revierte la fase completa: no queda ruta, perfil, asignación, regla, evento ni `ScmOperacion` incompleta. Antes de editar, vincular o publicar se verifica que cada revisión pertenezca al PT/perfil de la sesión.

`ESTRUCTURA` admite alta contextual de WIP dentro de la misma unidad de trabajo:

```json
{
  "wips_nuevos": [
    {"client_id": "wip-cesto", "nombre": "Cesto prearmado", "requiere_calidad": false}
  ],
  "estructura": {
    "payload": {
      "componentes": [
        {"articulo_client_id": "wip-cesto", "cantidad": 1, "unidad": "UN"}
      ]
    }
  }
}
```

Cada componente usa XOR `articulo_id | articulo_client_id`. La respuesta resuelve `wips:[{client_id, articulo_ref}]` y no deja WIP huérfano si falla la BOM.

`RUTA_EMPAQUE` cubre exactamente cada salida única de la ruta, no sólo el PT terminal:

```json
{
  "ruta": {"modo": "NUEVA|EDITAR|REUTILIZAR", "accion": "GUARDAR_BORRADOR|ENVIAR|PUBLICAR", "payload": {}},
  "empaques": [
    {
      "client_id": "salida-pieza-color",
      "articulo_ref": 25,
      "perfil_empacable": {"modo": "NUEVO|REUTILIZAR", "payload": {}},
      "regla_empaque": {"modo": "NUEVA|EDITAR|REUTILIZAR", "accion": "GUARDAR_BORRADOR|ENVIAR|PUBLICAR", "payload": {}}
    }
  ]
}
```

No se admiten salidas duplicadas ni faltantes. Reutilizar un perfil conserva las asociaciones alternativas existentes del artículo; sólo cambia el predeterminado de forma explícita.

Volver a aplicar una fase C materializada exige `supersedes_application_key`, que debe señalar la aplicación `APPLIED` vigente. Se crea una nueva entrada de journal y se conserva la anterior como historial; A/B no permiten este reemplazo.

## 3. Readiness

El contrato existente `POST /api/scm/v1/altas-producto/{id}/validar` se fortalece para consultar fuentes canónicas. No se agrega una segunda ruta de readiness.

Respuesta:

```json
{
  "status": "BLOCKED|PENDING_APPROVAL|READY",
  "checked_at": "2026-08-10T00:00:00Z",
  "items": [
    {
      "code": "ROUTE_NOT_APPROVED",
      "severity": "BLOCKER",
      "paso": "RUTA_EMPAQUE",
      "entity": {"type": "RUTA", "id": 10},
      "message": "La ruta aún no está publicada.",
      "action": "OPEN_STEP"
    }
  ]
}
```

La evaluación consulta estado actual y no confía en el snapshot de la sesión. Como mínimo verifica:

1. PT y subtipo Artículo SCM activos;
2. toda PiezaColor usada es resoluble y activa;
3. estructura aprobada vigente del PT y de cada WIP consumido, recorriendo recursivamente WIP anidados y detectando ciclos;
4. ruta aprobada vigente, DAG válido y terminal PT;
5. cada operación de fabricación resuelve molde/salidas y formulación aprobada aplicable;
6. cada salida de ruta que genera mangas coincide con el perfil y la revisión de regla seleccionados por la sesión; una revisión seleccionada BORRADOR no queda oculta por otra regla aprobada del mismo perfil;
7. ninguna referencia maestra necesaria está inactiva.

Una fase de Ingeniería aplicada queda `COMPLETADO` como **captura**, aunque su revisión canónica esté BORRADOR o PENDIENTE. Ese estado externo produce `PENDING_APPROVAL`; no se degrada artificialmente a `BLOCKED` por confundir captura con publicación. En COLORES, en cambio, una formulación declarada `PENDIENTE` sigue siendo información faltante y bloquea.

El conjunto exacto depende de BOM y ruta. Una regla que no aplica se marca `NOT_APPLICABLE`, no bloqueo.

## 4. Aplicación, aprobación y capacidades

Las acciones `GUARDAR_BORRADOR`, `ENVIAR` y `PUBLICAR` forman parte de `/pasos/{codigo}/aplicar`, no de `finalizar`:

- vincular o reutilizar exige `ESTRUCTURA_VER`, `RUTA_VER` o `EMPAQUE_VER` según el dominio;
- crear, editar o asignar exige la capacidad `*_ADMINISTRAR` correspondiente;
- publicar directamente exige además `*_PUBLICAR_DIRECTO`;
- reutilizar un perfil siempre exige `EMPAQUE_ADMINISTRAR`, porque establecerlo como predeterminado modifica `ScmArticuloPerfil`;
- la UI muestra el handoff antes de llamar la API cuando falta una capacidad; el backend sigue siendo la autoridad.

No se otorga una capacidad global “WIZARD_PUBLICAR_TODO”. Una acción sin permiso devuelve 403 y revierte toda la fase C.

La fase `REVISION` exige tres confirmaciones canónicas y un snapshot explícito de las entidades revisadas. Para estructura, ruta y reglas se registra `{tipo, id, version|content_hash}`. `finalizar` vuelve a leer esas referencias y rechaza `REVISION_CONFIRMATION_STALE` si alguna cambió después de la revisión del usuario.

## 5. Volver atrás

- una revisión BORRADOR se reabre en sitio mediante reaplicación explícita y `supersedes_application_key`;
- una `PENDIENTE_APROBACION` exige retirar/cancelar mediante su regla canónica antes de editar;
- una APROBADA se clona a nueva revisión;
- cambiar una estructura marca la ruta y readiness como potencialmente desactualizados, pero no los retira automáticamente;
- la UI muestra un diff de alto nivel antes de crear la nueva revisión.

## 6. Finalización

`POST /api/scm/v1/altas-producto/{id}/finalizar` recibe `expected_version`, revalida el snapshot de `REVISION` y exige readiness fresco:

- `READY` → sesión `FINALIZADA`, resultado **Listo para planificar**;
- `PENDING_APPROVAL` → puede cerrar captura, conserva estado funcional **Pendiente de aprobación**;
- `BLOCKED` → no finaliza; ofrece guardar y salir.

Finalizar no crea OP ni reserva inventario.

La etiqueta final distingue **Captura finalizada · pendiente de aprobación** de **Listo para planificar**. Sólo `READY` habilita el segundo mensaje.

## 7. Pruebas

| Escenario | Nivel |
|---|---|
| AGP-C01 | integración PostgreSQL del grafo de estructura |
| AGP-C02 | UI + servicio de ruta terminal |
| AGP-C03 | integración de calculadora/perfil/regla |
| AGP-C04 | contrato readiness + navegación UI |
| AGP-C05 | autorización backend por cada dominio |
| AGP-C06 | E2E corto de finalización honesta |
| AGP-C07 | integración de idempotencia/reintento parcial |
| AGP-C08 | rollback total ante falla intermedia y reintento sin huérfanos |
| AGP-C09 | WIP contextual y BOM recursiva multinivel |
| AGP-C10 | ruta con dos salidas, dos perfiles/reglas y replay idempotente |
| AGP-C11 | referencias ajenas/capacidades por modo dejan cero mutaciones |
| AGP-C12 | confirmación de revisión queda obsoleta ante cambio canónico |

### Primera RED

`test_validar_alta_bloquea_pt_con_ruta_borrador`: debe fallar mientras `validar` sólo compruebe completitud estructural de los pasos.

### E2E mínimo

Crear/reutilizar la sesión `UAT COLADOR #3`, completar los seis pasos, publicar con Gestor de Maestros y comprobar `READY`. Una segunda prueba deja la estructura pendiente y exige `PENDING_APPROVAL` sin falso éxito.

## 8. Observabilidad

Registrar por sesión y paso: duración, reintentos, códigos de bloqueo y created/reused. No enviar nombres, recetas ni contenido de fuentes a telemetría externa. Métricas mínimas: tasa de abandono por paso, conflictos de versión y tiempo hasta `READY`.

## 9. Puerta de aprobación

- editores compartidos sin divergencia con Ingeniería SCM;
- readiness autoritativo y testeado;
- publicación respeta capacidades y versiones;
- UAT de seis pasos, reanudación y backtracking aprobada;
- alias del asistente anterior y documentación de deprecación listos.
