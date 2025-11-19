# Configuration du Webhook de Production n8n

## 📋 URL de Production

Votre URL de webhook n8n en production :
```
https://floroo.app.n8n.cloud/webhook-test/mcp-whatsapp
```

⚠️ **Note** : Utilisez `/webhook-test/` pour les tests et `/webhook/` pour la production active.

## ✅ Configuration

### Option 1 : Via fichier `.env` (Recommandé)

1. **Créez ou modifiez le fichier `.env`** à la racine du projet :
   ```bash
   cd /Users/koffiyohanerickouakou/whatsapp-mcp-n8n
   ```

2. **Ajoutez la configuration** :
   ```bash
   # URL du webhook n8n (test ou production)
   # Pour les tests : /webhook-test/
   # Pour la production : /webhook/
   N8N_WEBHOOK_URL=https://floroo.app.n8n.cloud/webhook-test/mcp-whatsapp
   ```

3. **Redémarrez le bridge WhatsApp** :
   ```bash
   docker compose down
   docker compose up -d --build whatsapp-bridge
   ```

### Option 2 : Via docker-compose.yml directement

Modifiez `docker-compose.yml` et remplacez :
```yaml
- N8N_WEBHOOK_URL=${N8N_WEBHOOK_URL:-}
```

Par :
```yaml
- N8N_WEBHOOK_URL=https://floroo.app.n8n.cloud/webhook-test/mcp-whatsapp
```

Puis redémarrez :
```bash
docker compose up -d --build whatsapp-bridge
```

## 🔍 Vérification

### 1. Vérifier que le webhook est configuré

```bash
docker compose logs whatsapp-bridge | grep -i webhook
```

Vous devriez voir :
```
Webhook configured: https://floroo.app.n8n.cloud/webhook-test/mcp-whatsapp
```

### 2. Tester en envoyant un message WhatsApp

1. **Envoyez un message WhatsApp** à votre numéro
2. **Vérifiez dans n8n** que le workflow se déclenche
3. **Vérifiez les logs** :
   ```bash
   docker compose logs whatsapp-bridge | tail -20
   ```

Vous devriez voir :
```
Webhook sent successfully to https://floroo.app.n8n.cloud/webhook-test/mcp-whatsapp
```

## ⚠️ Points Importants

### 1. HTTPS vs HTTP

- L'URL de production utilise **HTTPS** (sécurisé)
- Le bridge Go supporte HTTPS automatiquement
- Pas de configuration supplémentaire nécessaire

### 2. Accessibilité

- Assurez-vous que le serveur peut accéder à Internet
- Vérifiez qu'il n'y a pas de firewall bloquant les connexions HTTPS sortantes
- Testez la connectivité :
  ```bash
  docker compose exec whatsapp-bridge curl -I https://floroo.app.n8n.cloud/webhook/mcp-whatsapp
  ```

### 3. Workflow n8n

- Assurez-vous que le workflow est **activé** dans n8n
- Vérifiez que le webhook est configuré avec le path `mcp-whatsapp`
- Testez le webhook manuellement depuis n8n

## 🐛 Dépannage

### Erreur : "Connection refused" ou "Timeout"

**Causes possibles** :
- Le serveur n'a pas accès à Internet
- Firewall bloque HTTPS
- URL incorrecte

**Solutions** :
1. Vérifiez la connectivité :
   ```bash
   docker compose exec whatsapp-bridge ping -c 2 floroo.app.n8n.cloud
   ```

2. Testez l'URL :
   ```bash
   docker compose exec whatsapp-bridge curl -v https://floroo.app.n8n.cloud/webhook/mcp-whatsapp
   ```

3. Vérifiez les logs :
   ```bash
   docker compose logs whatsapp-bridge | grep -i webhook
   ```

### Erreur : "SSL certificate problem"

**Solution** :
- Le bridge Go devrait gérer SSL automatiquement
- Si problème, vérifiez que les certificats système sont à jour dans le conteneur

### Le webhook ne se déclenche pas

**Vérifications** :
1. Le workflow est activé dans n8n
2. Le path du webhook est correct : `mcp-whatsapp`
3. Le webhook accepte les requêtes POST
4. Les logs du bridge montrent que le webhook est envoyé

## 📊 Format des Données Envoyées

Quand un message WhatsApp est reçu, le bridge envoie ce payload au webhook :

```json
{
  "from": "2250703324674@s.whatsapp.net",
  "to": "VOTRE_NUMERO@s.whatsapp.net",
  "message": "Bonjour !",
  "text": "Bonjour !",
  "body": "Bonjour !",
  "timestamp": "2024-01-15T10:30:00Z",
  "chat_jid": "2250703324674@s.whatsapp.net",
  "chat_name": "Nom du contact",
  "is_from_me": false,
  "media_type": "",
  "filename": "",
  "message_id": "3EB0123456789ABCDEF"
}
```

## ✅ Checklist de Configuration

- [ ] Fichier `.env` créé avec `N8N_WEBHOOK_URL=https://floroo.app.n8n.cloud/webhook/mcp-whatsapp`
- [ ] Bridge WhatsApp redémarré
- [ ] Logs vérifiés : `docker compose logs whatsapp-bridge | grep webhook`
- [ ] Workflow activé dans n8n
- [ ] Webhook configuré avec path `mcp-whatsapp`
- [ ] Test effectué en envoyant un message WhatsApp
- [ ] Vérification que le workflow se déclenche dans n8n

## 🎯 Résumé

**Configuration minimale** :

1. Créez `.env` avec :
   ```bash
   N8N_WEBHOOK_URL=https://floroo.app.n8n.cloud/webhook-test/mcp-whatsapp
   ```

2. Redémarrez le bridge :
   ```bash
   docker compose up -d --build whatsapp-bridge
   ```

3. Vérifiez :
   ```bash
   docker compose logs whatsapp-bridge | grep webhook
   ```

C'est tout ! 🚀

Une fois configuré, chaque message WhatsApp reçu sera automatiquement envoyé à votre workflow n8n en production.

