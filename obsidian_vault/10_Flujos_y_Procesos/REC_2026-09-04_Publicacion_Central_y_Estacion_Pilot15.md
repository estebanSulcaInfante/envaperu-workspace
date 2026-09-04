---
tipo: recibo-ejecucion-agentica
estado: desplegado-con-uat-fisica-pendiente
tags: [scm, pesaje, despliegue, render, supabase, pilot15, uat]
fecha: 2026-09-04
---

# REC-2026-09-04: Publicación de Central y estación de pesaje pilot.15

## Objetivo y alcance

- **Historia / DEV:** conjunto integrado K2–K8 y M4 del piloto de pesaje en kg.
- **Porción vertical ejecutada:** integrar ramas operativas, migrar Supabase, desplegar API y frontend Central, y publicar un paquete offline trazable para Balanza.
- **Fuera de alcance respetado:** instalar durante una sesión productiva, validar hardware sin operador presente, conciliar consumo/retorno de Armado y declarar salida a producción.
- **Branch / worktree / commit:** API `cc6899857d4c5c532c71eb9eae78a36d50000539`; Central `01193e16da287c12affb5b885566350cd7cb117b`; Balanza `9d0992c0ed72e275dba92a6cb8d34332ef654ee7`.
- **Gate de entrada:** solicitud explícita de publicar para pruebas directas en Central y Balanza.
- **Gate solicitado:** despliegue técnico y preparación de UAT física; no habilitación productiva.

## Cambios

| Archivo o componente | Motivo | Tipo |
|---|---|---|
| API Central y migraciones `f91`–`f93` | Habilitar avances repetibles en kg y reapertura auditada con línea base | Producto / datos |
| Frontend Central | Publicar jerarquía OT/color, asignación visible en kg, anulaciones y reapertura | Producto |
| Estación `1.2.0-pilot.15` | Publicar escaneo de un solo uso, contexto kg y flujo de cierre/reapertura | Producto |
| Constructor de release | Admitir Python 3.12 provisto por `setup-python` en CI sin relajar la versión aprobada | Infraestructura / prueba |

## Verificaciones ejecutadas

| Comando / revisión | Resultado | Evidencia | Interpretación |
|---|---|---|---|
| Backend Central completo | `521 passed`, `2 skipped`, `29 deselected` | pytest local de integración | Sin fallas en el perfil aplicable |
| Frontend Central completo | `514 passed` | Vitest local de integración | Sin regresiones conocidas |
| Build Central | correcto | Vite; advertencia no bloqueante de tamaño de chunk | Artefacto desplegable |
| Auditoría runtime Central | 0 vulnerabilidades | `npm audit --omit=dev` | Dependencias servidas sin alertas reportadas |
| Backend Balanza | `190 passed` | pytest local | Servicios y adaptadores verdes |
| Frontend Balanza | `76 passed` | Vitest local | Flujo físico simulado verde |
| Workflows Balanza pilot.15 | pruebas y release `success` | GitHub Actions `33891503268` y `33891503297` | Paquete oficial generado por CI |
| Supabase | head `f93d4e6a8c02`; 2 índices parciales; 2 checks; 2 roles | verificación SQL posterior | Esquema y permisos alineados |
| Render API | deploy `dep-dadea0afngtc73b2m5bg` `live`; `/api/health` = `ok` | Render y smoke HTTPS | API operativa |
| Render Central | deploy `dep-dadecgukb8uc73966k60` `live`; HTTP 200 | Render y smoke HTTPS | UI publicada |
| Compatibilidad estación existente | heartbeat y progreso HTTP 200 desde `pilot.13` | logs posteriores al deploy | El cambio Central no desconectó la estación activa |
| Preflight PC de Balanza | `VERSIONED`; activo `pilot.13`; configuración física válida; SQLite `quick_check=ok`; sin emisiones SCM inciertas | `C:\Soporte\Pilot15\diagnostico-pre-pilot15.json` y revisión local por SSH | Estación apta para actualización versionada |
| Integridad del paquete en estación | SHA-256 `f4807ef0a20a8e45cff32b10c06ac4615a5d4143e1b4ab4f89542394259defd2` coincidente | ZIP y sidecar CI copiados a `C:\Soporte\Pilot15\artifact` | Paquete oficial íntegro antes de instalar |
| Actualización transaccional | `UPDATE_COMPLETE version=1.2.0-pilot.15`; anterior `pilot.13` | `Update-Station.ps1` en `PESAJE-PLANTA-01` | Release activado con rollback disponible |
| Base local posterior | `quick_check=ok`; schema `v10`; `17 139` pesajes; `43` intentos SCM preservados | SQLite autoritativa en `ProgramData` | Historial disponible después de migrar |
| Smoke técnico de estación | `LIVE`, `READY`, identidad esperada, Central `ONLINE`, sin issues | endpoints locales y `station_control.py identity` | Runtime nuevo saludable |
| Heartbeat posterior | `pilot.15`; proceso/base `READY`; balanza `CONNECTED_LISTENING`; Central `ONLINE`; sin error | `estacion_estado_actual` a las `2026-09-04 16:36:30 UTC` | Central observa el release y la balanza real |
| Impresora sin emisión | `TSC TE200` detectada por Windows; driver presente; monitor aún `NO_VERIFICADO` | `Get-Printer`; no se envió trabajo RAW | Instalación preservada; falta prueba física deliberada |

