# EnvaPeru SCM — acuerdo de trabajo para agentes

## Fuente de verdad

- Antes de cambiar comportamiento, consulta `obsidian_vault/00_Meta/Prompt_Agent_Instructions.md`, la nota de dominio aplicable y las decisiones relacionadas.
- El pipeline canónico está en `obsidian_vault/00_Meta/Estandar_Pipeline_Agentico.md`.
- No inventes reglas de planta, ergonomía, tolerancias, autoridades ni contingencias. Registra la incógnita y solicita validación humana cuando la evidencia local no la resuelva.
- Conserva los cambios existentes del usuario y evita modificar archivos ajenos al incremento activo.

## Trabajo sobre una especificación

Usa los playbooks de `.agents/workflows/` para enriquecer historias, generar Tech Specs, implementar e instanciar UAT.

1. Identifica la User Story o Technical Enabler, su Tech Spec, el documento `DEV-*`, dependencias, restricciones de liberación y UAT relacionada.
2. Para interfaces operativas, consulta el contexto operativo y los perfiles UAT seleccionados antes de proponer o cambiar la UI.
3. Una pantalla funcional no se considera usable ni lista para planta por inferencia del agente.
4. Implementa una porción vertical y revisable a la vez mediante `BASELINE -> RED -> GREEN -> REFACTOR`.
5. Ejecuta las verificaciones proporcionales al cambio y registra evidencia, comprobaciones omitidas y riesgos restantes.
6. No marques una validación humana como aprobada. Si falta, conserva `ux_validation: provisional` y, cuando aplique, `release_constraint: no_habilitar_en_planta`.

## Interfaces operativas

- Declara cuál es la información primaria, la acción primaria, los estados de espera/listo/error/éxito y la recuperación.
- Produce evidencia visual en el dispositivo o viewport objetivo para los estados relevantes.
- Prioriza la tarea inmediata del trabajador; la información diagnóstica o secundaria no debe competir con ella.
- Las pruebas automáticas demuestran comportamiento y accesibilidad básica, no sustituyen la observación con trabajadores ni la UAT física.

## Verificación

- Workspace completo: `./scripts/test.ps1 -Component all`.
- Contratos central–pesaje: `./scripts/test-contracts.ps1`.
- Recorrido aislado de sincronización: `./scripts/test-sync-e2e.ps1`.
- Usa pruebas más acotadas durante RED/GREEN y la regresión correspondiente antes de entregar.

## Cierre del trabajo

- Entrega un recibo siguiendo `obsidian_vault/99_Plantillas/TPL_Recibo_Ejecucion_Agentica.md` cuando el incremento sea material.
- Distingue siempre `spec_phase`, `delivery_state`, `functional_validation`, `ux_validation` y `physical_uat`; el campo histórico `estado` no sustituye esos ejes.
- No declares `LISTO_PARA_PLANTA` sin la UAT operativa/física exigida por el riesgo UX.
