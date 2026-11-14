# Calisoft 3D

## Control obligatorio de proyecto — no cambiar el encargo sin autorización

**Leer antes de intervenir:** `docs/CALISOFT_CONTROL_PROYECTOS_V1.md` y la hoja de proyecto / referencia visual correspondiente. Esta norma se aplica a Chat, Work, agentes y operaciones por GitHub/Publicador y prevalece sobre instrucciones genéricas de «seguir», «terminar» o «mejorar» cuando exista una discrepancia con una decisión de producto previa.

- **NO sustituir por cuenta propia** un juego, proyecto abierto, motor, arquitectura de referencia, reglas, funcionalidades o diseño previamente elegido o validado. Diferenciar expresamente un candidato pendiente de una alternativa aprobada.
- Si la solución prevista falla o parece inviable, **detener solo ese cambio**: aportar prueba del bloqueo, las alternativas y repercusión en esfuerzo/reutilización, y pedir decisión expresa antes de desarrollar un reemplazo. No inferir permiso por silencio ni por haber ejecutado tests.
- **Presentar y validar la apariencia representativa** antes de desarrollar o publicar una sustitución visual. No asumir que un render técnico es aprobación de un nuevo diseño.
- En cada PR funcional, exigir hoja de proyecto, comprobación contra requisitos, registro de desviaciones, enlace de aprobación cuando proceda y estado separado de pruebas técnicas, funcionamiento real y publicación. **Desviación sin aprobación: no fusionar ni publicar.**
- Registrar cambios y relevo en el plan/registro; usar Chat y Publicador cuando sea viable, minimizar Work/Actions, no introducir infraestructuras duplicadas ni perder tiempo reparando una alternativa no autorizada.
- Estas reglas **no reemplazan** la seguridad, licencias ni validación E2E. El documento no equivale a protección técnica de rama; no afirmar que una revisión humana está forzada si no existe la regla configurada.


- Trabajar solo en davidsinmas/3d. No modificar el original ni producción.
- No GitHub Actions, compilaciones automáticas, facturación o servicios nuevos.
- No reescribir main: sin reset, force-push ni rebase destructivo.
- Las actualizaciones se preparan en update/solidcraft-* y se revisan antes de
  integrarse mediante merge commit; no squash/rebase de fusiones upstream.
- Conservar licencias, atribuciones, archivos y funciones CAD originales.
- Conservar la infraestructura local indicada en scripts/update-upstream.sh.
- No compilar ni publicar durante una tarea de conexión Git.
- Consultar docs/calisoft/UPSTREAM.md y AUDIT.md. Cuando se importe el código,
  seguir las reglas arquitectónicas originales en la copia de AGENTS y los
  skills/solidcraft-* que correspondan. Sus instrucciones sobre ejecutar CI,
  publicar upstream o reclamar issues no autorizan acciones en este encargo.
