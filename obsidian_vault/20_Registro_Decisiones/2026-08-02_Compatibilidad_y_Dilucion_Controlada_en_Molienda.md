---
tipo: decision
estado: aceptada
tags: [scm, molienda, reproceso, merma-recuperable, compatibilidad, genealogia]
relaciones:
  - "[[US-010E_Molienda_y_Material_Recuperado_Trazable]]"
  - "[[Regla_Compatibilidad_Reproceso]]"
  - "[[Orden_Molienda]]"
  - "[[Lote_Material_Recuperado]]"
fecha_creacion: 2026-08-02
fecha_actualizacion: 2026-08-03
---

# Compatibilidad y dilución controlada en molienda

## Contexto validado

EnvaPerú recupera ramales, rechazos de fabricación y piezas dañadas durante
Armado mediante molienda. La segregación física se realiza principalmente por
color. Para decidir si dos aportes pueden compartir una molienda también se
debe considerar:

- familia de materia prima, por ejemplo polipropilenos;
- proceso de origen, especialmente inyección o soplado;
- color o familia de color;
- condición y contaminación observable.

Dos materiales pueden no ser compatibles como aportes principales y, aun así,
admitir una cantidad pequeña de uno dentro de otro sin afectar de manera
relevante el resultado esperado.

## Decisión

1. El SCM no reducirá la compatibilidad a `SI/NO` ni la inferirá únicamente por
   el color visible.
2. Cada aporte se clasifica por familia de material, proceso de origen, color y
   condición.
3. La evaluación produce `COMPATIBLE`, `CONDICIONADA` o `INCOMPATIBLE`.
4. `CONDICIONADA` exige un porcentaje máximo respecto del peso total
   planificado de la molienda.
5. Los límites son datos maestros versionados y aprobados; no quedan
   codificados en la aplicación.
6. Superar un límite bloquea la confirmación normal. Solo una excepción
   autorizada puede continuar y el lote resultante queda marcado.
7. La salida conserva la composición real y genealogía N:M hacia todos los
   aportes, sin inventar una procedencia única.
8. La mezcla por debajo de un umbral no borra la diferencia técnica: se
   denomina **dilución controlada**, no compatibilidad absoluta.
9. Familias, materiales, procesos, colores, condiciones, tolerancias y
   porcentajes son configuración maestra; no listas hardcodeadas.
10. Como valor inicial, inyección y soplado pueden mezclarse si uno representa
    como máximo `10 %` del total. La regla es simétrica: cualquiera puede ser el
    proceso minoritario. Las demás dimensiones y el porcentaje son
    configurables.
11. Contaminación o transmutación del material —por ejemplo, quemadura— vuelve
    la merma no recuperable.
12. El Jefe de Producción libera el lote recuperado antes de reutilizarlo.
13. La merma se pesa al cerrar/almacenar su bolsa para conocer el saldo y vuelve
    a pesarse inmediatamente antes de entrar al molino. El segundo peso
    gobierna el consumo y no crea una segunda existencia.
14. El Almacenero realiza el pesaje de almacenamiento y el encargado de molino
    realiza el pesaje previo al proceso.
15. La diferencia de custodia admite inicialmente hasta `1.000 kg`; el umbral
    queda configurable. Superarlo genera alerta, motivo y autorización del Jefe
    de Producción.
16. Familias de color distintas que representan el mismo color nominal pueden
    mezclarse para tender a un color dominante definido por la orden. La salida
    conserva la composición real y no promete igualdad colorimétrica.
17. La tolerancia del balance final de molienda permanece configurable sin un
    valor inicial hasta contar con evidencia de Planta.

## Fórmula de control

```text
porcentaje_aportante =
    kg_aportante / kg_total_entradas_planificadas * 100
```

El denominador se recalcula cuando cambia la selección o cantidad de cualquier
aporte. Una orden no se confirma con pesos reales que violen la regla aprobada,
salvo excepción explícita.

## Autoridad

El operario registra y ejecuta la molienda, pero no define porcentajes ni
autoriza mezclas fuera de regla. La matriz y las excepciones requieren una
capacidad separada asignable posteriormente a responsables técnicos o Jefatura
de Producción.

## Pendiente de planta

Los porcentajes concretos y la granularidad de colores compatibles deben
levantarse mediante experiencia histórica o pruebas de proceso. Hasta entonces
una combinación sin regla aprobada se considera `SIN_REGLA` y no se confirma
como mezcla normal.
