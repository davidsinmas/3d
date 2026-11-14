## Puerta de control del proyecto (obligatoria para cambios funcionales)

**Hoja de proyecto y versión/commit leído:**  
**Referencia visual aprobada (o «sin referencia»):**  
**Qué solución/obra externa se iba a reutilizar:**  
**Qué se reutiliza realmente y qué queda intacto:**  

**Clasificación (marcar solo lo que se pueda demostrar):**
- [ ] **Cambio equivalente:** respeta todas las decisiones de producto existentes, sin sustituir diseño/motor/reglas/alcance.
- [ ] **Cambio de producto autorizado:** explicar qué cambia y adjuntar **enlace/fecha de aprobación expresa PREVIA del usuario**.
- [ ] **Propuesta pendiente:** NO fusionar, NO publicar, dejar PR en borrador.

**Evidencia de aprobación** (mensaje concreto, PR revisada por propietario o «No aplica: equivalente»):  
**Requisitos/criterios originales comparados** (cumple / no cumple / no probado):  
**Captura de propuesta aprobada y resultado real**, cuando afecta a interfaz:  
**Coste/tiempo adicional y recursos usados** (sin cifras inventadas):  
**Pruebas técnicas ejecutadas / no ejecutadas:**  
**Prueba funcional con usuario y dispositivo real / pendiente:**  
**Publicación** (no realizada / URL, versión, verificación de producción):  
**Registro de decisión actualizado en plan o documento enlazado:**  

> **NO marcar aprobación sin fuente.** Una PR fusionada, tests verdes o un deploy exitoso NO equivalen a aprobación del producto. Si hay desviación pendiente, detener el cambio afectado. Ver [control de proyectos](../docs/CALISOFT_CONTROL_PROYECTOS_V1.md).

---

## Change

Describe the problem and resulting behavior. Link the issue when applicable.

Changes a default: no

<!-- Required line, replace "no" if this changes what a user gets out of the box (a default value, key binding, setting, tool behaviour):
Changes a default: yes — <what>, old behaviour kept behind preference <name>
Docs-only and bot PRs are exempt. -->

## Validation

What did you run, and what were the results? Include expected and measured values for geometry changes.

## Screenshots of the behavior (when observable)

For observable CAD, UI or model behavior, include actual descriptive screenshots or a short recording from a small reproduction. This includes kernel, geometry, assembly and backend effects that can be shown in the app. Coding agents should run the app and capture the evidence themselves, rather than asking a human for evidence they can produce. Show the actual failure/result, preferably before and after, with brief steps, expected/actual behavior and annotations where helpful.

Flowcharts and Mermaid diagrams cannot substitute for evidence of visible behavior. Use diagrams for architectural reasoning when actual screenshots cannot illustrate the point. Changes with no useful observable behavior may omit screenshot/video evidence. Exclude private designs and sensitive details; attach media or link to an accessible recording rather than committing generated review artifacts.

## Integration status

Record the upstream commit and PR status checked before handoff, any conflicts resolved, and validation after integration. Keep up with upstream merges and monitor this PR while the task is active; rebase before pushing and never force-push.
