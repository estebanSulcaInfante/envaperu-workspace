---
tipo: recibo_ejecucion
fecha: 2026-09-02
spec_phase: approved
delivery_state: review
functional_validation: untested
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
---

# REC — Reset y arranque de UAT local de Pesaje

## Objetivo y autoridad

Solicitud explícita: «enciende la uat local con reset para iniciarla denuevo».
Se reinicia el escenario existente `jarra-real-6l-pesaje-piezas` con fecha
operativa 2026-09-02 y se dejan los servicios encendidos. Guion:
[[UAT_US-010K_Modulo_Pesaje_Piloto_Kg]], basado en DEV K3/K4 y etiquetas v5.
No se amplía el alcance al nuevo cierre/inventario kg ni se aprueba UAT humana.

Workspace: `C:/Users/esteb/gitprojects/envaperu-workspace-2`, con cambios locales
previos conservados. Sin cambios de producto ni commits. No aplica ciclo RED
porque se ejecuta el lanzador existente, no una implementación nueva.

## Targets y recuperación

Antes del reset se comprobaron rutas absolutas y ausencia de enlaces/reparse
points. PostgreSQL confirmó `enva_uat_recorrido | 127.0.0.1 | 5432`.

Se eliminaron y reconstruyeron únicamente:

- base local `enva_uat_recorrido`;
- directorio `.codex-tmp/uat-recorrido`, dentro del workspace.

El avance anterior es recuperable desde el respaldo local previo:
`.codex-tmp/uat-backups/2026-09-02_124420/`.
Contiene `enva_uat_recorrido.dump` (896116 bytes, formato custom, índice validado
con pg_restore) y `runtime/` con el estado anterior. No se publicaron archivos
de respaldo ni secretos. Restaurar requeriría una operación posterior explícita;
no aplicar ese respaldo sobre el nuevo avance por defecto.

## Ejecución y verificaciones

| Acción | Resultado |
|---|---|
| Preflight y respaldo | Targets locales verificados; dump y runtime preservados. |
| `scripts/uat-local.ps1 Reset -Scenario jarra-real-6l-pesaje-piezas -Fecha 2026-09-02 -ConfirmReset` | OK; esquema reconstruido hasta `f91b2d4e6c83`, semilla y token de estación DPAPI. |
| Semilla | Jarra Real 6 L Transparente / INY-01, fecha 2026-09-02. Su guarda de baseline exige cero documentos/movimientos del recorrido; no precarga mangas/pesajes. |
| Build Central | OK, 1311 módulos; advertencia de bundle grande, no error. |
| Build Pesaje | OK, 136 módulos. |
| `scripts/uat-local.ps1 Start` | OK, procesos ocultos en segundo plano registrados por el lanzador. |
| `scripts/uat-local.ps1 Status` a las 12:47 Lima | Central, frontend y Pesaje LISTO. |
| Readiness estación | READY, Central ONLINE, sin issues ni último error. |
| HTTP de ambas interfaces | 200 en Central y Pesaje. |

## Acceso y modo

- Central: `http://127.0.0.1:5174`.
- Pesaje: `http://127.0.0.1:5051/?tab=scm-weighing`.
- API Central: `http://127.0.0.1:5100`.
- Base, almacenamiento y origen de Central exclusivos de UAT en loopback.
- Balanza e impresora simuladas; no se emitió papel ni se usó hardware real.
- Autenticación UAT por actor local; no se modificó producción ni Supabase.

## Omisiones y gates

No se ejecutó un nuevo recorrido operativo, aceptación humana, QA visual ni
suite completa: esta pasada valida reset/arranque/conectividad. Se conserva
la evidencia técnica y las limitaciones del recibo de preparación UAT.
La disponibilidad HTTP no demuestra usabilidad ni cierra las brechas KG-01…07.

Estados: especificación aprobada para el alcance existente, entrega en revisión;
aceptación funcional del módulo sin ejecutar, UX provisional, UAT física pendiente,
`no_habilitar_en_planta`. Marcha blanca no ejecutada.

Siguiente acción segura: iniciar el recorrido en Central con documentos nuevos
y registrar resultados en [[ACTA_UAT_Pesaje_Piloto_Kg]]. El servicio queda
encendido por petición del usuario; no hay monitor recurrente creado.
