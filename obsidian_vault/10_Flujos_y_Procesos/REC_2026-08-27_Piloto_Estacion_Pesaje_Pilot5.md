---
tipo: recibo_ejecucion
estado: en_validacion
fecha: 2026-08-27
tags: [edge, pesaje, piloto, despliegue, rollback, uat]
relaciones:
  - "[[05_Especificaciones/02_Technical_Enablers/TE-004_Despliegue_Operativo_y_Observabilidad_Estacion_Pesaje|TE-004]]"
  - "[[05_Especificaciones/03_Tech_Specs/TS-TE-004_Despliegue_y_Comunicacion_Estacion_Pesaje|TS-TE-004]]"
  - "[[05_Especificaciones/04_Approved_for_Dev/DEV-TE-004_Actualizacion_Segura_Estacion_Edge|DEV-TE-004]]"
  - "[[10_Flujos_y_Procesos/UAT_TE-004_Actualizacion_Estacion_Edge|UAT TE-004]]"
---

# Recibo — despliegue piloto de estación de pesaje `1.2.0-pilot.5`

## Objetivo y alcance

- **Historia / DEV:** TE-004 / DEV-TE-004.
- **Porción vertical ejecutada:** adoptar la base SQLite híbrida existente, instalar un release versionado de la estación, conectar el heartbeat con Central, provisionar a Renato Peña Damián como operador de pesaje separado del maquinista y dejar contingencia reversible antes de la primera operación nueva.
- **Fuera de alcance respetado:** no se simuló ni ejecutó una lectura real de balanza, un escaneo QR, una impresión física, un pesaje SCM ni un reinicio de Windows.
- **Branch / worktree / commit estación:** `codex/pilot-k1-release-20260826`, worktree aislado `.codex-tmp/release-station-20260826`, commit `f3f64642d64fea8586f3bd3f18beb8fe99175533`.
- **Branch / commit Central:** `codex/pilot4-central-deploy-20260827`, commit desplegado `5740c5d07c7f9ecbd90b13038daaddb70318936d`.
- **Gate de entrada:** ventana sin producción, estación anterior detenida, base conciliada y backup verificado.
- **Gate solicitado:** despliegue técnico para UAT física; no `LISTO_PARA_PLANTA`.

## Cambios

| Archivo o componente | Motivo | Tipo |
|---|---|---|
| `release/Start-ActiveStation.ps1` | Preservar como un único argumento las rutas de Windows con espacios al iniciar en segundo plano. | producto |
| `backend/tests/test_release_windows_powershell.py` | Reproducir y bloquear la regresión con instalación bajo `Program Files` y un ID de estación con espacios. | prueba |
| Release inmutable `1.2.0-pilot.5` | Empaquetar el arreglo sin alterar `pilot.4`; SHA-256 externo `48b6304f98d4d03fdca9412805d200965f9e8e3b3ad33e107aa35cf0d9588023`. | producto |
| Central SCM | Publicar únicamente las capacidades liberadas para el piloto de mangas/pesaje; se mantuvieron fuera las capacidades futuras de materia prima y preparado. | producto |
| Rol `OPERADOR_PESAJE` para trabajador `TRB-000002` | Autorizar a Renato Peña Damián como operador de la estación sin reemplazar su rol principal ni confundirlo con el maquinista de la preetiqueta. | configuración |
| `Rollback-Pilot5-ToLegacy.ps1` | Recuperar la estación anterior solo si la conciliación demuestra que no existen hechos nuevos desde el corte. | soporte |

## Verificaciones ejecutadas

