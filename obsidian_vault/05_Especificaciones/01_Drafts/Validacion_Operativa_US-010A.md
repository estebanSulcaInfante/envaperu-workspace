---
tipo: ficha-validacion-operativa
estado: validacion-parcial
fecha_creacion: 2026-07-15
fecha_actualizacion: 2026-07-21
tags: [us-010a, scm, recepcion, almacen, calidad, trazabilidad, validacion]
relaciones:
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[2026-07-13_Perfil_Trazabilidad_ISO9001_ISA95_GS1]]"
---

# Ficha de Validacion Operativa de US-010A

## 1. Objetivo

Cerrar con Almacen, Calidad y Gerencia la configuracion real que necesita la recepcion trazable de materias primas antes de UAT y operacion en planta.

Esta ficha distingue tres clases de contenido:

- **APROBADO:** regla ya aceptada en US-010A; no se reabre durante esta sesion.
- **DESCUBIERTO:** hecho comprobado en el codigo actual; describe el punto de partida, no el diseno objetivo.
- **POR VALIDAR:** dato o autoridad de planta que no debe inventarse en codigo ni en la Tech Spec.

La ficha solo se convierte en evidencia de negocio cuando los responsables completan y validan sus secciones. Los valores vacios no se interpretan como cero, ausencia de control ni autorizacion implicita.

### 1.1. Esta Ficha No es una Precondicion de Pruebas

Las pruebas automatizadas usan fixtures sinteticos y verifican reglas configurables. No necesitan que Gerencia entregue previamente nombres reales, valores numericos o personas asignadas.

| Contenido pendiente | ¿Bloquea pruebas o refinamiento de US-010B? | ¿Cuando debe cerrarse? |
|---|---|---|
| Nombres/codigos reales de ubicaciones, materiales y motivos | No | Antes de UAT/carga inicial |
| Valores reales de tolerancia y suplencia autorizada de Gerencia | No; v1 admite `SIN_POLITICA` y toda corrección confirmada exige Gerencia | Antes del piloto |
| Personas reales y suplencias | No; las pruebas usan capacidades sinteticas | Antes de habilitar usuarios reales |
| Fuente/adaptador de OC y proveedores | No bloquea B; está definido técnicamente en TS-010A | Antes de aprobar `TS-010A` para desarrollo |
| Capacidades y segregacion de funciones | Se pueden probar como contrato; su modelo afecta seguridad | Antes de cerrar la Tech Spec de autorizacion |
| Caso real anonimizado | No bloquea unit/contract tests | Durante validacion funcional/UAT |

La ausencia de configuracion productiva nunca autoriza hardcodear datos de prueba como valores reales.

## 2. Participantes y Evidencia

| Funcion | Responsable real | Fecha | Evidencia o acta | Estado |
|---|---|---|---|---|
| Gerencia de planta | POR VALIDAR | | | Pendiente |
| Responsable de Almacen de materias primas | POR VALIDAR | | | Pendiente |
| Responsable de Calidad | POR VALIDAR | | | Pendiente |
| Compras o responsable de OC/proveedores | POR VALIDAR | | | Pendiente |
| Responsable funcional del sistema | POR VALIDAR | | | Pendiente |

## 3. Punto de Partida Descubierto

