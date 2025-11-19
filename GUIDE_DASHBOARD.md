# 📊 Guide du Dashboard WhatsApp

## 🎯 Vue d'ensemble

Le dashboard WhatsApp est une interface web React qui permet de gérer vos conversations WhatsApp via une interface graphique moderne.

## 🚀 Installation et démarrage

### 1. Construire le dashboard

Le dashboard doit être construit avant d'être intégré dans Docker :

```bash
cd whatsapp-mcp/whatsapp-dashboard
npm install
npm run build
```

### 2. Reconstruire l'image Docker

```bash
docker compose build whatsapp-mcp-server
docker compose up -d whatsapp-mcp-server
```

### 3. Accéder au dashboard

Une fois le service démarré, le dashboard est accessible à :

**URL** : `http://localhost:8000/ui`

## 🔧 Configuration

### Variables d'environnement

Dans `docker-compose.yml`, vous pouvez configurer :

- `DASHBOARD_PORT` : Port du dashboard (défaut: 8000)
- `WHATSAPP_BRIDGE_URL` : URL de l'API WhatsApp bridge (défaut: http://whatsapp-bridge:8080/api)

### Authentification

Le dashboard utilise actuellement des identifiants codés en dur dans `api.js`. Pour la production, vous devriez :

1. Configurer l'authentification via variables d'environnement
2. Ou utiliser un système d'authentification plus sécurisé

## 📱 Fonctionnalités

Le dashboard permet de :

- ✅ **Lister les chats** : Voir toutes vos conversations WhatsApp
- ✅ **Lire les messages** : Consulter l'historique des messages
- ✅ **Envoyer des messages** : Envoyer des messages via l'interface

## 🛠️ Développement

### Mode développement

Pour développer le dashboard localement :

```bash
cd whatsapp-mcp/whatsapp-dashboard
npm run dev
```

Le dashboard sera accessible sur `http://localhost:5173` (port par défaut de Vite).

### Rebuild après modifications

Après avoir modifié le code du dashboard :

```bash
cd whatsapp-mcp/whatsapp-dashboard
npm run build
docker compose build whatsapp-mcp-server
docker compose up -d whatsapp-mcp-server
```

## 🔍 Dépannage

### Le dashboard ne s'affiche pas

1. Vérifier que le dashboard est buildé :
   ```bash
   ls -la whatsapp-mcp/whatsapp-dashboard/dist/
   ```

2. Vérifier les logs du serveur :
   ```bash
   docker compose logs whatsapp-mcp-server
   ```

3. Vérifier que le port 8000 est exposé :
   ```bash
   docker compose ps
   ```

### Erreurs d'API

Si les appels API échouent :

1. Vérifier que le WhatsApp bridge est démarré :
   ```bash
   docker compose ps whatsapp-bridge
   ```

2. Vérifier la connectivité :
   ```bash
   curl http://localhost:8081/api/health
   ```

3. Vérifier les logs :
   ```bash
   docker compose logs whatsapp-bridge
   ```

## 📝 Structure du projet

```
whatsapp-mcp/
├── whatsapp-dashboard/
│   ├── src/
│   │   ├── App.jsx          # Composant principal
│   │   ├── api.js            # Appels API
│   │   └── components/       # Composants React
│   ├── dist/                 # Build de production
│   └── package.json
└── whatsapp-mcp-server/
    ├── dashboard_server.py   # Serveur HTTP pour le dashboard
    └── ui/                   # Dashboard buildé (copié depuis dist/)
```

## 🔗 Liens utiles

- **Dashboard** : http://localhost:8000/ui
- **API WhatsApp Bridge** : http://localhost:8081/api
- **n8n** : http://localhost:5678

## 💡 Notes

- Le dashboard est servi via un serveur HTTP Python simple
- Les fichiers statiques sont servis depuis `/app/ui` dans le conteneur
- Le dashboard communique avec l'API WhatsApp bridge via HTTP
- Pour la production, configurez l'authentification et HTTPS

---

**Dernière mise à jour** : 16 novembre 2025

