#!/usr/bin/env bash
# One controlled Trunk release build, preserving existing Cargo cache and settings.
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
WEB="$ROOT/apps/solidcraft-web"
if [[ ! -f "$WEB/Trunk.toml" || ! -f "$WEB/index.html" || ! -f "$ROOT/Cargo.lock" ]]; then
  echo "ERROR: falta el código web de SolidCraft. Cambia a la rama de importación/compilación." >&2
  exit 2
fi
if [[ "$#" -gt 1 || ( "$#" -eq 1 && "$1" != "--dry-run" ) ]]; then
  echo "Uso: bash scripts/build-web.sh [--dry-run]" >&2
  exit 2
fi
echo "Calisoft 3D: compilación web release de consumo controlado"
echo "Rama: $(git -C "$ROOT" branch --show-current 2>/dev/null || echo desconocida)"
echo "Directorio: $WEB"
echo "Comando: trunk build --release --public-url ./"
echo "Cargo: CARGO_BUILD_JOBS=1; no cargo clean; no cambio de RUSTFLAGS/perfiles."
if [[ "${1:-}" == "--dry-run" ]]; then
  echo "SIMULACIÓN: ninguna compilación, descarga ni instalación realizada."
  exit 0
fi
bash "$ROOT/scripts/setup-web.sh"
if ! command -v trunk >/dev/null 2>&1; then
  echo "ERROR: Trunk no instalado; no se inicia compilación." >&2
  exit 2
fi
export CARGO_BUILD_JOBS=1
LOG_DIR="$ROOT/target/calisoft-build-logs"
mkdir -p "$LOG_DIR"
if command -v flock >/dev/null 2>&1; then
  exec 9>"$LOG_DIR/build.lock"
  if ! flock -n 9; then
    echo "ERROR: hay otra compilación Calisoft controlada en curso. No se ejecuta otra." >&2
    exit 4
  fi
else
  echo "AVISO: no hay flock; comprueba manualmente que ninguna otra compilación esté ejecutándose."
fi
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
LOG="$LOG_DIR/$RUN_ID.trunk.log"
METRICS="$LOG_DIR/$RUN_ID.time.txt"
EVENTS_BEFORE="$LOG_DIR/$RUN_ID.cgroup-before.txt"
EVENTS_AFTER="$LOG_DIR/$RUN_ID.cgroup-after.txt"
if [[ -r /sys/fs/cgroup/memory.events ]]; then
  cat /sys/fs/cgroup/memory.events > "$EVENTS_BEFORE"
fi
echo "Log: $LOG"
echo "Métricas: $METRICS"
echo "Para comprobar recursos previamente: bash scripts/diagnose-build.sh"
cd "$WEB"
start="$(date +%s)"
status=0
if [[ -x /usr/bin/time ]]; then
  /usr/bin/time -v -o "$METRICS" trunk build --release --public-url ./ 2>&1 | tee "$LOG" || status="${PIPESTATUS[0]}"
else
  echo "AVISO: /usr/bin/time ausente; no habrá medición de RSS máximo." | tee "$LOG"
  trunk build --release --public-url ./ 2>&1 | tee -a "$LOG" || status="${PIPESTATUS[0]}"
fi
elapsed=$(( $(date +%s) - start ))
if [[ -r /sys/fs/cgroup/memory.events ]]; then
  cat /sys/fs/cgroup/memory.events > "$EVENTS_AFTER"
fi
echo "Duración total: ${elapsed}s. Código de salida de Trunk: $status"
if [[ -f "$METRICS" ]]; then
  echo "--- Máximo RSS y terminación (/usr/bin/time) ---"
  grep -E 'Maximum resident set size|Elapsed \(wall clock\)|Exit status|Command terminated by signal' "$METRICS" || true
fi
if [[ -f "$EVENTS_BEFORE" && -f "$EVENTS_AFTER" ]]; then
  echo "--- Eventos cgroup (antes -> después; revisar oom/oom_kill) ---"
  paste "$EVENTS_BEFORE" "$EVENTS_AFTER" || true
fi
if (( status != 0 )); then
  echo "ERROR: compilación incompleta; no se repite automáticamente."
  echo "Revisar log y eventos cgroup. SIGTERM=143 no confirma por sí solo falta de memoria."
  exit "$status"
fi
DIST="$ROOT/dist/web"
if [[ ! -s "$DIST/index.html" || ! -s "$DIST/sw.js" || ! -s "$DIST/build.json" ]]; then
  echo "ERROR: Trunk terminó sin archivos web completos (index.html, sw.js, build.json)." >&2
  exit 5
fi
wasm_file="$(find "$DIST" -type f -name '*.wasm' -size +0c -print -quit)"
if [[ -z "$wasm_file" ]]; then
  echo "ERROR: falta un archivo .wasm no vacío en dist/web." >&2
  exit 5
fi
echo "OK: artefactos web presentes; WASM: $wasm_file"
echo "No se ha ejecutado ningún despliegue ni se ha publicado en OVH."
