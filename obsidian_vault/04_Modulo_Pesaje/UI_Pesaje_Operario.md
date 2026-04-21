---
tipo: modulo
estado: placeholder
tags: [pesaje, ui, operario]
fecha_creacion: 2026-04-21
---

# UI de Pesaje para Operario

Documenta la interfaz de usuario específica del módulo de pesaje en planta.

## Requerimientos de UX
- Pantalla simplificada para uso en planta (resistente a errores)
- Lectura automática de balanza con confirmación manual
- Visualización del acumulado de bultos pesados
- Comparación en tiempo real contra producción reportada

## Flujo del Operario
1. Seleccionar [[Registro_Diario]] activo (o se detecta automáticamente)
2. Colocar bulto en balanza → lectura automática
3. Confirmar peso y color
4. Sistema registra en [[Control_Peso]]
5. Dashboard muestra Total Pesado vs Teórico

> **TODO:** Diseño de mockups y especificación detallada.