| Area | Evidencia actual | Consecuencia para US-010A |
|---|---|---|
| Catalogo de materiales | `backend/app/models/materiales.py` solo contiene `MateriaPrima(id, nombre, tipo)` y `Colorante(id, nombre)`. `tipo` es texto libre y no existen codigo estable, categoria, proveedor ni unidad base declarada. | La recepcion no puede apoyarse en nombres libres. Debe validarse el catalogo maestro y sus categorias antes de definir el esquema. |
| Alta de materiales | `backend/app/api/rutas_produccion.py` crea materias primas o colorantes por nombre mientras registra una OP si no los encuentra. | Debe impedirse que una variante ortografica cree identidades distintas para el mismo material trazable. La futura TS tendra que separar administracion del maestro y uso en una OP. |
| Compras y proveedores | No existen modelos ni rutas de proveedor, OC, recepcion o imputacion de lineas de OC en el backend actual. | Debe identificarse el sistema dueno de proveedores y OC aprobadas y el contrato minimo para consultarlas o capturar una referencia controlada. |
| Lotes e inventario de materia prima | No existen `LoteMaterial`, saldo por lote, estado de Calidad ni movimientos de materias primas. | US-010A introduce un subdominio nuevo; no es una extension del kardex actual de bultos. |
| Ubicaciones | `InventarioManga.locacion_actual` y sus movimientos aceptan strings; rutas kardex usan valores como `ALMACEN_PRINCIPAL`, `TRANSITO`, `ZONA_ARMADO` y `CLIENTE_FINAL`. | Son ubicaciones legacy de bultos o `PiezaColor`. No deben reutilizarse automaticamente como almacen de materias primas. |
| Roles operativos | US-009 creo `RolOperativo` con `MAQUINISTA`, `OPERADOR_PESAJE`, `MEZCLADOR`, `AYUDANTE` y `SUPERVISOR`. | El catalogo identifica funciones de trabajadores, pero aun no contiene funciones explicitas de Almacen o Calidad. |
| Identidad y permisos | Las rutas Flask actuales no autentican al usuario ni aplican autorizacion por permiso; `RolOperativo` se usa como catalogo/filtro. | Registrar un nombre de trabajador no demuestra quien aprobo. US-010A necesita identidad autenticada, permisos y auditoria separados del rol operativo. |
| Tolerancias | La unica constante encontrada es `abs(diferencia) < 5.0` en control de bultos de produccion. | Ese `5 kg` no es una politica de recepcion y queda prohibido usarlo como valor inicial de US-010A. |
| Correcciones y devoluciones | El kardex posee operaciones legacy para bultos, pero no eventos compensatorios ni devolucion a proveedor de materia prima. | Las reglas D se implementaran como eventos nuevos y no como edicion del kardex de mangas. |

### 3.1. Ubicaciones Legacy que No Son Fuente de Verdad para Materias Primas

| Valor encontrado | Uso actual inferido del codigo | Tratamiento en US-010A |
|---|---|---|
| `ZONA_PRODUCCION` | Origen de ingreso de un bulto producido | No reutilizar sin validacion explicita. |
| `ALMACEN_PRINCIPAL` | Destino generico de `InventarioManga` | No equivale a almacen de materias primas. |
| `TRANSITO` | Estado/ubicacion intermedia del movimiento de bultos | El nuevo catalogo debe separar estado logistico y ubicacion fisica. |
| `ZONA_ARMADO` / `ALMACEN_PARTES` | Destino de piezas para armado o partes | Ambito `PIEZA_COLOR`, fuera de US-010A. |
| `CLIENTE_FINAL` / `ZONA_DESPACHO` | Despacho de bultos | Fuera de la recepcion de materia prima. |
| `MOLINO_DESTRUCCION` | Salida legacy hacia destruccion | La molienda recuperable se modela en US-010E, no como recepcion externa. |

## 4. Fuente de Proveedores y Ordenes de Compra

La planta no posee hoy un documento interno estandarizado de compra anterior a la OP. La guía, factura y pedido observados son emitidos por el proveedor y no demuestran por sí solos una aprobación interna. Para v1, EnvaPerú creará una `OrdenCompraMaterial` mínima y un catálogo interno de proveedores como fuentes autoritativas. Esta decisión cierra la frontera documental para redactar `TS-010A`.

