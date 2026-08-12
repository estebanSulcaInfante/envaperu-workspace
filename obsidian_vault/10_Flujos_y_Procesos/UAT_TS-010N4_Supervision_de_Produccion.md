---
tipo: uat
estado: pendiente
tags: [scm, uat, control, supervision, fabricacion, armado, permisos, responsive]
relaciones:
  - "[[US-010N4_Supervision_de_Produccion_Read_Model_Operativo]]"
  - "[[TS-010N4_Supervision_de_Produccion]]"
  - "[[DEV-010N4_Supervision_de_Produccion]]"
  - "[[Vista_US-010N4_Supervision_de_Produccion]]"
  - "[[UAT_TS-010N3_Jornadas_de_Planta_y_Fechas_Proyectadas]]"
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
---

# UAT TS-010N4: Supervisión de producción

## Estado

**PENDIENTE.** Este documento prepara casos y evidencia. Ninguna fila se marca
aprobada por pruebas automáticas, implementación local o revisión documental.

## Objetivo

Confirmar con Producción que Supervisión permite explicar OT de Fabricación y
Armado sin modificar ejecución, duplicar hechos, revelar datos no autorizados
o mezclar unidades, kg físicos, kg estándar, recepción, inventario y Calidad.

## Roles de la sesión

| Participante | Capacidad mínima | Propósito |
|---|---|---|
| Jefatura completa | `OT_VER`, `MANGA_PESAJE_VER`, `ALERTA_VER`, `RECEPCION_MANGA_VER`, `CALIDAD_MANGA_VER` | Verificar universo y enriquecimientos. |
| Consulta OT | solo `OT_VER` dentro del corte | Verificar degradación. |
| Consulta sin pesaje | `OT_VER`, sin `MANGA_PESAJE_VER` | Probar que oculta lecturas/kg pero conserva estado operativo. |
| Consulta sin alertas | `OT_VER`, sin `ALERTA_VER` | Probar riesgo y side channel. |
| Consulta solo Almacén | `OT_VER`, `RECEPCION_MANGA_VER`, sin `CALIDAD_MANGA_VER` | Verificar degradación independiente. |
| Consulta solo Calidad | `OT_VER`, `CALIDAD_MANGA_VER`, sin `RECEPCION_MANGA_VER` | Verificar degradación independiente. |
| Sin OT | sin `OT_VER` | Verificar ausencia del feature y 403. |

No se comparten identidades. Se registra actor y conjunto efectivo de
capacidades en cada evidencia.

## Dataset mínimo

Crear por UI/API autorizada o reutilizar datos UAT identificados; no insertar
por SQL para “hacer pasar” la UAT:

1. `OT-000101` Fabricación, día `2026-08-10`, máquina `MAQ-01`, dos Trabajos de
   color: 600 unidades Carne completadas y 200 Azul en ejecución.
2. Dos mangas válidas que suman 62.500 kg físicos y 64.000 kg estándar para la
   salida atribuible.
3. Una corrección de pesaje 31.000 → 30.500 kg aplicada y auditable.
4. Una manga/pesaje anulado de 10.000 kg que no debe sumar.
5. `OT-000102` Armado, `OA-000020`, 300 unidades confirmadas y avances
   provisionales ya conciliados, con manga pendiente de recepción.
6. `OT-000103` Armado, manga recibida, Calidad `BLOQUEADA`, no disponible.
7. 65 OT autorizadas para recorrer tres páginas con el límite por defecto 25.
8. OT en al menos dos días de agosto para granularidad DIA y MES.
9. Una OT con responsable o dato técnico realmente ausente.
10. Una fila/snapshot `LOCAL_REPORTED_LEGACY` de la misma fecha, solo para
    comprobar aislamiento.

Los códigos son ilustrativos. La evidencia registra los IDs reales usados y
las cantidades esperadas antes de abrir la pantalla.

## Precondiciones

