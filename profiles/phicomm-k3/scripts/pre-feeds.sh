#!/usr/bin/env bash
set -euo pipefail

clone_repo() {
  local repo_url="$1" branch="$2" dst="$3"
  rm -rf "$dst"
  if [[ -n "$branch" ]]; then
    git clone -b "$branch" --single-branch --depth 1 "$repo_url" "$dst"
  else
    git clone --depth 1 "$repo_url" "$dst"
  fi
}

append_feed_if_missing() {
  local line="$1"
  grep -qxF "$line" feeds.conf.default || echo "$line" >> feeds.conf.default
}

echo '>>> Add Passwall Feed >>>'
append_feed_if_missing 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages;main'
echo '<<< Completed Add Passwall Feed <<<'

echo '>>> Clone Passwall LuCI App >>>'
clone_repo 'https://github.com/xiaorouji/openwrt-passwall' 'main' 'package/luci-app-passwall'
echo '<<< Completed Clone Passwall LuCI App <<<'

echo '>>> Clone K3 Screen App >>>'
clone_repo 'https://github.com/yangxu52/luci-app-k3screenctrl.git' '' 'package/k3screenctrl-luci'
echo '<<< Completed Clone K3 Screen App <<<'

echo '>>> Clone K3 Screen Driver >>>'
clone_repo 'https://github.com/yangxu52/k3screenctrl_build.git' '' 'package/k3screenctrl'
echo '<<< Completed Clone K3 Screen Driver <<<'

echo '>>> Clone Argon Theme >>>'
clone_repo 'https://github.com/jerrykuku/luci-theme-argon' 'master' 'package/luci-theme-argon'
clone_repo 'https://github.com/jerrykuku/luci-app-argon-config' 'master' 'package/luci-app-argon-config'
echo '<<< Completed Clone Argon Theme <<<'

echo '>>> Replace WiFi Firmware (69027) >>>'
FIRMWARE_PATH='package/firmware/brcmfmac-firmware-4366c-pcie/files/lib/firmware/brcm/brcmfmac4366c-pcie.bin'
mkdir -p "$(dirname "$FIRMWARE_PATH")"
wget -nv 'https://github.com/yangxu52/Phicomm-k3-Wireless-Firmware/raw/master/brcmfmac4366c-pcie.bin.69027' -O "$FIRMWARE_PATH"
echo '<<< Completed Replace WiFi Firmware <<<'
