#!/bin/bash
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/ui.sh" ]; then source "$SCRIPT_DIR/ui.sh"; fi
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'; WHITE='\033[0;37m'; BOLD='\033[1m'; NC='\033[0m'
ROOT_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)"
VERSION="$(cat /etc/joeltom/version 2>/dev/null || echo '2.0.0')"

pause(){ read -rp $'\n↩ Appuyez sur Entrée pour continuer...' _; }
run_menu(){ local f="$1"; shift; if [ -x "$SCRIPT_DIR/$f" ]; then bash "$SCRIPT_DIR/$f" "$@"; else echo -e "${RED}❌ Script introuvable: $f${NC}"; pause; fi; }
svc_exists(){ systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "$1.service" || systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "$1"; }
service_action(){
  local action="$1" svc="$2"
  if ! svc_exists "$svc"; then echo -e "${YELLOW}⚠️ Service $svc non installé.${NC}"; return; fi
  case "$action" in
    start|stop|restart) echo -e "${CYAN}🔄 $action $svc...${NC}"; systemctl "$action" "$svc" || echo -e "${RED}❌ Échec de $action $svc${NC}";;
    status) systemctl status "$svc" --no-pager;;
    logs) journalctl -u "$svc" -n 80 --no-pager;;
  esac
}
service_menu(){
  while true; do
    clear; header "⚙️ GESTION DES SERVICES"
    echo "01) ▶️  Start"; echo "02) ⏹️  Stop"; echo "03) 🔄 Restart"; echo "04) 📊 Status"; echo "05) 📜 Logs"; echo "00) ↩️  Retour"; echo
    read -rp 'Choix: ' a
    [ "$a" = 00 ] && return
    read -rp 'Nom exact du service systemd: ' s
    [ -z "$s" ] && continue
    case "$a" in 01) service_action start "$s";;02) service_action stop "$s";;03) service_action restart "$s";;04) service_action status "$s";;05) service_action logs "$s";;*) echo -e "${RED}❌ Choix invalide.${NC}";;esac
    pause
  done
}
header(){ echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"; echo -e "${CYAN}║${NC} ${BOLD}${WHITE}$1${NC} — ${GREEN}JOELTOM_VPN${NC}"; echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"; }
show_info(){
 clear; header '🖥️ INFORMATIONS VPS'
 . /etc/os-release 2>/dev/null || true
 IP4="$(curl -4fsS --max-time 3 https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')"
 IP6="$(curl -6fsS --max-time 3 https://api64.ipify.org 2>/dev/null || echo N/A)"
 echo "🌐 IPv4    : ${IP4:-N/A}"; echo "🌐 IPv6    : ${IP6:-N/A}"; echo "💻 OS      : ${PRETTY_NAME:-$(uname -s)}"; echo "🧠 RAM     : $(free -h | awk '/Mem:/ {print $3" / "$2}')"; echo "💾 Disque  : $(df -h / | awk 'NR==2 {print $3" / "$2" ("$5")"}')"; echo "⚙️ CPU     : $(nproc) vCPU — $(lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^ +/,"",$2); print $2; exit}')"; echo "⏱️ Uptime  : $(uptime -p 2>/dev/null || echo N/A)"; echo
 echo '📡 Services principaux:'
 for s in ssh dropbear nginx xray ws-stunnel openvpn squid zivpn udp-custom hysteria-server tuic-server joeltom-web joeltom-core-bot joeltom-deploy-bot joeltom-whatsapp-bot; do if svc_exists "$s"; then if systemctl is-active --quiet "$s"; then st="${GREEN}● RUN${NC}"; else st="${RED}○ OFF${NC}"; fi; printf '  %-28s %b\n' "$s" "$st"; fi; done
 pause
}
ports_info(){ clear; header '🔌 PORTS & RÉSEAU'; command -v ss >/dev/null && ss -lntup 2>/dev/null | head -80 || echo 'ss indisponible'; pause; }
logs_menu(){ clear; header '📜 LOGS'; read -rp 'Service (ex: xray, nginx, ssh): ' s; [ -n "$s" ] && service_action logs "$s"; pause; }
protocol_menu(){
 while true; do clear; header '🔐 PROTOCOLES VPN';
 echo '01) 🔑 SSH / Dropbear / WebSocket'; echo '02) ⚡ Xray / VMess / VLESS / Trojan'; echo '03) 🧦 SOCKS / Shadowsocks'; echo '04) 🚀 ZIVPN / UDP Custom'; echo '05) 🐌 SlowDNS / DNS'; echo '06) 🔒 OpenVPN'; echo '07) 🛡️ WireGuard'; echo '08) 🌪️ Hysteria2'; echo '09) 🚀 TUIC'; echo '00) ↩️ Retour'; echo; read -rp 'Choix: ' o;
 case "$o" in 01) run_menu ssh.sh;;02) run_menu vmess.sh;;03) run_menu socks.sh;;04) run_menu zivpn.sh;;05) run_menu dns.sh;;06) run_menu openvpn.sh;;07) run_menu wireguard.sh;;08) run_menu hysteria2.sh;;09) run_menu tuic.sh;;00) return;;*) echo -e "${RED}❌ Choix invalide${NC}"; sleep 1;; esac
 done
}
users_menu(){ while true; do clear; header '👤 GESTION UTILISATEURS'; echo '01) ➕ Créer / gérer SSH'; echo '02) 📋 Liste SSH'; echo '03) ⏳ Expiration'; echo '04) ⚡ Comptes Xray'; echo '05) 🧹 Nettoyage'; echo '00) ↩️ Retour'; read -rp 'Choix: ' o; case "$o" in 01|02) run_menu ssh.sh;;03) run_menu expiry.sh;;04) run_menu vless.sh;;05) run_menu log.sh;;00) return;;*) echo -e "${RED}❌ Choix invalide${NC}"; sleep 1;; esac; done; }
maintenance_menu(){ while true; do clear; header '🧹 MAINTENANCE'; echo '01) 📊 Statut VPS'; echo '02) 🔌 Ports'; echo '03) 📜 Logs'; echo '04) 🌐 Domaine'; echo '05) 🧭 DNS'; echo '06) 🔄 Mise à jour'; echo '07) 🗑️ Désinstallation'; echo '00) ↩️ Retour'; read -rp 'Choix: ' o; case "$o" in 01) run_menu status.sh;;02) ports_info;;03) logs_menu;;04) run_menu domain.sh;;05) run_menu dns.sh;;06) run_menu update.sh;;07) run_menu uninstall.sh;;00) return;;*) echo -e "${RED}❌ Choix invalide${NC}"; sleep 1;; esac; done; }
main(){
 while true; do clear; header '🚀 JOELTOM VPN PANEL';
 IP="$(hostname -I 2>/dev/null | awk '{print $1}')"; DOMAIN="$(cat /etc/xray/domain 2>/dev/null || echo N/A)"; echo -e "🌐 IP: ${IP:-N/A}   |   🌍 Domaine: $DOMAIN   |   📦 Version: $VERSION"; echo
 echo '01) 🖥️  Informations VPS'; echo '02) 👤  Gestion des utilisateurs'; echo '03) 🔐  Protocoles VPN'; echo '04) ⚙️  Gestion des services'; echo '05) 📊  Statut & ports'; echo '06) 🧹  Maintenance'; echo '07) 🤖  Bots & panneau Web'; echo '08) 📈  Outils réseau'; echo '00) ❌  Quitter'; echo; read -rp 'Sélectionnez une option: ' o;
 case "$o" in 01) show_info;;02) users_menu;;03) protocol_menu;;04) service_menu;;05) run_menu status.sh; ports_info;;06) maintenance_menu;;07) run_menu tgbot.sh;;08) run_menu speedtest.sh;;00) exit 0;;*) echo -e "${RED}❌ Choix invalide${NC}"; sleep 1;; esac
 done
}
main
