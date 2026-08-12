---
tipo: user-story
estado: desplegada-pendiente-uat
tags: [scm, frontend, roles, capacidades, workspace, inicio, atdd]
relaciones:
  - "[[US-010N_Navegacion_SCM_y_Workspace_por_Capacidades]]"
  - "[[TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
  - "[[2026-07-30_Experiencia_por_Actor_y_Navegacion_por_Capacidades]]"
  - "[[Vista_US-010N_Workspace_Navegacion_e_Inicio]]"
  - "[[UAT_TS-010N2_Inicio_Parametrizado_por_Rol_y_Capacidades]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# US-010N2: Inicio parametrizado por rol y capacidades

## Historia

**Como** administrador del SCM  
**Quiero** que un rol nuevo obtenga automáticamente navegación e inicio según
sus capacidades, con preferencias gobernadas  
**Para** ampliar la organización sin programar otro menú o dashboard por cargo.

## Alcance

- derivación del workspace desde capacidades efectivas;
- foco, función inicial y prioridades/fijados opcionales por rol;
- rol principal explícito para personas con varios roles;
- previsualización administrativa del resultado;
- eliminación de `ROLE_EXPERIENCE`, `ROLE_PRIORITY`, `TASKS` y `slice(0, 6)`;
- estado seguro para perfiles de consulta o configuración incompleta;
- actualización de contratos de roles/trabajadores y `/api/auth/me`.

## Invariantes

1. Capacidad efectiva gobierna elegibilidad; preferencia solo ordena.
2. Una preferencia nunca hace visible una función sin capacidad.
3. La desactivación de trabajador, rol o capacidad se refleja en la siguiente
   carga de identidad.
4. Los roles nuevos no necesitan una constante en frontend.
5. El rol principal no limita la unión de capacidades de otros roles activos.
6. Si falta rol principal, se muestra foco genérico y se señala la
   regularización; no se aplica una jerarquía hardcodeada.
7. Una clave de función desconocida se ignora de forma segura.
8. El inicio no trunca silenciosamente tareas elegibles.
9. Un perfil de consulta conserva accesos de lectura y Guía sin inventar una
   acción pendiente.
10. El frontend no es autoridad de permisos.

## Reglas de orden

Las funciones elegibles se ordenan por:

1. fijada por rol;
2. prioridad configurada por rol;
3. prioridad predeterminada de la función;
4. título estable.

Los contadores vivos podrán alterar el orden en una historia posterior; no se
simulan pendientes con números estáticos en N2.

## Escenarios ATDD/BDD

### N2-01 — Rol nuevo sin código frontend

**Dado** el rol `AUDITOR_INVENTARIO` con `INVENTARIO_VER`  
**Cuando** se asigna como principal a una persona y esta inicia sesión  
**Entonces** obtiene Almacén e inventario y la tarea de consulta de Kardex sin
editar una constante de roles.

### N2-02 — Preferencia no concede autorización

**Dado** un rol que fija `production.machineWork` como inicio pero no tiene `OT_VER`  
**Cuando** se calcula su workspace  
**Entonces** la preferencia se ignora, se elige otra función elegible y la ruta
de OT continúa protegida.

### N2-03 — Persona con varios roles

**Dado** una persona con Planificación y Calidad y Calidad como rol principal  
**Cuando** abre Inicio  
**Entonces** el rótulo/foco procede de Calidad, pero aparecen todas las
funciones permitidas por la unión de capacidades.

### N2-04 — Principal pendiente

**Dado** una persona con dos roles activos sin principal  
**Cuando** abre Inicio  
**Entonces** recibe experiencia genérica, conserva sus capacidades y el
administrador ve el pendiente de configuración.

### N2-05 — Más de seis tareas

**Dado** Gerencia con más de seis funciones elegibles  
**Cuando** abre Inicio  
**Entonces** ninguna desaparece por posición; las fijadas y prioritarias se
presentan primero y el resto permanece accesible.

### N2-06 — Previsualización

**Dado** un administrador editando capacidades, foco y prioridades de un rol  
**Cuando** solicita **Así verá este rol**  
**Entonces** ve áreas, inicio y tareas calculadas antes de guardar, sin asumir
la identidad de otra persona ni ejecutar sus comandos.

### N2-07 — Rol o trabajador inactivo

**Dado** un rol o trabajador desactivado  
**Cuando** se refresca la identidad  
**Entonces** deja de aportar capacidades y no conserva tareas fijadas como
accesibles.

### N2-08 — Falla cerrada de identidad

**Dado** que `/api/auth/me` no puede cargar identidad o capacidades  
**Cuando** se construye el workspace  
**Entonces** no se habilitan comandos y se muestra un error recuperable.

### N2-09 — Clave retirada

**Dado** una preferencia persistida que referencia una función ya retirada  
**Cuando** se carga una nueva versión del frontend  
**Entonces** se ignora esa entrada, se usa el orden predeterminado y no falla el
inicio.

## Dataset de ejemplo

- Rol `AUDITOR_INVENTARIO`: `INVENTARIO_VER`, foco “Revisar existencias y
  movimientos”, inicio `warehouse.kardex`.
- Rol `CALIDAD`: capacidades de consulta/resolución y prioridad para recepción.
- Persona multirrol Planificación + Calidad, con Calidad principal.
- Gerencia con al menos ocho funciones elegibles.
- Rol de consulta sin comandos de escritura.

## Fuera de alcance

- constructor libre de dashboards;
- URLs administrables;
- preferencias personales, favoritos y recientes;
- contadores pendientes agregados entre módulos;
- suplantación de identidad para previsualizar;
- cambios en segregación o permisos de dominio.

## Definición de preparada

- [x] Fuente de elegibilidad y orden decididas.
- [x] Rol principal y multirrol definidos.
- [x] Fallback y claves obsoletas definidos.
- [x] Administración no puede conceder acceso por preferencia.
- [x] Escenarios observables y automatizables.
- [x] Tech Spec hija disponible.
