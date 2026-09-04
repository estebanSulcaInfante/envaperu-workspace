---
tipo: recibo_ejecucion
estado: implementado-solo-local
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: not_required
release_constraint: no_habilitar_en_planta
fecha: 2026-09-02
---

# Asignación en kg teóricos y advertencia de manga parcial

## Autorización y alcance

Usuario solicita kg como referencia/entrada, aviso no bloqueante de última manga
parcial y ayuda para convertir kg continuos a unidades discretas. Extensión local
de [[REC_2026-09-02_Propuesta_Mangas_Contextual_OT]], TS-010C y [[Perfil_Empaque]].
Contexto de supervisión escritorio: [[CTX_PROTO_US-010M4_Recuperacion_OT_Vacia]].
No cambio de inventario/medición, backend ni capacidades. No hechos de negocio
durante QA. Mantener excepción solo local, UX provisional, sin habilitar planta.

## Contratos y wireflow de esta porción

1. Primaria: kg teóricos a asignar por salida; pendiente, por manga, asignado y
   distribución de mangas en kg. Unidades quedan como equivalencia de planificación.
2. Fuente: peso unitario congelado de la salida exacta de la OF, vinculada por ID
   desde la línea del plan; nunca peso maestro actual ni otra salida con nombre parecido.
3. Kg excluyen tara y colada; no equivalen a kg reales de balanza. Para salida WIP
   no reinterpretar su peso como material inyectado aislado.
4. Conversión decimal exacta: kg / peso unitario. Un resultado no entero ofrece
   inferior/superior con unidades y kg efectivos; decisión humana explícita, sin
   redondeo automático ni umbrales inventados. Alternativa fuera del saldo no elegible.
5. La cantidad enviada sigue siendo UN enteras mediante contrato vigente.
   Kg solicitados/diferencia se muestran antes de agregar; no se afirma un nuevo
   campo persistente de demanda en kg ni auditoría de intención que el backend no tiene.
6. Aviso de última manga parcial para cualquier resto no nulo, sin bloquear ni
   exigir aceptación adicional. No modificar capacidades de empaque ni descartar resto.
7. Sin peso exacto/disponible, kg inválidos o decisión discreta pendiente: explicar
   y no enviar una asignación ficticia. Cero permitido para salidas no elegidas;
   continuidad seleccionada mantiene su flujo y no duplica manga.
8. Al cambiar plan/OF se reinician los kg editados; una selección de redondeo
   solo vale para el texto solicitado actual. Error conserva edición para revisión.

Ejemplo real local: peso 240 g, manga de 50 un = 12 kg. Pedir 13 kg no da 54,166…
unidades realizables: elegir 54 un = 12,96 kg o 55 un = 13,20 kg. La segunda manga
resultante será 0,96 o 1,20 kg, no afirmar silenciosamente que pesa exactamente 1 kg.

## Evidencia y cierre

Workspace/submódulo frontend sucios previos, sin commit; preservar trabajo ajeno.

| Paso / comando desde frontend | Resultado |
|---|---|
| BASELINE: npm run test:run -- src/tests/OtMangasScm.spec.jsx | 35 verdes |
| RED: mismo comando con -t 'asigna kg' | Falló por ausencia del campo Kg teóricos a asignar |
| RED de utilidad: npm run test:run -- src/tests/workKgAssignment.spec.js | Módulo aún inexistente |
| GREEN inicial de utilidad | 13 pruebas verdes |
| GREEN focal integración kg/continuidad/cantidades/plan | 8 verdes, 28 omitidas por filtro |
| Regresión: npm run test:run -- src/tests/OtMangasScm.spec.jsx src/tests/OtMangasDailyBoard.spec.jsx src/tests/PlantJourneysScm.spec.jsx src/tests/OtHeaderSafety.spec.jsx src/tests/scmOtApi.spec.js src/tests/workKgAssignment.spec.js | 88 verdes, seis archivos |
| REFACTOR final: npm run test:run -- src/tests/workKgAssignment.spec.js src/tests/OtMangasScm.spec.jsx -t 'asignación discreta\|asigna kg' | 17 verdes, 35 omitidas por filtro; patrón literal usa barra vertical sin escape |
| npm run build final | Correcto, 1314 módulos; advertencia preexistente de tamaño de bundle |
| git diff --check focal | Sin errores, aviso LF/CRLF |

Refactor: utilidad decimal pura y componente controlado separado; no se añadieron
dependencias. Validación común antes del envío. Se retiró ayuda de «cantidad > 0»
cuando el bloqueo real es decisión de equivalencia pendiente. Se añadió diferencia
exacta y se comprobó que modificar kg invalida la elección anterior.

