---
tipo: tech-spec
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha: 2026-09-02
---

# TS-010K4 — Diagnóstico de Pesaje sin alterar autoridad

Implementa [[US-010K4_Estado_y_Bloqueos_Visibles_al_Pesar]]. Entrada:
petición explícita del 2026-09-02; excepción local provisional de interfaz,
sin UAT humana inferida. [[PROTO_US-010K4_Estado_y_Accion_Pesaje]].

## Contrato y reglas

- Central añade `bloqueos_pesaje.completar_final` y `registrar_avance_kg`.
  Cada valor es nulo si autorizado o `{codigo, mensaje, recuperacion,
  responsable}`. Se conservan `can_weigh`, `can_register_weight_control`
  y validaciones de escritura. Diagnóstico puro sin mutaciones ni migración.
- Explicar estado de Trabajo de la OT, no confundir encabezado con inicio
  de cada Trabajo. Añadir estado OT como dato contextual, no nueva guarda.
- Estación transmite metadata existente/aditiva. UI consume capacidad +
  diagnóstico y conserva fallback seguro con servidores anteriores.
- Presentación centralizada de estado: no mostrar listo si botón deshabilitado.
- Último neto: control de la sesión o `continuidad.ultimo_control`; preservar
  al alternar modo. Tope bruto es snapshot existente, no tolerancia inventada.
- No afirmar estabilidad física desde solo un número; validación definitiva
  de lectura sigue en el servicio de captura.
- Botón/F2 no cambian de dominio: AVANCE_KG no cierra ni transfiere.

## Verificación y límites

BASELINE UI 11, estación backend 34, servicio OT Central 38 verdes.
RED: diagnóstico faltante y repetición por reescaneo/checkbox; GREEN helper
Central + estado UI; REFACTOR una fuente de habilitación/mensaje.
Regresión: frontend estación, backend estación, Central focal, contratos y
build. QA visual real del componente con fixtures locales sin red productiva.
UAT física pendiente: PES/LEC/CON/IMP. Relevo/cierre solo kg bloqueado por
decisión del draft. Rollback: revertir exclusivamente este incremento;
campos aditivos pueden ignorarse por clientes anteriores.
