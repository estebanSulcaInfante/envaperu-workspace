---
tipo: draft
estado: promovido-a-pipeline
tags: [scm, mom, mes, isa95, ot, trabajo-color, corrida, manga, refactor]
relaciones:
  - "[[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]]"
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
  - "[[Orden_Fabricacion]]"
  - "[[Registro_Diario]]"
  - "[[US-010C_Orden_Trabajo_Ejecucion_y_Planificacion_Bolsas]]"
  - "[[US-010D_Pesaje_Bolsas_Unidad_Logistica_y_Sincronizacion]]"
  - "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
  - "[[US-010L_Material_Segunda_Reproceso_y_Mezcla_Preparada_Trazable]]"
  - "[[2026-07-29_Separacion_OP_OF_OA_OT_y_Cobertura_NM]]"
  - "[[2026-07-30_OT_Diaria_Comun_para_Fabricacion_y_Armado]]"
fecha_creacion: 2026-08-07
fecha_actualizacion: 2026-08-08
---

# Draft: OT de máquina y Trabajo de color alineados con ISA-95

## 1. Estado de la evaluación

> [!success] Promovido el 2026-08-08
> El refactor de OT de Fabricación y Trabajo de color fue aprobado mediante
> [[2026-08-08_OT_de_Maquina_y_Trabajo_de_Color_en_Piloto]] y promovido a la
> épica [[US-010M_OT_de_Maquina_y_Trabajo_de_Color|US-010M]], dividida en M1,
> M2 y M3. Este draft queda como evidencia del análisis; la decisión, las US y
> las TS son la autoridad para desarrollo.

El cambio se trata como un cambio de agregado y no como un renombre de interfaz.

Resultado propuesto:

```text
OT de máquina/turno
├── Trabajo de color 01
├── Trabajo de color 02
└── Trabajo de color 03
```

La OT conserva el documento conocido por Planta. La atomicidad técnica baja al
`Trabajo de color`.

## 2. Contraste con prácticas estándar

No existe una nomenclatura SCM universal que obligue a llamar OT a la unidad
atómica. ISA-95/IEC 62264 separa la programación del trabajo, la unidad de
trabajo ejecutable y la respuesta real. La guía pública de Job Control resume
la jerarquía como `Work Schedule -> Work Request -> Job Order`; un `Job Order`
es la unidad de trabajo despachada a un centro o línea.

La correspondencia siguiente es conceptual y no constituye certificación
formal ISA-95:

| EnvaPerú | Correspondencia aproximada |
|---|---|
| OP | Production/Operations Request |
| OF y sus corridas | Work Request y requisitos homogéneos de fabricación |
| OT de máquina/turno | Work Schedule o envolvente local de despacho |
| Trabajo de color | Job Order ejecutable |
| Ruta, receta y configuración aprobadas | Work Master / Workflow Specification |
| Requisitos de máquina, material y personal | Resource Requirements |
| Ejecución, relevos, consumo, merma y pesaje | Job Response / Work Performance |
| Manga | Sublote material contenido en una unidad logística identificada |

Referencias oficiales consultadas:

- https://www.isa.org/standards-and-publications/isa-standards/isa-95-standard
- https://reference.opcfoundation.org/specs/OPC-10031-4/4
- https://www.isa.org/standards-and-publications/isa-standards/isa-88-standards
- https://learn.microsoft.com/en-us/dynamics365/supply-chain/production-control/production-process-overview
- https://support.gs1.org/support/solutions/articles/43000734289-what-is-a-logistics-unit-and-how-is-it-identified-

## 3. Definición de dominio propuesta

### 3.1. OT de máquina

Documento de despacho por:

- máquina o centro exactos;
- fecha operativa;
- turno;
- tipo de proceso;
- cola ordenada de trabajos;
- responsable predeterminado opcional;
- estado agregado y auditoría.

La OT deja de contener directamente OF, corrida, color, receta, cupos,
contadores o snapshots técnicos de una ejecución concreta. Puede contener
trabajos de distintas OF si realmente representa toda la jornada de la
máquina.

### 3.2. Trabajo de color

Nombre de Planta para la unidad ejecutable atómica de Fabricación. No se define
solamente por `color_id`, sino por un contexto técnico homogéneo:

- una OF exacta;
- una `CorridaFabricacion` exacta;
- color y receta gobernados por esa corrida;
- molde, ruta y snapshots compatibles;
- objetivo y cupo asignados;
- salidas esperadas;
- intervalos, asignaciones y resultado real.