- N4 desplegada en entorno UAT con los tres GET autorizados;
- N3/Jornadas disponible para verificar deep-link sin duplicación;
- datos normalizados de OT, trabajos, mangas, pesajes y recepción;
- perfiles anteriores asignados;
- reloj cliente y zona horaria `America/Lima` conocidos;
- viewports 390, 768 y 1440 px;
- herramientas para observar requests/respuestas sin modificar payloads;
- RUN_ID y carpeta de evidencia preparados.

## Casos

| Caso | Acción | Resultado esperado | Estado |
|---|---|---|---|
| N4-U01 | Abrir fecha/turno del dataset | Aparecen las tres OT normalizadas una vez cada una; la OT multicolor no se duplica y la legacy no entra. | PENDIENTE |
| N4-U02 | Abrir `OT-000101` | Detalle muestra Carne y Azul separados, 800 unidades efectivas y Azul actual. | PENDIENTE |
| N4-U03 | Abrir `OT-000102` | Armado muestra 300 confirmadas; avances provisionales conciliados no se suman otra vez. | PENDIENTE |
| N4-U04 | Comparar kg de `OT-000101` | Muestra 62.500 kg físicos y 64.000 kg estándar en campos separados y rotulados. | PENDIENTE |
| N4-U05 | Revisar corrección/anulación | Total usa 30.500 vigente y excluye 10.000 anulado; originales siguen auditables en detalle. | PENDIENTE |
| N4-U06 | Revisar OT pendientes/recibidas | Manga pesada no figura recibida; manga recibida/bloqueada no figura disponible. | PENDIENTE |
| N4-U07 | Abrir con solo `OT_VER` | Núcleo y conteos logísticos visibles; pesaje, alerta y detalle Almacén/Calidad están `null`/ocultos, no en cero. | PENDIENTE |
| N4-U08 | Sin capacidades sensibles, filtrar `alertas`, `pendientes_almacen` y `pendientes_pesaje` | Alertas/Almacén devuelven 403 sin revelar coincidencias; pendiente de pesaje funciona con `OT_VER` pero no expone lectura ni kg. | PENDIENTE |
| N4-U09 | Abrir sin `OT_VER` | No aparece feature y request directo queda 403. | PENDIENTE |
| N4-U10 | Cargar tres páginas de 25 con cursor | Cada OT aparece una vez, todas las páginas conservan el mismo `as_of` y Cargar más desaparece al final. | PENDIENTE |
| N4-U11 | Cambiar filtro después de página 2 | Resultados y cursor reinician explícitamente; no mezcla universos. | PENDIENTE |
| N4-U12 | Reusar cursor con filtros distintos | Request se rechaza; UI no simula vacío ni vuelve silenciosamente a página 1. | PENDIENTE |
| N4-U13 | Consultar resumen DIA y MES | Totales y series concilian con lista bajo los mismos filtros; kg físico/estándar no se suman entre sí. | PENDIENTE |
| N4-U14 | Filtrar Fabricación, Armado, estados, recurso, responsable y códigos | Cada combinación conserva período y devuelve únicamente el universo autorizado. | PENDIENTE |
| N4-U15 | Esperar 30 s, pausar y reanudar | `as_of` se renueva; pausa detiene requests y deja antigüedad visible; reanudar conserva filtros. | PENDIENTE |
| N4-U16 | Simular fallo de refresh/resumen | Última lista válida permanece; error parcial y `as_of` anterior son visibles; no aparecen ceros. | PENDIENTE |
| N4-U17 | Consultar OT con dato faltante | Muestra No informado/Por asignar; no calcula cero ni oculta toda la OT. | PENDIENTE |
| N4-U18 | Abrir detalle y seguir enlace a Jornadas | Supervisión no ofrece comandos; Jornadas abre contexto exacto y volver conserva filtros. | PENDIENTE |
| N4-U19 | Probar 390, 768 y 1440 px con teclado | Sin desborde global; tarjetas/tabla/filtros/drawer funcionan y foco retorna al disparador. | PENDIENTE |
| N4-U20 | Buscar la fuente legacy | Permanece separada/rotulada; N4 no ofrece suma ni tab combinado. | PENDIENTE |
| N4-U21 | Consultar sin `limit`, con `1`, `100`, `0` y `101` | Usa 25 por defecto; acepta extremos válidos; `0/101` responden `INVALID_OBSERVABILITY_LIMIT` sin corregirse solos. | PENDIENTE |
| N4-U22 | Consultar `desde > hasta` y luego un rango largo válido | Rango invertido responde `INVALID_OBSERVABILITY_DATE_RANGE`; el rango largo no se rechaza por un máximo inexistente en v1. | PENDIENTE |
| N4-U23 | Alterar cursor o usar versión desconocida | Responde `INVALID_OBSERVABILITY_CURSOR`; UI conserva contexto y ofrece reinicio explícito. | PENDIENTE |
| N4-U24 | Reusar cursor con otro filtro | Responde `OBSERVABILITY_CURSOR_FILTER_MISMATCH`; no mezcla páginas ni reinicia en silencio. | PENDIENTE |
| N4-U25 | Abrir con recepción pero sin Calidad | Muestra detalle de Almacén; `calidad=false` y el detalle de Calidad queda oculto/null, no en cero. | PENDIENTE |
| N4-U26 | Abrir con Calidad pero sin recepción | Muestra decisión de Calidad; `almacen=false` y el detalle de recepción queda oculto/null, sin ocultar Calidad. | PENDIENTE |

