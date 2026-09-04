---
tipo: recibo-ejecucion-agentica
estado: publicado-con-uat-fisica-pendiente
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

## Evidencia UX y operativa

- **Dispositivo / viewport:** automatización local; estación física reporta `READY`, balanza conectada, impresora disponible y Central online.
- **Estados capturados:** despliegues `live`, esquema migrado, heartbeat posterior y paquete pilot.15 generado.
- **Comparación con wireflow:** pruebas automatizadas K2–K8 verdes; observación física aún pendiente.
- **Accesibilidad básica:** cubierta por las pruebas de componentes; no sustituye legibilidad real del sticker.
- **Validación humana realizada:** no para pilot.15; requiere operador y responsable UAT frente al hardware.

## Comprobaciones omitidas

| Comprobación | Motivo | Riesgo | Próximo responsable |
|---|---|---|---|
| Instalación de pilot.15 en PC de Balanza | La estación sigue activa en pilot.13 y no existe una ventana operativa confirmada en esta ejecución | Interrumpir una captura o impresión | Soporte con operador presente |
| Balanza, impresora, doble sticker y QR reales | Requiere hardware físico | Diferencias de puerto, papel, lectura o tamaño | Responsable UAT + operario |
| Reinicio y tarea programada | Solo después de instalar | Arranque no validado | Soporte de planta |

## Resultado

```yaml
spec_phase: approved
delivery_state: central_deployed_station_release_published
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
```

- **Riesgos restantes:** pilot.15 aún no está activo en la PC; la estación continúa reportando `1.2.0-pilot.13`.
- **Decisión humana pendiente:** confirmar ventana de actualización y ejecutar/firma de UAT física.
- **Observación productiva / marcha blanca:** pendiente.
- **Siguiente acción segura:** descargar el artefacto CI `envaperu-pesaje-1.2.0-pilot.15-win-x64`, ejecutar `Inspect-Station.ps1`, actualizar con respaldo automático y recorrer el smoke físico antes de producir.
