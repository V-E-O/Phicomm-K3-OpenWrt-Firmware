#!/usr/bin/env bash
set -euo pipefail

# Hostname
if [[ -n "${MODIFY_HOSTNAME:-}" ]]; then
  echo '>>> Update Hostname >>>'
  sed -i "s/hostname='OpenWrt'/hostname='${MODIFY_HOSTNAME}'/g" \
    package/base-files/files/bin/config_generate
  echo '<<< Completed Update Hostname <<<'
fi

# Kernel: BBR as default congestion control + FQ as default qdisc
echo '>>> Configure Kernel Performance >>>'
for cfg in target/linux/bcm53xx/config-*; do
  grep -q 'CONFIG_TCP_CONG_BBR' "$cfg" || echo 'CONFIG_TCP_CONG_BBR=y' >> "$cfg"
  grep -q 'CONFIG_DEFAULT_TCP_CONG' "$cfg" || echo 'CONFIG_DEFAULT_TCP_CONG="bbr"' >> "$cfg"
  grep -q 'CONFIG_NET_SCH_FQ=y' "$cfg" || echo 'CONFIG_NET_SCH_FQ=y' >> "$cfg"
  grep -q 'CONFIG_DEFAULT_NET_SCH' "$cfg" || echo 'CONFIG_DEFAULT_NET_SCH="fq"' >> "$cfg"
done
echo '<<< Completed Configure Kernel Performance <<<'
