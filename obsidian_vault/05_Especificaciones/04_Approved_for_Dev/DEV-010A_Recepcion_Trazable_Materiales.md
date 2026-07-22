---
tipo: approved-for-dev
estado: en-desarrollo
tags: [scm, recepcion, materiales, inventario, calidad, roles, tdd, postgresql]
user_story: "[[US-010A_Recepcion_Trazable_Materiales]]"
tech_spec: "[[TS-010A_Recepcion_Trazable_Materiales]]"
fecha_aprobacion: 2026-07-21
---

# DEV-010A: Recepción Trazable de Materiales

## 1. Decisión de Aprobación

El 2026-07-21 el usuario responsable aprobó [[TS-010A_Recepcion_Trazable_Materiales]] para desarrollo. Esta nota es la entrada operativa del ciclo TDD y no sustituye los contratos, invariantes ni escenarios `REC-01` a `REC-46` de la US y la TS.

La aprobación autoriza cambios locales en backend, frontend, pruebas y migraciones del workspace. No autoriza escribir en la base de datos desplegada ni habilitar el flujo en producción.

## 2. Referencias Obligatorias

- Historia: [[US-010A_Recepcion_Trazable_Materiales]].
- Diseño técnico: [[TS-010A_Recepcion_Trazable_Materiales]].
- Validación de planta: [[Validacion_Operativa_US-010A]].
- Vista funcional: [[Vista_US-010A_Recepcion_Materiales]].
- Identidad diferida: [[2026-07-17_Autenticacion_Humana_Diferida_Hasta_Cierre_Funcional]].
- Línea base: [[TE-001_Infraestructura_TDD_Reproducible]].

## 3. Alcance de Implementación

- [ ] Backend: módulo `/api/scm/v1`, modelos, servicios transaccionales, validaciones y errores de dominio.
- [ ] Persistencia: migraciones Alembic aditivas, catálogos SCM, OC, recepciones, lotes, saldos, movimientos, eventos y evidencias.
- [ ] Frontend: reemplazar `MOCK_LOCAL` por adaptador HTTP manteniendo mocks únicamente para pruebas y demostraciones aisladas.
- [ ] Calidad e inventario: decisiones totales/parciales, ubicaciones, retenciones, correcciones y devoluciones append-only.
- [ ] Seguridad: capacidades server-side y segregación de funciones.
- [ ] Pruebas: mapa `REC-01` a `REC-46`, integración PostgreSQL y un E2E principal.

Quedan fuera reserva, premezcla y consumo por OP; pertenecen a US-010B y posteriores.

## 4. Roles, Capacidades y Usuarios

El desarrollo de US-010A debe crear la infraestructura de roles y capacidades, aunque la asignación final a usuarios humanos ocurra al terminar el desarrollo.

Capacidades mínimas sembradas:

- `PROVEEDOR_ADMINISTRAR`;
- `OC_CREAR`;
- `OC_APROBAR`;
- `RECEPCION_CONFIRMAR`;
- `ENTRADA_EXCEPCIONAL_REGULARIZAR`;
- `CALIDAD_RESOLVER`;
- `LIBERACION_DIRECTA_ADMINISTRAR`;
- `CORRECCION_SOLICITAR`;
- `CORRECCION_APROBAR`;
- `DEVOLUCION_REGISTRAR`;
- `CONFIG_RECEPCION_ADMINISTRAR`.

Reglas obligatorias:

1. Crear `scm_capacidad` y la relación N:M entre `RolOperativo` y capacidad.
2. Derivar permisos exclusivamente en el servidor; nunca aceptar rol o capacidad desde el body del frontend.
3. Sembrar roles funcionales iniciales como configuración revisable: Compras, Almacén/Recepción, Calidad, Gerencia, Configuración SCM y Auditoría/Consulta.
4. Mantener las segregaciones: creador de OC distinto del aprobador; solicitante de corrección distinto del aprobador; devolución ejecutada por actor distinto de quien decidió Calidad.
5. Durante desarrollo/UAT controlado, `X-Actor-Id` puede identificar un `Trabajador` validado server-side.
6. Al cierre del desarrollo se asignarán roles y capacidades a usuarios humanos reales y se validarán suplencias.
7. Antes de producción multiusuario deben existir autenticación, sesión, autorización server-side y pruebas de acceso negativo. Sin esa puerta el módulo permanece limitado a entornos controlados.

