---
tipo: approved-for-dev
estado: implementado-local-pendiente-uat
historia: "[[US-010F_Prearmado_y_Armado_Concurrente_Trazable]]"
tech_spec: "[[TS-010F_Armado_Genealogia_Mangas_PT_y_Cierre_Armado]]"
fecha_aprobacion: 2026-08-03
---

# DEV-010F1: Cierre exacto de manga de Armado

Se autoriza e implementa localmente el primer incremento acotado de TS-010F.
No autoriza despliegue ni habilita silenciosamente genealogía candidata o
legacy.

## Alcance exacto

- plan de mangas PT/WIP desde una OA liberada y un perfil aprobado;
- asignación de las mangas de salida a una OT diaria de Armado;
- preetiquetado mediante la cola existente de la estación de pesaje;
- cierre por el responsable asignado a la OT;
- cantidad real independiente del peso y motivo obligatorio ante diferencia;
- consumo FIFO exclusivamente entre mangas exactas recibidas en la mesa;
- genealogía manga PT -> asignación -> manga componente;
- acreditación de unidades y estado `CERRADA_ARMADO_PENDIENTE_PESAJE`;
- pesaje posterior con cantidad de Armado no editable;
- capacidades configurables para planificar, cerrar y consultar genealogía;
- API, interfaz, migración y pruebas automatizadas.

## Invariantes

1. El cierre no crea pesaje ni entrada de Kardex para la manga PT.
2. El pesaje no cambia la cantidad confirmada ni los consumos.
3. Si falla un consumo, no se acredita ninguna salida parcial.
4. Solo el responsable de la OT confirma la manga.
5. El abastecimiento debe estar recibido en Mesa de Armado.
6. Las modalidades `CONJUNTO_CANDIDATOS` y `LEGACY_SIN_ORIGEN` permanecen
   bloqueadas hasta definir y aprobar sus políticas operativas.

## Pendiente antes de producción

- UAT con una BOM, OA, OT, mangas fuente y manga PT reales anonimizadas;
- validar capacidad de un Tipo de manga PT real;
- validar sobrantes, scrap y `USO_EN_PROCESO` en planta;
- completar los incrementos candidato/legacy y correcciones posteriores si la
  operación los necesita.
