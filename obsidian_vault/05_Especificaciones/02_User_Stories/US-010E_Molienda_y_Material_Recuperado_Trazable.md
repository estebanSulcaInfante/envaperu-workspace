---
tipo: user-story
subtipo: historia-hija
estado: implementada-local-pendiente-uat
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, molienda, reproceso, merma-recuperable, material-segunda, genealogia, kardex, atdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[US-010L_Material_Segunda_Reproceso_y_Mezcla_Preparada_Trazable]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[Orden_Molienda]]"
  - "[[Regla_Compatibilidad_Reproceso]]"
  - "[[Lote_Material_Recuperado]]"
  - "[[Lote_Merma_Recuperable]]"
  - "[[2026-08-02_Compatibilidad_y_Dilucion_Controlada_en_Molienda]]"
  - "[[2026-08-03_Alcance_Piloto_Apertura_Inicial_sin_Recepcion_Compras]]"
fecha_creacion: 2026-08-02
fecha_actualizacion: 2026-08-08
---

# US-010E: Molienda y Material Recuperado Trazable

> [!NOTE] Aplicación en el nuevo piloto
> El primer recorrido registra, pesa, clasifica y almacena merma recuperable.
> La molienda completa se ejecuta como segundo recorrido específico, salvo que
> la OP elegida necesite producir material recuperado durante la prueba. El
> material recuperado existente al corte puede ingresar por
> `APERTURA_INICIAL`, sin atribuirle una genealogía desconocida.

## 1. Decisión de alcance

La merma recuperable de EnvaPerú incluye ramal y rechazo de fabricación, además
de `PiezaColor` rota, aplastada o deformada durante Armado. No retorna como
pieza disponible ni se destruye: se segrega, pesa y transforma mediante
molienda en material de segunda.

La separación visible por color se complementa con familia de materia prima y
proceso de origen. Inyección y soplado no se consideran automáticamente
compatibles. Una cantidad minoritaria puede admitirse mediante una regla de
dilución máxima aprobada.

## 2. Historia de usuario

**Como** responsable de Producción o Molienda  
**Quiero** reunir merma recuperable compatible, ejecutar su molienda y registrar
el material resultante  
**Para** reutilizarlo sin perder composición, balance de masa, procedencia ni
control sobre mezclas excepcionales.

## 3. Actores y responsabilidades

| Actor | Responsabilidad |
|---|---|
| Fabricación / Armado | Clasifica la merma, indica motivo y la entrega segregada |
| Responsable de Molienda | Pesa nuevamente antes del molino, ejecuta y confirma salidas/pérdidas |
| Almacén | Pesa/recibe la merma almacenada, transfiere custodia y recibe las bolsas recuperadas |
| Jefe de Producción | Autoriza excepciones y anulaciones y libera el material recuperado |
| Responsable técnico configurable | Mantiene y aprueba reglas de compatibilidad |
| Gerencia / Auditoría | Consulta genealogía, rendimientos y excepciones |

Una persona puede asumir más de un rol operativo, pero crear/aprobar reglas o
autorizar su propia excepción debe respetar segregación cuando la política lo
exija.

## 4. Fuentes admitidas

- ramal generado por una corrida de fabricación;
- rechazo recuperable de fabricación;
- `PiezaColor` dañada durante prearmado o armado;
- saldo recuperable identificado por corrección o contingencia aprobada.

No se admite material peligroso, contaminado o clasificado como destrucción.
Una merma de Armado consume el saldo de la `PiezaColor` por un hecho separado
de la cantidad incorporada al producto.

## 5. Clasificación de cada aporte

Todo aporte congela como mínimo:

- familia de materia prima;
- material/grado cuando se conozca;
- proceso de origen: inyección, soplado u otro catálogo;
- color o familia de color;
- condición y contaminación observable;
- peso real disponible;
- artículo, lote, manga, OT/OF/OA y evento de merma de origen aplicables;
- número de reprocesos conocido.

El sistema no deduce polímero únicamente del color ni reinterpreta la
composición histórica cuando cambia una receta. Familias, materiales, procesos,
colores, condiciones y reglas son maestros configurables; no se hardcodean sus
valores de negocio.

Materiales registrados en familias de color distintas pueden compartir
molienda cuando la regla los declara compatibles y apuntan al mismo color
nominal. La orden declara el color objetivo/dominante; no se infiere únicamente
por HEX o por contar cuál aporte es mayor. La salida conserva los porcentajes de
todos los colores/familias aportantes y se presenta como material que **tiende**
al color dominante, no como equivalencia colorimétrica garantizada.

## 6. Compatibilidad y dilución

La [[Regla_Compatibilidad_Reproceso]] evalúa cada aporte contra la
especificación objetivo de la [[Orden_Molienda]]:

| Resultado | Efecto |
|---|---|
| `COMPATIBLE` | Puede participar normalmente |
| `CONDICIONADA` | Puede participar sin superar el porcentaje máximo |
| `INCOMPATIBLE` | Se bloquea su selección/confirmación |
| `SIN_REGLA` | Requiere definir una regla o una excepción autorizada |

