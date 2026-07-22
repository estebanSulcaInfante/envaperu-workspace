---
tipo: especificacion
subtipo: tech_specs
estado: activo
tags: [pipeline, tech-specs, api, base-datos, ui]
fecha_creacion: 2026-06-08
---

# 03_Tech_Specs (Especificaciones Técnicas)

Este directorio contiene las **especificaciones técnicas y decisiones de diseño e infraestructura** para implementar las historias de usuario.

## Propósito
Definir con precisión técnica cómo se construirá el requerimiento, minimizando la incertidumbre técnica antes de comenzar el desarrollo de código.

## Áreas de Definición

### 1. Esquema de Base de Datos
- Cambios en las tablas existentes o creación de nuevas tablas.
- Tipos de datos, llaves primarias/foráneas y restricciones (Constraints).
- Puedes basarte en las plantillas ubicadas en [[99_Plantillas/TPL_Modelo_BD|TPL_Modelo_BD]].

### 2. Contratos de API
- Definición de endpoints (`GET`, `POST`, `PUT`, `DELETE`).
- Estructura de payloads JSON (Request/Response) y códigos de estado HTTP.
- Puedes basarte en las plantillas ubicadas en [[99_Plantillas/TPL_Endpoint_API|TPL_Endpoint_API]].

### 3. Componentes de UI e Interfaces
- Mockups, diagramas de flujo de vistas y requerimientos visuales.
- Especificación de estados de los componentes (Cargando, Vacío, Error, Éxito).
- Puedes basarte en las plantillas ubicadas en [[99_Plantillas/TPL_Componente_UI|TPL_Componente_UI]].

### 4. Estrategia de Pruebas

Toda Tech Spec debe:

- referenciar una historia no épica que cumpla su Definición de Preparada o un Technical Enabler con impacto arquitectónico;
- mapear cada escenario de aceptación por ID a pruebas unitarias, integración, contrato, UI o E2E;
- definir fixtures y datos canónicos sin ocultar reglas mediante mocks;
- identificar qué garantías requieren infraestructura real, como PostgreSQL, concurrencia o sincronización offline;
- declarar el comando de línea base y los fallos preexistentes aceptados;
- indicar cuál será la primera prueba `RED` y por qué debe fallar antes de implementar;
- evitar una prueba E2E para cada variante ya cubierta en niveles más rápidos.

Una Tech Spec no debe agrupar una épica completa. Cada historia hija produce su propia TS y puede compartir ADRs o contratos transversales.

## Tech Specs de Historias

| Tech Spec | Historia | Estado |
|---|---|---|
| [[TS-010A_Recepcion_Trazable_Materiales|TS-010A]] | [[../02_User_Stories/US-010A_Recepcion_Trazable_Materiales|US-010A]] | Aprobada para desarrollo |
| [[TS-016_Maestro_Colores_y_Recetas|TS-016]] | [[../02_User_Stories/US-006_Normalizar_Composicion_Color_Familia|US-006]] | Implementada parcialmente |

## Tech Specs Correctivas Transversales

| Tech Spec | Alcance | Estado |
|---|---|---|
| [[TS-012_Normalizacion_Relacion_Molde_Pieza_NM|TS-012]] | Catálogo `Pieza`, composición `MoldePieza`, variantes `PiezaColor` y snapshots de OP | Aprobada para desarrollo |
| [[TS-013_Codigos_Correlativos_Automaticos_Catalogo|TS-013]] | Códigos automáticos `PZ`, `PC`, `PT` y `ML`, migración conservadora y concurrencia | Aprobada para desarrollo |
| [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD|TS-014]] | Relación `Linea <-> Familia` N:M, CRUD lógico/versionado, filtros y validación de pares | Aprobada para desarrollo |

| [[TS-015_Asistente_Catalogo_Altas_En_Contexto_y_OP_Excepcional|TS-015]] | Configuración guiada, altas de catálogo dentro de selectores e integridad de OP excepcional | En desarrollo |

## Tech Specs de Enablers

| Tech Spec | Enabler | Estado |
|---|---|---|
| [[TS-TE-003_Contratos_Central_Pesaje_y_E2E_Aislado|TS-TE-003]] | [[../02_Technical_Enablers/TE-003_Contratos_Central_Pesaje_y_E2E_Aislado|TE-003]] | Implementado |
| [[TS-TE-004_Despliegue_y_Comunicacion_Estacion_Pesaje|TS-TE-004]] | [[../02_Technical_Enablers/TE-004_Despliegue_Operativo_y_Observabilidad_Estacion_Pesaje|TE-004]] | En refinamiento |

## Próximo Paso en el Pipeline
Cuando el diseño técnico y su estrategia de pruebas estén validados, la especificación se aprueba en [[04_Approved_for_Dev/README|04_Approved_for_Dev]]. El desarrollo comienza comprobando la línea base y creando la primera prueba `RED`, no implementando primero el modelo completo.
