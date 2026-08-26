#!/bin/bash

set -euo pipefail

# ============================================================
#        JOELTOM_VPN — INSTALLATEUR PRINCIPAL
#        Version : 2.1.0
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------
# Vérification root
# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Ce script doit être exécuté en root.${NC}"
    echo
    echo "Utilisez :"
    echo "sudo ./install.sh"
    exit 1
fi

# ------------------------------------------------------------
# Vérification Bash
# ------------------------------------------------------------

if ! command -v bash >/dev/null 2>&1; then
    echo -e "${RED}❌ Bash est requis.${NC}"
    exit 1
fi

# ------------------------------------------------------------
# Préparation
# ------------------------------------------------------------

chmod +x "$ROOT_DIR/joeltom.sh" 2>/dev/null || true
chmod +x "$ROOT_DIR/menu/"*.sh 2>/dev/null || true
chmod +x "$ROOT_DIR/core/"*.sh 2>/dev/null || true

# Désactive le reboot automatique pendant l'installation
export JOELTOM_NO_REBOOT=1

# Dépôt utilisé par les scripts
export SERVER_HOST="${SERVER_HOST:-https://raw.githubusercontent.com/ILYASSE237/JOELTOM_VPN/main}"

# Fuseau horaire par défaut
export TIMEZONE="${TIMEZONE:-Africa/Douala}"

# ------------------------------------------------------------
# Bannière
# ------------------------------------------------------------

clear

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║                                                      ║"
echo "║             🚀 JOELTOM_VPN v2.1.0                    ║"
echo "║                                                      ║"
echo "║             AUTO-INSTALLATEUR VPS                    ║"
echo "║                                                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}⚠️  L'installation modifie les services réseau du VPS.${NC}"
echo -e "${YELLOW}⚠️  Vérifiez les ports et effectuez une sauvegarde avant de continuer.${NC}"
echo

# ------------------------------------------------------------
# Vérification du script principal
# ------------------------------------------------------------

if [ ! -f "$ROOT_DIR/joeltom.sh" ]; then
    echo -e "${RED}❌ joeltom.sh est introuvable.${NC}"
    echo "Répertoire : $ROOT_DIR"
    exit 1
fi

# ------------------------------------------------------------
# Installation du cœur VPN
# ------------------------------------------------------------

echo -e "${CYAN}🚀 Lancement de l'installation JOELTOM_VPN...${NC}"
echo

bash "$ROOT_DIR/joeltom.sh"

# ------------------------------------------------------------
# Installation du panneau Web
# ------------------------------------------------------------

if [ "${JOELTOM_INSTALL_WEB:-1}" = "1" ] &&
   [ -d "$ROOT_DIR/nexus-web" ] &&
   [ -f "$ROOT_DIR/install_web_panel_vps.sh" ]; then

    echo
    echo -e "${CYAN}🌐 Installation du panneau Web JOELTOM...${NC}"
    echo

    bash "$ROOT_DIR/install_web_panel_vps.sh"
fi

# ------------------------------------------------------------
# Fin
# ------------------------------------------------------------

VERSION="$(cat /etc/joeltom/version 2>/dev/null || echo "2.1.0")"

echo
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║                                                      ║"
echo "║       ✅ INSTALLATION TERMINÉE AVEC SUCCÈS          ║"
echo "║                                                      ║"
echo "║                 JOELTOM_VPN                          ║"
echo "║                                                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${GREEN}Version : ${VERSION}${NC}"
echo
echo "Menu : /usr/local/bin/menu"
echo
echo -e "${CYAN}Pour ouvrir le menu :${NC}"
echo
echo "menu"
echo