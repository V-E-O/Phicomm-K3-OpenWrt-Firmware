# Phicomm K3 OpenWrt Firmware

Phicomm K3 (BCM47094) firmware built with official OpenWrt 25.12, compiled via GitHub Actions.

## Overview

| Item | Detail |
|------|--------|
| Target | bcm53xx / Phicomm K3 |
| Kernel | 6.12 (ARM Cortex-A9 + NEON) |
| Firewall | nftables (fw4) |
| Upstream | [openwrt/openwrt](https://github.com/openwrt/openwrt) branch `openwrt-25.12` |

## Features

- **Passwall** transparent proxy (Xray, Hysteria, Haproxy) with nftables
- **BBR + FQ** as default congestion control and qdisc
- **DDNS** (Aliyun, DNSPod)
- **UPnP**
- **mwan3** multi-WAN load balancing
- **WiFi Schedule**
- **K3 LCD screen** control
- **Argon** theme

## Performance Optimizations

- `-O2` compiler optimization (instead of `-Os`)
- `-falign-functions=32` for cache line alignment on Cortex-A9
- NEON/VFP enabled (hardware AES acceleration)
- BBR congestion control + FQ qdisc as kernel default

## Usage Tips

### WiFi Transmit Power

LuCI → Network → Wireless → Edit → Advanced Settings → Transmit Power

Or via startup script (System → Startup → Local Startup Script, before `exit 0`):
```shell
iwconfig wlan0 txpower 23
iwconfig wlan1 txpower 23
```
`wlan0` = 2.4G, `wlan1` = 5G. Range: 23-27 recommended (max 31).

### Network Acceleration

BBR + FQ is enabled by default at kernel level (no manual config needed).

For flow offload: LuCI → Network → Firewall → General Settings → enable "Software flow offloading".

### Default Access

- Address: `192.168.1.1`
- User: `root`
- Password: `password` (change after first login)

## Build

Trigger manually via GitHub Actions (workflow_dispatch), or fork and push.

WiFi firmware uses the [69027 version](https://github.com/yangxu52/Phicomm-k3-Wireless-Firmware).

## Credits

- [OpenWrt](https://github.com/openwrt/openwrt)
- [xiaorouji/openwrt-passwall](https://github.com/xiaorouji/openwrt-passwall)
- [jerrykuku/luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon)
- [yangxu52](https://github.com/yangxu52) (K3 screen, WiFi firmware)