## Evidencia UX y operativa

- **Dispositivo / viewport:** estación física `PESAJE-PLANTA-01`; release `1.2.0-pilot.15` instalado por SSH en la ventana confirmada por el usuario.
- **Estados capturados:** preflight `VERSIONED`, actualización completa, `LIVE/READY`, balanza real `COM4/9600` conectada y escuchando, impresora `TSC TE200` detectada y heartbeat Central posterior.
- **Comparación con wireflow:** pruebas automatizadas K2–K8 verdes; observación física aún pendiente.
- **Accesibilidad básica:** cubierta por las pruebas de componentes; no sustituye legibilidad real del sticker.
- **Validación humana realizada:** no para pilot.15; requiere operador y responsable UAT frente al hardware.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Balanza, impresora, doble sticker y QR reales | Requiere hardware físico | Diferencias de puerto, papel, lectura o tamaño | Responsable UAT + operario |
| Reinicio y tarea programada | Solo después de instalar | Arranque no validado | Soporte de planta |

## Resultado

```yaml
spec_phase: approved
delivery_state: central_and_station_deployed_uat_pending
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** la impresora permanece `NO_VERIFICADO` hasta una emisión física; no se ha probado todavía doble sticker, lectura QR ni reinicio. Dos trabajos generados el 3 de septiembre permanecen `PENDING` en Central y no fueron eliminados ni reclamados durante la actualización.
- **Decisión humana pendiente:** ejecutar y firmar la UAT física antes de habilitar uso productivo.
- **Observación productiva / marcha blanca:** pendiente.
- **Siguiente acción segura:** refrescar la UI local, verificar lectura estable de balanza y ejecutar una impresión/escaneo controlados antes de producir; después validar el reinicio y la tarea programada.

## Incidencia operativa observada durante la ventana

`station_control.py stop` no encontró el evento de parada porque el runtime activo
había quedado huérfano en otra sesión de Windows, aunque seguía escuchando en
`127.0.0.1:5050`. Se identificó el PID exacto y se comprobó que su línea de comando
correspondía a `pilot.13`; después de `pragma quick_check=ok` y de confirmar que no
existían emisiones pendientes o inciertas locales, se detuvo únicamente ese listener.
El segundo `Inspect-Station.ps1` devolvió `ready_for_update: true` sin hallazgos.
Esta condición debe considerarse en una mejora futura del mecanismo de parada remota.
