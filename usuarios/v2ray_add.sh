#!/bin/bash
# JOELTOM VPS — création d'un compte V2Ray/Xray indépendant
BASE="/etc/movivip"
CFG="/usr/local/etc/xray/config.json"
DB="$BASE/usuarios/v2ray-users.db"
GREEN="\e[1;92m"; RED="\e[1;91m"; CYAN="\e[1;96m"; RESET="\e[0m"
mkdir -p "$(dirname "$DB")"

[[ -f "$CFG" ]] || { echo -e "${RED}Xray n'est pas installé.${RESET}"; read -r -p "Entrée..."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo -e "${RED}jq est requis.${RESET}"; read -r -p "Entrée..."; exit 1; }

read -rp "Nom du compte V2Ray : " USER
[[ -z "$USER" ]] && exit 1
if grep -q "^${USER}|" "$DB" 2>/dev/null; then
    echo -e "${RED}Ce compte existe déjà.${RESET}"; read -r -p "Entrée..."; exit 1
fi

read -rp "Durée en jours [30] : " DAYS
DAYS="${DAYS:-30}"
[[ "$DAYS" =~ ^[0-9]+$ ]] || DAYS=30
UUID=$(cat /proc/sys/kernel/random/uuid)
EMAIL="${USER}@joeltom"

TMP=$(mktemp)
if ! jq --arg uuid "$UUID" --arg email "$EMAIL" '
  .inbounds |= map(
    if (.protocol=="vmess" and .settings.clients) then
      .settings.clients += [{"id":$uuid,"level":0,"email":$email}]
    else . end
  )' "$CFG" > "$TMP"; then
    rm -f "$TMP"; echo -e "${RED}Erreur de modification Xray.${RESET}"; exit 1
fi
mv "$TMP" "$CFG"
systemctl restart xray 2>/dev/null || true
EXP=$(date -d "+${DAYS} days" +%s 2>/dev/null || echo 0)
echo "${USER}|${UUID}|${EXP}" >> "$DB"

DOMAIN="${SERVER_DOMAIN:-$(hostname -f 2>/dev/null || hostname)}"
PORT="${XRAY_PORT:-443}"
echo ""
echo -e "${GREEN}✔ Compte V2Ray créé.${RESET}"
echo "Nom      : $USER"
echo "UUID     : $UUID"
echo "Serveur  : $DOMAIN"
echo "Port     : $PORT"
echo "Transport: VMess"
echo "Path     : /vmess"
echo "Expire   : $(date -d "@$EXP" '+%d/%m/%Y' 2>/dev/null || echo "$DAYS jours")"
echo ""
read -r -p "Entrée pour continuer..."
