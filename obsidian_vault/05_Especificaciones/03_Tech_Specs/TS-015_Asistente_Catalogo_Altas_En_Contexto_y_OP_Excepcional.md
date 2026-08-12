---
tipo: tech_spec
id: TS-015
titulo: "Asistente de catálogo, altas en contexto e integridad de OF excepcional"
estado: en-desarrollo
tags: [catalogo, wizard, ux, altas-en-contexto, orden-produccion, integridad]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-08-10
relaciones:
  - "[[TS-001_Creacion_Agil_Molde_Producto_Pieza]]"
  - "[[TS-012_Normalizacion_Relacion_Molde_Pieza_NM]]"
  - "[[TS-013_Codigos_Correlativos_Automaticos_Catalogo]]"
  - "[[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD]]"
  - "[[../02_User_Stories/US-007_Normalizar_ProductoTerminado_PiezaColor_Salidas_OP]]"
  - "[[../02_User_Stories/US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[../../../03_Frontend/Componentes/Patron_Altas_En_Contexto]]"
  - "[[TS-017A_Sesion_Durable_y_Shell_de_Alta_Guiada]]"
  - "[[../02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
---

# TS-015: Asistente de catálogo, altas en contexto e integridad de OF excepcional

> [!IMPORTANT] Alcance sustituido parcialmente
> La familia [[../02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado|US-012]] / TS-017 sustituye este wizard como interfaz principal de alta de ProductoTerminado. TS-015 conserva autoridad sobre el patrón **Crear nuevo…** y sobre la integridad de la OF excepcional. Su flujo Molde–Pieza–PiezaColor queda como antecedente y fachada transitoria; no debe ampliarse con BOM plano ni presentarse como recorrido integral.

## 1. Decisión

El wizard Molde–Pieza–PiezaColor es una herramienta de alta coordinada de catálogos, no una operación diaria de Producción. Su entrada canónica queda en **Datos maestros > Configuración guiada**, junto a Productos, Piezas, Moldes y Líneas/Familias. La ruta histórica puede conservarse como alias para no romper marcadores.

Los formularios que dependen de catálogos pequeños adoptan el patrón **“Crear nuevo…” al final del selector**. La creación ocurre en un modal, conserva el formulario padre, vuelve a consultar el catálogo y selecciona la entidad confirmada. Los maestros complejos no se reducen a un modal incompleto: se crean con su formulario completo o con la configuración guiada.

La creación directa de la orden técnica pasa a llamarse **OF excepcional**. El
flujo normal crea una OP de demanda y propone OF/OA mediante US-010P. La
excepción no autoriza relaciones arbitrarias ni fallbacks a la primera fila
disponible.

## 2. Wizard conforme al modelo vigente

El asistente debe respetar estas reglas antes de guardar:

1. `Molde` y `Pieza` son maestros independientes.
2. Una pieza global puede participar en varios moldes; `cavidades` y `peso_unitario_gr` viven en `MoldePieza`.
3. En el flujo transitorio de esta TS, una pieza clasificada usa un par activo `LineaFamilia`. Para altas integrales nuevas, [[../../../20_Registro_Decisiones/2026-08-10_Autoridad_de_Clasificacion_Comercial_en_ProductoTerminado|la decisión del 2026-08-10]] hace opcional la clasificación técnica de Pieza y elimina este bloqueo para generar PiezaColor.
4. Los campos Línea/Familia duplicados en `PiezaColor` son compatibilidad legacy y no constituyen autoridad comercial para nuevas altas.
5. Un color operativo es `ColorBase + FamiliaColor`; ambos son obligatorios en altas nuevas.
6. Los códigos de Molde, Pieza, PiezaColor y ProductoTerminado son correlativos asignados por el backend. El usuario no escribe ni confirma una identidad calculada por el frontend.
7. Al reutilizar un molde o una pieza, el asistente referencia su identidad existente. No duplica la entidad por nombre.
8. La respuesta final diferencia entidades creadas de entidades reutilizadas y muestra los códigos definitivos recibidos del servidor.
9. Reutilizar un molde siempre toma **todas** sus relaciones `MoldePieza` activas para generar Pieza × Color, kit y BOM; las filas enviadas no recortan su composición persistida.
10. Un `color_id` inexistente, una composición vacía o un kit solicitado sin colores se rechazan; no se omiten silenciosamente.

