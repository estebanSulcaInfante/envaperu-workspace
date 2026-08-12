---
tipo: modelo_bd
tabla: scm_presentacion_comercial
estado: activo
tags: [dominio, scm, producto, presentacion, demanda]
relaciones:
  - "[[ProductoTerminado]]"
  - "[[Orden_Produccion]]"
  - "[[Perfil_Empaque]]"
fecha_creacion: 2026-08-06
fecha_actualizacion: 2026-08-06
---

# Presentación comercial

Conversión normalizada entre la forma en que se solicita o vende un
[[ProductoTerminado]] y su unidad base SCM `UN`. No es una BOM, un WIP ni un
contenedor productivo.

Ejemplo:

```text
PT-000001 Alcancía Pablo Grande
Presentación PRE-000002 Pack x6
1 Pack x6 = 6 UN
Demanda 10 Pack x6 = 60 UN para planificación
```

## Reglas

- Cada PT recibe automáticamente la presentación `Unidad = 1 UN`.
- Puede tener varias presentaciones activas, pero solo una predeterminada.
- `codigo` es correlativo, estable e inmutable.
- `unidades_base` es un entero positivo.
- `codigo_barra` es opcional y único cuando se informa.
- La presentación predeterminada no puede desactivarse hasta asignar otra.
- No existe eliminación directa; la baja es lógica.
- Una línea de OP congela código, nombre y unidades por presentación.
- Cobertura, fabricación, armado e inventario siempre operan en `UN`.

## Fronteras

- [[ProductoTerminado]] y BOM responden qué se fabrica.
- Presentación comercial responde cómo se expresa la demanda o venta.
- [[Perfil_Empaque]] y la regla de empaque responden cómo se acomoda en manga.
