---
tipo: modelo_bd
tabla: scm_proveedor
estado: activo
tags: [dominio, maestro, SCM, proveedor, US-010A]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# ProveedorSCM

Maestro de proveedores que respaldan compras y recepciones de materiales.

| Campo | Regla |
| :--- | :--- |
| `codigo` | Correlativo autogenerado y estable. |
| `razon_social` | Nombre legal o comercial obligatorio. |
| `ruc` | Opcional; si se informa debe contener 11 dígitos y ser único. |
| `activo`, `version` | Baja lógica y concurrencia optimista. |

La trazabilidad por bolsa puede conservar un conjunto de proveedores candidatos cuando se mezclan insumos y no existe lote externo confiable; no se inventa una asignación exacta por bolsa.
