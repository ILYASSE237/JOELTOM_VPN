#!/bin/bash
BASE="/etc/movivip"
DB="$BASE/usuarios/v2ray-users.db"
GREEN="\e[1;92m"; CYAN="\e[1;96m"; RESET="\e[0m"
clear
echo -e "${CYAN}=== JOELTOM — COMPTES V2RAY/XRAY ===${RESET}"
echo ""
if [[ ! -s "$DB" ]]; then
  echo "Aucun compte V2Ray enregistré."
else
  while IFS='|' read -r USER UUID EXP; do
    [[ -z "$USER" ]] && continue
    if [[ "$EXP" =~ ^[0-9]+$ && "$EXP" -gt 0 ]]; then
      DATE=$(date -d "@$EXP" '+%d/%m/%Y' 2>/dev/null)
    else DATE="Illimité"; fi
    echo "• $USER | $UUID | $DATE"
  done < "$DB"
fi
echo ""
read -r -p "Entrée..."
