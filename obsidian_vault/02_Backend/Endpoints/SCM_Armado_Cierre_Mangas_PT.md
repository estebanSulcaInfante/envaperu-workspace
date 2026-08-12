---
tipo: endpoints
estado: implementado-local
tech_spec: "[[TS-010F_Armado_Genealogia_Mangas_PT_y_Cierre_Armado]]"
fecha_actualizacion: 2026-08-03
---

# SCM — Armado, mangas PT y genealogía

Todos los comandos reciben `X-Actor-Id`; los comandos mutables también
requieren `Idempotency-Key`.

| Método | Ruta | Capacidad | Resultado |
|---|---|---|---|
| `GET` | `/api/scm/v1/ordenes-armado/{id}/plan-mangas` | `PLAN_MANGA_VER` | Plan activo o `null`. |
| `POST` | `/api/scm/v1/ordenes-armado/{id}/plan-mangas/recalcular` | `ENSAMBLE_PLANIFICAR` | Congela perfil, capacidad, peso y revisión. |
| `POST` | `/api/scm/v1/ots/{id}/mangas-salida` | `ENSAMBLE_PLANIFICAR` | Materializa la cuota de la OT como mangas PT/WIP. |
| `POST` | `/api/scm/v1/mangas/{id}/cerrar-armado` | `ENSAMBLE_MANGA_CERRAR` | Consume orígenes exactos y acredita unidades en una transacción. |
| `GET` | `/api/scm/v1/mangas/{id}/genealogia` | `GENEALOGIA_VER` | Confirmación y mangas de componentes consumidas. |
| `POST` | `/api/scm/v1/abastecimiento/{id}/fuentes-no-exactas` | `GENEALOGIA_CANDIDATA_CONFIRMAR` o `GENEALOGIA_LEGACY_APERTURA` | Abre y reserva una fuente excepcional auditada. |
| `POST` | `/api/scm/v1/mangas/{id}/correcciones-cantidad` | `ENSAMBLE_CORREGIR_SOLICITAR` | Solicita corrección sin editar el cierre. |
| `POST` | `/api/scm/v1/correcciones-armado/{id}/aprobar` | `ENSAMBLE_CORREGIR_APROBAR` | Aplica el delta compensatorio con cuatro ojos. |

## Cerrar manga

```json
{
  "version": 2,
  "cantidad_real": 98,
  "motivo_diferencia": "Faltaron dos unidades conformes"
}
```

`motivo_diferencia` solo es obligatorio cuando la cantidad real difiere de la
planificada. La operación exige OT iniciada, actor responsable y solicitud de
abastecimiento recibida. El resultado queda pendiente de pesaje; todavía no
nace una existencia PT en Kardex.

## Fuentes no exactas

`CONJUNTO_CANDIDATOS` recibe dos o más códigos de manga, conserva el conjunto
N:M y nunca reparte cantidades por candidato. `LEGACY_SIN_ORIGEN` recibe un
conteo inicial, ubicación y motivo. Ambas fuentes participan en reserva,
traslado y consumo, pero la genealogía informa su certeza real.

## Correcciones

La solicitud conserva la cantidad original. La aprobación exige otro actor y
genera consumos o restituciones compensatorias. Solo opera antes del pesaje;
si la manga ya avanzó, responde que se requiere custodia física coordinada.

## Contrato con Balanza

Al resolver el QR de una manga cerrada por Armado, la API devuelve la cantidad
confirmada con `cantidad_fuente = RESPONSABLE_ARMADO` y
`cantidad_editable = false`. La estación captura solamente el peso.
