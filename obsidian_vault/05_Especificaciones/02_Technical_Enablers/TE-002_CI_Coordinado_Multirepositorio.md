---
tipo: technical-enabler
estado: en-desarrollo
tags: [ci, github-actions, testing, multirepositorio, submodulos, tdd]
relaciones:
  - "[[TE-001_Infraestructura_TDD_Reproducible]]"
  - "[[TE-003_Contratos_Central_Pesaje_y_E2E_Aislado]]"
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
fecha_creacion: 2026-07-13
---

# TE-002: CI Coordinado Multirepositorio

## 1. Problema

La línea base de TE-001 solo se ejecutaba localmente. El workspace y sus tres submódulos son repositorios Git independientes y ninguno poseía automatización versionada. Una regresión podía integrarse en un componente o en una combinación de SHAs sin ejecutar las mismas pruebas usadas durante TDD.

## 2. Capacidad Habilitada

**Como** equipo de desarrollo  
**Queremos** ejecutar automáticamente la línea base en cada repositorio y en la combinación fijada por el workspace  
**Para** detectar regresiones antes de integrar cambios y conservar evidencia repetible.

## 3. Clasificación

TE-002 es autocontenido y no requiere `TS-TE-002`: solo añade automatización de desarrollo, usa comandos ya aprobados, no despliega, no accede a datos productivos y no cambia contratos ni comportamiento runtime.

## 4. Diseño

| Repositorio | Runner | Verificación |
|---|---|---|
| Backend central | Ubuntu, Python 3.12 | Suite rápida y smoke PostgreSQL en jobs separados |
| Frontend | Ubuntu, Node.js 24 | Instalación con `npm ci` y Vitest no interactivo |
| Módulo de pesaje | Windows, Python 3.12 | Suite del backend en el SO operativo principal |
| Workspace | Windows, Python 3.12 y Node.js 24 | Checkout de SHAs de submódulos, bootstrap y línea base completa |

Todos los workflows:

- se disparan por `push`, `pull_request` y ejecución manual;
- declaran únicamente permiso `contents: read`;
- cancelan ejecuciones obsoletas de la misma referencia;
- poseen timeout explícito;
- propagan cualquier fallo como resultado no exitoso.

## 5. Submódulos Privados

El checkout del workspace usa `WORKSPACE_REPOS_TOKEN` cuando existe y, en caso contrario, `github.token`. Si algún submódulo es privado, el repositorio workspace deberá configurar ese secret con acceso de solo lectura a los tres repositorios. No se incorporan credenciales al código.

## 6. Criterios de Aceptación

### TE-002-01: CI por componente

Cada repositorio ejecuta su suite propia desde una instalación limpia y falla si su línea base falla.

### TE-002-02: PostgreSQL representativo

Backend central levanta PostgreSQL 16 como servicio aislado y ejecuta exclusivamente las pruebas marcadas `postgres` en un job visible por separado.

### TE-002-03: Integración por SHAs

Workspace obtiene recursivamente los commits de submódulo fijados y ejecuta `bootstrap-tests.ps1` seguido de `test.ps1`.

### TE-002-04: Mínimo privilegio

Los workflows no poseen permisos de escritura, secretos productivos ni pasos de despliegue.

### TE-002-05: Reproducibilidad

Las versiones mayores del runtime, las acciones y las imágenes de servicio están declaradas; dependencias Python y npm provienen de archivos versionados.

## 7. Fuera de Alcance

- despliegue continuo;
- publicación de artefactos de escritorio;
- cobertura porcentual como gate;
- pruebas con balanza o impresora física;
- reglas de protección de rama, que se configuran en GitHub después de la primera ejecución verde;
- decidir reglas funcionales pendientes de US-010.

## 8. Definición de Terminado

- [x] Existe workflow del backend central.
- [x] Existe job PostgreSQL aislado.
- [x] Existe workflow del frontend.
- [x] Existe workflow del módulo de pesaje.
- [x] Existe workflow coordinador del workspace.
- [x] Los YAML son válidos y los comandos equivalentes pasan localmente.
- [ ] Los cuatro workflows tuvieron una primera ejecución remota verde.
- [ ] Las ramas principales exigen sus checks correspondientes.

## 9. Estado de Implementación

La automatización está versionada localmente. TE-002 permanecerá `en-desarrollo` hasta confirmar y publicar primero los cambios de cada submódulo, actualizar sus SHAs en el workspace y observar una ejecución remota verde. Después podrán configurarse los checks como obligatorios en protección de ramas.

## 10. Validación Local

- los cuatro workflows y `docker-compose.test.yml` fueron parseados correctamente;
- el workspace ejecutó `75` pruebas backend, `2` frontend y `10` de pesaje sin fallos;
- el contrato coordinado y el E2E aislado de TE-003 también quedaron verdes;
- el job PostgreSQL no pudo reproducirse localmente porque esta máquina no tiene Docker, pero reutiliza el smoke test ya versionado por TE-001;
- la ejecución repetida reveló un empate de timestamps en el historial de OP; se añadió orden secundario por `id DESC` y una prueba determinista para impedir esa intermitencia en CI.