## 5. Secuencia de Desarrollo

### Fase 0 — Consolidar línea base

- [ ] Consolidar el refactor frontend actual en Git sin mezclar cambios ajenos.
- [x] Ejecutar backend rápido, frontend completo y módulo de pesaje; registrar intermitencias preexistentes.
- [x] Ejecutar el harness PostgreSQL y dejarlo verde antes del primer merge que escriba inventario.

### Fase 1 — RED de autoridad de cantidad

- [x] Crear primero la prueba `REC-44`: virgen, `200 x 25 kg`, documento `5,000.000 kg`, conteo coincidente, resultado documental y peso interno `NO_MEDIDO`.
- [x] Verificar que falle porque el motor y sus tipos aún no existen.
- [x] Implementar funciones puras con `Decimal` y repetir `RED -> GREEN -> REFACTOR` para las modalidades y discrepancias.

### Fase 2 — Migración y catálogos

- [x] Inicializar Flask-Migrate/Alembic en `create_app()`.
- [x] Crear una migración aditiva versionada para US-010A.
- [ ] Retirar `db.create_all()` y scripts ad hoc como mecanismos productivos después de validar la adopción Alembic sobre una copia restaurada.
- [ ] Introducir material común, proveedores, roles, capacidades, ubicaciones, motivos, políticas y evidencias.
- [x] Migrar las referencias legacy de material ya cubiertas sin inventar categorías ambiguas; dejarlas `POR_CONFIGURAR` y no recibibles.

### Fase 3 — Compras y recepción

- [x] Implementar OC versionada, aprobación distinta del creador y saldos derivados provisionales hasta existir imputaciones.
- [ ] Implementar borrador, rechazo previo y confirmación idempotente.
- [ ] Crear lote, evento, movimiento y saldo en una sola transacción PostgreSQL.
- [ ] Probar reintentos, conflicto de clave idempotente, concurrencia y rollback.

### Fase 4 — Calidad, movimientos y excepciones

- [ ] Implementar decisiones parciales de Calidad conservando el total físico.
- [ ] Implementar retención documental y regularización independiente de Calidad.
- [ ] Implementar correcciones compensatorias aprobadas por Gerencia.
- [ ] Implementar devoluciones sin reescribir la recepción histórica.

### Fase 5 — Integración frontend

- [ ] Crear adaptador HTTP y estados de carga, vacío, error, conflicto `409` e idempotencia.
- [ ] Conectar gradualmente las vistas refactorizadas sin perder el mock de tests.
- [ ] Habilitar acciones según capacidades recibidas del servidor.
- [ ] Mantener separados cantidad física, disponible, retención, Calidad y ubicación.

### Fase 6 — Cierre, permisos y UAT

- [ ] Completar materiales, ubicaciones, balanza, motivos y políticas reales.
- [ ] Asignar roles/capacidades a usuarios humanos y suplentes autorizados.
- [ ] Probar accesos permitidos y denegados con identidades reales de UAT.
- [ ] Definir el plazo de conservación de adjuntos y validar el límite piloto de 10 MiB.
- [ ] Recorrer un caso real anonimizado con Compras, Almacén, Calidad y Gerencia.
- [ ] Habilitar `SCM_RECEPCION_ENABLED` solo después de PostgreSQL verde, UAT y autorización de despliegue.

## 6. Gates que no Deben Omitirse

- [ ] Ninguna cantidad persistente usa `Float`.
- [ ] Ninguna recepción confirmada se modifica o elimina destructivamente.
- [ ] Ningún reintento duplica inventario, eventos o devoluciones.
- [ ] Ningún permiso depende únicamente de la interfaz.
- [ ] Ninguna guía o factura externa se trata como aprobación interna de compra.
- [ ] Ningún lote externo ausente se inventa.
- [ ] Ningún umbral de recepción reutiliza la tolerancia legacy de pesaje de producción.
- [ ] Ninguna prueba de integración crítica sustituye PostgreSQL por SQLite.

## 7. Definición de Terminado

DEV-010A termina únicamente cuando los escenarios aceptados poseen pruebas en el nivel definido, el flujo principal E2E está verde, la trazabilidad puede consultarse hacia atrás y adelante, las migraciones son reproducibles, el frontend opera contra la API, los roles/capacidades existen y la asignación final de permisos a usuarios queda completada o bloquea explícitamente cualquier despliegue multiusuario.

