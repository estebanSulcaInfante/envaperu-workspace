---
tipo: tech-spec
id: TS-013
titulo: "Códigos correlativos automáticos para los maestros"
estado: aprobado-para-desarrollo
tags: [catalogo, identificadores, correlativos, sku, concurrencia, migracion, frontend, backend]
relaciones:
  - "[[TS-001_Creacion_Agil_Molde_Producto_Pieza]]"
  - "[[TS-002_Refactor_CRUD_Molde_Pieza_Producto]]"
  - "[[TS-003_Creacion_Manual_Producto_Terminado]]"
  - "[[TS-012_Normalizacion_Relacion_Molde_Pieza_NM]]"
  - "[[US-001_Creacion_Agil_Molde_Producto_Pieza]]"
  - "[[US-002_Refactor_CRUD_Molde_Pieza_Producto]]"
  - "[[US-003_Creacion_Manual_Producto_Terminado]]"
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-23
---

# TS-013: Códigos correlativos automáticos para los maestros

## 1. Estado y alcance de la decisión

Esta Tech Spec transversal queda **aprobada para desarrollo el 2026-07-22**. Sustituye toda definición anterior que:

- solicite al usuario escribir el código o SKU durante un alta ordinaria;
- derive un identificador desde nombre, línea, familia, color, molde u otro atributo mutable;
- use `MAX(código) + 1`, un contador del frontend o un UUID visible como estrategia definitiva;
- presente como autoritativo un preview del próximo correlativo antes de confirmar el alta.

La decisión aplica a las altas nuevas de `Pieza`, `PiezaColor`, `ProductoTerminado`, `Molde`, materiales SCM, proveedores, categorías de recepción, trabajadores, máquinas, líneas, familias y familias de color. No cambia sus relaciones de dominio, BOM, composiciones ni snapshots; esas reglas continúan bajo [[TS-012_Normalizacion_Relacion_Molde_Pieza_NM|TS-012]] y las Tech Specs funcionales relacionadas.

## 2. Formato e identidades

Cada agregado utiliza un espacio correlativo independiente:

| Entidad | Campo canónico vigente | Prefijo | Formato nuevo | Ejemplo |
| :--- | :--- | :---: | :--- | :--- |
| `Pieza` | `codigo` | `PZ` | `PZ-NNNNNN` | `PZ-000001` |
| `PiezaColor` | `sku` | `PC` | `PC-NNNNNN` | `PC-000001` |
| `ProductoTerminado` | `cod_sku_pt` | `PT` | `PT-NNNNNN` | `PT-000001` |
| `Molde` | `codigo` | `ML` | `ML-NNNNNN` | `ML-000001` |
| `MateriaPrima` | `scm_material.codigo` | `MP` | `MP-NNNNNN` | `MP-000001` |
| `Colorante` | `scm_material.codigo` | `COL` | `COL-NNNNNN` | `COL-000001` |
| `Aditivo` | `scm_material.codigo` | `ADT` | `ADT-NNNNNN` | `ADT-000001` |
| `Proveedor` | `codigo` | `PRV` | `PRV-NNNNNN` | `PRV-000001` |
| `CategoriaRecepcion` | `codigo` | `CAT` | `CAT-NNNNNN` | `CAT-000001` |
| `Trabajador` | `codigo` | `TRB` | `TRB-NNNNNN` | `TRB-000001` |
| `Maquina` | `codigo` | `MAQ` | `MAQ-NNNNNN` | `MAQ-000001` |
| `TipoMaquina` | `codigo` | `TMQ` | `TMQ-NNNNNN` | `TMQ-000001` |
| `Linea` | `codigo` entero legacy + `codigo_display` | `LIN` | `LIN-NNNNNN` | `LIN-000001` |
| `Familia` | `codigo` entero legacy + `codigo_display` | `FAM` | `FAM-NNNNNN` | `FAM-000001` |
| `FamiliaColor` | `codigo` entero legacy + `codigo_display` | `FC` | `FC-NNNNNN` | `FC-000001` |

Para altas nuevas, el sufijo decimal se rellena con ceros hasta un **mínimo de seis dígitos**. Por eso los primeros valores cumplen `PZ-000001`; si un espacio supera `999999`, continúa como `PZ-1000000` sin truncar ni reciclar códigos. `Linea`, `Familia` y `FamiliaColor` conservan temporalmente su columna entera para no romper FKs e importadores legacy; el número se reserva en el mismo contador y la API expone su representación prefijada mediante `codigo_display`.

Reglas:

