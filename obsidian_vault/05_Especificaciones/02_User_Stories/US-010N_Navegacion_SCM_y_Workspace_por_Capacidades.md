---
tipo: user-story
subtipo: epic
estado: refinada
tags: [scm, frontend, ux, navegacion, workspace, capacidades, epic]
relaciones:
  - "[[2026-08-08_Arquitectura_de_Informacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[US-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
  - "[[US-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes]]"
  - "[[US-010N4_Supervision_de_Produccion_Read_Model_Operativo]]"
  - "[[Vista_US-010N_Workspace_Navegacion_e_Inicio]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-10
---

# US-010N: Navegación SCM y workspace por capacidades

## Propósito

**Como** usuario del SCM \
**Quiero** encontrar mi trabajo por proceso y recibir un inicio derivado de mis
capacidades \
**Para** operar sin conocer la estructura técnica del sistema ni perder
funciones importantes entre pestañas extensas.

Esta nota organiza la arquitectura aprobada en
[[2026-08-08_Arquitectura_de_Informacion_SCM_y_Workspace_por_Capacidades]]. Es
una épica y no genera una Tech Spec monolítica.

## Resultado observable

```text
Gerente General
├── Inicio: pendientes, accesos fijados y situación de planta
├── Planificación
├── Producción
├── Materiales
├── Almacén e inventario
├── Control
└── Soporte: Maestros, Administración y Guía

Gestor de maestros
├── Inicio: carga y revisión de catálogos
├── Datos maestros
└── Guía
```

Ambas experiencias proceden del mismo registro de funciones. No son menús
copiados por cargo.

## Historias hijas

| Historia | Entrega vertical |
|---|---|
| [[US-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada|N1]] | Áreas coherentes, sidebar responsive, maestros centralizados, madurez y compatibilidad de rutas |
| [[US-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades|N2]] | Workspace automático por capacidades, rol principal, foco/inicio/prioridades y previsualización |
| [[US-010N3_Jornadas_de_Planta_y_Contexto_Temporal_de_Ordenes|N3]] | Contexto temporal de OF/OA y Jornadas operativas por recurso, fecha y turno |
| [[US-010N4_Supervision_de_Produccion_Read_Model_Operativo|N4]] | Control de solo lectura para consultar Fabricación y Armado por lista, detalle y resumen |

## Invariantes transversales

1. Una función posee una sola ubicación primaria en la arquitectura.
2. Los enlaces contextuales no crean otra autoridad ni otro CRUD.
3. La API valida todos los comandos aunque el frontend oculte una acción.
4. Una preferencia de rol no concede permisos.
5. Un rol nuevo funciona con capacidades sin modificar componentes.
6. Las rutas históricas siguen resolviendo durante el piloto.
7. Prototipos y cortes fuera del piloto no se presentan como operables.
8. No se exponen términos internos cuando existe lenguaje operativo aceptado.

## Fuera de alcance

- renombrar masivamente rutas físicas o endpoints;
- rediseñar pantallas de dominio internas;
- búsqueda global de documentos y maestros;
- favoritos y recientes persistentes por persona;
- contadores vivos de cada bandeja;
- permisos configurables desde el frontend sin validación server-side;
- layout arbitrario tipo constructor de dashboards.

## Secuencia de entrega

1. N1 introduce el registro único, la nueva agrupación y sus guardas.
2. N2 deriva Inicio y experiencia desde capacidades y preferencias gobernadas.
3. N3 separa la jornada operativa por recurso, fecha y turno.
4. N4 incorpora Supervisión en Control sin trasladar comandos de Jornadas.
5. Se actualizan Guía, documentación frontend y pruebas de acceso por rol.
6. La UAT del piloto revalida hallazgo de Kardex, Preparación, ejecución y
   supervisión.

## Definición de completada

- [ ] N1–N4 implementadas y probadas según el estado de cada hija.
- [ ] Ninguna vista productiva queda huérfana o duplicada en el menú.
- [ ] Un rol nuevo con capacidades obtiene workspace sin editar código de rol.
- [ ] Acceso directo sin capacidad continúa bloqueado por API/ruta.
- [ ] Navegación móvil y escritorio no desborda horizontalmente.
- [ ] Guía SCM usa la misma taxonomía.
