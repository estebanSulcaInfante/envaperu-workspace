---
tipo: decision-arquitectura
estado: aceptada
fecha_decision: 2026-08-08
fecha_actualizacion: 2026-08-09
tags: [scm, frontend, ux, arquitectura-informacion, navegacion, roles, capacidades, piloto]
relaciones:
  - "[[2026-07-30_Experiencia_por_Actor_y_Navegacion_por_Capacidades]]"
  - "[[US-010N_Navegacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[Arquitectura_Workspace_SCM_por_Areas]]"
  - "[[Arquitectura_Navegacion_Por_Procesos]]"
  - "[[Vista_US-010N_Workspace_Navegacion_e_Inicio]]"
  - "[[Alcance_Nuevo_Piloto_SCM_2026-08]]"
---

# Arquitectura de información SCM y workspace por capacidades

## Contexto

El frontend creció incorporando OP, OF, OA, OT, Trabajo de color, mangas,
materiales, recepción, Kardex, reproceso, alertas y maestros. La navegación
vigente concentra trece accesos heterogéneos bajo **Producción**, mientras que
funciones centrales como Kardex y Preparación de materiales quedan ocultas o
rotuladas con nombres poco reconocibles.

El inicio también depende de una lista estática de tareas, una prioridad de
roles codificada en frontend y un recorte arbitrario a seis tarjetas. Crear un
nuevo rol en backend no produce una experiencia completa sin editar código.

## Decisión

### 1. Navegación por intención de trabajo

El primer nivel queda congelado así:

```text
Inicio
Planificación
Producción
Materiales
Almacén e inventario
Control

Soporte
├── Datos maestros
├── Administración
└── Guía SCM
```

Cada área responde una pregunta:

| Área | Pregunta |
|---|---|
| Planificación | ¿Qué se necesita producir y qué trabajo técnico se generó? |
| Producción | ¿Cómo, cuándo y con qué recursos se ejecutará? |
| Materiales | ¿Qué material se requiere y cómo llega al consumo? |
| Almacén e inventario | ¿Qué existe físicamente, dónde está y cómo ingresó? |
| Control | ¿Qué ocurre, qué falló y qué requiere atención? |
| Datos maestros | ¿Cuál es la definición canónica reutilizada por los procesos? |
| Administración | ¿Cómo se gobiernan acceso, estaciones e integraciones? |

**Producción** deja de ser un contenedor genérico. Conserva únicamente
Fabricación, Jornadas de Planta y Armado. Jornadas proyecta Fabricación por
máquina y Armado por centro; los editores especializados permanecen separados.

### 2. Proyección en Planificación y ejecución autoritativa

Planificación muestra las OF y OA producidas por el plan, con OP de origen,
cantidad, cobertura, revisiones congeladas, estado y enlace contextual. No
edita máquina, corrida, maquinista, mangas, picking ni genealogía.

La configuración y transición autoritativa de OF, OA, OT y Trabajo de color
permanece en Producción. Mostrar el mismo identificador en dos áreas no crea
dos documentos ni dos fuentes de verdad.

### 3. Maestros centralizados

Datos maestros permanece como un solo hub canónico agrupado en:

1. Producto e ingeniería.
2. Materiales y proveedores.
3. Planta y logística.
4. Organización.
5. Gobierno de datos.

Una acción contextual como **Ver maestro** abre el mismo registro canónico. No
se crean CRUD paralelos dentro de Producción, Materiales o Almacén.

### 4. Registro único de funciones UI

Rutas, navegación, tareas de inicio y metadatos de madurez se describen una
sola vez en un registro de funciones versionado con el frontend. Cada entrada
usa una clave estable y declara área, sección, ruta física, coincidencias,
capacidades, prioridad, madurez y posibilidad de aparecer como tarea.

La ruta sigue siendo código confiable; un administrador no puede introducir
URLs o componentes arbitrarios desde base de datos.

### 5. Workspace derivado, no pantalla generada

El workspace se calcula así:

```text
identidad -> capacidades efectivas -> funciones elegibles
          -> madurez habilitada -> preferencias del rol -> inicio visible
```

Crear un rol con capacidades produce navegación e inicio automáticamente. El
perfil del rol solo configura foco, función inicial y prioridades/fijados. Una
preferencia nunca concede capacidad ni elude la autorización del backend.

No se crea una pantalla física por rol. Todos usan los mismos componentes y
contratos filtrados por capacidades.

### 6. Rol principal explícito

Una persona con varios roles debe tener un rol principal explícito para el
rótulo y preferencias del workspace. Las capacidades efectivas siguen siendo
la unión de todos sus roles activos. Si no se ha configurado un principal, el
sistema usa una experiencia genérica y solicita regularización administrativa;
no aplica una prioridad hardcodeada.

### 7. Madurez visible y segura

Las funciones se clasifican como:

- `PILOTO`;
- `DISPONIBLE`;
- `LEGACY_MARCHA_BLANCA`;
- `PROTOTIPO`;
- `FUERA_PILOTO`.

`PROTOTIPO` y `FUERA_PILOTO` no aparecen en el workspace productivo. El acceso
directo muestra una frontera de disponibilidad y no monta comandos mock.
`LEGACY_MARCHA_BLANCA` exige capacidad y habilitación explícita por entorno.

### 8. Compatibilidad durante el piloto

El primer incremento no renombra endpoints ni rutas físicas. La nueva
arquitectura asigna cada ruta existente a una sola función y conserva alias y
marcadores. La normalización futura de URLs será otro incremento.

## Mapa funcional aprobado

| Área | Secciones |
|---|---|
| Planificación | Demanda y OP; cobertura y metas; plan; OF/OA generadas |
| Producción | Fabricación/OF; Jornadas de Planta (Fabricación por máquina y Armado por centro); detalle Armado/OA |
| Materiales | Preparación; reserva/emisión/devolución; abastecimiento interno; reproceso/molienda |
| Almacén e inventario | Recepción; Calidad; Kardex/existencias; movimientos/ajustes/reversas |
| Control | Avance; alertas; pesajes/correcciones/anulaciones; marcha blanca/legacy |
| Datos maestros | Producto; materiales; planta; organización; gobierno de datos |
| Administración | Roles/capacidades; estaciones; parámetros técnicos; integraciones |

## Consecuencias

- Kardex y recepción de mangas dejan de presentarse como Producción.
- Preparación de materiales recibe su nombre operativo explícito.
- Registro diario y talonarios pasan a la zona controlada de marcha blanca.
- Configuración deja de reutilizar el componente prototipo de recepción.
- El filtrado de frontend mejora la comprensión, pero la API sigue siendo la
  autoridad de acceso.
- Búsqueda global, favoritos, recientes y contadores vivos son evoluciones
  posteriores; el registro deja las claves preparadas, pero no bloquean N1/N2.

## Decisión extendida

Esta ADR extiende
[[2026-07-30_Experiencia_por_Actor_y_Navegacion_por_Capacidades]]. Sustituye su
implementación estática de experiencia/prioridad, no sus principios de
autorización server-side, segregación ni mínimo de interacción por actor.