Aunque el nombre visible sea `Trabajo de color`, internamente conviene modelar
un `TrabajoOT` genérico con una especialización de Fabricación.

```text
scm_orden_trabajo
└── scm_trabajo_ot
    ├── scm_trabajo_color
    └── scm_trabajo_armado
```

Así Fabricación y Armado no terminan dando dos significados diferentes a la
misma OT.

### 3.3. Corrida y Trabajo de color

La corrida conserva la especificación homogénea de color, receta, materiales,
ciclos y salidas. Un mismo objetivo de corrida puede requerir varios Trabajos
de color en distintas OT diarias o máquinas.

`Trabajo de color` no es una operación de ruta. Soplado, inyección, pintado y
armado siguen siendo operaciones tecnológicas de la ruta. El Trabajo de color
es la unidad de despacho que ejecuta una corrida en un recurso concreto.

### 3.4. Frontera con material preparado

El refactor aprobado solo puede atribuir al Trabajo de color la reserva,
emisión y consumo ordinarios de una receta aprobada. No incorpora lote de
material preparado, formulación experimental, dosificación medida ni
generaciones `R1…Rn`. Esas capacidades continúan exclusivamente en
[[US-010L_Material_Segunda_Reproceso_y_Mezcla_Preparada_Trazable|US-010L]] y
quedan fuera del piloto.

## 4. Invariantes recomendadas

### OT

1. Una OT pertenece a una máquina/centro, fecha operativa, turno y tipo de
   proceso.
2. Solo un trabajo puede estar `EN_EJECUCION` en la misma máquina e instante.
3. La OT no duplica color, receta, corrida u objetivo de sus hijos.
4. La OT cierra únicamente cuando sus trabajos y excepciones están resueltos.
5. El estado y las cantidades de OT son proyecciones de sus trabajos; no otra
   fuente editable.

### Trabajo de color

1. Referencia exactamente una OF y una corrida perteneciente a esa OF.
2. Obtiene color y receta de la corrida; no admite texto libre equivalente.
3. Conserva secuencia, cuota, snapshots, contadores, tiempos y estados propios.
4. Puede tener varias salidas simultáneas cuando el molde es multipieza.
5. Un relevo de trabajador crea otra asignación por intervalo, no otro trabajo.
6. Una parada sin cambio de contexto pausa y reanuda el mismo trabajo.
7. Un cambio de corrida, receta, molde, producto, máquina o límite de Calidad
   crea otro trabajo.
8. Volver de color A a B y luego a A puede reanudar el trabajo A únicamente si
   conserva la misma corrida, receta y límite de lote; los intervalos de
   ejecución y los cambios de configuración quedan separados. En otro caso se
   crea un trabajo continuación.
9. El cambio de color registra preparación, limpieza/purga, tiempo y merma
   entre trabajos.
10. La emisión o consumo ordinario que ya exista puede atribuirse al trabajo;
    no infiere compatibilidad solo por el nombre del color.
11. No crea ni acepta formulaciones experimentales o lotes preparados dentro
    del alcance M1–M3.

### Manga

1. La manga referencia un `TrabajoOT` y una salida exacta, no solo la OT.
2. Cupo, sticker, pesaje, consumo y resultado se atribuyen al trabajo.
3. El QR conserva la identidad estable de manga; la versión de etiqueta es una
   identidad separada.
4. Una manga no mezcla trabajos, corridas, recetas o colores incompatibles.
5. La anulación prepesaje devuelve cupo de manera transaccional.

## 5. Relevos y frontera multi-jornada

El trabajador no forma parte de la identidad de OT ni de Trabajo de color. Se
registra mediante asignaciones auditadas por intervalo.

La OT debe continuar diaria/por turno. No se recomienda volverla
multi-jornada para resolver una manga lenta, porque se perderían cortes diarios
y responsabilidad por turno.

El piloto M3 se limita a relevos dentro de la misma OT. La propuesta siguiente
se conserva como entrada de US-010K y **no** forma parte de M1–M3:

- `trabajo_color_origen_id` inmutable;
- `TramoMangaTrabajoColor` para cada aporte posterior;
- OT, trabajo, máquina, trabajador, inicio, fin y control de frontera;
- continuidad únicamente sobre la misma corrida, salida y color compatibles;
- cierre de la OT anterior después de una transferencia formal, sin cerrar la
  vida logística de la manga.

Hasta aprobar US-010K, el flujo de M rechaza la transferencia de una manga a
otra OT, turno o fecha y no registra pesajes intermedios.

