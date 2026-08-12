---
tipo: modelo_bd
tabla: control_peso
estado: activo
tags: [dominio, core, pesaje, calidad, verificacion]
relaciones_padre:
  - "[[Registro_Diario]]"
relaciones_modulo:
  - "[[Sincronizacion_Datos]]"
  - "[[UI_Pesaje_Operario]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[Unidad_Logistica]]"
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-07-23
---

# Control de Peso (Doble Verificación)

Sistema de pesaje individual de "bultos" para contrastar con la producción reportada. Sirve como doble verificación y control de calidad.

> [!IMPORTANT] Evolución SCM
> El modelo actual es legacy y no identifica obligatoriamente la salida ni una unidad logística. [[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion|US-010D]] lo sustituye para pesajes nuevos por una captura idempotente asociada a [[Unidad_Logistica]], estación y contenido exacto. El contenido puede ser un `LoteSalidaPiezaColor` o un producto de [[Orden_Armado]]. La evidencia legacy se conserva y no se transforma silenciosamente en inventario SCM.

> [!WARNING] Bolsas compuestas
> `SUM(peso_real_kg)` mide kg físicos embolsados. No equivale necesariamente a kg producidos por la máquina: una bolsa de baldes con asas previas incluye inventario consumido durante [[US-010F_Prearmado_y_Armado_Concurrente_Trazable|US-010F]]. El descuento porcentual legacy tampoco crea genealogía ni demuestra el peso individual de cada componente.

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
| **Peso Teórico legacy** | Proyección del molde/contadores, antes de sustituir `total_kg_real` por pesajes. | `coladas × peso_snapshot_aplicable` |
| **Diferencia** | Discrepancia entre ambos. | `total_pesado - peso_teorico` |
| **Coincide** | Validación con tolerancia. | `ABS(diferencia) < 5 Kg` |

Usar `registro.total_kg_real` como teórico después de que ese mismo campo fue reemplazado por `SUM(ControlPeso)` sería circular. Esta comparación solo es interpretable para una bolsa simple del mismo contenido. Para producto armado se compara el peso físico contra la BOM ejecutada y se conserva por separado el aporte estándar de la OT actual, los componentes previos y el residual.

## Relaciones
- **Padre:** [[Registro_Diario]] (N:1)
- **Módulo:** [[Integracion_Balanza]] (fuente de datos de peso)
