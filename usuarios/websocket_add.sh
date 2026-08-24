#!/bin/bash
# WebSocket est un transport : l'authentification reste SSH.
BASE="/etc/movivip"
GREEN="\e[1;92m"; CYAN="\e[1;96m"; RESET="\e[0m"
clear
echo -e "${CYAN}=== JOELTOM — COMPTE WEBSOCKET / SSH ===${RESET}"
echo ""
echo "WebSocket utilise les identifiants SSH ; aucun mot de passe WS séparé"
echo "n'est créé par le serveur."
echo ""
bash "$BASE/usuarios/add.sh"
