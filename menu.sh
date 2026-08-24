#!/bin/bash
# ==========================================================
# JOELTOM VPS — PANNEAU PRINCIPAL
# ==========================================================

BASE="/etc/movivip"
CONFIG="$BASE/config.conf"
[[ -f "$CONFIG" ]] && source "$CONFIG"

[[ -f "$BASE/lib/ui.sh" ]] && source "$BASE/lib/ui.sh"
[[ -f "$BASE/lib/nav.sh" ]] && source "$BASE/lib/nav.sh"
[[ -f "$BASE/languages/lang.sh" ]] && source "$BASE/languages/lang.sh"
[[ -f "$BASE/languages/protocols.sh" ]] && source "$BASE/languages/protocols.sh"

if declare -F load_language >/dev/null 2>&1; then
    load_language "$(get_current_language 2>/dev/null || echo fr)"
fi

RESET="\e[0m"; RED="\e[1;91m"; GREEN="\e[1;92m"; GOLD="\e[1;93m"
CYAN="\e[1;96m"; BLUE="\e[1;94m"; WHITE="\e[1;97m"; GRAY="\e[1;90m"

svc_on() {
    local s="$1"
    systemctl is-active --quiet "$s" 2>/dev/null
}

dot() {
    if [[ "$1" == "1" ]]; then echo -e "${GREEN}●${RESET}"; else echo -e "${RED}●${RESET}"; fi
}

service_flag() {
    local a=0
    for s in "$@"; do
        if svc_on "$s"; then a=1; break; fi
    done
    echo "$a"
}

get_ip() {
    local ip
    ip=$(curl -4 -fsS --max-time 3 https://api.ipify.org 2>/dev/null || true)
    [[ -z "$ip" ]] && ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    echo "${ip:--}"
}

get_domain() {
    echo "${SERVER_DOMAIN:--}"
}

cpu_usage() {
    awk -F'id,' '/Cpu/ {gsub(",",".",$1); split($1,a," "); printf "%.1f%%",100-a[length(a)]}' < <(top -bn1 2>/dev/null | head -n1)
}

ram_info() {
    free -m 2>/dev/null | awk '/Mem:/ {printf "%dM/%dM",$3,$2}'
}

ram_bar() {
    free 2>/dev/null | awk '/Mem:/ {p=$3/$2*100; n=int(p/10); printf "%d",$3/$2*100}'
}

disk_info() {
    df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2}'
}

disk_pct() {
    df -P / 2>/dev/null | awk 'NR==2 {gsub("%","",$5); print $5}'
}

bar() {
    local pct="${1:-0}" width=10 filled empty
    [[ "$pct" =~ ^[0-9]+$ ]] || pct=0
    (( pct > 100 )) && pct=100
    filled=$((pct*width/100)); empty=$((width-filled))
    printf "["
    printf '█%.0s' $(seq 1 "$filled" 2>/dev/null)
    printf '░%.0s' $(seq 1 "$empty" 2>/dev/null)
    printf "]"
}

