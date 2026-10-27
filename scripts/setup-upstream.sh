#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/upstream-common.sh"
case "$(git remote get-url origin)" in
  https://github.com/davidsinmas/3d|https://github.com/davidsinmas/3d.git|git@github.com:davidsinmas/3d.git|ssh://git@github.com/davidsinmas/3d.git) ;;
  *) fail 'origin no es davidsinmas/3d; no se cambia automáticamente.' ;;
esac
if git remote get-url upstream >/dev/null 2>&1; then
  case "$(git remote get-url upstream)" in
    https://github.com/tangency-labs/solidcraft|https://github.com/tangency-labs/solidcraft.git|git@github.com:tangency-labs/solidcraft.git|ssh://git@github.com/tangency-labs/solidcraft.git) ;;
    *) fail 'upstream ya apunta a otro proyecto. Revisa la configuración.' ;;
  esac
else
  git remote add upstream https://github.com/tangency-labs/solidcraft.git
fi
# A read-only upstream. This changes local Git config, not the official repository.
git config --local --replace-all remote.upstream.pushurl disabled://solidcraft-read-only
git config --local remote.pushDefault origin
branch="$(git ls-remote --symref upstream HEAD | sed -n 's|^ref: refs/heads/\([^[:space:]]*\).*HEAD$|\1|p')"
[[ -n "$branch" ]] || fail 'No se pudo detectar la rama principal del original.'
git check-ref-format "refs/heads/$branch" >/dev/null
if [[ "$(git rev-parse --is-shallow-repository)" == true ]]; then
  git fetch --unshallow --no-tags origin
fi
git fetch --no-tags upstream "refs/heads/$branch:refs/remotes/upstream/$branch"
git symbolic-ref refs/remotes/upstream/HEAD "refs/remotes/upstream/$branch"
printf 'origin: davidsinmas/3d; upstream: tangency-labs/solidcraft (%s).\n' "$branch"
printf 'Solo consulta: no se ha integrado, compilado ni publicado nada.\n'
