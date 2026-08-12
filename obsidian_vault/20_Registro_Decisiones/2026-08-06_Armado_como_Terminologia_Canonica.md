---
tipo: decision_arquitectura
estado: aprobada
fecha: 2026-08-06
tags: [scm, lenguaje-ubiquo, armado, oa, ot, compatibilidad]
relacionados:
  - "[[Orden_Armado]]"
  - "[[Orden_Operacion]]"
  - "[[Ruta_Produccion]]"
  - "[[Vista_US-010F_Ordenes_Armado]]"
---

# ARMADO como terminología canónica del SCM

## Decisión

En EnvaPerú, **ARMADO** es el término de negocio oficial para las actividades
que unen componentes y producen un WIP o producto terminado. Las palabras
«ensamble», «ensamblado» y sus derivados dejan de formar parte del lenguaje
visible del producto, la guía de usuario y la documentación operativa.

La orden ejecutable correspondiente conserva la sigla **OA**, pero su nombre
de negocio es **Orden de Armado**. Su ejecución diaria se denomina **OT de
Armado**.

## Vocabulario canónico

| Término anterior | Término canónico |
|---|---|
| Orden de Ensamble | Orden de Armado |
| ensamble o ensamblado | armado |
| ensamblar | armar |
| Jefe de Ensamble | Jefe de Armado |
| subensamble | WIP |
| OT de Ensamble | OT de Armado |

`Prearmado` se mantiene cuando describe la unión parcial que produce un WIP.
`Armado` describe tanto la transformación posterior como la familia operativa
que gobierna prearmado, armado, acabado y empaque mediante OA/OT de Armado.

## Compatibilidad técnica

Los identificadores persistidos anteriores, como `ENSAMBLE`,
`ORDEN_ENSAMBLE`, `JEFE_ENSAMBLE`, `ENSAMBLE_*`, `SUBENSAMBLE_WIP`, campos
terminados en `_ensamble` y los endpoints `/ordenes-ensamble`, son aliases
técnicos heredados. Se conservan temporalmente para leer datos, permisos,
integraciones y marcadores anteriores sin romper trazabilidad.

Estos aliases:

- no deben mostrarse al usuario;
- no deben aparecer en contratos o enlaces nuevos;
- deben traducirse a ARMADO en la frontera de interfaz y documentación;
- solo pueden eliminarse mediante una migración de datos versionada y probada.

El contrato público nuevo usa `/produccion/ordenes-armado`,
`/scm/v1/ordenes-armado` y `/scm/v1/correcciones-armado`. Las rutas anteriores
permanecen únicamente como redirecciones o aliases de compatibilidad.

## Alcance

La decisión aplica a:

- navegación, títulos, botones, mensajes y errores;
- guía `/guia/scm`, glosario y matriz de roles;
- dominio, historias, especificaciones, endpoints y UAT del vault;
- nombres visibles de centros, rutas, operaciones, OA y OT;
- documentación y contratos creados después de esta decisión.

## Criterio de aceptación

Una búsqueda de contenido visible no debe encontrar «ensamble», «ensamblado»
o «subensamble». Las coincidencias restantes deben estar limitadas a aliases
técnicos heredados, migraciones históricas o pruebas explícitas de
compatibilidad y deben estar identificadas como tales.
