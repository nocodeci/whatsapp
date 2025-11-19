# Guide : Configurer le webhook pour recevoir les messages WhatsApp dans n8n

Ce guide explique comment configurer un webhook pour que votre workflow n8n se déclenche automatiquement à chaque fois qu'un message WhatsApp est reçu.

## 🎯 Objectif

Quand quelqu'un vous envoie un message WhatsApp, le bridge Go envoie automatiquement une notification HTTP (webhook) à n8n, qui déclenche votre workflow.

## 📋 Étapes de configuration

### Étape 1 : Créer le webhook dans n8n

1. **Ouvrez n8n** : http://localhost:5678
   - Utilisateur : `admin`
   - Mot de passe : `admin`

2. **Créez un nouveau workflow** ou ouvrez votre workflow existant

3. **Ajoutez un nœud "Webhook"** comme premier nœud (trigger)

4. **Configurez le webhook :**
   - **HTTP Method** : `POST`
   - **Path** : `mcp-whatsapp` (ou le nom de votre choix)
   - **Response Mode** : `Last Node` (ou `When Last Node Finishes`)

5. **Activez le workflow** (bouton ON/OFF en haut à droite)

6. **Copiez l'URL du webhook** :
   - Cliquez sur le nœud Webhook
   - L'URL complète s'affiche, par exemple :
     ```
     http://localhost:5678/webhook/mcp-whatsapp
     ```
   - ⚠️ **Important** : Notez cette URL, vous en aurez besoin !

### Étape 2 : Configurer l'URL du webhook dans Docker

#### Option A : Via fichier `.env` (recommandé)

1. **Créez un fichier `.env`** à la racine du projet (si ce n'est pas déjà fait) :
   ```bash
   cd /Users/koffiyohanerickouakou/whatsapp-mcp-n8n
   ```

2. **Ajoutez la variable d'environnement** :
   ```bash
   # URL du webhook n8n pour recevoir les messages WhatsApp
   # Utilisez le nom du service Docker (n8n) et non localhost
   N8N_WEBHOOK_URL=http://n8n:5678/webhook/mcp-whatsapp
   ```
   ⚠️ **Important** : Utilisez `n8n` (nom du service Docker) et non `localhost` !

#### Option B : Via docker-compose.yml directement

Modifiez `docker-compose.yml` et remplacez :
```yaml
- N8N_WEBHOOK_URL=${N8N_WEBHOOK_URL:-}
```

Par :
```yaml
- N8N_WEBHOOK_URL=http://n8n:5678/webhook/mcp-whatsapp
```

### Étape 3 : Redémarrer les services

```bash
cd /Users/koffiyohanerickouakou/whatsapp-mcp-n8n
docker compose down
docker compose up -d --build whatsapp-bridge
```

Le service `whatsapp-bridge` sera reconstruit avec le support webhook.

### Étape 4 : Vérifier la configuration

1. **Vérifiez les logs** du bridge :
   ```bash
   docker compose logs whatsapp-bridge | grep -i webhook
   ```

   Vous devriez voir :
   ```
   Webhook configured: http://n8n:5678/webhook/mcp-whatsapp
   ```

2. **Testez en envoyant un message WhatsApp** à votre numéro

3. **Vérifiez dans n8n** :
   - Le workflow devrait se déclencher automatiquement
   - Les données du message devraient apparaître dans le nœud Webhook

## 📦 Format des données reçues

Quand un message est reçu, n8n recevra un payload JSON avec cette structure :

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

### Champs disponibles

| Champ | Description | Exemple |
|-------|-------------|---------|
| `from` | Expéditeur (JID complet) | `2250703324674@s.whatsapp.net` |
| `to` | Destinataire (votre numéro) | `VOTRE_NUMERO@s.whatsapp.net` |
| `message` | Contenu du message texte | `"Bonjour !"` |
| `text` | Alias pour `message` | `"Bonjour !"` |
| `body` | Alias pour `message` | `"Bonjour !"` |
| `timestamp` | Date/heure du message | `"2024-01-15T10:30:00Z"` |
| `chat_jid` | JID de la conversation | `2250703324674@s.whatsapp.net` |
| `chat_name` | Nom du contact/chat | `"Jean Dupont"` |
| `is_from_me` | `true` si envoyé par vous | `false` |
| `media_type` | Type de média (si présent) | `"image"`, `"video"`, `"audio"`, etc. |
| `filename` | Nom du fichier (si média) | `"photo.jpg"` |
| `message_id` | ID unique du message | `"3EB0123456789ABCDEF"` |

## 🔧 Configuration avancée

### Filtrer les messages

Si vous voulez recevoir seulement certains types de messages, vous pouvez ajouter une condition dans votre workflow n8n :

```javascript
// Exemple : Recevoir seulement les messages texte (pas les médias)
{{ $json.media_type === "" }}
```

### Extraire le numéro de téléphone

Pour extraire uniquement le numéro (sans le suffixe `@s.whatsapp.net`) :

```javascript
{{ $json.from.split('@')[0] }}
```

### Ignorer vos propres messages

Les webhooks sont déjà filtrés pour ne pas envoyer vos propres messages (`is_from_me: false`), mais vous pouvez ajouter une vérification supplémentaire :

```javascript
{{ $json.is_from_me === false }}
```

## 🐛 Dépannage

### Le webhook ne se déclenche pas

1. **Vérifiez que le workflow est activé** dans n8n
2. **Vérifiez l'URL du webhook** dans les logs :
   ```bash
   docker compose logs whatsapp-bridge | grep -i webhook
   ```
3. **Vérifiez la connectivité réseau** :
   ```bash
   docker compose exec whatsapp-bridge ping -c 2 n8n
   ```
4. **Vérifiez les logs n8n** :
   ```bash
   docker compose logs n8n | tail -50
   ```

### Erreur "Connection refused"

- Vérifiez que n8n est bien démarré : `docker compose ps n8n`
- Vérifiez que vous utilisez `n8n` (nom du service) et non `localhost`
- Vérifiez que le port est correct : `5678`

### Le webhook se déclenche mais les données sont vides

- Vérifiez que le message contient du texte ou un média
- Les messages vides sont ignorés automatiquement
- Vérifiez les logs du bridge pour voir si le message a été traité

## 📝 Exemple de workflow complet

Voici un exemple de workflow qui répond automatiquement aux messages :

1. **Webhook Trigger** → Reçoit le message
2. **Set Node** → Extrait les informations importantes
3. **AI Agent - MCP WhatsApp** → Génère une réponse avec l'IA
4. **MCP WhatsApp Server** → Envoie la réponse via `send_message`

## ✅ Résumé

1. ✅ Créer un webhook dans n8n (nœud Webhook)
2. ✅ Configurer `N8N_WEBHOOK_URL` dans `.env` ou `docker-compose.yml`
3. ✅ Redémarrer `whatsapp-bridge` avec `docker compose up -d --build whatsapp-bridge`
4. ✅ Tester en envoyant un message WhatsApp
5. ✅ Vérifier que le workflow se déclenche automatiquement

Une fois configuré, chaque message WhatsApp reçu déclenchera automatiquement votre workflow n8n ! 🎉

