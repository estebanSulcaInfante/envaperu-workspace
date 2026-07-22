---
tipo: especificacion
subtipo: user_stories
estado: activo
tags: [pipeline, user-stories, comportamiento, negocio]
fecha_creacion: 2026-06-08
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
