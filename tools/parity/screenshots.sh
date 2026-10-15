#!/bin/bash
# Captures the README's images and pub.dev's screenshots on the parity
# simulator, with both apps installed (see README.md), and writes them to
# docs/demo/ and screenshots/.
#
#   ./screenshots.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
source "$here/parity.env"
out="$PARITY_OUT/readme"
mkdir -p "$out"

xcrun simctl status_bar "$PARITY_UDID" override --time 9:41 \
  --batteryState discharging --batteryLevel 100 --wifiBars 3 --cellularBars 4
trap 'xcrun simctl status_bar "$PARITY_UDID" clear' EXIT

for page in place player settings styles; do
  SIMCTL_CHILD_VIB_PERF_OFF=0 PARITY_SETTLE=6 "$here/capture.sh" flutter "$page" x x light "$out/$page-on.png"
  SIMCTL_CHILD_VIB_PERF_OFF=1 PARITY_SETTLE=6 "$here/capture.sh" flutter "$page" x x light "$out/$page-off.png"
done
PARITY_SETTLE=6 "$here/capture.sh" flutter card regular x light "$out/card-flutter.png"
"$here/capture.sh" native card regular x light "$out/card-native.png"

# The styles page scrolls itself two seconds after launch, for six seconds.
SIMCTL_CHILD_VIB_SCENE=scroll xcrun simctl launch --terminate-running-process \
  "$PARITY_UDID" "$FLUTTER_BUNDLE" >/dev/null
xcrun simctl io "$PARITY_UDID" recordVideo --codec=h264 --force "$out/scroll.mov" >/dev/null 2>&1 &
recorder=$!
sleep 11
kill -INT "$recorder"
wait "$recorder" || true
ffmpeg -v error -y -ss 2.3 -t 6.4 -i "$out/scroll.mov" -vf \
  "fps=20,scale=300:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4" \
  "$out/scroll.gif"

python3 "$here/readme_images.py" "$out" "$root"
