---
tipo: tech_spec
id: TS-017B
titulo: "Configuración física, formulaciones y UX premium"
estado: implementada-local-pendiente-uat
tags: [catalogo, molde, pieza, color, receta, frontend, ux]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
user_story: "[[../02_User_Stories/US-012B_Configuracion_Fisica_Color_y_Formulacion]]"
relaciones:
  - "[[TS-012_Normalizacion_Relacion_Molde_Pieza_NM]]"
  - "[[TS-016_Maestro_Colores_y_Recetas]]"
  - "[[TS-017A_Sesion_Durable_y_Shell_de_Alta_Guiada]]"
---

# TS-017B: Configuración física, formulaciones y UX premium

## 1. Objetivo técnico

Implementar los pasos `COMPONENTES` y `COLORES` sobre servicios canónicos de Molde, Pieza, PiezaColor, Material y Receta, preservando la sesión durable y la clasificación decidida para PT/Pieza.

## 2. Contrato de COMPONENTES y COLORES

`PUT /api/scm/v1/altas-producto/{id}/pasos/{codigo}` conserva un borrador sin materializar maestros. La aplicación canónica e idempotente usa:

`POST /api/scm/v1/altas-producto/{id}/pasos/{codigo}/aplicar`

con `Idempotency-Key` UUID y body `{expected_version, application_key, data}`. `application_key` permanece estable durante un intento `PARTIAL`; no se deriva nuevamente del payload corregido.

Shape efectivo de `COMPONENTES`:

```json
{
  "molde": {
    "modo": "NUEVO|REUTILIZAR",
    "ref": "ML-000001",
    "nombre": "Molde Portavajillas",
    "peso_tiro_gr": 320,
    "tiempo_ciclo_std": 30
  },
  "piezas": [
    {
      "client_id": "pieza-tapa",
      "modo": "NUEVA|REUTILIZAR",
      "ref": 10,
      "nombre": "Tapa",
      "cavidades": 1,
      "peso_unitario_gr": 80
    }
  ]
}
```

Shape efectivo de `COLORES`:

```json
{
  "colores": [
    {
      "client_id": "transparente",
      "modo": "NUEVO|REUTILIZAR",
      "color_ref": 5,
      "nombre": "Transparente",
      "familia_color_id": 2,
      "hex": "#FFFFFF"
    }
  ],
  "matriz": [
    {
      "pieza_ref": 10,
      "color_client_id": "transparente",
      "seleccionada": true
    }
  ],
  "formulaciones": [
    {
      "color_client_id": "transparente",
      "tipo": "EXISTENTE|NUEVA|SIN_PIGMENTO|PENDIENTE",
      "receta_ref": 8,
      "base_virgen_kg": 1,
      "componentes": []
    }
  ]
}
```

Las referencias pueden usar `*_ref` o el `client_id` estable de una unidad creada en la misma aplicación. La respuesta y `pasos[].application_status` exponen `created`, `reused`, `pending` y `resolved_references`. Una unidad ya resuelta queda bloqueada durante un reintento parcial; sólo se corrige la unidad pendiente.

## 3. Orquestación

Orden idempotente de resolución canónica:

1. crear/reutilizar Molde;
2. crear/reutilizar Piezas sin heredar clasificación comercial;
3. crear/reactivar `MoldePieza` con cavidades y peso;
4. habilitar cada color mediante el comando atómico del molde completo;
5. crear/reutilizar ingredientes explícitamente confirmados;
6. crear/actualizar formulaciones en BORRADOR;
7. asociar imágenes a PT o PiezaColor mediante el endpoint multipart de la sesión;
8. publicar formulaciones sólo si fueron solicitadas, válidas y autorizadas.

Una falla después de haber materializado unidades puede dejar el paso `PARTIAL`, con journal y referencias suficientes para reanudar sin duplicar. `IDENTIDAD` se aplica antes de `COMPONENTES`, y `COMPONENTES` antes de `COLORES`. No se llama a la rama de ProductoTerminado/BOM plano de `/api/configurar-producto`.

## 4. Cambios de dominio y compatibilidad

- ajustar validaciones que hoy exigen Línea/Familia en Pieza antes de PiezaColor;
- impedir que nuevas PiezaColor usen sus campos legacy de clasificación como autoridad;
- mantener lectura de datos legacy durante expand/contract;
- emitir un reporte de filas cuya única clasificación viva en PiezaColor antes de retirar columnas;
- `PiezaColor` sigue siendo única por `pieza_id + color_produccion_id`.

