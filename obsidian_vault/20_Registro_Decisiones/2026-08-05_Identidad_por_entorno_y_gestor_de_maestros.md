# Identidad por entorno y gestor de maestros

Fecha: 2026-08-05

## Decisión

- El selector **Cambiar perfil** es una herramienta exclusiva de desarrollo y UAT local.
- Los builds de producción no lo muestran. La identidad productiva será obtenida de una sesión autenticada y no de un trabajador elegido en la interfaz.
- Se incorpora el rol `GESTOR_MAESTROS` para la carga inicial realizada por personal de apoyo.

## Alcance del gestor de maestros

Puede consultar y mantener:

- productos terminados, piezas, variantes e imágenes;
- líneas, familias, colores y recetas;
- moldes y máquinas;
- materias primas, categorías y proveedores;
- artículos WIP, estructuras BOM, rutas y perfiles de empaque.

Puede publicar directamente revisiones técnicas creadas durante la carga inicial para no bloquear el trabajo por segregación de funciones. La publicación conserva la auditoría del actor.

No recibe capacidades de:

- administración de participantes, identidades o roles;
- planificación y ejecución de OP, OF, OE u OT;
- pesaje, anulación o corrección;
- recepción, Calidad, Kardex, inventario o molienda.

## Configuración del frontend

`VITE_SCM_PROFILE_SWITCH_ENABLED=false` permite deshabilitar el selector también en desarrollo. Vite lo habilita por defecto sólo durante `npm run dev`; un build de producción no puede habilitarlo mediante esta variable.

Ocultar el selector no reemplaza la autenticación. El despliegue definitivo debe validar la sesión de Supabase Auth en el backend antes de retirar el encabezado provisional `X-Actor-Id`.