| Pregunta | Respuesta de planta | Estado |
|---|---|---|
| ¿Que sistema, archivo o proceso es hoy fuente oficial de proveedores? | Nuevo catálogo interno de proveedores de EnvaPerú; la guía solo aporta datos para conciliación. | Definido para v1 |
| ¿Que sistema, archivo o proceso demuestra que una OC esta aprobada? | `OrdenCompraMaterial` interna con revisión y actor aprobador distintos del creador. | Definido para v1 |
| ¿Que identificador estable tiene una OC y cada una de sus lineas? | ID técnico inmutable, número interno legible y `linea_id` estable por revisión. | Definido para TS |
| ¿Como se conoce el saldo pendiente cuando existen entregas parciales? | `cantidad_autorizada - recepciones_confirmadas`; rechazo previo no consume y devolución posterior no reabre el saldo automáticamente. | Definido para v1 |
| ¿Quien puede corregir en origen una OC o proveedor incorrecto? | Proveedor: capacidad administrativa. OC en borrador: creador. OC aprobada: nueva revisión o cancelación auditada; nunca sobrescritura. | Definido para v1 |
| ¿US-010A consultara esa fuente, importara un snapshot o usara carga manual controlada en v1? | El propio sistema será la fuente v1. Se cargan catálogos y órdenes internas; documentos externos se adjuntan y capturan estructuradamente. | Definido para v1 |
| ¿Que ocurre operativamente cuando la fuente de OC no esta disponible? | Se conserva papel/foto como evidencia provisional. Al recuperar servicio se registra idempotentemente; sin OC aprobada solo procede entrada excepcional retenida. | Definido para v1 |

La guía, factura o pedido del proveedor nunca se presentan como OC aprobada. La aprobación pertenece exclusivamente a la orden interna y queda auditada.

### 4.1. Documentos Normalizados para v1

| Documento | Dueño | Propósito | Crea inventario |
|---|---|---|---|
| `OrdenCompraMaterial` | EnvaPerú | Autorizar proveedor, material y cantidad; controlar saldo por línea. | No |
| Documento externo de proveedor | Proveedor | Evidenciar lo declarado y trasladado; conservar guía, factura, pedido y líneas crudas. | No |
| `RecepcionMaterial` | EnvaPerú | Aceptar custodia, identificar lote, medir, inspeccionar y ubicar. | Sí, solo al confirmar |

El alcance no incluye precios, impuestos, pagos ni contabilidad. Los datos personales del transporte se conservan en el adjunto con acceso restringido y no se replican en vistas generales.

## 5. Catalogo Maestro de Materiales

Completar una fila por material real o, como minimo, validar las categorias y reglas de identificacion. No usar nombres comerciales parecidos como si fueran equivalentes tecnicos.

| Codigo interno real | Nombre controlado | Categoria | Grado/especificacion | Unidad base | Lote proveedor obligatorio | Modalidad usual | Activo |
|---|---|---|---|---|---|---|---|
| POR VALIDAR | | Resina virgen | | kg | No para v1; capturar si aparece en bolsa | `VIRGEN_CONFIANZA_PROVEEDOR` | |
| POR VALIDAR | | Resina reciclada comprada/segunda | | kg | No para v1; capturar si aparece en bolsa | `SEGUNDA_PESAJE_BOLSA` | |
| POR VALIDAR | | Masterbatch/colorante | | kg | No para v1; capturar si aparece en bolsa | POR VALIDAR | |
| POR VALIDAR | | Aditivo | | kg | No para v1; capturar si aparece en bolsa | POR VALIDAR | |

Validaciones necesarias:

- [ ] Se distinguieron resina virgen, material reciclado comprado y material recuperado internamente.
- [ ] Se decidio si pigmento en polvo, masterbatch y aditivo liquido son categorias distintas.
- [ ] Cada material posee codigo estable; el nombre visible no es su identidad.
- [ ] Se acordaron sinonimos o duplicados que deben depurarse del catalogo actual.
- [ ] La OP seleccionara materiales existentes y no dara de alta maestros silenciosamente por texto libre.

## 6. Catalogo Fisico de Ubicaciones de Materias Primas

Puede haber varias filas por tipo funcional. El codigo es estable; cambiar el rotulo visible no debe romper el historial.

| Tipo funcional aprobado | Codigo estable | Nombre usado en planta | Padre/zona | Rack, silo o posicion | Categorias admitidas | Responsable | Estado |
|---|---|---|---|---|---|---|---|
| Recepcion/cuarentena | POR VALIDAR | POR VALIDAR | | | | | Pendiente |
| Resinas | POR VALIDAR | POR VALIDAR | | | | | Pendiente |
| Masterbatch/colorantes/aditivos | POR VALIDAR | POR VALIDAR | | | | | Pendiente |
| Bloqueados | POR VALIDAR | POR VALIDAR | | | | | Pendiente |
| Rechazados/devoluciones | POR VALIDAR | POR VALIDAR | | | | | Pendiente |
| Material recuperado | POR VALIDAR | POR VALIDAR | | | | | Pendiente |

