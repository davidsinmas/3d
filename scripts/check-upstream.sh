#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/upstream-common.sh"
bash "$ROOT/scripts/setup-upstream.sh"
ref="$(upstream_ref)"
printf '\nOriginal: '
git log -1 --format='%h %s' "$ref"
if base="$(git merge-base HEAD "$ref")"; then
  printf 'Base común: %s\n' "$base"
  printf 'Commits originales aún no integrados: '
  git rev-list --count "HEAD..$ref"
  git log --oneline -20 "HEAD..$ref"
  git diff --stat "$base" "$ref"
else
  printf 'Historiales independientes. La primera integración debe conservar ambos padres.\n'
  git log --oneline -10 "$ref"
fi
printf '\nPara preparar una rama revisable: ./scripts/update-upstream.sh\n'
