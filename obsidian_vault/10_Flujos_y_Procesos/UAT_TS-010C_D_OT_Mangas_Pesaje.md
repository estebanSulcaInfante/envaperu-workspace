---
tipo: guia-uat
estado: requiere-adaptacion-us-010m
tags: [scm, uat, ts-010c, ts-010d, ot, mangas, balanza, etiquetas, windows]
fecha_creacion: 2026-07-28
fecha_actualizacion: 2026-08-08
base_datos: envaperu_test
revision_minima: f63a2c8d4e70
relaciones:
  - "[[UAT_TS-010M_OT_y_Trabajos_Color]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[TS-010C_OT_Central_Planificacion_Mangas_y_Etiquetado_Prepesaje]]"
  - "[[TS-010D_Pesaje_Conectado_Mangas_y_Etiquetado_Final]]"
  - "[[SCM_OT_Mangas_y_Etiquetas_Prepesaje]]"
  - "[[SCM_Pesaje_Mangas_y_Etiqueta_Final]]"
  - "[[TS-010P_OP_Demanda_OF_OA_y_Migracion_Documental]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
---

# UAT TS-010C/D: OF, OT, mangas y pesaje conectado

> [!warning] Puerta US-010M
> Esta guía no vuelve a estado ejecutable hasta aprobar
> [[UAT_TS-010M_OT_y_Trabajos_Color]]. La OT ahora es cabecera de
> máquina/turno y cada manga de Fabricación debe resolver su Trabajo de color.
> Después se repiten todos los casos C/D como regresión.

> [!info] Línea base C/D que se adaptará después de UAT-M
> Esta guía parte de una `OF/corrida` liberada por el flujo normalizado
> `OP demanda -> cobertura -> plan -> OF/OA`. Debe ejecutarse después de la fase
> de liberación de OF de [[UAT_TS-010P_Flujo_Demanda_Fabricacion_Armado]] y
> continúa en [[UAT_TS-010I_Recepcion_Mangas_Kardex]].

## 1. Objetivo

Validar en planta, desde los servicios detenidos, el recorrido:

```text
OF/corrida normalizada
  -> plan de mangas
  -> OT diaria
  -> manga identificada
  -> etiqueta PREPESAJE
  -> escaneo
  -> peso estable y F2
  -> pesaje central
  -> etiqueta POSTPESAJE
  -> PENDIENTE_RECEPCION_ALMACEN
```

Esta guía cubre la primera UAT física de TS-010C y TS-010D. No habilita
producción, no crea Kardex y no prueba todavía el ingreso de almacén de
US-010I.

### Qué significa una UAT limpia

Una ejecución limpia no borra la base ni elimina históricos. Debe:

1. usar exclusivamente PostgreSQL local `envaperu_test`;
2. definir un `RUN_ID` único, por ejemplo `UAT-2026-08-03-01`;
3. crear OP, OF, OT, mangas y operaciones nuevas para ese `RUN_ID`;
4. usar almacenamiento aislado de estación `Pesaje-UAT-<RUN_ID>`;
5. registrar baseline, actores, códigos y saldos antes de operar;
6. conservar correcciones, reversas y anulaciones como evidencia;
7. no ejecutar `seed.py`, `DELETE`, `TRUNCATE` ni limpiezas SQL.

Una repetición completa usa otro `RUN_ID`. Un error operativo se corrige,
reversa o anula mediante el flujo funcional.

## 2. Reglas de seguridad

- Usar exclusivamente PostgreSQL local `envaperu_test`.
- No apuntar `DATABASE_URL` a la base desplegada.
- No ejecutar `backend/seed.py`: elimina tablas y recrea datos.
- No borrar ni reinterpretar pesajes históricos de la estación.
- Usar un almacenamiento local aislado `Pesaje-UAT`; no abrir el SQLite de
  `Pesaje`.
- No habilitar `SYNC_ENABLED`; debe permanecer `false`.
- No introducir el token de estación en `.env`, capturas o evidencias.
- Si se repite una impresión, generar un reemplazo; no reutilizar la identidad
  anterior.
- Conservar las mangas y correcciones UAT como evidencia. No limpiarlas con SQL.

