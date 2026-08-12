---
tipo: guia_usuario_referencia
estado: pendiente-uat
piloto: true
ruta_frontend: /guia/scm?etapa=participantes
uat: UAT_01_Configuracion_Participantes_y_Permisos
fecha_actualizacion: 2026-08-10
tags: [frontend, scm, guia-usuario, roles, permisos, participantes, pesaje]
---

# Roles y permisos del piloto SCM

## Regla general

Los roles son funciones predefinidas del sistema. Durante el alta se crean
**participantes** y se les asigna el rol mínimo que corresponde a su trabajo;
no se crean roles nuevos para cada persona.

Las capacidades efectivas de una persona son la unión de todos sus roles. Por
eso, durante la UAT de permisos conviene utilizar una identidad distinta por
rol: una combinación puede ocultar qué rol concedió una acción.

## Rol principal e Inicio

Una persona puede conservar varios roles activos. Todos aportan capacidades,
pero uno solo se marca como **rol principal** para ordenar su experiencia:

- el foco explica qué trabajo priorizar;
- el acceso principal abre la función recomendada solo cuando la persona pulsa
  **Abrir**;
- las funciones fijadas aparecen primero;
- el resto de funciones autorizadas permanece disponible, agrupado por área.

Estas preferencias no son permisos. Fijar Kardex, por ejemplo, no permite
abrirlo si la persona no tiene una capacidad de inventario. Si falta el rol
principal, Inicio usa una presentación genérica sin quitar ni inventar
capacidades.

Solo quien posee `AUTORIZACION_SCM_ADMINISTRAR` puede crear o editar roles,
asignar capacidades, definir el rol principal y previsualizar el resultado. La
previsualización no cambia la sesión del administrador.

## Gerente General, jefaturas y segregación de funciones

`GERENTE_GENERAL` es el superusuario funcional del piloto: posee las
capacidades necesarias para consultar, administrar y aprobar los flujos. Eso
no lo convierte en una identidad exenta de las reglas de integridad.

La autorización responde a dos preguntas distintas:

1. **¿Puede ejecutar esta clase de acción?** La capacidad del rol responde sí.
2. **¿Puede ejecutarla sobre este registro concreto?** Las reglas de
   segregación pueden responder no.

En estructuras BOM, rutas y reglas de empaque existe una excepción explícita:
`GERENTE_GENERAL`, `GERENCIA`, `GESTOR_MAESTROS` y los perfiles `JEFE_*`
autorizados pueden usar **Publicar** sobre un borrador sin solicitar una segunda
aprobación. La publicación sigue validando la composición y genera auditoría
completa.

Esta excepción no se extiende a correcciones, aperturas de inventario u otros
flujos que exigen solicitante y aprobador distintos.

## Roles principales del recorrido UAT

| Rol | Capacidades | Responsabilidad | Acciones principales |
|---|---:|---|---|
| GERENTE_GENERAL | 117 | Bootstrap y contingencia | Funciones generales del piloto, aprobaciones y publicación técnica directa. La matriz exhaustiva documenta tres capacidades restringidas de catálogo incorporadas posteriormente. |
| GESTOR_MAESTROS | 14 | Carga y mantenimiento de catálogos | Administra productos, piezas, materiales, proveedores, máquinas, estructuras, rutas y empaque; no ejecuta producción. |
| PLANIFICACION | 19 | Demanda y plan industrial | Crea OP y OT, calcula y confirma planificación, administra planes de manga y planifica armado. |
| JEFE_PRODUCCION | 81 | Dirección productiva | Administra y publica estructuras y rutas; dirige OT, OF y OA; aprueba excepciones, correcciones y anulación de pesaje. |
| MAQUINISTA | 4 | Ejecución en máquina | Consulta OT y WIP y puede confirmar el pesaje básico de una manga. |
| OPERADOR_PESAJE | 7 | Estación de pesaje de mangas | Pesa mangas de fabricación y PT, consulta pesajes, imprime postetiqueta y solicita reemplazo o corrección. |
| ALMACEN_RECEPCION | 20 | Recepción y movimientos físicos | Recepciona materiales y mangas, ejecuta picking/despacho, retornos, emisión y devolución. |
| CALIDAD | 11 | Decisión de calidad | Resuelve controles y libera, bloquea o rechaza mangas recibidas. |
| GERENCIA | 27 | Aprobaciones sensibles | Publica estructuras y rutas; aprueba OC, correcciones y OP, administra autorizaciones y consulta el flujo. |
| AUDITORIA_CONSULTA | 17 | Consulta independiente | Sólo lectura de órdenes, pesajes, inventario, calidad, alertas y genealogía. |

