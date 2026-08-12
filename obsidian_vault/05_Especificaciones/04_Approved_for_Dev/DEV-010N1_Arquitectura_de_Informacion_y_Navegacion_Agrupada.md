---
tipo: approved-for-dev
estado: desplegado-pendiente-uat
tags: [scm, frontend, ux, navegacion, tdd]
relaciones:
  - "[[US-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
  - "[[TS-010N1_Arquitectura_de_Informacion_y_Navegacion_Agrupada]]"
  - "[[Baseline_TS-010N_2026-08-08]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-09
---

# DEV-010N1: Arquitectura de información y navegación agrupada

## Resultado autorizado

Implementar N1 sin renombrar rutas físicas, endpoints ni reglas de dominio.
La reorganización debe clasificar cada vista existente mediante un registro
único y mantener compatibilidad con marcadores del piloto.

## Secuencia TDD

1. BASELINE: usar [[Baseline_TS-010N_2026-08-08]].
2. RED N1-09: demostrar que `/produccion/kardex` activa Producción.
3. GREEN: introducir registro y resolución específica por función.
4. RED/GREEN N1-01, N1-05 y N1-07: áreas, compatibilidad y legacy.
5. RED/GREEN N1-04: sidebar/drawer sin tabs globales desbordadas.
6. RED/GREEN N1-03: maestros agrupados y un solo CRUD canónico.
7. RED/GREEN N1-06/N1-08: disponibilidad y capacidades.
8. RED/GREEN N1-02: enlaces OF/OA desde Planificación sin duplicar ejecución.
9. Ejecutar suite, lint, build y smoke responsive.

## Restricciones

- No crear rutas `/almacen/*` o `/control/*` en este corte.
- No duplicar componentes para simular la nueva ubicación.
- No mostrar prototipos como funcionalidad productiva.
- No implementar N2, búsqueda global, favoritos, recientes ni contadores.
- No convertir la navegación en autoridad de permisos.

## Criterio de completada

- [x] N1-01…N1-09 cubiertos automáticamente.
- [x] Kardex activa Almacén e inventario.
- [x] Preparación activa Materiales.
- [x] OF/OT/OA permanecen en Producción.
- [x] Producción no contiene recepción, Kardex, reproceso, alertas o legacy.
- [x] URLs existentes siguen resolviendo.
- [x] Suite, lint y build verdes.
- [x] Vault actualizado con evidencia real.
- [x] Padres desplegables e hijos conservan el mismo ancho clicable; la
  jerarquía se expresa por sangría, altura y tipografía, no por una hitbox
  irregular.

## Evidencia de implementación — 2026-08-08

- registro único `workspaceRegistry.js` y adaptador temporal `navigation.js`;
- sidebar plegable en escritorio y drawer en móvil, con secciones del área activa;
- eliminación de `ModuleTabs` como navegación global y breadcrumbs derivados del registro;
- guardas de madurez que no montan prototipos o funciones fuera del piloto;
- maestros agrupados en las cinco familias aprobadas sin duplicar CRUD;
- Planificación enlaza a las vistas canónicas de OF/OA después de confirmar;
- `npm test -- --run`: **40 archivos / 173 pruebas verdes**;
- `npm run build`: verde;
- `npm run lint`: cero errores y una advertencia preexistente en
  `ProductionPlanningScm.jsx:178` (`react-hooks/exhaustive-deps`), ya registrada
  en el baseline.
- smoke responsive local verde en 390 px: drawer accesible, Almacén/Kardex
  visibles, cero `tablist` global y cero desborde horizontal del shell.
- hardening local 2026-08-09: `ListItemButton` usa `width: 100%` y
  `box-sizing: border-box` tanto para el botón de área como para sus enlaces;
  la prueba focal `WorkspaceNavigationShell.spec.jsx` quedó **6/6**, lint y
  build productivo verdes. En navegador, el padre Producción y el hijo activo
  midieron `231.33 px`, y el extremo derecho del padre expandió/contrajo el
  área correctamente.

La validación visual en Render queda gobernada por
[[UAT_TS-010N1_Navegacion_Agrupada]].

## Despliegue

- frontend `6df4d28` (`feat: group SCM workspace navigation`);
- rama `codex/render-provisional-dashboard`;
- Render publicó el artefacto el 2026-08-08 19:28:59 UTC;
- bundle productivo observado: `assets/index-Amrktyas.js`;
- smoke remoto de Gerente General verde en Kardex, guarda fuera del piloto y
  viewport de 390 px.
- ajuste semántico `596ba2d`: el recorrido transversal ya no afirma estados
  documentales; bundle Render `assets/index-CJQ-96rS.js`, 174 pruebas verdes.
- consistencia `6a7beeb`: el paso 2 queda fijo como **Órdenes técnicas · OF y
  OA** en Planificación, Fabricación y Armado; bundle `assets/index-eMik2xsT.js`.
