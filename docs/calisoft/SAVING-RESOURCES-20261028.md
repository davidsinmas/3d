# Calisoft 3D — ahorro de GitHub sin perder trabajo

## Estado y objetivo (28/10/2026)

Esta configuración y los scripts son **operativos solo tras integrarlos** en la rama de trabajo correspondiente. No se ha abierto ni detenido ningún Codespace por esta modificación. No se han borrado cachés, cambiado RAM/CPU, compilado Rust, lanzado Actions ni desplegado a OVH.

### 1. Prioridad: distribución oficial web sin compilación

Existe una distribución web precompilada de SolidCraft **0.25.1** con ZIP y `SHA256SUMS.txt`:
https://github.com/tangency-labs/solidcraft/releases/tag/v0.25.1

El script `scripts/stage-official-web.py` **descarga solo al ejecutarlo manualmente**, verifica SHA-256 del ZIP según el archivo oficial de sumas, valida rutas y licencias, y extrae a `dist/upstream-official/`. Ninguna instalación de Rust, Cargo, Trunk, CodeSpace, Actions ni subida a OVH es necesaria.

```bash
python3 scripts/stage-official-web.py
python3 scripts/test_stage_official_web.py
```

Se puede ejecutar también con `--archive` y `--checksums` ya descargados para trabajar sin red. No sobrescribe una extracción previa. `dist/` ya estaba excluido de Git.

**Importante:** el artefacto oficial 0.25.1 **NO** contiene los ajustes de Calisoft sobre la rama de código importado 0.24.1. No hay equivalencia de versiones ni garantía de compatibilidad para diseños entre versiones. Solo utilizarlo como distribución oficial intacta o para hacer una prueba separada. Para personalizar y publicar una distribución Calisoft real, una compilación controlada continúa siendo necesaria.

### 2. Codespace con caché — CONSERVAR

Codespace histórico: `sinister-orb-r7rxjg6pj5jrh5vv6`. Reutilizar ese **mismo Codespace** mientras conserve `target/`, logs y las herramientas; no crear otro para cada intento ni ejecutar `cargo clean`, `git clean -fdx` o reconstrucciones de contenedor sin verificar las consecuencias.

El ensayo previo de wasm-bindgen se completó con **16 GB**, no con 8 GB. Una máquina de 2 núcleos/8 GB sirve para scripts Git y revisión, pero **no está demostrada como suficiente para el posprocesamiento WASM**. Para esa tarea, utilizar la memoria requerida, una sola prueba autorizada y devolver a la máquina pequeña al terminar si corresponde.

Detener (NO eliminar) al terminar. El estado y archivos persisten en un Codespace detenido, con coste de almacenamiento, pero sin coste de cómputo. GitHub no detiene el Codespace simplemente por cerrar la pestaña:
https://github.com/codespaces

El usuario ya ha aplicado el nuevo tiempo predeterminado de inactividad de **5 minutos**. Los Codespaces anteriores pueden conservar su tiempo propio. No modificar retención a `0`: eliminaría los Codespaces detenidos y las cachés. Mantener suficiente retención para guardar los artefactos mientras la compilación continúe.

### 3. Compilaciones bajo demanda

`scripts/build-web.sh` **ya es manual** y limita `CARGO_BUILD_JOBS=1`, conserva `target/`, comprueba el entorno, registra métricas y nunca reintenta automáticamente ni publica. Mantenerlo así. **No** editar `Cargo.lock`, flags o configuración de Rust por cambios cosméticos, ya que pueden invalidar la caché.

Para distinguir un despliegue sin cambios de código de uno personalizado:
- Sin cambios Rust/egui/funciones CAD: utilizar `stage-official-web.py` para la versión oficial, sin compilar.
- Con cambios Rust/egui/funciones CAD: utilizar el build bajo demanda, tras diagnóstico y con recursos RAM suficientes.
- No iniciar una compilación como efecto de abrir Codespaces, cambiar de rama o entrar en el portal.

### 4. GitHub Actions automáticas

El árbol revisado de `davidsinmas/3d` en `main`, `update/solidcraft-20261027-214859-7fad8dbe` y `calisoft/build-low-memory-20261028` **no contiene archivos `.github/workflows/*.yml`**. El historial de ejecuciones consultado de 3D devuelve cero runs. No crear workflows automáticos ni activar prebuilds.

Los workflows automáticos existentes en otros proyectos de CalisoftProjects se están poniendo en modo **workflow_dispatch** (solo manual), con ramas de copia de seguridad antes de los cambios. No desactivar nunca la protección de los endpoints o los controles de login solo para ahorrar minutos.

### 5. Configuración de prebuilds y máquina

Los prebuilds son una opción **a nivel de repositorio en GitHub Settings → Codespaces**. No se configuran en `devcontainer.json` ni se pueden dar por desactivados porque no existan workflows versionados: GitHub los gestiona externamente, con Actions. Este chat **no dispone de permisos administrativos de Codespaces** para consultar o cambiar esa configuración; no se ha confirmado si hay prebuilds habilitados.

Revisar si en https://github.com/davidsinmas/3d/settings/codespaces aparece alguna configuración:
- Si existe y ejecuta prebuilds automáticos: menú de tres puntos → `Disable runs` (o eliminar configuración solo tras revisar sus efectos).
- Si solo aparece la opción `Set up prebuilds`: no crear ninguna.
- Cambiar máquina de un Codespace ya existente desde https://github.com/codespaces → `...` → `Change machine type`; no forzar 2 CPU/8 GB durante la fase que ya necesitó 16 GB.

La configuración alternativa `.devcontainer/upstream/devcontainer.json` solo hace `git fetch` y **NO** compila nada al abrir un Codespace. La descarga Git al iniciar consume red y tiempo; para evitar incluso eso, puede ejecutarse el script `setup-upstream.sh` solo a demanda, pero no tocar la configuración del Codespace con caché sin una revisión de su estado.

### 6. Guardado de documentos CAD en Safari / ordenador

SolidCraft original utiliza **OPFS** (almacenamiento privado del origen del navegador). En Safari, el botón de guardar puede persistir el diseño en OPFS, sin crear un archivo Finder. La función original `Archivo > Descargar diseño` entrega una copia a la carpeta de descargas del dispositivo; usarla como copia explícita tras trabajar.

No borrar datos de Safari/Chrome ni variar el origen del sitio de producción antes de exportar los diseños: OPFS depende del origen. Para nube, usar inicialmente una carpeta sincronizada (iCloud Drive, Drive o OneDrive) con archivos descargados.

Un gestor `Mis proyectos` en Supabase Storage requeriría decidir autenticación, permisos RLS y cuotas; **no está implementado ni se declara como almacenamiento de producción**. No guardar documentos personales en el repositorio público de GitHub.

### Qué no se ha hecho

- No se ha descargado el ZIP binario en ChatGPT ni se ha ejecutado el script en el Codespace.
- No hay compilación WebAssembly completa nueva, ni cambios a la web OVH.
- No se ha modificado `Cargo.toml`, `Cargo.lock`, `Trunk.toml`, `target/`, RAM, cuotas o retención de Codespaces.
- Los cambios en esta rama no implican que prebuilds estén desactivados administrativamente.

El objetivo es minimizar trabajo real, no maquillar resultados como terminados.
