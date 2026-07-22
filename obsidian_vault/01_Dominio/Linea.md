---
tipo: modelo_bd
uso: modelo_bd
estado: aprobado-para-desarrollo
tags: [dominio, catalogo, clasificacion, linea, TS-014]
relaciones:
  - "[[Familia]]"
  - "[[LineaFamilia]]"
  - "[[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]]"
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# Línea

## Metadata

- **Tabla BD:** `linea`
- **Estado:** objetivo aprobado en [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD|TS-014]]
- **Fecha de definición:** 2026-07-22

## Descripción

Maestro de una clasificación comercial o productiva de alto nivel. Una Línea puede habilitar varias [[Familia|Familias]] y una Familia puede participar en varias Líneas mediante [[LineaFamilia]].

## Campos de la tabla

| Atributo | Tipo / Origen | Descripción | Lógica |
| :--- | :--- | :--- | :--- |
| **id** | Integer PK | Identidad técnica estable. | Inmutable. |
| **codigo** | Integer | Código único del catálogo. | Se conserva en migración y no se reutiliza. |
| **nombre** | String(50) | Nombre visible único. | No determina relaciones por sí solo. |
| **activo** | Boolean | Disponibilidad lógica del maestro. | `true` por defecto. |
| **version** | Integer | Versión de concurrencia optimista. | Inicia en `1` y aumenta por escritura. |

## Validaciones

- `codigo` y `nombre` son obligatorios y únicos, incluso para filas inactivas.
- `version > 0`.
- Una Línea es seleccionable solo si está activa.
- No puede inactivarse mientras cualquier `ProductoTerminado`, `Pieza` o `PiezaColor` la referencie.
- La baja es lógica; no existe borrado físico funcional.

## Estructura JSON de referencia

```json
{
  "id": 1,
  "codigo": 1,
  "nombre": "HOGAR",
  "activo": true,
  "version": 3
}
```

## Relaciones

- **N:M:** [[Familia]] mediante [[LineaFamilia]].
- **Consumidores:** `ProductoTerminado`, `Pieza` y compatibilidad legacy de `PiezaColor`.
- **Fuente técnica:** [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]].