show_panel() {
    local IP DOMAIN UPTIME CPU RAM DISK RP DP
    IP="$(get_ip)"
    DOMAIN="$(get_domain)"
    UPTIME="$(uptime -p 2>/dev/null | sed 's/^up //')"
    CPU="$(cpu_usage)"
    RAM="$(ram_info)"
    DISK="$(disk_info)"
    RP="$(ram_bar)"
    DP="$(disk_pct)"

    local SSH TLS WS UDP SDNS XRAY ZI DROP BAD BBR
    SSH=$(service_flag ssh sshd)
    TLS=$(service_flag haproxy stunnel4)
    WS=$(service_flag ssh-ws-internal ssh-ws ssh-wss)
    UDP=$(service_flag udp-custom)
    SDNS=$(service_flag slowdns)
    XRAY=$(service_flag xray)
    ZI=$(service_flag zivpn)
    DROP=$(service_flag dropbear dropbear_custom)
    BAD=$(service_flag badvpn-udpgw-7200 badvpn-udpgw-7300 badvpn-udpgw)
    BBR=0
    [[ "$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)" == "bbr" ]] && BBR=1

    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${GOLD}                         JOELTOM VPS                         ${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
    echo -e "${MAGENTA:-$CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "${BLUE}OS${RESET}       ${GREEN}%-24s${RESET} ${BLUE}CPU${RESET}     ${GREEN}%-8s${RESET}\n" "$( . /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-Linux}" )" "$CPU"
    printf "${BLUE}Uptime${RESET}   ${GREEN}%-24s${RESET} ${BLUE}RAM${RESET}     ${GREEN}%-8s${RESET} ${GREEN}%s${RESET}\n" "$UPTIME" "$RAM" "$(bar "${RP%.*}")"
    printf "${BLUE}IP${RESET}       ${GREEN}%-24s${RESET} ${BLUE}Disque${RESET}  ${GREEN}%-8s${RESET} ${GREEN}%s${RESET}\n" "$IP" "$DISK" "$(bar "$DP")"
    printf "${BLUE}Domaine${RESET}  ${GREEN}%-24s${RESET}\n" "$DOMAIN"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GOLD}⭐${RESET} ${WHITE}Développeur : JOEL TOM${RESET} ${GRAY}|${RESET} ${WHITE}Version : 1.0.0${RESET}"
    echo -e "${WHITE}👥 Utilisateurs SSH : ${GREEN}$(awk -F: '$3>=1000 && $1!="nobody"{n++} END{print n+0}' /etc/passwd 2>/dev/null)${RESET} ${GRAY}|${RESET} ${WHITE}Connexions : ${GREEN}$(ss -Htan 2>/dev/null | tail -n +1 | wc -l | tr -d ' ')${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "%b SSH:${RESET} %b ON   " "$(dot "$SSH")" ""
    printf " | TLS: %b %s   " "$(dot "$TLS")" "$([[ $TLS == 1 ]] && echo ON || echo OFF)"
    printf " | WS: %b %s\n" "$(dot "$WS")" "$([[ $WS == 1 ]] && echo ON || echo OFF)"
    printf "Dropbear: %b %s | ZiVPN: %b %s | V2Ray: %b %s\n" "$(dot "$DROP")" "$([[ $DROP == 1 ]] && echo ON || echo OFF)" "$(dot "$ZI")" "$([[ $ZI == 1 ]] && echo ON || echo OFF)" "$(dot "$XRAY")" "$([[ $XRAY == 1 ]] && echo ON || echo OFF)"
    printf "UDP: %b %s | SlowDNS: %b %s | BadVPN: %b %s | BBR: %b %s\n" "$(dot "$UDP")" "$([[ $UDP == 1 ]] && echo ON || echo OFF)" "$(dot "$SDNS")" "$([[ $SDNS == 1 ]] && echo ON || echo OFF)" "$(dot "$BAD")" "$([[ $BAD == 1 ]] && echo ON || echo OFF)" "$(dot "$BBR")" "$([[ $BBR == 1 ]] && echo ON || echo OFF)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

auto_panel() {
    local file="/etc/profile.d/joeltom-vps.sh"
    if [[ "${AUTO_START:-OFF}" == "ON" ]]; then
        sed -i 's/^AUTO_START=.*/AUTO_START=OFF/' "$CONFIG" 2>/dev/null
        rm -f "$file"
        echo -e "${GOLD}⚠ Auto-Panel désactivé.${RESET}"
    else
        if grep -q '^AUTO_START=' "$CONFIG" 2>/dev/null; then
            sed -i 's/^AUTO_START=.*/AUTO_START=ON/' "$CONFIG"
        else
            echo 'AUTO_START=ON' >> "$CONFIG"
        fi
        cat > "$file" <<'EOF'
#!/bin/bash
if [[ $- == *i* ]] && command -v menu >/dev/null 2>&1; then
    menu
fi
EOF
        chmod +x "$file"
        echo -e "${GREEN}✔ Auto-Panel activé.${RESET}"
    fi
    sleep 1
}

uninstall() {
    clear
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${RED}║                  DÉSINSTALLATION JOELTOM VPS              ║${RESET}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    read -rp "Supprimer le panneau et ses fichiers ? [o/N] : " ans
    [[ "${ans,,}" != "o" && "${ans,,}" != "oui" ]] && return
    systemctl disable --now xray zivpn slowdns udp-custom ssh-ws-internal ssh-ws ssh-wss dropbear_custom 2>/dev/null || true
    rm -f /usr/local/bin/menu /etc/profile.d/joeltom-vps.sh
    rm -rf "$BASE"
    echo -e "${GREEN}✔ Panneau JOELTOM VPS supprimé.${RESET}"
    exit 0
}

while true; do
    show_panel
    SEL=$(nav_pick "► MENU PRINCIPAL :"         "👤 SSH / VPN"         "🚀 Xray / V2Ray"         "🔐 ZiVPN"         "📊 Monitor"         "🌐 Domaine"         "📦 Protocoles"         "🎨 Banners"         "🔄 Auto-Panel: [${AUTO_START:-OFF}]"         "🛠 Mise à jour"         "🗑 Désinstaller"         "✕ Quitter") || SEL=11

    case "$SEL" in
        1) bash "$BASE/usuarios/protocolos.sh" ;;
        2) FROM_MAIN=1 bash "$BASE/protocolos/v2ray.sh" ;;
        3) FROM_MAIN=1 bash "$BASE/protocolos/zipvpn.sh" ;;
        4) bash "$BASE/herramientas/network_traffic.sh" ;;
        5) bash "$BASE/herramientas/change-domain.sh" ;;
        6) bash "$BASE/protocolos/menu.sh" ;;
        7) bash "$BASE/usuarios/banner.sh" ;;
        8) auto_panel ;;
        9) bash "$BASE/update.sh" ;;
        10) uninstall ;;
        11|0) clear; exit 0 ;;
        *) sleep 1 ;;
    esac
done
