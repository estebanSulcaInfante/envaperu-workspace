---
tipo: modelo_objetivo
estado: implementado-local-r-core
tags: [dominio, scm, articulo, bom, wip, producto, US-010R]
relaciones:
  - "[[PiezaColor]]"
  - "[[ProductoTerminado]]"
  - "[[Lote_WIP]]"
  - "[[Lote_Producto_Terminado]]"
  - "[[Ruta_Produccion]]"
  - "[[Perfil_Empaque]]"
  - "[[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-07-25
---

# Artículo SCM

Identidad común para cualquier salida o componente inventariable que deba planificarse, consumirse, almacenarse, embolsarse o recorrer una genealogía de manufactura. Evita que una [[PiezaColor]] tenga que fingir que es kit, WIP o producto terminado.

## Estado de implementación

El incremento R1 está implementado localmente mediante la migración expand `c91d4e7a2b60`:

- `scm_articulo`, `scm_articulo_pieza_color`, `scm_definicion_wip` y `scm_articulo_producto`;
- backfill reproducible de PiezaColor y ProductoTerminado;
- dual-write transaccional para altas nuevas;
- correlativo `WIP-*`;
- triggers PostgreSQL de subtipo exacto e identidad inmutable;
- lectura unificada y alta autorizada de WIP.

La BOM revisionada quedó implementada en R2 mediante `scm_estructura_revision` y
`scm_estructura_componente`, aprobación segregada, hash, CTE recursivo y guardas
PostgreSQL. R3 implementó rutas y centros; R4 implementó perfiles y reglas de
empaque; R5/R6 completaron la vista y el CRUD local de esos maestros. Los lotes
comunes y la ejecución runtime pertenecen a US-010F y posteriores.

El backfill conserva también catálogos legacy defectuosos: normaliza códigos y,
si la clave está vacía o colisiona, genera una identidad SCM estable sin cambiar
la PK legacy referenciada. Un producto con PK legacy vacía es visible para
conciliación, pero no es enrutable hasta sanear esa clave.

## Clasificación

| Tipo | Significado |
|---|---|
| `PIEZA_COLOR` | Pieza física producible por molde con color exacto. |
| `SUBENSAMBLE_WIP` | Resultado intermedio físicamente existente que será consumido por otra operación. |
| `PRODUCTO_TERMINADO` | SKU comercial completo y potencialmente despachable. |

`MATERIAL` puede incorporarse al mismo supertipo en una fase posterior si la Tech Spec demuestra que no duplica la identidad ya gobernada por [[MaterialSCM]]. No es necesario forzar esa migración para resolver el primer corte de producción.

El modelo relacional objetivo usa una identidad base y subtipos 1:1, no un par polimórfico `tipo + id` sin integridad:

```text
ArticuloSCM
├── ArticuloPiezaColor       -> PiezaColor
├── ArticuloWIPWIP  -> DefinicionWIP
└── ArticuloProducto        -> ProductoTerminado
```

Cada subtipo conserva sus responsabilidades. `ArticuloSCM` no absorbe cavidades, color, clasificación comercial ni datos de molde.

## Estructura/BOM multinivel

`RevisionEstructuraArticulo` define qué artículos componen otro artículo:

| Campo | Regla |
|---|---|
| `articulo_resultado_id` | Artículo padre producido por la estructura. |
| `numero_revision` | Correlativo por artículo resultado. |
| `estado` | `BORRADOR`, `APROBADA` o `RETIRADA`. |
| `vigente_desde`, `vigente_hasta` | Vigencia auditable. |
| `content_hash` | Huella canónica de cabecera y líneas. |
| `aprobada_por_id`, `aprobada_at` | Autoridad de aprobación. |

`ComponenteEstructuraArticulo` referencia `articulo_componente_id`, cantidad positiva y unidad compatible. Esto permite:

```text
PiezaColor
  -> WIP WIP
      -> otro WIP WIP
          -> ProductoTerminado
```

La estructura declara **qué contiene** el resultado. [[Ruta_Produccion]] declara **en qué operación, orden y lugar** se transforma.

## Invariantes

- [[PiezaColor]] representa una sola pieza física coloreada; no admite `tipo=KIT`.
- Un WIP que se cuenta, pesa, mueve o almacena posee identidad `SUBENSAMBLE_WIP`.
- Un artículo solo se considera `PRODUCTO_TERMINADO` cuando completa la estructura comercial aprobada.
- Una revisión aprobada es inmutable. Todo cambio crea otra revisión.
- La pareja `revision_id + articulo_componente_id` es única.
- Un artículo no puede contenerse directa ni indirectamente a sí mismo. La aprobación valida el grafo completo y rechaza ciclos.
- Las cantidades de artículos discretos son enteras; cualquier unidad distinta exige una conversión aprobada.
- La ejecución congela revisión, hash y snapshot legible; editar maestros no altera OP, órdenes, lotes o bolsas históricos.
- El tipo de artículo no se deduce desde su nombre, color, bolsa o ubicación.

## Retiro del kit legacy

La implementación `PiezaColor.tipo=KIT` + `PiezaComponente` nunca tuvo datos operativos en EnvaPerú. No se reutiliza como fundamento del modelo nuevo porque mezclaba pieza inyectada, composición y producto comercial.

La migración debe:

1. comprobar explícitamente que no existen filas `PiezaColor.tipo=KIT` ni `PiezaComponente`;
2. fallar y exigir conciliación si aparece cualquier fila inesperada;
3. retirar el alta de kits de API y frontend;
4. eliminar columnas/tabla legacy mediante la estrategia expand/contract aprobada;
5. no fabricar productos, WIP ni genealogía para datos inexistentes.

En `enva_test`, los dos KIT y cuatro componentes encontrados eran mocks
descartables. El usuario autorizó su eliminación y luego el retiro de la
estructura el 2026-07-25. La revisión `a61c8d2f4e90` eliminó
`pieza_componente` y `pieza_color.tipo` después de comprobar evidencia cero.
Otros ambientes siguen obligados a ejecutar su propia precondición.
