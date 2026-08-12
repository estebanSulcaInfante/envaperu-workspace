---
tipo: uat
estado: lista-para-ejecucion-uat
tags: [scm, uat, piloto, ot, trabajo-color, mangas, qr, pesaje, relevos]
relaciones:
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[TS-010M1_OT_Maquina_y_Cola_Trabajos_Color]]"
  - "[[TS-010M2_Mangas_Pesaje_Anulacion_por_Trabajo_Color]]"
  - "[[TS-010M3_Relevos_en_Trabajo_Color]]"
  - "[[UAT_TS-010C_D_OT_Mangas_Pesaje]]"
  - "[[Alcance_Nuevo_Piloto_SCM_2026-08]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-09
---

# UAT TS-010M: OT y Trabajos de color

## 1. Objetivo

Demostrar físicamente que una sola OT de máquina/turno ejecuta dos Trabajos de
color sin mezclar cupos, mangas, responsables o pesajes, y que un relevo puede
reasignar stickers con control suficiente para un usuario novato.

Esta UAT es puerta previa para volver a ejecutar
[[UAT_TS-010C_D_OT_Mangas_Pesaje]].

## 2. Fronteras

La prueba usa solamente mangas que cierren dentro de la misma OT. No habilita:

- otra fecha, turno u OT para la misma manga;
- control o pesaje intermedio;
- `TramoMangaTrabajoColor`;
- material preparado, mezcla experimental o R1…Rn;
- TrabajoArmado nuevo.

Una manga abierta puede transferirse excepcionalmente dentro de la misma OT
con conteo de frontera; esa acción no captura peso ni imprime postetiqueta.

## 3. Participantes y datos

| Elemento | Requisito |
|---|---|
| Supervisor | Capacidad de OT, trabajos, asignaciones, impresión y anulación. |
| Maquinistas | Renato y Luis, activos. |
| Balanza | Operador/estación autenticados y separados del responsable productivo. |
| Máquina | Haitian 3000 u otra máquina piloto real. |
| Producto | Alcancía Pablo Grande o trazador aprobado. |
| Corridas | Dos corridas liberadas compatibles: Verde y un segundo color. |
| Mangas | Mínimo seis físicas; una para anulación y una para relevo. |
| RUN_ID | `UAT-M-AAAA-MM-DD-01`, presente en observaciones/evidencias. |

## 4. Puertas antes de ejecutar

- [x] Baseline automática de backend, PostgreSQL, frontend y estación verde.
- [x] Migración M aplicada en `envaperu_test` y Supabase; ambos en `f78`.
- [x] M1-01…10, M2-01…09 y M3-01…09 cubiertos automáticamente en su
  lógica; la evidencia física permanece en esta UAT.
- [x] Evidencia PostgreSQL de doble `ANULAR_PESAJE` cerrada.
- [x] Identidad y capacidades cargan correctamente en `envaperu_test`; smoke
  local ejecutado como Gerente General sobre la vista protegida por rol.
- [ ] Balanza, lector, impresora y papel disponibles.
- [ ] Regla de empaque y tara físicamente validadas.
- [ ] No existe otra UAT/productivo activo sobre la máquina o RUN_ID.
- [ ] Se conoce el procedimiento de reversa de recepción.

### 4.1. Evidencia automática de salida a UAT — 2026-08-08

- backend SCM sin PostgreSQL: `112 passed`;
- migración PostgreSQL aislada: `15 passed`, incluyendo backfill, RLS,
  upgrade/downgrade/upgrade y carrera de dos sesiones sobre una máquina;
- concurrencia de relevo M3-02 en PostgreSQL: `1 passed`;
- concurrencia de doble `ANULAR_PESAJE` M2 en PostgreSQL: `1 passed`;
- base PostgreSQL nueva + chequeo de drift: `1 passed`;
- frontend central focal (OT, API, Armado, guía e Ingeniería): `52 passed`,
  build correcto y lint sin errores;
- estación de pesaje: backend `9 passed`, frontend `5 passed` y build correcto.

Esta evidencia valida el paquete local. No sustituye aplicar la migración ni
ejecutar la UAT en Render/Supabase con balanza, lector e impresora reales.

### 4.2. Preparación local de `envaperu_test` — 2026-08-08

- respaldo previo recuperable:
  `.codex_tmp/envaperu_test_pre_f78_20260808_115646.dump`;
