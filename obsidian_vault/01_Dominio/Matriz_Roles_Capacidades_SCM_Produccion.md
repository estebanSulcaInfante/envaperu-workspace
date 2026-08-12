---
tipo: modelo_autorizacion
estado: vigente
tags: [dominio, scm, roles, capacidades, permisos, produccion, pesaje]
relaciones:
  - "[[Trabajador]]"
  - "[[RolOperativo]]"
  - "[[Guia_Roles_y_Permisos_SCM_Piloto]]"
  - "[[2026-08-06_OA_como_Sigla_Orden_Armado]]"
  - "[[Preferencia_Workspace_Rol]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-08-10
---

# Matriz de roles y capacidades SCM

Referencia exhaustiva del contrato de autorización del piloto SCM. La fuente
ejecutable sigue siendo `backend/app/services/scm_configuration.py` junto con
las migraciones posteriores. Esta ficha traduce esa configuración a una forma
consultable por usuarios, responsables funcionales y auditoría.

## Estado vigente

- Capacidades existentes en el catálogo: **120**.
- Capacidades incluidas en la asignación base de `GERENTE_GENERAL`: **117**.
- Roles base o incorporados por migración: **16**.
- Las capacidades efectivas de una persona son la unión de todos sus roles
  activos.
- El seed es aditivo: una asignación manual adicional no se elimina al volver a
  ejecutarlo. Por eso la API es la autoridad sobre una persona concreta.

> [!warning] Brecha detectada
> `GERENTE_GENERAL` se define como superusuario funcional, pero las tres
> capacidades de catálogo incorporadas posteriormente —proveedores, materiales
> y planta— solo fueron asignadas explícitamente a `GESTOR_MAESTROS`. Mientras
> no se alinee el seed, el gerente conserva 117 de las 120 capacidades del
> catálogo. Esta ficha registra el estado real y no oculta esa diferencia.

## Reglas obligatorias

1. El frontend nunca envía roles o capacidades como prueba de autoridad.
2. Ocultar o deshabilitar un botón no sustituye la validación del backend.
3. Un trabajador inactivo no posee capacidades efectivas.
4. Los códigos `UPPER_SNAKE_CASE` son identificadores estables y no se
   reutilizan con otro significado.
5. Los eventos históricos conservan actor y snapshot aunque posteriormente
   cambien sus roles.
6. La eliminación física está bloqueada; se utilizan desactivación, retiro,
   reversa o anulación auditada.
7. Correcciones, aperturas de inventario, reversas y otras decisiones sensibles
   pueden exigir solicitante y aprobador distintos aunque una persona acumule
   ambas capacidades.
8. `GERENTE_GENERAL`, `GERENCIA`, `GESTOR_MAESTROS` y los perfiles `JEFE_*`
   autorizados pueden publicar directamente borradores técnicos. La validación
   de integridad y la auditoría permanecen activas.
9. El rol principal configura foco, acceso principal y orden visual del
   workspace. Los demás roles activos siguen aportando capacidades.
10. Una preferencia de Inicio nunca concede permisos: solo puede proyectar una
    función ya autorizada y habilitada para el piloto.

## Leyenda abreviada de roles

| Código | Rol | Capacidades base |
|---|---|---:|
| GG | `GERENTE_GENERAL` | 117 |
| GM | `GESTOR_MAESTROS` | 14 |
| GE | `GERENCIA` | 27 |
| PL | `PLANIFICACION` | 19 |
| IN | `INGENIERIA_SCM` | 13 |
| JP | `JEFE_PRODUCCION` | 81 |
| JE | `JEFE_ENSAMBLE` | 36 |
| SU | `SUPERVISOR` | 34 |
| MA | `MAQUINISTA` | 4 |
| OP | `OPERADOR_PESAJE` | 7 |
| OM | `OPERADOR_MOLINO` | 4 |
| AR | `ALMACEN_RECEPCION` | 20 |
| CA | `CALIDAD` | 11 |
| CO | `COMPRAS` | 3 |
| CS | `CONFIGURACION_SCM` | 11 |
| AU | `AUDITORIA_CONSULTA` | 17 |

## Matriz funcional de permisos

Esta es la vista cruzada principal. Los roles están en filas y las áreas del
SCM en columnas. Cuando una celda contiene varios niveles, el rol acumula esas
facultades dentro del área.

