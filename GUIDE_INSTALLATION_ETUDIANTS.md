# 📚 Guide d'Installation pour Étudiants

Ce guide vous explique étape par étape comment installer et configurer le projet WhatsApp MCP avec n8n.

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir :

- ✅ **Docker Desktop** installé et démarré
  - [Télécharger Docker Desktop](https://www.docker.com/products/docker-desktop/)
  - Windows : Installez Docker Desktop
  - Mac : Installez Docker Desktop
  - Linux : Installez Docker et Docker Compose

- ✅ **Git** installé
  - [Télécharger Git](https://git-scm.com/downloads)

- ✅ **Un compte WhatsApp** avec un numéro de téléphone actif

- ✅ **Un terminal/console** (Terminal sur Mac, PowerShell sur Windows, Terminal sur Linux)

## 🚀 Étape 1 : Cloner le Repository

### Sur Windows (PowerShell ou Git Bash)

```powershell
# Ouvrir PowerShell ou Git Bash
cd Desktop
git clone <URL_DU_REPO>
cd whatsapp-mcp-n8n
```

### Sur Mac/Linux (Terminal)

```bash
cd ~/Desktop
git clone <URL_DU_REPO>
cd whatsapp-mcp-n8n
```

**Remplacez `<URL_DU_REPO>` par l'URL fournie par votre professeur.**

## 🔧 Étape 2 : Vérifier Docker

Avant de continuer, vérifiez que Docker fonctionne :

```bash
docker --version
docker compose version
```

Vous devriez voir les versions de Docker et Docker Compose.

Si vous obtenez une erreur, assurez-vous que **Docker Desktop est démarré**.

## ⚙️ Étape 3 : Configurer l'Environnement

### 3.1 Créer le fichier .env

```bash
# Copier le fichier d'exemple
cp .env.example .env
```

### 3.2 Éditer le fichier .env (Optionnel)

Si vous utilisez n8n Cloud ou avez un webhook configuré, ouvrez `.env` et ajoutez votre URL :

```bash
# Sur Mac/Linux
nano .env

# Sur Windows (avec Notepad)
notepad .env
```

Ajoutez votre URL de webhook (si vous en avez une) :

```env
N8N_WEBHOOK_URL=https://votre-domaine.n8n.cloud/webhook/votre-id
```

**Note** : Si vous n'avez pas encore de webhook, laissez cette ligne vide ou commentée. Vous pourrez la configurer plus tard.

## 🐳 Étape 4 : Démarrer les Services

### 4.1 Démarrer Docker Compose

```bash
docker compose up -d
```

Cette commande va :
- Télécharger les images Docker nécessaires (première fois seulement)
- Construire les conteneurs
- Démarrer tous les services en arrière-plan

**⏱️ La première fois peut prendre 5-10 minutes** (téléchargement des images).

### 4.2 Vérifier que les services sont démarrés

```bash
docker compose ps
```

Vous devriez voir 3 services avec le statut "Up" :
- `n8n`
- `whatsapp-bridge`
- `whatsapp-mcp-server`

## 📱 Étape 5 : Scanner le QR Code WhatsApp

### 5.1 Afficher les logs pour voir le QR code

```bash
docker compose logs -f whatsapp-bridge
```

### 5.2 Chercher le QR code dans les logs

Vous verrez quelque chose comme :

```
QR code for pairing:
████████████████████████████████
████████████████████████████████
████████████████████████████████
...
```

### 5.3 Scanner le QR code avec WhatsApp

1. **Ouvrez WhatsApp** sur votre téléphone
2. Allez dans **Paramètres** (⚙️)
3. Allez dans **Appareils liés** (ou **Linked Devices**)
4. Appuyez sur **Lier un appareil** (ou **Link a Device**)
5. **Scannez le QR code** affiché dans votre terminal

### 5.4 Confirmation

Après avoir scanné, vous devriez voir dans les logs :

```
✅ WhatsApp connecté !
✅ Client connecté et prêt
```

**🎉 Félicitations ! WhatsApp est maintenant connecté.**

## 🧪 Étape 6 : Tester l'Installation

### 6.1 Accéder au Dashboard

Ouvrez votre navigateur et allez à : **http://localhost:8000**

Vous devriez voir le dashboard WhatsApp avec vos conversations.

### 6.2 Accéder à n8n

Ouvrez votre navigateur et allez à : **http://localhost:5678**

- **Utilisateur** : `admin`
- **Mot de passe** : `admin`

### 6.3 Tester l'envoi d'un message

Depuis un autre téléphone, envoyez un message WhatsApp à votre numéro.

Vous devriez voir le message apparaître dans :
- Le dashboard (http://localhost:8000)
- Les logs : `docker compose logs -f whatsapp-bridge`

## 📖 Étape 7 : Utiliser avec n8n

Maintenant que tout est installé, vous pouvez :

1. **Créer un workflow dans n8n** pour automatiser les réponses
2. **Utiliser les nœuds MCP** pour interagir avec WhatsApp
3. **Configurer un webhook** pour recevoir les messages automatiquement

Consultez les guides suivants :
- [GUIDE_MCP_NATIF_N8N.md](GUIDE_MCP_NATIF_N8N.md) - Utiliser les nœuds MCP
- [GUIDE_WEBHOOK_MESSAGES.md](GUIDE_WEBHOOK_MESSAGES.md) - Configurer les webhooks
- [GUIDE_WORKFLOW_COMPLET.md](GUIDE_WORKFLOW_COMPLET.md) - Exemple de workflow complet

## 🛠️ Commandes Utiles

### Voir les logs en temps réel

```bash
# Logs du bridge WhatsApp
docker compose logs -f whatsapp-bridge

# Logs du serveur MCP
docker compose logs -f whatsapp-mcp-server

# Logs de n8n
docker compose logs -f n8n

# Tous les logs
docker compose logs -f
```

### Arrêter les services

```bash
docker compose stop
```

### Redémarrer les services

```bash
docker compose restart
```

### Arrêter et supprimer les conteneurs

```bash
docker compose down
```

### Redémarrer complètement (si problème)

```bash
docker compose down
docker compose up -d
```

## 🐛 Problèmes Courants

### ❌ "Docker is not running"

**Solution** : Démarrez Docker Desktop et attendez qu'il soit complètement démarré.

### ❌ "Port already in use"

**Solution** : Un autre service utilise déjà le port. Arrêtez les autres services ou modifiez les ports dans `docker-compose.yml`.

### ❌ "QR code not appearing"

**Solution** :
1. Vérifiez les logs : `docker compose logs whatsapp-bridge`
2. Redémarrez le service : `docker compose restart whatsapp-bridge`
3. Consultez [GUIDE_QR_CODE_ETUDIANTS.md](GUIDE_QR_CODE_ETUDIANTS.md)

### ❌ "Cannot connect to WhatsApp"

**Solution** :
1. Vérifiez que vous avez scanné le QR code
2. Vérifiez votre connexion Internet
3. Redémarrez le service : `docker compose restart whatsapp-bridge`

### ❌ "Services won't start"

**Solution** :
1. Vérifiez que Docker Desktop est démarré
2. Vérifiez les logs : `docker compose logs`
3. Essayez de redémarrer : `docker compose down && docker compose up -d`

## 📞 Besoin d'Aide ?

Si vous rencontrez des problèmes :

1. **Consultez les guides** dans le dossier du projet
2. **Vérifiez les logs** avec `docker compose logs`
3. **Demandez à votre professeur** ou ouvrez une issue sur GitHub

## ✅ Checklist d'Installation

- [ ] Docker Desktop installé et démarré
- [ ] Repository cloné
- [ ] Fichier `.env` créé
- [ ] Services démarrés avec `docker compose up -d`
- [ ] QR code scanné avec WhatsApp
- [ ] WhatsApp connecté (confirmation dans les logs)
- [ ] Dashboard accessible (http://localhost:8000)
- [ ] n8n accessible (http://localhost:5678)
- [ ] Test d'envoi de message réussi

**Une fois toutes les cases cochées, vous êtes prêt à utiliser le projet ! 🎉**

---

**Bon développement ! 🚀**

