#!/usr/bin/env bash
# Render printable parts. Requires OpenSCAD (tested with 2026.11 nightly).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
SCAD="${SCAD:-openscad}"
mkdir -p stl
packages=(
  "levers=lever"
  "handles=handle_left"
  "handles=handle_right"
  "shoe=tracker_shoe"
  "collar=shaft_collar"
  "cradle=scope_cradle"
)
for pair in "${packages[@]}"; do
  group="${pair%%=*}"; part="${pair##*=}"
  out="stl/${group}__${part}.stl"
  printf '  %-28s -> %s\n' "$part" "$out"
  "$SCAD" --export-format binstl -o "$out" -D "part=\"$part\"" bronchoscope_prop.scad 2>/dev/null
done
echo "done: $(ls -1 stl/*.stl | wc -l) parts in $(pwd)/stl"
