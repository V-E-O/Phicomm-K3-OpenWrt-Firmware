#!/usr/bin/env bash
set -euo pipefail

# Hostname
if [[ -n "${MODIFY_HOSTNAME:-}" ]]; then
  echo '>>> Update Hostname >>>'
  sed -i "s/hostname='OpenWrt'/hostname='${MODIFY_HOSTNAME}'/g" \
    package/base-files/files/bin/config_generate
  echo '<<< Completed Update Hostname <<<'
fi

# Kernel: Enable VFP/NEON (BCM4709A0 Cortex-A9 has NEON hardware,
# but all OpenWrt/immortalwrt/LEDE bcm53xx targets leave it disabled)
echo '>>> Enable VFP/NEON in Kernel >>>'
for cfg in target/linux/bcm53xx/config-*; do
  sed -i '/CONFIG_VFP/d' "$cfg"
  sed -i '/CONFIG_NEON/d' "$cfg"
  sed -i '/CONFIG_KERNEL_MODE_NEON/d' "$cfg"
  echo 'CONFIG_VFP=y' >> "$cfg"
  echo 'CONFIG_NEON=y' >> "$cfg"
  echo 'CONFIG_KERNEL_MODE_NEON=y' >> "$cfg"
done
echo '<<< Completed Enable VFP/NEON <<<'
