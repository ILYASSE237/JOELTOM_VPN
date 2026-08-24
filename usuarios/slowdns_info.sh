#!/bin/bash
BASE="/etc/movivip"
CONFIG="$BASE/config.conf"
[[ -f "$CONFIG" ]] && source "$CONFIG"
PUB="/etc/slowdns/server.pub"
clear
echo "=== JOELTOM — INFORMATIONS SLOWDNS ==="
echo ""
if systemctl is-active --quiet slowdns 2>/dev/null && [[ -f "$PUB" ]]; then
    DOMAIN="${SERVER_DOMAIN:-$(hostname -f 2>/dev/null || hostname)}"
    echo "Serveur : $DOMAIN"
    echo "Port DNS : ${DNS_PORT:-53}"
    echo "Port tunnel : ${SLOWDNS_PORT:-5300}"
    echo "Clé publique client :"
    cat "$PUB"
    echo ""
    echo "Note : SlowDNS utilise une clé serveur commune dans ce projet."
    echo "Il n'y a pas de compte utilisateur séparé côté serveur."
else
    echo "SlowDNS n'est pas installé ou n'est pas actif."
fi
echo ""
read -r -p "Entrée..."
