---
tipo: tech-spec
estado: aprobada-exploracion-local
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
ux_risk: high
fecha: 2026-09-02
---

# TS-010M4 — Anulación de OT vacía y revisión de creación

Fuentes: [[US-010M4_Creacion_Revisada_y_Anulacion_OT_Vacia]],
[[CTX_PROTO_US-010M4_Recuperacion_OT_Vacia]], Registro_Diario, matriz de roles,
ADR OT/Trabajo 2026-08-08. Autorización humana explícita del 2026-09-02 para
los criterios M4-01…10 y excepción exploratoria solo local.

## Contrato de dominio

OT normalizada de FABRICACION, sin vínculos directos legacy OF/corrida,
PLANIFICADA, nunca iniciada/cerrada, sin hijos operativos. ANULADA terminal.
Capacidad OT_ANULAR para SUPERVISOR, JEFE_PRODUCCION, GERENTE_GENERAL;
sin condición de creador ni segundo aprobador. Conservar todo historial.
No anular otras entidades ni liberar inventario. Nueva OT usa correlativo nuevo.

Revisar FK entrantes a registro_diario_produccion en metadata: trabajo OT,
manga, asignación plan, solicitud extra, detalle horario, control de peso,
confirmación de armado y solicitud de abastecimiento. Cualquier referencia
bloquea, incluso si su estado es terminal. Nuevas FK también deben bloquear.
Auditoría genérica no se considera hijo operativo.

## Contrato API/datos

POST /api/scm/v1/ots/{uuid}/anular, cuerpo {version, motivo}; actor autorizado
e Idempotency-Key obligatorios. Reserva idempotente existente; misma clave
y petición devuelve mismo resultado. Motivo recortado no vacío, máximo 250.
Bloqueo de fila OT FOR UPDATE, lectura fresca, verificar versión/estado e hijos
en la misma transacción. add_color_work y transition_ot ya bloquean la OT y
validan estado; ANULADA no permite agregar ni iniciar. No llamadas externas
dentro de la transacción.

Persistir evento FABRICATION_OT_HEADER_ANNULLED con before/after, motivo,
snapshot actor y fecha; incrementar versión, sin falsear iniciada_at/cerrada_at.
Lectura añade bloqueo_anulacion (razón común) y anulacion (evidencia), sin
retirar campos previos. API siempre revisa referencias completas aunque UI
no las conozca. Errores 403 permiso, 404 identidad, 409 versión/estado/vínculos,
400/422 entrada. Rollback atómico de operación y evento ante error.

Capacidad aditiva en seed, sin retirar grants existentes. Para local aplicar
solo esa capacidad/grants, no reseed de documentos ni reset. No requiere
columnas nuevas: evidencia en journal existente. Promoción de permisos a
otra base fuera de alcance; deberá hacerse explícitamente al liberar.

## Contrato de interacción y presentación

Creación: primera acción abre diálogo con resumen congelado, Volver y
Confirmar creación. Anulación secundaria en detalle; diálogo identidad/motivo,
Volver y Anular OT. Foco inicial seguro en motivo/Volver, Tab y escape;
no mutación por cerrar. Sin doble envío por guard síncrono; clave estable
durante reintento de una petición, nueva para una intención distinta.
Sin acuse no afirmar éxito. Refrescar tras conflicto; la UI no admite trabajo
en ANULADA/CERRADA. Mantener contexto de jornada e historial consultable.
Error visible en diálogo; motivo conservado. Anulada muestra evidencia.

Corrección UAT autorizada el 2026-09-02 («ajustemos el aviso»): el aviso de
coincidencia por máquina excluye cabeceras ANULADA de su conteo, pero conserva
la lista completa para consulta y selección histórica. No cambia el criterio
previo para CERRADA/legacy ni el total informativo de jornadas registradas.
Pruebas: una planificada + una anulada no alerta; dos no anuladas + una anulada
alerta por dos; seleccionar la anulada sigue siendo posible sin falsa alerta.

Wireflow y jerarquía en contexto enlazado; escritorio local objetivo QA
1440×900 y 1163×654, no hardware validado de planta. Capturas: revisión crear,
motivo vacío/listo, anulada y bloqueo; pruebas estados de red y teclado.

## Pruebas y liberación

BASELINE: scripts/test.ps1 -Component backend y frontend (iniciados antes de
ediciones de producto); focal backend test_scm_ot_service.py y frontend
OtMangasScm/scmOtApi/PlantJourneys. Primera RED: POST anular una OT vacía
debe devolver 200 y evento único; actualmente ruta ausente. M4-01/02/10 UI;
M4-03/04/05/06/08/09 servicio/API; M4-07 concurrencia/versión y PostgreSQL.
No cambios al contrato Central–estación ni sync: regresión de esos contratos
solo si se amplía el alcance. Build frontend y QA visual antes de entrega.

Rollout solo local: reconstruir frontend/reiniciar API sin Reset, permisos
aditivos; preservar OT-000001. Rollback de código no elimina eventos ni OT
anuladas; retirar acceso a la acción antes de revertir. No rollback de datos.
UAT ADM/CON funcional-operativa aislada; no fabricar ni imprimir para probar
anulación. Gates humanos permanecen pendientes.
