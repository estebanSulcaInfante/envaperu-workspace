---
tipo: modelo_dominio
estado: propuesto
tags: [scm, molienda, compatibilidad, maestro, versionado]
relaciones:
  - "[[Orden_Molienda]]"
  - "[[Lote_Material_Recuperado]]"
  - "[[2026-08-02_Compatibilidad_y_Dilucion_Controlada_en_Molienda]]"
fecha_creacion: 2026-08-02
fecha_actualizacion: 2026-08-03
---

# Regla de Compatibilidad de Reproceso

Maestro versionado que determina si un aporte de merma recuperable puede
participar en una molienda con una especificación objetivo.

Las familias de materia prima, procesos, colores y condiciones referenciados
son catálogos administrables. El dominio define sus identidades y relaciones,
pero no contiene listas cerradas como PP, PEAD, inyección o soplado.

## Dimensiones mínimas

| Dimensión | Objetivo | Aportante |
|---|---|---|
| Familia de materia prima | Requerida | Requerida |
| Proceso | Proceso de uso esperado | Proceso de origen |
| Color/familia de color | Requerida | Requerida |
| Condición | Calidad admitida | Condición observada |

Una revisión puede ampliar estas dimensiones con grado, aditivo, contaminación
o número de reprocesos sin alterar el significado histórico de revisiones ya
usadas.

## Resultado

- `COMPATIBLE`: sin límite adicional distinto de la capacidad de la orden.
- `CONDICIONADA`: requiere `porcentaje_maximo` mayor que cero.
- `INCOMPATIBLE`: no puede participar en la molienda objetivo.
- `SIN_REGLA`: resultado operativo cuando no existe una revisión aplicable; no
  equivale a compatible.

## Gobierno

Cada revisión conserva código estable, versión, vigencia, estado, motivo
técnico, creador, aprobador y fecha. Una revisión aprobada no se edita; se crea
otra. Toda [[Orden_Molienda]] congela el identificador, versión y valores de las
reglas evaluadas.

La configuración inicial validada admite una regla condicionada y simétrica
entre inyección y soplado con aporte minoritario máximo de `10 %`: cualquiera
de los dos puede ser el proceso minoritario. Familia/color aplicables y
porcentaje permanecen configurables y versionados.

Una regla puede relacionar familias de color diferentes con un mismo color
nominal objetivo. Debe declarar `color_objetivo_id`, condiciones de aporte y,
cuando corresponda, límites porcentuales. La coincidencia de HEX o nombre no
sustituye esta relación explícita.
