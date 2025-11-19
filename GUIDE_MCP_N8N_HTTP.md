# Guide : Utiliser MCP WhatsApp dans n8n via HTTP (Méthode Alternative)

Si l'option MCP native n'est pas disponible dans votre version de n8n, vous pouvez utiliser le serveur MCP WhatsApp via des requêtes HTTP.

## 📋 Vue d'ensemble

Le serveur MCP WhatsApp expose une interface HTTP sur le port 8000 qui permet d'appeler les outils MCP via des requêtes POST simples.

## 🚀 Configuration rapide

### Étape 1 : Vérifier que le serveur est actif

```bash
docker compose ps whatsapp-mcp-server
docker compose logs whatsapp-mcp-server | grep "Dashboard server"
```

### Étape 2 : Créer un workflow dans n8n

1. **Ouvrez n8n** : http://localhost:5678
2. **Créez un nouveau workflow**
3. **Ajoutez un nœud HTTP Request**

## 📝 Exemples d'utilisation

### Exemple 1 : Envoyer un message WhatsApp

**Configuration du nœud HTTP Request :**

```
Méthode : POST
URL : http://whatsapp-mcp-server:8000/run_tool
Headers :
  Content-Type: application/json
Body (JSON) :
{
  "tool": "send_message",
  "params": {
    "recipient": "+33612345678",
    "message": "Bonjour depuis n8n !"
  }
}
```

**Configuration complète dans n8n :**

1. **Méthode** : `POST`
2. **URL** : `http://whatsapp-mcp-server:8000/run_tool`
3. **Authentication** : `None`
4. **Send Body** : `Yes`
5. **Body Content Type** : `JSON`
6. **Body** :
```json
{
  "tool": "send_message",
  "params": {
    "recipient": "={{ $json.phone }}",
    "message": "={{ $json.message }}"
  }
}
```

### Exemple 2 : Lister les chats

**Configuration du nœud HTTP Request :**

```
Méthode : POST
URL : http://whatsapp-mcp-server:8000/run_tool
Body (JSON) :
{
  "tool": "list_chats",
  "params": {
    "limit": 10,
    "include_last_message": true
  }
}
```

### Exemple 3 : Lister les messages d'un chat

**Configuration du nœud HTTP Request :**

```
Méthode : POST
URL : http://whatsapp-mcp-server:8000/run_tool
Body (JSON) :
{
  "tool": "list_messages",
  "params": {
    "chat_jid": "22554038858@s.whatsapp.net",
    "limit": 20
  }
}
```

### Exemple 4 : Rechercher des contacts

**Configuration du nœud HTTP Request :**

```
Méthode : POST
URL : http://whatsapp-mcp-server:8000/run_tool
Body (JSON) :
{
  "tool": "search_contacts",
  "params": {
    "query": "Jean"
  }
}
```

### Exemple 5 : Envoyer un fichier

**Configuration du nœud HTTP Request :**

```
Méthode : POST
URL : http://whatsapp-mcp-server:8000/run_tool
Body (JSON) :
{
  "tool": "send_file",
  "params": {
    "recipient": "+33612345678",
    "file_path": "/app/media/image.jpg",
    "file_type": "image"
  }
}
```

## 🔧 Workflows complets

### Workflow 1 : Envoyer un message automatique

```
1. Trigger (Webhook/Schedule)
   ↓
2. HTTP Request
   - URL: http://whatsapp-mcp-server:8000/run_tool
   - Method: POST
   - Body: {
       "tool": "send_message",
       "params": {
         "recipient": "={{ $json.phone }}",
         "message": "Bonjour {{ $json.name }} !"
       }
     }
   ↓
3. IF (vérifier le succès)
   ↓
4. Notification
```

### Workflow 2 : Surveiller les nouveaux messages

```
1. Schedule (toutes les 5 minutes)
   ↓
2. HTTP Request
   - URL: http://whatsapp-mcp-server:8000/run_tool
   - Method: POST
   - Body: {
       "tool": "list_messages",
       "params": {
         "limit": 10,
         "after": "={{ $workflow.staticData.lastCheck }}"
       }
     }
   ↓
3. Filter (nouveaux messages)
   ↓
4. Traitement des messages
   ↓
5. Set (mettre à jour lastCheck)
```

### Workflow 3 : Chatbot WhatsApp

```
1. Webhook (recevoir événements)
   ↓
2. HTTP Request
   - Tool: list_messages
   - Params: { "chat_jid": "={{ $json.chat_jid }}", "limit": 1 }
   ↓
3. AI/LLM Node (générer réponse)
   ↓
4. HTTP Request
   - Tool: send_message
   - Params: {
       "recipient": "={{ $json.chat_jid }}",
       "message": "={{ $json.ai_response }}"
     }
```

## 📚 Tous les outils disponibles

### Communication

| Outil | Paramètres | Exemple |
|-------|------------|---------|
| `send_message` | `recipient`, `message` | Voir Exemple 1 |
| `send_file` | `recipient`, `file_path`, `file_type` | Voir Exemple 5 |
| `send_audio_message` | `recipient`, `audio_path` | Similaire à `send_file` |

