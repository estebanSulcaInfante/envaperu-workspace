---
tipo: uat
estado: pendiente-ejecucion
historia: "[[US-010B_Reserva_Emision_Materiales_OP]]"
fecha_creacion: 2026-08-03
---

# UAT US-010B — Reserva, emisión y premezcla

## Preparación

1. Usar solamente ambiente local.
2. Registrar y aprobar una apertura inicial de resina y colorante.
3. Contar con una OF liberada, corrida configurada y receta aprobada.
4. Identificar un actor Jefe de Producción y otro de Almacén.

## Recorrido principal

1. Jefe de Producción abre `Materias primas > Preparaciones` y genera los
   requerimientos. Verifica kg de resina, runner y dosis de colorante.
2. Reserva materiales. Comprueba que no cambie el físico y sí disminuya el
   disponible para otras órdenes.
3. Almacén emite todos los componentes. Comprueba origen, destino y actor.
4. Almacén devuelve una cantidad pequeña identificada y verifica la restitución.
5. Reemite esa cantidad para completar la proporción.
6. Jefe de Producción confirma la premezcla con motivo y genealogía.
7. Verifica el código `LMP-{corrida}-{secuencia}`, cantidad total, inputs y
   estado `DISPONIBLE_MAQUINA`.

## Casos de rechazo

- intentar reservar sin saldo suficiente: ninguna línea queda reservada;
- emitir más de lo reservado: rechazo sin movimiento;
- devolver más de lo separable: rechazo;
- confirmar premezcla sin un componente o fuera de proporción: rechazo;
- devolver un input después de premezclar: rechazo;
- repetir un comando con la misma clave: mismo resultado, sin duplicado.

## Evidencia y salida

Registrar actor, hora, captura, resultado esperado/obtenido y observaciones de
ergonomía. La UAT aprueba la historia solo si Producción y Almacén comprenden la
diferencia entre reservar, emitir y consumir, y los saldos coinciden con el
conteo físico de prueba.
