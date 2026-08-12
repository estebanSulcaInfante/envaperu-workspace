---
tipo: decision
estado: aceptada
tags: [scm, alertas, pesaje, anulacion, jefaturas, auditoria]
relaciones:
  - "[[US-010J_Alertas_Operativas_e_Inconsistencias]]"
  - "[[Alerta_Operativa_SCM]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-011C_Continuidad_y_Operacion_Auditada_Pesajes_Piloto]]"
fecha_creacion: 2026-08-02
fecha_actualizacion: 2026-08-02
---

# Alertas operativas configurables para jefaturas

## Decisión

Las jefaturas necesitan una bandeja de inconsistencias accionable, no solo
mensajes efímeros dentro del formulario. Las reglas y umbrales serán
configurables y versionados.

El primer catálogo incluye:

1. pesaje realizado más de un día después de la fecha operativa de la OT;
2. pesaje realizado más de `24 horas` después de crear/imprimir la preetiqueta;
3. anulación o corrección que retire el efecto de una bolsa más de `24 horas`
   después de pesarla.

Los eventos originales permanecen inmutables. “Eliminar una bolsa pesada” se
implementa como anulación o compensación auditable, nunca como borrado físico.

## Presentación

La bandeja muestra qué ocurrió, cuánto tiempo transcurrió, OP/OF/OT/manga,
actores, motivo declarado, estado y acceso al historial. Jefaturas ven alertas
según capacidades y alcance; Gerencia puede consultar transversalmente.

En el primer alcance las alertas se presentan únicamente dentro del SCM, en un
panel de jefatura. Correo, mensajería y notificaciones externas quedan fuera.

Reconocer una alerta significa que fue vista, no que la inconsistencia sea
correcta. Resolver exige resultado y actor.
