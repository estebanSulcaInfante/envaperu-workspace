---
tipo: user-story
subtipo: historia-hija
estado: en-desarrollo
epica: "[[US-010_Trazabilidad_End_to_End_SCM]]"
tags: [scm, trazabilidad, recepcion, proveedores, lotes, inventario, calidad, atdd, tdd]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[Vista_US-010A_Recepcion_Materiales]]"
  - "[[US-009_Normalizar_Trabajadores_Maquinas_y_Vistas_Catalogo]]"
  - "[[2026-07-13_Perfil_Trazabilidad_ISO9001_ISA95_GS1]]"
  - "[[TE-001_Infraestructura_TDD_Reproducible]]"
  - "[[Validacion_Operativa_US-010A]]"
  - "[[TS-010A_Recepcion_Trazable_Materiales]]"
  - "[[DEV-010A_Recepcion_Trazable_Materiales]]"
  - "[[Composicion_Materiales]]"
  - "[[2026-07-17_Autenticacion_Humana_Diferida_Hasta_Cierre_Funcional]]"
fecha_creacion: 2026-07-13
fecha_actualizacion: 2026-07-21
---

# US-010A: Recepción Trazable de Materiales

## 1. Decisión de Alcance

Esta es la primera historia hija de la épica US-010. Debe entregar un flujo vertical utilizable:

> Desde que un material llega a planta hasta que existe como inventario identificado, ubicado y disponible o no disponible según Calidad.

No se creará una `TS-010` para toda la épica. Esta historia ya alcanzó su Definición de Preparada y se traduce de forma independiente en [[TS-010A_Recepcion_Trazable_Materiales]].

La infraestructura común de identidad, ubicación, actor, tiempo, motivo e idempotencia se introducirá con el mínimo alcance requerido por este flujo. Sus detalles de persistencia y API se definen en la Tech Spec de esta historia.

## 2. Historia de Usuario

**Como** responsable de almacén y calidad  
**Quiero** registrar la recepción física de materias primas y colorantes por proveedor, documento y lote  
**Para** conocer qué ingresó, cuánto ingresó, dónde se encuentra, si puede utilizarse y cuál es su procedencia.

## 3. Resultado de Negocio

Al terminar esta historia, el sistema debe poder responder sin revisar papeles externos:

1. ¿Qué material ingresó?
2. ¿Quién lo suministró?
3. ¿Con qué documento y lote del proveedor llegó?
4. ¿Cuánto se recibió y en qué unidad?
5. ¿Cuándo, dónde y por quién fue recibido?
6. ¿Está pendiente, liberado, bloqueado o rechazado por Calidad?
7. ¿Cuánto está disponible y cuánto no disponible?
8. ¿Qué correcciones o movimientos ocurrieron desde la recepción?

## 4. Actores

- **Responsable de recepción/almacén:** crea y modifica borradores, confirma cantidades y estado físico, completa la inspección visual mínima, ubica material y ejecuta rechazos o devoluciones; no edita recepciones confirmadas ni decide su liberación manual.
- **Responsable de calidad:** revisa los criterios aplicables y libera, bloquea o rechaza cantidades totales o parciales. También administra las autorizaciones de liberación directa junto con Gerencia.
- **Gerencia:** aprueba las órdenes de compra, coautoriza políticas de liberación directa, resuelve discrepancias de conteo de material virgen y aprueba toda corrección compensatoria posterior a una recepción confirmada en v1.
- **Supervisor:** regulariza entradas documentales; no aprueba correcciones de recepciones confirmadas en v1.
- **Auditor o jefe de planta:** consulta la procedencia, estados e historial sin alterar registros.

Los actores deben resolverse mediante `Trabajador` y roles normalizados. Los nombres visibles se conservan también como snapshots históricos cuando corresponda.

Durante el desarrollo previo a la autenticación humana, el `Trabajador` elegido
es un actor declarado para probar las reglas del flujo; no demuestra quién inició
sesión. La autorización server-side basada en identidad verificada será un gate
transversal de cierre y no debe simularse confiando en un campo `rol` del frontend.

## 5. Lenguaje de Dominio Funcional

Esta sección define conceptos de negocio, no tablas ni contratos técnicos.

### 5.1. Definición de material

Es el artículo que se recibe, por ejemplo una `MateriaPrima` o un `Colorante`. El catálogo define qué es; no representa una existencia física concreta.

### 5.2. Recepción

Es el acto documentado mediante el cual uno o más materiales ingresan a custodia de la fábrica desde un proveedor.

Una recepción puede contener varias líneas y una línea documental puede requerir separación si físicamente llegaron lotes de proveedor distintos.

En el flujo ordinario de compra, la recepción se vincula a una o más líneas de OC aprobadas. Una OC puede recibirse parcialmente y una misma guía puede distribuir cantidades entre varias OC.

### 5.3. Lote de material

Es la existencia física identificable de un único material con procedencia conocida y una identidad interna propia.

No se debe inventar un supuesto lote de proveedor. En la operación actual normalmente no se recibe ese dato. Por ello toda recepción crea un lote interno y clasifica el dato externo como `INFORMADO`, `NO_INFORMADO` o `ILEGIBLE`.

Para v1 la ausencia de lote externo no bloquea por sí sola una materia prima cuando la política de su categoría lo declara opcional. Se intentará capturarlo desde la bolsa o etiqueta para mejorar trazabilidad futura. Solo una categoría configurada expresamente con lote obligatorio queda bloqueada cuando falta o es ilegible.

### 5.4. Ubicación

Es un lugar normalizado de planta. No es un texto libre ni forma parte de la identidad del lote. Un lote puede cambiar de ubicación o distribuir su cantidad entre ubicaciones sin convertirse silenciosamente en otro material.

El catálogo es común para la planta, pero cada ubicación declara su propósito de inventario. Como mínimo se distinguen los ámbitos `MATERIA_PRIMA`, `PIEZA_COLOR` y `PRODUCTO_TERMINADO`; compartir la palabra “almacén” no vuelve compatibles sus existencias.

US-010A solo administra ubicaciones de materias primas. Sus tipos funcionales iniciales son:

- recepción/cuarentena de materias primas;
- almacén de resinas;
- almacén de masterbatch, colorantes y aditivos;
- materias primas bloqueadas;
- materias primas rechazadas o pendientes de devolución;
- material recuperado para reproceso.

Gerencia y Almacén todavía deben proporcionar los nombres, códigos y jerarquía reales de zonas, racks, silos o posiciones. Los almacenes de piezas y de productos terminados son físicamente distintos y se completarán en sus historias de inventario correspondientes.

### 5.5. Estado de calidad

Determina si una cantidad puede utilizarse en producción. Es independiente de su ubicación y de la existencia física.

Estados aprobados para primera versión:

- `PENDIENTE`: recibido, todavía no liberado.
- `LIBERADO`: disponible para reserva o consumo.
- `BLOQUEADO`: existe, pero no puede utilizarse.
- `RECHAZADO`: se determinó que no es apto y espera devolución o disposición.

El estado se aplica a cantidades identificadas dentro del lote, no necesariamente al lote completo. Una misma identidad de lote puede tener cantidades simultáneamente `PENDIENTES`, `LIBERADAS`, `BLOQUEADAS` o `RECHAZADAS`, siempre separadas por cantidad y ubicación sin perder genealogía.

### 5.6. Disponibilidad

Es una cantidad derivada del estado físico, logístico, documental y de calidad. Que un lote exista en almacén no significa automáticamente que esté disponible para producción. Solo una cantidad `LIBERADA`, físicamente existente y sin otra retención puede reservarse o consumirse.

### 5.7. Retención documental

Impide utilizar material cuya entrada física todavía no cuenta con una OC o excepción regularizada. Es independiente del estado de Calidad: retirar la retención documental no libera por sí solo el material para producción.

### 5.8. Corrección compensatoria

Un borrador puede modificarse antes de confirmar porque todavía no produjo inventario. Una recepción confirmada es inmutable: cualquier corrección se representa con un evento enlazado que conserva valores anteriores, nuevos valores, responsable, autorizador, motivo y evidencia.

Una corrección de cantidad ajusta inventario mediante movimientos compensatorios. Una corrección de procedencia —proveedor, material o lote— actualiza la proyección mediante evidencia enlazada, sin borrar el dato originalmente capturado ni duplicar existencia.

### 5.9. Rechazo en recepción y devolución

- **Rechazo en recepción:** ocurre antes de aceptar custodia. Registra el intento y su motivo, pero no crea inventario ni `LoteMaterial` recibido.
- **Devolución a proveedor:** ocurre después de confirmar la recepción o sobre una parte ya recibida. Requiere identificar y bloquear/rechazar la cantidad física, registrar su salida y conservar la recepción original.

### 5.10. Orden interna de compra de material

EnvaPerú no posee hoy una fuente estandarizada anterior a la Orden de Producción que demuestre la autorización de compra. Para la primera versión, el propio sistema será la fuente autoritativa de una `OrdenCompraMaterial` mínima y no financiera.

La orden interna:

- identifica proveedor, solicitante, aprobador, fechas y estado;
- contiene líneas con material de catálogo, cantidad autorizada y unidad;
- conserva un número interno único y una identidad estable por línea;
- calcula saldo documental desde recepciones confirmadas y rechazos previos a custodia;
- admite entregas parciales;
- no administra precios, impuestos, cuentas por pagar ni evaluación comercial.

Estados funcionales mínimos: `BORRADOR`, `PENDIENTE_APROBACION`, `APROBADA`, `PARCIALMENTE_RECIBIDA`, `CERRADA` y `CANCELADA`. Solo una orden `APROBADA` o `PARCIALMENTE_RECIBIDA` con saldo habilita una recepción ordinaria. Una orden aprobada no se sobrescribe: se cancela o revisa conservando el historial.

### 5.11. Documento externo del proveedor

La guía de remisión, factura, nota o documento equivalente prueba lo declarado y trasladado por el proveedor. No prueba por sí solo que EnvaPerú autorizó la compra, aceptó custodia, midió el peso neto, verificó el lote ni liberó el material.

Se conserva como evidencia estructurada y adjunto:

- tipo, serie, número, emisor y fecha de emisión;
- fecha de traslado y motivo cuando corresponda;
- referencias externas como pedido o factura;
- origen, destino y datos de transporte cuando existan;
- líneas crudas con código, descripción, cantidad y unidad declaradas por el proveedor;
- archivo o fotografía, tipo MIME, tamaño, hash y actor que lo incorporó.

Los datos personales de transportista, licencia y firma se tratan como evidencia restringida; no se replican en listados generales ni se incorporan al dataset de pruebas.

### 5.12. Recepción interna de material

`RecepcionMaterial` es el acta interna de EnvaPerú que confronta la orden autorizada, el documento externo y el hecho físico. Posee número interno, responsable, momento, ubicación, inspección, lotes y cantidades documentales, nominales y medidas.

Confirmarla significa aceptar custodia y crear inventario exactamente una vez. El documento externo permanece enlazado, pero no se convierte en la identidad de la recepción ni del lote.

### 5.13. Catálogo interno de proveedores

