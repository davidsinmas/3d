# CALISOFT — Control de producto, decisiones y entregas · v1.0

**Vigencia:** 14/11/2026 · **Ámbito:** todos los proyectos y repositorios de CalisoftProjects, en Chat, Work, otros agentes, herramientas locales y Publicador.  
**Propietario de las decisiones de producto:** el usuario. **Aplicación:** obligatoria antes de diseñar, modificar, fusionar o publicar un cambio funcional.  
**Documento común:** copias locales de este archivo en Club, Apps, 3D, Portal, Ludeiko y CNAnalyzer. Si alguna copia está desactualizada, **no rebajar** controles; actualizarla antes de cambiar el procedimiento.

## 1. Fuente de verdad y jerarquía

Para cada tarea, identificar y **leer realmente** la hoja de proyecto/plan, referencias visuales aprobadas, decisiones vigentes, código y estado publicado. Registrar rutas y revisión. No sustituir la lectura por resúmenes de memoria ni por lo que un agente anterior afirmó.

Orden: (1) decisión expresa más reciente del usuario para ese alcance, (2) decisiones anteriores expresamente aprobadas que no estén revocadas, (3) hoja de proyecto y referencias, (4) contratos/estándares propios, (5) implementación existente. Si existen contradicciones, **señalarlas**: no resolverlas inventando una autorización. Diferenciar «candidato preferente», «propuesta», «evaluado» y «aprobado».

Una hoja de proyecto debe recoger, o enlazar de forma verificable, objetivo, fuente/software a reutilizar y su licencia, qué NO se puede sustituir, funciones y reglas, referencia visual, modo online/local, alcance, etapas, criterios de aceptación y asuntos pendientes. Si falta un punto esencial, se permite auditar y reparar incidencias que no alteren el producto; **no inventar una decisión de producto**.

## 2. La puerta de autorización: cambios de producto

**Requieren autorización expresa y previa, trazable a un mensaje/decisión del usuario:**

- Cambiar o abandonar el juego, aplicación, librería o proyecto elegido para reutilizar; sustituirlo por código propio o por otro motor.
- Cambiar reglas, flujo de uso, diseño/estética aprobada, estructura de pantallas, identidad, destinatarios, modos de juego, funciones o alcance.
- Rehacer una implementación en vez de reutilizar la existente, alterar almacenamiento/arquitectura sustancial, costes, servicios o licencias.
- Retirar capacidades previstas, ampliar el alcance más allá del plan o introducir un diseño distinto al mostrado para validación.
- Pasar de una evaluación técnica/prototipo a un desarrollo definitivo **cuando la selección sigue pendiente**.

**No requieren nueva autorización de producto**: correcciones acotadas de errores, accesibilidad, seguridad, pruebas, compatibilidad y refactorizaciones equivalentes **si preservan fielmente** el comportamiento/plan validado. La publicación, migraciones, borrados y operaciones externas se rigen además por las autorizaciones operativas y de seguridad aplicables.

**Si aparece una desviación:** detener SOLO la parte afectada. Antes de escribir la sustitución, presentar al usuario:
1. **Plan original:** fuente exacta y qué se acordó.
2. **Bloqueo verificable:** fallo real, prueba, licencia o limitación; distinguir hipótesis de hechos.
3. **Alternativas:** mantener/reparar lo previsto, adaptar, o cambiar; reutilización, coste/tiempo *aproximados y sin inventar*, riesgos y alcance.
4. **Comparación visual/funcional** cuando corresponda; prototipo o captura **antes** de programar la alternativa completa.
5. **Decisión pendiente concreta**, sin asumir aprobación por silencio, falta de respuesta, ejecución de pruebas o éxito de despliegue.

Solo continuar esa desviación tras confirmación explícita. Registrar el enlace/fecha o referencia a la decisión exacta. Un agente, la IA, una PR o una prueba técnica **no pueden aprobarse a sí mismos**. No registrar autorizaciones retroactivas ficticias.

## 3. Puntos de control para evitar trabajo desperdiciado

