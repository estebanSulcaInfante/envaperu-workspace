---
tipo: prototipo_operativo
estado: provisional
historia: "[[US-010K3_Control_Avance_Kg_y_Contexto_Visible_en_Estacion]]"
ux_risk: high
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
fecha_creacion: 2026-08-31
fecha_actualizacion: 2026-09-03
tags: [scm, prototipo, pesaje, qr, foco, imagen]
---

# PROTO US-010K3: pesaje único y contexto visible

## Wireflow

```mermaid
flowchart TD
    A["Input QR enfocado"] --> B["Escáner pega texto + Enter"]
    B --> C["Anunciar QR leído / cambio de manga"]
    C --> D["MANGA ACTIVA + artículo/color + foto opcional"]
    D --> E{"Lectura estable"}
    E -->|No| F["Esperar; Pesar bloqueado con causa"]
    F --> E
    E -->|Sí| G{"Manga incompleta"}
    G -->|Marcada| H["Pesar F2: AVANCE_KG"]
    G -->|Apagada| I["Pesar F2: FINAL"]
    H --> J["Guardar kg + imprimir control; manga activa"]
    I --> K["Cerrar + imprimir final"]
    J --> L["Devolver foco al QR"]
    K --> L
    L --> A
```

## Jerarquía objetivo

```text
┌────────────────────────────────────────────────────────────┐
│ ✓ CAMBIO DE MANGA · …M001 → …M002                          │
├───────────────────────────────┬────────────────────────────┤
│ MANGA ACTIVA                  │ [ foto de pieza ]          │
│ OF000017-OT007-M002           │ o “Sin foto registrada”    │
│ IDENTIDAD DEL CONTENIDO                                    │
│ EMBUDO #4                                                  │
│ [muestra] ANARANJADO SÓLIDO   │                            │
│ OT / máquina / maquinista     │                            │
├───────────────────────────────┴────────────────────────────┤
│ PESO NETO REAL                                            │
│                         7.600 kg                           │
│                                                            │
│ [✓] Manga incompleta · registrar solo avance en kg         │
│ MODO: SEGUIRÁ ABIERTA · no confirma unidades               │
│                                                            │
│                 [ PESAR MANGA (F2) ]                        │
└────────────────────────────────────────────────────────────┘
```

Checkbox apagado cambia la línea de modo a:
`MODO: CIERRE FINAL · confirma el objetivo e imprime`.

El cierre final parcial se presenta como excepción supervisada secundaria y
no puede coexistir con `Manga incompleta`.

La muestra de color tiene 44 px, borde visible y nombre textual. Para la
familia `TRANSPARENTE` usa cuadriculado gris/blanco; el blanco sólido conserva
una muestra blanca con borde y por ello no se confunden. El patrón no invade
la tarjeta ni compite con el código de manga.

## Estados

| Estado | Señal primaria | Recuperación |
|---|---|---|
| Esperando QR | Input enfocado; no hay manga activa | Escanear + Enter |
| QR resuelto | Anuncio textual + código grande | Verificar pieza, color y foto |
| Inestable | `Esperando peso estable` | Mantener manga en balanza |
| Listo avance | `SEGUIRÁ ABIERTA` | Pesar/F2 |
| Listo final | `CIERRE FINAL` | Pesar/F2 |
| Guardando | Botón bloqueado y texto de progreso | Esperar/replay |
| Avance aceptado | Neto/aporte, `sigue abierta`, impresión | Foco vuelve al QR |
| Final aceptado | Neto final, estado e impresión | Foco vuelve al QR |
| Foto ausente | Placeholder textual | Ninguna; no bloquea |
| Error | Código/mensaje textual; sin éxito falso | Reintentar o escanear |

## Evidencia pendiente

- captura a resolución real de `PESAJE-PLANTA-01`;
- tres QR consecutivos sin mouse;
- foto con nombres largos y fallback;
- reconocimiento de Transparente frente a blanco sólido desde el puesto;
- doble F2/click y respuesta perdida;
- control real impreso sin conteo;
- reconocimiento del modo por operador representativo.