## 3. Participantes mínimos

| Participante | Rol SCM requerido | Función en UAT |
|---|---|---|
| Coordinador UAT | `SUPERVISOR`, `INGENIERIA_SCM`, `CONFIGURACION_SCM`, `PLANIFICACION`, `OPERADOR_PESAJE` | Configura, planifica, solicita y pesa. |
| Jefe de Producción | `JEFE_PRODUCCION` | Aprueba reglas, extras, reemplazos y correcciones. |
| Maquinista | `MAQUINISTA` | Queda asignado a la OT y manga. |
| Observador | `AUDITORIA_CONSULTA` opcional | Registra resultados sin mutar. |

El solicitante y el aprobador deben ser trabajadores distintos.

## 4. Equipo y datos que deben estar disponibles

### Hardware

- PC Windows de la estación;
- balanza conectada y puerto COM identificado;
- lector QR configurado como teclado;
- impresora TSC TE200 instalada en Windows;
- papel de 109 × 50 mm con dos columnas de sticker;
- al menos una manga o bolsa física para la prueba;
- una carga de piezas de peso conocido.

### Datos mínimos

- una máquina operativa;
- un molde normalizado;
- una o dos PiezaColor existentes como artículos SCM;
- una OF normalizada con `molde_id`, `maquina_id`, snapshot de molde y salidas;
- un Tipo de manga con tara real;
- un perfil empacable;
- una regla de empaque aprobada;
- el perfil asignado como predeterminado a cada artículo de salida de la OF.

Antes de ejecutar, registrar en `00-baseline.md` los conteos y códigos reales de
la ejecución. No asumir fixtures, cantidades ni actores históricos. La puerta se
cumple sólo si:

- `envaperu_test` está en `f63a2c8d4e70` o un head posterior compatible;
- TS-010P dejó una OF/corrida nueva, normalizada y liberada;
- existen al menos tres mangas físicas para recorrido feliz, anulación y reversa;
- los actores y capacidades se verificaron desde la configuración vigente;
- perfil y regla de empaque están activos y aprobados.

## 5. Instalación inicial

Si los entornos `.venv`, `node_modules` y el build de la estación ya existen,
continuar en la sección 6.

### Backend central

```powershell
cd C:\Users\esteb\gitprojects\envaperu-workspace-2\backend
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
```

### Frontend central

```powershell
cd C:\Users\esteb\gitprojects\envaperu-workspace-2\frontend
npm.cmd install
```

### Estación de pesaje

Desde `C:\Users\esteb\gitprojects\envaperu-workspace-2\modulo-pesaje`:

```powershell
.\install-windows.bat
```

La instalación no debe abrir ni migrar manualmente el SQLite histórico.

## 6. Levantar central

### 6.1. Verificar migración

Abrir PowerShell:

```powershell
cd C:\Users\esteb\gitprojects\envaperu-workspace-2\backend
$env:DATABASE_URL='postgresql+psycopg2://postgres:<PASSWORD_LOCAL_UAT>@localhost/envaperu_test'
$env:FLASK_APP='run.py'
.\.venv\Scripts\python.exe -m flask db current
```

Resultado esperado:

```text
f63a2c8d4e70 (head)
```

Si aparece una revisión anterior:

```powershell
.\.venv\Scripts\python.exe -m flask db upgrade head
```

Detenerse si el nombre de la base no es `envaperu_test`.

### 6.2. Iniciar API

En la misma terminal:

```powershell
.\.venv\Scripts\python.exe run.py
```

Validar:

```powershell
Invoke-RestMethod http://127.0.0.1:5000/api/health
```

Debe devolver `status=ok` y `database=available`.

### 6.3. Iniciar frontend central

En otra terminal:

```powershell
cd C:\Users\esteb\gitprojects\envaperu-workspace-2\frontend
npm.cmd run dev
```

Abrir `http://127.0.0.1:5173`.

## 7. Preparar personas y actores

1. Abrir **Datos maestros → Trabajadores**.
2. Editar `TR-MIG-001` o crear al Coordinador UAT.
3. Asignar los roles indicados en la sección 3.
4. Crear otro trabajador para Jefe de Producción y asignar
   `JEFE_PRODUCCION`.
