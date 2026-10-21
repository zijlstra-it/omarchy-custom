#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "       Omarchy: Installing Plugins                 "
echo "===================================================="

omarchy plugin add https://github.com/kris-1/omarchy-monitor-layout.git --yes
omarchy plugin enable monitor-layout --section right
omarchy plugin add https://github.com/ParvvOK/equalizer.git --yes
omarchy plugin enable equalizer --section right
omarchy plugin add https://github.com/BibekBhusal0/omarchy-better-lock.git --yes
omarchy plugin add https://github.com/PixDevsApps/omarchy-hertz-radio.git --yes
omarchy plugin enable hertz-radio --section right
omarchy plugin add https://github.com/zijlstra-it/omarchy-spotify-player --yes
omarchy plugin enable omarchy-spotify-player --right

echo "===================================================="
echo "        ✅ Plugins installed successfully!        "
echo "===================================================="
