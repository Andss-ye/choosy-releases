#!/bin/sh
# Installs the latest Choosy in /Applications (or ~/Applications if /Applications isn't writable).
# Downloads with curl, which doesn't mark the file as quarantined: macOS doesn't treat it as a browser
# download and skips the "Apple could not verify…" warning shown for apps that aren't notarized.
# CHOOSY_DEST changes the destination and CHOOSY_NO_OPEN=1 skips opening the app (tests).
set -eu

[ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = 1 ] || { echo "Choosy only runs on Apple Silicon Macs." >&2; exit 1; }

TMP=$(mktemp -d)
MNT=$TMP/mnt
cleanup() {
  hdiutil detach -quiet "$MNT" 2>/dev/null || true
  rm -rf "$TMP"
  [ -z "${DEST:-}" ] || rm -rf "$DEST/.Choosy.app.new"
}
trap cleanup EXIT
trap 'exit 1' INT TERM

echo "Downloading Choosy…"
curl -fL --progress-bar -o "$TMP/Choosy.dmg" "${CHOOSY_DMG_URL:-https://github.com/Andss-ye/choosy-releases/releases/latest/download/Choosy.dmg}"
mkdir "$MNT"
hdiutil attach -quiet -nobrowse -readonly -mountpoint "$MNT" "$TMP/Choosy.dmg" </dev/null

min=$(/usr/libexec/PlistBuddy -c "Print :LSMinimumSystemVersion" "$MNT/Choosy.app/Contents/Info.plist")
if [ "$(printf '%s\n%s\n' "$min" "$(sw_vers -productVersion)" | sort -V | head -n 1)" != "$min" ]; then
  echo "Choosy needs macOS $min or later." >&2
  exit 1
fi

DEST=${CHOOSY_DEST:-/Applications}
if [ ! -w "$DEST" ]; then
  DEST=$HOME/Applications
  mkdir -p "$DEST"
fi

# The new copy is ready before the old one goes away.
ditto "$MNT/Choosy.app" "$DEST/.Choosy.app.new"
xattr -dr com.apple.quarantine "$DEST/.Choosy.app.new" 2>/dev/null || true
pkill -f "^$DEST/Choosy.app/Contents/MacOS/Choosy" 2>/dev/null || true
rm -rf "$DEST/Choosy.app"
mv "$DEST/.Choosy.app.new" "$DEST/Choosy.app"
echo "Choosy installed in $DEST"
echo "Optional command line: ln -sf \"$DEST/Choosy.app/Contents/MacOS/Choosy\" /usr/local/bin/choosy"
[ "${CHOOSY_NO_OPEN:-}" = 1 ] || open "$DEST/Choosy.app"
