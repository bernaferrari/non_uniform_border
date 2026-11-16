#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

rm -rf build/readme_frames
flutter test tool/render_readme_assets.dart

encode_lossless() {
  local name="$1"
  local scaled="build/readme_frames/${name}_960"
  mkdir -p "$scaled"
  ffmpeg -y -loglevel error -i "build/readme_frames/${name}/frame_%04d.png" -vf "scale=960:-1:flags=lanczos" "$scaled/frame_%04d.png"
  img2webp -min_size -loop 0 -d 40 -lossless -q 75 -m 4 "$scaled"/frame_*.png -o "assets/${name}.webp"
}

encode_lossless showcase
encode_lossless example

rm -rf build/readme_frames
ls -lh assets/NonUniformBorder.png assets/showcase.webp assets/example.webp
