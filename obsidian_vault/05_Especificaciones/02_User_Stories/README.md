---
tipo: especificacion
subtipo: user_stories
estado: activo
tags: [pipeline, user-stories, comportamiento, negocio]
fecha_creacion: 2026-06-08
fecha_actualizacion: 2026-08-11
---

# 02_User_Stories (Historias de Usuario Enriquecidas)

Este directorio contiene las **historias de usuario** formales que describen el comportamiento y las necesidades de negocio del sistema desde la perspectiva del usuario.

## Propósito
Transformar los requerimientos crudos de [[01_Drafts/README|01_Drafts]] en piezas de valor de software estructuradas, comprensibles para el negocio y con criterios de aceptación claros y verificables.

## Estructura Recomendada para las Notas
Cada historia de usuario debe seguir un formato claro:

```markdown
# US-XX: [Nombre descriptivo]

## Descripción
**Como** [Rol del usuario]
**Quiero** [Realizar una acción]
**Para** [Obtener un beneficio o valor de negocio]

## Criterios de Aceptación
1. **Escenario: [Caso de prueba principal]**
   - **Dado** [Contexto/Estado inicial]
   - **Cuando** [Acción que realiza el usuario]
   - **Entonces** [Resultado esperado]

2. **Escenario: [Caso de prueba alternativo/error]**
   - **Dado** [Contexto]
   - **Cuando** [Acción]
   - **Entonces** [Validación de error o comportamiento alternativo]
```

Además debe declarar:

- alcance y fuera de alcance;
- invariantes de negocio;
- dataset de ejemplo reproducible;
- errores, reintentos, permisos y correcciones relevantes;
- relación de cada escenario con el resultado de negocio;
- Definición de Preparada antes de pasar a Tech Spec.

## Tratamiento de Épicas

Una nota con `subtipo: epic` organiza una capacidad amplia, pero no se implementa directamente ni genera una única Tech Spec.

Antes de avanzar:

1. Construir una secuencia de historias hijas verticales.
2. Hacer que cada hija entregue un resultado observable y consultable.
3. Introducir infraestructura transversal dentro del primer flujo que la necesite.
4. Escribir ejemplos ATDD/BDD con datos concretos.
5. Validar las reglas con los responsables del proceso.

Una capa técnica aislada, como “crear tablas base” o “añadir IDs”, no es por sí sola una historia de usuario. Puede formar parte de una historia vertical y quedar detallada después en su Tech Spec.

## Definición de Preparada

Una historia puede pasar a Tech Spec cuando:

- el actor, objetivo y resultado son inequívocos;
- sus dependencias y límites están definidos;
- los términos e invariantes de negocio fueron validados;
- existe al menos un ejemplo principal con datos realistas;
- se cubren errores y comportamientos alternativos relevantes;
- los criterios son observables y automatizables;
- las preguntas pendientes son técnicas, no decisiones operativas ocultas;
- existe una línea base reproducible de pruebas.

## Continuidad con TDD

Los escenarios de la US son la entrada para TDD, no pruebas técnicas anticipadas. La Tech Spec posterior debe mapearlos a pruebas unitarias, integración, contrato, UI o E2E. Durante el desarrollo se implementa un escenario por vez mediante `RED -> GREEN -> REFACTOR`, comenzando desde una línea base verde.

## Próximo Paso en el Pipeline
Una vez que una historia no épica cumple su Definición de Preparada, se procede a diseñar exclusivamente sus contratos y arquitectura en [[03_Tech_Specs/README|03_Tech_Specs]].

## Familia activa US-010

