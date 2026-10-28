#!/usr/bin/env bash
# Check toolchain requirements without installing or changing anything.
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
if [[ ! -f "$ROOT/apps/solidcraft-web/Trunk.toml" || ! -f "$ROOT/Cargo.lock" ]]; then
  echo "ERROR: esta rama no contiene la aplicación web y Cargo.lock de SolidCraft." >&2
  exit 2
fi
echo "Calisoft 3D: comprobación de herramientas (sin descargas ni compilación)"
echo "Repositorio: $ROOT"
missing=0
for tool in rustc cargo rustup trunk; do
  if command -v "$tool" >/dev/null 2>&1; then
    "$tool" --version | head -n 1
  else
    echo "FALTA: $tool" >&2
    missing=1
  fi
done
if command -v rustup >/dev/null 2>&1; then
  echo "Toolchain activo:"
  rustup show active-toolchain || true
  if rustup target list --installed | grep -Fxq 'wasm32-unknown-unknown'; then
    echo "Target wasm32-unknown-unknown: instalado"
  else
    echo "FALTA el target wasm32-unknown-unknown; instalar manualmente si autorizas: rustup target add wasm32-unknown-unknown" >&2
    missing=1
  fi
fi
for tool in wasm-bindgen wasm-opt; do
  if command -v "$tool" >/dev/null 2>&1; then
    "$tool" --version | head -n 1 || true
  else
    echo "AVISO: $tool no figura en PATH. Trunk puede gestionar herramientas por su cuenta; verificar la versión antes de compilar."
  fi
done
echo "Trunk: apps/solidcraft-web/Trunk.toml; salida prevista: dist/web/"
echo "Cargo release: no se modifican perfil, RUSTFLAGS ni Cargo.lock."
if (( missing )); then
  echo "Entorno incompleto: no iniciar compilación todavía." >&2
  exit 2
fi
echo "Comprobación de herramientas terminada. No se ha ejecutado Trunk."