5. Crear o elegir un Maquinista con rol `MAQUINISTA`.
6. Obtener los ID internos:

```powershell
Invoke-RestMethod http://127.0.0.1:5000/api/catalogo/trabajadores |
  Select-Object id,codigo,nombre_completo
```

Registrar:

| Dato | Valor |
|---|---|
| `ACTOR_COORDINADOR_ID` | |
| `ACTOR_JP_ID` | |
| `MAQUINISTA_ID` | |

Los campos **Actor local de prueba** de Ingeniería SCM y **Actor SCM** de OT y
mangas utilizan el ID numérico, no el código `TRB-*`.

## 8. Configurar la manga y el empaque

Abrir **Datos maestros → Ingeniería SCM** y escribir el ID del Coordinador en
**Actor local de prueba**.

### 8.1. Tipo de manga

En **Empaque → Tipos de contenedor → Nuevo**:

- clase: `MANGA`;
- nombre: identificable, por ejemplo `Manga UAT estándar`;
- material: material físico real;
- tara nominal: peso real de la manga vacía en gramos;
- tolerancia de tara: valor acordado para la prueba;
- bruto máximo: límite seguro de balanza y manga.

Anotar el código automático `TMG-*`.

### 8.2. Perfil empacable

En **Empaque → Perfiles empacables → Nuevo**:

- nombre: `Perfil UAT <pieza>`;
- descripción física: cómo se acomodan las piezas.

Anotar el código `PEM-*`.

### 8.3. Regla de empaque

En **Empaque → Reglas de empaque → Nueva regla**:

- elegir el perfil y el Tipo de manga;
- cantidad objetivo: usar una cantidad pequeña y físicamente verificable;
- máximo probado: igual o mayor al objetivo;
- neto operativo máximo: superior al peso teórico esperado;
- margen y tolerancias: acordados para UAT;
- marcar “Capacidad verificada con una medición física” solo si efectivamente
  se realizó;
- guardar como borrador con el Coordinador.

Ir a **Aprobaciones**, cambiar **Actor local de prueba** al ID del JP y aprobar.
El mismo trabajador que creó la revisión no debe aprobarla.

### 8.4. Asignar el perfil a los artículos

La asignación ya está disponible en la interfaz:

1. abrir **Datos maestros → Ingeniería SCM → Artículos**;
2. localizar cada artículo de salida de la OF;
3. pulsar **Asignar perfil**;
4. seleccionar el perfil empacable aprobado;
5. marcarlo como predeterminado y activo;
6. confirmar que existe exactamente un perfil predeterminado por artículo.

No continuar hasta que cada salida de la OF tenga una regla `MANGA` aprobada.
No usar el antiguo procedimiento temporal por API.
## 9. Preparar o elegir la OF

### Opción recomendada

Crear una OF excepcional pequeña con artículos ya existentes:

1. **Producción → Órdenes de fabricación → Nueva OF excepcional**.
2. Usar un número reconocible: `UAT-D-001`.
3. Elegir máquina y molde normalizados.
4. Usar una o dos variantes PiezaColor ya visibles en Ingeniería SCM.
5. Crear un único lote/color con cantidades manejables.
6. Guardar.
7. Abrir la vista de solo lectura y verificar:
   - molde y máquina;
   - snapshot de piezas del molde;
   - PiezaColor de cada salida;
   - cantidades objetivo;
   - receta y materiales si corresponden.

### Opción de contingencia

Puede utilizarse la OF migrada con alias `OP-0084`, pero sus diez salidas requieren perfil de empaque.
Para la primera OT asignar cantidad solamente a una línea y dejar las demás en
cero.

## 10. Crear plan, OT y mangas

1. Abrir **Producción → OT y mangas**.
2. Escribir `ACTOR_COORDINADOR_ID` en **Actor SCM**.
3. Seleccionar la OF UAT.
4. Pulsar **Calcular plan** o **Recalcular plan**.
5. Verificar para cada salida:
   - artículo y PiezaColor correctos;
   - Tipo de manga correcto;
   - capacidad esperada;
   - número de mangas propuesto.