1. Cada espacio empieza en `000001` y avanza de manera independiente.
2. El código confirmado es único, estable, inmutable y nunca se reutiliza.
3. Los huecos históricos o producidos después de confirmar un alta son válidos. El generador no busca rellenarlos y un código no debe usarse para contar registros. Una reserva revertida junto con su transacción nunca llegó a emitirse y puede volver a ser el siguiente valor.
4. El correlativo es una identidad legible, no un dato de negocio. No representa prioridad, fecha, línea, familia, color, molde ni estado.
5. `ancho=6` es padding mínimo, no un límite de capacidad. Los valores mayores crecen en longitud y nunca se truncan.

## 3. Generación autoritativa

### 3.1. Responsabilidad del backend y contador transaccional

El backend es el único responsable de solicitar y asignar códigos. La fuente autoritativa es la tabla portable `correlativo_catalogo`, con una fila por espacio:

| `clave` (PK) | `prefijo` (UNIQUE) | `siguiente_valor` | `ancho` |
| :--- | :---: | ---: | ---: |
| `PIEZA` | `PZ` | entero positivo | `6` |
| `PIEZA_COLOR` | `PC` | entero positivo | `6` |
| `PRODUCTO_TERMINADO` | `PT` | entero positivo | `6` |
| `MOLDE` | `ML` | entero positivo | `6` |
| `MATERIA_PRIMA` / `COLORANTE` / `ADITIVO` | `MP` / `COL` / `ADT` | entero positivo | `6` |
| `PROVEEDOR` / `CATEGORIA_RECEPCION` | `PRV` / `CAT` | entero positivo | `6` |
| `TRABAJADOR` / `MAQUINA` / `TIPO_MAQUINA` | `TRB` / `MAQ` / `TMQ` | entero positivo | `6` |
| `LINEA` / `FAMILIA` / `FAMILIA_COLOR` | `LIN` / `FAM` / `FC` | entero positivo | `6` |

`siguiente_valor` es un `BIGINT` y señala el próximo número por entregar; `ancho` es un `SMALLINT` positivo y define padding mínimo. `clave` y `prefijo` se almacenan normalizados en mayúsculas, sin espacios exteriores. No existe CRUD funcional para estas filas.

El servicio común ejecuta, sin hacer `commit` propio:

1. normalizar la clave y rechazar una que no pertenezca a los espacios declarados antes de tocar la base;
2. hacer `INSERT ... ON CONFLICT (clave) DO NOTHING` para que la fila exista incluso en una base limpia;
3. ejecutar atómicamente `UPDATE correlativo_catalogo SET siguiente_valor = siguiente_valor + 1 WHERE clave = :clave RETURNING prefijo, siguiente_valor, ancho`;
4. tomar como valor asignado el `siguiente_valor` retornado menos uno y aplicar el padding configurado;
5. insertar la entidad dentro de la misma transacción del llamador.

PostgreSQL serializa los `UPDATE` concurrentes sobre la misma fila. SQLite serializa sus escrituras y soporta el mismo `UPSERT + UPDATE ... RETURNING`. Por tanto, el servicio admite explícitamente ambos dialectos; cualquier otro motor falla de forma explícita en vez de caer en un algoritmo no atómico.

La reserva y el alta pertenecen a la misma transacción. Si esta se revierte, también se revierte el incremento del contador. El código solo se considera emitido y se devuelve como creado después de un `commit` exitoso.

Queda prohibido en ejecución normal:

- calcular el siguiente número con `MAX + 1`;
- mantener un contador en memoria, JavaScript, `localStorage` o configuración de una instancia;
- implementar un bloqueo manual de toda la tabla para cada alta;
- generar el código desde atributos del formulario;
- consultar o reservar un “próximo código” para mostrarlo como definitivo antes de guardar.

Las restricciones `UNIQUE` existentes sobre los cuatro campos canónicos permanecen como última defensa de integridad.

### 3.2. Altas simples y en cascada

En una alta simple, el backend reserva un correlativo dentro de la transacción que crea la entidad. En el wizard de creación en cascada se reserva un correlativo separado para cada `Molde`, `Pieza`, `PiezaColor` y `ProductoTerminado` realmente nuevo.

Si cualquier validación o persistencia del flujo en cascada falla, se revierten el agregado completo y los incrementos de `correlativo_catalogo`. Un reintento puede recibir los mismos candidatos porque nunca fueron confirmados ni expuestos como códigos creados. Una vez confirmado un código, una baja lógica o eliminación posterior no habilita su reutilización.

## 4. Contrato de API y formularios

### 4.1. Creación

Los contratos ordinarios de creación omiten el identificador canónico:

```json
{
  "nombre": "Tapa regadera",
  "linea_id": 1,
  "familia_id": 7,
  "peso_nominal_gr": 30.0
}
```

```json
{
  "pieza_id": 7,
  "color_produccion_id": 3,
  "nombre": "Tapa regadera azul"
}
```

