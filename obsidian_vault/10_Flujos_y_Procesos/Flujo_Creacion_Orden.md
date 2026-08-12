---
tipo: flujo
estado: objetivo-en-especificacion
tags: [flujo, planificacion, orden-produccion, orden-fabricacion, orden-armado]
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-07-29
relaciones:
  - "[[Orden_Produccion]]"
  - "[[Orden_Fabricacion]]"
  - "[[Orden_Armado]]"
  - "[[Registro_Diario]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-07-31_Generacion_Desde_Una_OP_y_Cobertura_NM]]"
  - "[[Flujo_Plan_Confirmado_Liberacion_Ejecucion]]"
---

# Flujo: de demanda a ejecución

## Flujo normal

```mermaid
sequenceDiagram
    actor P as Planificación
    participant S as SCM
    participant JP as Jefe de Producción
    participant PL as Planta

    P->>S: Crear OP con líneas de ProductoTerminado
    S->>S: Congelar BOM/ruta y calcular cobertura
    S->>P: Mostrar stock, faltantes, propuestas y excedentes
    P->>S: Confirmar asignaciones y propuestas OF/OA
    JP->>S: Liberar OF/OA
    S->>S: Calcular requerimientos y plan agregado de mangas
    PL->>S: Programar OT desde corrida de OF
    S->>PL: Emitir OT y mangas prepesaje
    PL->>S: Pausar/reanudar OT por cambio de prioridad (si aplica)
    PL->>S: Confirmar ejecución, armado y pesajes
    S->>S: Actualizar OF/OA y cobertura de OP
```

Una pausa por prioridad se aplica a la OT, no a la OP. La OF/OA solo se
proyecta como pausada cuando todas sus OT o corridas ejecutables pendientes
están pausadas. La pausa conserva hechos, reservas y mangas; liberar una
reserva exige una acción autorizada y una nueva revisión de cobertura.

## Entradas de la OP

1. Una o más líneas de `ProductoTerminado`.
2. Cantidad entera por línea.
3. Fecha de necesidad.
4. Prioridad.
5. Origen y referencia.

La OP no solicita molde, máquina, ciclo o receta.

## Configuración de OF

1. Molde y snapshot de composición.
2. Operación/ruta congelada.
3. Máquina prevista.
4. Parámetros técnicos.
5. Corridas por color con ciclos enteros.
6. Salidas, kg estándar y excedentes.

La OF puede proponerse desde varias líneas de OP o crearse excepcionalmente para
stock, muestra, reproceso o prueba con motivo y autorización.

## Reglas

- Una OP puede generar cero, una o varias OF/OA.
- Una OF/OA puede cubrir varias OP mediante asignaciones cuantificadas.
- Liberar OF/OA congela la configuración ejecutable.
- La OT referencia una OF y corrida exactas.
- El formulario legacy de creación técnica pasa a `OF excepcional`.
- La impresión técnica anterior de OP pasa a ser impresión de OF.
- Los pesajes y documentos legacy conservan sus identificadores originales.
