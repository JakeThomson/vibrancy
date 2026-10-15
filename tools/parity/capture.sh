#!/bin/bash
# Launches one app on one page and screenshots it once it has settled.
#
#   ./capture.sh <native|flutter> <scene> <material> <style> <light|dark> <out.png>
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
source "$here/parity.env"
app="$1" scene="$2" material="$3" style="$4" brightness="$5" out="$6"
bundle=$NATIVE_BUNDLE
[ "$app" = flutter ] && bundle=$FLUTTER_BUNDLE
dark=0
[ "$brightness" = dark ] && dark=1
xcrun simctl ui "$PARITY_UDID" appearance "$brightness" >/dev/null
SIMCTL_CHILD_VIB_SCENE="$scene" SIMCTL_CHILD_VIB_BLUR="$material" \
  SIMCTL_CHILD_VIB_STYLE="$style" SIMCTL_CHILD_VIB_DARK="$dark" \
  xcrun simctl launch --terminate-running-process "$PARITY_UDID" "$bundle" >/dev/null
sleep "${PARITY_SETTLE:-3}"
mkdir -p "$(dirname "$out")"
xcrun simctl io "$PARITY_UDID" screenshot "$out" >/dev/null 2>&1
echo "$out"
