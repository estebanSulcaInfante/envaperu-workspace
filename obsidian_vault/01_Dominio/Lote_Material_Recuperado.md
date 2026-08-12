---
tipo: modelo_dominio
estado: propuesto
tags: [scm, material-recuperado, lote, genealogia, molienda]
relaciones:
  - "[[Orden_Molienda]]"
  - "[[Regla_Compatibilidad_Reproceso]]"
  - "[[MaterialSCM]]"
  - "[[Unidad_Logistica]]"
  - "[[US-010E_Molienda_y_Material_Recuperado_Trazable]]"
fecha_creacion: 2026-08-02
fecha_actualizacion: 2026-08-03
---

# Lote de Material Recuperado

Salida trazable de una [[Orden_Molienda]]. Representa material de segunda
producido internamente y no una devolución al stock de `PiezaColor`.

## Identidad congelada

- familia de materia prima;
- color o familia de color;
- color nominal objetivo/dominante y composición porcentual real de colores;
- proceso destino declarado;
- composición real por familia, proceso de origen y color;
- condición normal o mezcla excepcional;
- orden de molienda y revisión de reglas usadas;
- kg producidos, pérdidas y momento de cierre.

## Genealogía

La relación con los aportes es N:M y cuantificada. El lote permite recorrer
hacia ramales, rechazos de fabricación, merma recuperable de Armado y sus
unidades/lotes originales. Mezclar aportes no autoriza a atribuir todo el lote a
un único origen.

## Embalaje e inventario

La molienda puede producir bolsas de peso variable, cercanas operativamente a
30 kg. Cada bolsa se pesa realmente y referencia el lote; no se supone un peso
nominal fijo. El material solo queda disponible para reserva/consumo después
del cierre, recepción de Almacén y la política de liberación definida.