| Nivel | Significado |
|---|---|
| `V` | Ver o consultar |
| `O` | Ejecutar una operación ordinaria |
| `A` | Crear, editar o administrar configuración |
| `P` | Aprobar, liberar, corregir, revertir o anular |
| `D` | Publicar directamente un borrador técnico |
| `—` | Sin capacidad base en el área |

| Rol | Participantes | Maestros | Ingeniería | OP / Plan | OF / OA / OT | Mangas / Pesaje | Inventario / Materiales | Almacén | Calidad | Armado | Molienda / Alertas |
|---|---|---|---|---|---|---|---|---|---|---|---|
| GG | A | A* | A/P/D | A/P | A/O/P | A/O/P | A/O/P | O/P | O/P | A/O/P | A/O/P |
| GM | — | A | A/D | — | — | — | — | — | — | — | — |
| GE | A | V | A/D | V/P | V | V | V | V | V | V | V |
| PL | — | V | V | A | O | A | V | V | — | V | — |
| IN | — | A | A | — | — | — | — | — | — | — | A |
| JP | — | V | A/P/D | V | A/O/P | A/P | A/P | O/P | V | A/O/P | A/O/P |
| JE | — | V | A/D | V | O | V | V | O | V | A/O | V |
| SU | — | V | V | V | O | O | V | O | V | O | O/V |
| MA | — | — | V | — | V | O | — | — | — | — | — |
| OP | — | — | V | — | V | O | — | — | — | — | — |
| OM | — | — | — | — | — | — | — | — | — | — | O/V |
| AR | — | — | — | — | — | — | O | O | — | — | O/V |
| CA | — | V | V/P | — | — | — | — | — | O/P | — | — |
| CO | — | A | — | — | O | — | — | — | — | — | — |
| CS | — | A | A | — | — | — | — | — | — | — | A |
| AU | — | V | V | V | V | V | V | V | V | V | V |

`A*`: el Gerente General administra los maestros mediante las capacidades
generales del seed, pero todavía no posee las tres capacidades restringidas de
catálogo añadidas posteriormente. Véase la brecha documentada al inicio.

La matriz resume la intención operativa. Para decidir si una acción concreta
está autorizada debe consultarse el código exacto en el catálogo exhaustivo que
sigue; por ejemplo, `O` en Mangas no implica automáticamente permiso para
anular un pesaje.

## Catálogo completo de capacidades

La columna **Roles base** expresa las asociaciones sembradas por código y
migraciones. No incluye asignaciones manuales posteriores.

### Compras, recepción de materiales y autorización

| Capacidad | Finalidad | Roles base |
|---|---|---|
| `PROVEEDOR_ADMINISTRAR` | Administrar proveedores | GG, CO |
| `DOCUMENTO_PROVEEDOR_REGISTRAR` | Registrar documentos externos de proveedor | GG, CO, AR |
| `OC_CREAR` | Crear órdenes de compra de material | GG, CO |
| `OC_APROBAR` | Aprobar órdenes de compra de material | GG, GE |
| `RECEPCION_CONFIRMAR` | Confirmar recepciones de material | GG, AR |
| `ENTRADA_EXCEPCIONAL_REGULARIZAR` | Regularizar entradas excepcionales | GG, SU |
| `CALIDAD_RESOLVER` | Resolver decisiones de Calidad | GG, CA |
| `LIBERACION_DIRECTA_ADMINISTRAR` | Administrar políticas de liberación directa | GG, CS |
| `CORRECCION_SOLICITAR` | Solicitar correcciones de recepción | GG, AR |
| `CORRECCION_APROBAR` | Aprobar correcciones de recepción | GG, GE |
| `DEVOLUCION_REGISTRAR` | Registrar devoluciones a proveedor | GG, AR |
| `CONFIG_RECEPCION_ADMINISTRAR` | Administrar configuración de recepción | GG, CS |
| `AUTORIZACION_SCM_ADMINISTRAR` | Administrar roles, capacidades y asignaciones | GG, GE |

### Artículos, BOM, rutas, empaque y WIP