El sistema mantiene un proveedor con ID interno inmutable, código visible, razón social, identificador tributario cuando corresponda y estado activo. Una guía puede proponer datos para revisión, pero nunca crea o cambia silenciosamente la identidad maestra del proveedor.

### 5.14. Modalidad y Autoridad de Cantidad Recibida

La cantidad que incrementa inventario depende de una modalidad explícita:

- `VIRGEN_CONFIANZA_PROVEEDOR`: EnvaPerú no vuelve a pesar la resina virgen. La cantidad aceptada procede de la guía y del conteo/peso nominal de bolsas. Se conserva `fuente_cantidad = DOCUMENTO_PROVEEDOR` y el peso neto interno queda `NO_MEDIDO`.
- `SEGUNDA_PESAJE_BOLSA`: el material de segunda se pesa bolsa por bolsa en una balanza de planta. Cada peso se anota manualmente y la cantidad aceptada es la suma. La futura UI debe permitir transcribir el detalle o su total conciliado, vinculando balanza, actor y evidencia de la hoja manual.

Confiar en el proveedor es una política operativa visible, no un pesaje ficticio. El valor documental nunca se copia al campo de medición interna.

## 6. Invariantes de Negocio

1. Toda entrada nueva de material debe tener proveedor, material, cantidad, unidad, fecha, ubicación y actor; además, OC y documento físico para compra ordinaria, o motivo y evidencia para entrada excepcional.
2. Toda recepción de compra ordinaria debe imputar sus cantidades a una o más líneas de OC aprobadas sin exceder de forma silenciosa su saldo pendiente.
3. Una entrega parcial no cierra el saldo restante de la OC.
4. Una entrada excepcional sin OC puede reconocer existencia física únicamente si registra responsable, motivo administrable y al menos una evidencia disponible: documento, foto o constancia de autorización.
5. Toda entrada sin OC queda bajo retención documental y no disponible hasta su regularización, independientemente de su estado de Calidad.
6. Solo un supervisor puede retirar la retención documental vinculando una OC aprobada o aprobando expresamente la excepción; la decisión queda en el historial.
7. Todo lote físico debe tener una identidad interna global y no reutilizable.
8. Un lote de material representa un solo material; no se mezclan referencias distintas bajo una identidad común.
9. Recepciones o lotes internos distintos no se fusionan antes de una transformación documentada. La mezcla física posterior puede perder granularidad, pero esa pérdida pertenece a US-010B y debe declararse.
10. El lote del proveedor nunca se inventa. Se registra como `INFORMADO`, `NO_INFORMADO` o `ILEGIBLE`; solo una política de categoría con lote obligatorio convierte su ausencia en bloqueo.
11. Se captura foto de la bolsa o etiqueta cuando esté disponible. Para una categoría con lote opcional, la ausencia de foto o código externo no impide por sí sola la recepción ni la decisión de Calidad.
12. La cantidad confirmada debe ser positiva y expresable en una unidad autorizada para el material.
13. La cantidad que incrementa inventario procede de la modalidad: documento/conteo nominal para virgen bajo confianza del proveedor, o suma del pesaje manual bolsa por bolsa para material de segunda.
14. Toda diferencia entre cantidad esperada y medida permanece visible. No se clasifica automáticamente como merma ni se bloquea usando un porcentaje global supuesto; una política aprobada por categoría y modalidad sí puede clasificarla dentro o fuera de tolerancia.
15. Una recepción en borrador no incrementa inventario.
16. Confirmar una recepción produce inventario físico exactamente una vez.
17. Reintentar la misma operación no puede duplicar lotes, cantidades ni movimientos.
18. El material con retención documental o estado `PENDIENTE`, `BLOQUEADO` o `RECHAZADO` no está disponible para nuevas reservas o consumos.
19. Almacén registra como inspección mínima identidad del material y grado esperado, lote cuando corresponda, integridad del empaque y ausencia de contaminación visible.
20. Certificado, muestra o ensayo adicional solo se exige mediante una política aprobada para la categoría de material; no se incrusta una exigencia universal inexistente.
21. Toda cantidad recibida se crea primero como `PENDIENTE`. Solo Calidad puede decidir manualmente su liberación, bloqueo o rechazo.
22. Una política de liberación directa requiere una combinación específica de material y proveedor aprobada por Calidad y Gerencia, debe quedar versionada y puede retirarse.
23. La liberación directa es una transición auditada de `PENDIENTE` a `LIBERADO` dentro de la confirmación; solo se ejecuta si la inspección mínima y los requisitos de categoría se cumplen y no existe retención documental ni una política que bloquee por lote externo.
24. Retirar una política de liberación directa afecta recepciones futuras. Los lotes ya liberados solo cambian mediante una nueva decisión explícita de Calidad.
25. Calidad puede resolver una parte del lote si registra cantidad, ubicación, estado destino, responsable, momento y motivo.
26. Una resolución parcial deja en `PENDIENTE` toda cantidad no resuelta.
27. Para la existencia física actual del lote se cumple: `PENDIENTE + LIBERADO + BLOQUEADO + RECHAZADO = existencia física`, sumando todas sus ubicaciones. Una devolución, consumo o disposición reduce la existencia mediante su propio evento, no mediante la decisión de Calidad.
28. Liberar, bloquear o rechazar reclasifica cantidades; no cambia por sí mismo la existencia total ni la procedencia.
29. Un movimiento interno cambia ubicación, no procedencia, material ni cantidad total de planta.
30. Ninguna operación puede producir existencias negativas ni reclasificar más cantidad que la existente en el estado y ubicación de origen.
31. Una recepción confirmada no se edita ni elimina destructivamente.
32. Toda corrección posterior se registra mediante anulación o evento compensatorio, con actor y motivo.
33. El historial debe conservar qué ocurrió, quién lo hizo, dónde, cuándo y por qué.
34. Los registros legacy no conciliables se marcan como tales; no se completan con datos inventados.

### 6.1. Invariantes Aprobados de Documentos de Compra y Recepción

1. La `OrdenCompraMaterial` aprobada es la autorización interna de compra para v1; la guía, factura o pedido del proveedor no la reemplazan.
2. Una guía puede respaldar varias líneas u órdenes internas y una orden puede recibirse mediante varias guías, sin perder las imputaciones por cantidad.
3. Se impide confirmar dos veces el mismo documento externo para el mismo emisor, tipo, serie y número, salvo que la recepción anterior haya quedado únicamente en borrador o rechazo previo a custodia.
4. El saldo de una línea se deriva de la cantidad autorizada menos recepciones confirmadas. Un rechazo previo a custodia no consume saldo; una devolución posterior no lo reabre automáticamente.
5. El peso bruto o cantidad de una guía no se registran como medición de EnvaPerú. Para virgen pueden ser autoridad de cantidad mediante `VIRGEN_CONFIANZA_PROVEEDOR`, conservando que no hubo pesaje interno.
6. El lote del proveedor solo se obtiene de etiqueta, envase, certificado u otra evidencia específica. No se deduce desde descripción, código, pedido, factura o guía; su ausencia queda explícita y no bloquea salvo política contraria.
7. Si no existe una orden interna aprobada, la llegada solo puede registrarse como entrada excepcional con retención documental.
8. Cuando el sistema no está disponible, el papel o fotografía se conserva como evidencia provisional; al recuperar servicio se registra una única operación idempotente. La indisponibilidad no convierte la guía en una OC aprobada.
9. Los adjuntos conservan integridad mediante hash y metadatos, pero los campos críticos se capturan estructuradamente para consulta y validación.
10. La recepción interna, la orden interna y el documento externo conservan identidades independientes y relaciones explícitas.

### 6.2. Capacidades y Segregación de Funciones Objetivo

Las capacidades funcionales mínimas son `PROVEEDOR_ADMINISTRAR`, `OC_CREAR`, `OC_APROBAR`, `RECEPCION_CONFIRMAR`, `ENTRADA_EXCEPCIONAL_REGULARIZAR`, `CALIDAD_RESOLVER`, `LIBERACION_DIRECTA_ADMINISTRAR`, `CORRECCION_SOLICITAR`, `CORRECCION_APROBAR`, `DEVOLUCION_REGISTRAR` y `CONFIG_RECEPCION_ADMINISTRAR`.

Reglas de segregación:

1. Gerencia aprueba la orden y debe ser un actor distinto de quien la creó.
2. Quien confirma una recepción no realiza la liberación manual de Calidad sobre esa recepción.
3. Quien registra una entrada excepcional no la regulariza.
4. Quien solicita una corrección no aprueba su propia solicitud.
5. Una política de liberación directa exige dos aprobaciones distintas: Calidad y Gerencia.
6. Una misma persona puede poseer varias capacidades, pero las operaciones anteriores exigen actores distintos.

Hasta el enabler de autenticación humana, las pruebas usan actores declarados y verifican estas reglas de dominio. Su enforcement con sesión e identidad verificable sigue siendo gate obligatorio antes de producción multiusuario.

### 6.3. Invariantes Aprobados de Ubicación y Tolerancia

1. Toda ubicación se selecciona desde un catálogo controlado, activo y jerárquico; no se crean destinos escribiendo nombres libres durante una recepción o movimiento.
2. Una ubicación declara el tipo de inventario que admite. Una materia prima no puede ingresar en un almacén de piezas o de producto terminado.
3. Las zonas de materias primas bloqueadas o rechazadas no sustituyen el estado de Calidad: mover una cantidad no la bloquea y bloquearla no cambia automáticamente su ubicación.
4. Desactivar o renombrar una ubicación no modifica movimientos históricos; únicamente impide nuevos movimientos incompatibles.
5. La política de tolerancia de recepción se define por categoría de material y modalidad de recepción, con vigencia e identidad propias. No existe una tolerancia global implícita.
6. Para virgen en sacos cerrados se conservan cantidad documental, conteo recibido, peso nominal y cantidad aceptada, con `peso_interno = NO_MEDIDO` y fuente `DOCUMENTO_PROVEEDOR`.
7. Para material de segunda se registra un pesaje manual por bolsa en una balanza, o la transcripción conciliada de la hoja manual; la suma gobierna el inventario y se compara con la cantidad documental.
8. Cuando existe pesaje interno, se conserva diferencia absoluta y porcentual y se confirma usando la suma medida. Cuando no existe por política de confianza, la cantidad documental/nominal gobierna sin fingir una diferencia medida.
9. Fuera de tolerancia no existe aceptación ordinaria silenciosa: se requiere una autorización explícita para aceptar la cantidad medida o una decisión de rechazo.
10. Si no existe política activa para material de segunda, la diferencia se registra como `SIN_POLITICA`, la suma pesada gobierna el inventario y no se aplica un umbral inventado. Esto no bloquea por sí solo la confirmación.
11. Las tolerancias de recepción son independientes de la tolerancia de pesaje de bultos de producción y de la tolerancia de balance de masa.
12. Para material virgen, si el conteo de bolsas coincide con el documento y el peso nominal, la cantidad documental se acepta sin pesaje interno. Toda discrepancia de conteo requiere decisión explícita de Gerencia para aceptar la cantidad documentada, aceptar la cantidad nominal efectivamente contada o rechazar la entrega.

