---
tipo: arquitectura_frontend
estado: aprobado-para-implementacion
tags: [frontend, scm, guia-usuario, markdown, documentacion, diataxis, vite, react]
fecha_creacion: 2026-08-03
fecha_actualizacion: 2026-08-03
relacionados:
  - "[[Arquitectura_Navegacion_Por_Procesos]]"
  - "[[SCM_Frontend_Overview_US-010]]"
  - "[[Guia_Operativa_SCM_US-010]]"
  - "[[Guia_Roles_y_Permisos_SCM_Piloto]]"
  - "[[UAT_00_Preflight_Piloto_Limpio_2026-08-03]]"
  - "[[UAT_01_Configuracion_Participantes_y_Permisos]]"
  - "[[UAT_TS-010P_Flujo_Demanda_Fabricacion_Armado]]"
  - "[[UAT_TS-010C_D_OT_Mangas_Pesaje]]"
  - "[[UAT_TS-010I_Recepcion_Mangas_Kardex]]"
---

# Arquitectura de la Guía SCM basada en Markdown

## Contexto

La ruta `/guia/scm` existe como superficie de soporte transversal, pero su
contenido actual se mantiene en `frontend/src/data/scmGuide.js`. Ese arreglo
mezcla walkthroughs de mocks, conceptos futuros, rutas antiguas y estados de
implementación que ya no describen el piloto.

Editar una instrucción obliga hoy a modificar JavaScript. Además, la guía puede
contradecir el código y las UAT porque no posee metadatos verificables de estado,
fecha, alcance o caso de aceptación.

## Decisión

La guía de usuario del piloto se escribirá en archivos Markdown versionados y
se renderizará dentro del frontend React existente en `/guia/scm`.

La fuente propuesta es:

```text
frontend/src/content/scm-guide/
  00-inicio-piloto.md
  01-participantes.md
  02-maestros-imagenes.md
  03-op-cobertura-planificacion.md
  04-of-oa-ot.md
  05-mangas-preetiquetas.md
  06-pesaje-postetiqueta.md
  07-correccion-anulacion.md
  08-recepcion-calidad-kardex.md
  09-reversa-stickers.md
  10-contingencias.md
  90-fuera-del-piloto.md
  99-glosario.md
```

`obsidian_vault/03_Frontend` documenta la arquitectura y las decisiones. Los
Markdown que consume la aplicación viven junto al frontend para que el build
contenga exactamente la guía correspondiente a esa versión del piloto.

## Tecnología

- `react-markdown` para renderizar CommonMark de forma segura dentro de React;
- `remark-gfm` para tablas, listas de tareas y convenciones GitHub Flavored
  Markdown;
- `import.meta.glob` de Vite para descubrir los archivos y cargarlos como texto;
- frontmatter YAML para estado, roles, rutas, UAT y fecha de validación;
- componentes MUI para títulos, tablas, avisos, enlaces internos y badges;
- índice de búsqueda local construido durante el build;
- estilos de impresión para exportar una sección a PDF desde el navegador.

No se habilitará HTML crudo en Markdown. Si en el futuro se habilita, deberá
incorporarse sanitización explícita.

Referencias técnicas:

- https://github.com/remarkjs/react-markdown
- https://github.com/vitejs/vite/blob/main/docs/guide/features.md
- https://diataxis.fr/

## Alternativas descartadas en este incremento

| Alternativa | Decisión |
|---|---|
| Mantener `scmGuide.js` | Descartada: contenido acoplado al código y difícil de revisar. |
| MDX | Diferida: permite JSX, pero añade complejidad editorial innecesaria. |
| Docusaurus | Diferida: útil para un portal externo y versionado, pero duplica frontend y despliegue. |
| VitePress | Descartada para integración: introduciría una aplicación Vue separada. |
| MkDocs | Diferida: adecuado para sitio documental externo, no para la ruta React integrada. |

## Organización editorial

Se aplicará Diátaxis sin convertir la navegación en una taxonomía académica:

1. **Primer recorrido:** tutorial del piloto desde participantes hasta reversa.
2. **Cómo hacer:** procedimientos operativos por tarea y rol.
3. **Referencia:** estados, códigos, capacidades, glosario y errores.
4. **Comprender:** explicaciones breves de OP, OF, OA, OT, manga, Kardex y
   trazabilidad.

La ruta principal prioriza procedimientos. Las explicaciones y referencias se
enlazan como apoyo y no interrumpen la tarea.

## Metadatos obligatorios

