---
tipo: modelo_bd
tabla: orden_produccion
estado: activo
tags: [dominio, core, cabecera, produccion]
relaciones:
  - hijos: [[Lote_Color]], [[Registro_Diario]]
  - snapshots: [[Snapshot_Composicion_Molde]]
fecha_creacion: 2026-04-21
---

# Orden de Producción (Cabecera Global)

Es la entidad padre (`OrdenProduccion`). Contiene la configuración técnica de la máquina, el molde y los parámetros de producción.

## Campos de la Tabla

| Atributo / Campo | Origen de Dato | Descripción | Fórmula / Lógica |
| :--- | :--- | :--- | :--- |
| **Nº OrdenProduccion** | Input (Sistema) | Identificador único (ej. OP-1322). Primary Key tipo String. | - |
| **Fecha Creación** | Automático | Fecha de registro en BD (Timestamp UTC). | `NOW()` |
| **F. Inicio** | **Input (Usuario)** | Fecha planificada para el arranque de producción. | - |
| **Producto (SKU)** | Input (Usuario) | FK a `ProductoTerminado`. Incluye campo `producto` como nombre en cache. | - |
| **Molde (Código)** | Input (Usuario) | FK a `Molde`. Incluye campo `molde` como nombre en cache. | - |
| **Máquina** | Input (Usuario) | FK a `Maquina`. | - |
| **Activa** | Automático | Estado de la orden (abierta/cerrada). Default: `true`. Una OP cerrada no permite crear nuevos Registros Diarios. | `Boolean` |
| **Snapshot T. Ciclo (seg)** | Input (Técnico) | Duración de un ciclo de inyección en segundos. | - |
| **Snapshot Horas Turno** | Input (Técnico) | Horas laborales por día (ej. 23 o 24). | - |
| **Snapshot Peso Colada (g)** | Input (Técnico) | Peso del ramal/runner (gramos). No incluye piezas. | - |
| **Ciclos** | Input (Técnico) | Cantidad de ciclos teóricos (opcional). | - |
| **T/C (Tipo Cambio)** | Input (Finanzas) | Tipo de cambio USD/PEN al crear la orden (para costeo). | - |

> **Eliminado:** El campo `tipo_orden` (estrategia Por Peso / Por Cantidad / Stock) fue removido en el refactoring. La única estrategia vigente es `meta_kg` directo por lote. Ver [[2026-04-21_Refactor_Estrategia_Meta_Kg]].

## Cálculos Cacheados (Persistidos en BD)

Todos se actualizan llamando a `actualizar_metricas()`, que también dispara en cascada a los [[Lote_Color]] hijos.

| Columna Persistida | Descripción | Fórmula |
| :--- | :--- | :--- |
| **calculo_peso_neto_golpe** | Peso neto total del golpe (piezas, sin colada). | `SUM(snap.cavidades × snap.peso_unit_gr)` |
| **calculo_peso_tiro_gr** | Peso total del golpe (piezas + ramal). | `peso_neto_golpe + snapshot_peso_colada_gr` |
| **calculo_cavidades_totales** | Total de cavidades del golpe. | `SUM(snap.cavidades)` |
| **calculo_colores_activos** | Número de lotes activos en la OP. | `len(lotes)` |
| **calculo_peso_produccion** | Meta neta total de producción. | `SUM(lote.meta_kg)` |
| **calculo_merma_pct** | % de merma (solo colada/runner). | `(peso_tiro - peso_neto) / peso_tiro` |
| **calculo_peso_inc_merma** | Producción incluyendo merma natural. | `calculo_peso_produccion × (1 + calculo_merma_pct)` |
| **calculo_merma_natural_kg** | Kilos físicos de desperdicio (colada). | `calculo_peso_inc_merma - calculo_peso_produccion` |
| **calculo_horas** | Tiempo estimado de inyección (horas). | `golpes × ciclo_seg / 3600` |
| **calculo_dias** | Tiempo estimado en días. | `calculo_horas / snapshot_horas_turno` |
| **calculo_fecha_fin** | Fecha estimada de finalización. | `fecha_inicio + timedelta(days=calculo_dias)` |
| **calculo_familia_color** | Cache del nombre de familia de color del producto. | Desde `ProductoTerminado.familia_color_rel` |

> **Nota sobre `calculo_merma_pct`:** La merma se calcula **únicamente** como el desperdicio físico del ramal/colada (runner), no como una merma de producción configurable. Es un dato objetivo del molde.

## Propiedades Derivadas (desde [[Snapshot_Composicion_Molde]])

| Propiedad | Fórmula |
| :--- | :--- |
| **peso_neto_golpe_gr** | `SUM(snapshot.peso_subtotal_gr)` |
| **peso_tiro_gr** | `peso_neto_golpe_gr + snapshot_peso_colada_gr` |
| **cavidades_totales** | `SUM(snapshot.cavidades)` |
| **es_multipieza** | `len(snapshot_composicion) > 1` |

## Estructura JSON (Referencia API)

Endpoint: `GET /api/ordenes/<id>`

```json
{
  "numero_op": "OP-1322",
  "producto": "BALDE ROMANO",
  "maquina": "M1",
  "tipo_maquina": "Hidráulica 500T",
  "fecha": "2023-11-20T08:00:00",
  "fecha_inicio": "2023-11-21T07:00:00",
  "molde": "MOLDE-BALDE-01",
  "activa": true,
  "snapshot_tecnico": {
    "tiempo_ciclo_seg": 30.0,
    "horas_turno": 23.0,
    "peso_colada_gr": 2.0,
    "es_multipieza": false,
    "peso_neto_golpe_gr": 174.0,
    "peso_tiro_gr": 176.0,
    "cavidades_totales": 2,
    "composicion": [
      {
        "pieza_sku": "PIE-001",
        "pieza_nombre": "Balde Romano Cuerpo",
        "cavidades": 2,
        "peso_unit_gr": 87.0,
        "peso_subtotal_gr": 174.0
      }
    ]
  },
  "resumen_totales": {
    "Peso(Kg) PRODUCCION": 175.0,
    "Peso (Kg) Inc. Merma": 177.0,
    "%Merma": 0.0114,
    "Merma Natural Kg": 2.0,
    "Horas": 13.24,
    "Días": 0.58,
    "F. Fin": "2023-11-21T23:27:00",
    "Familia Color": "BALDE"
  },
  "avance_real_kg": 0.0,
  "avance_real_coladas": 0
}
```

## Relaciones
- **Hijos directos:** [[Lote_Color]] (1:N), [[Registro_Diario]] (1:N)
- **Snapshots:** [[Snapshot_Composicion_Molde]] (1:N)
- **FKs:** `ProductoTerminado`, `Molde`, `Maquina`