### 6.4. Invariantes Aprobados de Corrección y Devolución

1. Almacén puede modificar o descartar borradores sin afectar inventario; una recepción confirmada no admite edición ni eliminación directa.
2. Toda corrección de una recepción confirmada requiere evento compensatorio enlazado, solicitud separada, aprobación de Gerencia, motivo y evidencia.
3. En v1 no existen rangos delegados por cantidad o valor: ninguna corrección confirmada puede ser aprobada solamente por Almacén o Supervisión.
4. Una futura delegación de límites requerirá una nueva política versionada y no cambiará retroactivamente las aprobaciones anteriores.
5. Una compensación negativa no puede exceder la existencia física corregible ni retirar cantidad ya consumida, devuelta o dispuesta; los efectos posteriores requieren correcciones enlazadas en sus propios eventos.
6. Corregir proveedor, material o lote externo no sobrescribe la captura original: conserva ambos valores, evidencia, autorizaciones y vínculo de corrección.
7. Un rechazo previo a custodia registra proveedor, documento, material, cantidades conocidas, lote si está disponible, responsable, momento, motivo y evidencia, sin incrementar inventario.
8. Después de confirmar, una devolución requiere cantidad y ubicación actuales, estado `BLOQUEADO` o `RECHAZADO`, documento/motivo, evidencia, responsable y proveedor destinatario.
9. Una devolución total o parcial reduce existencia mediante un movimiento de salida; no cambia ni elimina la cantidad originalmente recibida del historial.
10. No se puede devolver más cantidad que la existencia física actual en las ubicaciones seleccionadas.
11. La devolución no reabre ni modifica silenciosamente saldos de OC; cualquier efecto comercial se comunica al sistema dueño de compras según la integración definida.
12. Correcciones, rechazos y devoluciones son idempotentes: un reintento no duplica compensaciones ni salidas.

## 7. Flujo Funcional

### 7.1. Preparar la recepción

1. Seleccionar proveedor y modalidad de entrada: compra ordinaria o entrada excepcional.
2. Para una compra ordinaria, seleccionar una o más `OrdenCompraMaterial` aprobadas con saldo pendiente.
3. Para una entrada excepcional, registrar motivo administrable y al menos una evidencia disponible.
4. Registrar el documento externo del proveedor, sus referencias y líneas crudas; en una entrada excepcional esto no reemplaza el motivo ni la evidencia exigidos.
5. Registrar fecha y responsable.
6. Añadir una o más líneas de material e imputar cada cantidad ordinaria a su línea de OC correspondiente.
7. Intentar capturar el lote desde bolsa o etiqueta y registrar `INFORMADO`, `NO_INFORMADO` o `ILEGIBLE`; bloquear solo si la política lo exige.
8. Seleccionar modalidad `VIRGEN_CONFIANZA_PROVEEDOR` o `SEGUNDA_PESAJE_BOLSA` y registrar por separado cantidad documental, empaque nominal, peso bruto declarado y medición interna cuando corresponda.
9. Seleccionar una ubicación inicial activa y compatible con materias primas.
10. Guardar como borrador o confirmar.

### 7.1.1. Crear y aprobar la orden interna

1. Compras selecciona un proveedor activo y añade líneas con materiales existentes, cantidades y unidades autorizadas.
2. Guarda `BORRADOR` o envía a `PENDIENTE_APROBACION`.
3. Un actor distinto con capacidad `OC_APROBAR` aprueba, observa o rechaza la revisión.
4. La aprobación congela la revisión recibible y abre el saldo de cada línea.
5. Cambios posteriores crean una revisión o cancelación auditada; no reescriben lo ya aprobado o recibido.

### 7.2. Confirmar la recepción

1. Validar campos obligatorios, cantidades e imputaciones contra OC en el flujo ordinario, o motivo y evidencia en el excepcional.
2. Conservar cantidades documentales, nominales y medidas por separado y elegir la cantidad de inventario según la modalidad aprobada.
3. Evaluar la política de tolerancia de la categoría y modalidad antes de completar una aceptación ordinaria.
4. Asignar identidad interna a cada lote físico.
5. Registrar el ingreso de inventario de forma atómica.
6. Aplicar retención documental a toda entrada sin OC.
7. Bloquear por lote externo ausente o ilegible únicamente cuando la política de categoría lo declare obligatorio.
8. Crear las demás cantidades en `PENDIENTE` y registrar la inspección mínima realizada por Almacén.
9. Si existe una política activa de liberación directa y se cumplen todos sus requisitos, registrar inmediatamente la transición auditada a `LIBERADO`.
10. Entregar una confirmación consultable y apta para identificación física.

### 7.3. Resolver Calidad

1. Consultar el lote recibido, su procedencia, inspección de Almacén y requisitos de su categoría.
2. Seleccionar cantidad y ubicación sobre las que se decide.
3. Registrar estado destino, responsable, momento y motivo.
4. Reclasificar únicamente la cantidad indicada como `LIBERADA`, `BLOQUEADA` o `RECHAZADA`.
5. Mantener como `PENDIENTE` la cantidad no resuelta.
6. Verificar que la suma por estados y ubicaciones coincida con la existencia física actual.
7. Recalcular disponibilidad sin alterar cantidad total, procedencia ni historial.

### 7.4. Ubicar o mover

1. Identificar el lote y la cantidad a mover.
2. Validar ubicación de origen y destino, actividad y compatibilidad de inventario.
3. Rechazar ubicaciones libres o destinos de piezas/producto terminado para una materia prima.
4. Registrar el movimiento.
5. Conservar el total de planta y la genealogía.

### 7.5. Regularizar una entrada sin OC

1. Consultar la entrada retenida, su responsable, motivo y evidencia.
2. Un supervisor vincula una OC aprobada o aprueba expresamente la excepción.
3. Registrar la decisión como evento no destructivo.
4. Retirar la retención documental sin modificar automáticamente el estado de Calidad.

### 7.6. Administrar liberación directa

1. Calidad y Gerencia autorizan una combinación específica de material y proveedor, junto con los requisitos de categoría aplicables.
2. Registrar vigencia, aprobadores y versión de la política.
3. En cada recepción elegible, conservar qué versión justificó la transición directa a `LIBERADO`.
4. Permitir retirar la política para recepciones futuras sin alterar retroactivamente lotes anteriores.

### 7.7. Evaluar Diferencias de Recepción

1. Calcular la cantidad esperada desde documento, conteo y peso nominal sin reemplazar la medición real.
2. Calcular diferencia en kg y, cuando la cantidad documentada sea positiva, su porcentaje.
3. Buscar la política activa para la categoría y modalidad de recepción.
4. Si cumple todos los límites aplicables, confirmar y conservar medición, diferencia y versión de política.
5. Si excede algún límite, exigir una decisión autorizada de aceptación por cantidad medida o rechazo; Almacén no puede omitir la discrepancia.
6. Si no existe política, registrar `SIN_POLITICA` y aplicar `A-PES-01` sin inventar tolerancias.

### 7.8. Corregir una Recepción

1. Si está en borrador, Almacén modifica o descarta el registro sin generar inventario.
2. Si está confirmada, rechazar cualquier edición o eliminación directa.
3. Registrar la corrección solicitada, motivo y evidencia, y calcular su impacto en cantidad o procedencia.
4. Validar la existencia corregible y que quien solicita no sea quien aprueba.
5. Obtener autorización de Gerencia antes de aplicar.
6. Registrar atómicamente el evento compensatorio y su vínculo al hecho original.
7. Conservar la recepción inicial y mostrar la proyección corregida junto con el historial completo.

### 7.9. Rechazar o Devolver al Proveedor

1. Determinar si EnvaPerú ya aceptó la custodia mediante la confirmación de recepción.
2. Antes de custodia, registrar `RECHAZO_RECEPCION` con motivo y evidencia, sin crear inventario.
3. Después de confirmar, seleccionar cantidad y ubicación física actuales y bloquearla o rechazarla.
4. Registrar `DEVOLUCION_PROVEEDOR` como movimiento total o parcial de salida, reduciendo la existencia exactamente una vez.
5. Conservar recepción, lote, decisiones de Calidad y devolución en una misma cadena de trazabilidad.
6. No modificar saldos comerciales de OC sin una integración explícita con el sistema de compras.

### 7.10. Conciliar el documento externo

1. Identificar emisor, tipo, serie y número y verificar que no exista una confirmación duplicada.
2. Capturar las líneas del proveedor sin normalizarlas destructivamente.
3. Relacionar cada cantidad recibida con una línea de orden interna y un material controlado.
4. Mostrar diferencias de código, descripción, unidad, cantidad y empaque sin asumir equivalencia.
5. Capturar lote desde bolsa/etiqueta cuando exista y aplicar la modalidad de cantidad; no inventar lote ni copiar un valor documental como pesaje interno.
6. Conservar el adjunto con hash y restringir datos personales de transporte.

## 8. Dataset Canónico de Aceptación

Los siguientes datos son ficticios y solo sirven para especificar ejemplos reproducibles:

| Dato | Valor de prueba |
|---|---|
| Proveedor | `PROV-TEST-01` - Polímeros de Prueba |
| Orden de compra aprobada | `OC-TEST-0100`, línea 1, saldo `1,250.000 kg` |
| Documento | Guía `GR-4587` |
| Material | `MP-PP-HOMO` - Polipropileno homopolímero |
| Lote proveedor | `PP-260701-A` |
| Envases | `25` bolsas de peso nominal `25.000 kg` |
| Cantidad neta | `625.000 kg` |
| Ubicación inicial | `REC-CUARENTENA` |
| Ubicación liberada | `ALM-MP-01` |
| Responsable recepción | `TRB-TEST-01` |
| Responsable calidad | `TRB-TEST-02` |
| Inspección mínima | Identidad, lote, empaque y ausencia de contaminación: conformes |
| Requisito adicional de categoría | Ninguno para el ejemplo |
| Política de liberación directa | Ninguna activa para el ejemplo principal |
| Política de tolerancia de recepción | Ninguna activa para el ejemplo principal |
| Clave de operación | `EVT-REC-0001` |
| Documento externo | `GUIA_REMISION`, emisor `PROV-TEST-01`, serie `T001`, número `00001001` |

Resultados esperados del ejemplo principal:

- inventario físico después de confirmar: `625.000 kg`;
- inventario disponible antes de liberar: `0.000 kg`;
- inventario disponible después de liberar: `625.000 kg`;
- segundo envío de `EVT-REC-0001`: no modifica ningún total;
- saldo restante de la línea de OC: `625.000 kg`;
- trazabilidad hacia atrás: material -> lote interno -> lote proveedor -> documento -> línea de OC -> proveedor.

## 9. Escenarios de Aceptación ATDD/BDD

### REC-01: Confirmar una recepción de un lote

