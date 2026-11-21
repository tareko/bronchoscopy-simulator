#!/usr/bin/env bash
# Render the demo video from the simulator itself (no screen recording).
#
#   ./tools/render_demo.sh              # 1920x1080, 34 s
#   FRAMES=300 W=1280 H=720 ./tools/render_demo.sh   # quick preview
#
# Requires Godot 4.7+ and ffmpeg. Frames are written to video/frames (ignored by
# git) and the encoded result to media/.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

GODOT_BIN="${GODOT_BIN:-godot}"
W="${W:-1920}"
H="${H:-1080}"
FRAMES="${FRAMES:-1020}"
FPS=30
OUT="media/bronchoscopy-simulator-demo.mp4"

mkdir -p video media
rm -rf video/frames
mkdir -p video/frames

echo "rendering $FRAMES frames at ${W}x${H} ..."
DEMO_W="$W" DEMO_H="$H" DEMO_FRAMES="$FRAMES" DEMO_OUT="res://video/frames" \
  "$GODOT_BIN" --path . res://src/demo/demo.tscn

duration=$(awk "BEGIN { printf \"%.2f\", $FRAMES / $FPS }")
fade_out=$(awk "BEGIN { printf \"%.2f\", $duration - 1.2 }")

echo "encoding ${duration}s at ${FPS}fps ..."
ffmpeg -y -loglevel error -framerate "$FPS" -i video/frames/%05d.png \
  -vf "fade=t=in:st=0:d=0.6,fade=t=out:st=${fade_out}:d=1.2,format=yuv420p" \
  -c:v libx264 -preset medium -crf 18 -movflags +faststart "$OUT"

# poster frame for the README
ffmpeg -y -loglevel error -ss 12 -i "$OUT" -frames:v 1 media/poster.png

echo "wrote $OUT ($(du -h "$OUT" | cut -f1)) and media/poster.png"
