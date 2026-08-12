---
tipo: tech-spec
estado: implementada-local-pendiente-uat
historia: "[[../02_User_Stories/US-010J_Alertas_Operativas_e_Inconsistencias|US-010J]]"
fecha_actualizacion: 2026-08-11
tags: [scm, alertas, configuracion, auditoria]
---

# TS-010J: Alertas operativas configurables

## Decisiones

1. La primera entrega usa un panel interno; no envía correo ni mensajería.
2. Una regla posee revisiones. Toda alerta referencia exactamente la revisión
   que la detectó.
3. La huella `regla + agregado + condición` es única mientras la condición esté
   activa. Reprocesar un evento no duplica alertas.
4. Reconocer, asignar, resolver y descartar son eventos distintos. Resolver o
   descartar exige motivo; nunca modifica ni elimina el hecho origen.
5. Los umbrales iniciales son 24 h para preetiqueta/pesaje, 24 h para
   corrección/anulación y 1.000 kg para custodia. Todos son editables y
   versionados.
6. TS-018 añade 24 h para manga pesada sin recepción y evaluación inmediata de
   diferencias de transferencia. La alerta nunca acredita un almacén.

## Modelo físico

| Tabla | Responsabilidad |
|---|---|
| `scm_regla_alerta` | Identidad estable y estado activo |
| `scm_regla_alerta_revision` | Umbral, unidad, severidad, alcance y vigencia |
| `scm_alerta_operativa` | Instancia, huella, agregado y estado |
| `scm_alerta_evento` | Historial append-only de gestión |

Estados: `ABIERTA`, `RECONOCIDA`, `RESUELTA`, `DESCARTADA`.

## API

Base: `/api/scm/v1/alertas`.

- `GET /` con filtros `estado`, `severidad`, `tipo`, `desde`, `hasta`;
- `POST /{id}/reconocer`;
- `POST /{id}/asignar`;
- `POST /{id}/resolver`;
- `POST /{id}/descartar`;
- `GET /reglas`;
- `POST /reglas/{codigo}/revisiones`;
- `POST /reglas/{codigo}/revisiones/{id}/aprobar`;
- `POST /evaluar` para reevaluación explícita y auditada.

Capacidades: `ALERTA_VER`, `ALERTA_GESTIONAR`, `ALERTA_CONFIGURAR`.

## UI

`/produccion/alertas` muestra contadores por severidad, filtros, antigüedad,
resumen y vínculo al agregado. Las acciones se ocultan/deshabilitan según
capacidad y explican la razón. La pestaña de configuración solo aparece para
quien mantenga reglas.

## Pruebas

- misma huella no duplica la alerta;
- reconocer no resuelve;
- resolver exige motivo y conserva origen;
- nueva revisión no cambia alertas históricas;
- diferencia de custodia mayor a 1 kg crea una alerta;
- pendiente TS-018: manga pesada sin recepción supera el umbral una sola vez;
- pendiente TS-018: diferencia de transferencia comparte ID entre Control y Alertas;
- filtros y permisos del panel corresponden a las capacidades efectivas.

Primera prueba RED: evaluar dos veces la misma diferencia de custodia debe
retornar la misma alerta abierta.
