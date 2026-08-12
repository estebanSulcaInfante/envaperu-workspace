---
tipo: meta
estado: activo
tags: [arquitectura, sistema, overview]
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-07-29
---

# Arquitectura Global — EnvaPeru SCM

## Descripción del Sistema
Sistema de gestión de cadena de suministro (Supply Chain Management) para la empresa EnvaPeru, especializada en manufactura por inyección de plásticos.

## Módulos Principales

### 1. Backend (Core)
- **Stack:** Python (Flask/FastAPI) + PostgreSQL
- **Responsabilidad:** Lógica de negocio, cálculos de producción, API REST
- **Entidades principales:** [[Orden_Produccion]], [[Orden_Fabricacion]], [[Orden_Armado]], [[Registro_Diario]], [[Unidad_Logistica]]

### 2. Frontend
- **Responsabilidad:** Interfaz de usuario para planificación, seguimiento y reportes
- **Vistas clave:** Órdenes de producción, registro diario, control de peso

### 3. Módulo de Pesaje
- **Responsabilidad:** Integración con balanzas físicas, captura de pesos en tiempo real
- **Relación:** Alimenta los datos de [[Control_Peso]] como doble verificación

## Flujo General de Datos

```mermaid
graph LR
    A["Planificación"] --> B["Orden de Producción (demanda PT)"]
    B --> C["Asignaciones N:M"]
    C --> D["Orden de Fabricación"]
    C --> E["Orden de Armado"]
    D --> F["Corridas por color"]
    F --> G["Orden de Trabajo diaria"]
    G --> H["Mangas y pesajes"]
    E --> H
    H --> I["Recepción de almacén"]
```

## Convenciones Generales
- Los cálculos se persisten en BD y se actualizan via `actualizar_metricas()`
- Snapshots se congelan al crear entidades hijas para consistencia histórica
- Unidades: gramos (g) para pesos unitarios, kilogramos (kg) para totales
- Los pesos conservan precisión decimal; los ciclos/coladas liberados son enteros
- OP expresa demanda; OF/OA expresan ejecución; OT despacha trabajo diario
- Las relaciones de cobertura entre demanda y suministro son N:M cuantificadas
