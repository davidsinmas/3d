# Compilación web — wasm-bindgen superado con 16 GB, 28 de octubre de 2026

**Estado más reciente:** el ensayo autorizado con 16 GB completó wasm-bindgen (código 0) y la validación estructural del WASM y sintáctica del JavaScript. No se ha completado aún wasm-opt, el ensamblado de Trunk, el hook offline ni la prueba funcional/ZIP. Los apartados anteriores al ensayo con 16 GB describen el historial de fallos, no el resultado más reciente.

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

## Revisión posterior de registros del sistema

Revisados los registros accesibles del mismo Codespace, sin compilar ni modificar configuración:

- journalctl no está instalado; dmesg devuelve Operation not permitted. No se dispone desde el contenedor del registro del kernel/host; no se han intentado eludir esos permisos.
- Revisados remoteagent.log, ptyhost.log, los logs de la extensión Codespaces de la sesión 20261028T042558 y creation.log. No se encontró una orden de apagado, OOM o SIGTERM que identifique al emisor a las 05:51:26 UTC.
- remoteagent.log y ptyhost.log registran una conexión y actividad a las 05:58:41–05:58:42 UTC, posteriores al fallo, en la misma carpeta de sesión. Esto no respalda atribuir el fallo a una detención completa del entorno en ese instante, pero no prueba por sí solo ausencia de cualquier evento del host.
- Los límites visibles memory.max y memory.high muestran max; los contadores memory.events actuales son cero. Estos valores son del cgroup visible y de la sesión reabierta; no describen necesariamente límites superiores del host durante el fallo. Los contadores antes/después de la ejecución original también eran cero.
- Árbol Git local limpio. Cachés y registros preservados.

Conclusión: la señal externa está documentada; su proceso emisor y motivo no pueden identificarse con los registros disponibles. El siguiente paso para atribuirla con certeza es consultar la telemetría del host mediante soporte oficial de GitHub, aportando el nombre del Codespace, la hora UTC y el extracto sanitizado de strace. No se ha enviado ninguna consulta de soporte ni se ha lanzado otro build.

## Ensayos aislados sobre la copia sin DWARF y un trabajador Rayon

La comprobación manual del archivo original encontró 351,74 MiB en secciones custom `.debug_*`. Se creó una copia separada de 106,89 MiB, conservando el original de aproximadamente 459 MiB y las demás secciones. Según el resultado aportado por el propietario, el primer ensayo de wasm-bindgen sobre esa copia terminó con 143 a los 33 s, con `SI_USER, si_pid=0, si_uid=61876` a las 10:20:40.958466.

Después se comprobó en el código oficial de wasm-bindgen 0.2.129 que cli-support activa la característica parallel de walrus:
https://github.com/wasm-bindgen/wasm-bindgen/blob/0.2.129/crates/cli-support/Cargo.toml

Se autorizó y ejecutó UN ensayo distinto, solo del posprocesamiento, con `RAYON_NUM_THREADS=1`, sobre la misma copia sin DWARF, sin Cargo, cambios de máquina ni desactivación de protecciones. Los argumentos de wasm-bindgen fueron los mismos: target web, weak-refs y no-typescript. El directorio de salida fue independiente.

Resultados medidos:
- Inicio: 2026-10-28T10:33:54Z.
- Terminación SIGTERM: 10:34:50.345983 UTC; finalización del registro: 10:34:51Z.
- Resultado: 143; duración del proceso: 56 s.
- Máximo RSS observado por muestreo cada segundo: **5.136.360 KiB (4,90 GiB)**.
- Máximo de hilos observados del proceso: **2** (principal y un trabajador). La limitación Rayon se aplicó.
- Mínimo MemAvailable observado: **890.520 KiB (aproximadamente 870 MiB)**; SwapFree=0.
- Señal: `SIGTERM {si_signo=SIGTERM, si_code=SI_USER, si_pid=0, si_uid=61876}`.
- Todos los contadores cgroup antes/después siguieron en cero.
- Directorio de salida vacío; sin artefactos web completos. Sin procesos de compilación activos al terminar ni cambios en archivos versionados locales.

Los logs, métricas, estado, timestamps y el script experimental permanecen fuera de Git en:
`target/calisoft-build-logs/rayon1-JuHO9Ft0/`
y `target/calisoft-build-logs/test-rayon1.sh`.

Interpretación: la reducción del tamaño de entrada y de la concurrencia NO bastaron. La memoria disponible descendió fuertemente antes de la señal, lo que refuerza la hipótesis de presión de memoria y un protector del host. No demuestra que earlyoom u otro servicio concreto sea el emisor: no se dispone del log del host y el pico es muestreado, no exacto. Tampoco se ha demostrado una mejora de memoria frente al ensayo sin limitar Rayon, que no disponía de estas mismas métricas.

No hay más reintentos automáticos. Siguientes opciones: solicitar identificación del emisor al soporte oficial, o autorizar una prueba acotada del mismo posprocesamiento con más RAM conservando el mismo Codespace y sus cachés. Cambiar a una máquina superior sigue requiriendo autorización del propietario; no se ha realizado.

