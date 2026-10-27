#!/usr/bin/env bash
# Source-only helpers. Git operations only; no build or deployment.
set -Eeuo pipefail
ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
cd "$ROOT"
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
clean_required() {
  [[ -z "$(git status --porcelain)" ]] || fail 'Guarda tus cambios y archivos sin seguimiento antes de continuar.'
  [[ ! -e "$(git rev-parse --git-path MERGE_HEAD)" ]] || fail 'Ya hay una fusión pendiente.'
  [[ ! -d "$(git rev-parse --git-path rebase-merge)" && ! -d "$(git rev-parse --git-path rebase-apply)" ]] || fail 'Ya hay un rebase pendiente.'
}
upstream_ref() {
  git symbolic-ref --quiet refs/remotes/upstream/HEAD || fail 'Ejecuta scripts/setup-upstream.sh.'
}
