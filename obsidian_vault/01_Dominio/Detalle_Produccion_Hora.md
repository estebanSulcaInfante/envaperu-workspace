---
tipo: modelo_bd
tabla: detalle_produccion_hora
estado: activo
tags: [dominio, detalle, hora, seguimiento]
relaciones_padre:
  - "[[Registro_Diario]]"
fecha_creacion: 2026-04-21
---

# Detalle Producción Hora (Tabla Interna)

Cada [[Registro_Diario]] tiene N filas de detalle, una por cada hora trabajada. Permite el seguimiento hora-a-hora.

## Campos de la Tabla

| Atributo | Origen | Descripción |
| :--- | :--- | :--- |
| **Hora** | Auto | Franja horaria (ej. "07:00 - 08:00"). |
| **trabajador_id** | Input | FK al Catálogo de Trabajadores. |
| **maquinista_snapshot** | Snapshot | Nombre del operador (histórico/congelado) para trazabilidad (TS-009). |
| **Color** | Input | Color producido (puede cambiar por hora). |
| **Coladas Realizadas** | Input | Cantidad de ciclos en esa hora. |
| **Observación** | Input | Notas (parada, cambio de molde, etc.). |
| **Cantidad Piezas** | Calculado | `coladas_realizadas × cavidades` |
| **Kg Producidos** | Calculado | `(coladas_realizadas × peso_tiro_gr) / 1000` |

## Relaciones
- **Padre:** [[Registro_Diario]] (N:1)