Comprobaciones en planta:

- [ ] El rotulo fisico permite reconocer sin ambiguedad cada ubicacion.
- [ ] Se identificaron zonas compartidas y su regla de segregacion fisica.
- [ ] Se indico si una ubicacion puede contener material `PENDIENTE`, `LIBERADO`, `BLOQUEADO` o `RECHAZADO`.
- [ ] Se confirmo que estado de Calidad y ubicacion siguen siendo dimensiones distintas.
- [ ] Se definio el procedimiento cuando una posicion esta llena, inactiva o temporalmente cerrada.

## 7. Calidad por Categoria

La inspeccion minima ya esta aprobada: identidad/grado, lote, empaque integro y ausencia de contaminacion visible. Esta tabla solo define requisitos adicionales y responsables reales.

| Categoria | Certificado requerido | Muestra requerida | Ensayo requerido | ¿Admite liberacion directa? | Responsable que libera | Estado |
|---|---|---|---|---|---|---|
| Resina virgen | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | Pendiente |
| Resina reciclada comprada | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | Pendiente |
| Masterbatch/colorante | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | Pendiente |
| Aditivo | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | Pendiente |

Para cada combinacion material-proveedor con liberacion directa se debe registrar quien la aprueba, vigencia, requisitos y quien puede retirarla. Marcar `No aplica` es valido; dejar vacio no lo es.

## 8. Tolerancias de Recepcion

`SIN_POLITICA` es una decision explicita valida para v1. No completar con el `5 kg` de bultos de produccion ni con porcentajes recomendados sin aprobacion.

| Categoria | Modalidad | Limite absoluto kg | Limite porcentual | Regla de conteo/envases | Resultado sin politica | Quien acepta fuera de tolerancia | Estado |
|---|---|---:|---:|---|---|---|---|
| Resina virgen | Sacos cerrados; confianza en proveedor | No aplica sin repesaje | No aplica sin repesaje | Contar bolsas y conservar peso nominal/documental | `SIN_POLITICA`; gobierna documento/conteo | Gerencia ante discrepancia de conteo | Modalidad definida |
| Resina reciclada comprada/segunda | Pesaje manual bolsa por bolsa | Sin límite numérico en v1 | Sin límite numérico en v1 | Registrar cada bolsa y sumar | `SIN_POLITICA`; gobierna suma medida y no bloquea por sí sola | No requiere aceptación adicional mientras no exista política numérica | Regla v1 definida |
| Masterbatch/colorante | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | `SIN_POLITICA` | POR VALIDAR | Pendiente |
| Aditivo | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | `SIN_POLITICA` | POR VALIDAR | Pendiente |
| Material a granel | Confirmar si existe | POR VALIDAR | POR VALIDAR | No aplica/POR VALIDAR | `SIN_POLITICA` | POR VALIDAR | Pendiente |

Si se configuran limite absoluto y porcentual, ambos deben cumplirse. La version aplicada y la diferencia siempre quedan en el evento de recepcion.

## 9. Identidad, Permisos y Segregacion de Funciones

Una persona de planta puede tener varios roles operativos. Aun asi, cada aprobacion debe atribuirse a un usuario autenticado enlazado con esa persona y con permisos vigentes en el momento del evento.

Los nombres de participantes, sus asignaciones de rol y las suplencias quedan configurables. Se reutiliza el catálogo `Trabajador`; posteriormente una pantalla administrativa podrá crear, editar y desactivar personas, y asignar o retirar roles/capacidades. Desactivar una persona no altera eventos anteriores, que conservan su identidad y snapshot.

