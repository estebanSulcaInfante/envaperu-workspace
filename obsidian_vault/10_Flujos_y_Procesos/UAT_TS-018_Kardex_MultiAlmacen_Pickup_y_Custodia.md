---
tipo: uat
estado: pendiente-ejecucion-local
tags: [uat, scm, almacen, kardex, picking, pickup, qr, custodia]
relaciones:
  - "[[TS-018A_Almacenes_Ubicaciones_y_Alcance_de_Datos]]"
  - "[[TS-018B_Sesiones_MultiQR_Picking_Pickup_y_Transferencias]]"
  - "[[TS-018C_Vistas_Especializadas_y_Control_de_Kardex]]"
fecha_creacion: 2026-08-11
fecha_actualizacion: 2026-08-11
---

# UAT TS-018 — Kardex multi-almacén, pickup y custodia

> El incremento local MVP existe, pero todos los casos siguen pendientes de
> ejecución humana. Este documento no autoriza despliegue.

## Participantes mínimos

- almacenero de Piezas/WIP;
- responsable de Armado;
- almacenero de Materias Primas;
- almacenero de Producto Terminado;
- Jefe de Producción o Control;
- administrador de alcances.

## Datos

- 20 mangas de piezas liberadas;
- 3 mangas bloqueadas/incompatibles;
- una solicitud realista de Armado;
- un remanente retornable;
- saldos MP en kg y PT en UN;
- lector QR configurado con Enter.

## A — Alcance

- [ ] A01 desde instalación sin almacenes, crear códigos/nombres elegidos por
  planta, jerarquía, compatibilidades y punto de pickup;
- [ ] A02 almacenero de PT no ve totales/códigos de MP ni Piezas;
- [ ] A03 capacidad sin scope no permite leer/mover;
- [ ] A04 scope sin capacidad permite lectura o bloquea acción según matriz;
- [ ] A05 supervisor transversal consulta sin adquirir acciones;
- [ ] A06 desactivar ubicación preserva historia y bloquea operaciones nuevas;
- [ ] A07 comparar saldos y IDs antes/después del backfill.

## B — Entrada multi-QR

- [ ] B01 fijar el almacén/recepción creados en A01 y escanear 12 mangas;
- [ ] B02 repetir QR y usar una incompatible: quedan fuera con explicación;
- [ ] B03 confirmar 12 y comprobar 12 movimientos/existencias sin duplicado;
- [ ] B04 replay técnico devuelve el mismo resultado;
- [ ] B05 cancelar borrador no altera Kardex.

## C — Picking y entrega

- [ ] C01 reservar 10 mangas para una solicitud; libre baja, físico no cambia;
- [ ] C02 cerrar picking; permanece en origen y se muestra staging/listo;
- [ ] C03 despachar: origen baja, tránsito sube, total físico global igual;
- [ ] C04 recibir en Mesa: tránsito baja, staging sube;
- [ ] C05 comprobar que recepción no registra consumo ni genealogía de salida.

## D — Pickup

- [ ] D01 preparar lote como `LISTO_PARA_PICKUP`;
- [ ] D02 receptor de Armado escanea en el punto acordado;
- [ ] D03 el solicitante acepta custodia y el Kardex acredita directamente
  `MESA_ARMADO`, sin tránsito intermedio ni consumo;
- [ ] D04 quedan preparador, receptor, punto configurable, horas y handoff;
- [ ] D05 un actor no autorizado no puede recoger;

## E — Diferencia y concurrencia

- [ ] E01 despachar 10 y recibir 9: una queda en tránsito/incidencia;
- [ ] E02 dos sesiones compiten por la misma manga: solo una confirma;
- [ ] E03 transferencia envejecida aparece en Control y no se autocierra;
- [ ] E04 corrección conserva eventos originales y requiere segregación.
- [ ] E05 diferencia aparece inmediatamente en Control/Alertas con un solo ID;
- [ ] E06 manga pesada pendiente de recepción no alerta antes de 24 h y crea
  una sola alerta al superar el umbral; no nace inventario automáticamente.

## F — Retorno

- [ ] F01 consumir parcialmente una manga en Armado;
- [ ] F02 solicitar y despachar remanente: pasa por tránsito de retorno;
- [ ] F03 recibir en ubicación compatible: queda disponible según Calidad;
- [ ] F04 identidad, cantidad y genealogía coinciden antes/después.

## G — Vistas especializadas

- [ ] G01 Piezas/WIP muestra recepción, picking, mesa y retorno;
- [ ] G02 MP muestra kg/lotes/emisión sin mangas PT;
- [ ] G03 PT muestra recepción/calidad/disponibilidad sin piezas internas;
- [ ] G04 Control consolida el mismo ledger sin sumar UN y KG;
- [ ] G05 búsqueda por QR muestra ubicación, custodio y timeline;
- [ ] G06 usuario fuera de scope no obtiene resultados por búsqueda/export;
- [ ] G07 `as_of` y snapshot desactualizado son visibles.

## H — Dispositivos y accesibilidad

- [ ] H01 recorrido de 20 QR con lector y Enter sin mouse;
- [ ] H02 390/768/1440 sin overflow ni acción primaria oculta;
- [ ] H03 Tab/Shift+Tab, foco visible y mensajes legibles por lector de pantalla;
- [ ] H04 duplicado/error tienen señal textual, no solo color/sonido.

## Evidencia

- saldos por origen, tránsito y destino antes/después;
- IDs de transferencia, movimientos y operation keys;
- QR/códigos y actores de entrega/recepción;
- capturas de las tres vistas y Control;
- tiempos reales de picking/pickup/recepción;
- decisiones operativas pendientes y responsables.

## Puerta de aprobación

No aprobar TS-018 para producción hasta validar el setup configurable, pickup
directo a Mesa, diferencias y alerta de 24 horas con usuarios de planta. DEV se
crea únicamente después de esa aprobación.
