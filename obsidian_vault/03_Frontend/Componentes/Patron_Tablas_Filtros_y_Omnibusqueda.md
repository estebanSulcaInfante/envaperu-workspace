---
tipo: patron_ui
estado: activo
tags: [frontend, tablas, filtros, busqueda, componentes]
fecha_creacion: 2026-07-21
fecha_actualizacion: 2026-07-21
relacionados:
  - "[[Arquitectura_Navegacion_Por_Procesos]]"
  - "[[Patron_Capacidades_API_y_Mocks]]"
---

# Patrón de Tablas, Filtros y Omnibúsqueda

## Propósito

Los listados operativos y catálogos deben ofrecer una superficie predecible para localizar registros sin conocer de antemano qué columna contiene el dato.

## Barra Estándar

`DataTableToolbar` reúne:

- una **omnibúsqueda** a la izquierda;
- filtros cerrados propios del dominio;
- acción `Limpiar` cuando existe algún criterio activo;
- contador `visibles de totales`;
- comandos de la vista a la derecha.

La omnibúsqueda local usa `matchesOmniSearch` y cumple:

1. búsqueda en valores simples, objetos y colecciones anidadas;
2. comparación sin distinguir mayúsculas;
3. comparación insensible a tildes;
4. ausencia de mutación sobre la colección original.

## Tablas Locales y Paginadas

| Caso | Regla |
| :--- | :--- |
| Fixture o catálogo cargado completo | Buscar y filtrar en memoria sobre toda la colección. |
| Listado paginado por API | Enviar búsqueda y filtros al servidor; no presentar la página actual como si fuera el conjunto completo. |
| Filtro adicional sobre un reporte ya agregado | Puede aplicarse localmente si el contador aclara cuántas filas visibles existen en la respuesta. |

El histórico legacy de OP aplica la consulta en servidor sobre OP, molde, color y máquina. Así la omnibúsqueda cubre las columnas visibles incluso con paginación.

## Excepciones Deliberadas

No se añade barra de búsqueda a una tabla cuando representa:

- líneas de un formulario aún no confirmado;
- pesos bolsa por bolsa dentro de una sola recepción;
- saldos o composición de un único registro seleccionado;
- una vista previa breve de importación;
- una matriz de cálculo cuya lectura depende del contexto padre.

Esas tablas no son bandejas ni catálogos; agregar filtros allí ocultaría información necesaria para validar el registro completo.

## Estados Mínimos

Todo listado debe mostrar:

- carga sin desplazar de forma incoherente la estructura;
- error recuperable cuando consulta una API;
- vacío real;
- vacío causado por filtros;
- cantidad de resultados;
- controles adaptables a escritorio y móvil.

## Implementación

- Barra: `frontend/src/components/ui/DataTableToolbar.jsx`.
- Utilidades: `frontend/src/utils/tableSearch.js`.
- Tema de encabezados: `frontend/src/App.jsx`.
- Pruebas: `frontend/src/tests/tableSearch.spec.js`.

El patrón se encuentra aplicado en Planificación, OP, avance e histórico de pesajes, recepciones, reservas US-010B y catálogos de productos, piezas, moldes, trabajadores, máquinas y materias primas.

