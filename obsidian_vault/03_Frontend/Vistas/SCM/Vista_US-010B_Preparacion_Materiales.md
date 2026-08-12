---
tipo: vista-frontend
estado: implementado-local-pendiente-uat
fuente_datos: api-scm
tags: [frontend, scm, materiales, reserva, emision, premezcla, us-010b]
relaciones:
  - "[[US-010B_Reserva_Emision_Materiales_OP]]"
  - "[[US-010L_Material_Segunda_Reproceso_y_Mezcla_Preparada_Trazable]]"
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
  - "[[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]"
  - "[[Vista_US-010P_Planificacion_Demanda_OP]]"
  - "[[SCM_Frontend_Overview_US-010]]"
  - "[[Patron_Capacidades_API_y_Mocks]]"
fecha_creacion: 2026-07-15
fecha_actualizacion: 2026-08-08
---

# Vista US-010B — Preparación de Materiales

## Estado Actual

Vista transaccional conectada a la API SCM. Consulta corridas de OF y persiste
generación de requerimientos, reserva, emisión, devolución y premezcla. Los
fixtures se conservan únicamente para pruebas de componente.

> [!WARNING] No es todavía una estación de dosificación
> La vista no escucha una balanza de materiales ni captura bruto, tara, neto,
> dosis, iteraciones o incorporación física. La acción vigente consume todos los
> saldos emitidos disponibles y muestra una salida derivada. No debe usarse para
> validar preparación experimental. La evolución se define en
> [[US-010L_Material_Segunda_Reproceso_y_Mezcla_Preparada_Trazable|US-010L]].

El fixture actual comienza con una orden técnica ya preparada, ahora denominada
OF. La creación de OP de demanda, explosión de BOM y generación/liberación de
esa OF pertenecen a [[US-010P_Planificar_Demanda_ProductoTerminado_y_Generar_OP]]
y [[Vista_US-010P_Planificacion_Demanda_OP]].

## Implementación

| Elemento | Ubicación |
| :--- | :--- |
| Rutas | `/materiales/preparaciones` y `/materiales/preparaciones/:numeroOp`; `/ordenes/:numeroOp/materiales` queda como alias |
| Vista | `frontend/src/components/PreparacionMateriales.jsx` |
| Adaptador | `frontend/src/services/preparacionMateriales.js` |
| Fuente operativa | `GET /api/scm/v1/materiales-ejecucion` |
| Fixtures de prueba | `frontend/src/mocks/preparacionMateriales.js` |
| Pruebas | `frontend/src/tests/PreparacionMateriales.spec.jsx` |

## Estructura Visible

- selector de OF y corrida;
- resumen de receta congelada, cobertura de reserva y emisión;
- etapa `Plan`: cantidades planificadas, reservadas, emitidas, preparadas y enviadas a máquina;
- etapa `Reserva`: lotes internos, proveedor, estado del lote externo, ubicación MP, Calidad, disponibilidad y asignación;
- etapa `Emisión`: origen, cantidad, método de determinación, balanza cuando aplique, trabajador y devoluciones;
- etapa `Premezcla`: lote WIP a la salida de tolva y nivel de procedencia `EXACTA` o `CONJUNTO_CANDIDATOS`;
- etapa `Trazabilidad`: secuencia de eventos del lote de producción.

## Punto de Entrada Objetivo

1. US-010P crea una OP de demanda y propone una OF, o registra una OF excepcional justificada.
2. Producción completa su configuración técnica.
3. Un usuario autorizado ejecuta `Liberar y calcular materiales`.
4. US-010P libera la revisión y US-010B calcula requerimientos una sola vez; entonces abastecimiento cambia a `REQUERIDO`.
5. La acción `Preparar materiales` abre `/materiales/preparaciones/:numeroOp`.
6. US-010B propone lotes físicos y recién `Confirmar reserva` compromete sus cantidades.

Una OF `BORRADOR` o `PROGRAMADA` sin liberar debe mostrar el bloqueo y regresar a configuración; no puede comenzar una reserva.

## Capacidades

| Capacidad | Lectura actual | Escritura actual |
| :--- | :--- | :--- |
| Consultar preparación | API SCM | No aplica |
| Generar requerimientos | API SCM | `MATERIAL_REQUERIMIENTO_GENERAR` |
| Confirmar reserva | API SCM | `MATERIAL_RESERVAR` |
| Emitir material | API SCM | `MATERIAL_EMITIR` |
| Registrar devolución | API SCM | `MATERIAL_DEVOLVER` |
| Confirmar premezcla | API SCM | `MATERIAL_PREMEZCLA_CONFIRMAR` |

El patrón de presentación se define en [[Patron_Capacidades_API_y_Mocks]].

## Contrato Consumido de US-010A

La vista presupone que recepción ya entregó `LoteMaterial` con identidad interna, proveedor, lote externo informado/ausente/ilegible, modalidad de cantidad, Calidad, retención, ubicación y disponibilidad. Esos datos justifican una selección; la vista **no recibe ni libera materiales**.

Por eso, US-010A está contemplada como dependencia y frontera de datos, pero no como pantalla dentro de este mock. Ver [[Vista_US-010A_Recepcion_Materiales]].

## Contrato Consumido de US-010P

La vista requiere una OF `LIBERADA` con corrida, ciclos/salidas, receta
congelada y requerimientos absolutos. No calcula demanda de
`ProductoTerminado` ni decide qué OP/OF/OA deben existir.

La API rechaza la generación cuando la OF no se encuentra liberada/programada
para ejecución o cuando no existe una receta aprobada y resoluble.

## Cobertura Actual

Las pruebas de componente verifican:

- carga y navegación básica de la preparación;
- cálculo visible de colorante sobre la base virgen (`MAT-02`);
- genealogía de una premezcla (`MAT-29`);
- diálogo de devolución con cantidad y motivo;
- transformación de premezcla con advertencia irreversible y genealogía.

La siguiente iteración debe cubrir `MAT-31` y mostrar una advertencia explícita cuando la salida de tolva solo conserve un `CONJUNTO_CANDIDATOS`; no debe renderizar cantidades o porcentajes por proveedor.

## Próximo Cambio de Madurez

Ejecutar [[UAT_US-010B_Reserva_Emision_Premezcla]] con usuarios de Producción y
Almacén. La vista no está autorizada todavía para despliegue y no toca la base
de datos desplegada.
