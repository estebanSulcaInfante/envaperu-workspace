---
tipo: acta-uat
estado: pendiente-de-ejecucion
uat: "[[UAT_US-010K_Modulo_Pesaje_Piloto_Kg]]"
spec_phase: approved
delivery_state: review
functional_validation: untested
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha_preparacion: 2026-09-02
---

# Acta lista para completar — UAT de Pesaje

No contiene aprobaciones. Copiar esta acta con RUN único al ejecutar para
conservar cada intento; no sobrescribir resultados anteriores.
Guion y criterios: [[UAT_US-010K_Modulo_Pesaje_Piloto_Kg]].

## Preflight

| Dato | Completar antes del ensayo |
|---|---|
| RUN / fecha / ventana | Pendiente |
| Bloques y casos aceptados para esta pasada | Pendiente; C/solo kg aún bloqueado |
| Responsable funcional / observador / trabajador | Pendiente |
| Central / estación / entorno / hashes + cambios locales | Pendiente |
| Balanza / protocolo / estabilidad / tara | Pendiente |
| Lector / sufijo / método de entrada | Pendiente |
| TSC / driver / spooler / DPI / papel | Pendiente |
| Pantalla / viewport / zoom / postura / distancia / EPP | Pendiente |
| Custodia durante fallo / quién resuelve | Pendiente |
| Carpeta de evidencia sin secretos | Pendiente |
| IDs dataset A/B/C/D/E/F/G/P/R/W y estados iniciales | Pendiente; solo los aplicables al bloque |
| Autorización ensayo aislado / impresión física si aplica | Pendiente |

## Resultado por caso

Valores humanos: PENDING, PASS, FAIL o NO_APLICA con justificación. La evidencia
automática se enlaza aparte; no completar PASS por los tests del agente.

| Caso | Funcional | Operativo | Físico | IDs / peso / evidencia / hallazgo |
|---|---|---|---|---|
| UAT-P01 Bloqueos e inicio | PENDING | PENDING | PENDING | |
| UAT-P02 Primer control | PENDING | PENDING | PENDING | |
| UAT-P03 Reescaneo sin aumento | PENDING | PENDING | PENDING | |
| UAT-P04 Segundo control misma OT/persona | PENDING | PENDING | PENDING | |
| UAT-P05 Cambio manga / QR rechazado | PENDING | PENDING | PENDING | |
| UAT-P06 Final de regresión, no nuevo cierre kg | PENDING | PENDING | PENDING | |
| UAT-P07 Reintento / doble F2 | PENDING | PENDING | PENDING | |
| UAT-P08 Negativos / balanza | PENDING | PENDING | PENDING | |
| UAT-P09 Conectividad / incertidumbre | PENDING | PENDING | PENDING | |
| UAT-P10 Impresión / lectura QR | PENDING | PENDING | PENDING | |
| UAT-P11 Pala / rastrillo separados | PENDING | PENDING | PENDING | Dataset por preparar |
| UAT-P12 WIP / peso fabricado teórico | PENDING | PENDING | PENDING | Dataset por preparar |

KG-01…KG-07: BLOCKED por adaptación pendiente; no son pruebas físicas
ejecutables todavía. Conciliación detallada: DIFERIDA, no criterio de esta UAT.

## Evidencia por perfil y observación

Registrar un resultado por cada ID PES-01…12, LEC-01…12, CON-01…12 e IMP-01…12
del guion. Una fila sin evidencia permanece PENDING.

| ID criterio | Resultado | Evidencia / explicación / caso relacionado |
|---|---|---|
| PES-01 | PENDING | |
| PES-02 | PENDING | |
| PES-03 | PENDING | |
| PES-04 | PENDING | |
| PES-05 | PENDING | |
| PES-06 | PENDING | |
| PES-07 | PENDING | |
| PES-08 | PENDING | |
| PES-09 | PENDING | |
| PES-10 | PENDING | |
| PES-11 | PENDING | |
| PES-12 | PENDING | |
| LEC-01 | PENDING | |
| LEC-02 | PENDING | |
| LEC-03 | PENDING | |
| LEC-04 | PENDING | |
| LEC-05 | PENDING | |
| LEC-06 | PENDING | |
| LEC-07 | PENDING | |
| LEC-08 | PENDING | |
| LEC-09 | PENDING | |
| LEC-10 | PENDING | |
| LEC-11 | PENDING | |
| LEC-12 | PENDING | |
| CON-01 | PENDING | |
| CON-02 | PENDING | |
| CON-03 | PENDING | |
| CON-04 | PENDING | |
| CON-05 | PENDING | |
| CON-06 | PENDING | |
| CON-07 | PENDING | |
| CON-08 | PENDING | |
| CON-09 | PENDING | |
| CON-10 | PENDING | |
| CON-11 | PENDING | |
| CON-12 | PENDING | |
| IMP-01 | PENDING | |
| IMP-02 | PENDING | |
| IMP-03 | PENDING | |
| IMP-04 | PENDING | |
| IMP-05 | PENDING | |
| IMP-06 | PENDING | |
| IMP-07 | PENDING | |
| IMP-08 | PENDING | |
| IMP-09 | PENDING | |
| IMP-10 | PENDING | |
| IMP-11 | PENDING | |
| IMP-12 | PENDING | |

| Persona / tarea | Completó | Ayuda | Dudas / retrocesos / casi-error | Tiempo observado | Evidencia |
|---|---|---|---|---|---|
| Pendiente | | | | | |

| Hallazgo | Severidad evaluada | Impacto | Responsable / siguiente acción | Revalidación |
|---|---|---|---|---|
| Revisar GAP-01…06 del guion antes de firmar | Pendiente | | | |

## Decisión humana

| Campo | Decisión / evidencia |
|---|---|
| Alcance efectivamente validado | Pendiente |
| Exclusiones y por qué no equivalen a PASS | Pendiente |
| functional_validation | untested |
| ux_validation | provisional |
| physical_uat | pending |
| release_constraint | no_habilitar_en_planta |
| Responsable funcional / fecha / firma | Pendiente |
| Trabajador / observador / fecha | Pendiente |

La firma de un bloque no acepta los demás ni autoriza despliegue, migración o
inventario integral kg. Una futura liberación exige evidencia de todos sus gates.
