# EnvaPeru Workspace

Bienvenido al repositorio maestro del **Sistema Core de Producción, Pesaje e Inventario de EnvaPeru**.
Este entorno (Workspace) centraliza el código fuente principal para los diferentes ecosistemas operacionales de la empresa.

## Arquitectura del Proyecto

El sistema está separado lógicamente en tres componentes principales:

### 1. `backend/` (Núcleo API y BDD)
Desarrollado en **Python / Flask (SQLAlchemy)** y Base de Datos **PostgreSQL**.
Gestiona el modelo de negocio central:
*   Creación y Administración de **Catálogos** (Piezas, Moldes, Productos Terminados, Colores).
*   Gestión de **Órdenes de Producción** y su Snapshot dinámico (1 molde $\leftrightarrow$ N piezas/cavidades).
*   Procesamiento de Registros y Control de Peso de **Bultos Diarios**.
*   Trazabilidad de Control de Calidad e inyecciones.
*   **Testing:** Desarrollado bajo Spec-Driven Development con `pytest` y fixtures `in-memory`. 

Para ejecutar el entorno:
```bash
cd backend
source venv/Scripts/activate # Windows
flask run
# Para pruebas
python -m pytest tests/ -v
```

### 2. `frontend/` (SPA y Dashboards Operativos)
Desarrollado en **React (Vite) + Material UI (MUI)**.
Es la Interfaz Gráfica utilizada por Administradores de Planta, Área Comercial y Gerencia.
*   Formularios Modulares. Integrados con Autocompletados y Estados Reactivos Dinámicos (ej. Cálculo de OP Multi-pieza).
*   Vistas Trazables y Modales de reportes de Producción e índices de Eficiencia.
*   **Testing:** `vitest` + `@testing-library/react`.

Para ejecutar el entorno:
```bash
cd frontend
npm install
npm run dev
# Para pruebas
npm run test
```

### 3. `Weighing Module` (Módulo Aislado/Físico)
El sistema incluye integraciones físicas (y sincronizaciones P2P o Endpoints `sync`) para las Tablets y Estaciones Físicas de Balanzas. Estás gestionan la lectura empírica de lotes producidos.
Se integran bajo una comunicación en la ruta `/api/sync/` del Backend Global.

---

## 🧠 Obsidian Vault (La Fuente de la Verdad)

Este Workspace utiliza una **bóveda de Obsdian (`obsidian_vault/`)** paralela al código que funciona como la _Memoria Persistente_ principal del sistema y actúa de fuente de verdad absoluta de Reglas de Negocio, Validaciones y Modelamiento de Datos.

**🚨 Reglas Fundamentales del Vault 🚨:**
1. **Nunca Asumir**: Si estás desarrollando una nueva fórmula, modificando cómo las cavidades de la Pieza-Molde operan o recalculando los Registros Diarios, **tienes que verificar la arquitectura registrada en la bóveda de Obsidian** primero (`/01_Dominio`, `/00_Meta`, etc.).
2. **Registro de Decisiones (ADRs)**: Cada vez que tomes una decisión importante (ej. refactorización de tests, nuevo endpoint), registra la decisión en la carpeta `10_Flujos_y_Procesos/` o `20_Registro_Decisiones/`.

> [!WARNING]
> La bóveda define las reglas explícitas como la tolerancia de 5KG en el Control de Peso, las fórmulas asíncronas para el Sistema de SNAPSHOT y congelamiento de las Ordenes de Producción respecto a Catálogo. No violar estas directivas.

---

## ATDD/BDD + TDD

El proyecto combina especificación por ejemplos con desarrollo guiado por pruebas:

1. **ATDD/BDD:** las User Stories describen comportamientos observables con datos realistas, incluidos errores, reintentos y correcciones.
2. **Tech Spec:** concreta contratos y asigna cada escenario al nivel de prueba adecuado.
3. **BASELINE:** la suite existente debe estar verde o sus fallos previos deben quedar aislados y documentados.
4. **RED:** se escribe una prueba que falla por la ausencia del comportamiento esperado.
5. **GREEN:** se implementa el mínimo código necesario para hacerla pasar.
6. **REFACTOR:** se mejora el diseño manteniendo toda la regresión verde.

Las pruebas deben proteger comportamiento y reglas del dominio, no reproducir mocks vacíos ni acoplarse innecesariamente a detalles internos. El caso “Jarra Regadera”, por ejemplo, debe demostrar el comportamiento `1 Molde -> N PiezasColor -> BOM de ProductoTerminado` en los niveles donde realmente pueda romperse.

- El backend utiliza `pytest`; las reglas relacionales rápidas pueden usar fixtures en memoria y las garantías específicas de transacción/concurrencia deben probarse también contra PostgreSQL.
- El frontend utiliza `vitest` y Testing Library para interacciones observables.
- El módulo de pesaje necesita pruebas propias de operación offline, idempotencia y sincronización.
- Los recorridos E2E deben ser pocos y representativos; las combinaciones pertenecen a niveles de prueba más rápidos.

### Comandos Versionados

Preparar los entornos de prueba con Python 3.12 y npm:

```powershell
.\scripts\bootstrap-tests.ps1 -Component all
```

Si `node_modules` ya existe, el bootstrap valida el árbol de dependencias y conserva la instalación activa. Para forzar una reinstalación reproducible con `npm ci`, primero detén el servidor Vite y ejecuta:

```powershell
.\scripts\bootstrap-tests.ps1 -Component frontend -CleanFrontend
```

Ejecutar la línea base completa:

```powershell
.\scripts\test.ps1 -Component all
```

También se puede seleccionar `backend`, `frontend` o `pesaje`. El perfil PostgreSQL es opt-in y requiere Docker:

```powershell
.\scripts\test.ps1 -Component backend -Postgres
```

La suite rápida excluye E2E, hardware y PostgreSQL. Estos perfiles solo se ejecutan de forma explícita para evitar conexiones accidentales con servicios o dispositivos reales.

Validar el contrato actual entre backend central y pesaje, incluidas sus copias versionadas:

```powershell
.\scripts\test-contracts.ps1
```

Ejecutar el recorrido HTTP aislado con bases temporales y puertos dinámicos:

```powershell
.\scripts\test-sync-e2e.ps1
```

El contrato se denomina `sync-pesajes-legacy-v1` deliberadamente: caracteriza la integración existente, pero no reemplaza el futuro contrato idempotente definido por US-010.
