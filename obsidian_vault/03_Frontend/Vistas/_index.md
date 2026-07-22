---
tipo: modulo
estado: activo
tags: [frontend, vistas, ui]
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-07-22
---

# Frontend — Vistas

Este directorio documenta cada pantalla principal sin duplicar las reglas funcionales de sus US o TS. Ver [[03_Frontend/README|regla de autoridad y estados de madurez]].

La estructura transversal de menú, módulos y rutas se documenta en [[Arquitectura_Navegacion_Por_Procesos]].

## Flujo SCM

- [[SCM_Frontend_Overview_US-010]]: alcance completo y frontera entre historias.
- [[Guia_Operativa_SCM_US-010]]: recorrido gerencial, anatomía de pantallas, glosario y decisiones de cierre.
- [[Vista_US-010A_Recepcion_Materiales]]: recepción, cuarentena y decisión de Calidad; mock funcional.
- [[Vista_US-010P_Planificacion_Demanda_OP]]: demanda de ProductoTerminado, cobertura y generación de OP; mock funcional.
- [[Vista_US-010B_Preparacion_Materiales]]: plan, reserva, emisión, premezcla y trazabilidad; mock funcional.
- [[Vista_US-011A_Dashboard_Avance_Pesajes]]: avance gerencial por OP desde snapshots reales de la estación; API integrada.

## Inventario por Documentar

- `/datos-maestros/colores` (`ColoresRecetasAdmin`): CRUD de familias de color y colores, selector de paleta/HEX visual y recetas maestras versionadas conforme a [[TS-016_Maestro_Colores_y_Recetas|TS-016]];
- `/datos-maestros/configuracion-guiada`: asistente Molde–Pieza–PiezaColor conforme a [[TS-015_Asistente_Catalogo_Altas_En_Contexto_y_OP_Excepcional|TS-015]];

- `/datos-maestros/clasificacion` (`LineasFamiliasAdmin`): CRUD y asociaciones N:M definidos por [[TS-014_Normalizacion_Linea_Familia_NM_y_CRUD|TS-014]];
- lista y detalle de [[Orden_Produccion]];
- [[Registro_Diario]] o Hoja de Producción;
- operación local de balanza y monitor central completo de estaciones;
- catálogos de piezas, PiezaColor y ProductoTerminado;
- almacenes de piezas y de productos terminados.

El inventario pendiente no implica que las pantallas no existan; indica que todavía no poseen una ficha visual normalizada en el vault.
