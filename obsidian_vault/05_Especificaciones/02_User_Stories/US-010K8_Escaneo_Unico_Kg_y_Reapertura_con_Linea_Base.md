---
tipo: user-story
estado: aprobada-para-dev-local
spec_phase: approved
delivery_state: review
functional_validation: qa_green
ux_validation: provisional
physical_uat: pending
release_constraint: no_habilitar_en_planta
ux_risk: high
contexto_operativo: "[[Contexto_Operativo_13_Maquinas_Talonario_QR_y_Pesaje_Central]]"
uat_profiles: [PES-v1, LEC-v1, ADM-v1, IMP-v1, CON-v1]
fecha_creacion: 2026-09-03
fecha_actualizacion: 2026-09-04
relaciones:
  - "[[Identidad_de_un_solo_uso_en_Pesaje_y_Reapertura_con_Linea_Base]]"
  - "[[2026-09-03_Escaneo_Unico_y_Reapertura_con_Linea_Base]]"
  - "[[TS-010K8_Escaneo_Unico_Kg_y_Reapertura_con_Linea_Base]]"
  - "[[PROTO_US-010K8_Escaneo_Unico_y_Reapertura_con_Linea_Base]]"
---

# US-010K8: escaneo único, contexto en kg y reapertura con línea base

Como operador de Pesaje quiero que cada QR habilite un solo pesaje y que la
pantalla priorice kg, para no registrar una segunda manga física bajo la
identidad anterior. Como Jefa de Producción quiero distinguir una reapertura
accidental de una continuación de llenado para conservar correctamente el peso
anterior sin borrar historia.

## Alcance

- Intención QR de un solo uso tras éxito, para control y final.
- Foco y recuperación por teclado/lector; mismo QR reescaneable.
- Contexto kg-first para manga simple de Fabricación.
- Retiro del cierre parcial por unidades en la estación de Fabricación.
- Dos tipos de reapertura y línea base persistida para continuación.
- Historia, postetiquetas, permisos, versión e idempotencia existentes.

Fuera de alcance: umbral mínimo en gramos, inventario/Kardex integral en kg,
reapertura posterior a recepción sin reversa, WIP/PT no soportado por K6,
conciliación de consumo/merma y despliegue productivo.

## Interacción y estados

Información primaria: código de manga, pieza/color, NET, último NET aceptado,
diferencia e intención Control/Cierre. Acción primaria: `Pesar manga (F2)`.
Después del éxito: resultado visible, intención consumida y foco en lector.
Recuperación: retirar objeto y escanear el QR que corresponda. Central presenta
el tipo de reapertura como selección explícita y explica si conservará el NET.

## BDD

- `K8-01`: dado un QR resuelto, cuando un control es aceptado, entonces F2 se
  bloquea aunque aumente la lectura y exige otro escaneo.
- `K8-02`: dado el éxito de A, cuando se coloca B sin escanearla y se pulsa F2,
  entonces no existe una segunda llamada ni un hecho atribuido a A.
- `K8-03`: dado A todavía abierta, cuando se vuelve a escanear su QR, entonces
  se habilita una nueva intención y se conserva el último NET de Central.
- `K8-04`: dado un cierre final aceptado, entonces la intención también queda
  consumida y el resultado/impresión siguen visibles.
- `K8-05`: dada una manga simple abierta, entonces la vista muestra peso
  fabricado teórico, último NET, NET actual y diferencia en kg; no solicita ni
  presenta unidades como conteo real.
- `K8-06`: dado un cierre accidental reabierto, entonces el final queda en
  historia, `peso_base_neto_kg` es nulo y no bloquea una lectura corregida menor.
- `K8-07`: dado un cierre correcto reabierto por `CONTINUAR_LLENADO`, entonces
  su NET queda como base y un nuevo control/final debe superarlo; el aporte es
  la diferencia.
- `K8-08`: repetir la reapertura con la misma clave devuelve el mismo resultado;
  tipo inválido, versión obsoleta, permiso ausente o recepción vigente no mutan.
- `K8-09`: Central explica y confirma el tipo, NET conservado, mismo QR e
  invalidación física del comprobante anterior.

## Dataset

Manga A, tara `0.030 kg`, control `4.790 kg`. Caso accidental: final erróneo
`8.950 kg`, reapertura accidental y nueva lectura `4.970 kg`, aceptable contra
el control `4.790`. Caso continuación: final correcto `5.000 kg`, reapertura
con base `5.000`, control `5.700`, aporte `0.700 kg`. Manga B se coloca después
de A sin escanear y no debe producir llamada.

## Gates

READY-FOR-DESIGN y aprobación local: cubiertos por evidencia UAT y solicitud
explícita del responsable. UX-READY representativo: pendiente; excepción local
con `ux_validation: provisional`. UAT física: pendiente.
