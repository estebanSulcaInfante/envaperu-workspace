---
tipo: uat
estado: lista-para-ejecucion-local
fecha_actualizacion: 2026-08-03
relaciones:
  - "[[../05_Especificaciones/03_Tech_Specs/TS-010E_Molienda_Merma_y_Material_Recuperado|TS-010E]]"
  - "[[../05_Especificaciones/03_Tech_Specs/TS-010J_Alertas_Operativas_Configurable|TS-010J]]"
---

# UAT TS-010E/J: merma, molienda y alertas

## Objetivo

Validar en local que una bolsa de merma recuperable nace de un pesaje de
almacén, se reserva y consume una sola vez en molienda, conserva su genealogía
y produce material recuperado pendiente de liberación. Las diferencias deben
aparecer en una bandeja configurable sin modificar el hecho original.

## Preparación

1. Ejecutar la migración hasta `f50c8a6b4e13` en la base local.
2. Ejecutar la semilla SCM para crear capacidades, `OPERADOR_MOLINO`, maestros,
   reglas PP y umbrales iniciales.
3. Usar actores distintos para crear/aprobar reglas y para pesar/autorizar una
   diferencia. La interfaz local conserva el selector de actor solo para UAT.
4. Contar con un color, un material de salida y una ubicación activos.

## Recorrido feliz

| Paso | Actor | Acción | Resultado esperado |
|---|---|---|---|
| 1 | Configuración SCM | Revisar familias, procesos y condiciones | Existen PP, inyección, soplado, limpia, contaminada y quemada; nada está hardcodeado en el formulario |
| 2 | Almacenero | Pesar una bolsa limpia indicando bruto y tara | Nace `MER-*` con saldo neto en kg y un solo movimiento de ingreso |
| 3 | Operador de molino | Crear `OM-*` y agregar la bolsa | El saldo queda reservado, no consumido |
| 4 | Operador de molino | Validar compatibilidad | PP inyectado/soplado respeta el límite aprobado de 10% cuando corresponda |
| 5 | Operador de molino | Registrar peso previo al molino | Se concilia contra el saldo almacenado sin crear otro ingreso |
| 6 | Operador de molino | Iniciar, moler y cerrar con salida/pérdida | Se debita la entrada una vez; el balance queda visible |
| 7 | Jefe de Producción | Liberar `REC-*` con motivo | El material pasa de pendiente a disponible sin borrar su composición |

## Excepciones obligatorias

1. Registrar una diferencia pre-molino superior al umbral vigente: debe nacer
   una sola alerta y la orden no debe iniciar sin autorización de otro actor.
2. Intentar usar kilos reservados por otra orden: el sistema debe bloquearlo.
3. Intentar mezclar sin regla o excediendo 10%: debe bloquear o exigir excepción
   del Jefe de Producción con motivo.
4. Repetir el mismo cierre con la misma llave idempotente: no debe duplicar
   consumo ni lote recuperado.
5. Intentar cerrar sin tolerancia de balance: debe solicitar configurarla.
6. Clasificar una bolsa como contaminada o quemada: no debe ingresar al saldo
   recuperable.

## Bandeja de alertas

1. En `/produccion/alertas`, reconocer una alerta; debe seguir pendiente de
   resolución.
2. Resolverla o descartarla con motivo; debe conservar todos sus eventos.
3. Crear una nueva revisión de umbral con un actor y aprobarla con otro.
4. Confirmar que una alerta histórica sigue referenciando su revisión original.
5. Verificar alertas automáticas de pesaje tardío desde preetiqueta, diferencia
   de fecha OT, corrección tardía y custodia de merma.

## Evidencia de cierre

- capturas de `MER-*`, `OM-*`, `REC-*` y la alerta;
- movimientos de la bolsa: un ingreso, una reserva y un consumo;
- balance entrada = salida + pérdida dentro de tolerancia;
- actores distintos en las decisiones de cuatro ojos;
- resultado del build del frontend y pruebas automatizadas del backend.

La UAT se aprueba cuando no existe doble conteo de kg, las excepciones quedan
auditadas y cada actor ve solo las acciones permitidas por sus capacidades.
