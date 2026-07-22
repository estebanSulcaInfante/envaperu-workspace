---
tipo: modulo
estado: placeholder
tags: [backend, api, endpoints]
fecha_creacion: 2026-04-21
---

# Backend — Endpoints API

> Este directorio documenta cada endpoint de la API REST del backend.

## Formato de Documentación

Cada archivo documenta un endpoint o grupo de endpoints con:
- Método HTTP y ruta
- Parámetros de entrada
- Estructura de respuesta JSON
- Reglas de negocio asociadas
- Entidades de dominio involucradas

## Endpoints Conocidos
- `GET /api/ordenes/<id>` → Ver [[Orden_Produccion]]
- `GET /api/ordenes/<op>/registros` → Ver [[Registro_Diario]]

### Clasificación de catálogo

- CRUD lógico/versionado de `/api/catalogo/lineas` → [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]] y [[Linea]].
- CRUD lógico/versionado de `/api/catalogo/familias` → [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]] y [[Familia]].
- Asociación `/api/catalogo/lineas/{linea_id}/familias` → [[LineaFamilia]].
- `GET /api/catalogo/familias?linea_id={id}` filtra mediante asociaciones N:M activas.

> **TODO:** Documentar todos los endpoints del backend aquí conforme se desarrollen.
