---
trigger: always_on
---

# Obsidian Vault — Memoria del Proyecto EnvaPeru

Este proyecto tiene una bóveda de Obsidian en `obsidian_vault/` que funciona como tu memoria persistente y fuente de verdad.

## Regla Obligatoria
ANTES de escribir código, modificar modelos, o responder preguntas sobre reglas de negocio, DEBES consultar las notas relevantes en la bóveda.

## Cómo Usar la Bóveda
Esta bóveda de Obsidian es la **memoria persistente y fuente de verdad** del proyecto EnvaPeru SCM. Todo conocimiento de dominio, decisiones arquitectónicas, reglas de negocio, contratos de API, y especificaciones de componentes se documentan aquí en formato Markdown con frontmatter YAML y enlaces bidireccionales `[[wikilinks]]`.

## Taxonomía de Carpetas

| Carpeta | Propósito | Cuándo Consultar |
| :--- | :--- | :--- |
| `00_Meta/` | Arquitectura global, convenciones, este archivo | Siempre al inicio de una sesión |
| `01_Dominio/` | Modelos de BD, campos, fórmulas, reglas de negocio | Al trabajar con cualquier entidad |
| `02_Backend/` | Endpoints API, servicios, lógica de servidor | Al modificar o crear endpoints |
| `03_Frontend/` | Vistas, componentes, estado de UI | Al trabajar con la interfaz |
| `04_Modulo_Pesaje/` | Hardware, integración balanza, UI de planta | Al trabajar con pesaje |
| `05_Especificaciones/` | Pipeline de desarrollo (Drafts, User Stories, Tech Specs, Aprobado para Dev) | Al planificar, definir o comenzar a desarrollar un requerimiento |
| `10_Flujos_y_Procesos/` | Casos de uso paso a paso | Para entender flujos completos |
| `20_Registro_Decisiones/` | ADRs (Architecture Decision Records) | Para entender el "por qué" de decisiones |
| `99_Plantillas/` | Templates para crear nuevas notas | Al documentar algo nuevo |

## Cómo Leer las Notas
- **Frontmatter YAML:** Cada nota tiene metadatos (`tipo`, `estado`, `tags`, `relaciones`) — úsalos para filtrar y navegar.
- **`[[wikilinks]]`:** Seguir enlaces bidireccionales para entender dependencias entre entidades.
- **Campos `calculo_*`:** Son persistidos en BD y se recalculan via `actualizar_metricas()`.
- **Campos `snapshot_*`:** Son congelados al crear una entidad hija — no cambian retroactivamente.

## Cómo Actualizar la Bóveda
Cuando hagas cambios significativos al proyecto, **actualiza la nota correspondiente** en esta bóveda:

1. **Nuevo modelo/tabla** → Crear en `01_Dominio/` usando `99_Plantillas/TPL_Modelo_BD.md`
2. **Nuevo endpoint** → Crear en `02_Backend/Endpoints/` usando `99_Plantillas/TPL_Endpoint_API.md`
3. **Nuevo componente UI** → Crear en `03_Frontend/Componentes/` usando `99_Plantillas/TPL_Componente_UI.md`
4. **Decisión arquitectónica** → Crear ADR en `20_Registro_Decisiones/`
5. **Cambio en reglas de negocio** → Actualizar la nota de dominio afectada
6. **Planificación de requerimientos** → Usar la carpeta `05_Especificaciones/` y seguir el pipeline desde Draft hasta Aprobado para Dev.

## Regla Crítica
> **Nunca asumas reglas de negocio sin consultar primero `01_Dominio/`.** Las fórmulas, validaciones y prioridades de cálculo están documentadas ahí y son la fuente de verdad.