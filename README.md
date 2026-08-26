🛡️ JOELTOM_VPN

🚀 Auto-installeur VPN multi-protocoles pour VPS Linux

JOELTOM_VPN est un système d'installation et de gestion de services VPN destiné aux VPS Linux.
Le projet regroupe plusieurs protocoles et outils réseau dans une architecture organisée avec un menu de gestion.

✨ Version

JOELTOM_VPN v2.1.0

📦 Protocoles et services

- 🔐 SSH / Dropbear
- 🌐 SSH WebSocket
- 🔒 WebSocket SSL
- ⚡ Xray
- 🔵 VMess
- 🟢 VLESS
- 🟠 Trojan
- 🧦 SOCKS
- 🔑 Shadowsocks
- 🚀 UDP Custom
- ⚡ BadVPN
- 📡 ZIVPN
- 🌍 SlowDNS / DNS
- 🔐 OpenVPN
- 🛡️ WireGuard
- 🚄 Hysteria2
- ⚡ TUIC v5
- 🌐 Nginx
- 🔒 Stunnel
- 🔑 Certificats ACME / SSL
- 🤖 Bots et outils de déploiement
- 🌐 Panneau Web JOELTOM

💻 Systèmes supportés

Le projet est prévu principalement pour :

- Ubuntu 20.04+
- Ubuntu 22.04
- Ubuntu 24.04
- Debian 11+
- Debian 12+

Architecture recommandée :

- x86_64 / amd64
- ARM64 / aarch64

«⚠️ Les environnements OpenVZ ne sont pas pris en charge.»

🚀 Installation rapide

Connectez-vous à votre VPS en SSH puis exécutez :

wget -qO- https://raw.githubusercontent.com/ILYASSE237/JOELTOM_VPN/main/autoinstall.sh | sudo bash

Ou avec le dépôt cloné :

git clone https://github.com/ILYASSE237/JOELTOM_VPN.git
cd JOELTOM_VPN
chmod +x install.sh
sudo ./install.sh

🌐 Domaine

Pendant l'installation, JOELTOM_VPN demande le domaine du VPS.

Le domaine doit pointer vers l'adresse IP publique du serveur.

Exemple :

vpn.exemple.com
        ↓
IP DU VPS

Le script vérifie automatiquement que le domaine correspond à l'IP du VPS avant de continuer.

🧭 Menu

Après l'installation, le menu principal est disponible avec :

menu

ou :

/usr/local/bin/menu

Le menu permet notamment de gérer :

- 👤 Utilisateurs
- 🔐 SSH
- 🌐 VMess
- 🟢 VLESS
- 🟠 Trojan
- 🧦 SOCKS
- 🔑 Shadowsocks
- 📡 ZIVPN
- 🌍 DNS / SlowDNS
- 🚀 UDP
- 🔒 OpenVPN
- ⚡ WireGuard
- 🚄 Hysteria2
- ⚡ TUIC
- 📊 Statistiques
- 🔌 Ports
- 📜 Logs
- 🤖 Telegram Bot
- 🌐 Panneau Web
- 🔄 Mise à jour
- 🗑️ Désinstallation

🌐 Panneau Web

Le projet comprend également un panneau Web basé sur :

- Node.js
- Express
- React
- SQLite

Le panneau peut être installé après le cœur VPN.

Port par défaut :

2087

Accès :

http://IP_DU_VPS:2087

Le mot de passe administrateur doit être configuré pendant l'installation et ne doit pas être placé directement dans le code source.

🔧 Commandes utiles

Vérifier Xray

systemctl status xray --no-pager

Vérifier Nginx

systemctl status nginx --no-pager

Vérifier le panneau Web

systemctl status joeltom-web --no-pager

Voir les ports utilisés

ss -lntup

Voir les logs Xray

journalctl -u xray -n 100 --no-pager

Voir les logs du panneau Web

journalctl -u joeltom-web -n 100 --no-pager

🔄 Mise à jour

Utilisez le menu JOELTOM_VPN pour accéder aux fonctions de mise à jour.

Les scripts de maintenance se trouvent notamment dans :

menu/update.sh
menu/uninstall.sh

🧹 Désinstallation

La désinstallation doit être effectuée depuis le menu afin de limiter les risques de supprimer accidentellement des services système qui ne font pas partie de JOELTOM_VPN.

🔐 Sécurité

⚠️ Ne publiez jamais dans GitHub :

- mots de passe
- tokens Telegram
- clés API
- clés privées
- identifiants VPS
- certificats privés
- fichiers ".env" contenant des secrets

Utilisez plutôt :

.env

ou des fichiers protégés dans :

/etc/joeltom/

📁 Structure du projet

JOELTOM_VPN/
│
├── core/
│   ├── sshws.sh
│   ├── xray.sh
│   ├── vpn.sh
│   ├── websocket.sh
│   ├── setup_zivpn.sh
│   ├── setup_dns.sh
│   └── setup_udp.sh
│
├── menu/
│   ├── menu.sh
│   ├── ssh.sh
│   ├── vmess.sh
│   ├── vless.sh
│   ├── trojan.sh
│   ├── zivpn.sh
│   ├── openvpn.sh
│   ├── wireguard.sh
│   ├── shadowsocks.sh
│   ├── hysteria2.sh
│   ├── tuic.sh
│   ├── update.sh
│   └── uninstall.sh
│
├── module/
├── nexus-web/
├── joeltom_core_bot/
├── joeltom_deploy_bot/
├── joeltom_whatsapp_bot/
├── doty_bot_source/
│
├── install.sh
├── autoinstall.sh
├── joeltom.sh
├── install_web_panel_vps.sh
├── docker-compose.yml
├── Dockerfile.bot
├── Dockerfile.web
├── nginx.conf
├── .env.example
├── version.txt
└── README.md

⚙️ Installation manuelle

git clone https://github.com/ILYASSE237/JOELTOM_VPN.git
cd JOELTOM_VPN
chmod +x install.sh joeltom.sh
sudo ./install.sh

🧪 Validation des scripts

Avant de déployer une modification :

chmod +x validate_shell_scripts.sh
bash validate_shell_scripts.sh

⚠️ Important

L'installation modifie plusieurs composants réseau du VPS.

Avant l'installation :

1. Faites une sauvegarde de vos données.
2. Utilisez un VPS dédié si possible.
3. Vérifiez les ports déjà utilisés.
4. Vérifiez que votre domaine pointe vers le VPS.
5. Ne lancez pas plusieurs installateurs VPN concurrents sur le même serveur.

👨‍💻 Projet

JOELTOM_VPN

Version : 2.1.0

© 2026 JOELTOM TEAM