**Dado** el dataset canónico, la OC aprobada y una recepción válida en borrador  
**Cuando** el responsable confirma la recepción  
**Entonces** se crea un lote interno trazable por `625.000 kg`  
**Y** se registra una sola entrada de inventario  
**Y** la recepción queda imputada a la línea de OC sin cerrar su saldo restante  
**Y** el lote queda en `PENDIENTE`  
**Y** su cantidad disponible es `0.000 kg`.

### REC-02: Un borrador no afecta inventario

**Dado** una recepción todavía no confirmada  
**Cuando** se consulta el inventario  
**Entonces** sus líneas no aparecen como existencia física ni disponible.

### REC-03: Separar lotes de proveedor en una misma recepción

**Dado** una guía con el mismo material en los lotes `PP-260701-A` y `PP-260702-B`  
**Cuando** se confirma la recepción  
**Entonces** el sistema conserva dos identidades internas y dos genealogías  
**Y** puede mostrar el total agregado sin fusionar los lotes.

### REC-04: Registrar material cuyo lote obligatorio es ilegible

**Dado** que una categoría exige lote de proveedor y la etiqueta recibida es ilegible  
**Y** el responsable adjunta una foto de la etiqueta  
**Cuando** confirma la llegada física  
**Entonces** se genera un lote interno sin inventar un código externo  
**Y** el lote de proveedor queda marcado como ilegible  
**Y** la cantidad queda `BLOQUEADA` y no disponible.

### REC-05: Rechazar cantidad inválida

**Dado** una línea con cantidad cero, negativa o unidad no autorizada  
**Cuando** se intenta confirmar  
**Entonces** la recepción permanece sin confirmar  
**Y** no se crea inventario parcial.

### REC-06: Reintento idempotente

**Dado** que `EVT-REC-0001` ya confirmó la recepción  
**Cuando** el cliente reenvía exactamente la misma operación por pérdida de conexión  
**Entonces** recibe el mismo resultado lógico  
**Y** siguen existiendo un lote y una entrada por `625.000 kg`.

### REC-07: Conflicto usando una clave de operación repetida

**Dado** que `EVT-REC-0001` ya fue procesado  
**Cuando** se reenvía esa clave con material o cantidad diferente  
**Entonces** el sistema rechaza el conflicto  
**Y** conserva intacta la operación original.

### REC-08: Liberar un lote

**Dado** el lote canónico en `PENDIENTE`  
**Y** Almacén registró conformes la identidad, lote, empaque y ausencia de contaminación visible  
**Y** se cumplieron los requisitos adicionales de su categoría  
**Cuando** un responsable autorizado de Calidad lo marca `LIBERADO`  
**Entonces** `625.000 kg` quedan disponibles  
**Y** se conserva quién tomó la decisión, cuándo y con qué evidencia.

### REC-09: Bloquear un lote liberado

**Dado** un lote liberado con cantidad no consumida  
**Cuando** Calidad lo bloquea con un motivo  
**Entonces** esa cantidad deja de estar disponible para nuevas operaciones  
**Y** no se borra la liberación previa  
**Y** el historial muestra ambas decisiones en orden.

### REC-10: Impedir una decisión de Calidad no autorizada

**Dado** un trabajador sin el rol requerido  
**Cuando** intenta liberar, bloquear o rechazar un lote  
**Entonces** la operación es rechazada  
**Y** el estado y la disponibilidad no cambian.

### REC-11: Movimiento interno conserva el total

**Dado** `625.000 kg` del lote en una ubicación válida  
**Cuando** se mueven `400.000 kg` a otra ubicación  
**Entonces** quedan `225.000 kg` en origen y `400.000 kg` en destino  
**Y** el total de planta continúa siendo `625.000 kg`  
**Y** ambas cantidades conservan el mismo origen de lote.

### REC-12: Impedir stock negativo

**Dado** `225.000 kg` en una ubicación  
**Cuando** se intenta mover `226.000 kg`  
**Entonces** no se registra el movimiento  
**Y** las cantidades permanecen sin cambios.

### REC-13: Corregir sin edición destructiva

**Dado** una recepción confirmada con `625.000 kg` que debió ser `620.000 kg`  
**Y** Almacén solicita una corrección de `-5.000 kg` con motivo y evidencia  
**Cuando** Gerencia aprueba y el sistema aplica la corrección  
**Entonces** la existencia resultante es `620.000 kg`  
**Y** la recepción original permanece visible  
**Y** el historial vincula la compensación, evidencia y autorización con el evento original.

### REC-14: Consultar trazabilidad hacia atrás

**Dado** un lote o existencia seleccionada  
**Cuando** el auditor solicita su procedencia  
**Entonces** obtiene material, lote interno, lote de proveedor, recepción, documento, líneas de OC, proveedor, responsables y eventos  
**Y** los datos faltantes legacy se muestran como desconocidos, no como valores inferidos.

### REC-15: Fallo atómico durante la confirmación

**Dado** una recepción con varias líneas válidas  
**Cuando** falla la confirmación antes de terminar todas las líneas  
**Entonces** no queda una recepción parcialmente aplicada al inventario  
**Y** el reintento puede procesarse de forma segura.

### REC-16: Registrar una entrega parcial de OC

**Dado** una línea de OC aprobada con saldo de `1,250.000 kg`  
**Cuando** se confirma una recepción válida de `625.000 kg`  
**Entonces** la recepción queda vinculada a esa línea por `625.000 kg`  
**Y** la línea conserva un saldo pendiente de `625.000 kg`  
**Y** la OC no se marca como recibida completamente.

### REC-17: Relacionar una guía con más de una OC

**Dado** una guía válida cuyas líneas corresponden a dos OC aprobadas del mismo proveedor  
**Cuando** se confirma la recepción con sus imputaciones explícitas  
**Entonces** cada cantidad queda vinculada a la línea de OC correspondiente  
**Y** la guía se conserva como un único documento físico de recepción  
**Y** no se fusionan los saldos ni la genealogía de las OC.

### REC-18: Conservar cantidad nominal y peso medido

**Dado** `25` bolsas nominales de `25.000 kg`, equivalentes a `625.000 kg` esperados  
**Y** un peso neto medido de `624.850 kg`  
**Y** no existe una política de tolerancia activa para esa categoría y modalidad  
**Cuando** se confirma la recepción  
**Entonces** el inventario físico aumenta en `624.850 kg`  
**Y** se conservan el conteo, el peso nominal, el peso esperado y el peso medido como hechos distintos  
**Y** queda visible una diferencia de `-0.150 kg`  
**Y** la diferencia queda `SIN_POLITICA`, sin clasificarse como merma ni evaluarse con un porcentaje supuesto.

### REC-19: Registrar una entrada excepcional sin OC

**Dado** que un material llegó sin OC  
**Y** el responsable selecciona un motivo administrado y adjunta una evidencia disponible  
**Cuando** confirma la llegada física  
**Entonces** se crea la existencia exactamente una vez  
**Y** queda bajo retención documental  
**Y** su cantidad disponible para producción es `0.000 kg`.

### REC-20: Regularizar una entrada excepcional

**Dado** una entrada bajo retención documental  
**Cuando** un supervisor la vincula a una OC aprobada o aprueba expresamente la excepción  
**Entonces** se retira la retención documental mediante un nuevo evento auditable  
**Y** no se borra el motivo ni la evidencia originales  
**Y** el estado de Calidad no cambia automáticamente.

### REC-21: Resolver un lote de proveedor ilegible

**Dado** un lote interno bloqueado porque el lote obligatorio del proveedor era ilegible  
**Cuando** un responsable autorizado registra la identificación confirmada por el proveedor y su evidencia  
**Entonces** la resolución queda vinculada al registro original sin reemplazo destructivo  
**Y** se retira el bloqueo causado por la falta de identificación  
**Y** el material solo queda disponible si cumple además las demás condiciones documentales, logísticas y de Calidad.

### REC-22: Aplicar una liberación directa autorizada

**Dado** una política vigente para la combinación exacta de material y proveedor, aprobada por Calidad y Gerencia  
**Y** la recepción no tiene retenciones y cumple la inspección mínima y requisitos de categoría  
**Cuando** Almacén confirma la recepción  
**Entonces** la cantidad se registra primero como `PENDIENTE` y transiciona inmediatamente a `LIBERADO`  
**Y** queda disponible sin una segunda intervención manual  
**Y** el historial conserva la versión y los aprobadores de la política utilizada.

### REC-23: Retirar una política de liberación directa

**Dado** una política de liberación directa previamente utilizada  
**Cuando** se retira su vigencia mediante una acción autorizada  
**Entonces** una recepción posterior de la misma combinación queda `PENDIENTE`  
**Y** los lotes liberados anteriormente no cambian retroactivamente  
**Y** cualquier bloqueo de esos lotes requiere una decisión explícita de Calidad.

### REC-24: Resolver solo una parte de un lote

**Dado** `625.000 kg` del mismo lote en estado `PENDIENTE` y ubicación conocida  
**Cuando** Calidad libera `400.000 kg` indicando ubicación y motivo  
**Entonces** `400.000 kg` quedan `LIBERADOS` y disponibles  
**Y** `225.000 kg` permanecen `PENDIENTES` y no disponibles  
**Y** ambas cantidades conservan la misma identidad y genealogía de lote  
**Y** la existencia física total continúa siendo `625.000 kg`.

### REC-25: No aplicar liberación directa si falla la inspección mínima

**Dado** una combinación con política de liberación directa vigente  
**Y** Almacén registra empaque dañado o contaminación visible  
**Cuando** confirma la recepción  
**Entonces** no se ejecuta la transición directa a `LIBERADO`  
**Y** la cantidad permanece no disponible a la espera de una decisión de Calidad  
**Y** la incidencia queda conservada como evidencia.

### REC-26: Seleccionar una ubicación compatible de materias primas

**Dado** una línea de recepción de resina y un catálogo global con almacenes de materias primas, piezas y producto terminado  
**Cuando** Almacén selecciona la ubicación inicial  
**Entonces** solo puede elegir ubicaciones activas compatibles con `MATERIA_PRIMA`  
**Y** los almacenes de piezas y producto terminado no aparecen como destinos válidos  
**Y** no puede crear una ubicación escribiendo texto libre.

### REC-27: Impedir mover materia prima al almacén de piezas

**Dado** un lote de resina existente en una ubicación de materias primas  
**Cuando** se intenta moverlo a una ubicación cuyo propósito es `PIEZA_COLOR` o `PRODUCTO_TERMINADO`  
**Entonces** el movimiento es rechazado  
**Y** la cantidad, ubicación de origen y genealogía permanecen intactas.

### REC-28: Recibir dentro de una tolerancia aprobada

**Dado** una política de prueba para material pesado con límites de `2.000 kg` y `0.500%`  
**Y** una cantidad documentada de `625.000 kg` y neta medida de `624.000 kg`  
**Cuando** se evalúa la recepción  
**Entonces** la diferencia absoluta es `1.000 kg` y la porcentual es `0.160%`  
**Y** la recepción queda dentro de ambos límites  
**Y** el inventario aumenta en `624.000 kg`  
**Y** se conservan la diferencia y la versión de política aplicada.

### REC-29: Exigir decisión fuera de tolerancia

