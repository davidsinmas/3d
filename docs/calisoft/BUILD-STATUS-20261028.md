# Compilación web — registros recuperados, 28 de octubre de 2026

## Estado comprobado

- Rama: `calisoft/build-low-memory-20261028`.
- HEAD local de la ejecución: `03fabede7f0b51ac4ade8ecd2802dc7d85a8f626`; árbol de trabajo limpio al recuperar registros.
- Base: SolidCraft 0.24.1, upstream `7fad8dbec06ab4a6407249a71673dfef53e5221b`.
- Se pudo reabrir el MISMO Codespace `sinister-orb-r7rxjg6pj5jrh5vv6` (2 CPU/8 GB). El bloqueo de acceso anterior ha desaparecido.
- No se ha lanzado otra compilación ni modificado perfiles, RUSTFLAGS, herramientas o funciones CAD.

## Resultado real de la ejecución controlada

| Etapa | Resultado recuperado |
| --- | --- |
| Cargo/Rust | Correcto: release optimized + debuginfo, 23 min 31 s |
| wasm-bindgen 0.2.129 | Terminado por SIGTERM, señal 15 |
| wasm-opt | No alcanzado en esta ejecución |
| Trunk | Código de salida 1; duración total 1439 s (23 min 59 s) |
| Hook offline | No completado |
| Sitio web y ZIP | Sin resultado completo validado |

El archivo `target/calisoft-build-logs/controlled-20261028.status` contiene `1`.
El fallo aparece a las 05:51:26 UTC (06:51:26, Europe/Madrid).

## Evidencia de la terminación

El registro strace contiene, para el proceso wasm-bindgen PID 53110:

```text
05:51:26.049746 --- SIGTERM {si_signo=SIGTERM, si_code=SI_USER, si_pid=0, si_uid=61876} ---
```

Después registra la terminación del proceso y sus hilos por SIGTERM y el wait4 del padre. `SI_USER` indica una señal enviada por un proceso; `si_pid=0` es compatible con un emisor fuera del espacio de PID visible desde el contenedor. Es evidencia de terminación externa, no de un error de compilación Rust. La identidad concreta del emisor y el motivo de la orden siguen sin determinarse.

Los contadores cgroup registrados ANTES y DESPUÉS permanecen en cero: `low`, `high`, `max`, `oom`, `oom_kill` y `oom_group_kill`. No se ha registrado OOM en ese cgroup. Esto no descarta límites o políticas en un nivel superior; no se atribuye el fallo a memoria sin pruebas.

Tampoco queda demostrado que la detención posterior del Codespace causara este SIGTERM: Trunk pudo registrar el fallo y finalizar con código 1.

## Recursos y archivos conservados

- Muestreo RSS por proceso cada segundo: máximo observado de wasm-bindgen y de los procesos muestreados, **3.952.032 KiB (3,77 GiB)**, último registro a las 05:51:25 UTC.
- Es un pico OBSERVADO por muestreo; no es el máximo exacto del árbol completo. No hubo medición con /usr/bin/time.
- WASM intermedio de Rust conservado: `target/wasm32-unknown-unknown/release/solidcraft-web.wasm`, aproximadamente **459 MiB**.
- `target/wasm-bindgen/release` está vacío y no se encontraron archivos en el primer nivel de `dist/web`.
- Sin procesos cargo, rustc, trunk, wasm-bindgen, wasm-opt o strace activos al comprobarlos.
- No se ha validado estructuralmente el WASM final ni se ha realizado prueba de navegador: no existe un resultado web completo.
- No se declara una mejora de consumo frente a intentos anteriores, cuyas condiciones y máximos no son directamente comparables.

Los registros completos permanecen en el Codespace, fuera de Git:

- `target/calisoft-build-logs/controlled-20261028.console.log`
- `target/calisoft-build-logs/controlled-20261028.signals.log`
- `target/calisoft-build-logs/controlled-20261028.memory.log`
- `target/calisoft-build-logs/controlled-20261028.status`
- `target/calisoft-build-logs/20261028T052727Z-36234.trunk.log`
- Archivos cgroup-before/cgroup-after de esa ejecución.

## Continuación mínima

1. Conservar target y todos los registros; no ejecutar cargo clean.
2. Investigar el emisor externo/política del host que provoca SIGTERM antes de repetir. La señal por sí sola no identifica el servicio responsable.
3. Si se aclara y corrige esa causa, priorizar solamente el posprocesamiento de WASM con las herramientas existentes. No repetir Cargo ni alterar RUSTFLAGS sin necesidad demostrada.
4. Tras completar Trunk: validar index.html, JS, WASM, sw.js, build.json, referencias y arranque; después empaquetar con `bash packaging/web/package.sh --skip-build`.
5. No hay reintento automático ni cambio a una máquina superior.

Versión desarrollada: SolidCraft 0.24.1 en la rama indicada. Versión Rust compilada: 0.24.1. Versión web compilada y validada: ninguna confirmada. OVH: sin cambios realizados; versión publicada no verificada. main y el repositorio original permanecen intactos. No se ejecutó GitHub Actions en esta recuperación.
