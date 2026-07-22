---
tipo: modelo_bd
uso: modelo_bd
estado: aprobado-para-desarrollo
tags: [dominio, catalogo, clasificacion, familia, TS-014]
relaciones:
  - "[[Linea]]"
  - "[[LineaFamilia]]"
  - "[[FamiliaColor]]"
  - "[[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]]"
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# Familia

## Metadata

- **Tabla BD:** `familia`
- **Estado:** objetivo aprobado en [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD|TS-014]]
- **Fecha de definición:** 2026-07-22

## Descripción

Maestro de agrupación comercial o productiva, por ejemplo `BALDES` o `JARRAS`. Una Familia puede estar habilitada en varias [[Linea|Líneas]] mediante [[LineaFamilia]].

> [!IMPORTANT]
> `Familia` clasifica productos y piezas. No es [[FamiliaColor]], que clasifica acabados de color como SÓLIDO o TRANSPARENTE.

## Campos de la tabla

| Atributo | Tipo / Origen | Descripción | Lógica |
| :--- | :--- | :--- | :--- |
| **id** | Integer PK | Identidad técnica estable. | Inmutable. |
| **codigo** | Integer | Código único del catálogo. | Se conserva en migración y no se reutiliza. |
| **nombre** | String(100) | Nombre visible único. | No determina una Línea por sí solo. |
| **activo** | Boolean | Disponibilidad lógica del maestro. | `true` por defecto. |
| **version** | Integer | Versión de concurrencia optimista. | Inicia en `1` y aumenta por escritura. |

## Validaciones

- `codigo` y `nombre` son obligatorios y únicos, incluso para filas inactivas.
- `version > 0`.
- Una Familia es seleccionable solo si ella, la Línea y su asociación están activas.
- No puede inactivarse mientras cualquier `ProductoTerminado`, `Pieza` o `PiezaColor` la referencie.
- La baja es lógica; no existe borrado físico funcional.

## Estructura JSON de referencia

```json
{
  "id": 7,
  "codigo": 14,
  "nombre": "BALDES",
  "activo": true,
  "version": 2
}
```

## Relaciones

- **N:M:** [[Linea]] mediante [[LineaFamilia]].
- **Consumidores:** `ProductoTerminado`, `Pieza` y compatibilidad legacy de `PiezaColor`.
- **Fuente técnica:** [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]].

