---
tipo: user_story
id: US-012A
titulo: "Sesión reanudable e identidad de ProductoTerminado"
estado: implementada-local-pendiente-uat
tags: [catalogo, wizard, borrador, producto-terminado, duplicados]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
epica: "[[US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
tech_spec: "[[../03_Tech_Specs/TS-017A_Sesion_Durable_y_Shell_de_Alta_Guiada]]"
---

# US-012A: Sesión reanudable e identidad de ProductoTerminado

## Descripción

**Como** Gestor de Maestros  
**Quiero** iniciar, guardar y reanudar una alta con búsqueda previa de duplicados  
**Para** capturar información durante varias consultas sin perder el trabajo ni crear otra identidad para el mismo producto.

## Alcance

- shell de seis pasos con navegación retrospectiva;
- autosave en servidor, acción persistente **Guardar y salir** y listado/reanudación de todos los estados abiertos;
- título de sesión derivado del producto resuelto en IDENTIDAD, con fallback provisional antes de resolverlo;
- registro textual de fuentes y pendientes;
- búsqueda/reutilización antes de crear PT, Línea y Familia;
- alta mínima de PT con clasificación comercial válida;
- creación atómica de Familia dentro de la Línea activa;
- estado visible de borrador frente a dato ya aplicado.

## Escenarios ATDD

### AGP-A01 — Reanudar sin pérdida

**Dado** una sesión con nombre provisional y el paso IDENTIDAD parcialmente completo  
**Cuando** el actor cierra la pestaña y vuelve a abrir la sesión  
**Entonces** recupera la última versión guardada, el paso actual y sus pendientes  
**Y** todavía no existe un PT si IDENTIDAD no fue finalizado.

### AGP-A02 — Conflicto entre pestañas

**Dado** la misma sesión abierta con versión 4 en dos pestañas  
**Cuando** la primera guarda la versión 5 y la segunda intenta guardar su versión 4  
**Entonces** la segunda recibe `409 VERSION_CONFLICT`  
**Y** puede recargar o copiar sus cambios sin sobrescribir silenciosamente la versión 5.

### AGP-A03 — Reutilizar antes de crear

**Dado** un PT existente cuyo código o nombre normalizado coincide con la búsqueda  
**Cuando** el usuario lo selecciona como existente  
**Entonces** la sesión guarda su identidad canónica y no reserva otro correlativo.

### AGP-A04 — Familia creada en contexto

**Dado** la Línea `HOGAR` seleccionada y una Familia `COLADORES` inexistente  
**Cuando** se confirma **Crear y seleccionar**  
**Entonces** se crean/reutilizan Familia y `LineaFamilia` en una operación válida  
**Y** la nueva Familia queda seleccionada sin abandonar el asistente.

El flujo no puede sustituirse por `POST /api/catalogo/familias`: la única alta permitida dentro del asistente es `POST /api/catalogo/lineas/{linea_id}/familias` con el objeto `familia`, para crear Familia y `LineaFamilia` atómicamente y autoseleccionar la respuesta.

### AGP-A05 — Volver y corregir

**Dado** el paso IDENTIDAD completo  
**Cuando** el actor vuelve a IDENTIDAD y corrige una fuente o el nombre provisional  
**Entonces** conserva los demás campos, recalcula las advertencias afectadas y guarda una nueva versión.

### AGP-A06 — Clasificación comercial autoritativa

**Dado** un PT nuevo con Línea–Familia comercial válida  
**Cuando** se completa IDENTIDAD  
**Entonces** el par se persiste en ProductoTerminado  
**Y** no se crea todavía ninguna Pieza ni se copia el par a otra entidad.

### AGP-A07 — Guardar, salir y reanudar por título

**Dado** una sesión `CON_BLOQUEOS` cuyo paso IDENTIDAD resolvió `COLADOR #3`  
**Cuando** el actor usa **Guardar y salir** y vuelve a **Altas en curso**  
**Entonces** la sesión aparece como `COLADOR #3`, conserva su versión y se abre en `paso_actual`  
**Y** el mismo comportamiento aplica a `BORRADOR` y `LISTA_PARA_PUBLICAR`.

## Errores, permisos y correcciones

- `ARTICULO_ADMINISTRAR` permite crear la sesión y el PT.
- Una asociación Línea–Familia inexistente responde un error de campo y no aplica el PT.
- Abandonar conserva auditoría y no elimina maestros ya aplicados.
- Un dato sin fuente confiable puede quedar pendiente, pero un campo obligatorio bloquea la finalización del paso.

## Dataset mínimo

- sesión `UAT COLADOR #3`;
- Línea `HOGAR` existente;
- Familia `COLADORES` nueva o reutilizable;
- nombre de PT `COLADOR #3` sin SKU digitado.

## Definición de preparada

- [x] Actor, resultado, persistencia, reanudación y conflictos definidos.
- [x] Regla de clasificación resuelta por ADR.
- [x] Escenarios observables y automatizables.
- [x] Dependencias técnicas diferidas a TS-017A.
