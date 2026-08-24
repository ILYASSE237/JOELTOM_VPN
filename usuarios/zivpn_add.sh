#!/bin/bash
# JOELTOM VPS — compte ZiVPN indépendant
BASE="/etc/movivip"
[[ -f "$BASE/config.conf" ]] && source "$BASE/config.conf"
GREEN="\e[1;92m"; RED="\e[1;91m"; CYAN="\e[1;96m"; RESET="\e[0m"

[[ -f /etc/zivpn/config.json ]] || { echo -e "${RED}ZiVPN n'est pas installé.${RESET}"; read -r -p "Entrée..."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo -e "${RED}jq est requis.${RESET}"; exit 1; }

read -rp "Mot de passe du compte ZiVPN : " PASS
[[ -z "$PASS" ]] && exit 1
read -rp "Durée en jours [30] : " DAYS
DAYS="${DAYS:-30}"
read -rp "Quota GB [0=illimité] : " GB
GB="${GB:-0}"

OUT=$(bash "$BASE/usuarios/account.sh" zipvpn_add "$PASS" "$DAYS" "$GB" 2>&1)
echo "$OUT"
echo ""
if grep -q '^OK:zipvpn_added:' <<<"$OUT"; then
  echo -e "${GREEN}✔ Compte ZiVPN créé avec succès.${RESET}"
  echo "Mot de passe : $PASS"
  echo "Durée        : $DAYS jours"
  echo "Quota        : ${GB} GB"
fi
read -r -p "Entrée..."
