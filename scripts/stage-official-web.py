#!/usr/bin/env python3
"""Prepara un ZIP WEB OFICIAL de SolidCraft SIN Rust, Trunk, Codespaces ni Actions.

Uso desde la raíz de davidsinmas/3d:
  python3 scripts/stage-official-web.py
  python3 scripts/stage-official-web.py --version 0.25.1
  python3 scripts/stage-official-web.py --version 0.25.1 \
      --archive /ruta/solidcraft-web-0.25.1.zip --checksums /ruta/SHA256SUMS.txt

Salida: dist/upstream-official/solidcraft-web-<version>/
No cambia Git, ningún Codespace, los datos locales ni el sitio OVH.
Separa claramente la versión oficial precompilada del CAD personalizado.
"""
from __future__ import annotations

import argparse
from contextlib import closing
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import tempfile
import urllib.request
import zipfile

DEFAULT_VERSION = "0.25.1"  # release oficial observado el 2026-10-28; nunca seguir 'latest' sin revisión
BASE_URL = "https://github.com/tangency-labs/solidcraft/releases/download"
ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "dist" / "upstream-official"
REQUIRED = ("index.html", "LICENSE-MIT", "LICENSE-APACHE", "NOTICE", "THIRD-PARTY-LICENSES.txt")
MAX_UNCOMPRESSED = 1024 * 1024 * 1024
MAX_FILES = 20000


def version_arg(value: str) -> str:
    if not re.fullmatch(r"\d+\.\d+\.\d+", value):
        raise argparse.ArgumentTypeError("La versión debe ser X.Y.Z, sin espacios ni URLs.")
    return value


def download(url: str, path: Path) -> None:
    request = urllib.request.Request(url, headers={"User-Agent": "Calisoft3D-official-release/1.0"})
    with closing(urllib.request.urlopen(request, timeout=90)) as response, path.open("wb") as destination:
        shutil.copyfileobj(response, destination, length=1024 * 1024)


def digest(path: Path) -> str:
    sha = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            sha.update(chunk)
    return sha.hexdigest()


def expected_digest(checksums: str, filename: str) -> str:
    for line in checksums.splitlines():
        match = re.fullmatch(r"\s*([a-fA-F0-9]{64})\s+\*?([^\s]+)\s*", line)
        if match and match.group(2) == filename:
            return match.group(1).lower()
    raise ValueError(f"No existe una huella SHA-256 válida para {filename} en SHA256SUMS.txt")


def check_archive(archive: Path, version: str) -> tuple[int, int]:
    if not zipfile.is_zipfile(archive):
        raise ValueError("El paquete descargado no es un ZIP.")
    root = f"solidcraft-web-{version}"
    total, count, names = 0, 0, set()
    with zipfile.ZipFile(archive) as z:
        for entry in z.infolist():
            parts = PurePosixPath(entry.filename)
            if not entry.filename or parts.is_absolute() or "\\" in entry.filename or ".." in parts.parts:
                raise ValueError("Ruta insegura dentro del ZIP.")
            if not parts.parts or parts.parts[0] != root:
                raise ValueError("El ZIP no conserva la estructura oficial.")
            if entry.filename in names:
                raise ValueError("ZIP con nombres de archivo duplicados.")
            names.add(entry.filename)
            if entry.flag_bits & 0x01:
                raise ValueError("ZIP cifrado, no es el paquete público esperado.")
            mode = (entry.external_attr >> 16) & 0xFFFF
            kind = stat.S_IFMT(mode)
            if kind not in (0, stat.S_IFREG, stat.S_IFDIR):
                raise ValueError("El paquete contiene enlaces u otros archivos no seguros.")
            if entry.is_dir():
                continue
            count += 1
            total += entry.file_size
            if count > MAX_FILES or total > MAX_UNCOMPRESSED:
                raise ValueError("El ZIP excede los límites de extracción segura.")
        for name in REQUIRED:
            if f"{root}/{name}" not in names:
                raise ValueError("Falta un archivo imprescindible: " + name)
        if not any(x.startswith(root + "/") and x.lower().endswith(".wasm") for x in names):
            raise ValueError("La distribución no contiene un módulo WASM.")
        if not any(x.startswith(root + "/") and x.lower().endswith(".js") for x in names):
            raise ValueError("La distribución no contiene JavaScript.")
    return count, total


def stage(archive: Path, checksums: Path, version: str, output_dir: Path = OUT) -> Path:
    name = f"solidcraft-web-{version}.zip"
    expected = expected_digest(checksums.read_text(encoding="utf-8"), name)
    actual = digest(archive)
    if expected != actual:
        raise ValueError("SHA-256 diferente de la publicación oficial: no se extrae ni se publica.")
    count, size = check_archive(archive, version)
    output_dir.mkdir(parents=True, exist_ok=True)
    destination = output_dir / f"solidcraft-web-{version}"
    if destination.exists():
        raise FileExistsError(f"Ya existe una copia: {destination}. Se conserva sin sobrescribir.")
    with tempfile.TemporaryDirectory(dir=output_dir, prefix=".stage-solidcraft-") as temp:
        scratch = Path(temp)
        with zipfile.ZipFile(archive) as z:
            z.extractall(scratch)
        source = scratch / f"solidcraft-web-{version}"
        if not (source / "index.html").is_file():
            raise ValueError("No existe index.html después de extraer.")
        # El navegador usa HTTPS para permitir guardar en OPFS. No sustituye a una prueba en OVH.
        html = (source / "index.html").read_text(encoding="utf-8")
        if re.search(r'(?:href|src)="/[^/]', html):
            raise ValueError("El index.html usa rutas absolutas incompatibles con subcarpetas.")
        source.rename(destination)
    manifest = {
        "original": "https://github.com/tangency-labs/solidcraft",
        "version": version,
        "asset": name,
        "sha256": expected,
        "files": count,
        "uncompressed_bytes": size,
        "build": "oficial precompilado; NO se ha usado Codespaces, Rust ni GitHub Actions",
        "code_modified": False,
        "published_in_ovh": False,
    }
    (output_dir / f"solidcraft-web-{version}.provenance.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    return destination


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", type=version_arg, default=DEFAULT_VERSION)
    parser.add_argument("--archive", type=Path)
    parser.add_argument("--checksums", type=Path)
    parser.add_argument("--output", type=Path, default=OUT)
    args = parser.parse_args()
    if bool(args.archive) != bool(args.checksums):
        parser.error("Para uso sin conexión indica --archive Y --checksums.")
    name = f"solidcraft-web-{args.version}.zip"
    url = f"{BASE_URL}/v{args.version}"
    with tempfile.TemporaryDirectory(prefix="calisoft-official-release-") as tmp:
        working = Path(tmp)
        archive = args.archive or (working / name)
        sums = args.checksums or (working / "SHA256SUMS.txt")
        if args.archive is None:
            print(f"Descargando {name} y sus sumas de verificación (sin compilar)...", flush=True)
            download(url + "/" + name, archive)
            download(url + "/SHA256SUMS.txt", sums)
        result = stage(archive, sums, args.version, args.output)
    print(f"Paquete oficial preparado: {result}")
    print("No se ha iniciado Codespaces, ni recompilado Rust, ni publicado nada.")
    print("IMPORTANTE: Esta distribución oficial no incorpora personalizaciones Calisoft.")
    print("Safari: guardar en OPFS ≠ tener el diseño en Finder; usar Archivo > Descargar diseño.")


if __name__ == "__main__":
    main()
