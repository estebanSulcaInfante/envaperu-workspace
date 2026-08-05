# Autenticación Supabase SCM

Fecha: 2026-08-05

## Contrato

En `SCM_AUTH_MODE=supabase`, Flask protege las rutas `/api/*`, excepto salud, integración de estaciones y recursos gráficos públicos expresamente definidos.

1. Lee `Authorization: Bearer <access_token>`.
2. Verifica localmente firma ES256, emisor, audiencia, expiración y campos obligatorios mediante el JWKS público de Supabase.
3. Convierte `sub` a UUID y busca `trabajador.auth_user_id`.
4. Exige que el trabajador permanezca activo.
5. Define `g.scm_actor_id`; cualquier `X-Actor-Id` recibido queda ignorado.
6. Los servicios SCM continúan validando capacidades y registrando el trabajador como actor auditable.

## Endpoint

### `GET /api/auth/me`

Devuelve el trabajador autenticado, correo de la sesión, roles y capacidades efectivas. La respuesta usa `Cache-Control: private, no-store`.

## Persistencia

`trabajador.auth_user_id UUID NULL UNIQUE` vincula una identidad de Supabase Auth con exactamente un participante SCM. No se replica la contraseña ni se utiliza el correo como clave de autorización.

La columna no tiene una clave foránea a `auth.users` para mantener ejecutable el mismo modelo en PostgreSQL local durante desarrollo y pruebas. El alta administrativa debe crear primero el usuario Auth y luego guardar su UUID en el trabajador correspondiente.

## Configuración

- `SCM_AUTH_MODE=supabase`
- `SUPABASE_URL`
- `SUPABASE_JWT_AUDIENCE=authenticated`
- `SUPABASE_JWT_ISSUER` opcional; por defecto `${SUPABASE_URL}/auth/v1`

No se requiere `service_role`, secreto JWT ni contraseña de base de datos para validar sesiones.

## Puesta en marcha sin bloqueo

1. Crear las identidades reales en Supabase Auth.
2. Vincular cada UUID con el trabajador SCM y comprobar que permanezca activo y tenga el rol correcto.
3. Probar `/api/auth/me` con las cuentas de Gerencia y Gestor de maestros.
4. Configurar backend y frontend en modo `supabase` y desplegarlos como una sola ventana de cambio.
5. Verificar ingreso, cierre de sesión, ocultamiento de **Cambiar perfil** y rechazo de una operación productiva para el gestor.

Mientras falte una identidad administrativa vinculada, producción permanece en el modo anterior. El modo `local_actor` se conserva exclusivamente para desarrollo y UAT local.