Versión desarrollada: base SolidCraft 0.24.1. Rust compilado: 0.24.1. Web compilada y validada: pendiente. Publicación OVH: sin cambios en esta intervención (la comprobación HTTP previa identificó Calisoft 3D 0.9.1).

## Ensayo autorizado con 16 GB: wasm-bindgen correcto

El propietario autorizó temporalmente 4 núcleos/16 GB en el MISMO Codespace, por un máximo de 10 minutos, utilizando solo la cuota incluida y restaurando después 2 núcleos/8 GB y la detención.

Antes de iniciar, la página oficial de facturación de davidsinmas mostró 0,34 USD de cómputo cubiertos dentro del equivalente incluido de aproximadamente 10,80 USD, y 0,24 USD de almacenamiento dentro de aproximadamente 1,05 USD. No se habilitaron pagos ni se modificaron presupuestos. Se comprobó dentro del Codespace que había 15.993 MiB de RAM y 4 CPU, que seguía presente la copia sin DWARF y que no había otro proceso de compilación.

Se reutilizó el mismo archivo de entrada de 106,89 MiB con wasm-bindgen 0.2.129, los mismos argumentos y RAYON_NUM_THREADS=1. Solo se amplió la RAM/CPU del entorno. Se añadió un límite preventivo de 480 s (timeout, con hasta 10 s adicionales para finalizar); NO se alcanzó ese límite.

| Medición | Resultado |
| --- | --- |
| Inicio del proceso | 2026-10-28T10:48:01Z |
| Fin del registro | 2026-10-28T10:48:51Z |
| Resultado wasm-bindgen | **0, correcto** |
| Duración | **50 s** |
| Pico RSS observado cada segundo | **5.895.032 KiB, aproximadamente 5,62 GiB** |
| Máximo de hilos observado | **2**, principal y un trabajador |
| Mínimo MemAvailable muestreado | **8.071.952 KiB, aproximadamente 7,70 GiB** |
| Swap | 0 |
| Contadores cgroup antes/después | Todos permanecen en cero |

Artefactos preservados:
- `target/calisoft-build-logs/ram16-rayon1-c61bMjmP/out/solidcraft-web_bg.wasm`: **104.945.405 bytes**.
- `target/calisoft-build-logs/ram16-rayon1-c61bMjmP/out/solidcraft-web.js`: aproximadamente 178 KiB.
- En el mismo directorio del ensayo: timestamps, console.log, signals.log, memory.log, status.txt, metrics.txt y contadores cgroup.
- Script aislado: `target/calisoft-build-logs/test-ram16-rayon1.sh`.
- Se conservan el WASM original, la copia sin DWARF y toda la caché de Cargo. No se ejecutó Cargo ni una nueva compilación Rust.

Validaciones ejecutadas con el Node ya instalado por VS Code (v24.22.1):
- WebAssembly.validate sobre el WASM generado: **true**, salida 0.
- `node --input-type=module --check` sobre el JavaScript generado: salida **0**.
- Hash SHA-256 WASM: `7a1d5e7abcf3b86c9cb4de88028d036e6968d4b99422bdac38196ff0a5938462`.
- Hash SHA-256 JavaScript: `d1f14197113b0ea92e7625f95e8c2c15f737e7a2c4c260a0b0585e430fb704f2`.

Conclusión acotada: el bloqueo de esta fase se ha superado con 16 GB; el mismo posprocesamiento con 8 GB había recibido SIGTERM al quedar poca memoria disponible. La comparación respalda la hipótesis de presión de memoria en el entorno de 8 GB, pero no identifica nominalmente al emisor del SIGTERM. No se ha demostrado que fuese earlyoom ni que se debiera a un defecto de wasm-bindgen.

La detención de la máquina de 16 GB se confirmó aproximadamente 262 s después de solicitar su arranque, dentro del máximo autorizado. Se restaura después la configuración de 2 núcleos/8 GB, sin reiniciar la fase pesada en esa máquina.

### Pendiente para una entrega publicable

1. Conservar los dos archivos generados para no repetir este paso.
2. Ejecutar la optimización wasm-opt z requerida por el index original.
3. Completar el ensamblado de recursos de Trunk y el hook web-offline (sw.js/build.json), procurando aprovechar herramientas y binarios existentes.
4. Validar recursos y arranque en navegador; después empaquetar. Ningún ZIP está aún validado para publicación.
5. Documentar el procedimiento definitivo antes de considerar reproducible la compilación web completa. Cualquier nueva ampliación de recursos queda fuera de este ensayo acotado y requiere respetar la autorización aplicable.

Versión desarrollada: SolidCraft 0.24.1 en calisoft/build-low-memory-20261028. Rust compilado y posprocesamiento wasm-bindgen estructuralmente validado: 0.24.1. Aplicación web completa validada: pendiente. Versión publicada previamente comprobada en OVH: Calisoft 3D 0.9.1, sin cambios realizados. main, upstream y GitHub Actions no se modifican.
