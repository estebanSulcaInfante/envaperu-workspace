---
trigger: always_on
---

# Obsidian Vault — Memoria del Proyecto EnvaPeru

Este proyecto tiene una bóveda de Obsidian en `obsidian_vault/` que funciona como tu memoria persistente y fuente de verdad.

## Regla Obligatoria
ANTES de escribir código, modificar modelos, o responder preguntas sobre reglas de negocio, DEBES consultar las notas relevantes en la bóveda.

## Cómo Usar la Bóveda
1. **Al iniciar cualquier tarea:** Lee `obsidian_vault/00_Meta/Arquitectura_Global.md` para contexto general.
2. **Para reglas de negocio, fórmulas y modelos de BD:** Consulta `obsidian_vault/01_Dominio/` — cada entidad tiene su propia nota con campos, fórmulas, validaciones y relaciones.
3. **Para convenciones de naming/unidades:** Consulta `obsidian_vault/00_Meta/Convenciones_Codigo.md`.
4. **Para endpoints API:** Consulta `obsidian_vault/02_Backend/Endpoints/`.
5. **Para entender flujos completos:** Consulta `obsidian_vault/10_Flujos_y_Procesos/`.
6. **Para entender decisiones pasadas:** Consulta `obsidian_vault/20_Registro_Decisiones/`.

## Regla de Actualización
Cuando hagas cambios significativos al proyecto (nuevo modelo, nuevo endpoint, refactoring, decisión arquitectónica), ACTUALIZA o CREA la nota correspondiente en la bóveda usando las plantillas en `obsidian_vault/99_Plantillas/`.

## Notas Clave del Dominio (Core)
- `01_Dominio/Orden_Produccion.md` — Cabecera global, cálculos cacheados, JSON de API
- `01_Dominio/Lote_Color.md` — meta_kg como único input, coladas float
- `01_Dominio/Registro_Diario.md` — Hoja de producción, snapshots, totalizadores
- `01_Dominio/Control_Peso.md` — Doble verificación, validación con tolerancia 5Kg

## Regla Crítica
NUNCA asumas reglas de negocio. Las fórmulas y validaciones en `01_Dominio/` son la fuente de verdad. Los campos `calculo_*` se persisten en BD. Los `snapshot_*` se congelan al crear entidades hijas.
