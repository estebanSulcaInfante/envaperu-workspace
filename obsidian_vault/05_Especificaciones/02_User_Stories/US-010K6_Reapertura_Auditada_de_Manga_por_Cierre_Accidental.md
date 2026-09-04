---
tipo: user-story
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
uat_profiles: [PES, LEC, ADM, CON, IMP]
fecha: 2026-09-03
---

# US-010K6 — Reapertura auditada de manga por cierre accidental

Como Jefa de Producción quiero reabrir desde Central una manga de Fabricación
cerrada accidentalmente, para que el trabajador continúe llenando el mismo
objeto físico con su mismo QR sin borrar el cierre erróneo ni crear otra manga.

Origen: hallazgo funcional/UX del recorrido local del 2026-09-03 sobre
`OF000001-OT002-M001`: el operador omitió `Control de peso` y F2 confirmó un
final de `8.950 kg` cuando la referencia teórica era `12.000 kg`.
La regla ya estaba definida en PMI-15 de
[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]. El
responsable funcional pidió explícitamente implementar el corte local siguiendo
el pipeline. La autorización no equivale a UX-READY ni habilita planta.

## Alcance e invariantes

- Incluye manga `NORMAL` de Fabricación, cierre normal vigente y ausencia de
  recepción en Almacén.
- `REABRIR_MANGA` exige Jefe de Producción o Gerente General, motivo, versión e
  idempotencia.
- El final y sus postetiquetas quedan invalidados de forma compensatoria; nunca
  se eliminan.
- La preetiqueta, `manga_id`, código, QR, controles, OT, Trabajo, maquinista,
  asignación y cupo se conservan.
- La manga vuelve a `EN_LLENADO`; la cantidad confirmada por el final deja de
  computar hasta un nuevo cierre.
- Reabrir no devuelve cupo, no crea manga, no imprime QR y no crea Kardex.
- Si existe recepción vigente, primero se exige su reversa.
- Cierre parcial, manga de Armado y anulación definitiva quedan fuera de este
  corte; deben continuar bloqueados y usar sus flujos específicos.

## Interacción y estados

Información primaria en Central: código de manga, final que se invalidará y
consecuencia «conserva QR y cupo». Acción primaria: `Reabrir manga`; motivo
obligatorio y confirmación explícita. Éxito: `Manga abierta · continúe con el
mismo QR` y recordatorio de retirar/marcar el sticker final invalidado. Error:
causa concreta y recuperación; nunca éxito optimista.

En Pesaje no se añade otra acción: antes de Central la manga permanece
bloqueada; después de la reapertura el mismo QR resuelve `EN_LLENADO` y permite
control o final conforme a K3/K4.

## Aceptación BDD

- `K6-01`: dado un cierre normal accidental no recibido, cuando JP reabre con
  motivo y versión, entonces el final queda `REABIERTO`, la manga vuelve a
  `EN_LLENADO`, conserva preetiqueta/QR/controles/cupo y no existe Kardex.
- `K6-02`: al reescanear el mismo QR, Pesaje permite operar y no presenta el
  final invalidado como vigente.
- `K6-03`: un nuevo final de la misma manga crea otro hecho; el anterior sigue
  consultable como histórico y existe como máximo un final `VIGENTE`.
- `K6-04`: recepción vigente, cierre parcial, Armado, actor sin permiso, versión
  obsoleta o reapertura repetida se rechazan sin mutación parcial.
- `K6-05`: repetir la misma clave devuelve la misma reapertura; otra clave sobre
  el mismo final devuelve conflicto.
- `K6-06`: Central diferencia visualmente `Reabrir manga` de `Anular pesaje` y
  explica que la primera conserva identidad/cupo mientras la segunda los termina.

## Dataset reproducible

Manga `M001`, un control neto `4.790 kg`, final accidental `8.950 kg`, tara
`0.030 kg`, objetivo teórico `12.000 kg`, sin recepción. Tras reabrir, el mismo
QR permite un control o final superior al último control persistido.

## Gates y riesgos

READY-FOR-DESIGN: cubierto por el hecho UAT, PMI-15 y límites anteriores.
UX-READY: pendiente; la observación fue funcional del responsable, no validación
representativa de todos los perfiles. Riesgo principal: una reapertura o retiro
de sticker equivocados puede mezclar una manga cerrada con otra abierta.

TS/DEV/UAT: [[TS-010K6_Reapertura_Auditada_de_Manga_por_Cierre_Accidental]],
[[DEV-010K6_Reapertura_Auditada_de_Manga_por_Cierre_Accidental]],
[[UAT_US-010K6_Reapertura_Auditada_de_Manga]].
