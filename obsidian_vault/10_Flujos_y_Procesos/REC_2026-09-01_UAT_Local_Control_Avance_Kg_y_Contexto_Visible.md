---
tipo: recibo_ejecucion
estado: uat-local-simulada-verde
fecha: 2026-09-01
historia: "[[US-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
dev: "[[DEV-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
uat: "[[UAT_US-010K3_Control_Avance_Kg_y_Contexto_Visible]]"
run_id: UAT-US-010K3-RUN-LOCAL-20260901-01
tags: [recibo, uat, scm, pesaje, avance-kg, local, simulacion]
---

# REC 2026-09-01 — UAT local de avance en kg y contexto visible

## Objetivo y alcance

- **Historia / DEV:** US/DEV-010K3.
- **Porción vertical ejecutada:** preparar una OP/OF/OT y dos mangas en la base
  UAT aislada; imprimir preetiquetas en simulación; recorrer dos avances en kg,
  cambio de manga y cierre final.
- **Fuera de alcance respetado:** producción, despliegue, balanza, lector QR,
  impresora y papel reales, recepción en almacén y aceptación humana.
- **Branch / worktree / commit:** worktree compartido y sucio; no se creó
  commit ni se alteraron cambios ajenos.
- **Gate de entrada:** implementación local `qa_green` con UAT preparada.
- **Gate solicitado:** UAT local simulada, no habilitación en planta.

## Cambios

| Archivo o componente | Motivo | Tipo |
|---|---|---|
| `backend/app/services/scm_uat_walkthrough_seed_service.py` | Alinear la guardia de seed con el head Alembic `f91b2d4e6c83`. | prueba/infra local |
| `backend/app/services/scm_demo_seed_service.py` | Evitar la misma obsolescencia en el seed demo. | prueba/infra local |
| `backend/tests/scm/test_scm_migrations_postgres.py` | Alinear la aserción de cabeza canónica. | prueba |
| `UAT_US-010K3_Control_Avance_Kg_y_Contexto_Visible.md` | Registrar el run y sus pendientes. | documento |

## Verificaciones ejecutadas

| Comando / revisión | Resultado | Evidencia | Interpretación |
|---|---|---|---|
| Reset y arranque de `jarra-real-6l-pesaje-piezas` | `RESET OK`; Central, frontend y estación disponibles. | Base `enva_uat_recorrido` y estado local del escenario. | Preparación reproducible y segregada de producción. |
| Creación del recorrido | `OP-000001`, `OF-000001`, `OT-000001`, Trabajo `TC01`, mangas `M001/M002`. | Respuestas de Central y preetiquetas `IMPRESA` en simulación. | Dos identidades válidas para la secuencia. |
| Control 1 | NET `4.800`, aporte `4.800`, conteo nulo. | Fila `AVANCE_KG`; sticker `CONTROL_PESO` `IMPRESA`. | No cerró manga ni acreditó producción/inventario. |
| Control 2 | NET `8.950`, aporte `4.150`, conteo nulo. | Segunda fila `AVANCE_KG` en la misma manga/tramo. | Avance repetible y no aditivo. |
| Cambio de QR | `M001 → M002 → M001` anunciado y código dominante actualizado. | Estado semántico y captura del viewport local. | El contexto activo resulta inequívoco en simulación. |
| Cierre final | NET `12.000`, aporte final `3.050`, `50.000` un. | Manga `PENDIENTE_RECEPCION_ALMACEN`; M002 sigue `PREETIQUETADA`. | Solo el cierre acreditó el plan confirmado. |
| Central focal | `2 passed`, una advertencia SQLAlchemy preexistente. | K3 de servicio + migración SQLite. | Regla de dominio y esquema verdes. |
| Backend estación | `11 passed`. | `tests/test_scm_weighing.py`. | Coordinación, reintento e impresión local verdes. |
| Frontend estación | `11 passed`. | `ScmWeighing.test.jsx`. | Acción única, foco, contexto y simulación verdes. |
| Revisión de logs | Sin `traceback`, `exception`, `error`, `failed` ni HTTP 500. | Logs del runtime UAT local. | Sin error técnico observado durante el run. |

## Evidencia UX y operativa

- **Dispositivo / viewport:** navegador integrado local, aproximadamente
  `1150 × 700`; no representa todavía el monitor de Pesaje.
- **Estados capturados:** M001 resuelta, código dominante, artículo, fallback
  sin foto, avance abierto, bloqueo sin aumento, segundo avance, anuncio de
  cambio, regreso a M001 y cierre final.
- **Comparación con wireflow:** la secuencia principal coincide; la variante
  con foto presente no pudo comprobarse porque el dataset no contiene imagen.
- **Accesibilidad básica:** cambio anunciado por texto, QR recupera foco y las
  acciones tienen nombre accesible.
- **Validación humana realizada:** no; ejecución automatizada/simulada.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Pieza con foto real | Dataset local sin imagen. | Validar legibilidad y recorte. | Operador + responsable UX. |
| Balanza, lector y TSC/papel reales | UAT solicitada fue local. | Integración física, estabilidad y márgenes no demostrados. | Operador/supervisor. |
| Doble F2 y QR en papel | Requieren periféricos representativos. | Duplicado o lectura difícil. | Operador/supervisor. |
| Caída de Central y spooler | No se inyectaron fallos en este run. | Recuperación operativa pendiente. | QA/UAT física. |
| Observación sin ayuda | No participó trabajador representativo. | Usabilidad en planta no aceptada. | Responsable de UAT. |

## Resultado

```yaml
spec_phase: approved
delivery_state: implemented
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** periféricos, postura/viewport, foto real, QR en papel,
  spooler y recuperación ante pérdida de conexión.
- **Decisión humana pendiente:** aceptar o rechazar UX y UAT física.
- **Observación productiva / marcha blanca:** pendiente.
- **Siguiente acción segura:** repetir el mismo guion en la PC de Pesaje con
  una manga dedicada, foto real, operador representativo y periféricos reales.
