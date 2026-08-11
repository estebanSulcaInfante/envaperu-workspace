---
tipo: approved-for-dev
estado: implementado-local-pendiente-uat
historia: "[[../02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
tech_specs:
  - "[[../03_Tech_Specs/TS-017A_Sesion_Durable_y_Shell_de_Alta_Guiada]]"
  - "[[../03_Tech_Specs/TS-017B_Configuracion_Fisica_Formulaciones_y_UX_Premium]]"
  - "[[../03_Tech_Specs/TS-017C_Ingenieria_Readiness_y_Publicacion_Guiada]]"
fecha_aprobacion: 2026-08-10
fecha_actualizacion: 2026-08-10
---

# DEV-017: Alta guiada integral de Producto Terminado

## Estado

**Implementado localmente; migraciones, despliegue y UAT humana pendientes.**

Esta evidencia aprueba el gate técnico local. No autoriza aplicar migraciones en
Supabase/Render, cargar datos productivos ni marcar la UAT como aprobada.

## Alcance implementado

- sesión durable, versionada, reanudable y con ownership;
- seis fases canónicas: IDENTIDAD, COMPONENTES, COLORES, ESTRUCTURA,
  RUTA_EMPAQUE y REVISION;
- alta contextual Línea → Familia atómica, incluida reactivación;
- materialización idempotente de PT, Molde, Piezas, PiezaColor y formulaciones;
- clasificación comercial autoritativa en PT; Pieza/PiezaColor técnicas sin copia
  obligatoria de Línea/Familia;
- retry `PARTIAL` por unidad, con referencias resueltas bloqueadas;
- editores compartidos de BOM, ruta y empaque;
- WIP contextual dentro de la misma unidad de trabajo de ESTRUCTURA;
- empaque exacto por cada salida única de ruta;
- aplicación C atómica, sin commits internos ni maestros huérfanos;
- reaplicación C explícita con `supersedes_application_key`;
- readiness canónico `BLOCKED|PENDING_APPROVAL|READY` y BOM/WIP recursiva;
- confirmación REVISION ligada a `{tipo,id,version,content_hash}` para evitar
  cierre con contenido cambiado;
- finalizar no crea OP, OF, OA, OT ni movimientos de inventario;
- imágenes multipart PT/PiezaColor, idempotentes, sin base64 y limitadas al
  scope de la sesión;
- almacenamiento S3 content-addressed por SHA-256 y compensación ante rollback;
- validación real JPEG/PNG/WEBP, 2 MB y 25 millones de píxeles;
- experiencia responsive con autosave, Back/Forward seguro, estados finales
  read-only, matriz Pieza×Color y asistente opcional con reduced-motion.

## Migraciones

- `f81d0e6f2b53`: sesión durable de alta de producto, RLS y grants restrictivos;
- `f82e1f7a3c64`: PiezaColor admite clasificación técnica nula;
- head único local: `f82e1f7a3c64`.

Las pruebas PostgreSQL aisladas están escritas, pero sus 18 casos quedaron
omitidos porque no existe `TEST_DATABASE_URL`. No se ejecutó una migración real
contra una base compartida o remota.

## Evidencia automática

- backend full default: **408 passed**, 1 skipped OCR, 22 deselected
  PostgreSQL/E2E, 0 fallos;
- backend focal agregado TS-017: **117/117**;
- frontend full: **67 archivos, 362/362 pruebas**;
- frontend focal de alta/editores: **51/51**, más 13/13 de regresión compartida;
- accesibilidad focal: teclado, Shift+Tab, Enter, `aria-current`, foco visible y
  asistente sin robo de foco; axe queda como UAT manual porque no está instalado;
- `npm run lint`: verde;
- `npm run build`: verde, con el warning conocido de chunk mayor a 500 kB;
- `compileall`, Alembic head y `git diff --check`: verdes.

## Smoke local

- ruta canónica visible desde Datos maestros;
- hero, progreso de seis fases, bloqueo de prerequisitos y asistente Luma
  verificados en navegador local;
- IDENTIDAD muestra fuente obligatoria, clasificación comercial e imagen PT;
- BOM permite inspección bloqueada y alta contextual WIP sin aplicar maestros;
- cero errores nuevos después de recargar el snapshot final.

El smoke no materializó un PT UAT completo. El recorrido humano de seis fases,
390/768/1440, axe y datos reales permanece en
[[../../10_Flujos_y_Procesos/UAT_TS-017_Alta_Guiada_Integral_PT]].

## Gates pendientes

- [ ] ejecutar migraciones f81/f82 en una base UAT aislada;
- [ ] ejecutar pruebas PostgreSQL reales con owner/RLS/ACL;
- [ ] completar UAT COLADOR #3 y PORTAVAJILLAS;
- [ ] verificar visualmente 390/768/1440 y axe;
- [ ] desplegar backend/frontend y ejecutar smoke remoto;
- [ ] retirar definitivamente la Configuración guiada legacy tras la marcha blanca.
