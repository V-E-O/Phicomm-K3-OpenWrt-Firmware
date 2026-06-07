#!/usr/bin/env bash
set -euo pipefail

# Hostname
if [[ -n "${MODIFY_HOSTNAME:-}" ]]; then
  echo '>>> Update Hostname >>>'
  sed -i "s/hostname='OpenWrt'/hostname='${MODIFY_HOSTNAME}'/g" \
    package/base-files/files/bin/config_generate
  echo '<<< Completed Update Hostname <<<'
fi