**Dado** una política de prueba para material pesado con límites de `2.000 kg` y `0.500%`  
**Y** una cantidad documentada de `625.000 kg` y neta medida de `620.000 kg`  
**Cuando** Almacén intenta completar la aceptación ordinaria  
**Entonces** la diferencia de `5.000 kg` y `0.800%` queda fuera de tolerancia  
**Y** la recepción permanece pendiente de una aceptación autorizada por la cantidad medida o de rechazo  
**Y** no se incrementa inventario silenciosamente.

### REC-30: Conservar conteo y peso de sacos cerrados

**Dado** una guía por `89` sacos nominales de `25.000 kg`  
**Y** Almacén cuenta `88` sacos y obtiene un peso neto medido de `2,199.500 kg`  
**Cuando** registra la recepción  
**Entonces** se conservan por separado `89` sacos documentados, `88` recibidos, peso nominal, cantidades esperadas y peso medido  
**Y** no se modifica ningún valor para forzar coincidencia  
**Y** la diferencia se evalúa mediante la política activa de esa categoría y modalidad.

### REC-31: Modificar un borrador sin afectar inventario

**Dado** una recepción en borrador por `625.000 kg`  
**Cuando** Almacén corrige la cantidad a `620.000 kg` antes de confirmar  
**Entonces** el borrador conserva `620.000 kg`  
**Y** no se crea lote, movimiento ni existencia de inventario.

### REC-32: Impedir editar o borrar una recepción confirmada

**Dado** una recepción confirmada por `625.000 kg`  
**Cuando** Almacén intenta cambiar directamente cantidad, proveedor, material o lote, o eliminar la recepción  
**Entonces** la operación es rechazada  
**Y** la recepción, existencia e historial permanecen intactos  
**Y** se ofrece únicamente el flujo autorizado de corrección compensatoria.

### REC-33: Exigir aprobación de Gerencia para toda corrección confirmada

**Dado** una solicitud compensatoria de `-1.000 kg` con motivo y evidencia  
**Cuando** Almacén o Supervisión intenta aplicarla sin aprobación de Gerencia  
**Entonces** la corrección permanece pendiente y no modifica inventario  
**Y** el sistema conserva la solicitud para la decisión de Gerencia.

### REC-34: Rechazar material antes de aceptar custodia

**Dado** material entregado por un proveedor que todavía no tiene recepción confirmada  
**Cuando** Almacén registra `RECHAZO_RECEPCION` con motivo y evidencia  
**Entonces** se conserva proveedor, documento, material, cantidades conocidas, lote si existe, responsable y fecha  
**Y** no se crea `LoteMaterial`, entrada ni existencia de inventario.

### REC-35: Devolver completamente una recepción confirmada

**Dado** una recepción confirmada con `625.000 kg` físicamente existentes  
**Y** Calidad marcó la cantidad `RECHAZADA` para devolución al proveedor  
**Cuando** Almacén confirma `DEVOLUCION_PROVEEDOR` por `625.000 kg`  
**Entonces** la existencia física actual queda en `0.000 kg`  
**Y** la salida se vincula a proveedor, recepción, lote, documento, responsable, motivo y evidencia  
**Y** la recepción original por `625.000 kg` permanece visible.

### REC-36: Devolver parcialmente un lote recibido

**Dado** `625.000 kg` confirmados del mismo lote  
**Y** `25.000 kg` fueron bloqueados o rechazados en una ubicación conocida  
**Cuando** Almacén registra `DEVOLUCION_PROVEEDOR` por esos `25.000 kg`  
**Entonces** la existencia física actual queda en `600.000 kg`  
**Y** el movimiento conserva la identidad y genealogía del lote  
**Y** no se altera la cantidad originalmente recibida.

### REC-37: Impedir devolver más que la existencia actual

**Dado** que solo quedan `25.000 kg` físicos de un lote después de consumos previos  
**Cuando** se intenta registrar una devolución por `30.000 kg`  
**Entonces** la devolución es rechazada  
**Y** no se crea salida parcial ni stock negativo.

### REC-38: Corregir procedencia sin sobrescribir el dato original

**Dado** una recepción confirmada cuyo lote de proveedor fue capturado como `LOTE-A`  
**Y** evidencia posterior confirma que correspondía a `LOTE-B`  
**Cuando** Gerencia aprueba la corrección solicitada con motivo y evidencia  
**Entonces** la proyección vigente muestra `LOTE-B`  
**Y** el evento original con `LOTE-A` permanece consultable y enlazado  
**Y** no se duplica el lote interno ni la existencia.

### REC-39: Impedir una compensación negativa sobre cantidad ya consumida

**Dado** una recepción de `625.000 kg` de la que solo quedan `25.000 kg` físicos  
**Cuando** se solicita una corrección compensatoria de `-125.000 kg`  
**Entonces** la compensación no se aplica sobre el saldo actual  
**Y** no se produce stock negativo  
**Y** el sistema exige resolver mediante correcciones enlazadas los eventos posteriores afectados.

### REC-40: Crear y aprobar una orden interna antes de recibir

**Dado** una `OrdenCompraMaterial` en `BORRADOR` por `1,250.000 kg`  
**Cuando** su creador intenta aprobar la misma revisión  
**Entonces** el sistema rechaza la autoaprobación  
**Y** un actor distinto con `OC_APROBAR` puede dejarla `APROBADA` y recibible.

### REC-41: La guía del proveedor no sustituye la autorización interna

**Dado** una guía válida del proveedor por `5,000.000 kg`  
**Y** no existe una orden interna aprobada  
**Cuando** Almacén registra la llegada  
**Entonces** no puede confirmarla como compra ordinaria  
**Y** solo puede registrar una entrada excepcional con motivo, evidencia y retención documental.

### REC-42: Conciliar una guía con cantidades y evidencias independientes

**Dado** una guía que declara `5,000.000 KGM`, peso bruto `5,000.000 kg` y `200` bolsas de `25.000 kg`  
**Cuando** Almacén prepara la recepción  
**Entonces** conserva esos valores como datos documentales y nominales  
**Y** deja el peso interno como `NO_MEDIDO` sin copiar el peso bruto  
**Y** no inventa un lote de proveedor ausente del documento.

### REC-43: Reintento del mismo documento externo

**Dado** una recepción confirmada para un emisor, tipo, serie y número de documento externo  
**Cuando** se intenta confirmar otra recepción ordinaria con la misma identidad documental  
**Entonces** el sistema evita la duplicación  
**Y** permite consultar la recepción original o registrar una corrección enlazada.

### REC-44: Recibir material virgen confiando en el proveedor

**Dado** una guía por `200` bolsas vírgenes de `25.000 kg` y `5,000.000 kg` documentados  
**Y** la modalidad `VIRGEN_CONFIANZA_PROVEEDOR`  
**Cuando** Almacén cuenta las `200` bolsas y confirma la recepción sin pesaje interno  
**Entonces** el inventario aumenta en `5,000.000 kg` con fuente `DOCUMENTO_PROVEEDOR`  
**Y** `peso_interno` queda `NO_MEDIDO`  
**Y** el sistema no afirma que EnvaPerú verificó ese peso.

### REC-45: Recibir material de segunda con pesaje manual por bolsa

**Dado** material de segunda entregado en `3` bolsas  
**Y** pesos anotados manualmente de `29.800`, `30.100` y `29.950 kg` en una balanza de planta  
**Cuando** Almacén transcribe y confirma el pesaje  
**Entonces** el inventario aumenta en `89.850 kg`  
**Y** se conservan los tres valores, la balanza, el actor y la evidencia manual  
**Y** la guía permanece como cantidad documental independiente.

### REC-46: Recibir sin lote de proveedor cuando es opcional

**Dado** una materia prima cuya política v1 declara opcional el lote de proveedor  
**Y** la bolsa no muestra un código de lote identificable  
**Cuando** Almacén confirma la recepción con proveedor, documento, material y cantidad válidos  
**Entonces** se crea un lote interno con lote externo `NO_INFORMADO`  
**Y** la ausencia no bloquea por sí sola la decisión posterior de Calidad  
**Y** una foto de la bolsa puede adjuntarse como evidencia sin inventar un código.

## 10. Matriz Inicial de Pruebas

Esta matriz define intención de prueba. Los nombres de módulos, endpoints y componentes se concretan en [[TS-010A_Recepcion_Trazable_Materiales]].

| Nivel | Comportamientos | Escenarios |
|---|---|---|
| Dominio unitario | cantidades, modalidades, tolerancias, compatibilidad, estados parciales, compensaciones, devoluciones, saldos y segregación | REC-05, REC-08, REC-09, REC-12, REC-16, REC-18, REC-19, REC-22, REC-24, REC-25, REC-26, REC-27, REC-28, REC-29, REC-30, REC-31, REC-33, REC-36, REC-37, REC-39, REC-40, REC-42, REC-44, REC-45, REC-46 |
| Integración con BD | confirmación atómica, documentos, pesajes manuales, inventario, saldos de OC, ubicaciones, políticas, correcciones, devoluciones y concurrencia | REC-01, REC-03, REC-07, REC-11, REC-13, REC-15, REC-16, REC-17, REC-18, REC-20, REC-21, REC-22, REC-23, REC-24, REC-27, REC-28, REC-29, REC-32, REC-34, REC-35, REC-36, REC-38, REC-39, REC-40, REC-41, REC-43, REC-44, REC-45, REC-46 |
| Contrato/API | validaciones, permisos, idempotencia, documentos, modalidades, escalamiento y respuestas repetidas | REC-04, REC-06, REC-07, REC-10, REC-17, REC-19, REC-20, REC-21, REC-22, REC-23, REC-27, REC-29, REC-32, REC-33, REC-34, REC-35, REC-37, REC-38, REC-40, REC-41, REC-43, REC-44, REC-45, REC-46 |
| Interfaz | borrador, orden interna, documento externo, pesaje manual, inspección, ubicaciones, tolerancias, correcciones, devoluciones y estados de error | REC-02, REC-04, REC-05, REC-08, REC-18, REC-19, REC-24, REC-25, REC-26, REC-29, REC-30, REC-31, REC-32, REC-33, REC-34, REC-36, REC-41, REC-42, REC-44, REC-45, REC-46 |
| E2E mínimo | aprobar OC -> recibir según modalidad -> validar -> liberar -> mover -> corregir/devolver -> consultar procedencia | REC-01, REC-08, REC-11, REC-13, REC-14, REC-16, REC-19, REC-20, REC-22, REC-26, REC-28, REC-34, REC-35, REC-40, REC-41, REC-42, REC-44, REC-45, REC-46 |

### 10.1. Riesgos que SQLite en memoria no cubre por sí solo

La suite actual del backend utiliza principalmente SQLite en memoria. Es adecuada para pruebas rápidas de dominio y parte de la integración, pero esta historia exige además una suite pequeña contra PostgreSQL para validar:

- restricciones y tipos reales;
- transacciones y rollback;
- concurrencia sobre cantidades;
- unicidad de claves de operación;
- bloqueos o control optimista que eviten stock negativo.

