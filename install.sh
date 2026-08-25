#!/bin/bash
set -euo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; NC='\033[0m'
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ "$EUID" -eq 0 ] || { echo -e "${RED}❌ install.sh doit être exécuté en root (sudo ./install.sh).${NC}"; exit 1; }
command -v bash >/dev/null || { echo -e "${RED}❌ Bash est requis.${NC}"; exit 1; }
chmod +x "$ROOT_DIR/joeltom.sh" "$ROOT_DIR/menu/"*.sh 2>/dev/null || true
export JOELTOM_NO_REBOOT=1
export SERVER_HOST="${SERVER_HOST:-https://raw.githubusercontent.com/joeltom-tech/JOELTOM_VPN/main}"
export TIMEZONE="${TIMEZONE:-Africa/Douala}"
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}       🚀 ${GREEN}JOELTOM_VPN — INSTALLATEUR${NC}       ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo -e "${YELLOW}⚠️  L'installation modifie les services réseau du VPS.${NC}"
echo -e "${YELLOW}⚠️  Aucun service existant ne sera tué arbitrairement.${NC}\n"
bash "$ROOT_DIR/joeltom.sh"
# Installer le panneau web seulement après le cœur VPN, et sans masquer les erreurs.
if [ "${JOELTOM_INSTALL_WEB:-1}" = "1" ] && [ -d "$ROOT_DIR/nexus-web" ]; then
  echo -e "${CYAN}🌐 Installation du panneau Web JOELTOM...${NC}"
  bash "$ROOT_DIR/install_web_panel_vps.sh"
fi
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       ✅ INSTALLATION TERMINÉE — JOELTOM_VPN        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo "Menu: /usr/local/bin/menu"
echo "Version: $(cat /etc/joeltom/version 2>/dev/null || echo 2.1.0)"
