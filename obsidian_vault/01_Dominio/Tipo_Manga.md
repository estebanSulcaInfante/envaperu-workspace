---
tipo: modelo_objetivo
estado: implementado-r-core
tags: [dominio, scm, manga, contenedor, maestro, tara, empaque, US-010C, US-010D]
relaciones:
  - "[[Perfil_Empaque]]"
  - "[[Unidad_Logistica]]"
  - "[[Etiqueta_Manga]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
fecha_creacion: 2026-07-24
fecha_actualizacion: 2026-07-24
---

# Tipo de Manga

Maestro configurable del soporte físico utilizado para contener la producción. En el lenguaje de planta, **manga** es la bolsa física entregada al maquinista y posteriormente pesada. El nombre técnico general puede continuar siendo `TipoContenedor`, pero la vista del piloto se presenta como **Tipos de manga** y filtra `clase=MANGA`.

El maestro local usa códigos correlativos `TMG-######`, baja lógica y cantidades físicas `Numeric(12,3)`. Sus valores se congelan al aprobar cada revisión de [[Perfil_Empaque]].

No contiene por sí solo la capacidad para una pieza específica. La capacidad en unidades y kg depende también del artículo o estado físico y se gobierna mediante [[Perfil_Empaque]].

## Atributos objetivo

| Campo | Regla |
|---|---|
| `id` | Identidad interna estable. |
| `codigo` | Código autogenerado, por ejemplo `TMG-000001`. |
| `nombre` | Nombre operativo visible. |
| `clase` | Para el piloto, constante `MANGA`. |
| `material`, `dimensiones` | Datos descriptivos configurables. |
| `tara_nominal_g` | Tara estándar no negativa. |
| `tolerancia_tara_g` | Desviación aceptada de la tara. |
| `peso_bruto_max_kg` | Límite físico o ergonómico. |
| `activo`, `version` | Baja lógica y control de concurrencia. |
| `created_at`, `updated_at` | Auditoría técnica. |

## Gobierno

- El CRUD del maestro forma parte de la configuración del piloto.
- Los valores físicos iniciales se levantarán durante la puesta en marcha; no bloquean el cierre del modelo funcional.
- Una manga planificada congela el tipo y sus valores relevantes. Editar el maestro no modifica mangas ya impresas.
- La tara puede sustituirse por una medición autorizada, conservando valor original, valor usado, actor y motivo.
- Desactivar un tipo impide usarlo en planes nuevos, pero no elimina su historia.
