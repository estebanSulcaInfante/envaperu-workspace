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

## Testing y SDD (Spec-Driven Development)

Ambos entornos, *Backend (Flask)* y *Frontend (React)*, siguen reglas BDD/SDD (Behavior/Spec-Driven).

*   Evitar simulaciones vacías o "TDD rígido". En cambio, priorizar "Specs" que modelen el ecosistema de Producción de EnvaPeru (ej. Caso "Jarra Regadera": 1 Molde $\rightarrow$ 3 Piezas $\leftrightarrow$ 1 Producto Terminado).
*   El backend en `backend/tests/test_spec_orden_produccion.py` verifica la integridad multi-pieza a nivel relacional (SQLAlchemy).
*   El frontend en `frontend/src/tests/` utiliza la arquitectura UI para emular la selección asíncrona y la renderización en forma de grilla multi-tabla.
