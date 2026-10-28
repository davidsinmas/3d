#!/usr/bin/env bash
# Read-only environment and resource report for Codespaces (Linux).
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
echo "=== Calisoft 3D | diagnóstico SIN compilación ==="
date -u '+Fecha UTC: %Y-%m-%dT%H:%M:%SZ'
printf 'Directorio: %s\n' "$ROOT"
if command -v git >/dev/null 2>&1; then
  git -C "$ROOT" branch --show-current 2>/dev/null | sed 's/^/Rama: /' || true
  git -C "$ROOT" rev-parse --short HEAD 2>/dev/null | sed 's/^/Commit: /' || true
fi
uname -smr
if command -v nproc >/dev/null 2>&1; then printf 'CPU disponibles: %s\n' "$(nproc)"; fi
if command -v free >/dev/null 2>&1; then
  echo "--- Memoria y swap (host / namespace) ---"
  free -h
fi
if [[ -r /proc/meminfo ]]; then
  grep -E '^(MemTotal|MemAvailable|SwapTotal|SwapFree):' /proc/meminfo || true
fi
echo "--- Cgroup: límites y eventos ---"
for file in /sys/fs/cgroup/memory.max /sys/fs/cgroup/memory.current \
            /sys/fs/cgroup/memory.peak /sys/fs/cgroup/memory.swap.max \
            /sys/fs/cgroup/memory.swap.current /sys/fs/cgroup/memory.events \
            /sys/fs/cgroup/memory/memory.limit_in_bytes \
            /sys/fs/cgroup/memory/memory.usage_in_bytes \
            /sys/fs/cgroup/memory/memory.failcnt \
            /sys/fs/cgroup/memory/memory.oom_control; do
  if [[ -r "$file" ]]; then
    echo "$file:"
    cat "$file" || true
  fi
done
echo "--- Espacio libre ---"
df -h "$ROOT" || true
echo "--- Límites relevantes del proceso ---"
printf 'ulimit -v (KB): '; ulimit -v || true
printf 'ulimit -t (s): '; ulimit -t || true
echo "--- Procesos con más memoria RSS (KB) ---"
if command -v ps >/dev/null 2>&1; then
  ps -eo pid,ppid,rss,pcpu,comm --sort=-rss | head -n 13 || true
fi
echo "--- Herramientas ---"
for tool in rustc cargo rustup trunk wasm-bindgen wasm-opt; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%s: ' "$tool"
    "$tool" --version 2>&1 | head -n 1 || true
  else
    echo "$tool: no encontrado en PATH"
  fi
done
if command -v rustup >/dev/null 2>&1; then
  rustup show active-toolchain 2>/dev/null || true
  rustup target list --installed 2>/dev/null || true
fi
echo "El diagnóstico NO identifica por sí solo quién envió un SIGTERM."