## Roles especializados

| Rol | Capacidades | Uso en el piloto |
|---|---:|---|
| SUPERVISOR | 34 | Coordina turno, inicia/cierra OT, genera preetiquetas y solicita mangas extra o correcciones. |
| OPERADOR_MOLINO | 4 | Inicia, pesa y cierra órdenes de molienda. |
| JEFE_ENSAMBLE | 36 | Administra y publica estructuras y rutas, planifica/cierra armado, ejecuta OA y gestiona abastecimiento. |
| COMPRAS | 3 | Administra proveedores, crea OC y registra documentos. |
| INGENIERIA_SCM | 13 | Administra artículos, estructuras, rutas, empaques, tipos de manga y reglas técnicas. |
| CONFIGURACION_SCM | 11 | Administra políticas de recepción, liberación directa, molienda y alertas. |

## Qué significa Operador de Pesaje

OPERADOR_PESAJE no significa “persona autorizada para cualquier balanza”.
En el alcance actual se refiere a la **estación de pesaje de mangas trazables**
de fabricación o de producto terminado vinculadas a una OT:

1. consultar la OT y el WIP;
2. confirmar el peso de la manga;
3. consultar el registro de pesaje;
4. imprimir la postetiqueta;
5. solicitar reemplazo de etiqueta;
6. solicitar una corrección de pesaje.

No incluye por sí solo:

- pesar o registrar merma recuperable;
- ejecutar la molienda;
- liberar material recuperado;
- confirmar la cantidad o consumir componentes durante el armado;
- aprobar una corrección o anular un pesaje.

## Permisos de Supervisión de producción

La vista **Control > Supervisión de producción** reutiliza capacidades
existentes; no existe un permiso nuevo llamado `PRODUCCION_SUPERVISAR`:

| Capacidad | Información visible en Supervisión |
|---|---|
| `OT_VER` | núcleo de la OT, recurso, responsable, trabajos, etapa y conteos logísticos agregados |
| `MANGA_PESAJE_VER` | peso físico, kg estándar y detalle autorizado de pesajes |
| `ALERTA_VER` | alertas y severidad real |
| `RECEPCION_MANGA_VER` | detalle de recepción y Almacén |
| `CALIDAD_MANGA_VER` | decisión y detalle de Calidad |

Recepción y Calidad se degradan por separado: disponer de una capacidad no
concede la otra. Una persona con solo `OT_VER` puede consultar el núcleo sin que los bloques no
autorizados se conviertan en cero. La API rechaza filtros sobre pesaje o alertas
físico, Almacén o alertas cuando falta su capacidad, para no revelar
indirectamente cuántas OT coinciden. **Pendiente de pesaje** sigue siendo un
estado operativo visible con `OT_VER`; no revela lectura ni kg.
Supervisión es de solo lectura: ninguna combinación de estos permisos habilita
comandos dentro de esa vista.

### Separación de los pesajes

| Objeto pesado | Rol operativo | Permiso o flujo |
|---|---|---|
| Manga con piezas producidas | OPERADOR_PESAJE o MAQUINISTA para confirmación básica | MANGA_PESAR |
| Postetiqueta de la manga | OPERADOR_PESAJE | MANGA_ETIQUETA_POST_IMPRIMIR |
| Ingreso de merma recuperable | ALMACEN_RECEPCION o JEFE_PRODUCCION | MERMA_RECUPERABLE_REGISTRAR |
| Pesaje y ejecución de molienda | OPERADOR_MOLINO o JEFE_PRODUCCION | MOLIENDA_EJECUTAR |
| Aprobación de corrección | JEFE_PRODUCCION | PESAJE_CORRECCION_APROBAR |
| Anulación controlada | JEFE_PRODUCCION o GERENTE_GENERAL | ANULAR_PESAJE |
| Manga de producto terminado cerrada por Armado | OPERADOR_PESAJE | MANGA_PESAR; el peso no modifica la cantidad confirmada ni la BOM |

## Segregación mínima

- Quien solicita una corrección no debe aprobarla.
- Quien prepara una apertura de inventario no debe aprobarla.
- Gerente General no debe utilizarse como operador habitual.
- Un participante inactivo no puede ejecutar acciones nuevas.
- La interfaz puede ocultar una acción, pero el backend también debe rechazarla
  con 403.

## Fuente verificable

La lista y las capacidades vigentes se consultan en
GET /api/catalogo/roles-operativos. Esta guía resume las capacidades de forma
operativa; el backend sigue siendo la fuente de autorización.
