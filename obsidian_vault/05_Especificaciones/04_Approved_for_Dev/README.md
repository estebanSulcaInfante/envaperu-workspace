---
tipo: especificacion
subtipo: approved_for_dev
estado: activo
tags: [pipeline, approved, ai-agent, desarrollo, codigo]
fecha_creacion: 2026-06-08
---

# 04_Approved_for_Dev (Aprobado para Desarrollo)

Este directorio contiene las **especificaciones finales consolidadas y aprobadas** para que el agente de IA (u otros desarrolladores) genere e implemente el código sin ambigüedades.

## Especificaciones Aprobadas

| Desarrollo | Historia | Tech Spec | Estado |
|---|---|---|---|
| [[DEV-010A_Recepcion_Trazable_Materiales|DEV-010A]] | [[../02_User_Stories/US-010A_Recepcion_Trazable_Materiales|US-010A]] | [[../03_Tech_Specs/TS-010A_Recepcion_Trazable_Materiales|TS-010A]] | En desarrollo; primer incremento de dominio GREEN |

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
