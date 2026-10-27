#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/upstream-common.sh"
clean_required
[[ "$(git branch --show-current)" == main ]] || fail 'Empieza desde main limpio; no se cambia de rama por ti.'
bash "$ROOT/scripts/setup-upstream.sh"
git fetch --no-tags origin main
git merge-base --is-ancestor origin/main HEAD || fail 'main no contiene origin/main. Revisa y actualiza main primero (sin reset ni force-push).'
ref="$(upstream_ref)"
target="$(git rev-parse "$ref")"
base="$(git rev-parse HEAD)"
if git merge-base --is-ancestor "$target" HEAD; then
  printf 'Esta versión original ya está integrada.\n'; exit 0
fi
kind=normal
merge_args=(--no-ff --no-commit)
if ! git merge-base HEAD "$target" >/dev/null; then
  kind=initial-unrelated-histories
  merge_args+=(--allow-unrelated-histories)
fi
branch="update/solidcraft-$(date -u +%Y%m%d-%H%M%S)-${target:0:8}"
git switch -c "$branch"
status=0
# Do not execute repository-provided local hooks while preparing imported code.
git -c core.hooksPath=/dev/null merge "${merge_args[@]}" "$target" || status=$?
[[ -f "$(git rev-parse --git-path MERGE_HEAD)" ]] || fail "Git no inició una fusión revisable (código $status). main sigue intacta."

# Only downstream infrastructure is protected automatically. CAD conflicts stay
# visible for human review; no blanket '-X ours' or fake history-only merge.
protected=(README.md AGENTS.md .devcontainer docs/calisoft
  scripts/upstream-common.sh scripts/setup-upstream.sh scripts/check-upstream.sh
  scripts/update-upstream.sh scripts/finish-upstream.sh
  scripts/calisoft-env.sh scripts/build-web.sh scripts/setup-web.sh
  scripts/package-web.sh scripts/clean-web.sh scripts/web-distribution.py
  packaging/calisoft rust-toolchain.toml)
for path in "${protected[@]}"; do
  if [[ -n "$(git ls-tree --name-only HEAD -- "$path")" ]]; then
    git restore --source=HEAD --staged --worktree -- "$path"
  elif [[ -n "$(git ls-files -- "$path")" ]]; then
    git rm -rf --ignore-unmatch -- "$path" >/dev/null
  fi
done
# Workflows remain in the original commit history, but never in an update branch's
# final tree. Nothing is pushed or executed by this script.
git rm -rf --ignore-unmatch -- .github/workflows >/dev/null
mkdir -p docs/calisoft/upstream-reference
for path in README.md AGENTS.md; do
  git show "$target:$path" > "docs/calisoft/upstream-reference/$path.txt"
done
printf '{\n  "repository": "https://github.com/tangency-labs/solidcraft",\n  "commit": "%s",\n  "base": "%s",\n  "integration": "%s"\n}\n' "$target" "$base" "$kind" > docs/calisoft/upstream-merge.json
git add docs/calisoft/upstream-reference docs/calisoft/upstream-merge.json
printf '\nRama preparada: %s\nOriginal: %s\n' "$branch" "$target"
if [[ -n "$(git diff --name-only --diff-filter=U)" ]]; then
  printf 'Conflictos pendientes (main no ha cambiado):\n'
  git diff --name-only --diff-filter=U
  printf 'Resuélvelos, añade los archivos resueltos y revisa el diff antes de finalizar.\n'
  exit 2
fi
git diff --cached --shortstat
printf '\nRevisa: git diff --cached\nFinaliza cuando proceda: ./scripts/finish-upstream.sh\nCancela la fusión: git merge --abort\n'
