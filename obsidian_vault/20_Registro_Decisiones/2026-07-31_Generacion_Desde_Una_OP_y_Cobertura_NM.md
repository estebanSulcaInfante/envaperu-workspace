---
tipo: decision-arquitectura
estado: aceptada-para-especificacion
fecha: 2026-07-31
tags: [scm, planificacion, orden-produccion, orden-fabricacion, orden-armado, cobertura, nm]
relaciones:
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[Orden_Produccion]]"
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Armado]]"
---

# Generación contextual desde una OP y cobertura N:M

## Contexto

El primer flujo del piloto parte de una sola OP: el planificador selecciona una
demanda, calcula su cobertura y obtiene propuestas de OF/OA. Esto simplifica la
adopción y coincide con la forma en que se utilizará inicialmente la interfaz.

Sin embargo, una OF u OA representa trabajo técnico agregado y no debe tener una
OP como propietaria obligatoria. Una misma campaña puede abastecer varias
demandas compatibles, o una producción para stock puede asignarse después a una
o más OP.

## Decisión

Se mantienen dos niveles diferentes:

1. **Generación contextual:** la propuesta puede originarse al trabajar una
   sola OP.
2. **Asignación de cobertura:** las cantidades de las salidas de OF/OA se
   vinculan a líneas de OP mediante `AsignacionDemandaSuministro`.

El campo `generated_from_op_id`, si se conserva, es únicamente una referencia
de auditoría del contexto que originó la propuesta. No es una relación padre
obligatoria ni sustituye las asignaciones cuantificadas.

## Comportamiento del piloto

La interfaz inicial seguirá este recorrido:

```text
OP seleccionada
  -> calcular cobertura
  -> proponer OF/OA
  -> crear una asignación para esa OP
```

No se obliga al planificador a seleccionar varias OP ni se introduce una
pantalla de consolidación en el primer recorrido. Si una OF/OA cubre una sola
OP, la asignación N:M tendrá una única fila y el comportamiento es equivalente
a 1:N para el usuario.

## Consolidación posterior

La capacidad N:M permitirá posteriormente consolidar demandas compatibles:

```text
OP-001: 100 cuerpos amarillos
OP-002:  60 cuerpos amarillos

OF-001: 160 cuerpos amarillos
  ├── OP-001: 100
  └── OP-002:  60
```

La misma regla aplica a una OA que armado componentes para varias OP. También
permite que una OF excepcional de reposición produzca stock y que ese stock sea
asignado después a distintas demandas.

## Invariantes

1. Una OP puede generar cero, una o varias propuestas OF/OA.
2. Una OF/OA puede cubrir una o varias OP mediante asignaciones separadas.
3. Una cantidad producida no puede satisfacer dos asignaciones activas.
4. Cancelar o suspender una OP afecta sus asignaciones, no automáticamente toda
   la OF/OA compartida.
5. Una OF/OA no se divide físicamente por cada OP; la distribución pertenece a
   las asignaciones de cobertura.
6. Las OT ejecutan la OF/OA agregada; no se crea una OT por cada OP salvo que la
   programación o trazabilidad lo requiera.
7. La consolidación futura no cambia la identidad de OF, OA, OT, mangas ni
   pesajes ya confirmados.

## Criterios de aceptación

### NMD-01 — Flujo simple del piloto

**Dado** una OP seleccionada con faltante de producción  
**Cuando** se confirma su plan  
**Entonces** se crea una OF/OA borrador con una asignación cuantificada a esa OP
**Y** no se exige seleccionar otras demandas.

### NMD-02 — Consolidación futura

**Dado** dos OP compatibles con el mismo molde, color y horizonte  
**Cuando** Planificación consolida la campaña  
**Entonces** se crea una OF común  
**Y** sus salidas se asignan separadamente a cada línea OP.

### NMD-03 — Suspensión de una demanda compartida

**Dado** una OF asignada a dos OP  
**Cuando** se suspende una OP  
**Entonces** se retiene o libera únicamente su asignación según autorización
**Y** la OF puede continuar para la OP restante.

## Alcance

La generación contextual desde una sola OP es parte del primer piloto. La
selección interactiva y consolidación de varias OP queda como evolución de
Planificación, pero la persistencia y los contratos deben conservar desde ahora
la relación N:M.
