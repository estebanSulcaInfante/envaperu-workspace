---
tipo: user_story
subtipo: epic
id: US-012
titulo: "Alta guiada integral de ProductoTerminado"
estado: implementada-local-pendiente-uat
tags: [catalogo, producto-terminado, wizard, carga-inicial, epic]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
actores: [GESTOR_MAESTROS, INGENIERIA_SCM, JEFE_PRODUCCION, GERENTE_GENERAL]
relaciones:
  - "[[US-012A_Sesion_Reanudable_e_Identidad_de_Producto]]"
  - "[[US-012B_Configuracion_Fisica_Color_y_Formulacion]]"
  - "[[US-012C_Ingenieria_Readiness_y_Publicacion]]"
  - "[[../../../20_Registro_Decisiones/2026-08-10_Autoridad_de_Clasificacion_Comercial_en_ProductoTerminado]]"
  - "[[../../../20_Registro_Decisiones/2026-08-10_Sesion_Durable_y_Aplicacion_Incremental_en_Alta_Guiada_PT]]"
---

# US-012: Alta guiada integral de ProductoTerminado

## Descripción

**Como** trabajador experimentado responsable de la carga inicial de maestros  
**Quiero** completar en una sola vista guiada todas las dependencias de un ProductoTerminado  
**Para** transformar información dispersa y parcialmente denormalizada en un producto trazable y listo para planificación, sin perder el avance ni crear duplicados.

## Resultado de negocio

La interfaz reemplaza a Configuración guiada como entrada principal para **altas nuevas**. Los CRUD individuales continúan disponibles para mantenimiento especializado. El resultado final no es “se guardó un formulario”, sino una matriz verificable de preparación del PT.

## Seis pasos del recorrido

1. **IDENTIDAD:** ProductoTerminado, clasificación, procedencia, búsqueda y reutilización.
2. **COMPONENTES:** molde, piezas, cavidades, pesos y salidas productivas.
3. **COLORES:** PiezaColor, formulaciones e imágenes.
4. **ESTRUCTURA:** WIP y BOM revisionada.
5. **RUTA_EMPAQUE:** operaciones, precedencias, recursos, perfiles y reglas de empaque.
6. **REVISION:** consistencia, bloqueos y publicación o envío a aprobación.

## Historias hijas

| Historia | Incremento observable |
|---|---|
| [[US-012A_Sesion_Reanudable_e_Identidad_de_Producto|US-012A]] | Shell durable y paso IDENTIDAD real, con PT no duplicado. |
| [[US-012B_Configuracion_Fisica_Color_y_Formulacion|US-012B]] | Pasos COMPONENTES y COLORES conectados a la configuración física. |
| [[US-012C_Ingenieria_Readiness_y_Publicacion|US-012C]] | Pasos ESTRUCTURA, RUTA_EMPAQUE y REVISION conectados a ingeniería/readiness. |

La épica no genera una Tech Spec monolítica. Cada hija posee su propia TS-017.

## Invariantes comunes

- Los códigos SCM son automáticos e inmutables.
- Antes de crear se busca por código, nombre normalizado y relaciones relevantes.
- ProductoTerminado gobierna Línea/Familia comercial; Pieza no la hereda silenciosamente.
- Una Familia creada dentro de una Línea queda asociada y seleccionada atómicamente.
- El asistente no invoca el alta global de Familia: usa el alta contextual de la Línea para evitar una Familia huérfana de `LineaFamilia`.
- Volver atrás no elimina ni reescribe silenciosamente datos canónicos ya aplicados.
- Revisiones aprobadas son inmutables.
- “Sin pigmento” puede ser una formulación válida; “sin formulación” es un bloqueo distinto.
- El asistente nunca crea KIT, BOM plano legacy ni PiezaColor genérica sin color.
- Permisos y publicación se validan en backend para cada dominio.

## Fuera de alcance del piloto

- ingestión automática o mapeo inteligente de Excel;
- OCR, inferencias con IA o conciliación automática entre fuentes;
- edición colaborativa en tiempo real o comentarios multiusuario;
- voz, personaje animado complejo o gamificación;
- planificación o creación de OP/OF/OA/OT desde el asistente;
- CRUD de trabajadores, proveedores o categorías que no sean dependencias del PT actual.

## Definición de preparada de la épica

Esta lista acredita refinamiento documental, no implementación ni UAT. La solución integral sigue pendiente hasta que A/B/C estén implementadas y la UAT TS-017 sea aprobada.

- [x] Recorrido dividido en historias hijas verticales.
- [x] Autoridad de clasificación y semántica de volver atrás decididas por ADR.
- [x] Dataset UAT y resultados observables identificados.
- [x] Límites entre borrador, maestros canónicos y revisiones aprobadas definidos.
- [x] Alcance premium del piloto separado de la mascota avanzada.