## 8. Registro de Ejecución

### 2026-07-21 — Incremento 1: autoridad de cantidad

- Línea base backend previa: `103 passed`, `1 skipped`, `3 deselected`.
- La primera ejecución de `REC-44` produjo el RED esperado: `ModuleNotFoundError: No module named 'app.domain'`.
- Se creó `app.domain.scm.quantity_authority`, puro e independiente de Flask/SQLAlchemy.
- Virgen con conteo coincidente conserva fuente `DOCUMENTO_PROVEEDOR`, cantidad aceptada documental, `NO_MEDIDO` y medición `None`.
- Segunda exige un peso positivo por bolsa, suma con `Decimal`, usa fuente `PESAJE_INTERNO_BOLSAS` y conserva diferencia `SIN_POLITICA`.
- Una discrepancia de conteo de virgen devuelve el error de dominio `VIRGIN_BAG_COUNT_DECISION_REQUIRED`; no se acepta silenciosamente.
- Pruebas nuevas de dominio: `8 passed`, cubriendo `REC-44`, `REC-45`, límites de `REC-05` y guardas de modalidad.
- Regresión backend posterior: `111 passed`, `1 skipped`, `3 deselected`.
- Módulo de pesaje: `85 passed`; fue necesario dirigir `basetemp` a una carpeta del workspace por restricciones del temporal del sistema.
- Frontend vigente: build verde; `12/12` pruebas US-010A verdes. La suite global había mostrado un timeout legacy que pasó de forma aislada y no pertenece a US-010A.
- PostgreSQL local: se creó únicamente `envaperu_test` con las credenciales proporcionadas y el harness pasó (`1 passed`); no se consultaron ni modificaron bases de aplicación.
- Docker Desktop 4.83.0 quedó instalado por usuario con WSL 2; motor 29.6.2 y Compose 5.3.1.
- Harness Docker: `postgres:16-alpine` levantó saludable, la prueba PostgreSQL pasó (`1 passed`) y Compose eliminó contenedor, volumen y red al terminar.
- `scripts/test.ps1` resuelve ahora tanto Docker en `PATH` como la instalación recomendada por usuario.

El siguiente incremento debe preparar Flask-Migrate/Alembic y el modelo común de catálogos/roles sin habilitar todavía escritura de inventario. El harness PostgreSQL debe seguir verde en cada incremento que escriba inventario.

### 2026-07-21 — Incremento 2: baseline, material común y autorización

- El RED de catálogo falló inicialmente con `ModuleNotFoundError: No module named 'app.models.scm_catalogos'`.
- `create_app()` inicializa Flask-Migrate y mantiene `SCM_RECEPCION_ENABLED=false`; todavía no se habilitó ninguna escritura de recepción o inventario.
- Se creó una línea base Alembic reproducible del esquema legacy de 44 tablas para bases nuevas y una segunda revisión exclusivamente aditiva para US-010A.
- La revisión US-010A crea `scm_categoria_recepcion`, `scm_material`, `scm_capacidad` y `scm_rol_capacidad`, con constraints nombrados y `String + CheckConstraint`.
- PostgreSQL impide que una identidad común de clase `MATERIA_PRIMA` se vincule como `Colorante`, o viceversa, y bloquea cambiar la clase de una identidad ya enlazada.
- El backfill genera una identidad común estable por cada `MateriaPrima` y `Colorante`. Solo `trim/upper(tipo)=VIRGEN|SEGUNDA` se clasifica automáticamente; `MOLIDO`, nulos y colorantes quedan en `LEGACY_POR_CONFIGURAR`, no recibible.
- La migración valida que ninguna fila legacy existente quede huérfana. Las columnas `scm_material_id` permanecen temporalmente nullable como fase expand para no romper los escritores legacy; después de introducir dual-write se añadirá la revisión contract que las vuelva `NOT NULL`.
- Se sembraron las 11 capacidades aprobadas y los roles configurables `COMPRAS`, `ALMACEN_RECEPCION`, `CALIDAD`, `GERENCIA`, `SUPERVISOR`, `CONFIGURACION_SCM` y `AUDITORIA_CONSULTA`. Se reutiliza el código legacy `SUPERVISOR` para la regularización excepcional y se evita crear un rol duplicado. La migración no agrega capacidades a un rol homónimo que ya esté asignado a trabajadores; ese caso queda para la configuración final de UAT.
- El seed `seed-scm-config` es repetible, no reactiva capacidades, no repone relaciones retiradas ni sobrescribe nombres configurados. No crea ni asigna trabajadores.
- `Trabajador.capacidades_efectivas` deriva permisos solamente de trabajador, rol y capacidad activos; no existe autorización por roles enviados desde el frontend.
- Las pruebas PostgreSQL crean esquemas únicos dentro de `envaperu_test`, prueban instalación nueva, `db check` sin drift, adopción legacy mediante `stamp`, backfill, unicidad, rollback a baseline, conservación de filas y re-upgrade.
- La línea base es irreversible por diseño: intentar cruzarla con `downgrade base` falla antes de borrar tablas. El rollback permitido de 010A se detiene en `f02b00ae2e67`.
- El fixture de adopción usa DDL legacy mínimo congelado e independiente de Alembic. La compatibilidad con el despliegue real sigue bloqueada hasta comparar un restore anonimizado de esa base.
- Gate oficial: backend rápido `116 passed`, `1 skipped`, `5 deselected`; perfil PostgreSQL `3 passed`, `1 skipped`, `118 deselected`. Compose retiró contenedor, volumen temporal y red al finalizar.
- No se consultó ni modificó la base desplegada. La adopción real exige restaurar antes un backup aislado, compararlo con la línea base y obtener autorización separada.

