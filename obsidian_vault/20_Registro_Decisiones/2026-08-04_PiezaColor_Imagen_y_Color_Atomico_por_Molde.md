---
tipo: adr
estado: aceptada
fecha: 2026-08-04
tags: [arquitectura, pieza-color, imagen, molde, integridad]
relaciones:
  - "[[Pieza]]"
  - "[[PiezaColor]]"
  - "[[Molde]]"
  - "[[Catalogo_Piezas_SKU_e_Imagenes]]"
  - "[[Vista_Catalogo_Piezas_SKU_e_Imagenes]]"
---

# ADR: Imagen en PiezaColor y habilitación atómica de color por molde

## Contexto

`Pieza` representa una forma abstracta. Una misma forma puede fabricarse en varios colores y participar en distintos moldes. Además, un molde puede producir varias piezas simultáneamente; esas salidas no pueden declarar disponibilidades de color incompatibles porque comparten material en el mismo tiro.

Guardar una única imagen en `Pieza` confunde la forma con su presentación física. Permitir crear variantes de color aisladas desde el catálogo puede expresar falsamente que una salida del molde está disponible en un color mientras las demás no lo están.

## Decisión

1. La imagen se almacena en [[PiezaColor]] mediante `imagen_mime` e `imagen_data`.
2. [[Pieza]] no almacena imagen ni color.
3. La habilitación de un color es un comando sobre [[Molde]], no sobre una salida individual.
4. El comando crea o reutiliza una [[PiezaColor]] para cada [[MoldePieza]] activa en una sola transacción.
5. La disponibilidad se deriva por cobertura completa; no se crea una tabla `MoldeColor` en este incremento.
6. La interfaz muestra Pieza como padre desplegable y PiezaColor como hijo con SKU, color e imagen.

## Consecuencias

- Un molde de tres salidas genera o reutiliza tres variantes al habilitar un color.
- Repetir la operación no duplica SKU.
- Las imágenes legacy de Pieza no se migran automáticamente porque su asignación a un color sería ambigua.
- La creación técnica legacy de PiezaColor puede existir como compatibilidad, pero no representa por sí sola disponibilidad de un molde; los flujos operativos deben validar cobertura completa.
- Si en el futuro se requieren restricciones comerciales adicionales por molde y color, se podrá introducir una entidad explícita sin cambiar la identidad global `Pieza + ColorProduccion`.
