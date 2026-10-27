#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/upstream-common.sh"
[[ "$(git branch --show-current)" == update/solidcraft-* ]] || fail 'Solo se finalizan ramas update/solidcraft-*.'
[[ -f "$(git rev-parse --git-path MERGE_HEAD)" ]] || fail 'No hay una fusión pendiente.'
[[ -z "$(git diff --name-only --diff-filter=U)" ]] || fail 'Quedan conflictos sin resolver.'
[[ -z "$(git ls-files -- .github/workflows)" ]] || fail 'Elimina los workflows antes de confirmar la integración.'
git diff --quiet || fail 'Quedan cambios sin añadir al índice; revísalos primero.'
[[ -z "$(git ls-files --others --exclude-standard)" ]] || fail 'Quedan archivos nuevos sin revisar.'
# The original history contains a few pre-existing whitespace findings. Check
# only the downstream files that this integration procedure creates or protects.
git diff --cached --check HEAD -- AGENTS.md README.md .devcontainer docs/calisoft \
  scripts packaging/calisoft rust-toolchain.toml
for path in LICENSE-MIT LICENSE-APACHE NOTICE ATTRIBUTION.md THIRD-PARTY-LICENSES.txt; do
  git cat-file -e ":$path" || fail "Falta el aviso original $path."
done
target="$(cat "$(git rev-parse --git-path MERGE_HEAD)")"
git commit -m "Merge SolidCraft ${target:0:12} for review; retain Calisoft infrastructure and exclude Actions"
git merge-base --is-ancestor "$target" HEAD || fail 'No se conservó el historial original.'
printf '\nFusión local guardada con ambos historiales. No se ha publicado nada.\n'
printf 'Para guardar la rama en tu GitHub: git push -u origin %s\n' "$(git branch --show-current)"
printf 'Después abre un PR hacia main y revísalo. Usa merge commit, nunca squash/rebase para esta integración.\n'
