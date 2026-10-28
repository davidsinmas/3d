#!/usr/bin/env python3
"""Pruebas aisladas del paquete oficial. No descarga nada ni inicia Codespaces."""
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile

MODULE_PATH=Path(__file__).with_name('stage-official-web.py')
SPEC=importlib.util.spec_from_file_location('calisoft_stage_official',MODULE_PATH)
STAGE=importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(STAGE)


def create_fixture(root: Path, version='0.25.1', extra=None):
    archive=root/f'solidcraft-web-{version}.zip'
    entries={
        'index.html':b'<html><head><script src="./loader.js"></script></head><body></body></html>',
        'loader.js':b'console.log("fake");',
        'fake.wasm':b'\\0asm-fake',
        'LICENSE-MIT':b'MIT',
        'LICENSE-APACHE':b'Apache-2.0',
        'NOTICE':b'attribution',
        'THIRD-PARTY-LICENSES.txt':b'dependencies',
    }
    if extra: entries.update(extra)
    with zipfile.ZipFile(archive,'w') as z:
        for name,data in entries.items():
            z.writestr(f'solidcraft-web-{version}/{name}',data)
    checksum=root/'SHA256SUMS.txt'
    checksum.write_text(STAGE.digest(archive)+'  '+archive.name+'\n',encoding='utf-8')
    return archive,checksum


class OfflineStagingTests(unittest.TestCase):
    def test_valid_archive_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp)
            zip_path,sums=create_fixture(base)
            dest=STAGE.stage(zip_path,sums,'0.25.1',base/'prepared')
            self.assertTrue((dest/'index.html').is_file())
            self.assertTrue((dest/'LICENSE-MIT').is_file())
            with self.assertRaises(FileExistsError):
                STAGE.stage(zip_path,sums,'0.25.1',base/'prepared')

    def test_tampered_package_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp)
            zip_path,sums=create_fixture(base)
            with zip_path.open('ab') as f: f.write(b'UNEXPECTED')
            with self.assertRaisesRegex(ValueError,'SHA-256'):
                STAGE.stage(zip_path,sums,'0.25.1',base/'prepared')

    def test_missing_notice_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp)
            zip_path,sums=create_fixture(base)
            with zipfile.ZipFile(zip_path,'a') as z:
                pass
            with zipfile.ZipFile(zip_path,'w') as z:
                z.writestr('solidcraft-web-0.25.1/index.html','hi')
                z.writestr('solidcraft-web-0.25.1/loader.js','js')
                z.writestr('solidcraft-web-0.25.1/loader.wasm','wasm')
            sums.write_text(STAGE.digest(zip_path)+'  '+zip_path.name+'\n',encoding='utf-8')
            with self.assertRaisesRegex(ValueError,'Falta un archivo'):
                STAGE.stage(zip_path,sums,'0.25.1',base/'prepared')

    def test_path_traversal_rejected_before_extraction(self):
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp)
            zip_path,sums=create_fixture(base,extra={'../outside.txt':b'BAD'})
            with self.assertRaisesRegex(ValueError,'Ruta insegura'):
                STAGE.stage(zip_path,sums,'0.25.1',base/'prepared')
            self.assertFalse((base/'outside.txt').exists())


if __name__=='__main__':
    unittest.main()