## SLA y recencia a observar

N4 no tiene un SLA numérico de entrega de eventos aprobado. La UAT registra,
sin reinterpretar:

- latencia observada de lista, detalle y resumen;
- `as_of` devuelto y hora cliente;
- cadencia de 30 s del frontend;
- `ultimo_evento_at` y `horas_sin_actividad` como actividad de negocio;
- tiempo y comportamiento de recuperación tras un error.

Un hallazgo P1 se abre si la pantalla afirma actualidad que no puede probar,
borra la última respuesta válida o confunde falta de actividad con caída de
sincronización. Un SLA numérico futuro requiere decisión operativa separada.

## Evidencia requerida

Por caso:

- RUN_ID, entorno, build/commit y actor;
- URL y filtros;
- request/response sanitizados con `as_of` y `visibilidad`;
- captura en ancho aplicable;
- IDs de OT/trabajo/manga/pesaje/recepción usados;
- cálculo manual esperado para unidades y ambos kg;
- resultado real, severidad y responsable del hallazgo;
- evidencia de que no hubo escritura.

Carpeta sugerida:

```text
UAT-N4-AAAA-MM-DD-01/
├── precondiciones.md
├── dataset.md
├── permisos/
├── diario/
├── mensual/
├── cursor/
├── responsive/
└── hallazgos.md
```

## Matriz de ejecución

| Caso | Estado | Evidencia | Hallazgo |
|---|---|---|---|
| N4-U01…N4-U26 | PENDIENTE | | |

La fila compacta no implica ejecución conjunta: cada caso debe registrar su
resultado individual antes de cambiar el estado general.

## Criterio de aprobación humana

- N4-U01…N4-U26 aprobados por personas autorizadas;
- cero P0/P1 abiertos;
- cero doble conteo de unidades o kg;
- cero mezcla físico/estándar o legacy/normalizado;
- cero mutaciones desde Supervisión;
- cero filtración por permisos parciales;
- conciliación diaria y mensual firmada por Producción;
- accesibilidad y responsive sin bloqueo operativo.

Hasta entonces esta UAT permanece **PENDIENTE** aunque todas las suites
automáticas estén verdes.

## Evidencia automática

Evidencia local registrada el 2026-08-10:

