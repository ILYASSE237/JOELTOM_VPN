#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
echo "=== Installation du Bot Deploy JOELTOM VPN ==="
pip3 install -r requirements.txt >/dev/null 2>&1 || true
mkdir -p /etc/joeltom_deploy_bot
cp config.example.json /etc/joeltom_deploy_bot/config.json
cp deploy_bot.py /etc/joeltom_deploy_bot/
cp "$SCRIPT_DIR/../module/joeltom-deploy-bot.service" /etc/systemd/system/ 2>/dev/null || true
systemctl daemon-reload >/dev/null 2>&1 || true
systemctl enable joeltom-deploy-bot >/dev/null 2>&1 || true
echo "Éditez /etc/joeltom_deploy_bot/config.json avec votre token et votre ID Telegram"
echo "Démarrez avec: systemctl start joeltom-deploy-bot"

