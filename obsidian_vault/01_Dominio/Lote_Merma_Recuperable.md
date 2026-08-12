---
tipo: modelo_dominio
estado: propuesto
tags: [scm, merma-recuperable, lote, molienda, inventario, genealogia]
relaciones:
  - "[[Unidad_Logistica]]"
  - "[[Inventario_SCM]]"
  - "[[Orden_Molienda]]"
  - "[[Lote_Material_Recuperado]]"
  - "[[US-010E_Molienda_y_Material_Recuperado_Trazable]]"
fecha_creacion: 2026-08-02
fecha_actualizacion: 2026-08-03
---

# Lote de Merma Recuperable

Identidad material previa a la molienda. Agrupa merma compatible segregada que
todavía conserva su naturaleza de ramal, rechazo o `PiezaColor` dañada; no es
`PiezaColor` disponible ni material recuperado terminado.

## Clasificación congelada

- familia/material;
- proceso de origen;
- color o familia;
- condición;
- fuentes productivas y eventos de merma;
- fecha, responsable y ubicación de segregación.

## Bolsa e inventario

Una [[Unidad_Logistica]] con `content_lot_type=LOTE_MERMA_RECUPERABLE`
materializa una bolsa almacenada. Al cerrarla se registra bruto, tara y neto; la
recepción en la ubicación de merma crea su existencia en kg con disponibilidad
exclusiva `DISPONIBLE_MOLIENDA`.

No participa en cobertura de piezas, producto terminado ni material de segunda.
Solo una [[Orden_Molienda]] compatible puede reservarla y consumirla.

## Pesaje previo al molino

El peso antes de moler es una medición de consumo sobre la misma existencia:

```text
diferencia_custodia_kg =
    peso_pre_molino_kg - saldo_almacenado_seleccionado_kg
```

El pesaje no crea otra bolsa ni duplica Kardex. La diferencia se concilia según
una tolerancia configurable y ambos valores permanecen auditables.

La tolerancia inicial es `1.000 kg` de diferencia absoluta. Hasta ese valor la
conciliación es normal; por encima se genera alerta, se exige motivo y autoriza
el Jefe de Producción. Un débito que dejaría saldo negativo siempre se bloquea.
