---
tipo: frontend-view
estado: integrado
madurez: integrado
ruta: /datos-maestros/piezas
componente: PiezasAdmin
fuente_datos: API
tags: [frontend, datos-maestros, pieza, pieza-color, imagen]
fecha_creacion: 2026-08-04
fecha_actualizacion: 2026-08-04
relaciones:
  - "[[Pieza]]"
  - "[[PiezaColor]]"
  - "[[Molde]]"
  - "[[UAT_02_Maestros_e_Imagenes]]"
---

# Vista — Catálogo de piezas, SKU e imágenes

## Propósito

Separar el maestro abstracto de formas de sus presentaciones físicas. La tabla principal muestra [[Pieza]] y cada fila se despliega para consultar sus [[PiezaColor]].

## Anatomía

### Nivel Pieza

Muestra código `PZ-*`, nombre, línea/familia, peso nominal, moldes asociados, cantidad de variantes, estado y acciones del maestro. No muestra ni solicita imagen.

### Nivel PiezaColor

Muestra miniatura, SKU `PC-*`, nombre, color y referencia HEX, peso, estado de revisión y acción para cargar, cambiar o quitar la imagen.

Cuando no existen variantes se muestra el estado vacío: “Sin PiezaColor. Habilita un color en uno de sus moldes; se crearán todas las salidas del golpe”.

## Comandos

| Comando | Alcance | Regla visible |
| :--- | :--- | :--- |
| Nueva/editar/desactivar pieza | Pieza abstracta | No administra fotografía ni color. |
| Habilitar color | Molde completo | Advierte que se crearán o reutilizarán todos los SKU del tiro. |
| Cargar/cambiar/quitar imagen | PiezaColor | JPG, PNG o WebP; máximo 2 MB. |

El selector de color permanece bloqueado si no existen colores de producción. El botón de confirmación exige molde y color.

## Integridad protegida

Para un molde que produce cuerpo, tapa y pico simultáneamente, la interfaz no ofrece “crear variante” libre para una sola salida. El usuario habilita un color desde cualquiera de las piezas, selecciona el molde y el backend resuelve las tres variantes en una transacción.

## Estados y errores

- carga del catálogo y colores;
- estado vacío de variantes;
- error de consulta o persistencia mediante alerta;
- validación local del límite de 2 MB;
- confirmación visual después de guardar o eliminar la imagen;
- conservación de la imagen después de recargar.

## Cobertura UAT

La ejecución y evidencia se registran en [[UAT_02_Maestros_e_Imagenes]], casos M-03, M-04 y M-05.
