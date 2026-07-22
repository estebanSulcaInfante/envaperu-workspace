---
tipo: technical-enabler
estado: implementado
tags: [tdd, testing, pytest, vitest, postgresql, infraestructura, reproducibilidad]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
fecha_creacion: 2026-07-13
fecha_implementacion: 2026-07-13
---

# TE-001: Infraestructura TDD Reproducible

## 1. Problema

El workspace declara que usa pytest y Vitest, pero la ejecución no es reproducible de forma uniforme:

- backend central no declara pytest en una dependencia de desarrollo;
- pruebas rápidas, E2E y scripts manuales se mezclan bajo nombres `test_*`;
- frontend solo ofrece el comando interactivo `vitest` y no uno explícito de ejecución única;
- módulo de pesaje declara `flask-socketio` en runtime, pero no posee dependencias de test ni un entorno propio reproducible;
- no existe un comando en la raíz que ejecute las suites actuales de los submódulos;
- las pruebas críticas futuras necesitarán PostgreSQL real, mientras la suite rápida usa SQLite en memoria;
- los tres componentes son repositorios separados, por lo que CI requiere un enabler posterior y coordinación entre repositorios.

## 2. Evidencia Inicial

Línea base observada antes de TE-001:

| Componente | Resultado |
|---|---|
| Backend central | `74 passed`, `1 skipped`; E2E y script manual excluidos explícitamente |
| Frontend central | `2 passed` después de actualizar una caracterización obsoleta de TS-009 |
| Módulo de pesaje | Error de recolección al usar un entorno ajeno: `ModuleNotFoundError: flask_socketio` |

## 3. Capacidad Habilitada

**Como** equipo de desarrollo  
**Queremos** preparar y ejecutar las suites mediante comandos versionados y consistentes  
**Para** comenzar cada ciclo TDD desde una línea base conocida y distinguir regresiones de fallos ambientales.

## 4. Decisión de Clasificación

TE-001 es un enabler autocontenido. No requiere `TS-TE-001` porque:

- no modifica modelos, endpoints ni reglas de producción;
- no agrega dependencias al runtime de producción;
- sus cambios se limitan a configuración, dependencias de desarrollo, pruebas de caracterización y scripts locales;
- es reversible y verificable mediante los propios comandos que introduce.

## 5. Alcance

### Backend central

- declarar dependencias de desarrollo;
- configurar pytest y marcadores;
- excluir por defecto E2E, PostgreSQL y scripts manuales de la suite rápida;
- identificar explícitamente el E2E existente;
- proporcionar un smoke test opt-in para el PostgreSQL de pruebas.

### Frontend central

- mantener el modo watch;
- añadir un comando explícito de ejecución única;
- conservar verde la prueba de caracterización de `OrdenForm` normalizada por TS-009.

### Módulo de pesaje

- declarar dependencias de desarrollo;
- configurar pytest;
- aislar la prueba del hilo de sincronización y de la base local persistente;
- ejecutar la suite en un entorno propio.

### Workspace

- incorporar scripts PowerShell de bootstrap y ejecución;
- permitir ejecutar un componente o la línea base completa;
- añadir un PostgreSQL efímero opt-in para futuras pruebas de integración;
- documentar comandos y resultados.

## 6. Fuera de Alcance

- implementar recepción, lotes o calidad de US-010A;
- crear pruebas `REC-*` antes de aprobar sus decisiones de negocio;
- modificar la base de datos de producción;
- automatizar E2E que todavía requieren servidores levantados;
- añadir pruebas de UI al módulo de pesaje en esta entrega;
- configurar CI en los tres repositorios;
- exigir cobertura porcentual sin una línea base útil.

## 7. Criterios de Aceptación

### TE-001-01: Backend rápido reproducible

**Dado** un entorno instalado con las dependencias de desarrollo  
**Cuando** se ejecuta pytest sin marcadores adicionales  
**Entonces** corre la suite rápida  
**Y** no intenta conectar con los servidores E2E ni con PostgreSQL.

### TE-001-02: E2E identificado

**Dado** el recorrido de OP que necesita backend central y pesaje activos  
**Cuando** pytest recolecta las pruebas  
**Entonces** el recorrido se identifica con el marcador `e2e`  
**Y** solo se ejecuta por solicitud explícita.

### TE-001-03: PostgreSQL opt-in

**Dado** Docker y el perfil PostgreSQL de pruebas  
**Cuando** se solicita la suite PostgreSQL  
**Entonces** se levanta una base efímera aislada  
**Y** el smoke test demuestra conectividad real  
**Y** el servicio se elimina al finalizar.

### TE-001-04: Frontend no interactivo

**Dado** el frontend instalado mediante npm  
**Cuando** se ejecuta `npm run test:run`  
**Entonces** Vitest termina por sí mismo y devuelve un código de salida confiable.

### TE-001-05: Pesaje aislado

**Dado** un entorno propio del backend de pesaje  
**Cuando** se ejecuta pytest  
**Entonces** no inicia sincronización en background  
**Y** no escribe en la base SQLite operativa  
**Y** sus pruebas pasan o reportan un fallo funcional reproducible.