## 6. UX de Planta

La OT sigue siendo el documento conocido por el trabajador. El maquinista no
necesita conocer códigos internos de Trabajo de color.

```text
OT-000123 · Haitian 3000 · Turno día
├── Verde sólido · EN EJECUCIÓN · 8 mangas
├── Azul · LISTO · 5 mangas
└── Rojo · PENDIENTE · 4 mangas
```

El encargado usa `Iniciar`, `Pausar`, `Reanudar`, `Completar` y `Anular`. El
maquinista continúa escaneando únicamente sus QR de manga.

## 7. Impacto técnico comprobado

El código actual está acoplado a `OT = una corrida/color`:

- `RegistroDiarioProduccion` contiene OF, corrida, snapshots y contadores;
- asignación de plan, manga y solicitud extra apuntan directamente a OT;
- el servicio crea OT, cupo y mangas como una sola ejecución monocolor;
- pesaje deriva OF/corrida desde `manga.ot` y agrega kg por OT;
- la vista crea OT seleccionando directamente OF y corrida;
- etiquetas y estación muestran el contexto monocolor de la OT.

Inventario preliminar de impacto:

- 18 archivos de backend;
- 9 archivos de frontend y estación;
- al menos 11 suites automatizadas;
- al menos 25 documentos del vault.

La implementación debe incluir, como mínimo:

1. `scm_trabajo_ot` y `scm_trabajo_color`;
2. FKs de trabajo en mangas, asignaciones, extras y detalles;
3. cupo y salida por Trabajo de color;
4. estado agregado de OT;
5. activación exclusiva por máquina;
6. asignaciones de personal por intervalo;
7. cambio de configuración y merma de purga;
8. contratos de etiqueta y estación;
9. pesaje, corrección, anulación, Almacén, Calidad y Kardex;
10. adaptador explícito para conservar las OT de Armado sin crear
    `TrabajoArmado` en este incremento.

Material preparado, formulación experimental y generaciones de reproceso no
forman parte del inventario de impacto aprobado.

## 8. Migración recomendada

Aplicar `expand -> backfill -> cutover -> contract`:

1. crear tablas y FKs nuevas sin eliminar columnas vigentes;
2. crear un Trabajo de color por cada OT monocolor existente;
3. copiar OF, corrida, snapshots, contadores y objetivos al trabajo;
4. enlazar mangas, asignaciones y extras al trabajo creado;
5. preservar UUID y códigos de OT, manga, etiqueta y pesaje;
6. conservar `payload_json` histórico de etiquetas;
7. cambiar lecturas y escrituras al nuevo agregado;
8. retirar columnas directas de OT en una migración posterior.

Antes de migrar Producción se debe contar el estado real del Supabase. La base
local contiene muy pocos registros transaccionales, pero no certifica el
entorno desplegado.

## 9. Cierre de lagunas para M1–M3

La decisión del 2026-08-08 cerró el corte del piloto:

1. OT representa máquina, fecha, turno y proceso y admite trabajos de OF/moldes
   compatibles.
2. Se implementa `TrabajoOT/TrabajoColor`; Armado permanece como adaptador.
3. Multi-jornada y pesaje intermedio permanecen en US-010K.
4. A → B → A reanuda solo con corrida, receta, molde y límite de Calidad
   idénticos; en otro caso crea continuación.
5. La purga se registra como cambio de configuración y merma, sin material
   preparado.
6. La devolución de cupo prepesaje y `ANULAR_PESAJE` son transaccionales.
7. Responsable productivo y actor real de Balanza son identidades separadas.
8. OT es una proyección y no se reabre silenciosamente por una compensación.
9. US-010L queda fuera del piloto.

## 10. Dictamen aprobado

Se confirma para el piloto el siguiente modelo:

> OT = documento de despacho diario de máquina/turno.
>
> Trabajo de color = unidad ejecutable, atómica y trazable de Fabricación.
>
> Corrida = requisito técnico homogéneo que uno o más trabajos atienden.
>
> Manga = unidad identificada producida por un trabajo y una salida exactos.

Este modelo reduce la proliferación visible de OT sin sacrificar trazabilidad
y se aproxima al patrón estándar `Work Schedule -> Job Order -> Job Response`.
La ADR aceptada sustituye parcialmente las decisiones que fijaban
`OT = una corrida/color`. US-010M1/M2/M3, sus TS y documentos DEV gobiernan la
implementación.
