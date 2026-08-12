---
tipo: user_story
id: US-012C
titulo: "Ingeniería, readiness y publicación desde el alta guiada"
estado: implementada-local-pendiente-uat
tags: [catalogo, bom, ruta, empaque, readiness, aprobacion]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
epica: "[[US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
tech_spec: "[[../03_Tech_Specs/TS-017C_Ingenieria_Readiness_y_Publicacion_Guiada]]"
---

# US-012C: Ingeniería, readiness y publicación

## Descripción

**Como** Gestor de Maestros o responsable de Ingeniería  
**Quiero** completar ESTRUCTURA, RUTA_EMPAQUE y REVISION y recibir una evaluación final accionable  
**Para** saber si el ProductoTerminado está realmente listo para ser planificado.

## Alcance

- reutilizar dentro del asistente los editores canónicos de estructura, ruta y empaque;
- crear WIP cuando la transformación lo requiera;
- publicar directamente o enviar a aprobación según capacidades;
- calcular readiness con bloqueos, advertencias y opcionales enlazados a su paso;
- finalizar la sesión sin falsear que una aprobación pendiente está completa.

## Escenarios ATDD

### AGP-C01 — BOM multinivel válida

**Dado** un PT compuesto por PiezaColor y un WIP  
**Cuando** se publica su estructura  
**Entonces** cada cantidad es positiva, la revisión no contiene ciclos y conserva sus artículos exactos.

### AGP-C02 — Ruta con terminal PT

**Dado** una BOM válida y una ruta de dos pasos  
**Cuando** el usuario revisa el último paso  
**Entonces** éste produce el PT seleccionado, muestra su autoridad de ejecución y no puede dejar una salida terminal distinta.

### AGP-C03 — Empaque suficiente

**Dado** una salida que genera mangas de PiezaColor, WIP o PT  
**Cuando** se ejecuta readiness  
**Entonces** exige perfil predeterminado y una regla de empaque aprobada viable para cada salida que lo necesita.

### AGP-C04 — Bloqueo enlazado

**Dado** una formulación sin publicar o una ruta sin terminal  
**Cuando** se abre el resumen final  
**Entonces** muestra un bloqueo con entidad, motivo y acción **Ir al paso**  
**Y** no utiliza un contador genérico sin explicación.

### AGP-C05 — Publicación por capacidades

**Dado** un Gestor de Maestros con publicación directa  
**Cuando** confirma REVISION  
**Entonces** publica cada borrador válido mediante su servicio canónico y registra actor/evento  
**Pero** un actor sin esa capacidad sólo puede enviarlo a aprobación.

### AGP-C06 — Resultado honesto

**Dado** que una estructura quedó pendiente de aprobación  
**Cuando** se finaliza la sesión de captura  
**Entonces** el sistema puede marcar la sesión como completada para captura  
**Y** muestra `PENDIENTE DE APROBACIÓN`, no `LISTO PARA PLANIFICAR`.

### AGP-C07 — Reintento parcial

**Dado** que BOM y ruta se aplicaron y empaque falló por conflicto de versión  
**Cuando** el usuario reintenta REVISION  
**Entonces** no duplica las dos revisiones anteriores y reintenta sólo el comando pendiente.

## Readiness mínimo

La decisión se calcula según la ruta real, no mediante una checklist fija. Incluye al menos: identidad PT activa, salidas físicas resolubles, formulaciones aplicables a operaciones de fabricación, estructuras y ruta publicadas, terminal PT, perfiles/reglas de empaque requeridos y ausencia de referencias inactivas.

## Definición de preparada

- [x] Diferencia entre captura, publicación y readiness definida.
- [x] Permisos y reintentos cubiertos.
- [x] Los editores canónicos continúan siendo fuente de reglas.
