# 🛡️ JOELTOM_VPN v2.1.0

Auto-installeur VPN multi-protocoles pour VPS Linux, refactorisé à partir du projet existant. L'objectif est de conserver les protocoles présents, corriger les erreurs détectées et fournir une architecture/menu plus propre.

## 🚀 Installation

```bash
chmod +x install.sh
sudo ./install.sh
```

Installation distante :

```bash
wget -qO- https://raw.githubusercontent.com/joeltom-tech/JOELTOM_VPN/main/autoinstall.sh | sudo bash
```

> L'installation modifie des services réseau du VPS. Aucun processus important n'est tué arbitrairement en cas de conflit de port.

## 📦 Protocoles et composants conservés

- SSH / Dropbear
- SSH WebSocket / WebSocket SSL
- Xray / VMess / VLESS / Trojan
- SOCKS / Shadowsocks
- UDP Custom / BadVPN
- ZIVPN
- SlowDNS / DNS
- OpenVPN + OHP/Squid
- WireGuard
- Hysteria2
- TUIC v5
- Nginx / Stunnel / certificats ACME
- Panneau Web Express + React + SQLite
- Bots Telegram, Deploy multi-VPS et WhatsApp/Twilio

Les protocoles dont l'installation est optionnelle ou susceptible d'utiliser un port partagé sont exposés dans le menu plutôt que démarrés silencieusement avec une configuration conflictuelle.

## 🧭 Menu

Le menu principal est installé dans `/usr/local/sbin/menu.sh` et `/usr/local/bin/menu`.

- 🖥️ Informations VPS
- 👤 Gestion des utilisateurs
- 🔐 Protocoles VPN avec sous-menus
- ⚙️ Gestion des services systemd
- 📊 Statut / ports / logs
- 🧹 Maintenance, domaine, DNS, mise à jour et désinstallation
- 🤖 Bots et panneau Web

## 🌐 Panneau Web

Le panneau utilise Node.js 20+, Express, React et SQLite. Le mot de passe administrateur n'est plus codé en dur : l'installateur le demande et stocke les secrets dans `/etc/joeltom-web/joeltom.env` avec des permissions restrictives.

Accès par défaut : `http://IP_DU_VPS:2087` après installation.

## 🔧 Dépannage

```bash
systemctl status xray --no-pager
systemctl status nginx --no-pager
systemctl status joeltom-web --no-pager
ss -lntup
journalctl -u xray -n 100 --no-pager
journalctl -u joeltom-web -n 100 --no-pager
```

Validation locale des scripts :

```bash
bash validate_shell_scripts.sh
```

## 🔄 Mise à jour / désinstallation

Les fonctions correspondantes restent accessibles depuis le menu. Consultez également `menu/update.sh` et `menu/uninstall.sh`.

## 🔐 Sécurité

Ne placez jamais de tokens, clés privées, mots de passe ou secrets API dans Git. Utilisez `.env` ou les fichiers de configuration protégés prévus par le projet.

## 📁 Structure

```text
JOELTOM_VPN/
├── install.sh
├── autoinstall.sh
├── joeltom.sh
├── core/
├── menu/
├── module/
├── nexus-web/
├── joeltom_core_bot/
├── joeltom_deploy_bot/
├── joeltom_whatsapp_bot/
├── doty_bot_source/
└── README.md
```

© 2026 JOELTOM_VPN
