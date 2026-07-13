---
tipo: modelo_bd
tabla: registro_diario_produccion
estado: activo
tags: [dominio, core, registro, turno, produccion]
relaciones_padre:
  - "[[Orden_Produccion]]"
relaciones_hijos:
  - "[[Detalle_Produccion_Hora]]"
  - "[[Control_Peso]]"
fecha_creacion: 2026-04-21
---

# Registro Diario de Producción (Hoja de Producción)

Representa la "Hoja de Producción" física que se llena por turno. Es hija de [[Orden_Produccion]] y contiene la producción real reportada por los maquinistas.

## Campos de la Tabla

| Atributo / Campo | Origen de Dato | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **ID Registro** | Auto (BD) | Identificador único del registro diario. | `AUTOINCREMENT` |
| **Orden ID (FK)** | Selección | Referencia a la [[Orden_Produccion]] padre. | - |
| **Máquina ID (FK)** | Selección | Máquina donde se ejecutó la producción. | - |
| **Fecha** | Input (Manual) | Fecha del turno de producción. | - |
| **Turno** | Input (Select) | DIURNO, NOCTURNO, o EXTRA. | - |
| **Hora Inicio** | Input (Manual) | Hora de arranque (ej. 07:00). | - |
| **Colada Inicial** | Input (Manual) | Contador de la máquina al inicio del turno. | - |
| **Colada Final** | Input (Manual) | Contador de la máquina al final del turno. | - |
| **Tiempo Ciclo Reportado** | Input (Manual) | T/C observado en el panel (segundos). | - |
| **Tiempo Enfriamiento** | Input (Manual) | Tiempo de enfriamiento observado (seg). | - |

## Snapshots del Registro (Captura al Crear)

Se copian de la [[Orden_Produccion]] al momento de crear el registro para mantener consistencia histórica.

| Atributo | Origen | Descripción |
| :--- | :--- | :--- |
| **snapshot_cavidades** | Orden | Total de cavidades del golpe al crear el registro. |
| **snapshot_peso_neto_gr** | Orden | Peso neto total del golpe (todas las piezas, gramos). |
| **snapshot_peso_colada_gr** | Orden | Peso del ramal/colada (gramos). |
| **maquina_codigo_snapshot** | Maquina | Código de la máquina en el momento (TS-009). |
| **maquina_nombre_snapshot** | Maquina | Nombre de la máquina en el momento (TS-009). |

## Totalizadores (Calculados)

| Atributo | Descripción | Fórmula | Prioridad |
| :--- | :--- | :--- | :--- |
| **total_coladas_calculada** | Ciclos realizados en el turno. | `colada_final - colada_inicial` | Contadores > Suma detalles |
| **total_piezas_buenas** | Piezas buenas producidas. | `total_coladas_calculada × snapshot_cavidades` | - |
| **total_kg_real** | Kg reales del turno. | `SUM(ControlPeso.peso_real_kg)` | Pesajes reales > Cálculo coladas |

> **Nota sobre `total_kg_real`:** Prioridad 1: suma de pesajes físicos ([[Control_Peso]]). Prioridad 2 (fallback): `total_coladas × (peso_neto_gr + peso_colada_gr) / 1000`.

## Estructura JSON (Referencia API)

Endpoint: `GET /api/ordenes/<op>/registros`

```json
{
  "id": 1,
  "fecha": "2023-11-21",
  "turno": "DIURNO",
  "maquina": "INY-05",
  "orden": "OP-1322",
  "contadores": { "inicial": 1000, "final": 1500, "total": 500 },
  "parametros": { "ciclo": 30.0, "enfriamiento": 5.0 },
  "totales_estimados": { "piezas": 1000, "kg_total": 88.0 },
  "detalles": [ ... ]
}
```

## Relaciones
- **Padre:** [[Orden_Produccion]] (N:1)
- **Hijos:** [[Detalle_Produccion_Hora]] (1:N), [[Control_Peso]] (1:N)