```json
{
  "producto": "Regadera completa",
  "linea_id": 1,
  "familia_id": 7,
  "piezas": [
    { "pieza_sku": "PC-000014", "cantidad": 1 }
  ]
}
```

```json
{
  "nombre": "Molde regadera",
  "peso_tiro_gr": 420.0,
  "tiempo_ciclo_std": 24.0
}
```

Una solicitud ordinaria de los agregados productivos originales que envíe `codigo`, `sku` o `cod_sku_pt` con valor no vacío se rechaza con `400 CODIGO_MANUAL_NO_PERMITIDO`; no se ignora silenciosamente. En los maestros incorporados por esta ampliación, el frontend omite siempre el código y el backend lo genera; temporalmente se conserva la entrada explícita solo para importadores y pruebas legacy hasta separar un endpoint de importación. La respuesta de creación incluye el código finalmente asignado.

### 4.2. Edición

Los endpoints de actualización no aceptan cambiar el identificador. Si un `PATCH` o `PUT` intenta modificarlo, responden `400 CODIGO_INMUTABLE`, incluso cuando la entidad aún no tiene historia operativa.

Los formularios ordinarios:

- no muestran un input editable de código o SKU;
- muestran, como máximo, un control deshabilitado con “Se asignará automáticamente al guardar”;
- después del alta muestran el código confirmado por el backend;
- no construyen ni anticipan el valor usando el último código listado;
- conservan los códigos existentes como solo lectura durante la edición.

## 5. Inmutabilidad y referencias alternas

El código canónico no cambia si se renombra la entidad o se modifica su línea, familia, color, molde, peso, composición o estado. Por tanto, esos atributos no se concatenan en `PZ`, `PC`, `PT` o `ML`.

Los códigos de cliente, proveedor, plano, sistema anterior o archivo importado son referencias alternas. Cuando el proceso necesite conservarlos, se almacenan en un atributo o catálogo separado, como `codigo_legacy` o `referencia_externa`, junto con su origen cuando pueda existir más de un emisor. Nunca reemplazan, alteran ni se concatenan al correlativo canónico.

Los identificadores que ya existen antes de esta migración permanecen exactamente iguales en sus campos canónicos, aunque no coincidan con el nuevo patrón. No se regeneran, renombran ni trasladan, porque podrían estar referenciados por BOM, inventario, OP o integraciones. La separación de una referencia alterna nueva aplica hacia adelante; una depuración masiva de códigos históricos queda fuera de alcance.

## 6. Migración e inicialización de contadores

La migración debe ejecutarse con las altas del catálogo pausadas o dentro del aislamiento de escritura apropiado. Es el **único** lugar donde se consulta el máximo de códigos existentes; el servicio de ejecución normal nunca usa `MAX + 1`.

1. Crear `correlativo_catalogo` con PK `clave`, `prefijo` único y checks de normalización, `siguiente_valor > 0` y `ancho > 0`.
2. Para cada entidad, leer los códigos cuyo valor normalizado coincida con su prefijo seguido de uno o más dígitos, por ejemplo `^PZ-(\d+)$`.
3. Obtener el mayor sufijo numérico `M`. Los códigos legacy o externos que no coincidan se preservan, pero no intervienen en el cálculo.
4. Insertar una fila con `siguiente_valor=M+1` y `ancho=6`; si no existe un sufijo válido o la tabla/columna de origen no existe en una instalación adoptada, usar `siguiente_valor=1`.
5. Repetir para todas las claves declaradas sin obligarlas a compartir valor. Los catálogos de texto se inicializan desde sufijos que coincidan con su prefijo; `Linea`, `Familia` y `FamiliaColor` se inicializan desde el máximo entero persistido.
6. Validar que no cambió ningún código, PK, FK, BOM, asociación `MoldePieza` ni snapshot histórico.

Un downgrade elimina solamente `correlativo_catalogo`; no modifica los códigos creados. Un upgrade posterior vuelve a inicializar cada fila desde el mayor sufijo válido que permanezca en su tabla de origen.

No se modifica el identificador de una fila para “cerrar” huecos. Tampoco se fuerza a que los cuatro espacios avancen juntos.

## 7. Excepción manual futura

El override manual no está disponible en formularios ni endpoints ordinarios y no forma parte de este incremento. Si posteriormente un proceso regulado de importación o recuperación lo necesita, deberá diseñarse como una capacidad explícita —nombre reservado sugerido: `CATALOGO_CODIGO_OVERRIDE`— sin asignación automática a ningún rol.

Esa capacidad futura deberá exigir motivo, actor, fecha, código anterior/nuevo cuando corresponda, validación de espacio, no reutilización y evento de auditoría. No autoriza editar identificadores históricos referenciados ni omitir las restricciones únicas.

## 8. Escenarios de aceptación

### CCA-01: Alta ordinaria sin código

