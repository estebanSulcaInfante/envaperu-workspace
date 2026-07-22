---
tipo: patron_frontend
estado: en-desarrollo
tags: [frontend, formularios, autocomplete, modal, catalogos, ux]
fecha_creacion: 2026-07-22
fecha_actualizacion: 2026-07-22
relaciones:
  - "[[../../05_Especificaciones/03_Tech_Specs/TS-015_Asistente_Catalogo_Altas_En_Contexto_y_OP_Excepcional]]"
---

# Patrón — Altas en contexto desde selectores

## Objetivo

Permitir que un usuario complete un formulario cuando la base local todavía no contiene un maestro necesario, sin perder lo ya ingresado ni abandonar el flujo.

## Comportamiento

Un selector compatible agrega una fila visual **“Crear nuevo…”** después de todas las opciones filtradas. Esa fila abre un modal con el mínimo contrato válido del catálogo. Al confirmar:

1. se crea mediante la API real;
2. se refresca la lista;
3. se selecciona la respuesta del servidor;
4. se cierra el modal;
5. el formulario padre conserva el resto de su estado.

Cancelar no ejecuta escrituras. Los errores se muestran dentro del modal y el doble envío permanece bloqueado.

## Cuándo usarlo

Es apropiado para catálogos compactos, como Color, Línea o Familia. Una Familia creada desde una Línea también debe crear explícitamente la asociación `LineaFamilia`.

No debe usarse para ocultar maestros complejos. Molde, composición `MoldePieza`, PiezaColor y ProductoTerminado con BOM requieren su formulario completo o la Configuración guiada. Una Pieza puede crearse en contexto solo cuando el modal recoge también su peso, Línea y Familia y la asocia al molde en una única operación válida.

## Componentes de referencia

- `CreateOptionAutocomplete`: agrega y renderiza siempre la acción final sin convertirla en valor del formulario.
- `ColorQuickCreateDialog`: crea `ColorProduccion` solicitando color base y FamiliaColor.
- `ClassificationQuickCreateDialog`: crea una Línea o crea una Familia asociada atómicamente a la Línea activa.

Los componentes consumidores siguen siendo responsables de volver a consultar, seleccionar la entidad confirmada y anunciar errores accesibles.