| Capacidad | Finalidad | Roles base |
|---|---|---|
| `ARTICULO_VER` | Consultar artículos SCM | GG, GM, GE, PL, IN, JP, JE, SU, CA, CS, AU |
| `ARTICULO_ADMINISTRAR` | Administrar artículos SCM | GG, GM, IN, CS |
| `ESTRUCTURA_VER` | Consultar estructuras de producto | GG, GM, GE, PL, IN, JP, JE, SU, CA, AU |
| `ESTRUCTURA_ADMINISTRAR` | Administrar borradores de estructura | GG, GM, GE, IN, JP, JE |
| `ESTRUCTURA_APROBAR` | Aprobar o retirar estructuras | GG, JP |
| `ESTRUCTURA_PUBLICAR_DIRECTO` | Publicar una estructura sin segunda aprobación | GG, GM, GE, JP, JE |
| `RUTA_VER` | Consultar rutas de producción | GG, GM, GE, PL, IN, JP, JE, SU, CA, AU |
| `RUTA_ADMINISTRAR` | Administrar borradores de ruta | GG, GM, GE, IN, JP, JE |
| `RUTA_APROBAR` | Aprobar o retirar rutas | GG, JP |
| `RUTA_PUBLICAR_DIRECTO` | Publicar una ruta sin segunda aprobación | GG, GM, GE, JP, JE |
| `EMPAQUE_VER` | Consultar perfiles y reglas de empaque | GG, GM, GE, PL, IN, JP, JE, SU, CS, AU |
| `EMPAQUE_ADMINISTRAR` | Administrar tipos, perfiles y reglas de empaque | GG, GM, GE, IN, JP, JE, CS |
| `EMPAQUE_APROBAR` | Aprobar o retirar reglas de empaque | GG, JP |
| `EMPAQUE_PUBLICAR_DIRECTO` | Publicar una regla sin segunda aprobación | GG, GM, GE, JP, JE |
| `OPERACION_PLANIFICAR` | Planificar operaciones | GG, PL, JP |
| `OPERACION_EJECUTAR` | Ejecutar operaciones | GG, JP, SU |
| `OPERACION_CORREGIR` | Aprobar correcciones de operaciones | GG, JP |
| `WIP_VER` | Consultar WIP y genealogía | GG, GE, PL, JP, JE, SU, MA, OP, CA, AU |
| `WIP_LIBERAR` | Liberar WIP por Calidad | GG, CA |
| `TIPO_MANGA_ADMINISTRAR` | Administrar tipos de manga | GG, IN, CS |

### OT, mangas, stickers y pesaje

| Capacidad | Finalidad | Roles base |
|---|---|---|
| `OT_VER` | Consultar órdenes de trabajo | GG, GE, PL, JP, JE, SU, MA, OP, AU |
| `OT_CREAR` | Crear órdenes de trabajo | GG, PL, JP, JE, SU |
| `OT_INICIAR` | Iniciar órdenes de trabajo | GG, JP, JE, SU |
| `OT_CERRAR` | Cerrar órdenes de trabajo | GG, JP, JE, SU |
| `PLAN_MANGA_VER` | Consultar planes de manga | GG, GE, PL, JP, JE, SU, AU |
| `PLAN_MANGA_ADMINISTRAR` | Administrar planes de manga | GG, PL, JP, SU |
| `MANGA_PLANIFICAR` | Crear mangas normales desde el cupo | GG, PL, JP, SU |
| `MANGA_ANULAR` | Anular una manga no utilizada | GG, JP |
| `MANGA_EXTRA_SOLICITAR` | Solicitar mangas adicionales | GG, SU |
| `MANGA_EXTRA_APROBAR` | Aprobar mangas adicionales | GG, JP |
| `MANGA_ETIQUETA_PRE_GENERAR` | Generar etiqueta prepesaje | GG, JP, SU |
| `MANGA_ETIQUETA_REEMPLAZAR_SOLICITAR` | Solicitar reemplazo de etiqueta | GG, SU, OP |
| `MANGA_ETIQUETA_REEMPLAZAR_APROBAR` | Aprobar e invalidar etiqueta reemplazada | GG, JP |
| `MANGA_PESAR` | Confirmar pesaje de manga | GG, MA, OP |
| `MANGA_PESAJE_VER` | Consultar pesajes de manga | GG, GE, JP, JE, SU, MA, OP, AU |
| `MANGA_ETIQUETA_POST_IMPRIMIR` | Imprimir etiqueta final | GG, OP |
| `PESAJE_CORRECCION_SOLICITAR` | Solicitar corrección de pesaje | GG, SU, OP |
| `PESAJE_CORRECCION_APROBAR` | Aprobar corrección compensatoria | GG, JP |
| `ANULAR_PESAJE` | Ejecutar anulación controlada de pesaje | GG, JP |
| `PESAJE_TARA_OVERRIDE` | Autorizar tara distinta del snapshot | GG, JP |

