---
tipo: alcance-piloto
estado: aprobado-con-gates
fecha_actualizacion: 2026-08-10
tags: [scm, piloto, uat, kardex, produccion, armado, trabajo-color]
relaciones:
  - "[[2026-08-03_Alcance_Piloto_Apertura_Inicial_sin_Recepcion_Compras]]"
  - "[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]"
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[UAT_TS-010M_OT_y_Trabajos_Color]]"
  - "[[US-010N_Navegacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[US-010N4_Supervision_de_Produccion_Read_Model_Operativo]]"
  - "[[UAT_TS-010N4_Supervision_de_Produccion]]"
---

# Alcance del nuevo piloto SCM — agosto 2026

## Resultado que se quiere validar

Demostrar que una demanda de ProductoTerminado puede planificarse, fabricarse,
pesarse, recibirse, abastecer Armado y terminar como mangas de PT trazables en
Kardex, partiendo de un conteo físico inicial controlado.

## Incluido

1. Maestros, Artículo SCM, BOM, rutas y perfiles de empaque.
2. Conteo y apertura inicial de materia prima, material recuperado, piezas, WIP
   y PT necesarios para las OP seleccionadas.
3. OP de demanda, cobertura, metas justificadas, OF y OA.
4. Requerimiento, reserva y emisión mínima de materiales para OF.
5. OT de máquina/turno con cola de Trabajos de color atómicos, mangas,
   asignación directa de stickers a maquinistas, relevo dentro de la misma OT,
   preetiqueta, pesaje y etiqueta final.
6. Recepción por QR y nacimiento de Kardex para mangas producidas.
7. Picking, custodia, consumo y retorno hacia Armado.
8. Cierre de Armado, genealogía, manga PT, pesaje y recepción PT.
9. Registro y almacenamiento de merma recuperable.
10. Alertas operativas y segregación de acciones sensibles.
11. Navegación por áreas e Inicio derivado de capacidades, conservando rutas y
    autorización server-side.
12. Supervisión de producción P0/P1 en Control: lista, detalle y resumen diario
    o mensual de Fabricación y Armado, permisos progresivos, recencia y
    paginación, sin comandos ni mezcla con la fuente legacy.

## Segundo recorrido opcional del mismo piloto

`merma recuperable -> orden de molienda -> lote recuperado -> liberación -> reserva y consumo en OF`.

Se vuelve obligatorio si la OP de UAT necesita producir material recuperado
durante el período de prueba. Si existe material recuperado al momento del
corte, puede abrirse como inventario inicial.

## Fuera del primer lanzamiento

- recepción completa de compras, OC, guía/factura, discrepancias y devolución a
  proveedor;
- despacho a clientes y devoluciones comerciales;
- operación offline;
- reabastecimientos recurrentes mediante `APERTURA_INICIAL`;
- reglas contables o valorización de inventario;
- manga que continúa en otra OT, turno o fecha y pesaje/control intermedio;
- `TramoMangaTrabajoColor`;
- material preparado almacenable, mezcla experimental y generaciones R1…Rn;
- migración de Armado a `TrabajoArmado`; se conserva el adaptador vigente;
- tendencias avanzadas, pronóstico, exportación y vistas guardadas de
  Supervisión.

## Desarrollo todavía necesario

| Corte | Estado actual | Cierre requerido |
|---|---|---|
| Apertura inicial | Implementada local: lote, pegado tabular, revisión, aprobación segregada y aplicación atómica | UAT con conteo y actores reales |
| US-010B mínimo | Frontend mock, sin API transaccional | Requerimiento, reserva, emisión, devolución y premezcla cuando aplique |
| Seguridad piloto | Capacidades server-side y actores locales | Identidades humanas, asignación de roles y prueba de accesos permitidos/denegados |
| US-010M1/M2/M3 | Implementación local y suites automáticas verdes; UAT pendiente | Aplicar migración en el entorno UAT y aprobar [[UAT_TS-010M_OT_y_Trabajos_Color|UAT-M]] con hardware real |
| US-010N1/N2 | N1/N2 desplegados; Inicio y Administración verificados con Gerente General | Aprobar perfiles limitado/multirrol y responsive táctil en [[UAT_TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades|UAT-N2]] antes de la UAT integral |
| US-010N3 | Implementada localmente | Completar smoke y UAT humana de Jornadas para Fabricación y Armado |
| US-010N4 | P0/P1 implementados localmente; suites backend/frontend, lint y build verdes | Completar smoke visual y aprobar [[UAT_TS-010N4_Supervision_de_Produccion|UAT-N4]] diaria/mensual, permisos y conciliación sin mutaciones |
| Integración | Módulos locales disponibles | Recorrido E2E sin crear saldos o documentos ficticios |

## Puertas anteriores a UAT

1. Cargar y revisar maestros reales mínimos.
2. Completar los dos cortes de desarrollo anteriores.
3. Completar M1, M2 y M3 y aprobar UAT-M con dos colores y un relevo.
4. Seleccionar una OP y delimitar cantidades de prueba.
5. Ejecutar conteo físico de los artículos involucrados.
6. Asignar actores UAT y capacidades.
7. Preparar balanza, impresora, lector QR y ubicaciones físicas.
8. Revalidar que cada actor encuentre solo sus áreas habilitadas y que Kardex,
   Preparación y Control no queden ocultos bajo Producción.
9. Antes del cierre integral, ejecutar UAT-N4 con Fabricación multicolor,
   Armado, corrección/anulación, recepción, permisos parciales y cursor.

## Criterio para lanzar el piloto

El piloto se habilita solamente cuando:

- la migración sobre una copia de la base objetivo es repetible;
- cada OT monocolor histórica recibe exactamente un Trabajo de color sin
  perder IDs, QR, etiquetas, pesajes o recepción;
- UAT-M valida una OT con dos colores, subconjuntos de stickers y relevo dentro
  de la misma OT;
- UAT-N4 valida conciliación diaria/mensual, separación de kg físico/estándar,
  permisos progresivos, freshness y cero comandos desde Control;
- el E2E automatizado y la UAT física están aprobados;
- no existen comandos mock en el recorrido elegido;
- las impresiones y QR fueron validados físicamente;
- existe procedimiento de contingencia, respaldo y conciliación diaria;
- los responsables conocen qué acciones pueden ejecutar y cómo escalar una
  inconsistencia.
