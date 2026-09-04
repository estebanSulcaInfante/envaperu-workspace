---
tipo: recibo_ejecucion
estado: implementado-local-qa-green
fecha: 2026-08-31
historia: "[[US-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
dev: "[[DEV-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
tags: [recibo, scm, pesaje, avance-kg, ui, qa]
---

# REC 2026-08-31 — control de avance en kg y contexto visible

## Objetivo y alcance

- **Porción ejecutada:** control repetible `AVANCE_KG` sin conteo que conserva
  manga, tramo y Trabajo activos; contrato/impresión; botón único, checkbox,
  foco QR, código dominante, anuncio de cambio y foto opcional.
- **Fuera de alcance respetado:** despliegue, migración productiva, operación
  offline, validación humana, UAT física y corrección destructiva de hechos
  anteriores.
- **Branch/commit:** worktree compartido con cambios previos del usuario; no se
  creó commit ni se modificaron archivos ajenos al incremento.
- **Gate:** implementación local y QA; no habilitación en planta.

## BASELINE → RED → GREEN → REFACTOR

- Baseline: el control ordinario salía como `CORTE_TURNO`, exigía conteo,
  cerraba el tramo y dejaba `CONTINUIDAD_PENDIENTE`.
- RED: pruebas demostraron rechazo de `control_type`, ausencia de migración,
  firma local dependiente del conteo y UI con acción separada/sin foto.
- GREEN: migración `f91b2d4e6c83`, modelo 1:N, servicio Central, coordinador
  local, renderer `CONTROL_PESO_TSPL_2` y UI K3.
- REFACTOR: compatibilidad `control_peso` K1/K2, capacidad versionada,
  recuperación idempotente antes de volver a leer la balanza y demo aislada
  alineada al contrato productivo.

## Cambios principales

| Componente | Resultado |
|---|---|
| Central / migración | `AVANCE_KG`, conteo nullable con check condicional, controles repetibles por tramo e índice parcial para `CORTE_TURNO`. |
| Central / dominio | Avance valida peso/tara/monotonicidad, guarda kg/aporte, no pausa ni acredita producción/inventario y emite evento/job. |
| Resolución QR | Capacidad `can_register_weight_control` e `imagen_path` opcional para pieza-color/PT. |
| Estación backend | Envía `control_type=AVANCE_KG` sin conteo/motivo; replay evita otra lectura e impresión duplicada. |
| Sticker | Neto y aporte, `AVANCE EN KG · SIN CONTEO`, sin estándar ni QR, dos columnas y `PRINT 1,1`. |
| Estación UI | Checkbox + `Pesar manga (F2)`, foco automático, correlativo grande, anuncio contextual, foto/fallback y bloqueo hasta superar el último control. |
| Demo local | Simula el mismo control sin tocar Central/hardware y permite la UAT remota inicial. |
| Vault | Decisión, US, prototipo, TS, DEV, UAT y este recibo. |

## Verificaciones ejecutadas

| Comando/revisión | Resultado | Interpretación |
|---|---|---|
| Central: servicio, migraciones K1/K2/K3 y contrato de monitoreo | `51 passed`, 40 warnings SQLAlchemy ya existentes. | Regresión focal Central verde. |
| `scripts/test.ps1 -Component pesaje` | `140 passed`. | Backend completo de estación verde. |
| `npm test -- --run` en estación | `44 passed` en 10 archivos. | Flujo, foco, contexto, foto y acción única verdes. |
| `npm run build` en estación | Build Vite exitoso, 135 módulos. | Bundle generable. |
| `scripts/test-contracts.ps1` | Provider `1 passed`; consumer `2 passed`; copias coinciden. | Compatibilidad Central–estación verde. |
| `flask --app app db heads` | `f91b2d4e6c83 (head)`. | Una cabeza Alembic. |
| Migraciones PostgreSQL | `18 skipped`: falta `TEST_DATABASE_URL` local aislada. | No sustituye el smoke PostgreSQL previo a desplegar. |
| Browser local aislado | QR resuelto, control `10.000 kg`, foco volvió al input; botón deshabilitado hasta agregar peso; sticker sin QR visible. | Evidencia visual/semántica local verde; no es UAT física. |

## Evidencia UX y operativa

- **Viewport observado:** navegador local de Codex, aproximadamente
  `1150 × 700`; no representa aún la resolución de planta.
- **Estados capturados:** QR resuelto, código `MANGA ACTIVA` dominante, foto
  ausente con fallback, avance aceptado, sticker 2-up y espera de más peso.
- **Accesibilidad básica:** anuncio `aria-live`; input QR recupera foco; botón y
  checkbox tienen nombre accesible; texto acompaña color.
- **Validación humana:** no realizada. La ejecución fue automatizada/simulada.

## Comprobaciones omitidas y riesgos

| Comprobación | Motivo | Riesgo / siguiente responsable |
|---|---|---|
| Upgrade/downgrade en PostgreSQL aislado | No hay `TEST_DATABASE_URL`. | Ejecutar smoke de migración antes de publicar Central. |
| Balanza, lector y TSC reales | No fue solicitado desplegar y falta ventana física. | Operador/supervisor ejecutan [[UAT_US-010K3_Control_Avance_Kg_y_Contexto_Visible]]. |
| Foto real con nombres largos | Dataset demo no contiene foto de pieza. | Probar una pieza con imagen y otra sin imagen en estación real. |
| Cambio físico entre dos mangas | Demo pública posee una sola manga; prueba de componente cubre el anuncio. | Grabar secuencia real M001 → M002 sin mouse. |
| Fallo de spooler/emisión incierta | Requiere procedimiento/equipo representativo. | Ejecutar perfil IMP/CON antes de retirar la restricción. |

## Resultado

```yaml
spec_phase: approved
delivery_state: implemented
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

No se desplegó. La siguiente acción segura es ejecutar el smoke PostgreSQL,
publicar mediante el pipeline autorizado y completar la UAT física con el
operador; ninguna prueba automática declara el flujo listo para planta.