La superficie [[Vista_US-010N4_Supervision_de_Produccion|Supervisión de
producción]] no introduce una capacidad nueva. Usa `OT_VER` para el núcleo,
`MANGA_PESAJE_VER` para métricas/detalle de pesaje, `ALERTA_VER` para alertas y
`RECEPCION_MANGA_VER` para detalle de Almacén y `CALIDAD_MANGA_VER` para
Calidad, con degradación independiente. Los conteos logísticos
agregados por estado de manga permanecen dentro de `OT_VER`; los filtros de una
dimensión sensible sin permiso responden 403 y no exponen conteos indirectos.

### OP, planificación, inventario y materiales

| Capacidad | Finalidad | Roles base |
|---|---|---|
| `OP_VER` | Consultar órdenes de producción | GG, GE, PL, JP, JE, SU, AU |
| `OP_CREAR` | Crear órdenes de producción | GG, PL |
| `OP_APROBAR` | Aprobar demanda y congelar planificación | GG, GE |
| `PLANIFICACION_CALCULAR` | Calcular cobertura y propuestas | GG, PL |
| `PLANIFICACION_CONFIRMAR` | Confirmar el plan de suministro | GG, PL |
| `INVENTARIO_VER` | Consultar Kardex normalizado | GG, GE, PL, JP, JE, SU, AR, AU |
| `INVENTARIO_SALDO_INICIAL` | Registrar saldos iniciales | GG |
| `INVENTARIO_AJUSTAR` | Registrar ajustes auditados | GG, JP |
| `INVENTARIO_APERTURA_PREPARAR` | Preparar lotes de apertura inicial | GG, AR |
| `INVENTARIO_APERTURA_APROBAR` | Aprobar lotes de apertura inicial | GG, JP |
| `MATERIAL_REQUERIMIENTO_GENERAR` | Generar requerimientos de una OF | GG, JP |
| `MATERIAL_RESERVAR` | Reservar material para una OF | GG, JP |
| `MATERIAL_EMITIR` | Emitir material reservado a Producción | GG, AR |
| `MATERIAL_DEVOLVER` | Devolver material emitido al almacén | GG, AR |
| `MATERIAL_PREMEZCLA_CONFIRMAR` | Confirmar transformación de premezcla | GG, JP |

### Recepción de mangas y Calidad

| Capacidad | Finalidad | Roles base |
|---|---|---|
| `RECEPCION_MANGA_VER` | Consultar recepción de mangas | GG, GE, JP, JE, SU, AR, CA, AU |
| `RECEPCION_MANGA_CONFIRMAR` | Confirmar ingreso al almacén | GG, AR |
| `RECEPCION_MANGA_RECHAZAR` | Rechazar antes de aceptar custodia | GG, AR |
| `RECEPCION_MANGA_REVERSION_SOLICITAR` | Solicitar reversa de recepción | GG, AR |
| `RECEPCION_MANGA_REVERSION_APROBAR` | Aprobar reversa compensatoria | GG, JP |
| `RECEPCION_MANGA_BUSCAR_MANUAL` | Resolver una manga con QR ilegible | GG, AR |
| `CALIDAD_MANGA_VER` | Consultar mangas pendientes de Calidad | GG, GE, JP, JE, SU, CA, AU |
| `CALIDAD_MANGA_LIBERAR` | Liberar existencias de manga | GG, CA |
| `CALIDAD_MANGA_BLOQUEAR` | Bloquear existencias de manga | GG, CA |
| `CALIDAD_MANGA_RECHAZAR` | Rechazar existencias de manga | GG, CA |

### Abastecimiento, armado y genealogía