| Historia | Resultado | Estado de pipeline |
|---|---|---|
| [[US-010R_Rutas_BOM_Multinivel_WIP_y_Perfiles_Empaque|US-010R]] | Artículos, BOM multinivel, rutas, WIP y reglas de empaque | Implementada local; pendiente UAT con referencias reales |
| [[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP|US-010P]] | OP de demanda, cobertura N:M y propuestas OF/OA | Implementada local; pendiente UAT integral |
| [[US-010A_Recepcion_Trazable_Materiales|US-010A]] | Recepción ordinaria de compras de materiales | En desarrollo; diferida fuera del nuevo piloto |
| [[US-010B_Reserva_Emision_Materiales_OP|US-010B]] | Reserva, emisión y premezcla desde OF | Desarrollo pendiente; frontend actual es mock |
| [[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas|US-010C]] | Plan de mangas desde OF/corrida, asignación OT y etiqueta previa | Implementada local; pendiente UAT física de impresión |
| [[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]] | Pesaje conectado y etiqueta final; termina pendiente de recepción, sin Kardex | Implementada local; pendiente UAT con balanza e impresora |
| [[US-010E_Molienda_y_Material_Recuperado_Trazable|US-010E]] | Molienda trazable, compatibilidad, dilución controlada y material recuperado | Implementada local; registro de merma incluido y molienda completa en segundo recorrido opcional |
| [[US-010F_Prearmado_y_Armado_Concurrente_Trazable|US-010F]] | Ejecución intermedia/final; Armado confirma cantidad y genealogía antes del pesaje obligatorio | Implementada local; pendiente UAT física y reglas de planta |
| [[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex|US-010I]] | Escaneo de ingreso, movimiento inicial, ubicación y decisión posterior de Calidad | Implementada local; pendiente UAT y criterios concretos de Calidad |
| [[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas|US-010H]] | Picking QR, custodia, consumo parcial y devolución de mangas hacia una OT de Armado | Implementada local; pendiente UAT de custodia y retorno |
| [[US-010J_Alertas_Operativas_e_Inconsistencias|US-010J]] | Bandeja configurable de alertas temporales y correcciones sensibles para jefaturas | Implementada local; pendiente UAT de jefaturas |
| [[US-010M_OT_de_Maquina_y_Trabajo_de_Color|US-010M]] | Épica: OT por máquina/turno con Trabajo de color como ejecución atómica | Refinada y dividida; no se implementa directamente |
| [[US-010M1_OT_Maquina_y_Cola_Trabajos_Color|US-010M1]] | Cabecera OT, cola de Trabajos de color, estados, exclusividad y migración | Aprobada para desarrollo mediante TS/DEV-010M1 |
| [[US-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color|US-010M2]] | Manga, QR, cupo, pesaje, recepción y anulación por Trabajo de color | Aprobada para desarrollo mediante TS/DEV-010M2 |
| [[US-010M3_Relevos_en_Trabajo_Color|US-010M3]] | Relevos y asignación de subconjuntos de mangas dentro de la misma OT | Aprobada para desarrollo mediante TS/DEV-010M3 |
| [[US-010N_Navegacion_SCM_y_Workspace_por_Capacidades|US-010N]] | Épica: arquitectura de información e Inicio derivados de capacidades | Refinada y dividida; no se implementa directamente |
| [[US-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada|US-010N1]] | Navegación por áreas, madurez, responsive y maestros centralizados | Refinada; Tech Spec aprobada para desarrollo |
| [[US-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades|US-010N2]] | Inicio automático por capacidades, rol principal y preferencias gobernadas | Desplegada; UAT por roles en ejecución |
| [[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes|US-010N3]] | Fechas OF/OA proyectadas y Jornadas de Planta para Fabricación/Armado | Implementada localmente; smoke y UAT humana pendientes |
| [[US-010N4_Supervision_de_Produccion_Read_Model_Operativo|US-010N4]] | Supervisión de Fabricación y Armado mediante lista, detalle y resumen de solo lectura | Implementada localmente; suites automáticas verdes; smoke visual y UAT humana pendientes |
| [[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color|US-010K]] | Controles acumulativos de mangas abiertas, cierre explícito y meta por corrida/color | En refinamiento; requiere validación operativa y sustituir parcialmente la regla de pesaje único |
| [[US-010L_Material_Segunda_Reproceso_y_Mezcla_Preparada_Trazable|US-010L]] | Segunda coloreada, R1…Rn, dosificación medida, mezcla experimental y material preparado almacenable | En refinamiento; falta validar balanzas, tolerancias, incorporación y Calidad |
| US-010G | Despacho, devolución comercial y explorador genealógico | Diferida fuera del nuevo piloto |