La Tech Spec decidirá el mecanismo, pero no podrá declarar cubierta la idempotencia o concurrencia usando solo mocks.

## 11. Protocolo TDD para US-010A

1. **BASELINE:** ejecutar la suite existente y dejar documentado qué está verde, omitido o roto antes del cambio.
2. **RED:** escoger un único escenario `REC-*`, escribir la prueba en el nivel más bajo que demuestre el comportamiento y comprobar que falla por la razón esperada.
3. **GREEN:** implementar el mínimo comportamiento que haga pasar esa prueba sin romper la regresión.
4. **REFACTOR:** mejorar estructura y nombres manteniendo toda la suite verde.
5. **INTEGRAR:** añadir la prueba del siguiente nivel solo cuando exista un límite real entre componentes.
6. **E2E:** conservar un recorrido principal corto; no duplicar en E2E todas las combinaciones ya cubiertas abajo.

No se considerará TDD válido escribir toda la implementación y añadir pruebas al final. Tampoco se aceptarán mocks que hagan pasar un escenario sin persistir o consultar el estado real que se pretende proteger.

### 11.1. Línea Base Revalidada el 2026-07-21

| Componente | Comando / alcance | Resultado |
|---|---|---|
| Backend, frontend y pesaje | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1 -Component all` | El aislamiento impidió a Vitest leer su configuración después del backend; las suites se completaron por componente. |
| Backend central | El mismo runner, excluyendo E2E legacy, PostgreSQL y el script manual de kardex | `103 passed`, `1 skipped`, `3 deselected`, 20 advertencias legacy/entorno. |
| Frontend central | El mismo runner mediante `npm run test:run` | `9` archivos y `37 passed`; `12` cubren el prototipo US-010A; build Vite verde; ejecución fuera del aislamiento por restricción de esbuild sobre `vite.config.js`. |
| Módulo de pesaje | El mismo runner con entorno virtual propio | `84 passed`, `1 failed`; la prueba intermitente de cierre/reuso de puerto pasó al repetirse aisladamente (`1 passed`). |
| E2E aislado central-pesaje | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-sync-e2e.ps1` | Verde: `12.5 kg` llegaron al backend central y el estado local recibió acuse |

Los avisos del backend corresponden principalmente a `Query.get()` legado de SQLAlchemy y al cache de pytest restringido por el entorno. No bloquean US-010A, pero el código nuevo debe usar `Session.get()`.

Durante esta revalidación se encontraron `.venv` que conservaban un `python.exe` pero habían perdido su runtime base. `test.ps1` ahora comprueba que el intérprete pueda ejecutarse y `bootstrap-tests.ps1` reconstruye un entorno roto; el parámetro `-Python` permite indicar explícitamente un Python `3.12` cuando no está en `PATH`. La política local de Windows bloquea la invocación directa de `.ps1`, por lo que los comandos reproducibles incluyen `-ExecutionPolicy Bypass` solo para el proceso actual.

El E2E legacy completo de OP todavía requiere servidores y datos preparados manualmente. TE-003 ya sustituyó su recorrido crítico de sincronización central-pesaje por `scripts/test-sync-e2e.ps1`, ejecutable con procesos, puertos y bases temporales. Antes de US-010D deberá evolucionarse ese recorrido al futuro contrato idempotente, sin confundir `legacy-v1` con el diseño objetivo. El perfil PostgreSQL permanece opt-in y no se ejecutó en esta revalidación; será obligatorio para las pruebas de transacción, idempotencia y concurrencia de la implementación de US-010A.

## 12. Decisiones de Negocio Validadas

Las diez decisiones del bloque gerencial quedaron confirmadas. La historia permanece `en-refinamiento` hasta completar su validación operativa y técnica:

1. [x] Documentos, OC y tratamiento de entradas excepcionales.
2. [x] Obligatoriedad del lote de proveedor y protocolo ante ausencia o ilegibilidad.
3. [x] Unidades, conversiones controladas y autoridad del peso neto medido.
4. [x] Control de envases/sacos, valores nominales, bruto, tara y neto en primera versión.
5. [x] Inspección mínima, responsabilidad de Almacén y autoridad de Calidad.
6. [x] Estado inicial `PENDIENTE` y liberación directa mediante política material-proveedor aprobada y revocable.
7. [x] Tipos funcionales de ubicación para materias primas y separación de almacenes de piezas/producto terminado.
8. [x] Tolerancias configurables por categoría y modalidad, sin umbral global supuesto.
9. [x] Correcciones compensatorias autorizadas y escalamiento por cantidad o valor.
10. [x] Rechazo antes de custodia y devolución total/parcial después de confirmar.

Estas preguntas son de operación y control. No deben resolverse implícitamente en una migración o componente de interfaz.

### 12.1. Extracción Controlada de la Respuesta A

Fechas de revisión: 2026-07-13 y 2026-07-14.

Para esta extracción solo se consideran validadas las afirmaciones expresamente aceptadas o descritas como práctica real. Las recomendaciones permanecieron como hipótesis hasta la aprobación expresa del 2026-07-14 registrada en la sección 12.6; las demás sugerencias continúan sin aprobarse.

| Decisión | Estado consolidado | Regla validada | Pendiente fuera de esta decisión |
|---|---|---|---|
| 1. Documentos de recepción | Validada para primera versión | La compra ordinaria exige OC aprobada; admite entregas parciales y guía asociada a varias OC. Una entrada sin OC se registra bajo retención documental, con responsable, motivo administrable y evidencia, hasta que un supervisor la regularice. | Los valores iniciales del catálogo de motivos se cargarán como configuración operativa. La retención documental permanece independiente del estado de Calidad. |
| 2. Lote del proveedor | Refinada para primera versión | Normalmente no está disponible. Nunca se inventa; se captura desde bolsa/etiqueta cuando aparezca y se conserva `INFORMADO`, `NO_INFORMADO` o `ILEGIBLE`. Por defecto es opcional y no bloquea; una categoría futura puede exigirlo mediante política. | El formato del lote interno se decidirá en la Tech Spec sin sacrificar unicidad. |
| 3. Unidades y conversiones | Refinada para primera versión | Inventario en kg con tres decimales. Virgen usa documento/conteo nominal bajo confianza del proveedor; segunda usa suma de pesos manuales bolsa por bolsa. Todas las fuentes quedan separadas. | No existe tolerancia global; las políticas se configuran por categoría/modalidad. |
| 4. Bruto, tara, neto y envases | Refinada para primera versión | Se registran envases, peso nominal y fuente de cantidad. Virgen no se repesa; segunda se pesa bolsa por bolsa y se suma. Bruto/tara solo se registran cuando realmente intervienen. | La recuperación interna permanece en US-010E como transformación y no como recepción. |

### 12.2. Resolución de Lagunas Lógicas Evaluadas

1. **OC no equivale a recepción física — resuelta para primera versión.** La OC autoriza la compra ordinaria; la guía, conteo y pesaje cuando aplique evidencian lo recibido. Una entrada sin OC puede reconocerse físicamente, pero queda retenida y no disponible hasta regularización.
2. **Compras está fuera del alcance funcional de US-010A.** La historia puede conservar una referencia o snapshot de OC, pero no debe asumir que este MES administrará precios, saldos de compra o aprobación comercial si esa responsabilidad pertenecerá a un ERP.
3. **Una muestra física no puede aumentar stock con `0 kg` — resuelta por alcance.** Toda entrada registra cantidad física positiva; una posible valorización cero pertenece al sistema financiero.
4. **La excepción sin OC necesitaba definir disponibilidad — resuelta.** La existencia queda bajo retención documental y no disponible; un supervisor la regulariza sin usar un plazo ficticio de 48 horas.
5. **La inspección no podía fijarse como MFR y color para todos los materiales — resuelta.** La revisión mínima aprobada cubre identidad/grado, lote, integridad del empaque y contaminación visible. Certificado, muestra o ensayo se exige solo mediante política de categoría aprobada.
6. **El lote externo normalmente ausente necesitaba una regla honesta — resuelta.** La llegada se identifica con lote interno; el externo queda `NO_INFORMADO` o `ILEGIBLE` y no bloquea v1 por defecto. Solo una política futura que lo declare obligatorio provoca bloqueo.
7. **Vencimiento, fecha de reanálisis y bloqueo son decisiones distintas — diferida conscientemente.** En primera versión no hay materiales configurados con vencimiento o reanálisis; el modelo deberá permitir añadirlos después.
8. **El formato sugerido de lote interno no garantiza unicidad.** El objetivo de negocio validado es identidad interna única y no reutilizable. El formato legible y el identificador técnico se decidirán después; una fecha, proveedor y secuencia corta pueden colisionar o cambiar.
9. **Peso nominal no equivale a peso medido — resuelta.** En virgen el valor documental/nominal es autoridad aceptada y se declara `NO_MEDIDO`; en segunda la suma manual bolsa por bolsa alimenta inventario.
10. **La tolerancia no puede asumirse universal — resuelta y refinada por C.** No se adopta `+/- 0.5%` ni otro porcentaje global. Una política activa por categoría/modalidad puede clasificar dentro o fuera de tolerancia; sin política, la diferencia queda `SIN_POLITICA` y no se aplica un umbral inventado.
11. **Material de segunda comprado y recuperado interno no son el mismo flujo — resuelta.** El primero es recepción externa pesada bolsa por bolsa; la merma molida es una transformación de US-010E con genealogía hacia sus lotes padre.

### 12.3. Preguntas Reformuladas para Cerrar A — Respondidas

1. En una compra normal, ¿la recepción debe estar vinculada obligatoriamente a una OC aprobada, aunque el ingreso físico se identifique con guía y pesaje?
2. ¿Se permiten entregas parciales de una OC y una guía asociada a más de una OC?
3. ¿Qué motivos de entrada sin OC existen realmente: muestra, préstamo, consignación, emergencia, devolución u otros?
4. ¿Una entrada sin OC puede registrarse físicamente pero permanecer no disponible? ¿Quién y bajo qué evidencia puede liberarla?
5. Para cada categoría, ¿el lote ausente impide descargar, permite cuarentena o permite recepción con autorización?
6. ¿Qué materiales requieren fecha de vencimiento o reanálisis y qué acción produce cada fecha?
7. Para bolsas vírgenes nominales de `25 kg`, ¿inventario usa conteo nominal, pesaje total o ambos? Para material de la calle, ¿se pesa cada costal o el total por lote?
8. ¿Cuál es la tolerancia aprobada por modalidad y qué acciones corresponden dentro y fuera de tolerancia?
9. Completar la frase pendiente sobre “cuando nosotros recuperamos la merma” para clasificar correctamente compra externa y recuperación interna.

### 12.4. Respuestas del Negocio — 2026-07-14

