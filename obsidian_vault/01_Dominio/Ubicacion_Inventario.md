---
tipo: modelo_objetivo
estado: implementado-parcial-piloto-local
tags: [dominio, scm, inventario, almacen, ubicacion, staging, trazabilidad]
relaciones:
  - "[[Inventario_SCM]]"
  - "[[Unidad_Logistica]]"
  - "[[Articulo_SCM]]"
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
  - "[[US-013A_Almacenes_Ubicaciones_y_Alcance_por_Trabajador]]"
  - "[[Almacen_SCM]]"
  - "[[Transferencia_Inventario]]"
fecha_creacion: 2026-07-30
fecha_actualizacion: 2026-08-11
---

# Ubicación de Inventario

Identidad normalizada de un lugar físico o punto logístico donde una existencia
puede recibirse, conservarse, prepararse, transferirse, bloquearse o consumirse.
Reemplaza textos libres como `ALMACEN_PRINCIPAL`, `TRANSITO` o `ZONA_ARMADO`.

## Tipos iniciales

| Tipo | Uso |
|---|---|
| `ALMACEN` | Ámbito físico responsable de existencias |
| `ZONA` | Sector dentro de un almacén o área productiva |
| `POSICION` | Dirección concreta de almacenamiento |
| `STAGING` | Espera temporal antes de consumo, recepción o despacho |
| `CALIDAD` | Área física de cuarentena o inspección |
| `TRANSITO` | Punto lógico temporal entre dos custodios |

`TRANSITO` no finge una posición física exacta: conserva origen, destino,
despachador y receptor pendientes.

## Jerarquía

```text
Planta
└─ Almacén / área
   └─ Zona
      └─ Posición
```

Una ubicación posee código estable, nombre visible, tipo, padre opcional,
estado activo e inventarios compatibles. Desactivarla no altera movimientos
históricos.

## Compatibilidad

La compatibilidad se configura por clase de artículo y propósito, por ejemplo:

- materias primas y recuperados;
- piezas y WIP;
- producto terminado;
- cuarentena;
- staging de Fabricación;
- staging de Armado.

La compatibilidad no se infiere por el texto del nombre. Un movimiento hacia
una ubicación incompatible se rechaza antes de cambiar saldo o custodia.

## Invariantes

1. Todo movimiento confirmado referencia origen y/o destino normalizados.
2. Calidad y ubicación son dimensiones independientes.
3. Una unidad en tránsito conserva origen, destino y custodios.
4. Una ubicación inactiva sigue visible históricamente, pero no recibe nuevos
   movimientos.
5. Una unidad logística tiene una sola ubicación actual en la proyección.
6. Las correcciones de ubicación usan movimientos compensatorios.
7. Las posiciones reales y permisos por área son configuración de planta, no
   constantes en el código.

## Pendiente operativo

El staging piloto de Armado se denomina `MESA_ARMADO` y está dentro de la
fábrica. Antes de desplegar deben registrarse su código definitivo, responsable
y relación con el Almacén de Piezas; las posiciones internas del almacén pueden
incorporarse progresivamente.

Los puntos de ingreso piloto se denominan:

- `RECEPCION_PIEZAS_WIP`;
- `RECEPCION_PT`.

Ambos son ubicaciones normalizadas distintas del inventario disponible: una
manga recibida permanece allí con Calidad `PENDIENTE` hasta su decisión y
ubicación posterior.

El primer incremento implementa compatibilidad mediante una lista explícita
de clases de `ArticuloSCM`: piezas/WIP para `RECEPCION_PIEZAS_WIP` y producto
terminado para `RECEPCION_PT`. Una lista vacía representa una ubicación general.

## Evolución propuesta US-013

TS-018A separa [[Almacen_SCM|Almacén]] de ubicación. Almacén será la frontera
de responsabilidad y seguridad; la ubicación seguirá representando recepción,
cuarentena, zona, posición, staging, punto productivo o tránsito.

`TRANSITO_PRODUCCION` y `TRANSITO_ALMACEN` se preservan durante expand como
proyecciones técnicas. La autoridad futura será [[Transferencia_Inventario]],
que conserva origen, destino, custodio y recepción pendiente sin presentar
tránsito como stock libre de un almacén.
