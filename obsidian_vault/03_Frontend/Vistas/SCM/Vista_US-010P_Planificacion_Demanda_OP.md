---
tipo: vista-frontend
estado: mock
fuente_datos: mock
tags: [frontend, scm, planificacion, demanda, producto-terminado, pieza-color, orden-produccion, us-010p]
relaciones:
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[SCM_Frontend_Overview_US-010]]"
  - "[[Patron_Capacidades_API_y_Mocks]]"
fecha_creacion: 2026-07-15
---

# Vista US-010P — Planificación de Demanda y OP

## Estado Actual

Existe un mock navegable que separa la demanda de `ProductoTerminado` de la configuración técnica de las OP. El formulario anterior permanece como superficie excepcional bajo el nombre `Nueva OP manual`.

La vista convierte cantidades deseadas de `ProductoTerminado` en cobertura, faltantes de `PiezaColor`, propuestas por molde/color y OP liberables. Los cálculos se ejecutan mediante funciones puras sobre fixtures; las escrituras continúan bloqueadas mientras no exista API.

## Rutas Objetivo

| Ruta | Responsabilidad | Estado |
| :--- | :--- | :--- |
| `/planificacion` | Bandeja de solicitudes y cobertura. | Mock navegable. |
| `/planificacion/:solicitudId` | Consultar demanda, cobertura, propuestas, configuración y liberación. | Mock navegable. |
| `/planificacion/nueva` | Crear demanda de `ProductoTerminado`. | Pendiente de API; el comando está bloqueado. |
| `/planificacion/:solicitudId/editar` | Editar un borrador o crear una revisión. | Pendiente de API y reglas de revisión. |
| `/ordenes/:numeroOp/configuracion` | Configuración técnica prellenada de una OP. | Representada como etapa de `/planificacion/:solicitudId`. |
| `/materiales/preparaciones/:numeroOp` | Entrada canónica a US-010B después de liberar y generar requerimientos. | Disponible para el fixture liberado. |

Las rutas son parte del diseño funcional; la Tech Spec definirá sus contratos y la implementación podrá conservar aliases de compatibilidad.

## Navegación Principal

El menú incorpora `Planificación` como entrada normal. La creación directa pasa a la acción secundaria `OP excepcional` dentro del listado de producción; la exigencia de propósito y motivo queda pendiente de su refactor específico.

```text
Planificación
  -> Nueva demanda
  -> Cobertura
  -> Propuestas de OP
  -> Configuración técnica
  -> Liberar y calcular materiales
  -> Preparar materiales (US-010B)
```

## Asistente

### 1. Demanda

- origen y referencia;
- fecha requerida y prioridad;
- una o más líneas de `ProductoTerminado`;
- cantidad entera por línea;
- validación de BOM activa.

### 2. Cobertura

- cantidad solicitada y cantidad de PT propuesta desde stock;
- cantidad restante por armar;
- BOM explotada por `PiezaColor`;
- stock no comprometido;
- suministro liberado no comprometido;
- faltante neto y origen de cada cifra;
- estado de la fuente de inventario; desconocido nunca se presenta como cero.

La cobertura de PT debe mostrarse como decisión; no se resta en segundo plano.

### 3. Propuestas de OP

- molde seleccionado y alternativas compatibles;
- lotes separados por `ColorProduccion`;
- ciclos enteros;
- salidas por `PiezaColor`;
- kg netos derivados;
- contingencia, excedentes técnicos y coproductos separados;
- demandas cubiertas;
- bloqueos de catálogo.

### 4. Configuración Técnica

Reformula el formulario existente y lo abre prellenado. Permite revisar:

- molde y snapshot;
- secuencia de colores/lotes;
- ciclos y salidas derivadas;
- receta/revisión;
- máquina prevista;
- advertencias que impiden liberar.

No permite crear colores, materiales o pigmentos maestros mediante texto libre.

### 5. Revisión y Liberación

- resumen de demanda cubierta;
- OP que se crearán o liberarán;
- contingencia y excedentes separados;
- requerimientos de materiales que se calcularán;
- bloqueos y autorizaciones;
- comando `Liberar y calcular materiales`.

La liberación seguida de un cálculo de requerimientos exitoso habilita `Preparar materiales`. Si el cálculo falla, la OP permanece liberada y se ofrece un reintento idempotente. `Confirmar reserva` sigue siendo un comando distinto dentro de US-010B.

## Dataset del Primer Mock

El primer fixture debe reutilizar `SP-00041` de US-010P:

