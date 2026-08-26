1| # 🛡️ JOELTOM_VPN v2.1.0
2| 
3| Auto-installeur VPN multi-protocoles pour VPS Linux, refactorisé à partir du projet existant. L'objectif est de conserver les protocoles présents, corriger les erreurs détectées et fournir une[...]
4| 
5| ## 🚀 Installation
6| 
7| ```bash
8| chmod +x install.sh
9| sudo ./install.sh
10| ```
11| 
12| Installation distante :
13| 
14| ```bash
15| wget -qO- https://raw.githubusercontent.com/ILYASSE237/JOELTOM_VPN/main/autoinstall.sh | sudo bash
16| ```
17| 
18| > L'installation modifie des services réseau du VPS. Aucun processus important n'est tué arbitrairement en cas de conflit de port.
19| 
20| ## 📦 Protocoles et composants conservés
21| 
22| - SSH / Dropbear
23| - SSH WebSocket / WebSocket SSL
24| - Xray / VMess / VLESS / Trojan
25| - SOCKS / Shadowsocks
26| - UDP Custom / BadVPN
27| - ZIVPN
28| - SlowDNS / DNS
29| - OpenVPN + OHP/Squid
30| - WireGuard
31| - Hysteria2
32| - TUIC v5
33| - Nginx / Stunnel / certificats ACME
34| - Panneau Web Express + React + SQLite
35| - Bots Telegram, Deploy multi-VPS et WhatsApp/Twilio
36| 
37| Les protocoles dont l'installation est optionnelle ou susceptible d'utiliser un port partagé sont exposés dans le menu plutôt que démarrés silencieusement avec une configuration conflictuelle[...]
38| 
39| ## 🧭 Menu
40| 
41| Le menu principal est installé dans `/usr/local/sbin/menu.sh` et `/usr/local/bin/menu`.
42| 
43| - 🖥️ Informations VPS
44| - 👤 Gestion des utilisateurs
45| - 🔐 Protocoles VPN avec sous-menus
46| - ⚙️ Gestion des services systemd
47| - 📊 Statut / ports / logs
48| - 🧹 Maintenance, domaine, DNS, mise à jour et désinstallation
49| - 🤖 Bots et panneau Web
50| 
51| ## 🌐 Panneau Web
52| 
53| Le panneau utilise Node.js 20+, Express, React et SQLite. Le mot de passe administrateur n'est plus codé en dur : l'installateur le demande et stocke les secrets dans `/etc/joeltom-web/joeltom.en[...]
54| 
55| Accès par défaut : `http://IP_DU_VPS:2087` après installation.
56| 
57| ## 🔧 Dépannage
58| 
59| ```bash
60| systemctl status xray --no-pager
61| systemctl status nginx --no-pager
62| systemctl status joeltom-web --no-pager
63| ss -lntup
64| journalctl -u xray -n 100 --no-pager
65| journalctl -u joeltom-web -n 100 --no-pager
66| ```
67| 
68| Validation locale des scripts :
69| 
70| ```bash
71| bash validate_shell_scripts.sh
72| ```
73| 
74| ## 🔄 Mise à jour / désinstallation
75| 
76| Les fonctions correspondantes restent accessibles depuis le menu. Consultez également `menu/update.sh` et `menu/uninstall.sh`.
77| 
78| ## 🔐 Sécurité
79| 
80| Ne placez jamais de tokens, clés privées, mots de passe ou secrets API dans Git. Utilisez `.env` ou les fichiers de configuration protégés prévus par le projet.
81| 
82| ## 📁 Structure
83| 
84| ```text
85| JOELTOM_VPN/
86| ├── install.sh
87| ├── autoinstall.sh
88| ├── joeltom.sh
89| ├── core/
90| ├── menu/
91| ├── module/
92| ├── nexus-web/
93| ├── joeltom_core_bot/
94| ├── joeltom_deploy_bot/
95| ├── joeltom_whatsapp_bot/
96| ├── doty_bot_source/
97| └── README.md
98| ```
99| 
100| © 2026 JOELTOM_VPN
101| 
