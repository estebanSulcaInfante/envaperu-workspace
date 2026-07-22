---
tipo: modelo_bd
tabla: control_peso
estado: activo
tags: [dominio, core, pesaje, calidad, verificacion]
relaciones_padre:
  - "[[Registro_Diario]]"
relaciones_modulo:
  - "[[04_Modulo_Pesaje]]"
fecha_creacion: 2026-04-21
---

# Control de Peso (Doble Verificación)

Sistema de pesaje individual de "bultos" para contrastar con la producción reportada. Sirve como doble verificación y control de calidad.

## Campos de la Tabla

| Atributo | Origen | Descripción |
| :--- | :--- | :--- |
| **ID** | Auto | Identificador del pesaje. |
| **Registro ID (FK)** | Sistema | Vinculado al [[Registro_Diario]] padre. |
| **Peso Real (Kg)** | Input/Balanza | Peso medido del bulto. |
| **Color** | Input | Color o identificador del bulto. |
| **Hora Registro** | Automático | Timestamp del pesaje. |

## Validación de Peso

> **Nota de alcance 2026-07-15:** esta validación compara bultos de producción contra lo reportado en `Registro_Diario`. La regla legacy de `5 kg` no es una tolerancia de recepción de materias primas y no debe reutilizarse como valor de `C-TOL-01`. Su vigencia debe revisarse en la historia de pesaje/salida correspondiente.

| Métrica | Descripción | Fórmula |
| :--- | :--- | :--- |
| **Total Pesado** | Suma de todos los bultos. | `SUM(peso_real_kg)` |
| **Peso Teórico** | Peso calculado del registro. | `registro.total_kg_real` |
| **Diferencia** | Discrepancia entre ambos. | `total_pesado - peso_teorico` |
| **Coincide** | Validación con tolerancia. | `ABS(diferencia) < 5 Kg` |

## Relaciones
- **Padre:** [[Registro_Diario]] (N:1)
- **Módulo:** [[Integracion_Balanza]] (fuente de datos de peso)