```text
1,000 SET-REGADERA-ROJO
BOM: cuerpo rojo x1 + tapa roja x1
Stock: cuerpo 100, tapa 80
Molde: 1 cuerpo + 1 tapa por ciclo
Resultado: 920 ciclos, 920 de cada pieza y 20 cuerpos excedentes
Kg netos: 138.000 kg
Contingencia: 0
```

El corte implementado incluye además:

- una demanda completamente cubierta que no genera OP;
- un componente sin molde compatible;
- una fuente de inventario no disponible, sin convertir lo desconocido en cero;
- una OP liberada que habilita el enlace hacia US-010B.

Las solicitudes que requieren varias OP, la consolidación N:M y la validación de propósito/motivo de una OP manual permanecen como fixtures de una siguiente iteración.

## Estados Visibles

### Solicitud

`BORRADOR`, `CALCULADA`, `COBERTURA_NO_CALCULABLE`, `CONFIRMADA`, `EN_COBERTURA`, `CUBIERTA`, `CANCELADA`.

### OP

`BORRADOR`, `PLANIFICADA`, `LIBERADA`, `EN_EJECUCION`, `COMPLETADA`, `CANCELADA`.

### Abastecimiento

`SIN_CALCULAR`, `REQUERIDO`, `RESERVA_PARCIAL`, `RESERVADO`, `EMISION_PARCIAL`, `EMITIDO`.

OP y abastecimiento se presentan en columnas o indicadores separados.

## Capacidades Durante el Mock

| Capacidad | Lectura mock | Escritura sin API |
| :--- | :--- | :--- |
| Consultar demanda y cobertura | Disponible | No aplica |
| Cambiar líneas de demanda | Puede recalcular localmente solo como simulación identificada | No persistir |
| Confirmar plan | Resultado futuro visible | Candado: API pendiente |
| Crear OP desde propuesta | Resultado futuro visible | Candado: API pendiente |
| Liberar y calcular materiales | Impacto visible | Candado: API pendiente |
| Abrir preparación de materiales | Disponible para fixture ya liberado | Solo lectura mock |

Los controles bloqueados siguen [[Patron_Capacidades_API_y_Mocks]] y no muestran éxito ficticio.

## Escenarios Representados

- `PLN-01`: explosión de BOM;
- `PLN-02`: cobertura total sin OP;
- `PLN-03`: ciclos y excedente multipieza;
- `PLN-08`: ausencia de molde;
- `PLN-10`: ciclos enteros;
- `PLN-12`: borrador sin reserva;
- `PLN-13`: entrega visible hacia US-010B mediante una OP ya liberada;
- `PLN-17`: inventario desconocido no equivale a cero;
- `PLN-18`: contingencia visible.

`PLN-04`, `PLN-05`, `PLN-06`, `PLN-07`, `PLN-09`, `PLN-11`, `PLN-14`, `PLN-15` y `PLN-16` completo siguen pendientes de fixtures o contratos persistentes.

## Lagunas que la Vista No Decide

- roles que confirman o liberan;
- política automática de stock de PT;
- estados elegibles de stock de `PiezaColor`;
- selección entre moldes alternativos;
- reglas de consolidación por fecha y prioridad;
- tratamiento de una OP liberada como suministro entrante;
- política y autorización de contingencia de producción;
- fuente autoritativa de disponibilidad durante la migración de inventarios.

Estas decisiones se muestran como supuestos del fixture y deben permanecer fuera de la lógica irreversible del mock.

## Implementación del Mock

- Componente principal: `frontend/src/components/PlanificacionProduccion.jsx`.
- Cálculos puros: `frontend/src/services/planificacionProduccion.js`.
- Dataset explícito: `frontend/src/mocks/planificacionProduccion.js`.
- Pruebas de interfaz y dominio observable: `frontend/src/tests/PlanificacionProduccion.spec.jsx`.
- Navegación: `/planificacion`, `/planificacion/:solicitudId` y enlace real a `/materiales/preparaciones/OP-B-TEST-001`.
- Los comandos `Nueva demanda`, `Confirmar plan y crear OP`, `Guardar configuración` y `Liberar y calcular materiales` usan el patrón de candado/API pendiente.
- La reserva física no comienza en esta vista; pertenece a US-010B después de disponer de una OP liberada.

El mock fue verificado en escritorio y móvil. En móvil el asistente se presenta vertical y las tablas desplazan su contenido dentro de su contenedor sin provocar desbordamiento horizontal de la página.

## Próximo Cambio de Madurez

La ficha pasa a `api-parcial` cuando consultar demanda, confirmar plan o liberar OP use contratos reales con autorización, idempotencia y errores de negocio. La madurez de esta vista no implica que la US completa esté terminada: siguen pendientes los contratos, decisiones de negocio y escenarios persistentes descritos en la historia.
