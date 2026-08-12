---
tipo: guia-uat
estado: lista-para-ejecucion-local
fecha_creacion: 2026-08-03
fecha_actualizacion: 2026-08-03
base_datos: envaperu_test
revision_minima: f62e0b8d7c36
run_id: UAT-PILOTO-2026-08-03-01
tags: [uat, participantes, trabajadores, roles, capacidades, autorizacion]
---

# UAT 01 — Configuración de participantes y permisos

## Objetivo

Validar que el piloto comienza con una única identidad bootstrap y que desde la
interfaz pueden configurarse participantes de UAT, roles, estado y separación
de responsabilidades sin editar la base manualmente.

## Baseline obligatorio

| Control | Esperado |
|---|---|
| Participantes activos | 1 |
| Código | `TRB-000001` |
| Nombre | `Gerente General` |
| Rol | `GERENTE_GENERAL` |
| Capacidades efectivas | 112 de 112 |
| Otros participantes | 0 |
| Revisión | `f62e0b8d7c36` o posterior compatible |

No crear participantes por SQL. Toda alta y edición de esta UAT se hace desde
**Datos maestros → Trabajadores** con Gerente General seleccionado como actor.

## Participantes que debe crear la UAT

| Identidad funcional | Rol mínimo |
|---|---|
| Coordinador UAT | `PLANIFICACION` y/o `SUPERVISOR` |
| Jefe de Producción | `JEFE_PRODUCCION` |
| Maquinista | `MAQUINISTA` |
| Operador de pesaje | `OPERADOR_PESAJE` |
| Almacén | `ALMACEN_RECEPCION` |
| Calidad | `CALIDAD` |
| Aprobador gerencial | `GERENCIA` |
| Auditor | `AUDITORIA_CONSULTA` opcional |

Durante la UAT se permiten identidades funcionales temporales reconocibles,
por ejemplo Responsable de Calidad. No usar nombres ambiguos como Usuario 1 ni
compartir una identidad entre varias personas. Antes de iniciar la operación real,
estas identidades deben reemplazarse por participantes nominales o desactivarse.

## P-01 — Verificar bootstrap

1. Ingresar con `TRB-000001 · Gerente General`.
2. Abrir **Datos maestros → Trabajadores**.
3. Confirmar que es el único participante.
4. Confirmar rol `GERENTE_GENERAL`, estado activo y acceso a todos los módulos.
5. Confirmar que el código es automático e inmutable.

Resultado: baseline coincide y no existen participantes mock.

## P-02 — Alta de participantes

1. Crear cada identidad funcional de la tabla anterior.
2. Completar nombres, apellidos y nombre corto acordados.
3. Asignar únicamente los roles necesarios.
4. Guardar y registrar el código automático `TRB-*`.
5. Recargar la pantalla y confirmar persistencia.

Resultado: no se permiten códigos manuales y cada persona conserva sus roles.

## P-03 — Edición y estado

1. Editar nombre corto u observación de un participante.
2. Intentar cambiar el código: debe rechazarse.
3. Desactivar temporalmente al participante de prueba.
4. Confirmar que deja de ser elegible como actor operativo.
5. Reactivarlo y confirmar recuperación de sus capacidades.

## P-04 — Capacidades efectivas

Para cada rol creado:

1. seleccionarlo como actor;
2. confirmar que ve las rutas autorizadas;
3. confirmar que no ve acciones ajenas a su rol;
4. invocar una acción no permitida y comprobar respuesta `403` del backend;
5. guardar captura del rol y capacidades efectivas.

La ocultación visual no sustituye el `403` del servidor.

## P-05 — Segregación

1. Crear una solicitud que requiera aprobación con el Coordinador.
2. Intentar aprobar con el mismo participante: debe rechazarse.
3. Aprobar con la identidad autorizada distinta.
4. Repetir el principio posteriormente en reglas de empaque, corrección de
   pesaje y reversa de recepción.

Gerente General tiene todas las capacidades, pero tampoco debe aprobar una
solicitud creada por esa misma identidad cuando el dominio exige cuatro ojos.

## P-06 — Gerente General como bootstrap, no como usuario compartido

1. Confirmar que `TRB-000001` no se asigna como Maquinista ni operador habitual.
2. Confirmar que su uso queda limitado a configuración inicial y contingencia
   controlada.
3. Registrar responsable y hora de cada uso durante UAT.
4. No compartir credenciales ni identidad entre participantes.

## Evidencias

```text
UAT-PARTICIPANTES-<RUN_ID>/
  00-baseline-unico-gerente.png
  01-capacidades-gerente.png
  02-altas-participantes.png
  03-codigos-automaticos.md
  04-edicion-y-estado.png
  05-denegacion-403.png
  06-segregacion.png
  07-resultados.md
```

## Acta

| Caso | Resultado | Evidencia | Observación |
|---|---|---|---|
| P-01 | APROBADO | Verificación visual y API | Baseline con único Gerente General. |
| P-02 | APROBADO | Interfaz y API de trabajadores | Códigos TRB-000002 a TRB-000008 persistidos; identidades funcionales temporales. |
| P-03 | APROBADO | Reprueba visual, API y regresión automática | Edición persistente; inactivo excluido del selector; reactivación restituye el perfil. |
| P-04 | EN CURSO | Auditor visual + backend 403 | Estado vacío estable; Auditor sólo consulta y POST de OP rechazado con CAPABILITY_REQUIRED/OP_CREAR. |
| P-05 | PENDIENTE | | |
| P-06 | PENDIENTE | | |

## Criterio de aprobación

La UAT se aprueba cuando:

- sólo Gerente General existía en el baseline;
- todos los participantes posteriores fueron creados por la interfaz;
- códigos y asignaciones persisten;
- identidades inactivas no pueden operar;
- acciones no autorizadas responden `403`;
- segregación rechaza autoaprobaciones;
- no existen identidades compartidas;
- las identidades funcionales temporales quedan identificadas para ser reemplazadas
  o desactivadas antes de la operación real.

Después de aprobar esta guía se continúa con **Maestros e imágenes**.