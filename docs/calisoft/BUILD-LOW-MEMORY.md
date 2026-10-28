# Calisoft 3D — compilación web controlada (Codespaces)

## Estado y causa del fallo previo

El código web original está en la rama de importación de SolidCraft, no en la rama principal de infraestructura. Estos scripts se han creado partiendo de `update/solidcraft-20261027-214859-7fad8dbe` y **no** modifican el motor CAD, perfiles de Cargo, Trunk.toml, Cargo.lock ni el código fuente.

Incidencia comunicada: la compilación Rust release había terminado; Trunk/wasm-bindgen terminó con código 143 (SIGTERM), con alrededor de 4,9 GB observados en una máquina de 2 CPU y 8 GB. **No existe aquí un registro completo verificable de esa ejecución**. SIGTERM no permite confirmar OOM; también puede responder a límites de tiempo, interrupción externa o cierre del entorno. No atribuir una causa sin comparar eventos del cgroup y registros del sistema.

La versión del espacio de trabajo importado declara Rust 1.95 mínimo, release con `opt-level=3`, `lto=thin`, `codegen-units=16`; Trunk invoca wasm-bindgen y el `index.html` exige `wasm-opt=z`. Su hook post_build ejecuta `cargo xtask web-offline` para generar `sw.js` y `build.json`. No se deshabilita ninguna etapa.

## Procedimiento (sin Work, GitHub Actions, ni compilación automática)

Usar **el mismo Codespace** que conserve los artefactos `target/`, cuando sea posible. Crear otro Codespace puede perder la caché. Antes de cambiar de rama: `git status --short`; guardar cualquier cambio local importante. El repositorio de trabajo debe contener los scripts de la rama `calisoft/build-low-memory-20261028`.

Desde la raíz del repositorio, en el terminal autenticado:

```bash
git fetch origin
git switch calisoft/build-low-memory-20261028
bash scripts/diagnose-build.sh
bash scripts/setup-web.sh
bash scripts/build-web.sh --dry-run
```

Si faltan dependencias, **no iniciar la prueba**. Preparar instalaciones conscientemente, sin modificar el perfil release ni limpiar `target/`. `setup-web.sh` solo comprueba: no instala herramientas.

**Solo después de revisar el diagnóstico** y confirmar que el Codespace sigue activo, lanzar una única compilación:

```bash
bash scripts/build-web.sh
```

El script configura únicamente `CARGO_BUILD_JOBS=1`, usa `flock` para evitar ejecuciones concurrentes mediante este mismo script, ejecuta el comando Trunk original, y captura salida, tiempo, RSS máximo (`/usr/bin/time -v`), eventos del cgroup antes/después y estado de salida. No añade RUSTFLAGS, no borra ni reubica target, no fuerza rebuild, no reintenta, no sube artefactos, no publica. Los logs permanecen en `target/calisoft-build-logs/`, excluido por .gitignore.

Si se ejecuta `trunk build` por fuera del script u otro proceso Cargo simultáneo, `flock` no puede impedirlo. Antes de compilar, cerrar tareas de compilación ajenas al script.

## Interpretación de resultados

- `status=0` y presencia de `dist/web/index.html`, `dist/web/*.wasm`, `dist/web/sw.js`, `dist/web/build.json`: artefactos generados (no equivale a pruebas funcionales ni publicación).
- `status=143`: proceso terminado por SIGTERM. Examinar quién lo emitió; no equivale automáticamente a OOM.
- `status=137`: SIGKILL, compatible con OOM pero no concluyente por sí solo.
- Aumento de `oom`/`oom_kill` en `memory.events`: evidencia adicional de presión/terminación por memoria cgroup.
- Sin incremento de OOM y con SIGTERM: inspeccionar expiración del Codespace, terminación manual, límites/gestor de procesos y registros del contenedor.
- El **RSS máximo** de `time` no es la suma de toda la memoria consumida por los procesos; cotejarlo con `memory.current`, `memory.peak` y eventos del cgroup.
- Fallo durante wasm-bindgen o wasm-opt: identificar el mensaje exacto antes de retocar flags que invalide la caché.
- Fallo en el hook `web-offline`: revisar `cargo xtask` y el manifiesto, sin repetir todo a ciegas.

Cuando termine, compartir **solo el tramo pertinente** del log y las métricas; revisar que no incluyan rutas o datos privados antes de compartirlos públicamente.

## Optimización posterior, solo si hay evidencia

Si wasm-opt (marcado `data-wasm-opt="z"`) es la etapa que supera el límite, evaluar y medir una ejecución alternativa con optimización menos exigente **en otra rama**, sin cambiar el perfil Rust ni publicar ese resultado automáticamente. Si el problema se reproduce en wasm-bindgen y no hay OOM, verificar versiones compatibles con el WASM generado y la herramienta Trunk instalada. Si el límite es el cierre programado de Codespaces, corregir ese mecanismo antes de tocar Cargo.

**No se ha realizado la compilación de validación desde Chat:** los conectores actuales permiten editar GitHub, pero no acceder al shell ni a la RAM del Codespace del usuario. No declarar éxito ni una nueva versión publicada sin ver un resultado real.