| Comando / revisión | Resultado | Evidencia | Interpretación |
|---|---|---|---|
| TDD del iniciador Windows | PASS | La prueba falló antes del arreglo y pasó después. | La causa observada en la PC quedó reproducida y cubierta. |
| Regresión de release edge | PASS | 63 pruebas aprobadas. | Stage, actualización, rollback, trazabilidad y control de estación permanecen verdes. |
| Backend Central enfocado | PASS | 50 pruebas aprobadas. | Contrato de capacidades, mangas y pesaje cubierto. |
| Backend Central completo | PASS con incidencia de invocación | 439 pruebas aprobadas; dos casos fallaron solo por ruta de ejecución y pasaron al reejecutarse por su ruta exacta. | No quedó un fallo funcional reproducible del incremento. |
| Migración productiva Central | PASS | Revisión Alembic `f89d4e6a8c53`; tablas de continuidad presentes. | El esquema aditivo quedó aplicado. |
| Construcción y verificación del ZIP | PASS | Manifiesto interno verificado; `source_revision=f3f64642...`; SHA de transferencia idéntico al publicado. | El paquete recibido por la estación corresponde al código probado. |
| Actualizador en estación | PASS | `PILOT_CONFIG_READY`, `CENTRAL_ONLINE`, `STATION_TASK_READY` y `UPDATE_COMPLETE version=1.2.0-pilot.5`. | La activación técnica terminó sin rollback automático. |
| Readiness posterior | PASS | `status=READY`, `app_version=1.2.0-pilot.5`, `central.state=ONLINE`, `issues=[]`. | Runtime local y enlace de arranque con Central saludables. |
| Conciliación SQLite posterior | PASS | `integrity=ok`; 16 104 pesajes; máximo ID 16 127; 4 535 intentos históricos; 27 correcciones; 0 impresiones pendientes; 0 impresiones SCM nuevas. | La actualización no alteró hechos operativos ni generó impresiones. |
| Contingencia | PASS de precondiciones, no ejecutada | Evidencia, baseline, archivo SQLite original, launcher legacy y SHA del script presentes. | El rollback está preparado, pero ejecutarlo sin incidente sería destructivo e invalidaría la activación. |

## Evidencia UX y operativa

- **Dispositivo / viewport:** PC Windows 10 de la estación; UI servida en `http://127.0.0.1:5050`.
- **Información primaria:** preetiqueta escaneada, peso estable y resultado del registro.
- **Acción primaria:** capturar peso y emitir el par de stickers autorizado.
- **Estados comprobados:** arranque, `READY`, Central `ONLINE` y recuperación técnica ante fallo previo de arranque.
- **Estados físicos pendientes:** lectura estable desde COM4, QR + Enter, impresión TSC TE200, legibilidad de ambos stickers y reinicio de Windows.
- **Validación humana realizada:** autorización del corte y elección de Renato como operador; falta validación del recorrido físico por el usuario en la estación.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Lectura real de balanza | Requiere acceso físico y una carga representativa. | Puerto o formato serial incompatibles bajo operación real. | Usuario en estación de pesaje. |
| Escaneo QR + Enter | Requiere el lector conectado al puesto. | Foco o terminador del escáner no aceptado por la UI. | Usuario en estación de pesaje. |
| Impresión física duplicada | No se enviaron bytes a la impresora durante el despliegue. | Cola, driver, tamaño, QR o duplicado físico incorrectos. | Usuario en estación de pesaje. |
| Reinicio de Windows | Se evitó interrumpir el acceso remoto antes de la UAT. | La tarea registrada aún no se validó durante un inicio de sesión real. | Soporte con usuario en planta. |
| `npm audit fix --force` | El build reportó 6 avisos de dependencias; aplicar cambios disruptivos no pertenece al hotfix de arranque. | Deuda de dependencias por clasificar en incremento separado. | Equipo de desarrollo. |

## Resultado

```yaml
spec_phase: approved
delivery_state: deployed
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** periféricos y ergonomía del flujo no validados físicamente; reinicio pendiente; deuda de dependencias por clasificar.
- **Decisión humana pendiente:** aceptar o rechazar la UAT física de balanza, QR, impresión duplicada y reinicio.
- **Observación productiva / marcha blanca:** pendiente; no se generaron hechos SCM nuevos durante el despliegue.
- **Rollback:** antes del primer hecho nuevo puede usarse la contingencia pilot.5→legacy. Después de cualquier pesaje, impresión, acuse o corrección nueva, el script debe rechazar la restauración y se requiere conciliación hacia adelante.
- **Siguiente acción segura:** ejecutar UAT-EDGE-02 pasos 5–7 y UAT-EDGE-04 con una muestra controlada; solo después actualizar los ejes de validación.
