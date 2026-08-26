#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
echo "=== Installation du Bot WhatsApp JOELTOM VPN ==="
pip3 install -r requirements.txt >/dev/null 2>&1 || true
mkdir -p /etc/joeltom_whatsapp_bot
cp config.example.json /etc/joeltom_whatsapp_bot/config.json
cp whatsapp_bot.py /etc/joeltom_whatsapp_bot/
cp "$SCRIPT_DIR/../module/joeltom-whatsapp-bot.service" /etc/systemd/system/ 2>/dev/null || true
systemctl daemon-reload >/dev/null 2>&1 || true
systemctl enable joeltom-whatsapp-bot >/dev/null 2>&1 || true
echo "Éditez /etc/joeltom_whatsapp_bot/config.json avec vos credentials Twilio"
echo "Configurez le webhook Twilio sur: https://VOTRE_DOMAINE:5001/whatsapp"
echo "Démarrez avec: systemctl start joeltom-whatsapp-bot"
