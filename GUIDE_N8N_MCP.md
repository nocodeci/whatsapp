# Guide : Utiliser le serveur MCP WhatsApp dans n8n

Ce guide explique comment intégrer et utiliser le serveur MCP WhatsApp dans vos workflows n8n.

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Méthode 1 : Utiliser l'API REST directement (Recommandé)](#méthode-1--utiliser-lapi-rest-directement-recommandé)
3. [Méthode 2 : Utiliser le protocole MCP via TCP](#méthode-2--utiliser-le-protocole-mcp-via-tcp)
4. [Exemples de workflows](#exemples-de-workflows)
5. [Outils disponibles](#outils-disponibles)

---

## Vue d'ensemble

Le serveur MCP WhatsApp expose deux interfaces :

1. **API REST** (via `whatsapp-bridge` sur le port 8081) - **Plus simple à utiliser**
2. **Protocole MCP** (via `whatsapp-mcp-server` sur le port 9000) - Pour les clients MCP natifs

Pour n8n, nous recommandons d'utiliser l'**API REST** car elle est plus simple et plus directe.

---

## Méthode 1 : Utiliser l'API REST directement (Recommandé)

### Configuration

1. **Accédez à n8n** : http://localhost:5678
   - Utilisateur : `admin`
   - Mot de passe : `admin`

2. **Créez un nouveau workflow**

3. **Ajoutez un nœud HTTP Request**

### ⚠️ Important : Utiliser les noms de services Docker

Dans n8n, utilisez les **noms des services Docker** (pas `localhost`) :
- ✅ `http://whatsapp-bridge:8080/api/send`
- ❌ `http://localhost:8081/api/send` (ne fonctionnera pas depuis n8n)

### Exemple 1 : Envoyer un message WhatsApp

**Configuration du nœud HTTP Request :**

```
Méthode : POST
URL : http://whatsapp-bridge:8080/api/send
Headers :
  Content-Type: application/json
Body (JSON) :
{
  "recipient": "+33612345678",
  "message": "Bonjour depuis n8n !"
}
```

**Exemple complet dans n8n :**

```json
{
  "method": "POST",
  "url": "http://whatsapp-bridge:8080/api/send",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "recipient": "{{ $json.phone }}",
    "message": "{{ $json.message }}"
  }
}
```

### Exemple 2 : Lister les chats

**Configuration du nœud HTTP Request :**

```
Méthode : GET
URL : http://whatsapp-bridge:8080/api/chats
```

### Exemple 3 : Utiliser les fonctions MCP via HTTP (Liste des chats)

Pour lister les chats et messages, utilisez le serveur MCP via HTTP :

**Configuration du nœud HTTP Request :**

```
Méthode : POST
URL : http://whatsapp-mcp-server:8000/run_tool
Headers :
  Content-Type: application/json
Body (JSON) :
{
  "tool": "list_chats",
  "params": {
    "limit": 10,
    "include_last_message": true
  }
}
```

### Exemple 4 : Lister les messages d'un chat

**Configuration du nœud HTTP Request :**

```
Méthode : POST
URL : http://whatsapp-mcp-server:8000/run_tool
Headers :
  Content-Type: application/json
Body (JSON) :
{
  "tool": "list_messages",
  "params": {
    "chat_jid": "22554038858@s.whatsapp.net",
    "limit": 20
  }
}
```

---

## Méthode 2 : Utiliser le protocole MCP via TCP

Si vous préférez utiliser le protocole MCP natif, vous pouvez créer un nœud personnalisé ou utiliser un nœud TCP.

### Configuration TCP

1. **Ajoutez un nœud TCP Request** (si disponible) ou créez un nœud personnalisé

2. **Configuration :**
   ```
   Host : whatsapp-mcp-server
   Port : 9000
   Protocol : TCP
   ```

### Format des messages MCP

Le protocole MCP utilise JSON-RPC 2.0. Voici un exemple pour envoyer un message :

**Initialisation :**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "tools": {}
    },
    "clientInfo": {
      "name": "n8n",
      "version": "1.0.0"
    }
  }
}
```

**Appel d'outil :**
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "send_message",
    "arguments": {
      "recipient": "+33612345678",
      "message": "Bonjour depuis n8n !"
    }
  }
}
```

---

## Exemples de workflows

### Workflow 1 : Envoyer un message automatique