**Dado** un formulario de nueva pieza sin campo de código editable  
**Cuando** el usuario guarda datos válidos  
**Entonces** el backend crea la pieza y responde un código con patrón `PZ-NNNNNN`  
**Y** el frontend muestra el valor confirmado.

### CCA-02: Espacios independientes

**Dado** que el último código de pieza es `PZ-000010` y el último de molde es `ML-000003`  
**Cuando** se crea una pieza y un molde  
**Entonces** reciben `PZ-000011` y `ML-000004`, respectivamente.

### CCA-03: Concurrencia real

**Dado** un PostgreSQL con la fila `PIEZA` inicializada  
**Cuando** varias transacciones crean simultáneamente entidades del mismo espacio  
**Entonces** todos los códigos confirmados son distintos y válidos  
**Y** ninguna creación usa `MAX + 1` ni depende del orden de respuesta HTTP.

### CCA-04: Rollback libera una reserva no emitida

**Dado** una transacción que ya obtuvo un correlativo  
**Cuando** una validación posterior provoca rollback  
**Entonces** la entidad no se crea  
**Y** también se revierte `siguiente_valor`  
**Y** una transacción posterior puede recibir ese número porque nunca fue confirmado.

### CCA-05: Migración conservadora

**Dado** códigos `PZ-000007`, `PZ-000012` y `PIEZA-LEGACY-A`  
**Cuando** se aplica la migración  
**Entonces** los tres valores permanecen intactos  
**Y** la siguiente pieza nueva recibe `PZ-000013`.

### CCA-06: Identificador inmutable

**Dado** una pieza existente `PZ-000013`  
**Cuando** cambia de nombre, familia o peso nominal  
**Entonces** conserva `PZ-000013`  
**Y** un intento explícito de cambiarlo recibe `400 CODIGO_INMUTABLE`.

### CCA-07: Entrada manual rechazada

**Dado** un usuario en un formulario o consumidor ordinario de la API  
**Cuando** intenta crear un producto enviando `cod_sku_pt=PT-900000`  
**Entonces** la operación se rechaza con `400 CODIGO_MANUAL_NO_PERMITIDO`  
**Y** no se reserva ningún override implícito por rol administrativo.

### CCA-08: Alta en cascada atómica

**Dado** un wizard que crea molde, piezas, variantes y producto  
**Cuando** falla una regla de integridad de la BOM  
**Entonces** no queda persistida ninguna entidad parcial  
**Y** tampoco quedan adelantados sus contadores.

## 9. Estrategia de pruebas

| Nivel | Cobertura mínima |
| :--- | :--- |
| Dominio unitario | Formato, padding mínimo, crecimiento más allá de seis dígitos, claves permitidas y rechazo de inputs manuales. |
| Integración PostgreSQL | Inicialización desde máximo válido, códigos legacy ignorados, rollback del contador y `UPSERT + UPDATE ... RETURNING`. |
| Integración SQLite | La misma reserva transaccional, recreación idempotente de una fila ausente y migración desde máximos válidos. |
| Concurrencia PostgreSQL | Transacciones realmente solapadas sobre una fila ausente y luego compartida; unicidad de todos los códigos confirmados. |
| Contrato API | `POST` sin código, `400 CODIGO_MANUAL_NO_PERMITIDO`, `400 CODIGO_INMUTABLE` y respuesta con código confirmado. |
| Frontend | Ausencia de input editable, mensaje previo al guardado y código readonly después de crear/editar. |
| Regresión | BOM, `MoldePieza`, snapshots, códigos y referencias existentes permanecen intactos. |

La prueba de alta concurrencia debe ejecutarse contra PostgreSQL real para demostrar la serialización por fila. SQLite debe tener pruebas propias de contrato transaccional y migración; un mock del asignador no demuestra ninguna de las dos garantías.

La primera prueba `RED` crea una `Pieza` mediante el endpoint ordinario omitiendo `codigo` y exige un valor `PZ-000001`. Debe fallar mientras el formulario o contrato todavía dependa de entrada manual, UUID visible o un formato derivado.

## 10. Definición de terminado

1. `correlativo_catalogo` existe con una fila por espacio, restricciones e inicialización desde datos reales.
2. Todas las rutas de alta —CRUD y wizard— usan el mismo servicio backend de asignación.
3. Ningún formulario ordinario permite escribir o anticipar el código.
4. Los identificadores son inmutables y las referencias alternas permanecen separadas.
5. Ningún código histórico ni referencia asociada cambia durante la migración.
6. Los escenarios CCA-01 a CCA-08 tienen evidencia automatizada en el nivel indicado.
7. Las pruebas de concurrencia PostgreSQL, compatibilidad SQLite y migración pasan, y la regresión afectada permanece verde.
