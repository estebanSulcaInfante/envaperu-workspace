---
tipo: draft
estado: refinado
tags: [catalogo, producto-terminado, wizard, carga-inicial, ux]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
---

# Alta guiada integral de ProductoTerminado

## Necesidad observada

La carga desde cero de un producto real obliga hoy a buscar información en varios Excel denormalizados y a saltar entre Productos, Líneas/Familias, Moldes, Piezas, Colores, Materiales, Ingeniería SCM y Empaque. La vista denominada **Configuración guiada** sólo coordina Molde, Pieza y PiezaColor; no conduce hasta un ProductoTerminado utilizable por Planificación.

La interfaz principal de alta debe permitir que una persona experimentada de planta capture, contraste y complete en un único recorrido todos los datos necesarios para un ProductoTerminado nuevo, sin perder el avance cuando falte un dato confiable.

## Resultado esperado

- una sesión durable que pueda cerrarse con **Guardar y salir** y reanudarse desde cualquier estado abierto;
- búsqueda y reutilización antes de cada alta para evitar duplicados;
- seis pasos navegables hacia atrás y hacia adelante según dependencias: `IDENTIDAD`, `COMPONENTES`, `COLORES`, `ESTRUCTURA`, `RUTA_EMPAQUE` y `REVISION`;
- creación contextual válida de catálogos pequeños sin abandonar la sesión;
- incorporación de ProductoTerminado, molde, piezas, variantes, formulaciones, BOM/WIP, ruta y empaque;
- revisión final que distinga bloqueos, advertencias y datos opcionales;
- publicación directa o envío a aprobación según las capacidades del actor;
- una experiencia visual especialmente cuidada, con ayuda contextual y una mascota mínima no intrusiva.

## Restricciones

- No inventar información que falte en los Excel o en la experiencia del trabajador.
- Crear una Familia desde una Línea debe usar `POST /api/catalogo/lineas/{linea_id}/familias` con el objeto `familia`: crea también `LineaFamilia` en la misma transacción y selecciona el resultado. Dentro del asistente queda prohibido el `POST /api/catalogo/familias` global porque deja la Familia sin vínculo utilizable.
- ProductoTerminado es la autoridad de clasificación comercial. La clasificación de Pieza, si existe, es técnica y opcional.
- El asistente no debe reactivar el BOM plano `ProductoPieza`, los KIT legacy ni la creación de PiezaColor genérica sin color.
- Las aprobaciones revisionadas conservan sus reglas de gobierno; volver atrás no reescribe una revisión aprobada.
- No se construye una transacción gigante. Cada paso aplica comandos canónicos idempotentes y la sesión conserva qué quedó creado o reutilizado.

## Alcance del primer piloto

El recorrido integral se entrega por incrementos y permanece pendiente hasta completar A/B/C: A aporta shell durable y `IDENTIDAD` real; B integra `COMPONENTES` y `COLORES`; C integra `ESTRUCTURA`, `RUTA_EMPAQUE` y `REVISION`. La importación automática de Excel, reconocimiento con IA, colaboración simultánea avanzada y animaciones ricas de la mascota quedan para incrementos posteriores.

## Continuidad del pipeline

Este borrador se refina en [[../02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado|US-012]] y sus historias hijas.
