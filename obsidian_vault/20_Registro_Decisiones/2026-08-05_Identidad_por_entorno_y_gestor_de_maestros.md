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

Su entrada principal para altas nuevas de ProductoTerminado será la sesión durable de [[../05_Especificaciones/02_User_Stories/US-012_Alta_Guiada_Integral_de_ProductoTerminado|US-012]]. La vista compone estas capacidades existentes y no incorpora un permiso global que permita omitir validaciones de catálogo o ingeniería.

No recibe capacidades de:

- administración de participantes, identidades o roles;
- planificación y ejecución de OP, OF, OA u OT;
- pesaje, anulación o corrección;
- recepción, Calidad, Kardex, inventario o molienda.

## Configuración del frontend

`VITE_SCM_PROFILE_SWITCH_ENABLED=false` permite deshabilitar el selector también en desarrollo. Vite lo habilita por defecto sólo durante `npm run dev`; un build de producción no puede habilitarlo mediante esta variable.

## Autenticación productiva

- Supabase Auth autentica correo y contraseña y entrega una sesión renovable.
- El backend valida el JWT firmado mediante el JWKS público de Supabase.
- El `sub` del JWT se vincula de forma única con `trabajador.auth_user_id`.
- En modo productivo se ignora `X-Actor-Id`: el actor auditable siempre procede de la sesión.
- El cambio a `SCM_AUTH_MODE=supabase` se realiza únicamente después de crear y vincular al menos una cuenta administrativa, para evitar un bloqueo operativo.
