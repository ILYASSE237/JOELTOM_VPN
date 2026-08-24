# JOELTOM VPS

Version 1.0.0 — panneau VPS libre, sans système de clé de licence.

## Modifications principales

- Marque principale : **JOELTOM VPS / JOEL TOM**
- Interface principale configurée en français par défaut.
- Suppression du système de licence : aucune `LICENCIA_KEY`, aucun `KEY-XXXXXXXXXX`, aucun gate Firebase.
- Suppression des modules de génération/validation de licences.
- Suppression des notifications Telegram d'activation et du bot de licence.
- Mise à jour automatique désactivée par défaut.
- Le menu principal est organisé comme demandé :
  1. SSH / VPN
  2. Xray / V2Ray
  3. ZiVPN
  4. Monitor
  5. Domaine
  6. Protocoles
  7. Banners
  8. Auto-Panel
  9. Mise à jour
  10. Désinstaller
  0. Quitter
- Ajout d'un gestionnaire de comptes séparés par protocole :
  - SSH
  - V2Ray / Xray
  - ZiVPN
  - WebSocket / SSH
  - Informations SlowDNS
- SlowDNS est traité comme un service à clé serveur commune : ce protocole ne possède pas, dans cette implémentation, un compte serveur distinct par utilisateur.
- WebSocket utilise les identifiants SSH ; il n'invente pas un système d'authentification WS séparé.

## Installation

Décompresser le projet sur le VPS puis :

```bash
cd JOELTOM-VPS
chmod +x install.sh
sudo ./install.sh
```

Le script ne redémarre plus automatiquement le VPS à la fin.

## Mise à jour

Aucune URL de dépôt externe n'est imposée. Pour activer les mises à jour, ajouter votre propre dépôt Git dans `/etc/movivip/config.conf` :

```bash
JOELTOM_REPO="https://github.com/VOTRE-COMPTE/VOTRE-DEPOT.git"
JOELTOM_BRANCH="main"
```

Les clés cryptographiques propres aux protocoles (par exemple la clé publique/privée SlowDNS) ne sont pas des clés de licence et restent nécessaires au fonctionnement des services concernés.