| Capacidad | Funcion de planta | Perfil/permiso del sistema | ¿Puede aprobar su propia accion? | Nivel superior | Estado |
|---|---|---|---|---|---|
| Crear orden interna | Compras/encargado designado | `OC_CREAR` | No puede aprobarla | Gerencia | Función definida |
| Aprobar orden interna | Gerencia | `OC_APROBAR` | No si también creó esa revisión | Gerencia | Función definida |
| Crear y editar borrador | POR VALIDAR | POR VALIDAR | No aplica | | Pendiente |
| Confirmar recepcion ordinaria | POR VALIDAR | POR VALIDAR | POR VALIDAR | | Pendiente |
| Registrar entrada excepcional sin OC | POR VALIDAR | POR VALIDAR | POR VALIDAR | | Pendiente |
| Regularizar entrada sin OC | Supervisor aprobado | POR VALIDAR | POR VALIDAR | POR VALIDAR | Pendiente |
| Registrar inspeccion fisica | Almacen | POR VALIDAR | POR VALIDAR | | Pendiente |
| Liberar, bloquear o rechazar cantidad | Calidad | POR VALIDAR | POR VALIDAR | POR VALIDAR | Pendiente |
| Administrar liberacion directa | Calidad + Gerencia | POR VALIDAR | No | POR VALIDAR | Pendiente |
| Aceptar fuera de tolerancia | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | Pendiente |
| Solicitar corrección compensatoria | Almacén o Supervisor designado | `CORRECCION_SOLICITAR` | No puede aprobarla | Gerencia | Función definida; persona por asignar |
| Aprobar corrección confirmada | Gerencia | `CORRECCION_APROBAR` | No si también la solicitó | No aplica en v1 | Regla v1 definida |
| Registrar devolucion a proveedor | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | Pendiente |
| Administrar ubicaciones, motivos y tolerancias | POR VALIDAR | POR VALIDAR | No aplica | POR VALIDAR | Pendiente |

Preguntas bloqueantes:

1. ¿Puede quien recibe liberar el mismo lote si tambien pertenece a Calidad? **No para v1: son encargados distintos.**
2. ¿Puede quien solicita una correccion aprobarla? **No; en v1 toda corrección confirmada la aprueba Gerencia y debe ser otro actor.**
3. ¿Una devolucion requiere una o dos aprobaciones? **En v1 no añade aprobación de Gerencia: Calidad debe haber clasificado la cantidad como `BLOQUEADO` o `RECHAZADO` y un actor de Almacén con `DEVOLUCION_REGISTRAR`, distinto de quien tomó la decisión de Calidad, ejecuta la salida.**
4. ¿Quien sustituye a Calidad o al supervisor fuera de horario? **Una persona configurada con la misma capacidad vigente; la suplencia no elimina ninguna regla de segregación. El nombre real se asigna antes del piloto.**
5. ¿Como se deshabilita inmediatamente el acceso de una persona que ya no trabaja o cambia de funcion? **Se desactiva `Trabajador` y se retiran sus roles/capacidades; la invalidación inmediata de sesiones/tokens pertenece al enabler de autenticación humana.**

## 10. Limites de Correccion y Devolucion

| Nivel | Rango de cantidad kg | Rango de valor | Moneda/fuente | Aprobador | Evidencia minima | Estado |
|---|---:|---:|---|---|---|---|
| Operativo | Ninguno | No aplica | No aplica | No aprueba | Motivo + evidencia para solicitar | Regla v1 definida |
| Supervisor | Ninguno | No aplica | No aplica | No aprueba | Motivo + evidencia para solicitar | Regla v1 definida |
| Gerencia | Toda corrección de recepción confirmada | No aplica en v1 | No aplica en v1 | Gerencia, actor distinto del solicitante | Motivo + evidencia | Regla v1 definida |

Si no existe un valor confiable procedente del ERP, el escalamiento monetario queda deshabilitado; nunca se sustituye el dato faltante por `0`.

## 11. Catalogos de Motivos Iniciales

No existe hoy una estandarizacion validada. Completar solamente motivos que ocurren realmente y mantener catalogos separados cuando conduzcan a controles distintos.

Los tipos de evidencia y sus requisitos mínimos también son catálogos configurables. La configuración puede versionarse o desactivarse; una evidencia concreta ya utilizada en una recepción, aprobación o corrección no se edita ni elimina. Un reemplazo crea un nuevo adjunto enlazado y conserva el anterior para auditoría.

