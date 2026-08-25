#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
REPO_RAW="${REPO_RAW:-https://raw.githubusercontent.com/joeltom-tech/JOELTOM_VPN/main}"
RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'
[ "$EUID" -eq 0 ] || { echo -e "${RED}❌ Exécutez ce script en root.${NC}"; exit 1; }
command -v curl >/dev/null 2>&1 || { apt-get update -y && apt-get install -y curl ca-certificates; }
echo -e "${BLUE}🚀 JOELTOM_VPN — installation distante${NC}"
curl -fsSL "$REPO_RAW/install.sh" -o /tmp/joeltom-install.sh
chmod +x /tmp/joeltom-install.sh
exec bash /tmp/joeltom-install.sh
