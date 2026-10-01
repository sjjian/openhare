#!/usr/bin/env bash
# Build an unsigned, non-notarized DMG from the Flutter macOS release app.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="${APP_PATH:-$ROOT_DIR/client/build/macos/Build/Products/Release/openhare.app}"
VERSION="${1:-}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/dist}"

if [[ -z "$VERSION" ]]; then
  VERSION="$(sed -n 's/^version:[[:space:]]*\([0-9.]*\).*/\1/p' "$ROOT_DIR/client/pubspec.yaml" | head -n1)"
fi

if [[ -z "$VERSION" ]]; then
  echo "error: version not found in client/pubspec.yaml" >&2
  exit 1
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: app not found at $APP_PATH" >&2
  echo "run: flutter build macos --release" >&2
  exit 1
fi

DMG_NAME="openhare-macos-arm64-${VERSION}.dmg"
DMG_PATH="$OUTPUT_DIR/$DMG_NAME"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/openhare-dmg.XXXXXX")"

cleanup() {
  rm -rf "$STAGE"
}
trap cleanup EXIT

mkdir -p "$OUTPUT_DIR" "$STAGE"
cp -R "$APP_PATH" "$STAGE/openhare.app"
ln -s /Applications "$STAGE/Applications"

rm -f "$DMG_PATH"
hdiutil create \
  -volname "openhare" \
  -srcfolder "$STAGE" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "Created $DMG_PATH"
