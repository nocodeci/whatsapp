# Guide : Configurer les nœuds MCP natifs dans n8n

Ce guide explique comment configurer les nœuds MCP natifs de n8n (`@n8n/n8n-nodes-langchain.mcpTrigger` et `@n8n/n8n-nodes-langchain.mcpClientTool`) pour utiliser le serveur MCP WhatsApp.

## 📋 Vue d'ensemble

n8n dispose de nœuds MCP natifs qui permettent d'utiliser directement le protocole MCP. Vous avez déjà :
- **MCP Server Trigger** : Pour recevoir des événements depuis le serveur MCP
- **MCP Client** : Pour appeler les outils MCP

## 🚀 Configuration du serveur MCP

### Étape 1 : Vérifier que le serveur MCP est actif

```bash
docker compose ps whatsapp-mcp-server
docker compose logs whatsapp-mcp-server | grep "MCP STDIO-TCP bridge"
```

Vous devriez voir :
```
MCP STDIO-TCP bridge running on 0.0.0.0:9000
```

### Étape 2 : Configurer le nœud MCP Client

1. **Cliquez sur le nœud "MCP Client"** dans votre workflow

2. **Configurez l'Endpoint :**
   ```
   Endpoint : http://whatsapp-mcp-server:8000/run_tool
   ```
   ⚠️ **Important** : Utilisez le nom du service Docker (`whatsapp-mcp-server`) et non `localhost`

3. **Configurez le Server Transport :**
   ```
   Server Transport : HTTP Streamable
   ```
   (C'est l'option par défaut dans n8n)

4. **Configurez l'Authentication :**
   ```
   Authentication : None
   ```
   (Le serveur MCP WhatsApp n'utilise pas d'authentification par défaut)
   
   Si "None" n'est pas disponible, vous pouvez utiliser "Bearer Auth" et laisser le champ credential vide, ou créer une credential vide.

5. **Configurez Tools to Include :**
   ```
   Tools to Include : All
   ```
   Ou sélectionnez des outils spécifiques si vous préférez

6. **Les outils MCP disponibles incluent :**
   - `send_message` - Envoyer un message WhatsApp
   - `list_chats` - Lister les conversations
   - `list_messages` - Lister les messages
   - `search_contacts` - Rechercher des contacts
   - `get_chat` - Obtenir les détails d'un chat
   - `send_file` - Envoyer un fichier
   - `send_audio_message` - Envoyer un message audio
   - `download_media` - Télécharger un média
   - Et tous les autres outils disponibles

## 📝 Exemples de configuration

### Exemple 1 : Envoyer un message avec MCP Client

**Configuration du nœud MCP Client :**

1. **Endpoint** :
   ```
   http://whatsapp-mcp-server:8000/run_tool
   ```

2. **Server Transport** : `HTTP Streamable`

3. **Authentication** : `None`

4. **Tools to Include** : `All` (ou sélectionnez `send_message` spécifiquement)

5. **Dans le workflow, utilisez l'outil `send_message` avec les paramètres :**
   ```json
   {
     "recipient": "={{ $json.phone }}",
     "message": "={{ $json.message }}"
   }
   ```

### Exemple 2 : Lister les chats

**Configuration du nœud MCP Client :**

1. **Endpoint** : `http://whatsapp-mcp-server:8000/run_tool`
2. **Server Transport** : `HTTP Streamable`
3. **Authentication** : `None`
4. **Tools to Include** : `All` ou `list_chats`

**Utilisez l'outil `list_chats` avec les paramètres :**
```json
{
  "limit": 10,
  "include_last_message": true
}
```

### Exemple 3 : Lister les messages d'un chat

**Configuration du nœud MCP Client :**

1. **Endpoint** : `http://whatsapp-mcp-server:8000/run_tool`
2. **Server Transport** : `HTTP Streamable`
3. **Authentication** : `None`
4. **Tools to Include** : `All` ou `list_messages`

**Utilisez l'outil `list_messages` avec les paramètres :**
```json
{
  "chat_jid": "={{ $json.chat_jid }}",
  "limit": 20
}
```

## 🔧 Configuration du MCP Server Trigger

Le nœud **MCP Server Trigger** permet de recevoir des événements depuis le serveur MCP. Pour le configurer :

1. **Cliquez sur le nœud "MCP Server Trigger"**

2. **Configurez la connexion au serveur MCP :**
   ```
   Connection Type : TCP Socket
   Host : whatsapp-mcp-server
   Port : 9000
   ```

3. **Sélectionnez les outils à exposer** (si applicable)

4. **Le trigger sera activé** quand le serveur MCP enverra des événements

## 🎯 Workflow complet : Envoyer un message

```
1. Trigger (Webhook/Schedule/Manual)
   ↓
2. MCP Client
   - Connection: whatsapp-mcp-server:9000 (TCP)
   - Tool: send_message
   - Parameters:
     * recipient: ={{ $json.phone }}
     * message: ={{ $json.message }}
   ↓
3. IF (vérifier le succès)
   ↓
4. Notification/Response
```

## 📚 Tous les outils MCP disponibles

### Communication

| Outil | Paramètres | Description |
|-------|------------|-------------|
| `send_message` | `recipient`, `message` | Envoyer un message WhatsApp |
| `send_file` | `recipient`, `file_path`, `file_type` | Envoyer un fichier (image, vidéo, document) |
| `send_audio_message` | `recipient`, `audio_path` | Envoyer un message audio (voix) |

### Recherche et consultation

