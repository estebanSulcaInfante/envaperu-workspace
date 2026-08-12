---
tipo: endpoint-api
estado: implementacion-local
tags: [backend, api, scm, empaque, mangas, perfiles, reglas, decimal, postgresql]
relaciones:
  - "[[Perfil_Empaque]]"
  - "[[Tipo_Manga]]"
  - "[[Articulo_SCM]]"
  - "[[Matriz_Roles_Capacidades_SCM_Produccion]]"
  - "[[TS-010R_Articulos_BOM_Rutas_WIP_y_Perfiles_Empaque]]"
  - "[[DEV-010R_R-Core_Articulos_BOM_Rutas_y_Empaque]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-08-05
---

# API SCM de Perfiles y Reglas de Empaque

Base: `/api/scm/v1`.

## Tipos de contenedor

| Método y ruta | Capacidad | Uso |
|---|---|---|
| `GET /tipos-contenedor` | `EMPAQUE_VER` | Listar tipos, opcionalmente por estado. |
| `POST /tipos-contenedor` | `EMPAQUE_ADMINISTRAR` | Crear un tipo con código automático. |
| `PUT /tipos-contenedor/{id}` | `EMPAQUE_ADMINISTRAR` | Editar datos físicos mediante `version`. |
| `DELETE /tipos-contenedor/{id}` | `EMPAQUE_ADMINISTRAR` | Baja lógica mediante `version`. |

La clase `MANGA` recibe códigos `TMG-######`. Otras clases usan `TCO-######`. Tara, tolerancia y peso bruto son `Numeric(12,3)` y pueden permanecer en cero mientras el maestro está en levantamiento; una regla basada en límites inviables no puede aprobarse.

## Perfiles empacables

| Método y ruta | Capacidad | Uso |
|---|---|---|
| `GET /perfiles-empacables` | `EMPAQUE_VER` | Listar geometrías/estados físicos. |
| `POST /perfiles-empacables` | `EMPAQUE_ADMINISTRAR` | Crear perfil `PEM-######`. |
| `PUT /perfiles-empacables/{id}` | `EMPAQUE_ADMINISTRAR` | Editar con `version`. |
| `DELETE /perfiles-empacables/{id}` | `EMPAQUE_ADMINISTRAR` | Baja lógica. |
| `GET /articulos/{id}/perfiles-empaque` | `EMPAQUE_VER` | Consultar perfiles aplicables. |
| `PUT /articulos/{id}/perfiles-empaque` | `EMPAQUE_ADMINISTRAR` | Reemplazar asociaciones y elegir como máximo un predeterminado activo. |

El perfil describe el acomodo: por ejemplo, pieza suelta y prearmado parcial pueden compartir artículo relacionado, pero no necesariamente la misma capacidad física.

## Reglas revisionadas

| Método y ruta | Capacidad | Uso |
|---|---|---|
| `GET /reglas-empaque` | `EMPAQUE_VER` | Listar revisiones; admite filtros por perfil y contenedor. |
| `POST /reglas-empaque` | `EMPAQUE_ADMINISTRAR` | Crear la siguiente revisión borrador de una combinación. |
| `GET /reglas-empaque/{revision_id}` | `EMPAQUE_VER` | Consultar límites, estado, snapshots y hash. |
| `PUT /reglas-empaque/{revision_id}` | `EMPAQUE_ADMINISTRAR` | Editar un borrador usando `version`. |
| `POST /reglas-empaque/{revision_id}/aprobar` | `EMPAQUE_APROBAR` | Aprobar con actor distinto e `Idempotency-Key`. |
| `POST /reglas-empaque/{revision_id}/publicar` | `EMPAQUE_PUBLICAR_DIRECTO` | Publicar el borrador propio como jefatura o Gerencia, conservando validaciones e idempotencia. |
| `POST /reglas-empaque/calcular` | `EMPAQUE_VER` | Calcular una distribución teórica sin crear mangas ni inventario. |

Una aprobación exige:

- medición física declarada como probada;
- `cantidad_objetivo_un <= cantidad_maxima_probada_un`;
- perfil y contenedor activos;
- peso bruto, tara superior y margen con límite neto positivo;
- actor aprobador distinto del creador en la aprobación ordinaria. Los roles
  `JEFE_*`, `GERENCIA` y `GERENTE_GENERAL` pueden publicar directamente con
  `EMPAQUE_PUBLICAR_DIRECTO`.

Al aprobar se congelan tara nominal, tolerancia de tara y peso bruto máximo. Cambiar después el maestro no altera la revisión publicada.

## Cálculo

```json
{
  "regla_revision_id": 12,
  "cantidad_planificada_un": 17,
  "peso_unitario_snapshot_g": "1000"
}
```

La respuesta incluye capacidad por peso, capacidad efectiva, número de contenedores y la distribución; la última manga puede ser parcial.

Todos los cálculos físicos usan `Decimal`. Ninguna confirmación de unidades se infiere desde el peso.

### Override

Se admiten `override_cantidad_un` y `tara_real_g` con `motivo_override`. Requieren `EMPAQUE_ADMINISTRAR` y nunca pueden aumentar la capacidad aprobada. Una tara real menor puede describir mejor la medición, pero no amplía el máximo publicado.

La calculadora R4 es una previsualización determinista. La creación persistente de planes, identidades de manga y evidencia operativa pertenece a US-010C/F.

## Errores estables

| Código | Significado |
|---|---|
| `PACKAGING_RULE_NOT_VIABLE` | Los límites no permiten una capacidad positiva o falta evidencia física. |
| `PACKAGING_OVERRIDE_EXCEEDS_LIMIT` | El override intenta ampliar la capacidad. |
| `PACKAGING_OVERRIDE_REASON_REQUIRED` | Falta motivo para usar valores operativos distintos. |
| `PACKAGING_RULE_NOT_EDITABLE` | Se intentó editar una revisión publicada. |
| `CREATOR_CANNOT_APPROVE` | El creador intentó aprobar su propia revisión. |
| `MULTIPLE_DEFAULT_PACKAGING_PROFILES` | Un artículo recibió más de un perfil predeterminado activo. |

## PostgreSQL

Las revisiones aprobadas conservan `content_hash` y snapshots físicos. Triggers bloquean cambios de contenido mediante SQL directo y el índice parcial garantiza una sola aprobación vigente por regla.
