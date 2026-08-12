---
tipo: flujo
estado: aceptado
fecha_creacion: 2026-08-01
fecha_actualizacion: 2026-08-01
tags: [flujo, uml, ot, manga, preetiqueta, pesaje, ux]
relaciones:
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[2026-08-01_Stickers_Prepesaje_como_Orden_Fisica_de_Manga]]"
---

# Distribución de stickers y pesaje sin PC en máquina

```mermaid
sequenceDiagram
    autonumber

    actor Supervisor
    participant SCM
    participant Balanza as PC de Balanza
    actor Maquinista

    Supervisor->>SCM: Crear OT y asignar mangas
    SCM->>SCM: Reservar identidad y cantidad por manga
    Supervisor->>SCM: Solicitar hoja de OT y preetiquetas
    SCM->>Balanza: Enviar trabajo de impresión 2-up
    Balanza-->>Supervisor: Imprimir hoja y preetiquetas

    Supervisor->>Maquinista: Entregar trabajo y stickers
    Maquinista->>Maquinista: Colocar sticker en manga vacía
    Maquinista->>Maquinista: Producir, contar y llenar manga

    Maquinista->>Balanza: Escanear QR y colocar manga
    Balanza->>SCM: Consultar identidad y asignación
    SCM-->>Balanza: Devolver contexto de solo lectura

    alt Cantidad coincide con la asignada
        Balanza->>SCM: Confirmar bruto, tara y neto
        SCM->>SCM: Confirmar cantidad asignada y salida
        SCM-->>Balanza: Autorizar etiqueta final
    else Cantidad diferente
        Maquinista->>Supervisor: Informar faltante o excedente
        Supervisor->>SCM: Ajustar o conciliar con motivo
        SCM-->>Balanza: Actualizar cantidad autorizada
        Balanza->>SCM: Confirmar bruto, tara y neto
        SCM->>SCM: Confirmar cantidad conciliada y salida
    end

    Balanza-->>Maquinista: Imprimir etiqueta final
```

La flecha `Supervisor -> Maquinista` representa una entrega física. No existe
una interfaz SCM en la máquina. El maquinista no digita la cantidad ni elige
documentos; el QR recupera la asignación preparada por el supervisor.
