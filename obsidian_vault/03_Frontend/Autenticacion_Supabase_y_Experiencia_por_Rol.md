# Autenticación Supabase y experiencia por rol

Fecha: 2026-08-05

## Experiencia de usuario

El build productivo utiliza `VITE_SCM_AUTH_MODE=supabase` y presenta una pantalla de acceso por correo y contraseña. Después del ingreso:

- Supabase conserva y renueva la sesión;
- cada petición Axios envía el JWT en `Authorization: Bearer`;
- `/api/auth/me` devuelve únicamente el trabajador vinculado, sus roles y sus capacidades efectivas;
- la navegación, las pestañas, las rutas y las acciones se filtran por esas capacidades;
- la barra superior permite cerrar la sesión y no permite elegir otra identidad.

En desarrollo, `VITE_SCM_AUTH_MODE=local_actor` conserva **Cambiar perfil** para ejecutar UAT con varios actores. Esta modalidad no se admite como autenticación productiva.

## Variables públicas del frontend

- `VITE_SCM_AUTH_MODE=supabase`
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`

La llave publicable puede estar en el bundle. Nunca se incorpora una llave secreta o `service_role` al frontend.

## Estados de acceso

- Sin sesión: pantalla de inicio de sesión.
- Sesión válida sin trabajador vinculado: acceso denegado y mensaje de vínculo pendiente.
- Trabajador desactivado: acceso denegado inmediatamente.
- Sesión y trabajador activos: experiencia calculada por capacidades.