```text
porcentaje_aportante = kg_aportante / kg_total_entradas * 100
```

El porcentaje se valida con cantidades planificadas y nuevamente con pesos
reales. Rebasarlo nunca se resuelve ocultando el aporte o redondeando su peso.

La regla inicial validada por Planta permite combinar material de inyección y
soplado de la misma familia/color cuando uno de los procesos representa como
máximo `10 %` del total. La regla es simétrica: puede ser minoritario cualquiera
de los dos procesos. Ese `10 %` es un valor inicial configurable y versionado,
no una constante del software.

## 7. Flujo nominal

1. Producción/Armado clasifica la merma como `RECUPERABLE_MOLIENDA`.
2. Se crea o cierra una unidad logística de merma, se pesa y se almacena como
   saldo recuperable identificado.
3. Almacén o Molienda acepta la transferencia de custodia.
4. El responsable crea una orden y define la especificación objetivo.
5. Selecciona bolsas/lotes y cantidades; el SCM evalúa compatibilidad.
6. Se valida la orden o se tramita una excepción.
7. Inmediatamente antes del molino se vuelven a pesar los aportes; ese peso
   confirma la cantidad realmente consumida y se concilia contra el saldo
   almacenado. Después se ejecuta el proceso.
8. Se pesan las bolsas variables de salida y se registra la pérdida.
9. Una confirmación atómica consume las entradas y acredita el
   [[Lote_Material_Recuperado]].
10. Almacén recibe las bolsas resultantes en una ubicación de material
    recuperado.
11. El Jefe de Producción decide la liberación del material recuperado; solo
    después el saldo queda disponible para US-010B.

## 8. Estados mínimos

### Merma recuperable

`IDENTIFICADA -> SEGREGADA -> EN_CUSTODIA_MOLIENDA -> CONSUMIDA`

Laterales: `BLOQUEADA`, `RECLASIFICADA_DESTRUCCION`, `ANULADA`.

### Orden de molienda

`BORRADOR -> VALIDADA -> EN_EJECUCION -> CERRADA`

Laterales: `BLOQUEADA_COMPATIBILIDAD`, `ANULADA`.

### Lote recuperado

`PRODUCIDO -> PENDIENTE_RECEPCION -> RECIBIDO -> DISPONIBLE`

Laterales: `BLOQUEADO`, `RECHAZADO`.

## 9. Balance de masa

```text
kg_entrada_real = kg_salida_recuperada + kg_perdida_molienda
```

- entradas y salidas usan pesajes reales;
- el peso de almacenamiento acredita el saldo recuperable y el pesaje previo al
  molino gobierna el consumo; nunca se suman como dos entradas;
- la diferencia entre ambos queda como conciliación de custodia. El flujo
  validado vuelve a pesar incluso una bolsa cerrada antes de molerla;
- la tolerancia inicial de custodia es `1.000 kg`, configurable. Una diferencia
  absoluta mayor genera alerta, exige motivo y autorización del Jefe de
  Producción; cualquier intento de consumir más saldo del disponible se bloquea;
- las bolsas de salida pueden aproximarse a 30 kg, pero no poseen peso fijo;
- toda diferencia fuera de tolerancia exige motivo y autorización;
- corregir genera un evento compensatorio y no edita pesajes sincronizados.

## 10. Genealogía y composición

El lote resultante conserva por aporte:

- origen y cantidad real;
- porcentaje sobre la entrada total;
- familia, proceso y color;
- regla/versión evaluada;
- excepción y autorización, cuando exista.

La genealogía es N:M y cuantificada. Una bolsa fuente puede consumirse
parcialmente y un lote recuperado puede agrupar múltiples fuentes compatibles.

## 11. Mezcla excepcional

Si falta regla o se excede un límite:

1. la orden no puede validarse normalmente;
2. el responsable solicita excepción con motivo y porcentajes;
3. un actor con capacidad independiente aprueba o rechaza;
4. al aprobar se congela alcance, cantidad máxima y vigencia;
5. la salida queda `MEZCLA_EXCEPCIONAL` de forma visible y auditable.

La autorización no convierte la combinación en una regla maestra reutilizable.

## 12. Kardex

- identificar merma no acredita material recuperado;
- entregar merma cambia custodia, no su identidad;
- confirmar molienda debita los aportes y crea la salida en una transacción;
- recibir las bolsas crea/mueve su existencia según US-010I;
- reservar o emitir el material de segunda corresponde a US-010B;
- ningún movimiento puede dejar saldo negativo o duplicar una confirmación.

## 13. Capacidades configurables

- `MERMA_RECUPERABLE_REGISTRAR`
- `MOLIENDA_ORDEN_CREAR`
- `MOLIENDA_EJECUTAR`
- `MOLIENDA_REGLA_ADMINISTRAR`
- `MOLIENDA_REGLA_APROBAR`
- `MOLIENDA_EXCEPCION_SOLICITAR`
- `MOLIENDA_EXCEPCION_APROBAR`
- `MOLIENDA_LOTE_LIBERAR`
- `MOLIENDA_ANULAR`
- `MOLIENDA_VER_GENEALOGIA`

