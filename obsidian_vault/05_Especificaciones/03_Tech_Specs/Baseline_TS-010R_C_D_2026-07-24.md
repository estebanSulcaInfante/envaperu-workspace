---
tipo: baseline-tecnica
estado: verde
tags: [baseline, tdd, backend, frontend, pesaje, postgresql, US-010R, US-010C, US-010D]
relaciones:
  - "[[TS-010R_Articulos_BOM_Rutas_WIP_y_Perfiles_Empaque]]"
  - "[[TS-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje]]"
  - "[[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-07-24
---

# Baseline TS-010R/C/D — 2026-07-24

Línea base cerrada antes de implementar artículos, BOM, rutas, mangas o pesaje SCM. Durante el cierre se corrigieron defectos del arnés de migraciones y un drift entre el modelo ORM y la migración actual; no se agregaron modelos de negocio R/C/D ni se tocó la base desplegada.

## Resultado

| Componente | Comando | Resultado |
|---|---|---|
| Backend central rápido | `scripts/test.ps1 -Component backend` | `213 passed`, `1 skipped`, `11 deselected`; verde |
| Frontend central | `scripts/test.ps1 -Component frontend` | `90 passed`; verde con `--maxWorkers=2` incorporado al runner |
| Backend estación | `scripts/test.ps1 -Component pesaje` | `90 passed`; verde |
| Frontend estación | `npm test` | `14 passed`; verde |
| Build frontend central | `npm run build` | verde; 1127 módulos; advertencia por chunk de 1,152.01 kB |
| Build frontend estación | `npm run build` | verde; 127 módulos |
| E2E aislado legacy | `scripts/test-sync-e2e.ps1` | verde; `12.5 kg` llegó a central y fue acusado localmente |
| Backend PostgreSQL | `pytest -m postgres` sobre `postgres:16-alpine` | `9 passed`, `1 skipped`; verde |

## Estabilización del frontend central

Cuatro pruebas de UI alcanzaban el timeout de 5 segundos al competir con el paralelismo automático. Aisladas pasaron `11/11`, y la suite completa pasó `90/90` con `--maxWorkers=2`. Por tanto:

- no existe un fallo funcional reproducible en esos cuatro escenarios;
- `scripts/test.ps1` fija dos workers como configuración canónica y reproducible en Windows;
- volver al paralelismo automático requerirá una medición explícita en CI.

## Incidencias de entorno descartadas

Las primeras ejecuciones dentro del sandbox produjeron:

- `esbuild` sin permiso para resolver `vite.config.js`;
- `pytest` de estación sin permiso sobre `%TEMP%\pytest-of-esteb`.

Al ejecutar con acceso normal del usuario:

- backend estación pasó `90/90`;
- frontend estación pasó `14/14`;
- ambos builds pasaron;
- el frontend central reprodujo cuatro timeouts/interferencias con paralelismo automático, pero pasó completo con dos workers.

Por tanto, los errores de permisos no forman parte de la baseline del producto.

## Correcciones de baseline PostgreSQL

Docker Desktop `29.6.2` levantó `postgres:16-alpine`, el contenedor quedó healthy y fue retirado junto con su volumen al finalizar.

Se corrigieron tres causas detectadas por la primera ejecución:

1. El arnés ahora diferencia el `head` actual `b7e9f1a4d510` del objetivo histórico de adopción `c42d8e6f1a03`.
2. La prueba de base nueva reconoce todos los correlativos sembrados por el `head` actual.
3. `d7e9a4c2f105` trata explícitamente la ausencia de `snapshot_composicion_molde` en instalaciones parciales.
4. El modelo ORM declara el índice `ix_lote_salida_pieza_color_sku` ya creado por la migración, eliminando el drift de `flask db check`.

Después de estas correcciones, las nueve pruebas PostgreSQL pasan y el chequeo de drift queda verde.

## Decisión de pipeline

- La baseline funcional queda **verde** en suites rápidas, PostgreSQL, builds y E2E.
- El desarrollo R-core puede iniciar cuando su TS reciba aprobación explícita.
- C y D todavía requieren la validación operativa/hardware indicada en sus gates.
- Los roles y capacidades se sembrarán idempotentemente, pero la asignación `trabajador_rol` se reserva para el UAT final.