| # | Respuesta validada | Consecuencia para el alcance | Estado |
|---|---|---|---|
| 1 | Sí: la compra normal requiere una OC aprobada. | La OC es condición de entrada del flujo ordinario de recepción. | Cerrada. |
| 2 | Sí: existen entregas parciales y una guía puede asociarse a más de una OC. | La recepción necesita imputaciones por línea de OC y no una relación rígida guía-OC de uno a uno. | Cerrada. |
| 3 | No existe una estandarización de motivos para recibir sin OC. | Se utilizará un catálogo administrable, sin fijar motivos empíricos no validados en el código. | Cerrada para primera versión. |
| 4 | Se requiere flexibilidad y evidencia prudente para recibir sin OC. | La entrada se retiene; exige responsable, motivo y una evidencia disponible; un supervisor la regulariza. | Cerrada mediante `A-EXC-01`. |
| 5 | No existe protocolo previo ni el lote suele estar disponible. | Se crea lote interno y se registra el externo como `NO_INFORMADO` o `ILEGIBLE`; para v1 no bloquea salvo política expresa. Se intentará capturarlo desde la bolsa. | Cerrada y refinada mediante `A-LOT-01`. |
| 6 | No hay materiales con vencimiento o reanálisis definidos por el momento. | Caducidad y reanálisis quedan fuera de la primera versión; el modelo debe permitir incorporarlos después. | Cerrada para primera versión. |
| 7 | La modalidad depende del material: virgen sin repesaje y segunda pesada bolsa por bolsa. | Virgen usa guía/conteo nominal con fuente declarada; segunda usa la suma de pesos manuales de una balanza. | Cerrada y refinada mediante `A-PES-01`. |
| 8 | No existe una tolerancia estándar global de diferencia de peso. | La diferencia siempre queda visible. El bloque C posterior aprueba políticas configurables por categoría/modalidad y conserva `SIN_POLITICA` cuando no exista una vigente. | Cerrada y refinada por `C-TOL-01` y `C-TOL-02`. |
| 9 | La merma se muele y vuelve a procesarse; las bolsas pueden rondar `30 kg` y se pesan durante la operación del molino. | Es una transformación interna con genealogía de material, no una recepción de proveedor. `30 kg` es una observación variable, no una equivalencia estándar. | Cerrada como clasificación; el detalle operativo pasa a US-010E. |

### 12.5. Cierre de la Respuesta A

Con estas respuestas queda confirmado que:

1. La recepción ordinaria nace de una OC aprobada.
2. Una OC admite recepciones parciales y una guía puede distribuirse entre varias OC.
3. El lote del proveedor no se inventa y el sistema conserva además un lote interno.
4. El inventario se controla en kg con tres decimales.
5. La recepción conserva datos nominales, documentales y mediciones reales cuando existan, sin copiar un valor entre fuentes.
6. El material de segunda comprado se pesa manualmente bolsa por bolsa en una balanza; el virgen no se repesa.
7. Vencimiento y reanálisis no forman parte de la primera versión.
8. La merma molida y reprocesada pertenece al flujo de transformación interna de US-010E.
9. La entrada sin OC crea existencia física retenida y no disponible hasta regularización de un supervisor.
10. El lote externo ausente o ilegible produce un lote interno con estado explícito, nunca un código inventado; solo bloquea si una política lo exige.
11. La modalidad determina la autoridad: documento/conteo para virgen o suma medida para segunda.

Las tres reglas que permanecían bloqueantes fueron aprobadas el 2026-07-14. La respuesta A queda cerrada para primera versión. Las respuestas B, C y D fueron aprobadas el 2026-07-15; no quedan decisiones del bloque gerencial 1–10 sin respuesta.

### 12.6. Reglas Aprobadas — 2026-07-14

Estas reglas son `source of truth` funcional para los escenarios de aceptación y [[TS-010A_Recepcion_Trazable_Materiales]].

| ID | Regla aprobada | Motivo |
|---|---|---|
| A-EXC-01 | Una entrada física sin OC puede registrarse, pero queda con retención documental y no disponible. Debe registrar responsable, motivo administrable y al menos una evidencia disponible —documento, foto o constancia de autorización—. Un supervisor puede regularizarla vinculando una OC o aprobando expresamente la excepción. | Permite reconocer material que ya está físicamente en planta sin habilitar consumo carente de sustento. Mantiene el control documental separado del estado de Calidad. |
| A-LOT-01 | Toda recepción crea lote interno. El lote externo se captura desde bolsa/etiqueta cuando exista y se clasifica `INFORMADO`, `NO_INFORMADO` o `ILEGIBLE`. En v1 es opcional y no bloquea, salvo política expresa de categoría. | No inventa procedencia y permite mejorar gradualmente la evidencia real disponible. |
| A-PES-01 | `VIRGEN_CONFIANZA_PROVEEDOR` usa guía y conteo/peso nominal sin fingir pesaje interno. `SEGUNDA_PESAJE_BOLSA` suma pesos anotados manualmente bolsa por bolsa en una balanza de planta. | La fuente de cantidad queda visible y el inventario usa la autoridad operativa real de cada modalidad. |

### 12.7. Secuencia de Cierre Funcional Ejecutada

La captura guiada se encuentra en [[Validacion_Operativa_US-010A]]. La ficha conserva como `POR VALIDAR` los datos reales de piloto, sin reabrir las reglas ya cerradas.

1. La orden interna, las modalidades, la segregación y `REC-01` a `REC-46` quedaron definidos como contrato funcional.
2. Gerencia cerró v1 sin límites delegados: toda corrección confirmada requiere su aprobación; para segunda se usa `SIN_POLITICA` hasta definir tolerancia numérica.
3. La Definición de Preparada quedó cumplida y se redactó [[TS-010A_Recepcion_Trazable_Materiales]].
4. El caso real completo, las personas y los catálogos físicos se terminan antes de UAT.
5. El desarrollo comenzará, después de aprobar la TS, con la primera prueba `RED` de `REC-44` y continuará según su mapa de pruebas.

### 12.8. Respuesta B Aprobada — Calidad y Disponibilidad — 2026-07-15

Las propuestas 5, 6 y 7 del bloque B fueron aceptadas como `source of truth` funcional y se normalizan en las siguientes reglas:

| ID | Regla aprobada | Consecuencia verificable |
|---|---|---|
| B-CAL-01 | Almacén confirma cantidad y estado físico; Calidad decide la liberación. La inspección mínima registra identidad/material y grado, lote, empaque íntegro y ausencia de contaminación visible. Certificado, muestra o ensayo adicional depende de una política aprobada por categoría. | Sin inspección mínima conforme o requisito de categoría satisfecho, la cantidad no puede quedar disponible. |
| B-CAL-02 | Toda cantidad se crea `PENDIENTE`. La liberación directa solo aplica a una combinación exacta material-proveedor previamente autorizada por Calidad y Gerencia; la política queda versionada y puede retirarse. | La recepción registra la transición `PENDIENTE -> LIBERADO` y la versión que la justificó. Retirar la política detiene futuras liberaciones directas, sin cambiar lotes anteriores de forma retroactiva. |
| B-CAL-03 | Calidad puede decidir sobre una parte del lote identificando cantidad, ubicación y motivo. | El remanente no resuelto continúa `PENDIENTE`; todas las cantidades conservan la misma genealogía y la reclasificación no modifica la existencia física total. |

#### Normalización de la regla parcial

La suma aprobada debe incluir el remanente pendiente:

`PENDIENTE + LIBERADO + BLOQUEADO + RECHAZADO = existencia física actual del lote`

La igualdad se evalúa sobre todas las ubicaciones del lote. Consumos, devoluciones y disposiciones reducen la existencia mediante eventos propios; una decisión de Calidad solo reclasifica cantidades.

#### Cuarentena y estado de Calidad

Para primera versión, `CUARENTENA` no es un quinto estado de Calidad que compita con `PENDIENTE`. Puede existir como ubicación física, por ejemplo `REC-CUARENTENA`, mientras la cantidad mantiene uno de los cuatro estados aprobados: `PENDIENTE`, `LIBERADO`, `BLOQUEADO` o `RECHAZADO`.

### 12.9. Respuesta C Aprobada — Almacén y Cantidades — 2026-07-15

Las propuestas 8 y 9 del bloque C fueron aceptadas, junto con la precisión de que este catálogo mínimo corresponde únicamente a materias primas.

| ID | Regla aprobada | Consecuencia verificable |
|---|---|---|
| C-UBI-01 | Las ubicaciones se seleccionan de un catálogo controlado. Para materias primas se requieren como tipos funcionales mínimos: recepción/cuarentena, resinas, masterbatch/colorantes/aditivos, bloqueados, rechazados/devoluciones y material recuperado. | No se aceptan nombres libres; cada movimiento conserva origen, destino y jerarquía. Gerencia y Almacén suministran los nombres reales. |
| C-UBI-02 | Los almacenes de materias primas, piezas y productos terminados son ámbitos distintos. US-010A solo permite destinos de materias primas. | Una resina no puede recibirse ni moverse a una ubicación de `PIEZA_COLOR` o `PRODUCTO_TERMINADO`; esas zonas se completan en las historias de inventario correspondientes. |
| C-TOL-01 | La tolerancia se configura por categoría y modalidad. En virgen se controla documento/conteo nominal sin repesaje; en segunda se comparan documento y suma manual bolsa por bolsa. | La cantidad aceptada procede de la autoridad declarada por modalidad y conserva la versión de política. |
| C-TOL-02 | Para segunda, sin política activa la suma pesada gobierna inventario y la diferencia queda `SIN_POLITICA` sin bloquear por sí sola. Para virgen, el conteo coincidente permite aceptar la cantidad documental; una discrepancia de conteo exige decisión de Gerencia o rechazo. | Almacén no puede ignorar una diferencia, inventar un umbral ni reutilizar la tolerancia de otro proceso. |

#### Alcance de los Tres Almacenes

- **Materias primas:** resinas, masterbatch/colorantes, aditivos y material recuperado; alcance de US-010A y US-010B/US-010E.
- **Piezas:** existencias físicas de `PiezaColor` producidas; su detalle de ubicaciones corresponde a US-010D.
- **Producto terminado:** lotes o unidades resultantes del armado; su detalle corresponde a US-010F/US-010G.

El catálogo maestro puede ser común para trazabilidad, pero toda ubicación debe declarar qué inventario admite. No se deduce compatibilidad por el nombre visible.

#### Configuración Operativa Pendiente

Antes de la validación en planta deben cargarse:

1. códigos y nombres reales de almacenes, zonas, racks, silos o posiciones de materias primas;
2. límites aprobados por categoría y modalidad, o declaración explícita de `SIN_POLITICA`;
3. personas reales que ejercerán la decisión de Gerencia ante discrepancias de conteo de virgen;
4. vigencia y responsables de cada política.
5. personas reales que solicitarán correcciones y quien suplirá a Gerencia durante el piloto.

La regla fija de `5 kg` documentada en `Control_Peso` pertenece al contraste de bultos de producción. No es una tolerancia de recepción y no debe reutilizarse en US-010A.

### 12.10. Respuesta D Aprobada — Correcciones y Devoluciones — 2026-07-15

Las propuestas 10 y 11 del bloque D fueron aceptadas como `source of truth` funcional:

