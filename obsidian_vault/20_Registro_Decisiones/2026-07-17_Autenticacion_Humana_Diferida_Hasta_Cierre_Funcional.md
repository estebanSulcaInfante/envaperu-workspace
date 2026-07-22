---
tipo: adr
estado: aceptada
fecha: 2026-07-17
tags: [arquitectura, seguridad, autenticacion, autorizacion, rbac, scm, despliegue]
relaciones:
  - "[[US-010_Trazabilidad_End_to_End_SCM]]"
  - "[[US-010A_Recepcion_Trazable_Materiales]]"
  - "[[US-011_Monitorear_Estaciones_de_Pesaje]]"
  - "[[TE-004_Despliegue_Operativo_y_Observabilidad_Estacion_Pesaje]]"
---

# ADR: Autenticación Humana Diferida Hasta el Cierre Funcional

## Contexto

EnvaPerú todavía está normalizando datos maestros, recepción, reservas,
producción, pesaje, inventario y trazabilidad. Los roles de negocio y sus
límites operativos también continúan en validación.

Implementar ahora login, sesiones y RBAC transversal aumentaría el costo de cada
cambio funcional y podría fijar prematuramente una matriz de permisos todavía
incompleta. Sin embargo, varias rutas centrales siguen siendo anónimas y no deben
confundirse con una superficie lista para exposición pública.

## Decisión

1. La autenticación y autorización de **usuarios humanos** se implementarán al
   final del desarrollo funcional principal, mediante un Technical Enabler y su
   Tech Spec transversal.
2. Esta decisión no bloquea la implementación ni las pruebas TDD de los flujos
   SCM. Las reglas de autoridad se probarán con actores y roles de dominio
   explícitos, aunque todavía no exista una sesión autenticada.
3. La autenticación **técnica entre sistemas** no se posterga. Tokens de estación,
   TLS, secretos DPAPI, idempotencia y validación de contratos permanecen activos.
4. Hasta incorporar autenticación humana, los entornos se limitan a desarrollo,
   demostración o piloto en equipo controlado, loopback, LAN restringida o VPN.
   No se permite exposición directa a Internet ni a una red no confiable.
5. Un nombre o `trabajador_id` seleccionado durante esta fase representa un
   **actor declarado**, no una identidad digital verificada. La UI y la
   documentación no deben afirmar lo contrario.
6. No se implementará un login aparente solo en frontend ni se confiará en un
   campo `rol` enviado por el navegador como mecanismo de seguridad.
7. Antes del despliegue productivo multiusuario o externo, autenticación humana,
   autorización server-side, gestión de sesiones, auditoría de acceso y pruebas
   de denegación serán un gate obligatorio.

## Consecuencias

- El dashboard de US-011 y los flujos de US-010 pueden avanzar con datos mock o
  API real en un entorno interno controlado.
- Las vistas pueden ocultar comandos que no pertenecen al flujo, pero esa
  ausencia es diseño funcional y no sustituye control de acceso.
- Los eventos conservan snapshots del actor declarado para trazabilidad. Cuando
  exista identidad autenticada se añadirá la referencia verificable sin reescribir
  el historial anterior.
- Toda documentación que use expresiones como "usuario autorizado" o "permiso"
  debe distinguir la regla de negocio objetivo de su enforcement técnico futuro.

## Gate de Cierre

El futuro enabler de identidad deberá definir, como mínimo:

- proveedor de identidad, login, cierre y recuperación de sesión;
- identidad `Usuario` vinculada de forma controlada con `Trabajador`;
- RBAC server-side y matriz de segregación de funciones;
- autorización de excepciones, liberaciones, correcciones y ajustes;
- auditoría de accesos y acciones sensibles;
- migración de actores declarados a identidades verificables sin falsificar el
  histórico;
- pruebas unitarias, de integración y E2E para acceso permitido y denegado.

