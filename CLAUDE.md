# choosy-releases

Repo **público** de descargas de Choosy. El código vive en `Andss-ye/choosy` (privado); su `docs/releases.md` explica el pipeline.

## Qué hay aquí

- `README.md`: página para usuarios, en inglés. Las capturas de `assets/` salen de `Choosy --home <demo> --snapshot` en el repo privado.
- `install.sh`: instala la última versión con curl (sin cuarentena). `CHOOSY_DEST`, `CHOOSY_NO_OPEN=1` y `CHOOSY_DMG_URL` sirven para probarlo sin tocar `/Applications`.
- `.github/ISSUE_TEMPLATE/`: bug e idea; los issues de usuarios llegan aquí.
- Releases: `Choosy.dmg` y `appcast.xml`. **Las publica el workflow `release.yml` del repo privado**; nunca se suben a mano.

## Reglas

- Nunca código fuente ni enlaces al repo privado (los usuarios no pueden verlo).
- `releases/latest/download/appcast.xml` es la URL que leen todas las apps instaladas (`SUFeedURL`): no renombrar el asset ni borrar releases viejas.
- Los cambios de README e `install.sh` se prueban antes: `CHOOSY_DEST=$(mktemp -d) CHOOSY_NO_OPEN=1 sh install.sh`.
- Al salir la primera release, quitar el aviso «The first public release is on its way» del README.