Pendientes explícitos antes de cerrar Fase 2:

1. adaptar todos los escritores legacy de `MateriaPrima` y `Colorante` para crear `scm_material` en la misma transacción y luego aplicar `NOT NULL`;
2. completar proveedores, ubicaciones, motivos, políticas y evidencias;
3. definir una capacidad estable de consulta para Auditoría y la capacidad exacta que autorizará la decisión de discrepancia de conteo virgen;
4. resolver `Colorante.tipo=COLORANTE|ADITIVO` dentro de US-006 sin inferirlo por nombre;
5. sustituir los bootstrap productivos restantes basados en `db.create_all()` solo cuando la adopción Alembic de una copia restaurada haya sido validada.

### 2026-07-21 — Incremento 3: dual-write y cierre de identidad material

- El RED del servicio transaccional falló primero con `ModuleNotFoundError: No module named 'app.services.scm_material_service'`.
- Se incorporó un servicio único para crear o completar `MateriaPrima`/`Colorante` y `ScmMaterial` dentro de la misma transacción. El servicio no hace `commit`; el llamador conserva control total de `commit` y `rollback`.
- Las altas nuevas reciben códigos técnicos inmutables `MP-AUTO-{UUID}` o `COL-AUTO-{UUID}`. No se derivan del nombre ni se adopta todavía una numeración visible definitiva.
- Se adaptaron la ruta legacy de creación de OP, `crear_tablas.py` y todos los fixtures que escribían materiales directamente. La OP conserva compatibilidad con nombres libres, pero toda identidad aprendida de ese flujo queda en `LEGACY_POR_CONFIGURAR`, no recibible; el CRUD SCM posterior deberá exigir clasificación explícita.
- La clasificación automática controlada reconoce solamente `trim/upper(tipo)=VIRGEN|SEGUNDA`. `MOLIDO`, valores ambiguos y todos los colorantes permanecen en `LEGACY_POR_CONFIGURAR`.
- `Colorante.tipo=COLORANTE|ADITIVO` continúa diferido a US-006. No bloquea la identidad común obligatoria y no se infiere por el nombre.
- La revisión contract `58b3dd5878cd` reconverge filas creadas durante la ventana expand, aborta transaccionalmente ante colisiones de códigos reservados y vuelve `scm_material_id` `NOT NULL` tanto en `materia_prima` como en `colorante`.
- La migración bloquea catálogos en orden de dependencia para evitar deadlocks y soporta IDs mayores de ocho dígitos sin truncar sus códigos. Para aplicarla se deben pausar todas las altas de materiales, además de drenar instancias antiguas.
- El downgrade de la revisión contract solo vuelve las columnas nullable; conserva materiales, códigos y vínculos. Un re-upgrade reconverge nuevas filas y no duplica las existentes.
- Las pruebas PostgreSQL cubren instalación completa y `db check`, adopción legacy, huérfanos tardíos, colisión con rollback atómico, `NOT NULL`, downgrade preservador, re-upgrade idempotente y todas las restricciones de clase/clave.
- Gate oficial backend: `120 passed`, `1 skipped`, `5 deselected`. Gate PostgreSQL: `3 passed`, `1 skipped`, `122 deselected` tanto sobre PostgreSQL 18 local como en el arnés Docker descartable; Compose eliminó contenedor, red y volumen al terminar.
- `SCM_RECEPCION_ENABLED` permanece apagado. No se consultó ni modificó la base desplegada.