Los nombres físicos de roles se asignarán al final del desarrollo; el dominio
autoriza por capacidades.

## 14. Criterios de aceptación

- **MOL-01:** clasificar una `PiezaColor` rota como recuperable descuenta su
  saldo mediante merma separada y no la devuelve como pieza utilizable.
- **MOL-02:** dos aportes del mismo color pero distinta familia de material no
  se consideran compatibles por nombre o HEX.
- **MOL-03:** una combinación inyección/soplado condicionada se acepta solo si
  su porcentaje real no supera la revisión aprobada.
- **MOL-04:** cambiar pesos o aportes recalcula porcentajes antes de confirmar.
- **MOL-05:** un aporte incompatible bloquea la orden normal.
- **MOL-06:** superar el límite requiere una autorización distinta y marca la
  salida como excepcional.
- **MOL-07:** confirmar consume cada entrada una sola vez y acredita cada bolsa
  de salida una sola vez ante reintentos.
- **MOL-08:** la suma de salidas y pérdida concilia con entradas dentro de
  tolerancia.
- **MOL-09:** cada bolsa de salida conserva su peso real; no se fuerza 30 kg.
- **MOL-10:** la genealogía recorre desde material recuperado a todas las
  piezas/ramales originales y en sentido inverso.
- **MOL-11:** una regla aprobada usada históricamente no cambia al publicar otra
  versión.
- **MOL-12:** material producido pero no recibido o no liberado por Jefatura de
  Producción no queda disponible para una nueva OF.
- **MOL-13:** agregar una familia, proceso, color, condición o porcentaje nuevo
  se realiza mediante maestros/revisiones sin desplegar código.
- **MOL-14:** una merma contaminada o cuyo material se transmutó por quemadura
  queda no recuperable y no puede seleccionarse en una orden normal.
- **MOL-15:** pesar una bolsa al almacenarla y antes de molerla no duplica saldo;
  el segundo peso debita la existencia creada por el primero.
- **MOL-16:** una diferencia entre peso almacenado y peso previo al molino se
  conserva y concilia; ninguno de los pesajes se sobrescribe.
- **MOL-17:** aportes de familias de color distintas pero del mismo color
  nominal pueden mezclarse solo por una regla aprobada y la salida conserva un
  color dominante explícito y su composición.
- **MOL-18:** una diferencia absoluta de custodia de hasta `1.000 kg` se acepta
  normalmente; por encima crea alerta y exige autorización del Jefe de
  Producción.

## 15. Escenarios ATDD esenciales

### Escenario A: molienda compatible

**Dado** merma PP amarilla de inyección con regla compatible  
**Cuando** se pesa, muele y cierra la orden  
**Entonces** se consumen sus aportes y nace material recuperado PP amarillo con
genealogía y balance conciliado.

### Escenario B: dilución dentro del máximo

**Dado** un objetivo PP amarillo de inyección y una regla que admite hasta 5 %
de PP amarillo proveniente de soplado  
**Cuando** el peso real de soplado representa 4,8 %  
**Entonces** la orden puede confirmarse normalmente y conserva ese porcentaje.

### Escenario C: dilución fuera del máximo

**Cuando** el peso real de soplado representa 5,2 %  
**Entonces** el SCM bloquea la confirmación normal y solicita reducir el aporte
o tramitar una excepción.

### Escenario D: mismo color, polímero distinto

**Dado** PP amarillo y PE amarillo  
**Cuando** se intenta incluir ambos solo porque comparten color  
**Entonces** el sistema no los declara compatibles y aplica la matriz aprobada.

### Escenario E: reintento de cierre

**Dado** una orden ya cerrada  
**Cuando** la estación reintenta la misma operación idempotente  
**Entonces** no vuelve a consumir entradas ni crea otro lote.

## 16. Fuera de alcance de esta historia

- definir porcentajes técnicos sin validación de Planta;
- control automático del molino;
- valorización contable o costo estándar;
- destrucción de merma no recuperable;
- compra/recepción de material de segunda de proveedor;
- decidir fórmulas de producto que consumirán el lote recuperado.

## 17. Pendientes para cerrar refinamiento

1. Cargar en maestros el catálogo inicial de familias, materiales, procesos,
   colores y condiciones; el modelo no depende de una lista hardcodeada.
2. Cargar las reglas iniciales que relacionan familias de color con un mismo
   color nominal/dominante.
3. Definir tara/envase y formato de etiqueta para bolsas de merma y molido.
4. Definir la tolerancia inicial del balance de masa de molienda; permanecerá
   configurable.

## 18. Definición de preparada

La historia puede pasar a Tech Spec cuando Planta valide los puntos pendientes o
apruebe que alguno quede como maestro configurable con valor inicial pendiente.
