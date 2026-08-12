---
tipo: user-story
estado: refinada
tags: [scm, frontend, ux, navegacion, responsive, atdd]
relaciones:
  - "[[US-010N_Navegacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[TS-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
  - "[[Arquitectura_Navegacion_Por_Procesos]]"
  - "[[Vista_US-010N_Workspace_Navegacion_e_Inicio]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-09
---

# US-010N1: Arquitectura de información y navegación agrupada

## Historia

**Como** usuario operativo o administrativo  
**Quiero** navegar por áreas que representen mi intención de trabajo  
**Para** encontrar Kardex, Preparación, ejecución y maestros sin recorrer una
lista plana de entidades inconexas.

## Alcance

- registro único de funciones UI;
- áreas Planificación, Producción, Materiales, Almacén e inventario y Control;
- soporte Datos maestros, Administración y Guía;
- sidebar plegable en escritorio y drawer en móvil;
- landing o navegación contextual por área;
- madurez y frontera de funciones no habilitadas;
- compatibilidad con rutas y alias existentes;
- agrupación interna del hub de Datos maestros.

## Ubicación canónica

| Función actual | Ubicación primaria |
|---|---|
| OP, demanda, cobertura, plan y proyección OF/OA | Planificación |
| OF | Producción / Fabricación |
| Jornadas de Fabricación por máquina y de Armado por centro | Producción / Jornadas de Planta |
| Detalle OA, abastecimiento y cierre de Armado | Producción / Armado |
| Preparación, reserva, emisión y devolución | Materiales / Preparación |
| Abastecimiento a Armado | Materiales / Abastecimiento interno |
| Reproceso y molienda operativos | Materiales / Reproceso |
| Recepción de mangas y Calidad | Almacén e inventario / Recepción |
| Kardex, saldos, movimientos y reversas | Almacén e inventario |
| Avance, alertas y pesajes históricos | Control |
| Registro diario y talonarios | Control / Marcha blanca |
| Reglas de reproceso y alertas | Datos maestros / Gobierno |

## Invariantes

1. Cada función tiene una clave y ubicación primaria únicas.
2. Los enlaces desde otro proceso son contextuales y conservan el mismo ID.
3. Planificación consulta OF/OA generadas, pero Producción gobierna su ejecución.
4. Producción no contiene Kardex, recepción, reproceso, alertas o legacy.
5. Datos maestros es un único hub; no se copian tablas maestras.
6. La selección de workspace no se deduce solo del prefijo de URL.
7. Una ruta específica prevalece sobre alias o patrones generales.
8. Ocultar una función por madurez no sustituye autorización.
9. `PROTOTIPO` y `FUERA_PILOTO` no montan comandos en producción.
10. El primer corte conserva URLs físicas y enlaces históricos.
11. No existe navegación horizontal obligatoria para descubrir las áreas.
12. El menú visible se filtra por al menos una capacidad efectiva requerida.

## Escenarios ATDD/BDD

### N1-01 — Las funciones críticas se encuentran por proceso

**Dado** un actor con permisos de Preparación, Kardex y Producción  
**Cuando** abre la navegación principal  
**Entonces** encuentra Preparación en Materiales, Kardex en Almacén e
inventario y OF/OT/OA en Producción, sin duplicados primarios.

### N1-02 — OF y OA proyectadas desde Planificación

**Dado** una OP con plan confirmado que generó una OF y una OA  
**Cuando** se consulta Planificación  
**Entonces** ambas aparecen con su OP, cantidad, estado y enlace a Producción,
pero sin controles de corrida, manga, picking o cierre.

### N1-03 — Maestros no dispersos

**Dado** un material mostrado durante Preparación  
**Cuando** el usuario usa **Ver maestro**  
**Entonces** abre el registro canónico de Datos maestros y no un formulario
duplicado dentro de Materiales.

### N1-04 — Navegación responsive sin desborde

**Dado** un viewport móvil intermedio  
**Cuando** el actor abre Ingeniería, Planificación o Producción  
**Entonces** navega mediante drawer/secciones legibles y ningún acceso esencial
depende de desplazar horizontalmente trece pestañas.

### N1-05 — Compatibilidad de marcadores

**Dado** un marcador a `/produccion/kardex` o `/produccion/recepcion-mangas`  
**Cuando** se abre después del cambio  
**Entonces** la misma vista carga, pero el shell la ubica en Almacén e
inventario.

### N1-06 — Corte fuera del piloto

**Dado** una función `PROTOTIPO` o `FUERA_PILOTO` en producción  
**Cuando** el usuario intenta entrar mediante URL directa  
**Entonces** ve una frontera de disponibilidad, no un CRUD mock ni una acción
que parezca persistente.

### N1-07 — Marcha blanca gobernada

**Dado** Registro diario o Talonarios con madurez `LEGACY_MARCHA_BLANCA`  
**Cuando** el entorno y la capacidad los habilitan  
**Entonces** aparecen bajo Control / Marcha blanca; en otro caso no aparecen.

### N1-08 — Ruta sin capacidad

**Dado** un actor sin la capacidad requerida  
**Cuando** intenta abrir una ruta conocida directamente  
**Entonces** la guarda de ruta impide operar y la API mantiene el rechazo.

### N1-09 — Estado activo inequívoco

**Dado** una ruta histórica cuyo prefijo era `/produccion` pero cuya función es
Kardex  
**Cuando** se renderiza el shell  
**Entonces** queda activa únicamente Almacén e inventario y no Producción.

## Dataset de ejemplo

- Gerente General con `OP_VER`, `OF_VER`, `OA_VER`, `OT_VER`,
  `INVENTARIO_VER`, `ALERTA_VER` y capacidades de maestros.
- Gestor de maestros con capacidades de artículo, ruta y empaque, sin comandos
  de producción.
- Renato con acceso a Datos maestros y sin Producción.
- Viewports `390x844`, `768x1024` y `1440x900`.
- Rutas físicas actuales de Planificación, Producción, Materiales, Kardex,
  recepción, Control, Maestros, Configuración y Guía.

## Definición de preparada

- [x] Taxonomía y límites aprobados.
- [x] Mapa de vistas existentes cerrado.
- [x] Compatibilidad de URLs decidida.
- [x] Madurez y visibilidad decididas.
- [x] Escenarios observables y automatizables.
- [x] Tech Spec hija disponible.
