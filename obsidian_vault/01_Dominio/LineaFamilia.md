---
tipo: modelo_bd
uso: modelo_bd
estado: aprobado-para-desarrollo
tags: [dominio, catalogo, clasificacion, linea, familia, asociacion, TS-014]
relaciones:
  - "[[Linea]]"
  - "[[Familia]]"
  - "[[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]]"
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# LíneaFamilia

## Metadata

- **Tabla BD:** `linea_familia`
- **Estado:** objetivo aprobado en [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD|TS-014]]
- **Fecha de definición:** 2026-07-22

## Descripción

Entidad de intersección que materializa qué [[Familia|Familias]] están habilitadas para cada [[Linea|Línea]]. Es la fuente autoritativa para filtros y validaciones; reemplaza cualquier mapeo hardcodeado en frontend.

## Campos de la tabla

| Atributo | Tipo / Origen | Descripción | Lógica |
| :--- | :--- | :--- | :--- |
| **id** | Integer PK | Identidad estable de la asociación. | Se reutiliza al reactivar el par. |
| **linea_id** | FK → `linea.id` | Línea participante. | Obligatoria; borrado físico restringido. |
| **familia_id** | FK → `familia.id` | Familia participante. | Obligatoria; borrado físico restringido. |
| **activo** | Boolean | Habilitación lógica del par. | `true` por defecto. |
| **version** | Integer | Evidencia incremental de cambios. | Inicia en `1`; el backend la aumenta al asociar, desasociar o reactivar. |

## Validaciones

- `UNIQUE(linea_id, familia_id)` sin considerar el estado.
- `version > 0`.
- Un par es seleccionable solo si la asociación y ambos maestros están activos.
- No puede desasociarse mientras cualquier `ProductoTerminado`, `Pieza` o `PiezaColor` conserve ese par.
- La desasociación es lógica. Una reactivación actualiza esta misma fila.
- En el incremento de TS-014, POST y DELETE no exigen `version` al cliente; el servidor la mantiene de forma autoritativa.
- Índices funcionales: `(linea_id, activo)` y `(familia_id, activo)`.

## Estructura JSON de referencia

```json
{
  "id": 18,
  "linea_id": 1,
  "familia_id": 7,
  "activo": true,
  "version": 3
}
```

## Relaciones

- **Padres:** [[Linea]] y [[Familia]].
- **Consumidores validados:** `ProductoTerminado`, `Pieza` y compatibilidad legacy de `PiezaColor`.
- **Fuente técnica:** [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]].
