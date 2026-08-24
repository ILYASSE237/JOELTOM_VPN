#!/bin/bash
# JOELTOM VPS — MISE À JOUR SANS LICENCE
BASE="/etc/movivip"
REPO="${JOELTOM_REPO:-}"
BRANCH="${JOELTOM_BRANCH:-main}"
GREEN="\e[1;92m"; RED="\e[1;91m"; CYAN="\e[1;96m"; WHITE="\e[1;97m"; RESET="\e[0m"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║${WHITE}                 JOELTOM VPS — MISE À JOUR                ${CYAN}║${RESET}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""

if [[ -z "$REPO" && -f "$BASE/config.conf" ]]; then
    source "$BASE/config.conf" 2>/dev/null
    REPO="${JOELTOM_REPO:-}"
fi

if [[ -z "$REPO" ]]; then
    echo -e "${WHITE}Aucun dépôt de mise à jour n'est configuré.${RESET}"
    echo -e "${WHITE}Le système installé continue de fonctionner normalement.${RESET}"
    echo -e "${CYAN}Ajoutez JOELTOM_REPO dans config.conf pour activer les mises à jour.${RESET}"
    exit 0
fi

command -v git >/dev/null 2>&1 || { echo -e "${RED}Git n'est pas installé.${RESET}"; exit 1; }
TMP="/tmp/joeltom-update-$$"
trap 'rm -rf "$TMP"' EXIT

echo -e "${CYAN}→ Téléchargement depuis : ${REPO}${RESET}"
if ! git clone --depth 1 --branch "$BRANCH" "$REPO" "$TMP" >/dev/null 2>&1; then
    echo -e "${RED}✖ Impossible de récupérer la mise à jour.${RESET}"
    exit 1
fi
rm -rf "$TMP/.git"
cp -a "$TMP"/. "$BASE"/
chmod -R +x "$BASE" 2>/dev/null || true
echo -e "${GREEN}✔ JOELTOM VPS a été mis à jour.${RESET}"
