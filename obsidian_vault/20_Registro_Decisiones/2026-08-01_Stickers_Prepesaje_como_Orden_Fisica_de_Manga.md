---
tipo: decision
estado: aceptada
tags: [scm, ot, manga, preetiqueta, maquinista, ux, pesaje, impresion]
relaciones:
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[Etiqueta_Manga]]"
  - "[[2026-07-23_Autoridad_Central_OT_e_Impresion_Local]]"
  - "[[2026-07-24_Mangas_Etiquetas_Fecha_Operativa_y_Recepcion_Almacen]]"
  - "[[Flujo_Distribucion_Stickers_y_Pesaje_Sin_PC_en_Maquina]]"
fecha_creacion: 2026-08-01
fecha_actualizacion: 2026-08-01
---

# Stickers de prepesaje como orden física de manga

## Contexto físico

La planta no posee PCs en las máquinas. Existen PCs de oficina y una PC en el
módulo de pesaje, donde están conectadas la balanza y la impresora de stickers.
El maquinista debe concentrarse en producir, contar físicamente y pesar, sin
reconstruir documentos ni digitar datos de producción.

## Decisión

Se usan dos soportes complementarios:

1. **Hoja de OT:** comunica el trabajo general de la jornada: OF/OT, máquina,
   molde, corrida/color, parámetros, turno y observaciones.
2. **Sticker de prepesaje:** representa una manga planificada concreta. Actúa
   como orden física individual, identidad logística previa al pesaje y llave
   QR para recuperar el contexto en la estación.

El SCM nunca “muestra” una tarea directamente al maquinista en la máquina. El
supervisor prepara la OT desde una PC, central envía el trabajo de impresión a
la PC de Balanza y el supervisor entrega físicamente la hoja y los stickers al
maquinista.

## Flujo operativo

1. El supervisor crea o selecciona la OT y asigna su cuota de mangas.
2. Central reserva una identidad y cantidad para cada manga.
3. La impresora del módulo de pesaje genera las preetiquetas 2-up.
4. El supervisor distribuye la hoja de OT y los stickers por máquina y
   maquinista.
5. El maquinista coloca una preetiqueta en la manga vacía, produce, cuenta y
   llena la cantidad indicada.
6. En Balanza escanea el QR. La estación recupera OT, artículo, color,
   cantidad, tipo y vigencia como datos de solo lectura.
7. El maquinista coloca la manga, espera estabilidad y confirma el pesaje.
8. Central confirma la cantidad asignada y la estación imprime la etiqueta
   final de pesaje.

## Datos mínimos visibles de la preetiqueta

- fecha operativa y turno;
- código OT y código de manga;
- máquina y maquinista previstos;
- pieza-color y color;
- cantidad objetivo;
- tipo `NORMAL` o `EXTRA`;
- QR único de la manga.

Los parámetros extensos permanecen en la hoja de OT y en central. El QR es la
identidad autoritativa; el texto sirve para verificación humana.

## Excepciones

- Si la cantidad física no coincide con la asignada, el maquinista informa al
  supervisor. El supervisor ajusta o concilia desde una PC con actor, motivo y
  permiso; la estación no abre un formulario al maquinista.
- Una manga adicional requiere autorización del Jefe de Producción, motivo y
  marca visible `EXTRA`.
- Una preetiqueta perdida o dañada no se reimprime silenciosamente: se invalida
  la etiqueta anterior y se genera un reemplazo autorizado para la misma
  manga.
- Un QR anulado, reemplazado, vencido o ya pesado se bloquea al escanear.

## Invariantes de UX

1. El flujo normal del maquinista no contiene búsquedas, dropdowns ni campos de
   cantidad, OP, OT, pieza o color.
2. El pesaje comienza mediante escaneo y todos los datos de negocio se muestran
   en solo lectura.
3. El peso nunca se usa para inferir unidades.
4. La preetiqueta no acredita producción ni inventario; solo reserva identidad
   y cantidad.
5. La etiqueta final no cambia la identidad de la manga.

## Criterios de aceptación

- **STK-01:** una OT creada en oficina genera un trabajo de impresión en la PC
  de Balanza sin requerir una PC en la máquina.
- **STK-02:** al escanear una preetiqueta válida, la estación recupera todo el
  contexto sin selección manual del maquinista.
- **STK-03:** una manga con cantidad coincidente se pesa y confirma sin digitar
  unidades.
- **STK-04:** una diferencia de cantidad deriva al supervisor y no puede ser
  corregida por el maquinista desde el flujo normal.
- **STK-05:** una etiqueta reemplazada no permite pesar y el nuevo QR conserva
  la misma manga.