6. En **Asignar**, dejar `0` en salidas no probadas.
7. Asignar a la línea UAT una cantidad que produzca una o dos mangas.
8. Elegir fecha operativa, máquina, turno y Maquinista.
9. Pulsar **Crear OT y mangas**.
10. Pulsar **Iniciar OT**.

Registrar:

| Dato | Valor |
|---|---|
| OF | |
| OT | |
| Fecha operativa | |
| Código manga 1 | |
| Código manga 2 | |

## 11. Inicializar y provisionar la estación

### 11.1. Configuración base

Editar:

`C:\Users\esteb\gitprojects\envaperu-workspace-2\modulo-pesaje\.env`

Valores mínimos:

```dotenv
SCALE_PORT=COM4
SCALE_BAUD_RATE=9600
PRINTER_TYPE=TSPL
PRINTER_NAME=TSC TE200
STATION_CODE=PESAJE-UAT-01
STATION_DATA_ROOT=C:\ProgramData\EnvaPeru\Pesaje-UAT
STATION_MODE=SCM_V2_CONNECTED
STATION_APP_VERSION=1.1.0-pilot
SCM_OPERATOR_ID=<ACTOR_COORDINADOR_ID>
CENTRAL_ORIGIN=http://127.0.0.1:5000
ALLOW_INSECURE_CENTRAL=false
MONITORING_ENABLED=true
SYNC_ENABLED=false
```

`PRINTER_NAME` debe coincidir exactamente con el nombre mostrado por Windows.
Para TSPL se usa el spooler RAW; `PRINTER_PORT` no es la autoridad principal.

La estación `PESAJE-PLANTA-01` ya está reservada y no debe reutilizarse.

### 11.2. Crear identidad local aislada

No usar `start-windows.bat` en esta UAT: su valor predeterminado apunta a la
identidad ordinaria de planta. Iniciar una vez con código y almacenamiento UAT:

```powershell
cd C:\Users\esteb\gitprojects\envaperu-workspace-2\modulo-pesaje
backend\.venv\Scripts\python.exe backend\station_main.py `
  --station-id PESAJE-UAT-01 `
  --data-root C:\ProgramData\EnvaPeru\Pesaje-UAT
```

En otra terminal, detener:

```powershell
backend\.venv\Scripts\python.exe backend\station_control.py stop `
  --station-id PESAJE-UAT-01
```

Consultar identidad:

```powershell
backend\.venv\Scripts\python.exe backend\station_control.py identity `
  --data-root C:\ProgramData\EnvaPeru\Pesaje-UAT
```

Copiar el UUID `station_id`.

### 11.3. Registrar estación en central

En el backend central:

```powershell
cd C:\Users\esteb\gitprojects\envaperu-workspace-2\backend
$env:DATABASE_URL='postgresql+psycopg2://postgres:<PASSWORD_LOCAL_UAT>@localhost/envaperu_test'
.\.venv\Scripts\python.exe -m flask --app run.py provision-weighing-station `
  --station-id <UUID_ESTACION> `
  --code PESAJE-UAT-01 `
  --name "Balanza aislada UAT" `
  --location "Planta - pesaje"
```

Copiar `TOKEN_ONCE` sin incluirlo en evidencia.

### 11.4. Guardar token con DPAPI

En la estación:

```powershell
cd C:\Users\esteb\gitprojects\envaperu-workspace-2\modulo-pesaje
backend\.venv\Scripts\python.exe backend\station_control.py provision-token `
  --data-root C:\ProgramData\EnvaPeru\Pesaje-UAT
```

Pegar el token cuando lo solicite. Debe responder:

```text
STATION_TOKEN_PROVISIONED storage=DPAPI
```

No repetir `provision-weighing-station` con el mismo UUID. Si
`PESAJE-UAT-01` ya fue provisionada y la misma carpeta conserva el token DPAPI,
reutilizarla. Si la carpeta o el token se perdieron, usar un código y carpeta
nuevos, por ejemplo `PESAJE-UAT-02` y `Pesaje-UAT-02`; central no puede revelar
un `TOKEN_ONCE` anterior.

## 12. Arranque y preflight de la estación

```powershell
cd C:\Users\esteb\gitprojects\envaperu-workspace-2\modulo-pesaje
backend\.venv\Scripts\python.exe backend\station_main.py `
  --station-id PESAJE-UAT-01 `
  --data-root C:\ProgramData\EnvaPeru\Pesaje-UAT `
  --open-browser
```