| ID | Regla aprobada | Consecuencia verificable |
|---|---|---|
| D-COR-01 | Almacén puede modificar borradores. Una recepción confirmada solo se corrige mediante solicitud y evento compensatorio aprobados por Gerencia, con motivo y evidencia. | No existen `UPDATE` o `DELETE` funcionales sobre el hecho confirmado; la proyección corregida siempre conserva el evento original. |
| D-COR-02 | En v1 no hay límites delegados por cantidad o valor: Gerencia aprueba toda corrección confirmada. | Supervisión y Almacén pueden solicitar, pero no aplicar una compensación sin la aprobación registrada de Gerencia. Una delegación futura requerirá política versionada. |
| D-DEV-01 | Antes de aceptar custodia se registra `RECHAZO_RECEPCION` sin aumentar inventario. | Se conserva evidencia del intento de entrega, pero no se crea un lote recibido ni movimiento de entrada. |
| D-DEV-02 | Después de confirmar, toda devolución total o parcial registra ingreso original, bloqueo/rechazo y evento `DEVOLUCION_PROVEEDOR`. | La devolución reduce existencia actual, nunca la recepción histórica; no puede exceder el saldo físico ni duplicarse por reintento. |

#### Normalizaciones Lógicas de D

1. **Cantidad consumida:** una compensación o devolución no puede retirar stock que ya salió por consumo, devolución o disposición. Los eventos posteriores afectados requieren correcciones enlazadas propias.
2. **Procedencia:** corregir proveedor, material o lote no borra el valor capturado originalmente; la proyección actual y el historial deben mostrar ambos.
3. **Orden de compra:** una devolución no reabre saldos comerciales de OC por inferencia. El MES registra el hecho y el ERP decide su consecuencia comercial mediante integración explícita.
4. **Idempotencia:** rechazo, compensación y devolución poseen identidad de operación; repetir una solicitud no duplica movimientos.

#### Configuración Operativa Pendiente de D

Gerencia debe proporcionar los límites de escalamiento y roles superiores. Si se usan límites por valor, también debe definirse sistema de origen, moneda, momento del valor y comportamiento cuando ese dato no esté disponible.

### 12.11. Respuesta E Aprobada — Fuente Documental Interna — 2026-07-21

La evidencia operativa confirma que antes de la OP no existe un documento interno estandarizado. La planta recibe documentos emitidos por el proveedor, como guía de remisión electrónica, pedido y factura. Por ello se aprueba para v1:

| ID | Regla aprobada | Consecuencia verificable |
|---|---|---|
| E-DOC-01 | EnvaPerú crea una `OrdenCompraMaterial` mínima como fuente interna de autorización. | Una compra ordinaria no se confirma sin revisión aprobada y saldo por línea. |
| E-DOC-02 | Guía, factura y pedido del proveedor son evidencias externas, no autorizaciones internas. | Se conservan crudos y se concilian contra orden, recepción y material controlado. |
| E-DOC-03 | `RecepcionMaterial` es el acta interna que acepta custodia. | Solo su confirmación idempotente crea inventario. |
| E-DOC-04 | El catálogo interno es autoridad de proveedor y material. | Datos externos no crean identidades maestras silenciosamente. |
| E-DOC-05 | Cantidad documental, peso bruto declarado, empaque nominal y peso neto medido son campos distintos. | El documento fotografiado no se interpreta como medición neta de EnvaPerú. |
| E-DOC-06 | El lote del proveedor requiere evidencia específica y normalmente no aparece en la guía. | Se intenta obtener de la bolsa; la ausencia queda `NO_INFORMADO` y no bloquea salvo política conforme `A-LOT-01`. |

La orden interna no convierte US-010A en un módulo financiero. Precio, impuesto, pago y conciliación contable permanecen fuera de alcance.

### 12.12. Respuesta F Aprobada — Pesaje, Lote y Responsables — 2026-07-21

1. Material virgen: EnvaPerú confía en el peso declarado por el proveedor y no vuelve a pesarlo.
2. Material de segunda: se pesa bolsa por bolsa en una balanza y hoy se anota manualmente.
3. El lote del proveedor normalmente no está disponible; se buscará primero en la bolsa, sin inventarlo ni bloquear v1 por defecto.
4. Gerencia aprueba la compra. Recepción, Calidad y los demás procesos quedan a cargo de responsables distintos.
5. En virgen, el conteo coincidente habilita aceptar la cantidad documental; una discrepancia de conteo la resuelve Gerencia.
6. En segunda, la suma de los pesos manuales gobierna inventario y la diferencia queda visible como `SIN_POLITICA` mientras no exista tolerancia numérica.
7. Toda corrección posterior a la confirmación requiere aprobación de Gerencia, sin límites delegados en v1.

Estas reglas cierran la autoridad de cantidad y la segregación funcional para la primera versión. Los nombres de personas, código de balanza y formato de la hoja manual son configuración del piloto.

## 13. Definición de Preparada para TS-010A

- [x] Se validó que Gerencia aprueba la compra y que recepción, Calidad y los procesos posteriores tienen responsables distintos; faltan asignar personas reales.
- [x] Se aprobaron los estados, inspección mínima, decisiones parciales y liberación directa de Calidad.
- [x] Se aprobaron las reglas documentales, lote externo opcional y autoridad de cantidad diferenciada para virgen y segunda.
- [x] Se aprobaron los ámbitos de almacén y el comportamiento de tolerancias de recepción.
- [x] Se aprobaron correcciones compensatorias, rechazos en recepción y devoluciones al proveedor.
- [x] Se respondió la lista de decisiones de negocio pendiente.
- [x] Se definió el catálogo interno de proveedores y la `OrdenCompraMaterial` como fuente v1 de autorización, con líneas, saldos parciales y contingencia controlada.
- [x] Catálogos, ubicaciones, políticas y tolerancias se definieron como configuración; sus valores reales no se codificarán ni son requisito de unit tests.
- [x] Se definió el modelo objetivo de capacidades y segregación; la autenticación humana y asignación de personas reales permanecen como gate transversal del piloto/productivo.
- [x] Los escenarios `REC-01` a `REC-46` son comprensibles y verificables como contrato funcional; su recorrido con las personas reales queda como puerta de UAT.
- [x] Existe un comando reproducible para ejecutar la línea base de tests.
- [x] La línea base está verde o sus fallos previos están registrados y aislados.
- [x] No quedan decisiones de negocio que cambien contratos o autorizaciones escondidas como detalles técnicos.

**Resultado de la puerta al 2026-07-21: US-010A está preparada y su Tech Spec fue aprobada para desarrollo.** Quedaron cerradas las autoridades de cantidad, las discrepancias de virgen y la aprobación de correcciones por Gerencia. El recorrido con Compras, Almacén y Calidad, y los nombres reales de ubicaciones, motivos, balanza y personas, permanecen como configuración y puerta de UAT; no bloquean el diseño técnico.

Se aprobó [[TS-010A_Recepcion_Trazable_Materiales]] con esquema, restricciones, transacciones, contratos API, componentes y migración, sin convertir valores de planta en constantes. La implementación se controla desde [[DEV-010A_Recepcion_Trazable_Materiales]].

El desarrollo debe crear roles y capacidades SCM estables. La asignación definitiva de esos permisos a usuarios humanos se realizará al cierre del desarrollo y antes de habilitar el sistema para operación multiusuario.

### 13.1. Puerta Operativa Posterior

Antes de UAT o uso real sí debe completarse [[Validacion_Operativa_US-010A]] con:

- valores iniciales de materiales, ubicaciones, tolerancias y motivos;
- asignación de personas reales a capacidades autorizadas;
- asignación de la persona de Gerencia y su suplencia autorizada;
- al menos una recepción real anonimizada;
- resultados esperados de inventario y trazabilidad.

Esta puerta operativa puede avanzar en paralelo. Su demora no obliga a detener pruebas con fixtures ni el refinamiento de otras historias hijas.

## 14. Fuera de Alcance

- Reservar, emitir o devolver material identificado para una OP; corresponde a US-010B.
- Confirmar consumo real, ejecutar corridas y calcular balance de masa; corresponde a US-010C.
- Integrar pesajes o imprimir QR de salida de producción; corresponde a US-010D.
- Definir zonas internas detalladas de almacén de `PiezaColor` y producto terminado; corresponde a US-010D y US-010F/US-010G respectivamente.
- Redefinir la tolerancia legacy de `Control_Peso` o la tolerancia de balance de masa; son políticas distintas a la recepción.
- Compras, cuentas por pagar y evaluación comercial del proveedor.
- Integración EDI o EPCIS con proveedores.
- LIMS o formulación completa de ensayos de laboratorio.
- Gestión de transporte de ingreso.

## 15. Definición de Terminado

1. Todos los escenarios aceptados poseen pruebas automatizadas en su nivel apropiado.
2. La recepción confirmada genera inventario una sola vez, incluso ante reintentos.
3. La procedencia del lote puede consultarse sin reconstrucción manual.
4. Calidad controla la disponibilidad sin modificar destructivamente el historial.
5. Los movimientos internos conservan cantidad y genealogía y rechazan ubicaciones incompatibles con materias primas.
6. Las correcciones son compensatorias, autorizadas y auditables.
7. Las reglas críticas de transacción, unicidad y concurrencia se validan contra PostgreSQL.
8. La suite de regresión de backend, frontend afectado y flujo E2E está verde.
9. El vault refleja el dominio, flujo, contratos y decisiones finalmente implementados.
10. Toda recepción conserva política de tolerancia aplicada, resultado o marca `SIN_POLITICA`.
11. Ningún umbral de recepción se obtiene de una constante perteneciente a pesaje de producción o balance de masa.

## 16. Corte Frontend con Datos Mock

El 2026-07-15 se incorporó un mock navegable para validar la experiencia antes de disponer de TS-010A y APIs. Desde el 2026-07-21 funciona como scaffold visual de la Tech Spec:

- rutas de recepción más `/materiales/compras` y `/materiales/configuracion`;
- bandeja con casos de virgen y segunda;
- detalle separado de recepción, Calidad e historial;
- formulario interactivo que diferencia documento/conteo de virgen y pesaje manual bolsa por bolsa de segunda;
- CRUD, envío, aprobación, cancelación y revisión de OC simuladas en memoria;
- participantes, capacidades, evidencias y categorías configurables visualmente;
- resolución parcial visible sin modificar la existencia física total;
- catálogo de ubicaciones filtrado exclusivamente por alcance `MATERIA_PRIMA`;
- CRUD lógico de materiales, proveedores, ubicaciones, motivos, categorías y políticas;
- documentos externos, conciliación de líneas y reemplazo no destructivo de evidencias;
- confirmación local que crea lotes/saldos mock, Calidad, movimientos, retenciones, correcciones y devoluciones;
- mapa explícito de las superficies visuales para `REC-01` a `REC-46`;
- banner permanente `MOCK LOCAL`; ninguna llamada HTTP ni persistencia.

Los fixtures no son fuente de verdad ni reemplazan persistencia. Virgen ya usa `NO_MEDIDO` y segunda conserva pesos, suma y diferencia. La suite frontend tiene `37 passed` y el build Vite está verde. La ficha visual se mantiene en [[Vista_US-010A_Recepcion_Materiales]].
