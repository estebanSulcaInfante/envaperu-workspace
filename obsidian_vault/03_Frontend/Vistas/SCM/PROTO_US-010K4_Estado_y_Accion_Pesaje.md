---
tipo: prototipo-operativo
ux_validation: provisional
release_constraint: no_habilitar_en_planta
fecha: 2026-09-02
---

# PROTO K4 — Estado y acción de Pesaje

Información primaria: manga seleccionada, lectura y efecto de F2. Código
seleccionado no implica manga abierta: sustituir `MANGA ACTIVA` por
`MANGA SELECCIONADA`, con estado explícito. Pieza/color/persona contextualizan.
No inventar distancias ni resolución de la estación: QA visual local 1366×768
y vista estrecha si el navegador permite ajustar; hardware real en UAT.

Secuencia: escanear → reconocer manga/estado → revisar peso → elegir control
si continúa abierta → un botón/F2 → resultado o recuperación.

Junto al botón, bloque con texto además del color:

| Estado | Título / mensaje | Recuperación |
|---|---|---|
| Sin contexto | Escanee el QR de PREPESAJE | Escanear sin registrar hechos. |
| Manga cerrada | No se puede pesar: manga cerrada | Otra manga; error de cierre a Central. |
| Trabajo programado | Trabajo de la OT sin iniciar | Central inicia el Trabajo; reescanear. |
| Continuidad pendiente | Falta vincular/iniciar la continuidad | Central revisa vínculo; mismo QR. |
| Sin conexión/lectura | Motivo del dispositivo | Reconectar y resolver; no prometer cola offline. |
| Neto no creciente | Último control y neto actual | Verificar manga/lectura; no registrar doble aporte. |
| Listo | Control mantiene abierta / final cierra | Mismo botón y F2. |
| En curso | Registrando / consultando | Esperar; evitar acciones simultáneas. |
| Éxito | Control registrado o cierre registrado | Separar registro e impresión. |
| Error | Mensaje real de rechazo | No comunicar éxito; reintento idempotente o reescanear. |

Los cambios de maquinista/OT no aparecen como opciones de Pesaje. No se
incorporan unidades estimadas ni se presenta plan como conteo humano.
La excepción parcial histórica sigue fuera de la nueva validación solo kg.