| Contexto | Codigo | Nombre real | Evidencia minima | Quien puede usarlo | Activo |
|---|---|---|---|---|---|
| Entrada sin OC | POR VALIDAR | POR VALIDAR | Al menos una evidencia disponible | POR VALIDAR | |
| Lote ausente/ilegible | POR VALIDAR | POR VALIDAR | Foto cuando sea posible; si no, motivo | POR VALIDAR | |
| Aceptacion fuera de tolerancia | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | |
| Bloqueo/rechazo de Calidad | POR VALIDAR | POR VALIDAR | POR VALIDAR | POR VALIDAR | |
| Correccion compensatoria | POR VALIDAR | POR VALIDAR | Motivo + evidencia | POR VALIDAR | |
| Devolucion a proveedor | POR VALIDAR | POR VALIDAR | Motivo + evidencia | POR VALIDAR | |

## 12. Recorrido de un Caso Real Anonimizado

Usar una recepcion ya ocurrida. Ocultar precios, RUC y datos personales, pero conservar estructura, cantidades y secuencia.

### 12.1. Entrada

| Dato | Caso real anonimizado |
|---|---|
| Proveedor/codigo anonimizado | Proveedor formal `PROV-ANON-01`; razón social y RUC omitidos del vault. |
| OC aprobada y lineas | No se presentó una OC interna estandarizada. El caso requiere crear `OrdenCompraMaterial` o tratar la llegada como excepcional retenida. |
| Guia u otros documentos | Guía de remisión electrónica de julio de 2026; serie/número parcialmente ocultos. Contiene referencias externas de pedido y factura. |
| Material, categoria y grado | Código externo `MR1100030`; descripción comercial de resina PP/Braskem. Categoría y equivalencia exacta deben validarse contra el catálogo interno. |
| Lote del proveedor | No visible y normalmente no disponible. Se intentará obtener de la bolsa; para v1 queda `NO_INFORMADO` sin bloqueo automático. |
| Cantidad documentada | `5,000.000 KGM`. |
| Numero de sacos/costales | Observación: `200` bolsas. |
| Peso nominal | `25.000 kg` por bolsa; esperado `5,000.000 kg`. |
| Peso bruto, tara y neto medido | La guía declara peso bruto `5,000.000 kg`. Si el catálogo confirma material virgen, EnvaPerú acepta `5,000.000 kg` por confianza en proveedor y conserva `peso_interno = NO_MEDIDO`. |
| Balanza o fuente del pesaje | Virgen: documento/conteo nominal. Segunda: una balanza de planta, bolsa por bolsa, con anotación manual. Código de balanza POR VALIDAR. |
| Ubicacion inicial | No visible; debe seleccionarse del catálogo de recepción/cuarentena. |
| Responsable de recepcion | Existe sello/firma de recepción, pero la identidad se omite y no se considera autenticada desde la fotografía. |

### 12.2. Calidad y Resultado

| Dato | Caso real anonimizado |
|---|---|
| Inspeccion minima observada | La guía no prueba identidad física del lote, integridad de todos los empaques ni contaminación; debe registrarse en recepción. |
| Certificado, muestra o ensayo aplicable | No visible; POR VALIDAR según política de categoría/proveedor. |
| Decision total o parcial | No evidenciada; estado inicial objetivo `PENDIENTE`. |
| Cantidad por estado de Calidad | Si se confirma como virgen y coinciden las `200` bolsas, `5,000.000 kg PENDIENTE` con fuente `DOCUMENTO_PROVEEDOR`; no se exige repesaje. |
| Movimientos fisicos posteriores | No visibles; POR COMPLETAR durante el recorrido en planta. |
| Correccion o devolucion, si existio | No visible; no se infiere. |
| Actor y evidencia de cada decision | Guía y sello son evidencia documental; las decisiones de Calidad requieren eventos y actores propios. |

### 12.2.1. Hallazgos del Documento Observado

1. La guía aporta emisor, destinatario, fechas, traslado, peso bruto, una línea de material, código externo, cantidad, unidad, empaque nominal, pedido, factura, vehículo y transportista.
2. La guía no aporta autorización interna, lote de proveedor, tara, inspección, ubicación ni decisión de Calidad.
3. `200 x 25 kg = 5,000 kg` concilia nominalmente. Para virgen esa es la autoridad operativa aceptada; debe quedar visible que no hubo pesaje interno.
4. El código y la descripción externos requieren mapeo explícito a un material interno; la semejanza textual no crea identidad.
5. La fotografía contiene datos personales y direcciones. No se versiona en el repositorio; para el sistema productivo el adjunto tendrá acceso restringido y política de retención.
6. Para material de segunda, la futura recepción debe transcribir pesos bolsa por bolsa o el total conciliado de la hoja manual y vincular una balanza de planta.

