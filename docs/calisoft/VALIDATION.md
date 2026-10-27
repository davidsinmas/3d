# Comprobaciones Git — 27 de octubre de 2026

Comprobaciones ejecutadas:

- Sintaxis Bash correcta en los cinco scripts y JSON válido en la configuración
  alternativa de Codespaces.
- `setup-upstream.sh` detectó `main`, configuró origin/upstream, bloqueó el push
  local a upstream y descargó `upstream/main` correctamente.
- `check-upstream.sh` detectó que los historiales eran independientes y mostró el
  commit original disponible `7a6c884418698e9c9fb0e6f97b9b847998c58c49`.
- La primera integración se ensayó en un clon temporal mediante
  `update-upstream.sh` y `finish-upstream.sh`. El commit resultante tuvo dos padres:
  el historial de Calisoft y el commit original indicado.
- El ensayo terminó con árbol limpio, licencias y atribuciones presentes, y cero
  archivos bajo `.github/workflows` en el árbol final.
- La rama main real no se modificó durante ese ensayo. No se compiló ni publicó.

Limitación: el terminal de esta sesión no tiene credenciales Git para hacer push.
Los scripts y documentación se guardan mediante la conexión oficial de GitHub.
La importación inicial del código e historial completo se deja para una rama
revisable ejecutada desde un Codespace autenticado; main no se sobrescribe.