Cada página debe comenzar con:

```yaml
---
titulo: Anular un pesaje
slug: correccion-anulacion/anular-pesaje
estado: pendiente-uat
piloto: true
roles: [GERENTE_GENERAL, JEFE_PRODUCCION]
ruta: /produccion/ot-mangas
uat: UAT-D-09
actualizado: 2026-08-03
---
```

Estados permitidos:

| Estado | Uso |
|---|---|
| `pendiente-uat` | Implementado, pero todavía no aceptado por usuarios. |
| `aprobado-piloto` | UAT aprobada y procedimiento autorizado para el piloto. |
| `contingencia-manual` | Procedimiento temporal explícito y controlado. |
| `fuera-piloto` | Funcionalidad que no forma parte del alcance actual. |
| `no-implementado` | Diseño futuro sin operación disponible. |

No se utilizarán etiquetas ambiguas como `mock validable`, `próxima fase` o
`por normalizar` en la guía de usuario.

## Plantilla de procedimiento

```markdown
# Anular un pesaje

## Cuándo utilizarlo

## Antes de comenzar

## Procedimiento

## Resultado esperado

## Qué no debe hacerse

## Contingencia

## Problemas frecuentes
```

Los pasos usan los nombres visibles de la interfaz. Los códigos técnicos sólo se
incluyen cuando ayudan a reconocer un error o sirven como evidencia.

## Alcance visible del piloto

La guía principal cubrirá:

1. participantes y permisos;
2. maestros e imágenes;
3. OP, cobertura y planificación;
4. OF, OA y OT;
5. mangas y preetiquetas;
6. pesaje y postetiqueta;
7. corrección y anulación;
8. recepción, Calidad y Kardex;
9. reversa y conciliación 11213–11216;
10. contingencias de estación, balanza, impresora y QR.

Las secciones implementadas permanecen como `pendiente-uat` hasta que la UAT
correspondiente sea aprobada.

## Funciones fuera del piloto

No se mezclarán con el recorrido principal. La página **Fuera del piloto** debe
indicar por cada módulo:

- qué función no está disponible;
- por qué quedó fuera del alcance;
- qué procedimiento temporal se usa;
- quién es responsable;
- qué acción está prohibida;
- qué evento habilitaría su incorporación.

Una ruta no implementada no se mostrará como botón operativo. Una contingencia
manual nunca debe simular éxito ni crear datos ficticios para reemplazar el
módulo ausente.

## Relación entre UAT y guía

La UAT conserva casos, datos, evidencias y criterios de aceptación. La guía
explica la operación normal aprobada.

Regla de mantenimiento:

1. la sección nace como `pendiente-uat`;
2. se ejecuta la UAT relacionada;
3. se incorporan nombres y pasos validados por el usuario;
4. el mismo cierre cambia el estado a `aprobado-piloto`;
5. un defecto posterior actualiza guía, UAT y código según corresponda.

No se copiarán íntegramente los casos de prueba dentro de la guía.

## Navegación y experiencia

`/guia/scm` debe ofrecer:

- inicio con alcance, versión y progreso de UAT;
- índice por proceso y por rol;
- búsqueda por título, texto, código y error;
- badge visible de madurez;
- enlaces a las rutas reales del sistema;
- aviso destacado para contingencias y exclusiones;
- navegación anterior/siguiente;
- impresión de una sección;
- glosario accesible desde cualquier página.

## Migración del contenido actual

1. Congelar `scmGuide.js` como fuente histórica, sin seguir ampliándolo.
2. Clasificar sus secciones en vigente, obsoleta o fuera del piloto.
3. Crear primero Inicio y Participantes desde la UAT 01.
4. Migrar Maestros e imágenes durante su UAT.
5. Incorporar las demás páginas conforme avanzan TS-010P, C/D e I.
6. Retirar el arreglo JavaScript cuando todos los enlaces del piloto provengan
   de Markdown.
7. Mantener una prueba automática que falle ante slug duplicado, estado inválido,
   ruta inexistente o UAT obligatoria ausente.

## Criterio de terminación

La migración se considera completa cuando:

- `/guia/scm` no depende de `scmGuide.js`;
- toda sección posee frontmatter válido;
- no aparecen mocks como instrucciones operativas;
- lo fuera del piloto está separado y tiene contingencia explícita;
- cada flujo aprobado enlaza a su ruta real;
- las UAT aprobadas y la guía muestran el mismo estado;
- build, pruebas de contenido, navegación e impresión están verdes.