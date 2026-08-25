#!/usr/bin/env bash
set -euo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; NC='\033[0m'
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR=/opt/joeltom-web
DB_DIR=/etc/joeltom-web
SERVICE_FILE=/etc/systemd/system/joeltom-web.service
[ "$EUID" -eq 0 ] || { echo -e "${RED}❌ Panel Web: root requis.${NC}"; exit 1; }
command -v node >/dev/null 2>&1 || { echo -e "${RED}❌ Node.js 20+ requis pour le panneau Web.${NC}"; exit 1; }
NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]')
[ "$NODE_MAJOR" -ge 20 ] || { echo -e "${RED}❌ Node.js $NODE_MAJOR détecté. Node.js 20+ requis.${NC}"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo -e "${RED}❌ npm requis.${NC}"; exit 1; }
[ -d "$ROOT_DIR/nexus-web" ] || { echo -e "${RED}❌ nexus-web introuvable.${NC}"; exit 1; }

mkdir -p "$APP_DIR" "$DB_DIR"
cp -a "$ROOT_DIR/nexus-web/." "$APP_DIR/"
cd "$APP_DIR"

echo -e "${CYAN}📦 Installation des dépendances Web...${NC}"
npm ci --include=dev
npm run build

if [ ! -f "$DB_DIR/joeltom.env" ]; then
  read -rp "Nom admin du panneau [admin]: " ADMIN_USER
  ADMIN_USER="${ADMIN_USER:-admin}"
  while true; do
    read -rsp "Mot de passe admin (minimum 8 caractères): " ADMIN_PASS; echo
    [ "${#ADMIN_PASS}" -ge 8 ] && break
    echo -e "${YELLOW}⚠️ Mot de passe trop court.${NC}"
  done
  JWT_SECRET="$(openssl rand -hex 32)"
  cat > "$DB_DIR/joeltom.env" <<ENV
NODE_ENV=production
PORT=2087
NEXUS_PORT=2087
NEXUS_ADMIN_USER=$ADMIN_USER
NEXUS_ADMIN_PASS=$ADMIN_PASS
NEXUS_JWT_SECRET=$JWT_SECRET
JOELTOM_DB_DIR=$DB_DIR
ENV
  chmod 600 "$DB_DIR/joeltom.env"
fi

cp "$ROOT_DIR/module/joeltom-web.service" "$SERVICE_FILE"
chmod 644 "$SERVICE_FILE"
systemctl daemon-reload
systemctl enable --now joeltom-web
sleep 2
if ! systemctl is-active --quiet joeltom-web; then
  echo -e "${RED}❌ joeltom-web n'est pas actif.${NC}"
  journalctl -u joeltom-web -n 60 --no-pager || true
  exit 1
fi
if command -v ss >/dev/null 2>&1 && ! ss -lntp 2>/dev/null | grep -q ':2087\b'; then
  echo -e "${RED}❌ Le service est actif mais le port 2087 n'écoute pas.${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Panneau Web JOELTOM installé et actif: http://$(hostname -I | awk '{print $1}'):2087${NC}"
