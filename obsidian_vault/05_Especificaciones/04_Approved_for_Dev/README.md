---
tipo: especificacion
subtipo: approved_for_dev
estado: activo
tags: [pipeline, approved, ai-agent, desarrollo, codigo]
fecha_creacion: 2026-06-08
fecha_actualizacion: 2026-08-10
---

# 04_Approved_for_Dev (Aprobado para Desarrollo)

Este directorio contiene las **especificaciones finales consolidadas y aprobadas** para que el agente de IA (u otros desarrolladores) genere e implemente el código sin ambigüedades.

## Especificaciones Aprobadas

| Desarrollo | Historia | Tech Spec | Estado |
|---|---|---|---|
| [[DEV-010A_Recepcion_Trazable_Materiales|DEV-010A]] | [[../02_User_Stories/US-010A_Recepcion_Trazable_Materiales|US-010A]] | [[../03_Tech_Specs/TS-010A_Recepcion_Trazable_Materiales|TS-010A]] | En desarrollo; primer incremento de dominio GREEN |
| Implementación directa US-010B | [[../02_User_Stories/US-010B_Reserva_Emision_Materiales_OP|US-010B]] | [[../03_Tech_Specs/TS-010B_Reserva_Emision_y_Premezcla_Materiales|TS-010B]] | Implementada local; pendiente UAT operativa |
| [[DEV-010R_R-Core_Articulos_BOM_Rutas_y_Empaque|DEV-010R]] | [[../02_User_Stories/US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque|US-010R]] | [[../03_Tech_Specs/TS-010R_Articulos_BOM_Rutas_WIP_y_Perfiles_Empaque|TS-010R]] | R-core aprobado; incremento R1 en desarrollo |
| [[DEV-010P_OP_Demanda_OF_OA_y_Migracion_Documental|DEV-010P]] | [[../02_User_Stories/US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP|US-010P]] | [[../03_Tech_Specs/TS-010P_OP_Demanda_OF_OA_y_Migracion_Documental|TS-010P]] | Desarrollo local autorizado |
| [[DEV-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje|DEV-010C]] | [[../02_User_Stories/US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]] | [[../03_Tech_Specs/TS-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje|TS-010C]] | Implementado local; pendiente UAT física y primera OP normalizada |
| [[DEV-010M1_OT_Maquina_y_Cola_Trabajos_Color|DEV-010M1]] | [[../02_User_Stories/US-010M1_OT_Maquina_y_Cola_Trabajos_Color|US-010M1]] | [[../03_Tech_Specs/TS-010M1_OT_Maquina_y_Cola_Trabajos_Color|TS-010M1]] | Aprobado; ejecutar primero |
| [[DEV-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color|DEV-010M2]] | [[../02_User_Stories/US-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color|US-010M2]] | [[../03_Tech_Specs/TS-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color|TS-010M2]] | Aprobado; depende de M1 verde |
| [[DEV-010M3_Relevos_en_Trabajo_Color|DEV-010M3]] | [[../02_User_Stories/US-010M3_Relevos_en_Trabajo_Color|US-010M3]] | [[../03_Tech_Specs/TS-010M3_Relevos_en_Trabajo_Color|TS-010M3]] | Aprobado; depende de M1/M2 verdes |
| [[DEV-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada|DEV-010N1]] | [[../02_User_Stories/US-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada|US-010N1]] | [[../03_Tech_Specs/TS-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada|TS-010N1]] | Desplegado en Render; UAT visual en ejecución |
| [[DEV-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades|DEV-010N2]] | [[../02_User_Stories/US-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades|US-010N2]] | [[../03_Tech_Specs/TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades|TS-010N2]] | Desplegado; UAT por roles en ejecución |
| [[DEV-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas|DEV-010N3]] | [[../02_User_Stories/US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes|US-010N3]] | [[../03_Tech_Specs/TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas|TS-010N3]] | Implementado localmente; smoke y UAT humana pendientes |
| [[DEV-010N4_Supervision_de_Produccion|DEV-010N4]] | [[../02_User_Stories/US-010N4_Supervision_de_Produccion_Read_Model_Operativo|US-010N4]] | [[../03_Tech_Specs/TS-010N4_Supervision_de_Produccion|TS-010N4]] | Implementado localmente; suites/lint/build verdes; smoke visual y UAT humana pendientes |
| [[DEV-017_Alta_Guiada_Integral_PT|DEV-017]] | [[../02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado|US-012]] | [[../03_Tech_Specs/TS-017A_Sesion_Durable_y_Shell_de_Alta_Guiada|TS-017A/B/C]] | Implementado localmente; 408 backend y 362 frontend verdes; migraciones/despliegue/UAT pendientes |
| [[DEV-010H_Abastecimiento_Interno_Picking_QR|DEV-010H]] | [[../02_User_Stories/US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas|US-010H]] | [[../03_Tech_Specs/TS-010H_Abastecimiento_Interno_Picking_QR_y_Retorno|TS-010H]] | Desarrollo local autorizado; pendiente UAT operativa |
| [[DEV-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos|DEV-018A]] | [[../02_User_Stories/US-013A_Almacenes_Ubicaciones_y_Alcance_por_Trabajador|US-013A]] | [[../03_Tech_Specs/TS-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos|TS-018A]] | Desarrollo local autorizado; ejecutar primero |
| [[DEV-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias|DEV-018B]] | [[../02_User_Stories/US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias|US-013B]] | [[../03_Tech_Specs/TS-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias|TS-018B]] | Autorizado después de 018A verde |
| [[DEV-018C_Vistas_Especializadas_y_Control_de_Kardex|DEV-018C]] | [[../02_User_Stories/US-013C_Vistas_Especializadas_y_Control_de_Kardex|US-013C]] | [[../03_Tech_Specs/TS-018C_Vistas_Especializadas_y_Control_de_Kardex|TS-018C]] | Autorizado después de 018A/018B verdes |
| [[DEV-010F1_Cierre_Exacto_Armado|DEV-010F1]] | [[../02_User_Stories/US-010F_Prearmado_y_Armado_Concurrente_Trazable|US-010F]] | [[../03_Tech_Specs/TS-010F_Armado_Genealogia_Mangas_PT_y_Cierre_Armado|TS-010F]] | Cierre exacto implementado local; pendiente UAT y modalidades candidata/legacy |
| [[DEV-PILOTO_Apertura_Inicial_Controlada|DEV-PILOTO Apertura]] | [[../../20_Registro_Decisiones/2026-08-03_Alcance_Piloto_Apertura_Inicial_sin_Recepcion_Compras|Decisión de alcance]] | [[../../10_Flujos_y_Procesos/Alcance_Nuevo_Piloto_SCM_2026-08|Alcance piloto]] | Implementado local; pendiente UAT de corte físico |