Abrir `http://127.0.0.1:5050`.

Validar:

```powershell
Invoke-RestMethod http://127.0.0.1:5050/api/local/v1/health/live
Invoke-RestMethod http://127.0.0.1:5050/api/local/v1/health/ready
```

Puertas:

- central: `ONLINE`;
- base local: disponible;
- impresora TSC detectada;
- balanza conectada y escuchando;
- `SCM_OPERATOR_ID` corresponde a un trabajador activo con
  `OPERADOR_PESAJE`;
- frontend muestra **Etiquetas SCM** y **Pesaje SCM**.

No ejecutar F2 si alguna puerta falla.

## 13. Imprimir PREPESAJE

En el frontend central:

1. **Producción → OT y mangas**.
2. Seleccionar una o dos mangas.
3. Pulsar **Generar preetiquetas**.
4. Copiar `print_job_id`.

En la estación:

1. Abrir **Etiquetas SCM**.
2. Ingresar el `print_job_id`.
3. Cargar el trabajo.
4. Revisar el preview SVG antes de imprimir.
5. Pulsar imprimir.

### Inspección física

- hoja: 109 × 50 mm;
- dos columnas correctamente alineadas;
- una manga por columna;
- QR a `X + 120`, corrección `L`, módulo `4`;
- preview QR de referencia: 120 × 120 dots;
- texto no cortado;
- `OF/OT`, Maquinista, PiezaColor, Color y Tipo correctos;
- `NORMAL` o `EXTRA` visible;
- QR legible con el lector.

Si se imprimió una sola manga, la segunda columna debe quedar libre.

## 14. Ejecutar el pesaje

1. Entregar la etiqueta PREPESAJE al Maquinista.
2. Colocarla en la manga correspondiente.
3. Llenar la manga con la cantidad planificada.
4. Abrir **Pesaje SCM**.
5. Pulsar **Conectar balanza**.
6. Escanear el QR PREPESAJE.
7. Verificar que la UI resuelva, sin digitación:
   - OF/OT;
   - manga;
   - Maquinista;
   - PiezaColor;
   - color;
   - tipo;
   - cantidad asignada;
   - tara.
8. Colocar la manga completa en la balanza.
9. Esperar lectura estable.
10. Verificar bruto, tara y neto con tres decimales.
11. Pulsar F2 una sola vez.

Resultado esperado:

1. central confirma el pesaje;
2. la estación no crea un `Pesaje` legacy;
3. se genera e imprime POSTPESAJE;
4. la etiqueta contiene `KG FIS.` y `KG OT`;
5. la manga queda `PENDIENTE_RECEPCION_ALMACEN`;
6. no se crea inventario ni Kardex.

## 15. Verificación central

En **Producción → OT y mangas**:

1. actualizar;
2. ubicar la manga pesada;
3. pulsar **Ver pesaje**;
4. verificar:
   - captura Original;
   - proyección Vigente;
   - bruto, tara y neto;
   - cantidad confirmada;
   - kg atribuibles a la OT;
   - `estado_inventario=NO_INGRESADA`;
   - historial de etiquetas.

El peso físico y los kg de la OT pueden diferir. No corregir esa diferencia
automáticamente: representan magnitudes distintas.

## 16. Casos de aceptación

### UAT-D-01 — Recorrido feliz

- QR PREPESAJE resuelve la manga correcta.
- F2 acepta una lectura estable.
- Existe un solo pesaje central.
- POSTPESAJE se imprime con pesos correctos.
- Manga queda pendiente de almacén.

### UAT-D-02 — Central no disponible

1. Con una manga aún no pesada, detener temporalmente la API central.
2. Escanear o intentar F2.
3. Confirmar que F2 queda bloqueado.
4. Confirmar que no existe pesaje SCM local.
5. Reiniciar central y repetir normalmente.

