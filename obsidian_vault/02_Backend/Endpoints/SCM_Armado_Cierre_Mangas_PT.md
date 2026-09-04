---
tipo: endpoints
estado: implementado-local
tech_spec: "[[TS-010F_Armado_Genealogia_Mangas_PT_y_Cierre_Armado]]"
fecha_actualizacion: 2026-08-29
relaciones:
  - "[[TS-010F3_Ruta_WIP_OA_Excepcional_y_Consumo_en_Linea]]"
  - "[[DEV-010F3_Ruta_WIP_OA_Excepcional_y_Consumo_en_Linea]]"
---

# SCM — Armado, mangas PT y genealogía

Todos los comandos reciben `X-Actor-Id`; los comandos mutables también
requieren `Idempotency-Key`.

| Método | Ruta | Capacidad | Resultado |
|---|---|---|---|
| `POST` | `/api/scm/v1/ordenes-armado/excepcionales` | `OA_EXCEPCIONAL_CREAR` | Crea una OA `BORRADOR` de reposición WIP, sin OP padre, con motivo e idempotencia. |
| `GET` | `/api/scm/v1/ordenes-armado/{id}/plan-mangas` | `PLAN_MANGA_VER` | Plan activo o `null`. |
| `POST` | `/api/scm/v1/ordenes-armado/{id}/plan-mangas/recalcular` | `ENSAMBLE_PLANIFICAR` | Congela perfil, capacidad, peso y revisión. |
| `POST` | `/api/scm/v1/ots/{id}/mangas-salida` | `ENSAMBLE_PLANIFICAR` | Materializa la cuota de la OT como mangas PT/WIP. |
| `POST` | `/api/scm/v1/mangas/{id}/cerrar-armado` | `ENSAMBLE_MANGA_CERRAR` | Consume orígenes exactos y acredita unidades en una transacción. |
| `GET` | `/api/scm/v1/mangas/{id}/genealogia` | `GENEALOGIA_VER` | Confirmación y mangas de componentes consumidas. |
| `POST` | `/api/scm/v1/abastecimiento/{id}/fuentes-no-exactas` | `GENEALOGIA_CANDIDATA_CONFIRMAR` o `GENEALOGIA_LEGACY_APERTURA` | Abre y reserva una fuente excepcional auditada. |
| `POST` | `/api/scm/v1/mangas/{id}/correcciones-cantidad` | `ENSAMBLE_CORREGIR_SOLICITAR` | Solicita corrección sin editar el cierre. |
| `POST` | `/api/scm/v1/correcciones-armado/{id}/aprobar` | `ENSAMBLE_CORREGIR_APROBAR` | Aplica el delta compensatorio con cuatro ojos. |

`OA_EXCEPCIONAL_CREAR` se incorpora al catálogo mediante migración, pero el
incremento no la asigna a ningún rol. La propuesta para Jefe de Producción
continúa pendiente de confirmación humana; el seed general tampoco debe
concederla por herencia a Gerente General.

## OA excepcional de reposición WIP

```json
{
  "origen_demanda": "REPOSICION_WIP",
  "motivo": "Reposición técnica gobernada",
  "articulo_salida_id": "uuid-wip",
  "operacion_ruta_revision_id": "uuid-operacion",
  "estructura_revision_id": "uuid-estructura",
  "cantidad_objetivo": 20
}
```

El actor se obtiene del contexto autenticado. `Idempotency-Key` es obligatorio:
un replay exacto devuelve la OA previa y reutilizar la clave con otro contenido
responde `IDEMPOTENCY_CONFLICT`. La creación no reserva, consume, planifica
mangas ni acredita inventario. La liberación permanece como comando separado y
revalida WIP, BOM, ruta y operación aprobados.

La OA excepcional no exige `orden_produccion_id` y no crea una OP o un Producto
Terminado implícitos. La API rechaza motivo vacío, objetivo que no sea WIP,
ingeniería incompleta y ausencia de capacidad server-side.

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

### Reserva y saldo de producción en línea

En modo `CONCURRENTE_ENTRE_CICLOS`, la OT de Armado referencia el
`TrabajoColor` exacto que aporta la pieza fresca. Central crea o resuelve una
reserva de `SaldoWIPSalida` con uno de estos modos mutuamente excluyentes:

- `SALDO_EXISTENTE`: las unidades buenas ya fueron acreditadas;
- `CREDITO_EN_LINEA_PENDIENTE`: el cierre acreditará la producción buena y la
  consumirá inmediatamente como `CONSUMO_EN_LINEA_ARMADO`.

La estación o el cliente no eligen el modo. El saldo mantiene:

```text
disponible = acreditado - reservado - consumido
disponible >= 0
```

No se crea una manga, recepción o movimiento de Kardex intermedios para la
pieza fresca.

### Cierre atómico concurrente

El cierre bloquea manga, OA, OT de Armado, TrabajoColor, salida fresca,
reservas y componentes previos. En una sola transacción:

1. valida estado, versiones, responsable, BOM y cantidad real;
2. acredita la salida fresca si la reserva estaba en crédito pendiente;
3. consume esa salida como producción en línea;
4. consume los componentes previos reservados;
5. acredita exactamente un lote/manga WIP;
6. actualiza las proyecciones de OT/OA;
7. deja la manga `CERRADA_ARMADO_PENDIENTE_PESAJE`.

Un fallo revierte todos los efectos. El replay exacto no duplica producción,
consumo, WIP ni manga.

Mientras exista una reserva `CREDITO_EN_LINEA_PENDIENTE` sin sincronizar o
anular, el cierre de la OF/Trabajo que aporta esa salida queda bloqueado. Al
resolver la reserva, el cierre vuelve a evaluar su balance; nunca acepta
producción tardía oculta.

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
`cantidad_editable = false`. Para WIP concurrente también devuelve el artículo
WIP, la OF/OA/OT relacionadas y las atribuciones estándar marcadas como
derivadas. La estación captura solamente el peso físico del conjunto.
