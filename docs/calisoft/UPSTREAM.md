# Conexión mantenible con SolidCraft

## Estado y remotos

`origin` es https://github.com/davidsinmas/3d y `upstream` es
https://github.com/tangency-labs/solidcraft. Los remotos viven en `.git/config`;
no se distribuyen con un commit. `scripts/setup-upstream.sh` los comprueba y restaura,
detecta la rama principal mediante `git ls-remote --symref`, descarga su historial
y configura `upstream/HEAD`. La rama local main sigue perteneciendo a origin:
no se cambia su seguimiento hacia upstream. El push al remoto upstream queda
bloqueado localmente con una URL no operativa. No se altera el servidor original.

No somos un fork registrado en la red de forks de GitHub. Un remoto upstream y
un historial compartido permiten mantener el código, pero no crean esa relación
administrativa. Ver AUDIT.md para el estado real de la importación inicial.

## Codespaces

La configuración alternativa `.devcontainer/upstream/devcontainer.json` se llama
**Calisoft 3D — conexión Git (sin compilación)**. Se puede seleccionar al crear un
Codespace con opciones. Su postCreateCommand restaura automáticamente los remotos
y hace fetch. No integra cambios ni instala un compilador ni modifica otra
configuración de compilación. No se ha creado un Codespace durante este encargo.

Cuando se incorpore la configuración definitiva de compilación, añade esta entrada
al objeto `postCreateCommand`, conservando la imagen, recursos y comandos existentes:

```json
"calisoft-upstream": "bash scripts/setup-upstream.sh"
```

Si el comando existente es una cadena, conserva ese comando como otra entrada del
objeto. Las entradas pueden ejecutarse en paralelo: este hook solo configura/fetch
Git y nunca cambia archivos del árbol de trabajo. Si el setup existente también
opera con Git, encadena ambos en serie para evitar bloqueos.
En un clon normal basta ejecutar `./scripts/setup-upstream.sh` una vez.
No se activan prebuilds, facturación ni sincronizaciones periódicas.

## Actualizaciones controladas

```bash
./scripts/check-upstream.sh
./scripts/update-upstream.sh
```

El primer comando consulta y muestra commits y diferencias; no cambia el código.
El segundo requiere main limpio y que contenga origin/main. Crea una rama
`update/solidcraft-<fecha>-<sha>`, deja la fusión **sin commit** y muestra los
conflictos. Si los historiales son independientes utiliza
`git merge --allow-unrelated-histories --no-ff --no-commit`, conservando ambos
padres en el futuro commit. No hace una falsa fusión que ignore todo upstream.

La infraestructura propia se conserva por rutas explícitas; los conflictos CAD
requieren resolución manual. Esto protege scripts, docs/calisoft, .devcontainer,
rust-toolchain.toml y packaging/calisoft. Al actualizar Rust o herramientas, revisa
también si upstream exige versiones nuevas: conservar una configuración no garantiza
compatibilidad futura. Las personalizaciones de código se fusionan normalmente;
no se pueden garantizar actualizaciones sin conflictos.

Se eliminan del árbol final los workflows originales antes de poder guardar la
actualización. Sus versiones históricas permanecen en los commits originales:
no se reescribe el historial de sus autores. No se ejecuta GitHub Actions.
README y AGENTS originales quedan además en docs/calisoft/upstream-reference.
Las licencias MIT/Apache-2.0, NOTICE, ATTRIBUTION y licencias de dependencias se
importan y conservan. `upstream-merge.json` registra el commit y la base de la fusión.

Revisa `git diff --cached` y `git diff --name-only --diff-filter=U`. Resuelve y
añade los conflictos individualmente. Cuando estés conforme:

```bash
./scripts/finish-upstream.sh
git push -u origin "$(git branch --show-current)"
```

Abre un PR hacia main; valida las áreas afectadas y compila solo en una intervención
autorizada para ello. Integra mediante **Create a merge commit**, sin squash ni
rebase: así upstream conserva una base común real para la siguiente actualización.
No se publica en OVH. Para cancelar antes del commit: `git merge --abort` y
`git switch main`; la rama temporal puede conservarse para inspección.

## Estrategia de desarrollo

| Tipo de cambio | Rama y ubicación |
| --- | --- |
| Base revisada | main; cambios aceptados de ambos proyectos |
| Actualización original | update/solidcraft-*; una revisión por lote |
| Interfaz propia | calisoft/ui-*; crates/ui-egui y assets/locales |
| Nuevas herramientas | calisoft/tool-*; comandos en crates/engine, modelo en crates/doc |
| Croquis y restricciones | calisoft/sketch-*; crates/sketch y sus controles UI |
| Bibliotecas mecánicas | calisoft/library-*; ampliar mecanismos originales, datos propios separados |
| Integración con CalisoftProjects | calisoft/integration-*; adaptadores de la app, no el núcleo geométrico |
| Corrección general para upstream | contrib/*; commits pequeños e independientes |

Usa las capas existentes: geom → sketch/kernel/render → doc → io → engine → UI/apps.
Mantén las dependencias truck dentro de crates/kernel. Evita renombrar crates,
formatos, comandos y módulos sin necesidad. Separa cambios de marca e integración
privada de los que sean útiles para todos. No se desarrollan ahora funciones CAD.

## Contribuir al original

Este repositorio no está registrado como fork de SolidCraft; GitHub puede no
ofrecer un PR entre repositorios que no comparten su red de forks. La vía normal
es crear, con autorización posterior, un fork oficial distinto, por ejemplo
davidsinmas/solidcraft. No sustituye ni renombra davidsinmas/3d.

Para preparar una contribución: fetch upstream; crea una rama desde upstream/HEAD
en un worktree separado; aplica mediante cherry-pick **solo** los commits de utilidad
general. Lee CONTRIBUTING.md y las skills originales vigentes, conserva licencias
y añade las pruebas pertinentes. No incluyas credenciales, marcas ni configuración
de despliegue de Calisoft. No arrastres la fusión de historiales independientes.

Antes de subir una rama que conserve workflows originales a un fork propio,
deshabilita GitHub Actions en los ajustes de ese fork. No uses esa rama en 3d con
Actions habilitado. Un PR al original puede ejecutar su CI bajo las reglas y
recursos de sus mantenedores; no equivale a consumir nuestros minutos.
No se ha creado un fork, enviado un PR ni contactado con los desarrolladores.
