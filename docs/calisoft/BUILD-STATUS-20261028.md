# Compilación web — estado parcial, 28 de octubre de 2026

## Fuente comprobada

- Rama: `calisoft/build-low-memory-20261028`.
- HEAD remoto comprobado a las 06:00 UTC: `03fabede7f0b51ac4ade8ecd2802dc7d85a8f626` (antes de este informe).
- Base incorporada según el encargo: SolidCraft 0.24.1, upstream `7fad8dbec06ab4a6407249a71673dfef53e5221b`.
- Los scripts existentes se conservan. En esta continuación no se cambian perfiles, RUSTFLAGS, herramientas ni funciones CAD.

## Ejecución pendiente de recuperar

El relevo anterior informa de UNA compilación iniciada aproximadamente a las 05:27 UTC, en el Codespace existente de 2 CPU/8 GB, con `CARGO_BUILD_JOBS=1`, nohup, strace y muestreo RSS por proceso cada segundo. No se ha iniciado otra compilación en esta continuación.

Registros que deben recuperarse en el mismo Codespace:

- `target/calisoft-build-logs/controlled-20261028.console.log`
- `target/calisoft-build-logs/controlled-20261028.signals.log`
- `target/calisoft-build-logs/controlled-20261028.memory.log`
- `target/calisoft-build-logs/controlled-20261028.status` (si terminó)
- Logs internos fechados y eventos cgroup antes/después en ese mismo directorio.

El muestreo RSS no equivale a un máximo exacto de memoria del árbol de procesos. `/usr/bin/time` faltaba según el relevo. Duración total y pico observado de esta ejecución: todavía no recuperados.

## Bloqueo observado en esta continuación

La pestaña conservada no estaba disponible en la nueva sesión. Al abrir la URL del Codespace existente apareció VS Code intentando conectar; posteriormente GitHub mostró `Stopping codespace...`. La gestión oficial lista el mismo Codespace, la misma rama y 2 CPU/8 GB. La reapertura del MISMO Codespace y una recarga siguieron mostrando la detención. No se pudo leer la salida real del terminal.

Este estado NO demuestra OOM, ni identifica el resultado de Cargo, wasm-bindgen, wasm-opt o Trunk. Tampoco permite atribuir los SIGTERM anteriores a la detención actual. No se repite el build ni se cambian parámetros por conjetura.

## Resultados y entrega

| Etapa | Resultado de la ejecución controlada |
| --- | --- |
| Cargo | Sin recuperar; el relevo lo dejó activo |
| wasm-bindgen | Sin verificar |
| wasm-opt z | Sin verificar |
| Trunk y hook web-offline | Sin verificar |
| Artefactos dist/web y validez WASM | Sin verificar |
| Arranque en navegador y offline | Pendiente |
| ZIP dist/solidcraft-web-0.24.1.zip | No confirmado |

La compilación Rust release anterior fue comunicada como correcta; no se sustituye con ella la validación de esta ejecución. No se declara una mejora de consumo sin métricas.

## Continuación mínima

1. Recuperar conexión al mismo Codespace; leer status y logs antes de cualquier acción.
2. Si hay proceso activo, conservarlo y posponer una única consulta. No lanzar un segundo build.
3. Si hay fallo, identificar proceso, señales con siginfo/si_pid, eventos OOM y conservación del WASM; detener intentos si falta certeza.
4. Si hay éxito, comprobar index.html, WASM estructuralmente válido, JS y referencias, sw.js/build.json y hook offline; hacer smoke test si es posible.
5. Empaquetar solo tras validar: `bash packaging/web/package.sh --skip-build`, conservando licencias. No subir binarios ni logs completos al repositorio.
6. Registrar métricas y resultado sanitizado aquí; detener el Codespace al terminar, sin eliminarlo.

Versión desarrollada: base SolidCraft 0.24.1 en esta rama. Versión compilada y validada: ninguna confirmada todavía. OVH: sin cambios realizados; versión publicada no verificada. main, upstream y producción no se modifican. No se ejecuta GitHub Actions ni se crea otro entorno.
