---
tipo: modelo_bd
tabla: scm_alta_producto_sesion
estado: propuesto
tags: [dominio, workflow, catalogo, borrador, producto-terminado]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
relaciones:
  - "[[ProductoTerminado]]"
  - "[[../05_Especificaciones/02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
---

# Sesión de Alta de Producto

Agregado de workflow que conserva el avance de una alta guiada. No reemplaza a los maestros canónicos ni se usa para planificar producción.

## Campos propuestos

| Campo | Regla |
|---|---|
| `id` | UUID estable de la sesión. |
| `titulo` | Derivado del nombre/código del producto en `IDENTIDAD`; mientras no exista identidad resuelta usa el nombre provisional reconocible. No constituye otra identidad del PT. |
| `producto_terminado_id` | PT creado o reutilizado en IDENTIDAD; nullable hasta resolverlo. |
| `estado` | `BORRADOR`, `CON_BLOQUEOS`, `LISTA_PARA_PUBLICAR`, `FINALIZADA`, `ABANDONADA`. |
| `paso_actual` | Uno de los seis códigos congelados; sirve para reanudar, no para autorizar acciones. |
| `borrador_json` | Datos opacos versionados por paso, sin archivos binarios ni secretos. |
| `estados_paso_json` | Estado `PENDIENTE`, `EN_PROGRESO`, `COMPLETADO` o `INVALIDADO` por código. |
| `bloqueos_paso_json` | Errores estructurales y dependencias por paso. |
| `fuentes_json` | Procedencia declarada por paso: Excel, consulta o responsable. |
| `referencias_json` | IDs/códigos canónicos resueltos por paso. |
| `readiness_json` | Último conjunto calculado de bloqueos, advertencias y opcionales. |
| `invalidated_steps_json` | Pasos descendientes que deben revisarse después de un cambio. |
| `creada_por_id`, `actualizada_por_id` | Actor auditable. |
| `version` | Concurrencia optimista obligatoria. |
| timestamps | Creación, actualización, finalización o abandono. |

## Invariantes

- El borrador no crea inventario, órdenes ni movimientos.
- Una sesión finalizada o abandonada es inmutable salvo anotación administrativa separada.
- Una referencia canónica aplicada no se reemplaza por texto libre.
- Reintentar un paso con la misma clave idempotente devuelve el mismo resultado.
- Un conflicto de `version` responde `409` y conserva ambos estados para revisión; no aplica “última escritura gana”.
- Los datos faltantes se registran como pendientes explícitos. El sistema nunca completa una fuente desconocida por inferencia silenciosa.
- La retención y purga de sesiones abandonadas deben definirse antes de producción; nunca se eliminan entidades canónicas por purgar una sesión.
- `BORRADOR`, `CON_BLOQUEOS` y `LISTA_PARA_PUBLICAR` son estados abiertos: **Guardar y salir** los conserva y la bandeja permite reanudarlos en `paso_actual`.

## Pasos congelados para el piloto

1. `IDENTIDAD`: ProductoTerminado, clasificación y procedencia.
2. `COMPONENTES`: piezas, moldes, cavidades y salidas productivas.
3. `COLORES`: variantes PiezaColor, formulaciones e imágenes.
4. `ESTRUCTURA`: BOM multinivel y WIP.
5. `RUTA_EMPAQUE`: operaciones, recursos, perfiles y reglas de empaque.
6. `REVISION`: consistencia, pendientes y decisión de finalización/publicación.
