---
tipo: vista-frontend
estado: mock
fuente_datos: mock
tags: [frontend, scm, materiales, reserva, emision, premezcla, us-010b]
relaciones:
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[Vista_US-010P_Planificacion_Demanda_OP]]"
  - "[[SCM_Frontend_Overview_US-010]]"
  - "[[Patron_Capacidades_API_y_Mocks]]"
fecha_creacion: 2026-07-15
fecha_actualizacion: 2026-07-21
---

# Vista US-010B — Preparación de Materiales

## Estado Actual

Mock funcional de lectura basado en el contrato de [[US-010B_Reserva_Emision_Materiales_OP]]. Permite recorrer el estado futuro del flujo; no persiste reserva, emisión, devolución ni premezcla.

El fixture actual comienza con una OP ya preparada. La creación de demanda, la explosión de BOM y la generación/liberación de esa OP no estaban representadas; esa laguna queda delimitada por [[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]] y [[Vista_US-010P_Planificacion_Demanda_OP]].

## Implementación

| Elemento | Ubicación |
| :--- | :--- |
| Rutas | `/materiales/preparaciones` y `/materiales/preparaciones/:numeroOp`; `/ordenes/:numeroOp/materiales` queda como alias |
| Vista | `frontend/src/components/PreparacionMateriales.jsx` |
| Adaptador | `frontend/src/services/preparacionMateriales.js` |
| Fixtures | `frontend/src/mocks/preparacionMateriales.js` |
| Pruebas | `frontend/src/tests/PreparacionMateriales.spec.jsx` |

## Estructura Visible

- selector de OP y lote de producción;
- resumen de receta congelada, cobertura de reserva y emisión;
- etapa `Plan`: cantidades planificadas, reservadas, emitidas, preparadas y enviadas a máquina;
- etapa `Reserva`: lotes internos, proveedor, estado del lote externo, ubicación MP, Calidad, disponibilidad y asignación;
- etapa `Emisión`: origen, cantidad, método de determinación, balanza cuando aplique, trabajador y devoluciones;
- etapa `Premezcla`: lote WIP a la salida de tolva y nivel de procedencia `EXACTA` o `CONJUNTO_CANDIDATOS`;
- etapa `Trazabilidad`: secuencia de eventos del lote de producción.

## Punto de Entrada Objetivo

1. US-010P crea una OP en borrador desde una demanda o registra una OP manual justificada.
2. Producción completa su configuración técnica.
3. Un usuario autorizado ejecuta `Liberar y calcular materiales`.
4. US-010P libera la revisión y US-010B calcula requerimientos una sola vez; entonces abastecimiento cambia a `REQUERIDO`.
5. La acción `Preparar materiales` abre `/materiales/preparaciones/:numeroOp`.
6. US-010B propone lotes físicos y recién `Confirmar reserva` compromete sus cantidades.

Una OP `BORRADOR` o `PLANIFICADA` debe mostrar el bloqueo y regresar a configuración; no puede comenzar una reserva.

## Capacidades

| Capacidad | Lectura actual | Escritura actual |
| :--- | :--- | :--- |
| Consultar preparación | `MOCK` | No aplica |
| Confirmar reserva | Datos visibles | Bloqueada con candado: API pendiente |
| Emitir material | Datos visibles | Bloqueada con candado: API pendiente |
| Registrar devolución | Datos visibles | Bloqueada con candado: API pendiente |
| Confirmar premezcla | Datos visibles | Bloqueada con candado: API pendiente |

El patrón de presentación se define en [[Patron_Capacidades_API_y_Mocks]].

## Contrato Consumido de US-010A

La vista presupone que recepción ya entregó `LoteMaterial` con identidad interna, proveedor, lote externo informado/ausente/ilegible, modalidad de cantidad, Calidad, retención, ubicación y disponibilidad. Esos datos justifican una selección; la vista **no recibe ni libera materiales**.

Por eso, US-010A está contemplada como dependencia y frontera de datos, pero no como pantalla dentro de este mock. Ver [[Vista_US-010A_Recepcion_Materiales]].

## Contrato Consumido de US-010P

La vista requiere una OP `LIBERADA` con lote de producción, ciclos/salidas, receta congelada y requerimientos absolutos. No calcula la demanda de `ProductoTerminado` ni decide qué OP deben existir.

El mock mantiene temporalmente ese contrato como fixture. La integración futura debe impedir el acceso mutador cuando la OP no esté liberada o cuando los requerimientos no correspondan a su revisión vigente.

## Cobertura Actual

Las pruebas de componente verifican:

- carga y navegación básica de la preparación;
- cálculo visible de colorante sobre la base virgen (`MAT-02`);
- genealogía de una premezcla (`MAT-29`);
- comandos de inventario deshabilitados mientras su API no esté disponible.

La siguiente iteración debe cubrir `MAT-31` y mostrar una advertencia explícita cuando la salida de tolva solo conserve un `CONJUNTO_CANDIDATOS`; no debe renderizar cantidades o porcentajes por proveedor.

## Próximo Cambio de Madurez

La vista pasa de `mock` a `api-parcial` cuando el adaptador pueda consultar contratos reales y cada comando integrado cubra autorización, validación de estado, idempotencia, errores de negocio y pruebas de integración. No es necesario esperar ese momento para continuar el diseño de US-010A.