### UAT-D-03 — Doble acción o respuesta perdida

- Pulsar F2 no debe quedar disponible durante el envío.
- Un reintento con la misma operación devuelve el mismo resultado.
- No aparece una segunda fila de pesaje ni otra manga.

### UAT-D-04 — QR inválido

- Un QR legacy separado por `;` debe ser rechazado.
- Una etiqueta invalidada debe indicar la identidad vigente.
- Un QR POSTPESAJE no puede iniciar otro pesaje.

### UAT-D-05 — Corrección con cuatro ojos

1. En **Ver pesaje**, usar el Coordinador para solicitar una corrección.
2. Escribir valores propuestos y motivo.
3. Intentar aprobar con el mismo actor: debe rechazarse.
4. Cambiar **Actor SCM** al JP.
5. Aprobar.
6. Confirmar:
   - Original no cambió;
   - Vigente refleja la corrección;
   - etiqueta anterior quedó invalidada;
   - se generó nueva POSTPESAJE;
   - no se creó Kardex.

### UAT-D-06 — Reemplazo de etiqueta

- No usar una acción de “reimprimir”.
- Registrar motivo de daño o emisión incierta.
- Generar nueva identidad/version de etiqueta.
- La etiqueta anterior permanece como evidencia invalidada.

### UAT-D-07 — Manga extra

1. Solicitar una cantidad fuera del plan con motivo.
2. El mismo actor no puede autoaprobar.
3. Aprobar con JP.
4. La manga creada debe mostrar `EXTRA` de forma visible.

### UAT-D-08 — Fecha operativa

- Pesaje el mismo día: normal.
- Pesaje al día siguiente: pertenece a la fecha de OT.
- Más de un día: debe generar alerta.
- Nunca agrupar el avance por la fecha física en lugar de la fecha de OT.

### UAT-D-09 — Anulación controlada antes de Almacén

1. Pesar una manga normal y no recibirla en Almacén.
2. Abrir **Ver pesaje → Anular pesaje** con `JEFE_PRODUCCION`.
3. Ingresar motivo y evidencia.
4. Confirmar que Original permanece, Vigente desaparece y la manga queda
   `ANULADA`.
5. Confirmar que todos sus QR quedan `INVALIDADA`.
6. Confirmar que el cupo y una manga se devuelven al plan.
7. Repetir la misma operación técnica: no debe duplicar la anulación.
8. Crear una manga de reemplazo y confirmar que es `NORMAL`, no `EXTRA`.
9. Generar PREPESAJE nueva y pesar normalmente el reemplazo.

### UAT-D-10 — Anulación después de recepción

1. Recibir otra manga pesada mediante TS-010I.
2. Intentar anular el pesaje.
3. Debe responder `RECEIPT_REVERSAL_REQUIRED` sin modificar manga, QR ni cupo.
4. Como `ALMACEN_RECEPCION`, solicitar reversa con motivo y evidencia.
5. Intentar aprobar con el mismo actor: debe rechazarse por segregación.
6. Aprobar con un `JEFE_PRODUCCION` distinto.
7. Confirmar existencia `REVERSADA`, movimiento compensatorio y manga nuevamente
   `PENDIENTE_RECEPCION_ALMACEN`.
8. Anular el pesaje y confirmar cupo devuelto, QR inválidos y reemplazo normal.

La reversa debe bloquearse con `EXISTENCIA_COMPROMETIDA` si la existencia tiene
reservas o ya no es reversible. No corregir ese estado mediante SQL.

### UAT-D-11 — Eliminación directa y Excel

- Probar eliminación individual y masiva con perfiles distintos: ambas deben
  responder `403 DESTRUCTIVE_MUTATION_DISABLED`.
- Exportar Excel y confirmar que los históricos anulados aparecen como
  `BORRADO / ANULADO`.
- Confirmar que no suman producción válida.

### UAT-D-12 — Conciliación de stickers 11213–11216

1. Localizar los IDs 11213, 11214, 11215 y 11216 en el Excel.
2. Confirmar estado `BORRADO / ANULADO` y exclusión de totales válidos.
3. Conciliar cada sticker con el conteo físico del incidente.
4. Conservar foto/acta sin compartir el QR completo fuera del equipo.
5. Registrar diferencias como incidente; no alterar registros con DELETE.
## 17. Evidencias

