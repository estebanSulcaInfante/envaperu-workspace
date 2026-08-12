---
tipo: approved-for-dev
estado: desarrollo-local-autorizado
historia: "[[US-010H_Abastecimiento_Interno_Picking_QR_y_Consumo_Mangas]]"
tech_spec: "[[TS-010H_Abastecimiento_Interno_Picking_QR_y_Retorno]]"
fecha_aprobacion: 2026-08-03
---

# DEV-010H: Abastecimiento interno y picking QR

Se autoriza el desarrollo local del corte definido en TS-010H. No se autoriza
modificar la base desplegada ni desplegar sin UAT operativa.

## Entregables

- OT diaria de Armado como extensión del documento OT común;
- solicitud derivada de BOM y cuota;
- reserva exacta de manga liberada;
- picking, despacho y recepción en Mesa de Armado;
- retorno trazable del remanente;
- roles/capacidades configurables;
- API, interfaz por actor, migración y pruebas.

El consumo/genealogía se integra mediante el cierre atómico de manga de
TS-010F; no se implementa como movimiento manual independiente.
