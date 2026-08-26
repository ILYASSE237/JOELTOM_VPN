#!/bin/bash
# ============================================================
#   JOELTOM VPN — Installateur OpenVPN
#   Basé sur le script communautaire éprouvé angristan/openvpn-install
# ============================================================
set -e
mkdir -p /etc/joeltom/tools
curl -fsSL -o /etc/joeltom/tools/openvpn-install.sh \
  https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x /etc/joeltom/tools/openvpn-install.sh
AUTO_INSTALL=y bash /etc/joeltom/tools/openvpn-install.sh
echo "[INFO] OpenVPN installé. Gérez les clients via le menu 'openvpn'."