### 12.3. Resultados que Deben Verse

- [ ] Recepcion: proveedor, OC/guia, responsable, momento y clave idempotente.
- [ ] Lote: identidad interna, lote externo conocido/ausente y material exacto.
- [ ] Cantidades: documentada, nominal, bruto, tara, neto, diferencia y politica aplicada.
- [ ] Inventario: existencia fisica, cantidad disponible y cantidad retenida por cada causa.
- [ ] Calidad: estado total/parcial, actor, motivo, evidencia y transiciones.
- [ ] Ubicacion: posicion actual y movimientos con origen/destino.
- [ ] Correccion: hecho original y evento compensatorio visibles sin sobrescritura.
- [ ] Devolucion: ingreso original, bloqueo/rechazo y salida al proveedor.
- [ ] Trazabilidad hacia atras: lote -> recepcion -> proveedor/documentos.
- [ ] Trazabilidad hacia adelante: lote -> movimientos y, en historias posteriores, consumos/salidas.

## 13. Lectura Guiada de Escenarios ATDD

| Bloque | Escenarios | Responsable que confirma comprension | Observaciones | Estado |
|---|---|---|---|---|
| Recepcion e idempotencia | `REC-01` a `REC-07` | POR VALIDAR | | Pendiente |
| Calidad | `REC-08` a `REC-10`, `REC-21` a `REC-25` | POR VALIDAR | | Pendiente |
| Inventario, movimiento y trazabilidad | `REC-11`, `REC-12`, `REC-14`, `REC-26`, `REC-27` | POR VALIDAR | | Pendiente |
| OC, documentos y pesos | `REC-16` a `REC-20`, `REC-28` a `REC-30`, `REC-40` a `REC-46` | Responsable funcional | Documento y modalidades reales revisados; falta recorrido con Compras/Almacén. | Parcial |
| Correcciones, rechazo y devoluciones | `REC-13`, `REC-15`, `REC-31` a `REC-39` | POR VALIDAR | | Pendiente |

## 14. Salida de la Validacion

La ficha se considera lista para UAT/operacion cuando:

- [x] se definio el catálogo interno y la `OrdenCompraMaterial` como fuente v1 de proveedor y compra aprobada;
- [ ] se validaron catalogo de materiales y categorias de recepcion;
- [ ] se registraron ubicaciones fisicas reales de materias primas;
- [x] tolerancias poseen valores aprobados o `SIN_POLITICA` explicito para virgen y segunda; otras categorías se completan antes de habilitarlas;
- [ ] se asignaron actores autenticados, permisos y segregacion de funciones;
- [x] se definió que no existen límites delegados en v1 y que toda corrección confirmada la aprueba Gerencia;
- [ ] un caso real anonimizado recorrio el flujo completo; ya se completó la evidencia documental de entrada, faltan pesaje, inspección, ubicación y Calidad;
- [ ] Almacen, Calidad y Compras comprendieron los escenarios `REC-01` a `REC-46`;
- [ ] se acordaron las vistas de inventario y trazabilidad esperadas;
- [x] la linea base automatizada esta registrada y reproducible.

El avance de estas casillas puede ocurrir en paralelo con US-010B. Para `TS-010A` solo son bloqueantes las decisiones que cambian contratos o autorizacion; los valores iniciales permanecen como configuracion desplegable.

## 15. Implicacion Tecnica Detectada

La autenticacion y autorizacion no deben resolverse como un campo `rol` enviado por el frontend. Una vez validadas las funciones y segregaciones de la seccion 9, corresponde crear un Technical Enabler transversal de identidad y control de acceso, con su propia Tech Spec porque cambiara la arquitectura productiva y protegera tambien futuras historias SCM.

Este enabler no decide quien aprueba: implementa tecnicamente la matriz aprobada por el negocio.