- revisión anterior: `f73a2b7c0d54`;
- revisión aplicada: `f78a7b3c9d20 (head)`;
- `flask db check`: sin operaciones nuevas detectadas;
- backend reiniciado explícitamente contra `envaperu_test` y `/api/health`
  respondió `status=ok`, `database=available`;
- smoke de navegador en `/produccion/ots-mangas`: la vista cargó como Gerente
  General, separó la cabecera “OT de máquina” de la “Cola de producción”,
  permitió definir fecha, máquina, turno y maquinista predeterminado sin exigir
  OF/corrida/color, y consultó jornadas existentes sin error;
- no se creó una OT ficticia: la primera escritura se reserva para el RUN_ID y
  la OF real de Alcancía Pablo Grande.

Esta preparación habilita la ejecución transaccional local de UAT-M. No marca
como aprobadas la evidencia física de QR, balanza, impresora, mangas, recepción
ni reversa, y tampoco equivale al despliegue de `f78` en Render/Supabase.

### 4.3. Despliegue Render/Supabase — 2026-08-08

- respaldo remoto previo validado:
  `.codex_tmp/supabase_pre_f78_20260808_122134.dump` (31.4 MB);
- revisión Supabase anterior: `f77e6f1b4c98`;
- revisión Supabase posterior: `f78a7b3c9d20`;
- tablas `scm_trabajo_ot`, `scm_trabajo_color` y
  `scm_asignacion_personal_trabajo_ot` presentes con RLS habilitado;
- backend Render: commit `8c69ae5`, deploy `dep-d9rmfaf40ujc73bra080`, estado
  `live`; `/api/health` respondió `200` y base disponible;
- frontend Render: commit `a2e2fdf`, deploy `dep-d9rmgltbedkc73c2ou9g`, estado
  `live`;
- smoke remoto autenticado con Renato Peña: la guía oficial cargó la nueva
  terminología y el perfil Gestor de datos maestros permaneció bloqueado fuera
  de Producción;
- `GET /api/scm/v1/ots` sin identidad respondió `401`, confirmando protección
  del contrato nuevo;
- no se crearon OT, Trabajos de color, mangas ni movimientos de inventario.

El paquete desplegado queda listo para ejecutar UAT-M con un actor de
Producción autorizado. La aprobación sigue condicionada a QR, balanza,
impresora, mangas físicas, recepción, reversa y conciliación.

## 5. Preparación

1. Crear o seleccionar OF con corridas Verde y Azul liberadas.
2. Crear una OT mediante `POST /ots/fabricacion` o la vista central para máquina,
   fecha, turno y proceso.
3. Agregar ambos Trabajos de color a la misma OT.
4. Confirmar en `GET /ots` una cabecera y dos elementos
   `trabajos_color[]`.
5. Asignar inicialmente Verde a Renato y Azul a Luis.
6. Crear mangas separadas por trabajo/salida y registrar IDs/códigos.

## 6. Casos de aceptación

### UAT-M-01 — Una OT, dos Trabajos de color

- La tarjeta muestra una OT para la máquina/turno.
- Verde y Azul poseen UUID, secuencia, corrida, objetivo y estado propios.
- La OT no permite editar un color/corrida global como fuente autoritativa.

### UAT-M-02 — Exclusividad y A → B → A

1. Iniciar Verde.
2. Confirmar que iniciar Azul simultáneamente se bloquea.
3. Pausar Verde, registrar cambio y ejecutar Azul.
4. Volver a Verde con el mismo contexto y comprobar que reanuda el mismo UUID.
5. En ambiente automatizado, modificar una condición técnica y comprobar que
   corresponde trabajo continuación, no reescritura.

### UAT-M-03 — QR y pesaje por trabajo

1. Imprimir una manga Verde y otra Azul.
2. Escanear cada QR en Balanza.
3. Confirmar OT común y Trabajo/OF/corrida/color/salida diferentes en solo
   lectura.
4. Pesar ambas y verificar un hecho/postetiqueta por manga.
5. Confirmar totales correctos en cada trabajo y suma derivada en OT.

### UAT-M-04 — Subconjuntos de stickers

1. Crear diez mangas pendientes de un trabajo de prueba.
2. Asignar seis a Renato y dejar cuatro previstas para Luis mediante el mismo
   comando gobernado; no mantener a ambos como responsables activos simultáneos
   de la máquina.
