---
tipo: arquitectura_frontend
estado: aprobado-para-desarrollo
tags: [frontend, scm, ux, navegacion, workspace, capacidades]
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-10
relacionados:
  - "[[2026-08-08_Arquitectura_de_Informacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[US-010N_Navegacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[TS-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
  - "[[TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]]"
  - "[[TS-010N4_Supervision_de_Produccion]]"
  - "[[Vista_US-010N4_Supervision_de_Produccion]]"
  - "[[Vista_US-010N_Workspace_Navegacion_e_Inicio]]"
---

# Workspace SCM por áreas

## Propósito

Organizar el SCM por la intención del usuario y conservar una sola fuente de
verdad por documento. Esta ficha reemplaza la navegación histórica de cuatro
módulos y las pestañas horizontales planas de Producción.

## Primer nivel

```text
Trabajo diario
├── Inicio
├── Planificación
├── Producción
├── Materiales
├── Almacén e inventario
└── Control

Soporte
├── Datos maestros
├── Administración
└── Guía SCM
```

## Planificación

Contiene Demanda/OP, cobertura/metas, plan y proyección de OF/OA generadas.
Responde qué se necesita y por qué. Los enlaces a OF/OA abren la ejecución
autoritativa en Producción.

No contiene corridas, asignación de máquina, maquinista, mangas, picking ni
genealogía de cierre.

## Producción

Contiene:

- **Fabricación:** configurar y liberar OF, corridas y contexto técnico;
- **Jornadas y Trabajos de color:** OT, cola, asignaciones, mangas y
  preetiquetas;
- **Armado:** OA, OT de Armado, ejecución, genealogía y mangas de salida.

No contiene Kardex, recepción de almacén, reproceso, alertas ni herramientas
legacy.

## Materiales

Contiene Preparación, reservas/emisiones/devoluciones, abastecimiento interno a
Armado y reproceso/molienda operativos. El rótulo visible es **Preparación de
materiales**, no “Reservas y entregas”.

Compras y recepción ordinaria de proveedor permanecen fuera del primer piloto.
Sus rutas no se presentan como operables mientras la fuente siga siendo mock o
parcial.

## Almacén e inventario

Contiene recepción de mangas, Calidad, Kardex, existencias, ubicaciones,
movimientos, apertura, ajustes y reversas. Almacén da nacimiento y custodia a
la existencia; Producción solo genera el resultado físico previo.

## Control

Contiene **Supervisión de producción** como primera lectura transversal,
alertas, histórico de pesajes, correcciones, anulaciones, conciliación y
herramientas de marcha blanca. Supervisión consulta Fabricación y Armado en una
fila por OT, con detalle y resumen, pero no crea ni modifica documentos. Para
preparar, iniciar o continuar trabajo, el usuario abre **Jornadas y Trabajos de
color** en Producción.

La función canónica es `control.productionSupervision`, ruta
`/control/supervision-produccion`, visible con `OT_VER` y enriquecida por las
capacidades específicas de pesaje, alertas, recepción y Calidad, estas dos
últimas independientes. Las vistas históricas
`/produccion/avance` y pesajes reportados localmente permanecen rotuladas como
legacy; no se suman ni se presentan como otra pestaña del mismo universo. Las
reglas que alimentan alertas o motivos se administran como maestros; la bandeja
operativa vive en Control.

## Datos maestros

Un único hub presenta:

| Grupo | Catálogos |
|---|---|
| Producto e ingeniería | PT/presentaciones, piezas/PiezaColor/imágenes, moldes, líneas/familias, colores/recetas, WIP, BOM, rutas, empaque |
| Materiales y proveedores | materiales, categorías, proveedores y compatibilidades |
| Planta y logística | máquinas, centros, ubicaciones y contenedores |
| Organización | trabajadores y funciones operativas |
| Gobierno de datos | motivos, políticas, tolerancias, importación y revisión |

Los roles/capacidades se consultan en el contexto del trabajador, pero su
catálogo y experiencia se administran en Administración.

## Administración

Contiene roles/capacidades, rol principal, experiencia de inicio, estaciones,
dispositivos, parámetros técnicos e integraciones. No reutiliza el prototipo de
Recepción de materiales.

## Reglas de navegación

1. Máximo dos niveles de navegación global: área y sección.
2. Una vista puede tener tabs internas solo si representan el mismo agregado.
3. Una función tiene una ubicación primaria; los demás accesos son enlaces.
4. Breadcrumbs proceden de claves de función, no de texto repetido.
5. El estado activo procede de la ruta más específica.
6. Las rutas físicas actuales se conservan durante N1/N2.
7. Escritorio usa sidebar plegable; móvil usa drawer.
8. Soporte queda separado visualmente del trabajo diario.

## Madurez

| Estado | Comportamiento productivo |
|---|---|
| `PILOTO` | visible según capacidades |
| `DISPONIBLE` | visible según capacidades |
| `LEGACY_MARCHA_BLANCA` | visible solo con flag y capacidad |
| `PROTOTIPO` | oculto y bloqueado por frontera informativa |
| `FUERA_PILOTO` | oculto y bloqueado por frontera informativa |

## Compatibilidad de rutas

Las URLs `/produccion/kardex`, `/produccion/recepcion-mangas`,
`/produccion/reproceso`, `/produccion/alertas` y otras se conservan. El registro
las clasifica en su nueva área sin inferirla por prefijo. Los enlaces nuevos
usan claves de función y pueden normalizarse en una evolución posterior.

Para N4 la ruta primaria ya nace normalizada como
`/control/supervision-produccion`. El alias `/produccion/supervision`, si se
conserva por compatibilidad, redirige a la ruta canónica y no crea otra vista ni
otra autoridad.

## Evolución no bloqueante

El registro prepara `keywords`, prioridad y claves estables para incorporar
después búsqueda global, favoritos, recientes, contadores y vistas guardadas.
Estas funciones no forman parte de N1/N2. En N4 también quedan fuera tendencias
avanzadas, exportación, pronóstico y vistas guardadas.