### TE-001-06: Orquestación desde workspace

**Dado** los entornos preparados  
**Cuando** se invoca el runner raíz para uno o todos los componentes  
**Entonces** cada suite usa su propio entorno  
**Y** el proceso termina con error si alguna suite falla.

### TE-001-07: Separación de runtime

**Dado** las nuevas herramientas de prueba  
**Cuando** se revisan dependencias de producción  
**Entonces** pytest permanece fuera de `requirements.txt` productivo  
**Y** no se modifica el comportamiento runtime de la aplicación.

## 8. Estrategia TDD del Enabler

1. Capturar los fallos de línea base actuales.
2. Añadir configuración mínima de cada runner.
3. Ejecutar y observar el primer fallo ambiental reproducible.
4. Aislar entorno y dependencias sin modificar comportamiento productivo.
5. Ejecutar nuevamente hasta obtener línea base verde.
6. Añadir el orquestador raíz y comprobar propagación de errores.
7. Registrar resultados reales y deudas restantes.

## 9. Riesgos

- Un gestor de paquetes distinto puede alterar `node_modules`; frontend central usa npm como única fuente operativa.
- Una prueba contra SQLite no demuestra concurrencia ni restricciones específicas de PostgreSQL.
- El módulo de pesaje incluye dependencias de hardware; la suite rápida debe evitar abrir puertos o impresoras.
- E2E puede modificar datos si se ejecuta accidentalmente contra servidores no aislados.

## 10. Definición de Terminado

- [x] Existe documentación del carril Technical Enabler.
- [x] Backend posee dependencias dev, configuración y suite rápida verde.
- [x] Frontend posee `test:run` y suite verde.
- [x] Pesaje posee dependencias dev, configuración y suite verde en entorno propio.
- [x] El runner raíz ejecuta las tres líneas base.
- [x] El perfil PostgreSQL opt-in está versionado y su YAML es válido.
- [x] No se introdujeron reglas ni modelos de US-010A.
- [x] Resultados y limitaciones quedaron registrados en esta nota.

## 11. Resultado de Implementación

Comando ejecutado:

```powershell
.\scripts\test.ps1 -Component all
```

Resultado del 2026-07-13:

| Componente | Entorno | Resultado |
|---|---|---|
| Backend central | Python `3.12.10`, pytest `9.0.2` | `74 passed`, `1 skipped`, `3 deselected`, 19 warnings legacy |
| Frontend central | Vitest `4.1.5` | `2 passed` |
| Backend de pesaje | Python `3.12.10`, pytest `9.0.2` | `8 passed` |

TE-001 detectó y corrigió dos regresiones residuales de TS-009 en el módulo de pesaje:

1. Cuatro rutas seguían decoradas con el blueprint eliminado `rdp_bp`.
2. El endpoint de anulación convertía `correlativo` a texto, contradiciendo su PK y los demás contratos numéricos.

El bootstrap frontend usa `npm ci` cuando no existe una instalación local. Si `node_modules` ya existe, valida el árbol con `npm ls` y lo conserva para no interrumpir un servidor Vite activo. Una reinstalación estricta queda disponible mediante `-CleanFrontend` y requiere detener primero dicho servidor.

### Limitación Ambiental

`docker-compose.test.yml` y el smoke test PostgreSQL están implementados y se recolectan solo mediante el marcador `postgres`. No se levantó el contenedor en esta máquina porque Docker no está instalado. La primera ejecución en un equipo con Docker debe usar:

```powershell
.\scripts\test.ps1 -Component backend -Postgres
```

## 12. Continuación

- [[TE-002_CI_Coordinado_Multirepositorio|TE-002]]: workflows implementados localmente; pendiente primera ejecución remota y protección de ramas.
- [[TE-003_Contratos_Central_Pesaje_y_E2E_Aislado|TE-003]]: contrato `legacy-v1`, pruebas consumidor/proveedor y E2E aislado implementados.

Después de TE-003, la línea base vigente creció a `75` pruebas backend y `10` de pesaje; los números de la sección 11 conservan la evidencia histórica del cierre de TE-001.

### Revalidación del 2026-07-15

Se ejecutó nuevamente el runner completo:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1 -Component all
```

Resultado: backend `75 passed`, `1 skipped`, `3 deselected` y 19 advertencias legacy; frontend `2 passed`; backend de pesaje `10 passed`.

La revalidación detectó dos entornos virtuales que conservaban el ejecutable de entrada, pero no podían iniciar su runtime base. El runner ahora prueba que cada Python sea ejecutable antes de seleccionarlo y el bootstrap reconstruye entornos rotos. Cuando Python `3.12` no está publicado en `PATH`, puede indicarse sin codificar una ruta de máquina en el repositorio:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\bootstrap-tests.ps1 -Component all -Python C:\ruta\a\python.exe
```

El E2E aislado de TE-003 también quedó verde: `12.5 kg` llegaron al backend central y el módulo local registró el acuse.
