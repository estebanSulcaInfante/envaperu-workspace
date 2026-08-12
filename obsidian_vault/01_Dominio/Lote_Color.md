---
tipo: modelo_transicion
tabla: lote_color
estado: activo-evoluciona
tags: [dominio, fabricacion, corrida, color, produccion]
relaciones_padre:
  - "[[Orden_Fabricacion]]"
relaciones_hijos:
  - "[[Composicion_Materiales]]"
  - "[[Receta_Colorantes]]"
relaciones:
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-07-29
---

# Lote de Color / Corrida de Fabricación

`LoteColor` es el nombre técnico actual de una corrida por color dentro de la
entidad legacy `OrdenProduccion`. En el modelo objetivo evoluciona a
`CorridaFabricacion`, hija de [[Orden_Fabricacion]].

No es un lote inventariable ni una línea de `ProductoTerminado`. Es una
instrucción planificada que agrupa un único color/receta y las coladas que se
ejecutarán con el molde de la OF.

## Campos objetivo

| Campo | Regla |
|---|---|
| `orden_fabricacion_id` | OF técnica padre. La FK actual `orden_id` es transición. |
| `codigo/revision` | Identidad estable de corrida dentro de la OF. |
| `color_produccion_id` | Un único color exacto. |
| `receta_revision_id/hash` | Revisión congelada al liberar. |
| `material_policy_snapshot` | Materia base y política aplicable. |
| `ciclos_objetivo` | Entero positivo; autoridad física de planificación. |
| `secuencia` | Orden de ejecución dentro de la OF. |
| `estado` | `BORRADOR`, `LIBERADA`, `EN_EJECUCION`, `COMPLETADA`, `ANULADA`. |

## Salidas

Una corrida posee N `SalidaFabricacion` derivadas de la composición del molde:

- artículo `PiezaColor`, WIP o PT permitido por la ruta;
- cantidad por ciclo;
- peso unitario snapshot;
- cantidad y kg estándar objetivo;
- cantidad asignada a demanda;
- excedente inevitable.

El campo actual `producto_sku_output` no es autoridad y deja de usarse en altas
nuevas. Un molde multipieza no se reduce a un producto singular.

## Compatibilidad con `meta_kg`

`meta_kg` se conserva en filas legacy y puede seguir mostrándose en la impresión
histórica. Para órdenes nuevas:

```text
ciclos_objetivo =
    ceil(unidades_faltantes_limitantes / cantidad_por_ciclo_limitante)

cantidad_salida =
    ciclos_objetivo * cantidad_por_ciclo_snapshot

kg_estandar_salida =
    cantidad_salida * peso_unitario_snapshot_gr / 1000
```

Los kg son una salida calculada. No se liberan fracciones de colada ni se usa
`meta_kg` como única entrada comercial.

## Relaciones

- **Padre objetivo:** [[Orden_Fabricacion]].
- **Ejecución:** N [[Registro_Diario|OT]], cada una enlazada a esta corrida.
- **Hijos técnicos:** requerimientos de material, receta congelada y N salidas.
- **Cobertura:** cada salida se asigna N:M a líneas de [[Orden_Produccion]].

## Invariantes

1. Una corrida usa un único color y receta.
2. Los ciclos liberados son enteros.
3. Sus salidas proceden del mismo molde/revisión congelados por la OF.
4. Una OT no infiere la corrida por nombre de color.
5. La corrida no crea inventario; sus confirmaciones físicas lo hacen.
