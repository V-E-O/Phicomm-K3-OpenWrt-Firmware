#!/usr/bin/env bash
set -euo pipefail

# Hostname
if [[ -n "${MODIFY_HOSTNAME:-}" ]]; then
  echo '>>> Update Hostname >>>'
  sed -i "s/hostname='OpenWrt'/hostname='${MODIFY_HOSTNAME}'/g" \
    package/base-files/files/bin/config_generate
  echo '<<< Completed Update Hostname <<<'
fi

# Override bcm53xx target CPU_TYPE to enable NEON + hard-float
# make defconfig reads CPU_TYPE from target/linux/bcm53xx/Makefile
# and forces soft-float. Patch it at source so defconfig picks up +neon.
echo '>>> Patch bcm53xx target for NEON + hard-float >>>'
sed -i 's/CPU_TYPE:=cortex-a9$/CPU_TYPE:=cortex-a9+neon/' target/linux/bcm53xx/Makefile
sed -i '/^FEATURES:=/ s/$/ fpu neon/' target/linux/bcm53xx/Makefile
grep -E 'CPU_TYPE|FEATURES' target/linux/bcm53xx/Makefile
echo '<<< Completed Patch bcm53xx target <<<'

# Kernel: Enable VFP/NEON + ARM NEON crypto acceleration
# BCM4709A0 Cortex-A9 has NEON hardware, but all upstream bcm53xx
# targets (OpenWrt/immortalwrt/LEDE) leave it disabled.
echo '>>> Enable VFP/NEON + Crypto in Kernel >>>'
for cfg in target/linux/bcm53xx/config-*; do
  # Remove existing entries to avoid conflicts
  sed -i '/CONFIG_VFP/d' "$cfg"
  sed -i '/CONFIG_NEON/d' "$cfg"
  sed -i '/CONFIG_KERNEL_MODE_NEON/d' "$cfg"
  sed -i '/CONFIG_CRYPTO_AES_ARM/d' "$cfg"
  sed -i '/CONFIG_CRYPTO_SHA1_ARM/d' "$cfg"
  sed -i '/CONFIG_CRYPTO_SHA256_ARM/d' "$cfg"
  sed -i '/CONFIG_CRYPTO_SHA512_ARM/d' "$cfg"
  sed -i '/CONFIG_CRYPTO_CHACHA20_NEON/d' "$cfg"
  sed -i '/CONFIG_CRYPTO_POLY1305_ARM/d' "$cfg"
  sed -i '/CONFIG_CRYPTO_POLY1305_NEON/d' "$cfg"
  sed -i '/CONFIG_CRYPTO_BLAKE2S_ARM/d' "$cfg"
  sed -i '/CONFIG_CRYPTO_NHPOLY1305_NEON/d' "$cfg"
  sed -i '/CONFIG_CRYPTO_CURVE25519_NEON/d' "$cfg"

  # VFP/NEON core
  echo 'CONFIG_VFP=y' >> "$cfg"
  echo 'CONFIG_NEON=y' >> "$cfg"
  echo 'CONFIG_KERNEL_MODE_NEON=y' >> "$cfg"

  # AES: ARM scalar assembly + NEON bitsliced (bsaes-armv7)
  echo 'CONFIG_CRYPTO_AES_ARM=y' >> "$cfg"
  echo 'CONFIG_CRYPTO_AES_ARM_BS=y' >> "$cfg"

  # SHA: ARM assembly + NEON
  echo 'CONFIG_CRYPTO_SHA1_ARM=y' >> "$cfg"
  echo 'CONFIG_CRYPTO_SHA1_ARM_NEON=y' >> "$cfg"
  echo 'CONFIG_CRYPTO_SHA256_ARM=y' >> "$cfg"
  echo 'CONFIG_CRYPTO_SHA512_ARM=y' >> "$cfg"

  # ChaCha20-Poly1305 NEON (SSH, WireGuard)
  echo 'CONFIG_CRYPTO_CHACHA20_NEON=y' >> "$cfg"
  echo 'CONFIG_CRYPTO_POLY1305_ARM=y' >> "$cfg"
  echo 'CONFIG_CRYPTO_POLY1305_NEON=y' >> "$cfg"

  # Other NEON accelerated
  echo 'CONFIG_CRYPTO_BLAKE2S_ARM=y' >> "$cfg"
  echo 'CONFIG_CRYPTO_CURVE25519_NEON=y' >> "$cfg"
  echo 'CONFIG_CRYPTO_NHPOLY1305_NEON=y' >> "$cfg"
done
echo '<<< Completed Enable VFP/NEON + Crypto <<<'
