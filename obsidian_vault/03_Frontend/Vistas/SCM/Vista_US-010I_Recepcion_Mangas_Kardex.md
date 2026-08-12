---
tipo: frontend-view
estado: implementada-local-pendiente-uat
tags: [frontend, scm, almacen, qr, kardex, calidad, us-010i]
relaciones:
  - "[[US-010I_Ingreso_Almacen_Mangas_y_Nacimiento_Kardex]]"
  - "[[TS-010I_Recepcion_Mangas_y_Nacimiento_Kardex]]"
  - "[[UAT_TS-010I_Recepcion_Mangas_Kardex]]"
fecha_creacion: 2026-08-03
fecha_actualizacion: 2026-08-03
---

# Vista US-010I: Recepción de Mangas y Kardex

## Ruta

`/produccion/recepcion-mangas`

## Experiencia por actor

| Actor | Vista inicial | Acciones |
|---|---|---|
| Almacén / Recepción | `Recibir` | Escanear QR, abrir sesión opcional, verificar la manga, elegir ubicación compatible, aceptar o rechazar custodia |
| Calidad | `Custodia y Calidad` | Consultar existencia física y decidir `LIBERADA`, `BLOQUEADA` o `RECHAZADA` |
| Jefe de Producción / Auditoría | `Custodia y Calidad` | Consulta según capacidades; no recibe ni decide Calidad por defecto |

La identidad elegida en el perfil UAT solo simula una sesión local. La API
valida cada capacidad y no confía en ocultar botones como control de seguridad.

## Reglas de UX

1. El foco principal de Almacén es el campo de QR; también puede usar el código visible mediante una capacidad separada.
2. Antes de confirmar se muestran artículo, OT, fecha productiva, cantidad y pesos como datos de solo lectura.
3. La recepción exige tres comprobaciones físicas explícitas y una ubicación compatible.
4. La confirmación explica que nace existencia física, pero no stock disponible.
5. Calidad trabaja en una pestaña separada y sus decisiones no cambian el peso ni la cantidad recibida.
6. Los reintentos no duplican Kardex; los errores se muestran en lenguaje operativo.

## Estado validado el 2026-08-03

- escritorio: navegación y jerarquía visual correctas para Almacén y Calidad;
- móvil: formulario usable y navegaciones horizontales contenidas;
- QR inexistente: feedback visible `No existe una manga con ese código`;
- vacíos: mensajes específicos para pendientes, custodia y rechazos;
- build y pruebas de navegación aprobadas.

La prueba con una manga física real se ejecuta mediante
[[UAT_TS-010I_Recepcion_Mangas_Kardex]].
