# 📱 WhatsApp MCP Server avec n8n

Un serveur MCP (Model Context Protocol) complet pour intégrer WhatsApp avec n8n, permettant de créer des assistants IA automatisés pour WhatsApp.

## 🎯 Fonctionnalités

- ✅ **Serveur MCP natif** pour n8n avec support des nœuds MCP natifs
- ✅ **API REST** pour intégration avec d'autres outils
- ✅ **Webhook automatique** pour déclencher des workflows n8n sur réception de messages
- ✅ **Dashboard web** pour visualiser les conversations
- ✅ **Support des médias** (images, vidéos, audio, documents)
- ✅ **Messages interactifs** (boutons convertis en options numérotées)
- ✅ **Intégration IA** avec OpenAI GPT-4 via n8n

## 📋 Prérequis

- **Docker** et **Docker Compose** installés
- **Git** pour cloner le repository
- Un compte **WhatsApp** (numéro de téléphone)
- (Optionnel) Un compte **n8n Cloud** ou n8n installé localement

## 🚀 Installation Rapide

### 1. Cloner le Repository

```bash
git clone <URL_DU_REPO>
cd whatsapp-mcp-n8n
```

### 2. Configurer l'Environnement

```bash
# Copier le fichier d'exemple
cp .env.example .env

# Éditer .env et ajouter votre URL de webhook n8n (optionnel)
nano .env
```

### 3. Démarrer les Services

```bash
# Démarrer tous les services
docker compose up -d

# Voir les logs pour obtenir le QR code
docker compose logs -f whatsapp-bridge
```

### 4. Scanner le QR Code

1. Ouvrez WhatsApp sur votre téléphone
2. Allez dans **Paramètres** → **Appareils liés** → **Lier un appareil**
3. Scannez le QR code affiché dans les logs
4. Attendez la confirmation "✅ WhatsApp connecté !"

## 📖 Documentation Complète

- **[Guide d'Installation pour Étudiants](GUIDE_INSTALLATION_ETUDIANTS.md)** - Instructions détaillées pas à pas
- **[Guide QR Code](GUIDE_QR_CODE_ETUDIANTS.md)** - Comment scanner le QR code et résoudre les problèmes
- **[Guide n8n MCP](GUIDE_MCP_NATIF_N8N.md)** - Configuration des nœuds MCP dans n8n
- **[Guide Webhook](GUIDE_WEBHOOK_MESSAGES.md)** - Configuration des webhooks pour recevoir des messages
- **[Guide Workflow Complet](GUIDE_WORKFLOW_COMPLET.md)** - Exemple de workflow complet avec IA

## 🏗️ Architecture

```
┌─────────────────┐
│   WhatsApp      │
│   (Téléphone)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ WhatsApp Bridge │  ← Go (whatsmeow)
│   (Port 8081)   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌─────────┐ ┌──────────────┐
│  MCP    │ │   Dashboard   │
│ Server  │ │   (Port 8000) │
│(Port    │ └──────────────┘
│ 9000)   │
└────┬────┘
     │
     ▼
┌─────────┐
│   n8n   │
│(Port    │
│ 5678)   │
└─────────┘
```

## 🔧 Services Docker

- **whatsapp-bridge** : Bridge Go pour WhatsApp (port 8081)
- **whatsapp-mcp-server** : Serveur MCP Python (ports 8000, 9000)
- **n8n** : Plateforme d'automatisation (port 5678)

## 📝 Utilisation

### Envoyer un Message via API

```bash
curl -X POST http://localhost:8081/api/send \
  -H "Content-Type: application/json" \
  -d '{
    "recipient": "2250703324674",
    "message": "Bonjour !"
  }'
```

### Accéder au Dashboard

Ouvrez votre navigateur : http://localhost:8000

### Accéder à n8n

Ouvrez votre navigateur : http://localhost:5678
- Utilisateur : `admin`
- Mot de passe : `admin`

## 🔗 Intégration avec n8n

### Méthode 1 : Nœuds MCP Natifs (Recommandé)

Utilisez les nœuds natifs `MCP Client` et `MCP Server Trigger` dans n8n.

Voir : [GUIDE_MCP_NATIF_N8N.md](GUIDE_MCP_NATIF_N8N.md)

### Méthode 2 : API REST

Utilisez les nœuds HTTP Request dans n8n pour appeler l'API REST.

Voir : [GUIDE_N8N_MCP.md](GUIDE_N8N_MCP.md)

## 🎓 Pour les Étudiants

Si vous êtes étudiant et que vous venez de cloner ce projet, suivez ces guides :

1. **[Guide d'Installation](GUIDE_INSTALLATION_ETUDIANTS.md)** - Commencez ici !
2. **[Guide QR Code](GUIDE_QR_CODE_ETUDIANTS.md)** - Comment connecter WhatsApp
3. **[Guide n8n](GUIDE_MCP_NATIF_N8N.md)** - Comment utiliser avec n8n

## 🐛 Dépannage

### Le QR code n'apparaît pas

```bash
# Vérifier les logs
docker compose logs whatsapp-bridge

# Redémarrer le service
docker compose restart whatsapp-bridge
```

### Le webhook ne fonctionne pas

1. Vérifiez que `N8N_WEBHOOK_URL` est configuré dans `.env`
2. Vérifiez que le workflow n8n est activé
3. Consultez : [DIAGNOSTIC_WEBHOOK.md](DIAGNOSTIC_WEBHOOK.md)

### Les messages ne sont pas reçus

1. Vérifiez que WhatsApp est bien connecté (QR code scanné)
2. Vérifiez les logs : `docker compose logs whatsapp-bridge`
3. Testez l'envoi d'un message depuis un autre téléphone

## 📚 Ressources

- [Documentation MCP](https://modelcontextprotocol.io/)
- [Documentation n8n](https://docs.n8n.io/)
- [Documentation whatsmeow](https://github.com/tulir/whatsmeow)

## 📄 Licence

Voir le fichier [LICENSE](whatsapp-mcp/LICENSE) pour plus de détails.

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## 📧 Support

Pour toute question ou problème :
1. Consultez la documentation dans le dossier `docs/`
2. Ouvrez une issue sur GitHub
3. Contactez votre professeur

---

**Bon développement ! 🚀**
