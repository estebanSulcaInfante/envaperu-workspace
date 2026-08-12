---
tipo: user_story
id: US-012B
titulo: "Configuración física, color y formulación desde el alta guiada"
estado: implementada-local-pendiente-uat
tags: [catalogo, molde, pieza, color, receta, ux-premium]
fecha_creacion: 2026-08-10
fecha_actualizacion: 2026-08-10
epica: "[[US-012_Alta_Guiada_Integral_de_ProductoTerminado]]"
tech_spec: "[[../03_Tech_Specs/TS-017B_Configuracion_Fisica_Formulaciones_y_UX_Premium]]"
---

# US-012B: Configuración física, color y formulación

## Descripción

**Como** trabajador conocedor del producto y la planta  
**Quiero** completar COMPONENTES y COLORES dentro del mismo expediente  
**Para** dejar las salidas físicas fabricables sin navegar entre múltiples maestros.

## Alcance

- crear o reutilizar molde y piezas;
- capturar cavidades y peso operativo en MoldePieza;
- habilitar colores con cobertura atómica para todas las salidas activas del molde;
- crear/reutilizar materias primas, colorantes y aditivos estrictamente necesarios;
- crear formulaciones como borrador y publicar cuando el actor esté autorizado;
- asociar imágenes a PiezaColor;
- vista previa creada/reutilizada y matriz de cobertura;
- ayuda contextual premium con una mascota mínima, accesible y descartable.

## Escenarios ATDD

### AGP-B01 — Molde de varias salidas

**Dado** un molde con cuatro piezas activas y seis colores seleccionados  
**Cuando** el paso COMPONENTES se completa  
**Entonces** resuelve veinticuatro combinaciones PiezaColor, creadas o reutilizadas  
**Y** no permite cobertura parcial por color.

### AGP-B02 — Pieza reutilizable sin clasificación comercial heredada

**Dado** una pieza nueva que será usada por el PT actual y potencialmente por otros  
**Cuando** se crea desde la sesión  
**Entonces** no recibe silenciosamente Línea/Familia comercial del PT  
**Y** su clasificación técnica puede permanecer vacía.

### AGP-B03 — Formulación completa

**Dado** un color, una resina y pigmentos existentes con dosis confirmadas  
**Cuando** el actor guarda la formulación  
**Entonces** la suma de fracciones de materia prima es `1` y las dosis conservan su base en kg  
**Y** puede publicarla sólo con la capacidad correspondiente.

### AGP-B04 — Transparente sin pigmento

**Dado** una pieza incolora y una resina virgen confirmada  
**Cuando** el actor elige **Sin pigmento**  
**Entonces** se crea una formulación con materia prima fracción `1` y sin colorantes  
**Y** la UI no confunde esa condición con “sin formulación”.

### AGP-B05 — Ingrediente faltante

**Dado** una receta de Excel que menciona un pigmento no existente o ambiguo  
**Cuando** el usuario no puede confirmar su identidad  
**Entonces** registra el componente como pendiente con su fuente  
**Y** no crea un material aproximado ni publica la formulación.

### AGP-B06 — Volver después de completar

**Dado** COMPONENTES y COLORES ya completados por la sesión  
**Cuando** el usuario vuelve para corregir una formulación en borrador  
**Entonces** edita el borrador canónico  
**Y** si la revisión ya estaba aprobada, crea una revisión nueva en lugar de sobrescribirla.

### AGP-B07 — Ayuda premium accesible

**Dado** COMPONENTES o COLORES abierto  
**Cuando** aparece la mascota contextual  
**Entonces** resume la razón del paso y el siguiente bloqueo en texto accesible  
**Y** puede ocultarse, no roba foco, no contiene la única explicación y respeta `prefers-reduced-motion`.

## Fuera de alcance

- extracción automática desde Excel;
- animación compleja, voz o conversación libre con la mascota;
- inferir resina, peso, color o dosis por similitud.

## Definición de preparada

- [x] Regla de color atómico y formulación gobernada existentes.
- [x] Tratamiento de “sin pigmento” y datos faltantes definido.
- [x] Límites premium/accesibilidad definidos.
