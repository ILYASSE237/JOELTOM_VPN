#!/bin/bash
# ==========================================================
# JOELTOM VPS — COMPTES PAR PROTOCOLE
# ==========================================================
BASE="/etc/movivip"
CONFIG="$BASE/config.conf"
[[ -f "$CONFIG" ]] && source "$CONFIG"
[[ -f "$BASE/lib/ui.sh" ]] && source "$BASE/lib/ui.sh"
[[ -f "$BASE/lib/nav.sh" ]] && source "$BASE/lib/nav.sh"

GREEN="\e[1;92m"; RED="\e[1;91m"; GOLD="\e[1;93m"; CYAN="\e[1;96m"; WHITE="\e[1;97m"; RESET="\e[0m"

while true; do
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${GOLD}                 JOELTOM — COMPTES VPN                   ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    SEL=$(nav_pick "► Choisir le type de compte :"         "👤 Compte SSH"         "🚀 Compte V2Ray / Xray"         "🔐 Compte ZiVPN"         "🌐 Compte WebSocket / SSH"         "🐢 Informations SlowDNS"         "📋 Lister les comptes V2Ray"         "📋 Lister les comptes ZiVPN"         "🗑 Supprimer un compte SSH"         "↩ Retour") || SEL=9

    case "$SEL" in
        1)
            bash "$BASE/usuarios/add.sh"
            ;;
        2)
            bash "$BASE/usuarios/v2ray_add.sh"
            ;;
        3)
            bash "$BASE/usuarios/zivpn_add.sh"
            ;;
        4)
            bash "$BASE/usuarios/websocket_add.sh"
            ;;
        5)
            bash "$BASE/usuarios/slowdns_info.sh"
            ;;
        6)
            bash "$BASE/usuarios/v2ray_list.sh"
            ;;
        7)
            bash "$BASE/usuarios/zivpn_list.sh"
            ;;
        8)
            bash "$BASE/usuarios/delete.sh"
            ;;
        9|0)
            exec bash "$BASE/menu.sh"
            ;;
    esac
done