| Capacidad | Finalidad | Roles base |
|---|---|---|
| `ABASTECIMIENTO_VER` | Consultar abastecimiento interno | GG, GE, PL, JP, JE, SU, AR, AU |
| `ABASTECIMIENTO_SOLICITAR` | Solicitar componentes para una OT de armado | GG, JP, JE, SU |
| `PICKING_PREPARAR` | Reservar y preparar mangas por QR | GG, JP, AR |
| `PICKING_DESPACHAR` | Despachar picking hacia Producción | GG, JP, AR |
| `ABASTECIMIENTO_RECIBIR` | Recibir picking en Mesa de Armado | GG, JP, JE, SU |
| `ABASTECIMIENTO_DEVOLVER` | Devolver remanentes desde Armado | GG, JP, JE, SU |
| `RETORNO_RECIBIR` | Recibir remanentes en Almacén | GG, JP, AR |
| `UNIDAD_LOGISTICA_FRACCIONAR` | Autorizar fraccionamiento físico | GG, JP |
| `GENEALOGIA_CANDIDATA_CONFIRMAR` | Confirmar genealogía por candidatos | GG, JP, JE |
| `GENEALOGIA_LEGACY_APERTURA` | Autorizar apertura de stock legacy | GG, JP |
| `GENEALOGIA_VER` | Consultar genealogía exacta | GG, JP, JE |
| `ENSAMBLE_PLANIFICAR` | Planificar mangas de salida de armado | GG, JP, JE |
| `ENSAMBLE_MANGA_CERRAR` | Confirmar cantidad y consumos de Armado | GG, JP, JE |
| `ENSAMBLE_CORREGIR_SOLICITAR` | Solicitar corrección de Armado | GG, JP, JE, SU |
| `ENSAMBLE_CORREGIR_APROBAR` | Aprobar corrección compensatoria | GG, JP |
| `ABASTECIMIENTO_CORREGIR_SOLICITAR` | Solicitar corrección de abastecimiento | GG, JP, JE |
| `ABASTECIMIENTO_CORREGIR_APROBAR` | Aprobar corrección de abastecimiento | GG, JP |
| `ABASTECIMIENTO_EMERGENCIA_APROBAR` | Aprobar abastecimiento no planificado | GG, JP |

### OF, OA, merma, molienda y alertas

| Capacidad | Finalidad | Roles base |
|---|---|---|
| `OF_VER` | Consultar órdenes de fabricación | GG, GE, PL, JP, JE, SU, AU |
| `OF_EDITAR_BORRADOR` | Editar borradores de fabricación | GG, JP |
| `OF_EXCEPCIONAL_CREAR` | Crear fabricación excepcional | GG, JP |
| `OF_LIBERAR` | Liberar órdenes de fabricación | GG, JP |
| `OF_ANULAR` | Anular órdenes de fabricación | GG, JP |
| `OA_VER` | Consultar órdenes de armado | GG, GE, PL, JP, JE, SU, AU |
| `OA_LIBERAR` | Liberar órdenes de armado | GG, JP |
| `OA_EJECUTAR` | Ejecutar y cerrar órdenes de armado | GG, JP, JE, SU |
| `OA_ANULAR` | Anular órdenes de armado | GG, JP |
| `MERMA_RECUPERABLE_REGISTRAR` | Registrar y pesar merma recuperable | GG, JP, AR |
| `MOLIENDA_VER` | Consultar merma, molienda y genealogía | GG, GE, JP, JE, SU, OM, AR, IN, CS, AU |
| `MOLIENDA_ORDEN_CREAR` | Crear y preparar órdenes de molienda | GG, JP, SU, OM |
| `MOLIENDA_EJECUTAR` | Pesar, ejecutar y cerrar molienda | GG, JP, OM |
| `MOLIENDA_REGLA_ADMINISTRAR` | Administrar reglas de reproceso | GG, JP, IN, CS |
| `MOLIENDA_REGLA_APROBAR` | Aprobar reglas de compatibilidad | GG, JP |
| `MOLIENDA_EXCEPCION_APROBAR` | Autorizar excepciones de molienda | GG, JP |
| `MOLIENDA_LOTE_LIBERAR` | Liberar material recuperado | GG, JP |
| `MOLIENDA_ANULAR` | Anular órdenes o lotes de molienda | GG, JP |
| `ALERTA_VER` | Consultar alertas operativas | GG, GE, JP, JE, SU, OM, AR, IN, CS, AU |
| `ALERTA_GESTIONAR` | Reconocer, asignar y cerrar alertas | GG, JP |
| `ALERTA_CONFIGURAR` | Administrar reglas y umbrales | GG, JP, IN, CS |

### Catálogos restringidos del gestor de maestros