## 3. Altas en contexto

El patrón se aplica primero a catálogos compactos y frecuentes:

| Selector consumidor | Alta rápida | Datos mínimos |
|---|---|---|
| Color de una OP o variante | `ColorProduccion` | nombre de color base y FamiliaColor/acabado |
| Línea de Producto/Pieza | `Linea` | código de negocio y nombre |
| Familia dependiente | `Familia` + `LineaFamilia` | código, nombre y Línea ya seleccionada |

Reglas de interacción:

- la acción especial aparece siempre como última opción, incluso cuando el filtro no encuentra filas;
- elegirla abre el modal y no modifica aún el valor del formulario padre;
- cancelar no crea ni selecciona nada;
- guardar usa la API autoritativa, refresca las opciones y selecciona la respuesta confirmada;
- un duplicado idempotente reutilizable puede seleccionarse; cualquier conflicto real se muestra dentro del modal;
- durante el guardado se bloquea el doble envío;
- el modal nunca crea silenciosamente una FamiliaColor, una asociación Línea–Familia ni otra dependencia por defecto.

Para entidades con más reglas —Molde, Pieza con composición, PiezaColor con clasificación o ProductoTerminado con BOM— el selector puede ofrecer acceso a **Configuración guiada**, pero no debe insertar una fila parcial.

## 4. Integridad de la OF excepcional

`POST /api/ordenes` y `GET /api/validar-orden-prereq` comparten las reglas de identidad y compatibilidad de catálogo. El formulario valida además sus campos locales y el `POST` vuelve a validar autoritativamente el payload completo dentro de la transacción:

1. el número de OP es obligatorio y único;
2. la máquina existe y está activa;
3. el molde existe, está activo y posee al menos una asociación `MoldePieza` activa;
4. el snapshot automático usa solamente la composición activa del molde;
5. un snapshot manual no puede introducir una `PiezaColor` cuya `Pieza` no pertenezca activamente al molde elegido;
6. cavidades y pesos deben ser positivos y no pueden sustituir silenciosamente la composición vigente;
7. cada color existe, posee `familia_color_id` y se resuelve contra todas las piezas del molde;
8. la combinación `Pieza + ColorProduccion` se resuelve o crea de manera idempotente; nunca se toma la primera variante encontrada;
9. si se informa un ProductoTerminado, debe existir y su clasificación Línea–Familia debe seguir activa;
10. el backend no descubre un ProductoTerminado mediante un `.first()` ambiguo; una OF excepcional puede no tener producto asociado;
11. un error funcional produce `400`, `404` o `409` y revierte toda la transacción; no deja cabecera, snapshot, lotes ni variantes parciales;
12. la prevalidación devuelve errores y advertencias accionables con los mismos códigos de dominio para las condiciones que puede evaluar; parámetros técnicos, snapshot manual y detalle íntegro de lotes se confirman en el `POST`.

La UI deshabilita el envío mientras la prevalidación esté pendiente o inválida y conserva el borrador cuando el servidor rechaza la operación.

El formulario nuevo siempre usa `auto_snapshot_molde: true` y exige un molde catalogado. La API conserva temporalmente el snapshot manual sin molde solo para consumidores legacy ya existentes: no aparece en esta UI, no puede “aprender” maestros ambiguos y se retirará con la migración de US-007.

## 5. Frontera con US-007

La parte **estructural** de la migración del snapshot de US-007 quedó aplicada. `SnapshotComposicionMolde` usa como identidad canónica:

- `pieza_id`, FK a la `Pieza` abstracta;
- `pieza_codigo_snapshot` y `pieza_nombre_snapshot`, como texto histórico inmutable;
- `cavidades` y `peso_unit_gr`, como geometría congelada de la OP.

El antiguo valor `pieza_sku` se conserva, renombrado como `pieza_sku_legacy`, únicamente como evidencia nullable y sin FK para una futura importación o reconciliación. Una OP creada por el flujo vigente debe informar `pieza_id` y los textos snapshot, y **no debe escribir** `pieza_sku_legacy`.

