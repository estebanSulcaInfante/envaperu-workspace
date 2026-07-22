---
tipo: modelo_bd
tabla: scm_categoria_recepcion
estado: activo
tags: [dominio, maestro, SCM, recepcion, US-010A]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
---

# CategoriaRecepcionSCM

Configura el tratamiento de una clase de material al recibirla. No es una categoría comercial del material.

| Campo | Regla |
| :--- | :--- |
| `codigo`, `nombre` | Identidad única. |
| `modalidad` | `VIRGEN_CONFIANZA_PROVEEDOR`, `SEGUNDA_PESAJE_BOLSA` o `POR_CONFIGURAR`. |
| `requiere_lote_externo` | Exige lote del proveedor cuando sea confiable/disponible. |
| `recepcion_habilitada` | Permite usar la categoría en una recepción real. |
| `activo`, `version` | Baja lógica y concurrencia optimista. |

`POR_CONFIGURAR` nunca puede estar habilitada para recepción. En material de segunda, cada bolsa se pesa una sola vez, se identifica con sticker y se convierte en unidad trazable de almacenamiento.