| Carril | Comando | Resultado |
|---|---|---|
| Backend focal | `.venv/Scripts/python.exe -m pytest -q tests/scm/test_scm_production_observability.py` desde `backend/` | 8/8 |
| Backend completa | `.venv/Scripts/python.exe -m pytest -q` desde `backend/` | 351 passed, 1 skipped OCR, 21 deselected, 0 fallos |
| Frontend focal | comando de ocho archivos detallado en [[TS-010N4_Supervision_de_Produccion#15. Evidencia técnica de cierre local — 2026-08-10|TS-010N4]] | 8 archivos, 55/55 |
| Frontend completa | `npm run test -- --run` desde `frontend/` | 57 archivos, 295/295 |
| Frontend estática/build | `npm run lint`; `npm run build` | verdes; warning no bloqueante de chunk >500 kB |
| Smoke desktop local (no UAT) | Navegador integrado contra `enva_uat_alcancia`, 2026-08-10 | 2 OT visibles (Fabricación/Armado), filtro pesaje 1/1, modo Recursos y drawer jerárquico verificados |

La evidencia backend incluye 103 OT en el resumen sin truncamiento por
paginación y consultas acotadas por página. No ejecutó migración ni tocó una
base remota. Estas pruebas permiten comenzar la ejecución humana; **ningún caso
N4-U01…N4-U26 cambia de PENDIENTE** hasta registrar evidencia UAT y firma.

## Casos aditivos N4.1 - mangas

Todos permanecen **PENDIENTE** hasta evidencia humana:

| ID | Caso | Estado |
|---|---|---|
| N4-U27 | Abrir modo Mangas y ver Fabricacion y Armado en varios estados | PENDIENTE |
| N4-U28 | Buscar un codigo exacto y obtener una unica manga | PENDIENTE |
| N4-U29 | Buscar codigo parcial, articulo y color en servidor | PENDIENTE |
| N4-U30 | Filtrar estado de manga y combinar fecha/turno/tipo | PENDIENTE |
| N4-U31 | Ver cantidades, peso fisico y kg estandar sin mezclarlos | PENDIENTE |
| N4-U32 | Abrir trazabilidad y comprobar OT, trabajo, OF/OA y OP | PENDIENTE |
| N4-U33 | Actor OT_VER sin pesaje/almacen/calidad no recibe datos restringidos | PENDIENTE |
| N4-U34 | Cambiar OT-Mangas-Recursos reinicia cursor y conserva filtros compatibles | PENDIENTE |
| N4-U35 | Paginar con altas concurrentes sin duplicados dentro de `as_of` | PENDIENTE |
| N4-U36 | Validar tabla desktop y tarjetas 390/768/1440, teclado y lector | PENDIENTE |
| N4-U37 | Confirmar que no existe accion de recepcion, pesaje ni inventario | PENDIENTE |
| N4-U38 | Desplegar en Render y ejecutar smoke remoto con actor autorizado | PENDIENTE |

Evidencia automatica local inicial: backend observabilidad 10/10 y frontend
componente+API 23/23. No se ejecuto migracion ni se modifico una base remota.
Esta evidencia no aprueba los casos N4-U27...N4-U38.
Regresion ampliada local N4/navegacion: 8 archivos, 57/57; lint y build verdes.
No cambia el estado PENDIENTE de N4-U27...N4-U38.

## Casos aditivos N4.2 - OTs e impresion

| Caso | Escenario | Esperado | Estado |
|---|---|---|---|
| N4-U27 | Abrir OTs de planta | Se ven recursos del turno y alta de OT, sin formularios de Trabajo de color. | PENDIENTE |
| N4-U28 | Abrir una OT existente | Navega al detalle conservando fecha/turno/OT; no repite tablero general. | PENDIENTE |
| N4-U29 | Consultar impresion pendiente | Control muestra manga, PREPESAJE, estado y ausencia/presencia de estacion. | PENDIENTE |
| N4-U30 | Buscar codigo de manga | La cola queda filtrada al trabajo que contiene la manga. | PENDIENTE |
| N4-U31 | Abrir vista previa | Abre estacion sin imprimir ni cambiar GENERADA. | PENDIENTE |
| N4-U32 | Consultar POSTPESAJE | Se distingue del prepesaje y no ofrece impresion manual desde Control. | PENDIENTE |
| N4-U33 | Abrir alias historico | La ruta anterior sigue disponible sin aparecer como navegacion canonica. | PENDIENTE |