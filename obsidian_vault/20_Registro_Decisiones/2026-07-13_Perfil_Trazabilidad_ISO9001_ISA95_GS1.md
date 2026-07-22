---
tipo: adr
estado: aceptada
fecha: 2026-07-13
tags: [arquitectura, scm, trazabilidad, iso-9001, isa-95, gs1, epcis]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
---

# ADR: Perfil de Trazabilidad ISO 9001 + ISA-95 + GS1

## Contexto

EnvaPerú fabrica productos plásticos por inyección y soplado. No pertenece a la cadena alimentaria, pero necesita demostrar procedencia, transformación, ubicación y destino de materiales y productos.

El sistema actual registra parte de la ejecución de producción y movimientos de bultos, pero todavía no mantiene una genealogía completa entre:

- recepción de materias primas y colorantes;
- lotes consumidos por producción;
- corridas y salidas `PiezaColor`;
- pesajes y unidades logísticas;
- reproceso;
- armado de `ProductoTerminado`;
- despacho, devolución e impacto.

No existe una única norma ISO que defina todos los modelos y eventos técnicos de un SCM industrial. Se necesita un perfil compuesto que separe gestión, arquitectura de operaciones y semántica de trazabilidad.

## Decisión

Se adopta el siguiente perfil para US-010 y sus historias hijas.

### 1. ISO 9001 como marco principal de gestión

ISO 9001 orientará:

- identificación y control de procesos;
- información documentada;
- responsabilidades y autorizaciones;
- control de salidas no conformes;
- seguimiento, medición, auditoría y mejora;
- conservación de evidencia objetiva.

Adoptar este marco no equivale a declarar certificación ni conformidad auditada.

### 2. ISA-95 / IEC 62264 como arquitectura y vocabulario operacional

ISA-95 orientará la separación e integración entre:

- definiciones de material y lotes físicos;
- personal, equipos y activos;
- solicitudes y respuestas de producción;
- ejecución de operaciones;
- sistemas de planta y sistemas de negocio.

El sistema puede implementar el vocabulario necesario de forma incremental; no se requiere desplegar un MES comercial ni todos los modelos de la norma.

### 3. GS1 Global Traceability Standard como semántica de tracking

El flujo se modelará mediante:

- **Critical Tracking Events (CTE):** recepción, liberación, movimiento, consumo, transformación, pesaje, agregación, despacho, devolución y corrección.
- **Key Data Elements (KDE):** qué, quién, dónde, cuándo y por qué, más cantidades, unidades, estado y relaciones entre objetos.
- trazabilidad hacia atrás y hacia adelante;
- relaciones de transformación y agregación;
- principio de conocer el origen inmediato y el destino inmediato cuando aplique.

### 4. EPCIS como referencia semántica, no como requisito inicial de interoperabilidad

La semántica de eventos internos debe ser compatible conceptualmente con los patrones de EPCIS, especialmente:

- observación de objetos;
- agregación y desagregación;
- transformación de entradas en salidas;
- asociación de objetos con ubicaciones y contexto de negocio.

La primera implementación no está obligada a:

- publicar una API EPCIS;
- usar JSON-LD EPCIS;
- operar un repositorio EPCIS certificado;
- intercambiar eventos con terceros.

Una futura integración podrá mapear eventos internos sin reconstruir la genealogía desde cero.

### 5. Identificación interna antes que identificación comercial externa

Cada lote, unidad logística y evento tendrá una identidad interna global, estable y no reutilizable. Los IDs numéricos de base de datos, si existen, serán detalles internos y no la identidad intercambiada entre módulos.

Los identificadores GS1, como GTIN, GLN o SSCC, solo se utilizarán cuando EnvaPerú disponga de los prefijos, reglas y asignaciones correspondientes. No se generarán identificadores aparentemente GS1 sin autorización.

### 6. Historial por eventos auditables

Los hechos confirmados no se reescriben destructivamente. Una corrección debe:

- identificar el evento corregido;
- registrar actor, momento y motivo;
- compensar o reemplazar de forma explícita su efecto;
- conservar la versión histórica consultable.

Las vistas de estado actual pueden derivarse o mantenerse como proyección, pero no sustituyen el historial.

### 7. Calidad y logística son dimensiones distintas

Un lote puede estar físicamente en una ubicación y, al mismo tiempo, estar pendiente, liberado, bloqueado o rechazado. El estado de calidad no se codificará como una ubicación ni se confundirá con consumido, despachado o agotado.

## Normas No Seleccionadas como Eje Principal

- **ISO 22005:** no se adopta porque está orientada a trazabilidad en cadenas alimentarias y de alimentación animal.
- **ISO 28000:** puede evaluarse en el futuro para seguridad y resiliencia de la cadena, pero no resuelve la genealogía productiva prioritaria.
- **ISO 14001:** puede complementar el control ambiental de merma y reciclaje, pero no sustituye el sistema de trazabilidad.

## Consecuencias Positivas

- Las historias hijas compartirán el mismo lenguaje e invariantes.
- La trazabilidad será bidireccional y no dependerá de textos descriptivos.
- Recepción, producción, pesaje, inventario y despacho podrán evolucionar por cortes verticales.
- Una integración futura con clientes o proveedores tendrá una ruta de mapeo conocida.
- Calidad, auditoría y simulación de retiro usarán evidencia común.

## Costos y Riesgos

- Se requieren identidades globales e idempotencia entre módulos online/offline.
- Deben normalizarse ubicaciones, actores y estados.
- El modelo de eventos no elimina la necesidad de proyecciones eficientes para inventario y operación diaria.
- Una compatibilidad conceptual mal documentada podría confundirse con conformidad EPCIS; las interfaces deben declarar claramente su alcance.
- La certificación ISO 9001 requiere implantación organizacional y auditoría, no solamente software.

## Reglas para las Tech Specs

Cada Tech Spec hija de US-010 debe indicar:

1. Qué CTE incorpora.
2. Cuáles son sus KDE obligatorios.
3. Qué objetos de trazabilidad consume, produce, agrega o mueve.
4. Cómo evita duplicados y conserva correcciones.
5. Cómo participa en consultas hacia atrás y adelante.
6. Qué pruebas demuestran transacción, permisos, idempotencia y genealogía.

## Fuentes Oficiales

- [ISO 9001:2015](https://www.iso.org/standard/62085.html).
- [ISA-95 / IEC 62264](https://www.isa.org/standards-and-publications/isa-standards/isa-95-standard).
- [GS1 Global Traceability Standard](https://www.gs1.org/standards/gs1-global-traceability-standard/current-standard).
- [GS1 EPCIS 2.0.1](https://ref.gs1.org/standards/epcis/2.0.1/).
- [GS1 EPCIS TransformationEvent](https://ref.gs1.org/epcis/TransformationEvent).

