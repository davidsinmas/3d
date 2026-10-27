# Calisoft 3D

Repositorio conectado de forma controlada con
[SolidCraft](https://github.com/tangency-labs/solidcraft).

Estado actual: la conexión, los scripts y la documentación están preparados. El
código de SolidCraft se incorporará por primera vez en una rama revisable, sin
sobrescribir `main` ni activar GitHub Actions.

```bash
./scripts/check-upstream.sh
./scripts/update-upstream.sh
```

El segundo comando crea una rama `update/solidcraft-*` y deja la fusión preparada
para revisar. Consulta [docs/calisoft/UPSTREAM.md](docs/calisoft/UPSTREAM.md) para
resolver conflictos, finalizar la rama y abrir el PR hacia `main`.

No hay compilación, publicación en OVH ni actualización automática asociada a
estos scripts.
