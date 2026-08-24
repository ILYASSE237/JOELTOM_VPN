#!/bin/bash
BASE="/etc/movivip"
clear
echo "=== JOELTOM — COMPTES ZiVPN ==="
echo ""
bash "$BASE/usuarios/account.sh" zivpn_list 2>/dev/null || true
echo ""
read -r -p "Entrée..."