```
1. Trigger (Webhook, Schedule, etc.)
   ↓
2. HTTP Request
   - URL: http://whatsapp-bridge:8080/api/send
   - Method: POST
   - Body: {
       "recipient": "={{ $json.phone }}",
       "message": "={{ $json.message }}"
     }
   ↓
3. IF (vérifier le succès)
   ↓
4. Notification (optionnel)
```

**Exemple de body JSON dans n8n :**
```json
{
  "recipient": "={{ $json.body.phone }}",
  "message": "Bonjour {{ $json.body.name }} ! Votre commande est prête."
}
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
3. Filter (nouveaux messages depuis la dernière vérification)
   ↓
4. Traitement des messages
   ↓
5. Réponse automatique (optionnel)
   ↓
6. Set (mettre à jour lastCheck)
```

### Workflow 3 : Chatbot WhatsApp

```
1. Webhook (recevoir des événements)
   ↓
2. HTTP Request (GET /api/messages?chat_jid={{ $json.chat_jid }})
   ↓
3. AI/LLM Node (générer une réponse)
   ↓
4. HTTP Request (POST /api/send)
   - recipient: {{ $json.chat_jid }}
   - message: {{ $json.ai_response }}
```

---

## Outils disponibles

### Via API REST (http://whatsapp-bridge:8080/api)

| Endpoint | Méthode | Description | Paramètres |
|----------|---------|-------------|------------|
| `/send` | POST | Envoyer un message | `recipient`, `message` |
| `/health` | GET | Vérifier l'état du service | - |
| `/download` | POST | Télécharger un média | `message_id`, `chat_jid` |

**Note :** Pour lister les chats et messages, utilisez directement les fonctions MCP via le serveur Python (`whatsapp-mcp-server`).

### Via Protocole MCP (whatsapp-mcp-server:9000)

| Outil | Description |
|-------|-------------|
| `send_message` | Envoyer un message WhatsApp |
| `list_chats` | Lister les conversations |
| `list_messages` | Lister les messages avec filtres |
| `search_contacts` | Rechercher des contacts |
| `get_chat` | Obtenir les détails d'un chat |
| `send_file` | Envoyer un fichier |
| `send_audio_message` | Envoyer un message audio |
| `download_media` | Télécharger un média |

---

## Exemple complet : Workflow n8n JSON

Voici un exemple de workflow complet pour envoyer un message :

```json
{
  "name": "WhatsApp - Envoyer message",
  "nodes": [
    {
      "parameters": {},
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [250, 300],
      "webhookId": "whatsapp-send"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "http://whatsapp-bridge:8080/api/send",
        "options": {
          "headers": {
            "Content-Type": "application/json"
          }
        },
        "body": {
          "recipient": "={{ $json.phone }}",
          "message": "={{ $json.message }}"
        }
      },
      "name": "Envoyer message WhatsApp",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [450, 300]
    }
  ],
  "connections": {
    "Webhook": {
      "main": [[{"node": "Envoyer message WhatsApp", "type": "main", "index": 0}]]
    }
  }
}
```

---

## Dépannage

### Erreur : "Cannot connect to whatsapp-bridge"

**Solution :** Vérifiez que les services sont sur le même réseau Docker :
```bash
docker compose ps
```

### Erreur : "Connection refused"

**Solution :** Utilisez le nom du service Docker (`whatsapp-bridge`) au lieu de `localhost` dans n8n.

### Les messages ne sont pas envoyés

**Solution :** Vérifiez que WhatsApp est connecté :
```bash
docker compose logs whatsapp-bridge
```

### Format du numéro de téléphone

Le format attendu est :
- Avec indicatif : `+33612345678`
- Ou JID WhatsApp : `33612345678@s.whatsapp.net`

---

## Conseils

1. **Utilisez des variables d'environnement** dans n8n pour stocker l'URL de l'API
2. **Ajoutez une gestion d'erreurs** avec des nœuds IF pour vérifier les réponses
3. **Loggez les actions** pour le débogage
4. **Testez d'abord avec des numéros de test** avant de déployer en production

---

## Ressources supplémentaires

- **Dashboard WhatsApp** : http://localhost:8000/ui
- **API Bridge** : http://localhost:8081/api
- **Logs** : `docker compose logs -f whatsapp-bridge`

---

## Support

Pour plus d'aide :
1. Consultez les logs : `docker compose logs whatsapp-mcp-server`
2. Vérifiez le statut : `docker compose ps`
3. Testez l'API directement : `curl http://localhost:8081/api/chats`

