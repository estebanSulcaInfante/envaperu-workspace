---
tipo: decision_arquitectura
estado: aceptada
tags: [frontend, scm, ux, articulos, accesibilidad]
fecha: 2026-08-05
---

# Selectores buscables de Artículos SCM

## Contexto

Ingeniería SCM reúne PiezaColor, WIP y ProductoTerminado. Una lista desplegable
convencional deja de ser utilizable al crecer los maestros y dificulta distinguir
artículos con nombres parecidos.

## Decisión

Los campos de artículo de alta cardinalidad usan un componente buscable común.
Permite filtrar por código, nombre, clase y datos identificadores del subtipo,
sin distinguir mayúsculas ni tildes. Cada opción expone código, nombre y clase.

El dominio permitido se filtra antes de presentar las opciones:

- resultado BOM: WIP y ProductoTerminado;
- componente BOM: PiezaColor y WIP;
- producto objetivo de ruta: ProductoTerminado;
- artículo empacable: PiezaColor, WIP y ProductoTerminado;
- salida de operación: catálogo admitido por el editor y validación al publicar.

Los catálogos pequeños y cerrados mantienen listas simples.

## Alcance del piloto

La búsqueda es local porque el catálogo completo ya forma parte de la carga de
Ingeniería. Si el volumen futuro hace costosa esa carga, el mismo contrato visual
evolucionará a búsqueda paginada en servidor sin volver a listas extensas.

## Consecuencias

- La búsqueda no puede ampliar las clases admitidas por cada flujo.
- El componente conserva selección por identidad estable, aunque cambie el texto.
- Se requiere cobertura automática para búsqueda normalizada, selección y
  restricciones contextuales.
- Código, nombre y clase deben permanecer visibles para reducir selecciones
  ambiguas y facilitar el uso con teclado.
