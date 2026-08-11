---
tipo: decision
estado: aceptada
tags: [catalogo, wizard, borrador, idempotencia, ux]
fecha: 2026-08-10
relaciones:
  - "[[../01_Dominio/Sesion_Alta_Producto]]"
  - "[[../05_Especificaciones/02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
---

# Sesión durable y aplicación incremental en el alta guiada de PT

## Contexto

El alta integral cruza maestros simples y objetos revisionados con ciclos de aprobación distintos. Una única transacción final sería frágil, bloquearía sesiones largas y no podría fingir que una revisión aprobada vuelve a ser editable. Guardar sólo en el navegador tampoco es aceptable para la interfaz principal de carga.

## Decisión

Se incorpora una [[../01_Dominio/Sesion_Alta_Producto|Sesión de Alta de Producto]] persistida en servidor. La sesión guarda el borrador, las fuentes declaradas, el progreso por paso, referencias a entidades creadas o reutilizadas y resultados de validación. Su título visible se deriva del nombre/código resuelto en `IDENTIDAD`; antes de resolverlo usa el nombre provisional de la sesión.

La aplicación es incremental:

1. cada paso valida primero su borrador;
2. aplica comandos canónicos con una clave idempotente;
3. cada servicio conserva su propia transacción e invariantes;
4. la sesión registra el resultado y permite reintentar sólo lo fallido;
5. no se borran maestros válidos para simular un rollback global.

Volver a un paso anterior siempre es posible. Antes de aplicar, se modifica el borrador. Después de crear un maestro, se usa su edición canónica si continúa editable. Después de publicar una revisión, cualquier cambio crea una nueva revisión y nunca altera la evidencia aprobada.

## Estados

`BORRADOR`, `CON_BLOQUEOS`, `LISTA_PARA_PUBLICAR`, `FINALIZADA` y `ABANDONADA`.

“Finalizada” describe la sesión. “Producto listo para planificar” es un resultado calculado por readiness y exige que todas las dependencias obligatorias estén vigentes.

## Consecuencias

- El autosave, reanudación y control de concurrencia son parte del MVP, no QoL opcional.
- **Guardar y salir** confirma persistencia server-side; `BORRADOR`, `CON_BLOQUEOS` y `LISTA_PARA_PUBLICAR` reaparecen en **Altas en curso** y se reanudan en `paso_actual`.
- Se necesita `version` para evitar sobrescrituras silenciosas entre pestañas.
- El frontend muestra qué acciones ya produjeron datos canónicos y qué sigue siendo borrador.
- La API agregada orquesta servicios existentes; no duplica reglas de BOM, ruta, empaque, recetas o códigos.
- `/api/configurar-producto` queda como fachada legacy de alcance Molde–Pieza–PiezaColor hasta retirarse; no se amplía para el flujo integral.