Pendientes explícitos después del incremento 3:

1. completar proveedores, ubicaciones, motivos, políticas y tipos de evidencia;
2. implementar OC versionada, aprobación segregada y el primer corte de `/api/scm/v1`;
3. definir una capacidad estable de consulta para Auditoría y la capacidad exacta de discrepancia de conteo virgen;
4. validar la cadena Alembic contra un restore anonimizado antes de cualquier adopción real;
5. sustituir bootstrap productivo restante y asignar capacidades a usuarios humanos solamente en el cierre/UAT autorizado.

### 2026-07-21 — Incremento 4: proveedor, OC versionada y CRUD técnico de materiales

- La revisión `23a5f8a99a0b` agregó `scm_proveedor`, `scm_orden_compra`, `scm_orden_compra_revision`, `scm_orden_compra_linea`, `scm_operacion` y `scm_evento`. Usa `Numeric(15,3)`, FKs `RESTRICT`, constraints nombrados e índices parciales para una sola revisión abierta y una sola aprobada por OC. Un trigger PostgreSQL impide mutar líneas cuando su revisión ya no es `BORRADOR`.
- El downgrade de ese corte sólo procede con las seis tablas vacías; si existe cualquier dato aborta antes de destruir objetos. PostgreSQL impide `UPDATE` o `DELETE` sobre `scm_evento`.
- Se implementó CRUD lógico de proveedor con código estable, RUC normalizado, versión optimista, baja lógica, capacidades server-side y evento con snapshot de actor.
- La OC crea revisiones, permite reemplazar atómicamente las líneas de una revisión `BORRADOR`, envía a aprobación y exige un aprobador de Gerencia distinto del creador. Una nueva revisión clona la anterior y sólo supera la aprobada al aprobarse la nueva.
- Enviar y aprobar reservan `scm_operacion` por UUID/hash: el mismo request reproduce la respuesta y una reutilización distinta devuelve `409 IDEMPOTENCY_CONFLICT`. Configuración y borradores registran evento, pero no exigen operación idempotente del cliente.
- Proveedor, material y categoría se validan al enviar y se revalidan al aprobar. Una línea con material `POR_CONFIGURAR` puede conservarse en borrador, pero no avanzar a aprobación.
- Los saldos HTTP se derivan como autorizado menos `0.000` recibido hasta que exista la imputación real de recepciones; no se persiste un saldo ficticio editable.
- El RED de categorías/materiales produjo `3 failed in 0.66s`, todos por las rutas aún inexistentes. El GREEN añadió `GET/POST/PATCH` para categorías y materiales bajo `/api/scm/v1`, con `CONFIG_RECEPCION_ADMINISTRAR`, versión optimista, códigos/clase/unidad inmutables y baja lógica.
- Crear o renombrar un material sincroniza `scm_material` y su fila `MateriaPrima`/`Colorante` dentro de la misma transacción. `MateriaPrima.tipo` refleja la modalidad de la categoría; no se infiere por el nombre. Una prueba de fallo posterior al `flush` demuestra rollback de ambas identidades y del evento.
- El RED adicional de edición de revisión produjo `1 failed` por `404`; el GREEN incorporó `PATCH /ordenes-compra-material/{id}/revisiones/{numero}`, doble versión optimista, reemplazo completo de líneas y bloqueo fuera de `BORRADOR`.
- Se endurecieron los contratos JSON: tipos textuales/enteros reales, allowlists de campos, rechazo de typos y de PATCH sin cambio. Los timestamps SCM se serializan siempre en UTC aun cuando SQLite devuelva datetimes sin zona.
- `SCM_RECEPCION_ENABLED` permanece apagado. No se creó recepción, lote, movimiento ni saldo y no se consultó ni modificó ninguna base desplegada.
- Gate backend rápido: `131 passed`, `1 skipped`, `6 deselected`. Gate SCM: `26 passed`, `3 deselected`. Gate PostgreSQL local aislado: `4 passed`, `1 skipped`, `133 deselected`; Alembic conserva un único head `23a5f8a99a0b` y `git diff --check` no reportó errores.
- El arnés oficial PostgreSQL 16 en Docker no llegó a iniciarse en esta repetición porque el entorno Codex rechazó la elevación por cuota de ejecución. Los arneses Docker de incrementos anteriores sí habían quedado verdes y limpios; este gate permanece pendiente y no se registra como fallo de producto.

