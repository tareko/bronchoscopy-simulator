#!/usr/bin/env bash
# Launch the bronchoscopy simulator.
#
#   ./scripts/run.sh            # desktop mode (no headset needed)
#   ./scripts/run.sh --vr       # force OpenXR on (HTC Vive / any OpenXR HMD)
#   ./scripts/run.sh --editor   # open the project in the Godot editor
#
# Set GODOT_BIN if the engine is not on PATH, e.g.
#   GODOT_BIN=/opt/godot/Godot_v4.7.2-stable_linux.x86_64 ./scripts/run.sh --vr
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(dirname "$here")"
GODOT_BIN="${GODOT_BIN:-godot}"

args=()
mode="run"
for arg in "$@"; do
  case "$arg" in
    --vr) args+=(--xr-mode on) ;;
    --no-vr) args+=(--xr-mode off) ;;
    --editor|-e) mode="editor" ;;
    *) args+=("$arg") ;;
  esac
done

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  echo "error: '$GODOT_BIN' not found. Install Godot 4.7+ or set GODOT_BIN." >&2
  exit 1
fi

if [[ "$mode" == "editor" ]]; then
  exec "$GODOT_BIN" --editor --path "$project_root" "${args[@]}"
fi
exec "$GODOT_BIN" --path "$project_root" "${args[@]}"
