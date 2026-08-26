#!/bin/bash
# ============================================================
#   JOELTOM VPN — Installateur WireGuard
#   Basé sur le script communautaire éprouvé angristan/wireguard-install
# ============================================================
set -e
mkdir -p /etc/joeltom/tools
curl -fsSL -o /etc/joeltom/tools/wireguard-install.sh \
  https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x /etc/joeltom/tools/wireguard-install.sh
AUTO_INSTALL=y bash /etc/joeltom/tools/wireguard-install.sh
echo "[INFO] WireGuard installé. Gérez les clients via le menu 'wireguard'."
