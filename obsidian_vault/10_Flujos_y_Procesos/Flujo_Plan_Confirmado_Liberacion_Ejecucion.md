---
tipo: flujo
estado: objetivo-en-especificacion
fecha_creacion: 2026-07-31
fecha_actualizacion: 2026-07-31
tags: [flujo, uml, planificacion, orden-produccion, orden-fabricacion, orden-armado, orden-trabajo, pausa]
relaciones:
  - "[[Flujo_Creacion_Orden]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[2026-07-31_Pausa_Ejecucion_por_Prioridad]]"
---

# Secuencia: plan confirmado, liberación y ejecución

## Objetivo

Representar qué ocurre después de calcular la cobertura de una OP: aprobación
de la demanda, confirmación de metas, reservas de Kardex, creación de OF/OA,
liberación técnica, distribución mediante OT y pausa temporal por prioridad.

La secuencia parte de una OP seleccionada, pero conserva asignaciones N:M para
que una OF/OA pueda cubrir otras demandas compatibles en una evolución
posterior.

## Secuencia principal

```mermaid
sequenceDiagram
    actor P as Planificador
    participant S as SCM
    participant K as Kardex
    actor JP as Jefe de Producción
    actor JF as Jefe de Fabricación
    actor JE as Jefe de Armado
    actor SUP as Supervisor
    participant PL as Planta

    P->>S: Crear OP BORRADOR con líneas PT
    S->>S: Validar BOM/ruta y calcular cobertura preliminar
    S-->>P: Mostrar stock libre, faltantes y metas sugeridas
    opt Ajuste de adopción o decisión operativa
        P->>S: Confirmar meta objetivo con motivo
        S->>S: Crear nueva revisión de plan
    end

    JP->>S: Aprobar OP y confirmar plan
    S->>S: Revalidar BOM, ruta, Kardex y versión del plan

    alt Demanda cubierta con stock
        S->>K: Crear asignación a stock elegible
        S-->>P: OP sin OF/OA; cobertura satisfecha
    else Existe faltante
        S->>K: Reservar stock utilizado
        S->>S: Crear asignaciones OP-OF/OA
        S-->>P: Crear OF/OA BORRADOR

        JF->>S: Configurar OF: molde, máquina, ciclos y corridas
        JF->>S: Liberar OF

        opt La ruta requiere armado
            JE->>S: Validar BOM, componentes y salida de OA
            JE->>S: Liberar OA
        end

        SUP->>S: Crear OT con fecha, turno, máquina y responsable
        S->>S: Asignar porción del plan y planificar mangas
        S-->>PL: Emitir OT y etiquetas de prepesaje

        alt Cambio de prioridad
            SUP->>S: Pausar OT con motivo y orden prioritaria
            S->>K: Retener reservas por defecto
            S-->>PL: Resolver mangas abiertas antes de abandonar estación
            SUP->>S: Reanudar OT autorizada
            S->>S: Continuar desde saldo pendiente
        else Ejecución normal
            PL->>S: Confirmar producción, armado y mangas
        end
    end

    S->>S: Actualizar OF/OA, asignaciones y cobertura OP
```

## Reglas de lectura

1. Calcular cobertura no aprueba la OP ni mueve Kardex.
2. La aprobación de OP y confirmación del plan revalidan la versión de datos.
3. Una reserva no es consumo; el consumo ocurre durante la ejecución.
4. OF/OA pueden nacer con una sola asignación a la OP seleccionada.
5. La OT ejecuta una porción del objetivo de OF/OA y no modifica la meta global.
6. Una OP totalmente cubierta no genera OF/OA.
7. Una ruta de fabricación directa a PT no genera una OA ficticia.
8. Una OT pausada conserva los hechos, reservas y mangas ya confirmados.
9. La reanudación utiliza el saldo pendiente y no recrea efectos anteriores.
10. Una OF/OA compartida no se pausa por la suspensión de una sola asignación.

## Estados observables

```text
OP: BORRADOR -> APROBADA -> PLANIFICADA -> COMPLETADA
OF/OA: BORRADOR -> LIBERADA -> PROGRAMADA -> EN_EJECUCION -> CERRADA
OT: PLANIFICADA -> EMITIDA -> EN_CURSO -> PAUSADA -> EN_CURSO
    -> FINALIZADA -> CERRADA
```

`SUSPENDIDA` queda reservado para poner una OP completa en espera por decisión
del negocio. `PAUSADA` representa una detención temporal de ejecución por
prioridad.

## Variantes que debe cubrir la implementación

### Stock parcial

El stock cubre una parte de la demanda y OF/OA cubren únicamente el faltante.

### OF compartida

Una misma OF produce para dos OP compatibles mediante asignaciones separadas.

### Armado concurrente

Una OA se ejecuta mediante una OT de armado mientras continúa la OT de
fabricación de contexto. Sus avances y consumos permanecen separados.

### Pausa con reserva

La OT se pausa, la reserva permanece retenida y otra OP no puede utilizarla sin
un descompromiso autorizado.