### Recherche et consultation

| Outil | Paramètres | Exemple |
|-------|------------|---------|
| `list_chats` | `limit`, `page`, `query`, `include_last_message` | Voir Exemple 2 |
| `list_messages` | `chat_jid`, `limit`, `query`, `after`, `before` | Voir Exemple 3 |
| `search_contacts` | `query` | Voir Exemple 4 |
| `get_chat` | `chat_jid` | `{"tool": "get_chat", "params": {"chat_jid": "..."}}` |
| `get_direct_chat_by_contact` | `phone_number` | `{"tool": "get_direct_chat_by_contact", "params": {"phone_number": "+33612345678"}}` |
| `get_contact_chats` | `phone_number` | `{"tool": "get_contact_chats", "params": {"phone_number": "+33612345678"}}` |
| `get_last_interaction` | `phone_number` | `{"tool": "get_last_interaction", "params": {"phone_number": "+33612345678"}}` |
| `get_message_context` | `message_id`, `before`, `after` | `{"tool": "get_message_context", "params": {"message_id": "...", "before": 5, "after": 5}}` |

### Médias

| Outil | Paramètres | Exemple |
|-------|------------|---------|
| `download_media` | `message_id`, `chat_jid` | `{"tool": "download_media", "params": {"message_id": "...", "chat_jid": "..."}}` |

## ⚠️ Points importants

### Utiliser les noms de services Docker

Dans n8n, utilisez toujours le **nom du service Docker** :
- ✅ `http://whatsapp-mcp-server:8000/run_tool`
- ❌ `http://localhost:8000/run_tool` (ne fonctionnera pas)

### Format des réponses

Toutes les réponses sont au format JSON :

**Succès :**
```json
[
  {
    "jid": "22554038858@s.whatsapp.net",
    "name": "22554038858",
    ...
  }
]
```

**Erreur :**
```json
{
  "error": "Message d'erreur",
  "traceback": "..."
}
```

### Format des numéros de téléphone

- Avec indicatif : `+33612345678`
- Ou JID WhatsApp : `33612345678@s.whatsapp.net`

## 🔍 Dépannage

### Erreur : "Cannot connect to whatsapp-mcp-server"

**Solution :** Vérifiez que les services sont sur le même réseau Docker :
```bash
docker compose ps
docker network inspect whatsapp-mcp-n8n_internal
```

### Erreur : "Tool not found"

**Solution :** Vérifiez l'orthographe du nom de l'outil dans le paramètre `tool`.

### Erreur : "500 Internal Server Error"

**Solution :** Consultez les logs pour plus de détails :
```bash
docker compose logs whatsapp-mcp-server | tail -20
```

### Les messages ne sont pas envoyés

**Solution :** Vérifiez que WhatsApp est connecté :
```bash
docker compose logs whatsapp-bridge | grep "Connected\|QR code"
```

## 🎯 Exemple de workflow JSON pour n8n

Voici un exemple complet de workflow n8n que vous pouvez importer :

```json
{
  "name": "WhatsApp - Envoyer message via MCP",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "whatsapp-send",
        "responseMode": "responseNode"
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [250, 300],
      "webhookId": "whatsapp-send-mcp"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "http://whatsapp-mcp-server:8000/run_tool",
        "authentication": "none",
        "options": {
          "headers": {
            "Content-Type": "application/json"
          }
        },
        "bodyParameters": {
          "parameters": []
        },
        "sendBody": true,
        "bodyContentType": "json",
        "jsonBody": "={\n  \"tool\": \"send_message\",\n  \"params\": {\n    \"recipient\": \"{{ $json.body.phone }}\",\n    \"message\": \"{{ $json.body.message }}\"\n  }\n}"
      },
      "name": "MCP - Envoyer message",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.1,
      "position": [450, 300]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { \"success\": true, \"data\": $json } }}"
      },
      "name": "Répondre",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [650, 300]
    }
  ],
  "connections": {
    "Webhook": {
      "main": [[{"node": "MCP - Envoyer message", "type": "main", "index": 0}]]
    },
    "MCP - Envoyer message": {
      "main": [[{"node": "Répondre", "type": "main", "index": 0}]]
    }
  }
}
```

## 📖 Ressources supplémentaires

- **Dashboard WhatsApp** : http://localhost:8000/ui
- **Logs du serveur** : `docker compose logs -f whatsapp-mcp-server`
- **Guide MCP natif** : `GUIDE_MCP_NATIF_N8N.md` (si disponible dans votre version de n8n)

---

## ✅ Avantages de cette méthode

- ✅ Fonctionne avec toutes les versions de n8n
- ✅ Simple à configurer (juste des requêtes HTTP)
- ✅ Accès à tous les outils MCP
- ✅ Facile à déboguer (logs HTTP standards)
- ✅ Compatible avec tous les workflows n8n

Cette méthode est la **solution recommandée** si le support MCP natif n'est pas disponible dans votre version de n8n.

