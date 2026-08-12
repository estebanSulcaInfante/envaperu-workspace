---
tipo: acta-preflight-uat
estado: listo-para-iniciar-participantes
fecha: 2026-08-03
run_id: UAT-PILOTO-2026-08-03-01
base_datos: envaperu_test
revision: f62e0b8d7c36
---

# Preflight UAT piloto limpio — 2026-08-03

## Veredicto

La base está estructuralmente limpia y contiene una sola identidad bootstrap. La UAT debe comenzar
por **Configuración de participantes y permisos** y continuar con **Maestros e imágenes**.
No se puede saltar a planificación, OT o pesaje porque aún no existen actores segregados ni maestros operativos.

No ejecutar `seed.py`, no insertar fixtures y no limpiar con SQL. Los datos se
crean desde las interfaces bajo prueba y se conservan como evidencia.

## Baseline comprobado

| Control | Resultado | Estado |
|---|---:|---|
| Revisión Alembic | `f62e0b8d7c36` | APROBADO |
| Roles del catálogo | 15 | APROBADO |
| Capacidades del catálogo | 112 | APROBADO |
| Capacidades de GERENTE_GENERAL | 112 de 112 | APROBADO |
| ANULAR_PESAJE asignada a JEFE_PRODUCCION | 1 | APROBADO |
| Trabajadores activos | 1 (`TRB-000001 · Gerente General`) | APROBADO |
| Máquinas activas | 0 | INICIAL LIMPIO |
| Tipos de manga activos | 0 | INICIAL LIMPIO |
| Perfiles empacables activos | 0 | INICIAL LIMPIO |
| Reglas de empaque aprobadas | 0 | INICIAL LIMPIO |
| Corridas liberadas | 0 | INICIAL LIMPIO |
| Estaciones activas | 0 | INICIAL LIMPIO |

## Secuencia obligatoria

1. **Configuración de participantes y permisos**
   - verificar que sólo existe TRB-000001 · Gerente General;
   - comprobar acceso completo y 112 capacidades;
   - crear durante la UAT los participantes operativos segregados;
   - probar edición, desactivación y restricciones por rol.
2. **Maestros e imágenes**
   - crear trabajadores UAT y asignar roles;
   - crear/verificar máquinas, moldes, piezas, colores y productos;
   - cargar, visualizar y reemplazar imágenes;
   - crear tipo de manga, perfil y regla de empaque;
   - aprobar la regla con actor distinto.
3. **OP, cobertura y planificación** mediante TS-010P.
4. **OF/OA y OT** mediante TS-010P.
5. **Mangas y preetiquetas** mediante TS-010C/D.
6. **Pesaje y postetiqueta** mediante TS-010C/D.
7. **Corrección y anulación** mediante TS-010C/D casos D-05 y D-09.
8. **Recepción, Calidad y Kardex** mediante TS-010I.
9. **Reversa y anulación posterior** mediante TS-010I casos F/G y TS-010C/D D-10.
10. **Conciliación 11213–11216** mediante TS-010C/D D-12.

## Participante bootstrap y actores que crea la UAT

| Actor UAT | Rol mínimo |
|---|---|
| Gerente General bootstrap | GERENTE_GENERAL |
| Coordinador | PLANIFICACION y/o SUPERVISOR |
| Jefe de Producción | `JEFE_PRODUCCION` |
| Maquinista | `MAQUINISTA` |
| Operador de pesaje | `OPERADOR_PESAJE` |
| Almacén | `ALMACEN_RECEPCION` |
| Calidad | `CALIDAD` |
| Auditor | `AUDITORIA_CONSULTA` opcional |

Sólo Gerente General existe antes de comenzar. Los demás participantes se crean como evidencia de la primera UAT.

El solicitante y el aprobador de correcciones o reversas deben ser personas
distintas.

## Puerta para avanzar de Maestros a TS-010P

No avanzar hasta tener:

- actores activos con roles comprobados;
- al menos una máquina, molde y conjunto de artículos normalizados;
- imágenes visibles y reemplazables;
- tipo de manga con tara real;
- perfil predeterminado por artículo;
- regla de empaque aprobada;
- códigos y capturas guardados bajo el RUN_ID.

## Registro de ejecución

| Dato | Valor |
|---|---|
| RUN_ID | `UAT-PILOTO-2026-08-03-01` |
| Responsable | |
| Hora de inicio | |
| Carpeta de evidencias | |
| Resultado Participantes | PENDIENTE |
| Resultado Maestros | PENDIENTE |
| Resultado TS-010P | PENDIENTE |
| Resultado TS-010C/D | PENDIENTE |
| Resultado TS-010I | PENDIENTE |
| Resultado stickers 11213–11216 | PENDIENTE |

Valores permitidos: `APROBADO`, `FALLIDO`, `BLOQUEADO` o `DIFERIDO` con
aceptación explícita.