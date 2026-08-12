---
tipo: user-story
estado: implementada-local-pendiente-uat
tags: [scm, piloto, trabajo-color, trabajador, relevo, asignacion, atdd]
relaciones:
  - "[[US-010M_OT_de_Maquina_y_Trabajo_de_Color]]"
  - "[[TS-010M3_Relevos_en_Trabajo_Color]]"
  - "[[Asignacion_Trabajo_OT]]"
  - "[[US-010K_Pesaje_Intermedio_Cierre_de_Mangas_y_Avance_por_Color]]"
fecha_creacion: 2026-08-08
fecha_actualizacion: 2026-08-08
---

# US-010M3: Relevos dentro de un Trabajo de color

## Historia

**Como** supervisor de Producción  
**Quiero** relevar al maquinista dentro del mismo Trabajo de color  
**Para** conservar continuidad, custodia y responsabilidad sin crear otro
trabajo ni pedir digitación al maquinista.

## Alcance

- asignaciones de responsable por intervalo;
- responsable predeterminado opcional en OT;
- relevo dentro de la misma OT y contexto técnico;
- asignación directa de subconjuntos de mangas/stickers a un maquinista;
- reasignación masiva supervisada de mangas pendientes o no iniciadas;
- transferencia excepcional de manga abierta dentro de la misma OT con
  control/conteo de frontera, sin pesaje intermedio;
- separación entre responsable productivo e identidad registrada por Balanza.

## Invariantes

1. El trabajador no integra la identidad de OT ni Trabajo de color.
2. Una máquina tiene como máximo un responsable principal vigente por instante.
3. Los intervalos no se sobrescriben; el relevo cierra uno y abre otro.
4. Cambiar trabajador no cambia trabajo si OF, corrida, receta, molde, máquina y
   límite de Calidad continúan.
5. Una manga pesada o recibida conserva su responsable histórico.
6. Cada manga puede fijar la asignación que recibió ese sticker; el resto del
   trabajo puede asignarse a otra persona.
7. Las mangas pendientes/no iniciadas pueden reasignarse masivamente sin crear
   manga, trabajo o cupo nuevos.
8. Si la etiqueta impresa muestra al responsable anterior, la reasignación
   invalida esa versión y genera un reemplazo para la misma manga.
9. Una manga abierta solo se transfiere excepcionalmente dentro de la misma OT,
   con supervisor, motivo y control/conteo de frontera. No se pesa en el relevo.
10. Una manga pesada o recibida no cambia de asignación retroactivamente.
11. Sin conteo de frontera no se afirman unidades exactas por trabajador.
12. Cruzar a otra OT, turno o fecha no está permitido por M3.

## Escenarios ATDD/BDD

### M3-01 — Relevo sin nuevo trabajo

**Dado** Renato asignado al Trabajo Verde  
**Cuando** el supervisor lo releva por Luis dentro de la misma OT  
**Entonces** se cierra el intervalo de Renato, comienza el de Luis y el trabajo,
cuota y avance permanecen.

### M3-02 — Solapamiento bloqueado

**Dado** un responsable vigente en la máquina  
**Cuando** dos comandos concurrentes intentan abrir responsables distintos  
**Entonces** solo una asignación queda vigente y el conflicto es explícito.

### M3-03 — Subconjunto de stickers por maquinista

**Dado** diez mangas pendientes del mismo Trabajo Verde  
**Cuando** el supervisor asigna seis a Renato y cuatro a Luis  
**Entonces** cada QR resuelve su asignación propia sin dividir el Trabajo de
color ni modificar el cupo.

### M3-04 — Reasignación masiva pendiente

**Dado** mangas pendientes o no iniciadas de Renato  
**Cuando** el supervisor las reasigna a Luis por relevo  
**Entonces** cambian de asignación en una operación auditada, sin crear mangas,
Trabajo de color ni cupo adicional.

### M3-05 — Sticker ya impreso

**Dado** una manga no iniciada cuyo sticker impreso muestra a Renato  
**Cuando** el supervisor la reasigna a Luis  
**Entonces** invalida la versión anterior y genera un reemplazo para la misma
manga sin consumir otro cupo.

### M3-06 — Manga abierta dentro de la misma OT

**Dado** una manga abierta de Renato aún no pesada  
**Cuando** el supervisor la transfiere a Luis con motivo y conteo acumulado  
**Entonces** conserva la identidad de manga, trabajo y OT, registra la frontera
y no genera un pesaje ni una postetiqueta. Si el sticker identifica al
responsable anterior, su QR se invalida y se imprime la nueva versión.

### M3-07 — Actor y asignación snapshotteados

**Dado** una manga asignada a Luis  
**Cuando** otra identidad autorizada opera la Balanza y confirma el peso  
**Entonces** el pesaje conserva la asignación productiva de Luis y por separado
la identidad registrada por la estación de Balanza, sin afirmar que una
identidad técnica compartida demuestra quién trasladó físicamente la manga.

### M3-08 — Sin fuente de cantidad individual

**Dado** una manga abierta transferida sin conteo verificable  
**Cuando** se consulta productividad individual  
**Entonces** muestra asignaciones e intervalos, pero no reparte unidades exactas
por tiempo, peso o proporción.

### M3-09 — Cruce de OT bloqueado

**Dado** que termina el turno y la manga sigue abierta  
**Cuando** se intenta asignarla a la OT siguiente  
**Entonces** M3 bloquea la operación y señala que requiere US-010K.

## Fuera de alcance

- continuidad multi-jornada y `TramoMangaTrabajoColor`;
- pesaje intermedio de manga abierta;
- OCR, PLC o contador automático;
- material preparado y Trabajo de Armado.

## Definición de preparada

- [x] Relevo, asignación, custodia y atribución diferenciados.
- [x] Se evita prometer unidades exactas sin fuente.
- [x] La frontera con US-010K es explícita y automatizable.
- [x] Conflictos concurrentes y etiquetas emitidas están cubiertos.