| Outil | Paramètres | Description |
|-------|------------|-------------|
| `list_chats` | `limit`, `page`, `query`, `include_last_message` | Lister les conversations |
| `list_messages` | `chat_jid`, `limit`, `query`, `after`, `before` | Lister les messages avec filtres |
| `search_contacts` | `query` | Rechercher des contacts par nom ou numéro |
| `get_chat` | `chat_jid` | Obtenir les détails d'un chat spécifique |
| `get_direct_chat_by_contact` | `phone_number` | Trouver un chat direct avec un contact |
| `get_contact_chats` | `phone_number` | Lister tous les chats d'un contact |
| `get_last_interaction` | `phone_number` | Obtenir la dernière interaction avec un contact |
| `get_message_context` | `message_id`, `before`, `after` | Obtenir le contexte autour d'un message |

### Médias

| Outil | Paramètres | Description |
|-------|------------|-------------|
| `download_media` | `message_id`, `chat_jid` | Télécharger un média depuis un message |

## ⚙️ Configuration avancée

### Créer une connexion réutilisable

Pour simplifier la configuration, vous pouvez créer une credential MCP :

1. **Allez dans Credentials** (dans les paramètres n8n)

2. **Créez une nouvelle credential de type "MCP"**

3. **Configurez :**
   ```
   Name : WhatsApp MCP Server
   Endpoint : http://whatsapp-mcp-server:8000/run_tool
   Server Transport : HTTP Streamable
   Authentication : None
   ```

4. **Utilisez cette credential** dans vos nœuds MCP Client en sélectionnant "Credential for Bearer Auth" (même si vous utilisez "None" pour l'authentification)

### Variables d'environnement

Vous pouvez aussi utiliser des variables d'environnement dans n8n :

```yaml
# Dans docker-compose.yml pour n8n
environment:
  - N8N_MCP_WHATSAPP_HOST=whatsapp-mcp-server
  - N8N_MCP_WHATSAPP_PORT=9000
```

Puis dans les nœuds, utilisez :
```
Host : {{ $env.N8N_MCP_WHATSAPP_HOST }}
Port : {{ $env.N8N_MCP_WHATSAPP_PORT }}
```

## 🔍 Dépannage

### Erreur : "Cannot connect to MCP server"

**Vérifications :**
1. Le serveur MCP est-il en cours d'exécution ?
   ```bash
   docker compose ps whatsapp-mcp-server
   ```

2. Le port 9000 est-il accessible ?
   ```bash
   docker compose logs whatsapp-mcp-server | grep "running on"
   ```

3. Utilisez le nom du service Docker (`whatsapp-mcp-server`) et non `localhost`

**Solution :** Vérifiez que n8n et whatsapp-mcp-server sont sur le même réseau Docker :
```bash
docker network inspect whatsapp-mcp-n8n_internal
```

### Erreur : "Tool not found"

**Solution :** Vérifiez que le nom de l'outil est correct. Liste des outils disponibles :
- `send_message`
- `list_chats`
- `list_messages`
- `search_contacts`
- etc.

### Erreur : "Protocol version mismatch"

**Solution :** Assurez-vous que le protocole est bien configuré comme "MCP" ou "JSON-RPC 2.0" dans la connexion.

### Les outils ne répondent pas

**Vérifications :**
1. Le bridge WhatsApp est-il connecté ?
   ```bash
   docker compose logs whatsapp-bridge | grep "Connected"
   ```

2. WhatsApp est-il authentifié ?
   ```bash
   docker compose logs whatsapp-bridge | grep "QR code"
   ```

### Tester la connexion manuellement

```bash
# Depuis le conteneur n8n
docker compose exec n8n sh -c "echo '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2024-11-05\",\"capabilities\":{},\"clientInfo\":{\"name\":\"n8n\",\"version\":\"1.0.0\"}}}' | nc whatsapp-mcp-server 9000"
```

## 📖 Exemple de workflow JSON

Voici un exemple de workflow complet avec les nœuds MCP :

```json
{
  "name": "WhatsApp MCP - Envoyer message",
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
      "position": [250, 300]
    },
    {
      "parameters": {
        "connection": {
          "type": "tcp",
          "host": "whatsapp-mcp-server",
          "port": 9000
        },
        "tool": "send_message",
        "arguments": {
          "recipient": "={{ $json.body.phone }}",
          "message": "={{ $json.body.message }}"
        }
      },
      "name": "MCP Client - Send Message",
      "type": "@n8n/n8n-nodes-langchain.mcpClientTool",
      "typeVersion": 1.2,
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
      "main": [[{"node": "MCP Client - Send Message", "type": "main", "index": 0}]]
    },
    "MCP Client - Send Message": {
      "main": [[{"node": "Répondre", "type": "main", "index": 0}]]
    }
  }
}
```

## ✅ Avantages des nœuds MCP natifs

- ✅ Intégration native avec n8n
- ✅ Pas besoin de gérer le protocole JSON-RPC manuellement
- ✅ Interface utilisateur intuitive
- ✅ Validation automatique des paramètres
- ✅ Meilleure gestion des erreurs
- ✅ Support des types de données complexes

## 📚 Ressources supplémentaires

- **Logs du serveur MCP** : `docker compose logs -f whatsapp-mcp-server`
- **Dashboard WhatsApp** : http://localhost:8000/ui
- **Documentation n8n MCP** : https://docs.n8n.io/integrations/mcp/

---

## 🎯 Prochaines étapes

1. ✅ Configurez la connexion TCP dans le nœud MCP Client
2. ✅ Sélectionnez l'outil que vous voulez utiliser
3. ✅ Configurez les paramètres de l'outil
4. ✅ Testez le workflow
5. ✅ Créez des workflows plus complexes avec plusieurs outils MCP

Bon workflow ! 🚀