- **G0 — Recuperación del encargo:** localizar plan y decisiones; describir en 4–8 líneas lo que se conserva, restricciones y qué está realmente implementado.
- **G1 — Elección y maqueta:** auditar el proyecto externo elegido y su licencia; comprobar viabilidad. Si hay cambio de dirección o interfaz, mostrar prueba de concepto **y esperar aprobación del usuario** antes de desarrollo extenso.
- **G2 — Construcción por tramos útiles:** reutilizar motores/infraestructura; no crear sistemas paralelos ni perseguir modificaciones ajenas. Registrar desviaciones propuestas, no ejecutadas.
- **G3 — Verificación frente al encargo:** pruebas técnicas + comparación de características y visuales con las referencias aprobadas; listar diferencias con evidencia.
- **G4 — Entrega:** estado separado de **código**, **pruebas**, **integración**, **producción** y **validación real por el usuario**. No llamar «terminado», «validado» ni «publicado» si no hay evidencia de ese estado.

Un test verde, un merge, un ZIP correcto o una publicación SFTP exitosa **NO** demuestran que se haya cumplido el encargo.

## 4. Registro obligatorio, ligero y persistente

Antes de una PR funcional y tras cada entrega o relevo, actualizar la hoja de proyecto o su registro enlazado con el mínimo siguiente:

```text
PROYECTO / VERSIÓN / FECHA:
FUENTE DE VERDAD (archivo, referencia visual y commit):
OBJETIVO Y ELEMENTOS NO MODIFICABLES:
CAMBIO PROPUESTO (tipo: equivalente / desviación):
DECISIÓN DE PRODUCTO (no necesita / pendiente / aprobada):
EVIDENCIA DE APROBACIÓN (enlace y decisión literal, o N/A si equivalente):
REUTILIZACIÓN PREVISTA / REAL:
TRABAJO HECHO (commit/PR y archivos):
PRUEBAS Y COMPARACIÓN CON EL PLAN (aprobado/fallido/no hecho):
PUBLICACIÓN (no realizada / URL + prueba):
DESVIACIONES Y PENDIENTES:
SIGUIENTE PASO ÚNICO Y RESPONSABLE:
```

**Pendiente** significa pendiente; no marcar «aprobada» ni «validada» por inferencia. No cargar al usuario con controles técnicos menores; registrar y resolverlos autónomamente.

## 5. Puerta para PR, fusión y despliegue

Cada PR funcional debe indicar el plan base, qué se reutiliza, si existe desviación, evidencia de aprobación si la hay, comparativa de requisitos, visuales cuando aplique, pruebas reales/no realizadas y efectos sobre coste/infraestructura. Si hay desviación sin autorización **la PR queda en borrador, sin fusionar ni publicar**. Tampoco se sustituye una rama validada por otra sin comparar las diferencias.

Usar Publicador como vía habitual; evitar Work y GitHub Actions para tareas que puedan resolverse en Chat o localmente. No utilizar despliegues repetidos como sustituto de planificación o validación. Publicar solo cambios ya aprobados y probados, con respaldo, comprobación en producción y rollback. Una instrucción de «termina» o «continúa» NO autoriza por sí sola una desviación respecto a requisitos previamente aprobados.

La aceptación por el usuario debe referirse a **algo visible y representativo** cuando hay cambio de interfaz. Una descripción textual no reemplaza una referencia que se pueda inspeccionar.

## 6. Incumplimientos, correcciones y rendición de cuentas

Si se descubre una desviación previa: registrar el plan original, la implementación diferente, cuándo y cómo ocurrió, qué queda aprovechable, el coste no cuantificable o conocido y las opciones de corrección. **No atribuir aprobación donde no existe** ni ocultar el problema tras pruebas técnicas. Mantener el código y producción seguros mientras el usuario decide; las reparaciones no relacionadas pueden continuar.

**Limitación de aplicación:** este archivo y las plantillas de PR establecen un procedimiento comprobable para los agentes, pero **no constituyen por sí mismos un bloqueo técnico de GitHub**. Para impedir que una PR se fusione sin revisión humana hace falta, además, una regla de protección/ruleset que exija una aprobación independiente del propietario y prohíba saltársela; no afirmar que existe hasta verificarlo en la configuración del repositorio.
