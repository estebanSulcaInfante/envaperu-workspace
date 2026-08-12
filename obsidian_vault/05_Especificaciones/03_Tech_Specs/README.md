---
tipo: especificacion
subtipo: tech_specs
estado: activo
tags: [pipeline, tech-specs, api, base-datos, ui]
fecha_creacion: 2026-06-08
fecha_actualizacion: 2026-08-11
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
| [[TS-010B_Reserva_Emision_y_Premezcla_Materiales|TS-010B]] | [[../02_User_Stories/US-010B_Reserva_Emision_Materiales_OP|US-010B]] | Implementada local; pendiente UAT operativa |
| [[TS-010P_OP_Demanda_OF_OA_y_Migracion_Documental|TS-010P]] | [[../02_User_Stories/US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP|US-010P]] | En refinamiento; separa OP de OF/OA y define migración |
| [[TS-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje|TS-010C]] | [[../02_User_Stories/US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]] | Implementada local; guía adaptada y lista para UAT física |
| [[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final|TS-010D]] | [[../02_User_Stories/US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]] | En refinamiento |
| [[TS-010F_Armado_Genealogia_Mangas_PT_y_Cierre_Armado|TS-010F]] | [[../02_User_Stories/US-010F_Prearmado_y_Armado_Concurrente_Trazable|US-010F]] | En refinamiento; cierre de Armado separado de pesaje |
| [[TS-010E_Molienda_Merma_y_Material_Recuperado|TS-010E]] | [[../02_User_Stories/US-010E_Molienda_y_Material_Recuperado_Trazable|US-010E]] | Implementada local; pendiente UAT |
| [[TS-010J_Alertas_Operativas_Configurable|TS-010J]] | [[../02_User_Stories/US-010J_Alertas_Operativas_e_Inconsistencias|US-010J]] | Implementada local; pendiente UAT |
| [[TS-010I_Recepcion_Mangas_y_Nacimiento_Kardex|TS-010I]] | [[../02_User_Stories/US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex|US-010I]] | Implementada local; guía lista para UAT de recepción, Calidad y reversa |
| [[TS-010H_Abastecimiento_Interno_Picking_QR_y_Retorno|TS-010H]] | [[../02_User_Stories/US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas|US-010H]] | Aprobada para desarrollo local; pendiente UAT operativa |
| [[TS-010R_Articulos_BOM_Rutas_WIP_y_Perfiles_Empaque|TS-010R]] | [[../02_User_Stories/US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque|US-010R]] | En refinamiento |
| [[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color|TS-010M1]] | [[../02_User_Stories/US-010M1_OT_Maquina_y_Cola_Trabajos_Color|US-010M1]] | Aprobada para desarrollo; primera hija del refactor OT |
| [[TS-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color|TS-010M2]] | [[../02_User_Stories/US-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color|US-010M2]] | Aprobada para desarrollo; depende de M1 |
| [[TS-010M3_Relevos_en_Trabajo_Color|TS-010M3]] | [[../02_User_Stories/US-010M3_Relevos_en_Trabajo_Color|US-010M3]] | Aprobada para desarrollo; relevo dentro de OT únicamente |
| [[TS-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada|TS-010N1]] | [[../02_User_Stories/US-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada|US-010N1]] | Aprobada para desarrollo; no cambia rutas ni endpoints de dominio |
| [[TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades|TS-010N2]] | [[../02_User_Stories/US-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades|US-010N2]] | Desplegada; UAT por roles en ejecución |
| [[TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas|TS-010N3]] | [[../02_User_Stories/US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes|US-010N3]] | Implementada localmente; smoke y UAT humana pendientes |
| [[TS-010N4_Supervision_de_Produccion|TS-010N4]] | [[../02_User_Stories/US-010N4_Supervision_de_Produccion_Read_Model_Operativo|US-010N4]] | Implementada localmente; backend/frontend completos verdes; smoke visual y UAT humana pendientes |
| [[TS-016_Maestro_Colores_y_Recetas|TS-016]] | [[../02_User_Stories/US-006_Normalizar_Composicion_Color_Familia|US-006]] | Implementada parcialmente |
| [[TS-017A_Sesion_Durable_y_Shell_de_Alta_Guiada|TS-017A]] | [[../02_User_Stories/US-012A_Sesion_Reanudable_e_Identidad_de_Producto|US-012A]] | En revisión; sesión durable y fases 1–2 |
| [[TS-017B_Configuracion_Fisica_Formulaciones_y_UX_Premium|TS-017B]] | [[../02_User_Stories/US-012B_Configuracion_Fisica_Color_y_Formulacion|US-012B]] | En revisión; fase 3 y UX premium mínima |
| [[TS-017C_Ingenieria_Readiness_y_Publicacion_Guiada|TS-017C]] | [[../02_User_Stories/US-012C_Ingenieria_Readiness_y_Publicacion|US-012C]] | En revisión; fases 4–6 |
| [[TS-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos|TS-018A]] | [[../02_User_Stories/US-013A_Almacenes_Ubicaciones_y_Alcance_por_Trabajador|US-013A]] | Aprobada para desarrollo local; ejecutar primero |
| [[TS-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias|TS-018B]] | [[../02_User_Stories/US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias|US-013B]] | Aprobada; depende de 018A verde |
| [[TS-018C_Vistas_Especializadas_y_Control_de_Kardex|TS-018C]] | [[../02_User_Stories/US-013C_Vistas_Especializadas_y_Control_de_Kardex|US-013C]] | Aprobada; depende de 018A/018B verdes |

## Tech Specs Correctivas Transversales

Baseline de ingreso para N1/N2: [[Baseline_TS-010N_2026-08-08]].

| Tech Spec | Alcance | Estado |
|---|---|---|
| [[TS-012_Normalizacion_Relacion_Molde_Pieza_NM|TS-012]] | Catálogo `Pieza`, composición `MoldePieza`, variantes `PiezaColor` y snapshots de OP | Aprobada para desarrollo |
| [[TS-013_Codigos_Correlativos_Automaticos_Catalogo|TS-013]] | Códigos automáticos `PZ`, `PC`, `PT` y `ML`, migración conservadora y concurrencia | Aprobada para desarrollo |
| [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD|TS-014]] | Relación `Linea <-> Familia` N:M, CRUD lógico/versionado, filtros y validación de pares | Aprobada para desarrollo |

| [[TS-015_Asistente_Catalogo_Altas_En_Contexto_y_OP_Excepcional|TS-015]] | Altas en contexto, fachada guiada transitoria e integridad de OF excepcional | Sustituida por TS-017 sólo en su experiencia de wizard integral |

## Tech Specs de Enablers

| Tech Spec | Enabler | Estado |
|---|---|---|
| [[TS-TE-003_Contratos_Central_Pesaje_y_E2E_Aislado|TS-TE-003]] | [[../02_Technical_Enablers/TE-003_Contratos_Central_Pesaje_y_E2E_Aislado|TE-003]] | Implementado |
| [[TS-TE-004_Despliegue_y_Comunicacion_Estacion_Pesaje|TS-TE-004]] | [[../02_Technical_Enablers/TE-004_Despliegue_Operativo_y_Observabilidad_Estacion_Pesaje|TE-004]] | En refinamiento |

## Próximo Paso en el Pipeline
Cuando el diseño técnico y su estrategia de pruebas estén validados, la especificación se aprueba en [[04_Approved_for_Dev/README|04_Approved_for_Dev]]. El desarrollo comienza comprobando la línea base y creando la primera prueba `RED`, no implementando primero el modelo completo.