3. Verificar que cada QR resuelve su asignación prevista o vigente y que el
   cupo total no cambia.

### UAT-M-05 — Relevo y reasignación masiva

1. Con mangas pendientes/no iniciadas de Renato, ejecutar relevo a Luis con
   motivo.
2. Seleccionar el subconjunto restante o “todas las pendientes”.
3. Confirmar cierre/apertura de intervalos sin cambiar Trabajo de color.
4. Confirmar que no nacen mangas, cupos ni etiquetas adicionales indebidas.

### UAT-M-06 — Sticker ya impreso

1. Reasignar una manga no iniciada cuyo sticker muestra a Renato.
2. Confirmar invalidación de esa versión y reemplazo para la misma manga.
3. Escanear el QR anterior y comprobar bloqueo.
4. Escanear el nuevo y comprobar asignación a Luis, mismo trabajo y mismo cupo.

### UAT-M-07 — Manga abierta dentro de la misma OT

1. Marcar físicamente una manga abierta no pesada de Renato.
2. El supervisor registra motivo y conteo acumulado y la transfiere a Luis.
3. Confirmar que conserva la identidad de manga, Trabajo de color y OT.
4. Si el sticker muestra a Renato, confirmar que el QR anterior queda inválido
   y que se imprime una nueva versión para la misma manga y Luis.
5. Confirmar que no existe pesaje, lectura intermedia ni postetiqueta.
6. Al cierre final, pesar una sola vez y comprobar el conteo de frontera como
   evidencia declarada, no peso.

### UAT-M-08 — Snapshot al pesar

- El pesaje conserva la asignación de manga vigente al cierre.
- `trabajador productivo` y `actor real de Balanza` se muestran por separado.
- Un relevo posterior no cambia un pesaje o manga recibida.

### UAT-M-09 — Anulación y reversa

1. Anular un pesaje antes de Almacén: QR inválido, cupo devuelto al Trabajo de
   color y reemplazo `NORMAL`.
2. Recibir otra manga e intentar anular: exige
   `RECEIPT_REVERSAL_REQUIRED`.
3. Ejecutar `/recepcion-mangas/{existence_id}/reversiones` y después anular.
4. Confirmar hechos originales/compensatorios y eliminación directa bloqueada.

### UAT-M-10 — Cruce de OT bloqueado

Intentar llevar una manga abierta a otra OT, turno o fecha. Debe responder
`MULTI_SHIFT_BAG_NOT_ENABLED` o contrato equivalente y dirigir a US-010K sin
mutar la manga.

### UAT-M-11 — Regresión y frontera material

- La fachada `/ordenes-fabricacion/{of}/ots` continúa resolviendo el mismo
  agregado.
- Armado conserva su adaptador vigente.
- No aparecen campos, endpoints ni tablas de material preparado, mezcla
  experimental o R1…Rn en este recorrido.

### UAT-M-12 — Varias OT legacy coincidentes

1. Preparar una copia con dos OT monocolor históricas de la misma
   máquina/fecha/turno.
2. Ejecutar upgrade/backfill.
3. Confirmar que no se fusionan ni bloquean la migración.
4. Confirmar un Trabajo de color hijo por cada cabecera, con IDs, códigos,
   mangas y pesajes preservados.
5. Crear después una cabecera normalizada nueva y comprobar que la unicidad se
   aplica solo entre nuevas cabeceras equivalentes.

### UAT-M-13 — Pesaje diferido de color pausado

1. Dejar Verde `PAUSADO` con una manga cerrada todavía sin pesar.
2. Iniciar Azul en la misma máquina/OT.
3. Al final del turno, escanear y pesar la manga Verde.
4. Confirmar que Balanza acepta el pesaje, Verde sigue pausado y Azul continúa
   como único trabajo en ejecución.
5. Confirmar que Verde no puede marcarse `COMPLETADO` mientras conserve mangas
   sin resolver.

### UAT-M-14 — Tablero completo por máquina

1. Seleccionar fecha y turno con al menos una OT y varias máquinas activas sin
   jornada.