## Correcciones Transversales Aprobadas

| Tech Spec | Alcance | Estado |
|---|---|---|
| [[../03_Tech_Specs/TS-012_Normalizacion_Relacion_Molde_Pieza_NM|TS-012]] | Normalizar `Molde <-> Pieza` como N:M y preservar snapshots de OP | Aprobada para desarrollo |
| [[../03_Tech_Specs/TS-013_Codigos_Correlativos_Automaticos_Catalogo|TS-013]] | Autogenerar códigos correlativos e inmutables `PZ`, `PC`, `PT` y `ML` | Aprobada para desarrollo |
| [[../03_Tech_Specs/TS-014_Normalizacion_Linea_Familia_NM_y_CRUD|TS-014]] | Normalizar `Linea <-> Familia` como N:M e incorporar CRUD lógico/versionado | Aprobada para desarrollo |

| [[../03_Tech_Specs/TS-015_Asistente_Catalogo_Altas_En_Contexto_y_OP_Excepcional|TS-015]] | Reubicar y actualizar el wizard, permitir altas en contexto y proteger la OP excepcional | En desarrollo autorizado |

## Propósito
Servir como la única fuente de verdad y conjunto de instrucciones directas para la fase de programación, garantizando que el agente de IA tenga todo el contexto del negocio, los contratos de API y los requerimientos visuales en un solo lugar.

## Estructura Recomendada de una Especificación Aprobada
Una nota de especificación para desarrollo debe incluir:

```markdown
# DEV-XX: [Nombre del Requerimiento]

## Referencias
- **Historia de Usuario:** [[02_User_Stories/US-XX|US-XX]]
- **Especificaciones Técnicas:** [[03_Tech_Specs/TS-XX|TS-XX]]

## Alcance de la Implementación
Lista precisa de los componentes a modificar:
- [ ] Backend: Modelos y/o Endpoints.
- [ ] Frontend: Vistas y/o Componentes.
- [ ] Módulo de Pesaje: Controladores o Integraciones.

## Instrucciones Paso a Paso
1. **BASELINE:** Ejecutar la regresión y registrar fallos previos.
2. **RED:** Implementar la prueba del primer escenario y comprobar el fallo esperado.
3. **GREEN:** Añadir el mínimo código para hacerla pasar.
4. **REFACTOR:** Mejorar el diseño manteniendo la suite verde.
5. Repetir el ciclo para el siguiente escenario.

## Criterios de Aceptación a Validar
- [ ] El flujo principal funciona según los escenarios definidos.
- [ ] Las validaciones de base de datos e interfaz de usuario están implementadas y activas.
- [ ] Los tests automatizados (unitarios y de integración) corren exitosamente.
- [ ] Cada escenario de la US tiene evidencia en el nivel de prueba acordado.
- [ ] Idempotencia, concurrencia o transacciones críticas se probaron con infraestructura representativa.
```

## Flujo de Trabajo
Una vez que el agente de IA finaliza la tarea, debe marcarla como completada y actualizar la bitácora o los modelos en la bóveda si hubo algún cambio de último minuto aprobado durante el desarrollo.
