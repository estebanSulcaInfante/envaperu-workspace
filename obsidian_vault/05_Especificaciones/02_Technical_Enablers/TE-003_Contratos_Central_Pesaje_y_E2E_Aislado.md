---
tipo: technical-enabler
estado: implementado
tags: [contract-testing, json-schema, e2e, sync, pesaje, integracion]
relaciones:
  - "[[TE-001_Infraestructura_TDD_Reproducible]]"
  - "[[TE-002_CI_Coordinado_Multirepositorio]]"
  - "[[TS-TE-003_Contratos_Central_Pesaje_y_E2E_Aislado]]"
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
fecha_creacion: 2026-07-13
fecha_implementacion: 2026-07-13
---

# TE-003: Contratos Central-Pesaje y E2E Aislado

## 1. Problema

`SyncService` del módulo de pesaje y `POST /api/sync/pesajes` del backend central comparten un payload implícito. Sus pruebas estaban separadas y el único E2E requería dos servidores manuales, puertos fijos y datos persistentes. Un cambio unilateral podía romper la operación offline sin una señal reproducible.

El contrato actual además tiene deudas conocidas: identifica por `local_id` numérico, el backend central no conserva identidad global de origen y un reintento puede duplicar `ControlPeso`. Por ello no debe presentarse como solución de trazabilidad de US-010.

## 2. Capacidad Habilitada

**Como** equipo que mantiene central y estaciones de pesaje  
**Queremos** caracterizar y verificar automáticamente la integración existente  
**Para** evitar drift mientras diseñamos su reemplazo idempotente y trazable.

## 3. Clasificación

TE-003 posee la Tech Spec [[TS-TE-003_Contratos_Central_Pesaje_y_E2E_Aislado|TS-TE-003]] porque establece un artefacto de compatibilidad y una prueba entre procesos de repositorios diferentes. No cambia el contrato runtime; formaliza el comportamiento existente como `legacy-v1`.

## 4. Alcance

- JSON Schema Draft 2020-12 para request y respuesta exitosa/parcial;
- ejemplos canónicos en el workspace;
- copias idénticas en proveedor y consumidor para CI independiente;
- comprobación SHA-256 contra drift entre copias;
- prueba de proveedor con Flask test client;
- pruebas de emisión y consumo en el módulo de pesaje;
- E2E por HTTP real con procesos, puertos y SQLite aislados;
- ejecución en el CI coordinado del workspace.

## 5. Fuera de Alcance

- agregar UUID global, dispositivo de origen o clave idempotente;
- corregir duplicidad de reintentos;
- introducir `/api/v2`;
- cambiar estados HTTP o semántica de errores;
- validar el payload en runtime con JSON Schema;
- cubrir balanza, impresora, QR físico o UI;
- resolver decisiones funcionales de recepción, calidad o lotes.

## 6. Criterios de Aceptación

### TE-003-01: Contrato canónico

Request y respuesta `legacy-v1` poseen esquemas y ejemplos versionados, y las copias de ambos repositorios son byte a byte equivalentes al canónico.

### TE-003-02: Consumidor protegido

La serialización real de `Pesaje` valida contra el request y el consumidor interpreta una respuesta válida marcando solo los IDs confirmados.

### TE-003-03: Proveedor protegido

El endpoint central acepta el ejemplo válido, devuelve una respuesta conforme y crea un `ControlPeso`.

### TE-003-04: E2E aislado

Un runner levanta ambos procesos en puertos libres, crea un pesaje local, dispara sincronización, comprueba acuse local y total central, y elimina las bases temporales al terminar.

### TE-003-05: Frontera legacy explícita

Documentación, ruta de archivos y títulos indican que `legacy-v1` es caracterización transitoria y no la solución idempotente de US-010.

### TE-003-06: Automatización

Las pruebas de contrato forman parte de las suites de componente y la igualdad de copias más E2E forman parte del workflow del workspace.

## 7. Estrategia TDD

1. RED: intentar validar el payload real sin esquema ni dependencia declarada.
2. GREEN: introducir el esquema mínimo que describe exactamente el payload actual.
3. RED: ejecutar consumidor y proveedor contra copias independientes.
4. GREEN: distribuir el contrato y comprobar hashes.
5. RED: ejecutar el recorrido sin servidores preparados manualmente.
6. GREEN: crear servidores de soporte y bases efímeras.
7. REFACTOR: encapsular bootstrap, espera, diagnóstico y cleanup en runners raíz.

## 8. Definición de Terminado

- [x] Existe `TS-TE-003`.
- [x] Existe contrato canónico `legacy-v1`.
- [x] Proveedor y consumidor poseen copias verificables.
- [x] Existen pruebas de contrato en ambos componentes.
- [x] Existe runner de igualdad de contrato.
- [x] Existe E2E HTTP aislado.
- [x] Todas las suites y el E2E están verdes después de integrar los cambios.
- [x] Resultados finales están registrados.

## 9. Deuda Preservada Deliberadamente

Que estas pruebas estén verdes solo significa que ambos lados hablan el mismo contrato existente. No demuestra idempotencia, unicidad global, no repudio, reanudación segura ni trazabilidad ISO. Esas garantías deberán nacer en la historia hija correspondiente de US-010 y probablemente producir un contrato versionado nuevo.

## 10. Resultado de Implementación

| Verificación | Resultado |
|---|---|
| Contrato proveedor | `1 passed` |
| Contrato consumidor | `2 passed` |
| Igualdad de canónico y copias | SHA-256 coincidente |
| E2E HTTP aislado | `12.5 kg` recibido por central y acuse local confirmado |
| Backend completo | `75 passed`, `1 skipped`, `3 deselected` |
| Frontend completo | `2 passed` |
| Pesaje completo | `10 passed` |

El primer E2E detectó que los scripts bajo `tests/support` no heredaban la raíz del componente. El runner ahora declara un `PYTHONPATH` aislado por proceso y conserva diagnóstico de ambos servidores solo cuando ocurre un fallo.