Estas capacidades se incorporaron mediante la migración
`f72e1a6b9c43_add_master_data_steward_role.py` y explican la diferencia entre
las 120 capacidades existentes y las 117 asignadas al Gerente General.

| Capacidad | Finalidad | Roles base |
|---|---|---|
| `CATALOGO_PROVEEDOR_ADMINISTRAR` | Mantener proveedores sin operar compras | GM |
| `CATALOGO_MATERIAL_ADMINISTRAR` | Mantener materiales y categorías | GM |
| `CATALOGO_PLANTA_ADMINISTRAR` | Mantener máquinas y recursos de planta | GM |

## Matriz funcional resumida por rol

| Rol | Administración / ejecución autorizada | Restricciones principales |
|---|---|---|
| `GERENTE_GENERAL` | Todas las capacidades del seed general; publicación directa y contingencia | Mantiene segregación; brecha de 3 capacidades de catálogo indicada arriba |
| `GESTOR_MAESTROS` | Catálogos, artículos, BOM, rutas y empaque; publicación técnica directa | Sin participantes, OP/OF/OA/OT, inventario, pesaje, recepción, Calidad ni molienda |
| `GERENCIA` | Aprobación de OC/OP/correcciones, permisos y publicación técnica | No ejecuta producción ni pesaje |
| `PLANIFICACION` | OP, cobertura, confirmación del plan, OT y planes de manga | No libera OF/OA ni pesa |
| `INGENIERIA_SCM` | Borradores de artículos, BOM, rutas, empaque, molienda y alertas | No publica directamente ni ejecuta producción |
| `JEFE_PRODUCCION` | Dirección productiva, OF/OA, OT, inventario, mangas, molienda, armado y correcciones | No confirma el pesaje ordinario ni administra participantes |
| `JEFE_ENSAMBLE` | Ingeniería publicable, OT/OA, armado, abastecimiento y genealogía | Sin aprobaciones generales de inventario, pesaje o Calidad |
| `SUPERVISOR` | Coordinación de OT, mangas, preetiquetas y solicitudes de excepción | Solicita; no aprueba correcciones, extras o reemplazos |
| `MAQUINISTA` | Consulta OT/WIP y pesaje básico | Sin postetiqueta ni aprobación |
| `OPERADOR_PESAJE` | Pesaje, postetiqueta y solicitudes de reemplazo/corrección | Sin aprobación ni anulación |
| `OPERADOR_MOLINO` | Creación y ejecución de molienda | Sin reglas, liberación o excepciones |
| `ALMACEN_RECEPCION` | Recepción, emisión, devolución, picking y retornos | Solicita reversas; no las aprueba ni decide Calidad |
| `CALIDAD` | Decisiones de Calidad sobre materiales, WIP y mangas | No recibe, pesa ni ajusta inventario |
| `COMPRAS` | Proveedores, documentos y creación de OC | No aprueba OC ni recibe materiales |
| `CONFIGURACION_SCM` | Políticas, empaque, reproceso y alertas | Sin operación productiva ni aprobaciones sensibles |
| `AUDITORIA_CONSULTA` | Lectura transversal | Ninguna mutación |

## Segregaciones mínimas

| Solicitud / preparación | Aprobación / resolución |
|---|---|
| Corrección de recepción: AR | GE o GG |
| Apertura inicial de inventario: AR | JP o GG |
| Manga extra: SU | JP o GG |
| Reemplazo de sticker: SU u OP | JP o GG |
| Corrección de pesaje: SU u OP | JP o GG |
| Reversa de recepción de manga: AR | JP o GG |
| Corrección de armado: SU, JE o JP | JP o GG, mediante otro actor cuando corresponda |
| Corrección de abastecimiento: JE o JP | JP o GG, mediante otro actor cuando corresponda |

La posesión de ambas capacidades no elimina automáticamente la validación de
actor distinto. Las publicaciones directas de ingeniería son la excepción
funcional documentada.

## Fuente verificable

- Catálogo y roles base: `backend/app/services/scm_configuration.py`.
- Rol de carga inicial: migración `f72e1a6b9c43`.
- Capacidades efectivas de un participante: `GET /api/auth/me`.
- Catálogo administrativo: `GET /api/catalogo/roles-operativos`.
- La base de datos y el backend prevalecen ante cualquier diferencia documental.