Crear una carpeta por ejecución:

```text
UAT-TS010D-AAAA-MM-DD/
  01-preflight-central.png
  02-health-estacion.json
  03-plan-mangas.png
  04-ot-y-codigos.png
  05-preview-prepesaje.svg
  06-foto-prepesaje.jpg
  07-contexto-qr.png
  08-lectura-estable.png
  09-foto-postpesaje.jpg
  10-original-vigente.png
  11-correccion-cuatro-ojos.png
  12-anulacion-y-cupo.png
  13-reemplazo-normal.png
  14-reversa-almacen.png
  15-conciliacion-11213-11216.md
  16-resultados.md
```

No incluir token ni QR completo en evidencias compartidas fuera del equipo.

### Acta resumida

| Caso | Resultado | Evidencia | Observación |
|---|---|---|---|
| UAT-D-01 | PENDIENTE | | |
| UAT-D-02 | PENDIENTE | | |
| UAT-D-03 | PENDIENTE | | |
| UAT-D-04 | PENDIENTE | | |
| UAT-D-05 | PENDIENTE | | |
| UAT-D-06 | PENDIENTE | | |
| UAT-D-07 | PENDIENTE | | |
| UAT-D-08 | PENDIENTE | | |
| UAT-D-09 | PENDIENTE | | |
| UAT-D-10 | PENDIENTE | | |
| UAT-D-11 | PENDIENTE | | |
| UAT-D-12 / 11213–11216 | PENDIENTE | | |

## 18. Criterio de aprobación

La UAT queda aprobada cuando:

- UAT-D-01 a UAT-D-06 y UAT-D-09 a UAT-D-12 pasan;
- D-07 y D-08 pasan o quedan diferidos con aceptación explícita;
- la anulación devuelve exactamente el cupo y permite una manga normal;
- la anulación posterior a Almacén exige una reversa segregada;
- la eliminación directa está bloqueada para todos los perfiles;
- ambos QR se leen en el primer intento;
- ninguna columna queda recortada;
- no existe doble pesaje;
- central caída bloquea F2;
- pesaje original permanece inmutable;
- corrección y reemplazo cumplen cuatro ojos;
- no nace Kardex antes de almacén;
- Producción acepta nombres, tamaños y secuencia operativa.

Un defecto de dimensiones, QR, duplicidad, identidad o persistencia central es
bloqueante. Una mejora puramente estética puede registrarse sin repetir todo el
recorrido.

## 19. Cierre seguro

Detener la estación:

```powershell
cd C:\Users\esteb\gitprojects\envaperu-workspace-2\modulo-pesaje
backend\.venv\Scripts\python.exe backend\station_control.py stop `
  --station-id PESAJE-UAT-01
```

Detener Vite y Flask con `Ctrl+C` en sus terminales.

No borrar los registros UAT. Si debe repetirse una manga, anularla con motivo o
crear una nueva según la regla funcional.

## 20. Problemas frecuentes

| Síntoma | Verificación |
|---|---|
| `Central sin conexión` | API en 5000, token DPAPI, UUID, `CENTRAL_ORIGIN`, versión mínima. |
| `AUTH_ERROR` | Token no coincide; no volver a provisionar el mismo UUID. |
| `CENTRAL_INCOMPATIBLE` | `STATION_APP_VERSION` inferior a la mínima central. |
| No aparece plan | Falta artículo SCM, perfil predeterminado o regla aprobada. |
| No deja aprobar regla/corrección | Solicitante y aprobador son iguales o faltan capacidades. |
| No conecta balanza | Revisar `SCALE_PORT`, baudios, cable y uso exclusivo del COM. |
| No imprime | Revisar nombre exacto TSC en Windows y spooler RAW. |
| QR no resuelve | Confirmar que sea PREPESAJE vigente y no un QR legacy. |
| F2 deshabilitado | Central offline, balanza no escuchando, lectura inestable o contexto inválido. |
| POSTPESAJE falló | El pesaje central se conserva; recuperar operación y generar reemplazo. |
