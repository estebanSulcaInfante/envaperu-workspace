---
tipo: decision
estado: aceptada
tags: [catalogo, producto-terminado, pieza, linea, familia]
fecha: 2026-08-10
relaciones:
  - "[[../01_Dominio/ProductoTerminado]]"
  - "[[../01_Dominio/Pieza]]"
  - "[[../01_Dominio/LineaFamilia]]"
  - "[[../05_Especificaciones/02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
---

# ProductoTerminado es la autoridad de clasificación comercial

## Contexto

La UAT real registró que Línea y Familia se solicitan al crear una Pieza aunque el usuario las entiende como clasificación del producto comercial. Una misma pieza física puede reutilizarse en productos de distintas familias. Copiar el par del primer producto hacia Pieza y PiezaColor convierte una relación de uso en una identidad permanente y genera contradicciones posteriores.

Además, [[../05_Especificaciones/03_Tech_Specs/TS-014_Normalizacion_Linea_Familia_NM_y_CRUD|TS-014]] permite que la clasificación de Pieza quede vacía, mientras [[../05_Especificaciones/03_Tech_Specs/TS-015_Asistente_Catalogo_Altas_En_Contexto_y_OP_Excepcional|TS-015]] todavía la exige antes de crear PiezaColor.

## Decisión

1. `ProductoTerminado.linea_id + familia_id` es la clasificación comercial obligatoria y autoritativa.
2. `Pieza.linea_id + familia_id` pasa a ser una clasificación técnica opcional. Si se informa, el par debe seguir siendo una asociación `LineaFamilia` activa.
3. Crear una Pieza dentro del alta de un producto no copia silenciosamente la clasificación comercial del PT.
4. La creación de `PiezaColor` no se bloquea por ausencia de clasificación técnica de Pieza.
5. Los campos de Línea/Familia duplicados en `PiezaColor` se consideran compatibilidad legacy y no son fuente para nuevas decisiones comerciales.
6. Los filtros de “productos que usan esta pieza” se resuelven mediante estructuras/BOM, no comparando Línea o Familia.

## Consecuencias

- El asistente solicita la clasificación comercial en el paso IDENTIDAD del PT y no en la tarjeta de cada Pieza.
- La administración individual de Pieza puede ofrecer una sección avanzada llamada **Clasificación técnica**, claramente opcional.
- Deben alinearse validaciones de API, serialización, importadores y el endpoint legacy `/api/configurar-producto`.
- No se eliminan columnas legacy en el primer incremento; se deja de escribirlas como autoridad y se planifica su contrato posterior con evidencia de datos.
- El hallazgo `UAT-M-H01` sólo puede cerrarse cuando UI y backend demuestren esta regla.

## Alternativas descartadas

- Copiar siempre Línea/Familia del PT a la Pieza: impide reutilización semánticamente correcta.
- Hacer que la primera Pieza defina la clasificación del PT: invierte la autoridad comercial.
- Mantener dos pares obligatorios con el mismo nombre: conserva la ambigüedad que originó el hallazgo.