## Archivos cambiados

- frontend/src/utils/workKgAssignment.js: aritmética decimal con enteros BigInt;
  fuente exacta por ID de salida, límites de saldo, opciones y distribución.
- frontend/src/components/WorkKgAllocation.jsx: tarjeta kg, decisión explícita,
  avisos, desglose y cantidades secundarias. [[WorkKgAllocation]].
- frontend/src/components/OtMangasScm.jsx: integración controlada y envío de UN
  elegidas, reset de edición por cambio/recálculo/recarga de plan.
- frontend/src/tests/workKgAssignment.spec.js y OtMangasScm.spec.jsx: casos exactos,
  coma decimal, cero/negativo/exceso/fracción, peso ausente/ajeno, multipieza,
  parciales y petición efectiva. Fixtures existentes declaran salida y peso congelado
  para no depender de una conversión implícita o inventada.
- TS-010C y nota del componente: contrato y trazabilidad.

## Evidencia visual y operativa

Revisión con habilidad de navegador, viewport 1049×859, Said/Supervisor, local.
Capturas en outputs/uat-m4-2026-09-02:

- 14-asignacion-kg-completa.png: 24 kg, dos mangas de 12 kg;
- 15-asignacion-kg-eleccion-discreta.png: 13 kg exige elección;
- 16-asignacion-kg-manga-parcial.png: primera versión del aviso parcial;
- 17-asignacion-kg-diferencia-final.png: 12,96 kg elegidos, diferencia -0,04 kg,
  manga de 12 kg y parcial 0,96 kg. Botón Agregar habilitado, no pulsado.

Se restauró el campo a 24 kg al terminar. API confirmó OT-000002 PLANIFICADA,
cero trabajos de color. No se crearon trabajos/mangas ni se recalculó el plan.
Interacción real: escribir kg, elegir alternativa, volver a editar; controles con
nombres accesibles y estado seleccionado aria-pressed. No prueba física de teclado.

## UAT incremental ADM/CON

Participante/RUN/aceptación por registrar; técnico verde no implica aceptación:

| Perfil | Caso adaptado | Resultado esperado | Estado humano |
|---|---|---|---|
| ADM-02/03 | Leer la propuesta antes de asignar | Reconoce kg teóricos principales, unidades secundarias y ausencia de peso real | PENDING |
| ADM-08 | Pedir 13 kg con peso 240 g | Elige conscientemente 12,96/13,20; ve diferencia | PENDING |
| ADM-04/11 | Revisar última manga parcial | Ve distribución y aviso no bloqueante; puede continuar | PENDING |
| ADM-09 | Operar con teclado | Campo/opciones/acción accesibles sin confundir ajuste con confirmación | PENDING |
| ADM-12 | Cambiar OF o recalcular propuesta | Edición anterior no se aplica a otra propuesta | PENDING |
| CON-11 | Peso faltante/error de consulta | No inventa kg ni manda cantidad no resuelta | PENDING |

Sin tolerancia de «manga demasiado pequeña» inventada: cualquier resto dispara
el aviso. No requiere confirmación adicional por parcial. No hardware en este corte.

## Omisiones, riesgos y siguiente gate

- Suite completa scripts/test.ps1 no repetida: baseline/regresión focal frontend;
  problemas globales preexistentes de ProductOnboarding quedan fuera de alcance.
- Backend/PostgreSQL/contratos Central–pesaje/sync omitidos por no cambiar código
  ni contratos. El servidor sigue validando saldo y unidades enteras autoritativamente.
- Vista multipieza con datos reales, WIP físico, otros viewports y validación con
  trabajador representativo pendientes. La utilidad sí prueba pesos distintos por
  salida y falla segura sin peso congelado exacto.
- No se persiste solicitud inicial en kg; se envía la equivalencia UN elegida al
  contrato existente. No se afirma migración integral del inventario a kg.
- La tarjeta puede exigir scroll en el viewport local: aviso y desglose se revisaron,
  usabilidad representativa todavía provisional, no LISTO_PARA_PLANTA.
- Entrada admite punto/coma decimal sin notación científica. Límite defensivo de
  longitud de texto 80 caracteres, no una tolerancia ni precisión de planta.
- Siguiente acción: usuario prueba 13 kg sin enviar si desea validar la ayuda,
  vuelve a 24 kg y crea el trabajo del recorrido cuando confirme la propuesta.
- Marcha blanca productiva: no aplica; no despliegue remoto ni reset.
