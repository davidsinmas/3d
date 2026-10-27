# Auditoría — 27 de octubre de 2026

Estado observado en GitHub antes de esta intervención:

- Repositorio público `davidsinmas/3d`, rama principal main.
- Un único commit: `32afb0b85dd6b4bf08c81c834fc7b03eaa061b45`.
- Un único archivo versionado: README.md (4 bytes). Ningún código CAD, compilador,
  .devcontainer ni personalización de SolidCraft guardados todavía en GitHub.
- Historial independiente de SolidCraft; `git merge-base` no encuentra antepasado.
- Ningún archivo bajo .github/workflows y cero ejecuciones de Actions según API.
- El único blob histórico se revisó: no contiene credenciales. Esto no es una
  auditoría de servicios externos ni de secretos que puedan existir fuera de Git.
- No hay licencias de SolidCraft en main porque aún no se ha importado su código.

Original consultado: tangency-labs/solidcraft, rama main, versión declarada 0.24.1,
commit `7a6c884418698e9c9fb0e6f97b9b847998c58c49`. Licencia MIT OR Apache-2.0;
NOTICE y avisos de dependencias y fuentes presentes. Se conserva la atribución al
importarlos. Esta versión declarada no implica una release publicada ni validación
funcional del CAD.

La preparación anterior llegó a tener archivos locales y una compilación iniciada,
pero no quedó confirmada en main. El mantenimiento automático del entorno retiró
esos archivos locales. Esta intervención no presenta ese trabajo como importado,
compilado o publicado; tampoco reconstruye o sustituye un entorno de compilación
que no está disponible en el repositorio.

Se guarda ahora una conexión Git reproducible, scripts manuales y una configuración
alternativa de Codespaces solo para Git. El resultado de las comprobaciones figura
en VALIDATION.md. La integración inicial debe revisarse y guardarse con ambos
padres; main no se sobrescribe con el código original.