Al momento de aplicar esta estructura no existen OP reales creadas con el esquema legacy. La revisión `d7e9a4c2f105` migró en `enva_test` cinco snapshots de demostración: resolvió cuatro por identidad exacta y preservó uno sin `pieza_id`, sin inferirlo por nombre. Esta comprobación técnica no permite certificar la reconciliación con un caso real. `pieza_id` permanece nullable durante esta ventana de compatibilidad; su posible endurecimiento a `NOT NULL` se evaluará después de la primera prueba controlada con una OP legacy real.

El 2026-07-23 se implementó el primer corte de salida física para OP nuevas: cada combinación `LoteColor × Pieza snapshot` crea transaccionalmente un `LoteSalidaPiezaColor`, resuelve el `PiezaColor` exacto y congela cavidades, peso unitario, cantidad objetivo y kg netos objetivo. La consulta de la OP expone estas salidas. `producto_sku_output` permanece solo como referencia al paquete cuando la OP posee ProductoTerminado y ya no sustituye la salida física.

Continúan pendientes dentro de US-007:

- ejecutar el backfill y el reporte de reconciliación cuando aparezca la primera OP legacy de prueba;
- asociar ejecución horaria, pesajes, bultos e inventario a la salida física y actualizar sus cantidades reales;
- retirar la compatibilidad legacy únicamente después de reconciliar y aprobar la evidencia.

La prueba con una OP legacy nunca debe inferir genealogía por nombre ni elegir la primera variante disponible. Cada `pieza_sku_legacy` debe resolverse de forma unívoca hacia `PiezaColor -> Pieza`, o quedar reportado como no conciliable sin inventar una relación.

## 6. Pruebas de aceptación

| ID | Evidencia mínima |
|---|---|
| WIZ-01 | Navegación: Configuración guiada aparece dentro de Datos maestros y la ruta legacy sigue resolviendo. |
| WIZ-02 | UI/API: una pieza existente puede asociarse a otro molde sin duplicarse; cavidades y peso quedan en `MoldePieza`. |
| WIZ-03 | UI/API: el wizard rechaza una Familia no asociada a la Línea. |
| WIZ-04 | UI/API: reutilizar un molde de tres piezas y elegir un color genera o reutiliza tres variantes sin duplicar `MoldePieza`. |
| WIZ-05 | API: color inexistente, molde nuevo sin composición y kit sin color se rechazan sin persistencia parcial. |
| UX-01 | UI: “Crear nuevo color…” es la última opción, abre modal, crea, refresca y selecciona. |
| UX-02 | UI: cancelar el modal conserva el valor y no invoca el POST. |
| OPX-01 | API: máquina o molde inexistente/inactivo impide crear la OP sin persistencia parcial. |
| OPX-02 | API: snapshot manual con pieza ajena al molde se rechaza. |
| OPX-03 | API: un color nuevo resuelve exactamente una variante por pieza del molde de forma idempotente. |
| OPX-04 | API: no se infiere un ProductoTerminado ambiguo. |
| OPX-05 | Contrato: prevalidación y creación usan los mismos códigos para incompatibilidades de catálogo; el `POST` conserva la validación autoritativa completa. |
| OPX-06 | E2E: desde catálogos operativos vacíos se crean los maestros requeridos, una receta aprobada y una OF excepcional; el `GET` conserva la revisión de receta y una salida física por pieza del molde. |
| MIG-01 | Esquema: el snapshot referencia `Pieza` mediante `pieza_id`, conserva código/nombre históricos y `pieza_sku_legacy` no posee FK. |
| MIG-02 | Escritura: una OP nueva completa los campos canónicos y deja `pieza_sku_legacy` en `NULL`. |
| MIG-03 | Pendiente condicionado: la primera OP legacy se procesa con el checklist de reconciliación de US-007 antes de endurecer o retirar columnas. |

## 7. No alcance

- liberar OP, reservar materiales o ejecutar producción;
- migrar las OP legacy o conectar ejecución, pesaje e inventario con las salidas físicas;
- asignar permisos finales a usuarios humanos;
- tocar una base desplegada o publicar el frontend.