## 5. Formulación de material

La UI usa el rótulo **Formulación de material**. Mapea a `RecetaColorMaestra` sin renombrar tablas en este incremento.

- **Con pigmento:** al menos una materia prima; fracciones suman `1`; colorantes/aditivos usan gramos y base kg.
- **Sin pigmento:** materia prima válida con suma `1`; cero colorantes es permitido.
- **Pendiente:** conserva fuente y texto no resuelto en la sesión, pero no crea una línea de receta libre ni permite publicar.
- Crear ingrediente exige la capacidad de catálogo material y el contrato completo de `ScmMaterial`; si falta, se ofrece **Registrar pendiente**, no un alta parcial.

## 6. UI premium mínima del piloto

La calidad premium procede de consistencia y feedback:

- matriz Pieza × Color con estados creada, reutilizada, falta formulación o falta imagen;
- previsualización antes de aplicar y resumen de cambios después;
- búsqueda por código/nombre sin tildes y opciones de reutilización visibles;
- animaciones de transición de `160–220 ms`, sin desplazar el contenido inesperadamente;
- skeletons en lugar de spinners globales;
- mensajes junto al campo y resumen de errores al inicio del paso;
- atajos documentados y orden de tabulación estable.

### Mascota contextual mínima

Componente `CatalogSetupCoach` con un SVG liviano de marca, tres estados (`NEUTRAL`, `ALERTA`, `COMPLETO`) y mensajes predefinidos por paso/código de bloqueo. Es colapsable, no intercepta el guardado, no usa voz ni red y nunca contiene información exclusiva. Con `prefers-reduced-motion: reduce` cambia de estado sin animación. En móvil aparece como bloque desplegable, no como overlay.

## 7. Seguridad y límites de imágenes

La carga usa:

`POST /api/scm/v1/altas-producto/{session_uuid}/imagenes/{entity_type}/{entity_id}`

- `entity_type`: `PRODUCTO_TERMINADO` o `PIEZA_COLOR`;
- headers: `X-Actor-Id` e `Idempotency-Key` UUID;
- `multipart/form-data`: `imagen`, `expected_version` y `application_key` estable;
- formatos: JPEG, PNG o WEBP, máximo 2 MB;
- el servidor decodifica con Pillow, verifica formato↔MIME, imagen completa, máximo 25 millones de píxeles y rechaza truncados/polyglots;
- la entidad debe pertenecer a las referencias resueltas de la sesión y el actor debe ser su propietario;
- el mismo Idempotency-Key y contenido devuelve `REPLAYED`; otro contenido produce conflicto;
- ni el borrador ni el journal guardan base64.

La respuesta agrega `image_results` con `entity_type`, `entity_id`, MIME, tamaño, SHA-256 e `imagen_url`. `GET` de la sesión expone el último metadata aplicado en `imagenes[]`. En S3 se usa una clave versionada por digest (`.../sha256-{digest}`): la imagen anterior no se sobrescribe antes del commit. Si el commit falla, se elimina best-effort sólo el objeto nuevo y se conserva coherencia con la metadata anterior.

## 8. Pruebas

| Escenario | Nivel |
|---|---|
| AGP-B01 | integración del comando de color de molde + UI de matriz |
| AGP-B02 | API/modelo: Pieza nullable y PiezaColor creada sin copia comercial |
| AGP-B03 | servicio de receta + PostgreSQL |
| AGP-B04 | API/UI “Sin pigmento” |
| AGP-B05 | UI/API: pendiente no crea material ni receta aprobada |
| AGP-B06 | integración de nueva revisión tras aprobación |
| AGP-B07 | unitario UI, teclado, axe y reduced-motion |
| AGP-B08 | multipart idempotente, scope de sesión, MIME real y límite 2 MB |

### Primera RED

`test_habilitar_color_en_pieza_sin_clasificacion_tecnica`: debe fallar mientras las validaciones vigentes obliguen a copiar Línea/Familia.

## 9. Puerta para TS-017C

- matriz completa Pieza × Color resoluble;
- ninguna variante genérica sin color creada;
- formulaciones y pendientes diferenciados;
- imágenes asociadas al SKU físico correcto;
- UX premium mínima y accesibilidad verdes.