Pendientes explícitos después del incremento 4:

1. documentos externos, adjuntos, tipos/requisitos de evidencia y resolución de su cardinalidad N:M;
2. ubicaciones, motivos y políticas de tolerancia/liberación directa;
3. borrador/confirmación/rechazo de recepción, pesaje por bolsa, imputaciones y lotes internos;
4. inventario, Calidad, retenciones, correcciones, devoluciones y trazabilidad;
5. adaptador HTTP del frontend, fingerprint contra restore anonimizado y asignación final de permisos en UAT.

### 2026-07-21 — Incremento 5: documentos compartidos y borrador pesado por bolsa

- Se cerró la cardinalidad pendiente: una guía o factura puede cubrir varias recepciones físicas parciales. `scm_documento_proveedor` conserva una sola identidad externa y `scm_recepcion_documento` implementa la relación N:M sin FK exclusiva a una recepción.
- Se cerró la decisión de almacenamiento para material de segunda: cada bolsa será una unidad física trazable, pesada una vez al recibirla y etiquetada al confirmar. El peso de recepción quedará congelado; una mezcla posterior heredará el conjunto de proveedores/lotes candidatos desde las bolsas consumidas.
- La revisión `7c1e4a9d2b6f` agregó documento externo, recepción borrador, vínculo N:M, línea y pesaje individual. También agregó `DOCUMENTO_PROVEEDOR_REGISTRAR` a Compras y Almacén/Recepción sin asignar personas concretas.
- Se implementó CRUD versionado de `/documentos-proveedor` y creación/consulta/edición de `/recepciones/materiales`. El servidor deriva la modalidad desde el material: virgen rechaza pesajes internos y segunda exige exactamente una secuencia continua y un peso positivo por bolsa.
- La edición reemplaza documentos, líneas y pesajes sólo mientras la recepción está `BORRADOR`, exige versión optimista, rechaza no-op y genera eventos con snapshot del actor. PostgreSQL añade un trigger que impide mutar documentos, líneas o pesajes cuando la recepción deja de ser borrador.
- El mismo documento se probó enlazado a dos recepciones distintas. También se verificaron rollback por conteo de bolsas inconsistente, prohibición de repesaje de virgen, identidad externa única, permisos y conflictos de versión.
- Este corte persiste borradores y pesajes, pero deliberadamente no crea todavía custodia, lote, unidad de almacenamiento, sticker, movimiento ni saldo. Esos efectos pertenecerán a la confirmación idempotente y `SCM_RECEPCION_ENABLED` permanece apagado.
- Gate backend aislado: `135 passed`, `1 skipped`, `5 deselected`; se excluyeron 2 pruebas live-server que requieren un Flask externo en `127.0.0.1:5000`. Gate SCM: `30 passed`, `4 deselected`. Gate PostgreSQL local aislado: `4 passed`. Alembic conserva un único head `7c1e4a9d2b6f`; `git diff --check` sólo reportó advertencias de conversión LF/CRLF ya esperadas.
- Ninguna prueba consultó o modificó la base desplegada. PostgreSQL creó y eliminó un esquema aislado por prueba dentro de `envaperu_test`.

Pendientes explícitos después del incremento 5:

1. confirmación idempotente con imputación a OC, lote interno, ubicación inicial y una unidad de almacenamiento/sticker por pesaje de segunda;
2. adjuntos, tipos/requisitos de evidencia, motivos y políticas de tolerancia/liberación;
3. saldo/movimiento, Calidad, retenciones, correcciones, devoluciones y trazabilidad de bolsas;
4. adaptador HTTP y pantalla de impresión/reimpresión de stickers;
5. fingerprint contra restore anonimizado y asignación final de permisos humanos en UAT.