2. Confirmar una tarjeta por cada máquina activa y el resumen total de planta.
3. En una tarjeta con OT, verificar código/estado, maquinista, color activo,
   artículo/OF, mangas cerradas/con sticker/pendientes y siguiente color.
   `PREETIQUETADA` no debe mostrarse como abierta o en llenado.
4. Confirmar que una máquina sin OT muestra “Sin OT” y no crea registros por
   el solo hecho de consultarla.
5. Seleccionar una tarjeta y comprobar que abre el detalle de esa misma OT.
6. Repetir en móvil y escritorio sin desborde ni pérdida de la acción primaria.
7. Con dos OT legacy coincidentes en una máquina, confirmar que ambas quedan
   visibles como conflicto seleccionable y ninguna desaparece por agrupación.
8. Pausar el único Trabajo de color de una OT que conserve estado agregado
   `EN_EJECUCION`; la tarjeta debe decir **Pausada**, no **Produciendo**.
9. Agregar mangas a un color completado, otro pausado y otro planificado;
   confirmar que la tarjeta cuenta solo las mangas del color pausado que
   identifica y no suma colores diferentes.

### UAT-M-15 — Lenguaje humano del color

1. Abrir una OF con una sola configuración Verde sólido heredada de PiezaColor.
2. Confirmar que **Color a fabricar** muestra `VERDE SÓLIDO` como solo lectura y
   explica su origen.
3. Confirmar que el formulario no exige entender “corrida” ni `C01`.
4. Abrir una OF de prueba con dos configuraciones liberadas y confirmar un
   selector por nombres humanos inequívocos.
5. Crear el trabajo y verificar que internamente conserva el ID técnico exacto
   sin permitir color libre o incompatible.

## 7. Evidencias

Guardar sin secretos ni QR completos:

```text
UAT-M-AAAA-MM-DD/
├── 01-ot-dos-trabajos.png
├── 02-cambio-a-b-a.png
├── 03-pre-y-post-etiquetas.jpg
├── 04-subconjuntos-relevo.png
├── 05-sticker-reemplazado.jpg
├── 06-manga-abierta-frontera.png
├── 07-anulacion-reversa.png
├── 08-tablero-diario-maquinas.png
├── 09-color-humano.png
└── acta.md
```

### Smoke local previo — 2026-08-09

Validación de navegador sobre `envaperu_test`, sin crear ni modificar datos:

- fecha `2026-08-09`: el tablero mostró las dos máquinas activas, ambas con
  estado **Sin OT** y sin crear jornadas por consultarlas;
- fecha `2026-08-10`: mostró `OT-000001` únicamente en
  `MAQ-000002 · Sopladora Alcancía UAT`, conservando también la máquina sin OT;
- al abrir la tarjeta se seleccionó el detalle de `OT-000001`;
- el alta mostró **Color a fabricar · VERDE SÓLIDO**, el artículo
  `Cuerpo Alcancía Pablo Grande VERDE SÓLIDO` y `OF-000001`, sin exponer
  “corrida” ni `C01`.

Este smoke respalda el corte técnico de M-14/M-15, pero no sustituye la UAT:
quedan pendientes la matriz móvil/escritorio, 13 máquinas reales, múltiples
colores liberados y la firma del usuario.

## 8. Acta

| Caso | Estado | Evidencia | Observación |
|---|---|---|---|
| UAT-M-01 | PENDIENTE | | |
| UAT-M-02 | PENDIENTE | | |
| UAT-M-03 | PENDIENTE | | |
| UAT-M-04 | PENDIENTE | | |
| UAT-M-05 | PENDIENTE | | |
| UAT-M-06 | PENDIENTE | | |
| UAT-M-07 | PENDIENTE | | |
| UAT-M-08 | PENDIENTE | | |
| UAT-M-09 | PENDIENTE | | |
| UAT-M-10 | PENDIENTE | | |
| UAT-M-11 | PENDIENTE | | |
| UAT-M-12 | PENDIENTE | | |
| UAT-M-13 | PENDIENTE | | |
| UAT-M-14 | PENDIENTE | | |
| UAT-M-15 | PENDIENTE | | |

## 9. Criterio de aprobación

La UAT se aprueba cuando M-01…M-15 pasan, no existen defectos P0/P1, cada
diferencia de sticker/cupo queda explicada, ninguna identidad fue borrada y la
regresión C/D/I permanece verde. Solo entonces cambia a
`aprobada-para-marcha-blanca`.