La secuencia del piloto pasa a
`R -> P(OP/OF/OA) -> B -> M1 -> M2 -> M3 -> D/I`, conservando C/D como
contratos funcionales que M adapta al nuevo agregado. M1–M3 son puerta previa
a retomar la UAT física de OT, mangas y pesaje. La secuencia anterior era
`R -> P(OP/OF/OA) -> B -> C -> D-core -> I`,
con `H -> F` para abastecer y transformar piezas/WIP ya inventariados. El WIP
acreditado en línea sigue el contrato directo de F y no simula un despacho de
Almacén. Para el nuevo piloto, US-010A se sustituye únicamente como fuente
inicial por un corte auditado de `APERTURA_INICIAL`; esto no convierte la
apertura en recepción ni permite usarla para compras posteriores. El alcance y
sus gates se registran en
[[2026-08-03_Alcance_Piloto_Apertura_Inicial_sin_Recepcion_Compras]] y
[[Alcance_Nuevo_Piloto_SCM_2026-08]].

US-010K es una extensión propuesta entre D e I. Mientras permanezca en
refinamiento, D-core conserva la regla productiva de un único pesaje final por
manga cerrada; los controles de mangas abiertas no están habilitados todavía.
US-010M3 no cruza OT, turno ni fecha: la continuidad multi-jornada y
`TramoMangaTrabajoColor` siguen perteneciendo exclusivamente a K.

US-010L extiende A/B/E, pero queda fuera de US-010M y del piloto. La premezcla
local de B continúa ligada a una corrida y a una receta aprobada; no debe
presentarse como soporte de mezcla experimental ni como inventario reusable de
material preparado. M2 solo puede añadir la referencia del consumo ordinario
al Trabajo de color.

## Familia US-012 — Alta guiada integral de PT

| Historia | Resultado | Estado de pipeline |
|---|---|---|
| [[US-012_Alta_Guiada_Integral_de_ProductoTerminado|US-012]] | Épica de seis fases para carga inicial de un PT | Refinada y dividida; no se implementa directamente |
| [[US-012A_Sesion_Reanudable_e_Identidad_de_Producto|US-012A]] | Sesión durable, duplicados, PT y clasificación comercial | Preparada; TS-017A en revisión |
| [[US-012B_Configuracion_Fisica_Color_y_Formulacion|US-012B]] | Molde, piezas, variantes, formulaciones, imágenes y UX premium mínima | Preparada; TS-017B en revisión |
| [[US-012C_Ingenieria_Readiness_y_Publicacion|US-012C]] | BOM/WIP, ruta, empaque, readiness y publicación | Preparada; TS-017C en revisión |

## Familia US-013 — Kardex multi-almacén y operaciones QR

| Historia | Resultado | Estado de pipeline |
|---|---|---|
| [[US-013_Kardex_MultiAlmacen_Custodia_y_Operaciones_QR|US-013]] | Épica de almacenes, custodia, transferencias y vistas especializadas | Aprobada y dividida; no se implementa directamente |
| [[US-013A_Almacenes_Ubicaciones_y_Alcance_por_Trabajador|US-013A]] | Almacenes/ubicaciones y scope autoritativo por trabajador | Aprobada mediante TS/DEV-018A |
| [[US-013B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias|US-013B]] | Sesión multi-QR, picking, pickup, tránsito, recepción y retorno | Aprobada mediante TS/DEV-018B; depende de A |
| [[US-013C_Vistas_Especializadas_y_Control_de_Kardex|US-013C]] | Vistas MP, Piezas/WIP, PT y Control sobre un ledger único | Aprobada mediante TS/DEV-018C; depende de A/B |
