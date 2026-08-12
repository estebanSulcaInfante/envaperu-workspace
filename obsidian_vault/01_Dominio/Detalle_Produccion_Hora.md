---
tipo: modelo_bd
tabla: detalle_produccion_hora
estado: activo
tags: [dominio, detalle, hora, seguimiento]
relaciones_padre:
  - "[[Registro_Diario]]"
relaciones_objetivo:
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
  - "[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]]"
fecha_creacion: 2026-04-21
fecha_actualizacion: 2026-08-01
---

# Detalle Producción Hora (Tabla Interna)

Cada [[Registro_Diario]] tiene N filas de detalle, una por cada hora trabajada. Permite el seguimiento hora-a-hora.

En el modelo objetivo esta tabla evoluciona conceptualmente a
`CorteHorarioOT`. El corte observa el proceso; no sustituye el cierre de manga,
el pesaje final ni el nacimiento de Kardex. Véase
[[2026-08-01_Corte_Horario_sin_Pesaje_de_Manga_Abierta]].

## Campos de la Tabla

| Atributo | Origen | Descripción |
| :--- | :--- | :--- |
| **Hora** | Auto | Franja horaria (ej. "07:00 - 08:00"). |
| **trabajador_id** | Input | FK al Catálogo de Trabajadores. |
| **maquinista_snapshot** | Snapshot | Nombre del operador (histórico/congelado) para trazabilidad (TS-009). |
| **Color** | Input | Color producido (puede cambiar por hora). |
| **Lectura contador** | Input preferido | Valor acumulado observado en el contador de máquina. |
| **Coladas Realizadas** | Derivado / transición | Diferencia entre lecturas acumuladas válidas; el input manual legacy conserva su fuente. |
| **Observación** | Input | Notas (parada, cambio de molde, etc.). |
| **Cantidad Piezas** | Calculado legacy | `coladas_realizadas × cavidades`; es teórica hasta confirmar buenas/rechazadas por salida. |
| **Kg Producidos** | Calculado legacy | `(coladas_realizadas × peso_tiro_gr) / 1000`; incluye ramal y no equivale necesariamente a kg buenos ni kg físicos embolsados. |
| **Conteo provisional** | Input opcional | Estimación de piezas en una manga abierta; nunca acredita producción ni Kardex. |
| **Estado de máquina** | Input | Operando, parada, cambio u otro estado gobernado. |
| **Muestra de proceso** | Evento relacionado | Evidencia de la muestra horaria; tomarla no implica conformidad. |

## Proyección objetivo en tiempo real

US-010C conserva eventos/intervalos de ciclos y calcula unidades por cada salida del snapshot multipieza. US-010F registra por separado los conjuntos armados durante la misma franja y sus componentes previos.

Una fila horaria puede mostrar simultáneamente:

- ciclos y piezas buenas de la OT actual;
- kg estándar por `LoteSalidaPiezaColor` de la OT;
- unidades prearmadas provisionales abiertas y armadas confirmadas en contexto, como métricas distintas;
- kg físicos embolsados por US-010D;
- componentes anteriores incorporados y desviación.

Las mangas cerradas y pesadas durante la franja se agregan por referencia a sus
eventos finales; no se copian ni se vuelven a sumar. Una manga abierta no se
pesa en el piloto. El conteo provisional se reemplaza visualmente por la
cantidad confirmada al cierre, conservando la diferencia para auditoría.

El prearmado no incrementa `coladas_realizadas`. El peso de asas anteriores tampoco se agrega a los kg de salida del molde actual.

## Relaciones
- **Padre:** [[Registro_Diario]] (N:1)
