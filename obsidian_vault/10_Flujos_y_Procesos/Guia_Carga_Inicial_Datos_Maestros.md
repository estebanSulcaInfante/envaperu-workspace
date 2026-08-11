# Guía de carga inicial de datos maestros

> [!IMPORTANT] Entrada principal propuesta
> Para un ProductoTerminado nuevo, el recorrido canónico será **Datos maestros > Alta guiada de producto**, definido por [[../05_Especificaciones/02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado|US-012]]. Hasta que TS-017 complete desarrollo y UAT, esta guía continúa describiendo el orden manual vigente.

## Objetivo

Orientar a la persona que carga catálogos por primera vez y evitar duplicados o registros que todavía no puedan utilizarse en producción.

## Regla antes de crear

1. Buscar el nombre completo y una parte significativa del nombre.
2. Revisar también los registros inactivos.
3. Si existe uno parecido, consultar al responsable antes de crear otro.
4. No reutilizar un registro para representar una entidad diferente.
5. Los códigos SCM son automáticos e inmutables; no se digitan.

## Secuencia recomendada

### Recorrido integral de seis fases

El asistente nuevo conserva esta misma dependencia en una sola sesión durable:

1. `IDENTIDAD`: ProductoTerminado, clasificación, procedencia y duplicados.
2. `COMPONENTES`: molde, piezas, cavidades y pesos.
3. `COLORES`: variantes, formulaciones e imágenes.
4. `ESTRUCTURA`: BOM y WIP.
5. `RUTA_EMPAQUE`: ruta, recursos, perfiles y reglas.
6. `REVISION`: readiness y publicación o envío a aprobación.

Se puede volver a cualquier fase anterior. Si el dato aún es borrador se edita en la sesión; si ya es una revisión aprobada, la corrección crea una nueva revisión. No se elimina información canónica para simular un retroceso.

### 1. Base de clasificación y planta

- Crear líneas.
- Crear familias.
- Asociar cada familia con las líneas en las que puede utilizarse.
- Crear trabajadores.
- Crear máquinas.

La asociación Línea–Familia debe existir antes de crear piezas o productos que utilicen esa combinación.

En una alta integral, Línea y Familia clasifican comercialmente al ProductoTerminado. La clasificación de Pieza es técnica y opcional; no se copia silenciosamente desde el PT. Crear una Familia dentro del selector de una Línea debe asociarla y seleccionarla en la misma operación.

### 2. Abastecimiento y color

- Crear categorías de recepción.
- Crear proveedores.
- Crear materias primas, recuperado, colorantes y aditivos.
- Crear familias de color, colores de producción y recetas.

En la nueva interfaz se usa el término **Formulación de material**. Una salida sin pigmento todavía requiere una formulación de resina base; no debe confundirse con una formulación ausente.

Las recetas requieren que sus materiales ya existan. La unidad base de inventario de materiales es `KG`; una receta puede dosificar colorantes y aditivos en gramos.

Para cada proveedor registre la razón social y, cuando corresponda, el RUC. Complete además la persona de contacto, teléfono, WhatsApp y correo si esos datos fueron confirmados. Estos datos son opcionales y pueden editarse; no deben copiarse desde una fuente dudosa. El código `PRV-######` lo genera el SCM y no corresponde al código provisional del archivo de carga.

### 3. Piezas y fabricación

- Crear la identidad abstracta de cada pieza. La Pieza representa una forma y no posee color, SKU físico ni imagen.
- Crear el molde.
- Asociar las piezas al molde e informar cavidades y peso operativo.
- Habilitar cada color desde el molde. Esta acción crea o reutiliza una variante Pieza–Color para **todas** las piezas activas que salen en el mismo tiro.
- Desplegar cada pieza en el catálogo para revisar sus variantes, SKU, color e imagen.
- Cargar la imagen en la Pieza–Color correspondiente, no en la Pieza abstracta.

Una Pieza–Color es la identidad física fabricable de una pieza en un color determinado. Posee su propio SKU e imagen.

#### Regla para moldes de varias salidas

Si un molde produce, por ejemplo, cuerpo, tapa y pico en cada tiro, no se puede habilitar un color solo para una de esas piezas. El sistema habilita el color para el molde completo y exige que existan las tres variantes del mismo color. Repetir la operación para un color ya habilitado reutiliza las variantes existentes y no duplica los SKU.

La disponibilidad de un color se considera completa únicamente cuando todas las salidas activas del molde poseen su Pieza–Color. Si una salida cambia, revise nuevamente la cobertura de colores antes de planificar.

### 4. Producto e ingeniería

- Crear el ProductoTerminado.
- Crear y aprobar su BOM en Ingeniería SCM.
- Crear y aprobar su ruta.
- Crear y aprobar su perfil y regla de empaque cuando corresponda.

El alta de ProductoTerminado solo crea su identidad comercial; no reemplaza la BOM ni la ruta.

## Criterios de calidad

- Nombres descriptivos y reconocibles para planta.
- Sin abreviaturas ambiguas.
- RUC único por proveedor.
- Datos de contacto del proveedor vigentes y sin valores inventados.
- Una sola identidad por entidad real.
- Inactivar en lugar de eliminar cuando el registro ya fue referenciado.
- No aprobar estructuras, rutas, recetas o reglas sin revisión de un segundo actor.

## Qué dejar pendiente

Si falta información confiable, no inventarla. Registrar la entidad mínima únicamente cuando el formulario lo permita y comunicar el dato faltante al responsable del catálogo.
