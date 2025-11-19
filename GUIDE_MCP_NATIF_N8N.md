# Guide : Utiliser le serveur MCP WhatsApp natif dans n8n

Ce guide explique comment configurer et utiliser le serveur MCP WhatsApp directement dans n8n via le protocole MCP natif.

## 📋 Table des matières

1. [Prérequis](#prérequis)
2. [Configuration dans n8n](#configuration-dans-n8n)
3. [Utiliser les outils MCP dans vos workflows](#utiliser-les-outils-mcp-dans-vos-workflows)
4. [Exemples de workflows](#exemples-de-workflows)
5. [Dépannage](#dépannage)

---

## Prérequis

1. **n8n version 1.0.0 ou supérieure** (avec support MCP natif)
2. **Serveur MCP WhatsApp opérationnel** sur le port 9000
3. **Services Docker en cours d'exécution**

### Vérification rapide

Testez la connexion MCP avec le script fourni :
```bash
./test-mcp-connection.sh
```

Ou manuellement :
```bash
docker compose ps whatsapp-mcp-server
docker compose logs whatsapp-mcp-server | grep "MCP STDIO-TCP bridge"
```

---

## Configuration dans n8n

> ⚠️ **Note importante** : Le support MCP natif dans n8n est disponible à partir de la version 1.120.0 environ. Si vous ne voyez pas l'option MCP dans les paramètres (version 1.118.2 ou antérieure), utilisez la **méthode HTTP alternative** décrite dans `GUIDE_MCP_N8N_HTTP.md`.

### Étape 1 : Activer l'accès MCP dans n8n

1. **Accédez à n8n** : http://localhost:5678
   - Utilisateur : `admin`
   - Mot de passe : `admin`

2. **Allez dans les Paramètres** (icône ⚙️ en bas à gauche)

3. **Trouvez la section "MCP" ou "Model Context Protocol"**
   - Si cette option n'existe pas, votre version de n8n ne supporte pas encore MCP natif
   - Utilisez alors `GUIDE_MCP_N8N_HTTP.md` pour la méthode HTTP

4. **Activez l'accès MCP** si ce n'est pas déjà fait

### Étape 2 : Ajouter le serveur MCP WhatsApp

1. **Dans les paramètres MCP**, cliquez sur **"Add MCP Server"** ou **"Ajouter un serveur MCP"**

2. **Configurez la connexion :**

   ```
   Nom : WhatsApp MCP Server
   Type : TCP
   Host : whatsapp-mcp-server
   Port : 9000
   Protocol : MCP (JSON-RPC 2.0)
   ```

3. **Sauvegardez la configuration**

### Étape 3 : Vérifier la connexion

1. **Testez la connexion** depuis n8n
2. **Vérifiez les logs** :
   ```bash
   docker compose logs whatsapp-mcp-server | grep "MCP client connected"
   ```

---

## Utiliser les outils MCP dans vos workflows

Une fois le serveur MCP configuré, vous pouvez utiliser les outils MCP directement dans vos workflows n8n.

### Méthode 1 : Nœud MCP Client (si disponible)

1. **Ajoutez un nœud "MCP Client"** ou **"MCP Tool"** dans votre workflow

2. **Sélectionnez le serveur** : "WhatsApp MCP Server"

3. **Choisissez l'outil** parmi :
   - `send_message`
   - `list_chats`
   - `list_messages`
   - `search_contacts`
   - `get_chat`
   - `send_file`
   - etc.

4. **Configurez les paramètres** de l'outil

### Méthode 2 : Nœud Code/Function (Alternative)

Si le nœud MCP natif n'est pas disponible, vous pouvez utiliser un nœud **Code** ou **Function** pour appeler le serveur MCP directement.

#### Exemple : Envoyer un message

```javascript
// Dans un nœud Code/Function
const mcpClient = {
  host: 'whatsapp-mcp-server',
  port: 9000
};

// Initialiser la connexion MCP
const initRequest = {
  jsonrpc: "2.0",
  id: 1,
  method: "initialize",
  params: {
    protocolVersion: "2024-11-05",
    capabilities: {
      tools: {}
    },
    clientInfo: {
      name: "n8n",
      version: "1.0.0"
    }
  }
};

// Appeler l'outil send_message
const toolRequest = {
  jsonrpc: "2.0",
  id: 2,
  method: "tools/call",
  params: {
    name: "send_message",
    arguments: {
      recipient: $input.item.json.phone,
      message: $input.item.json.message
    }
  }
};

return toolRequest;
```

### Méthode 3 : Nœud HTTP Request avec wrapper MCP

Créez un workflow qui encapsule les appels MCP dans des requêtes HTTP.

---

## Exemples de workflows

### Workflow 1 : Envoyer un message via MCP

```
1. Trigger (Webhook/Schedule)
   ↓
2. MCP Client Node
   - Server: WhatsApp MCP Server
   - Tool: send_message
   - Parameters:
     * recipient: {{ $json.phone }}
     * message: {{ $json.message }}
   ↓
3. IF (vérifier le succès)
   ↓
4. Notification
```

### Workflow 2 : Surveiller les nouveaux messages

```
1. Schedule (toutes les 5 minutes)
   ↓
2. MCP Client Node
   - Server: WhatsApp MCP Server
   - Tool: list_messages
   - Parameters:
     * limit: 10
     * after: {{ $workflow.staticData.lastCheck }}
   ↓
3. Filter (nouveaux messages)
   ↓
4. Traitement des messages
   ↓
5. Set (mettre à jour lastCheck)
```

### Workflow 3 : Chatbot WhatsApp avec MCP

```
1. Webhook (recevoir événements)
   ↓
2. MCP Client Node
   - Tool: list_messages
   - Parameters:
     * chat_jid: {{ $json.chat_jid }}
     * limit: 1
   ↓
3. AI/LLM Node (générer réponse)
   ↓
4. MCP Client Node
   - Tool: send_message
   - Parameters:
     * recipient: {{ $json.chat_jid }}
     * message: {{ $json.ai_response }}
```

---

## Outils MCP disponibles

### Communication

| Outil | Description | Paramètres |
|-------|-------------|------------|
| `send_message` | Envoyer un message WhatsApp | `recipient`, `message` |
| `send_file` | Envoyer un fichier | `recipient`, `file_path`, `file_type` |
| `send_audio_message` | Envoyer un message audio | `recipient`, `audio_path` |

### Recherche et consultation

| Outil | Description | Paramètres |
|-------|-------------|------------|
| `list_chats` | Lister les conversations | `limit`, `page`, `query`, `include_last_message` |
| `list_messages` | Lister les messages | `chat_jid`, `limit`, `query`, `after`, `before` |
| `search_contacts` | Rechercher des contacts | `query` |
| `get_chat` | Obtenir les détails d'un chat | `chat_jid` |
| `get_direct_chat_by_contact` | Trouver un chat direct | `phone_number` |
| `get_contact_chats` | Lister les chats d'un contact | `phone_number` |
| `get_last_interaction` | Dernière interaction | `phone_number` |
| `get_message_context` | Contexte d'un message | `message_id`, `before`, `after` |

### Médias

| Outil | Description | Paramètres |
|-------|-------------|------------|
| `download_media` | Télécharger un média | `message_id`, `chat_jid` |

---

## Format des messages MCP

Le protocole MCP utilise **JSON-RPC 2.0**. Voici les formats standards :

### Initialisation

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

### Notification d'initialisation

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized"
}
```

### Appel d'outil

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

### Lister les outils disponibles

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/list"
}
```

---

## Dépannage

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

3. Les services sont-ils sur le même réseau Docker ?
   ```bash
   docker network inspect whatsapp-mcp-n8n_internal
   ```

**Solution :** Utilisez le nom du service Docker (`whatsapp-mcp-server`) et non `localhost`.

### Erreur : "Protocol version mismatch"

**Solution :** Assurez-vous d'utiliser le protocole version `2024-11-05` dans votre requête d'initialisation.

### Erreur : "Tool not found"

**Vérifications :**
1. Liste les outils disponibles :
   ```json
   {
     "jsonrpc": "2.0",
     "id": 1,
     "method": "tools/list"
   }
   ```

2. Vérifiez l'orthographe du nom de l'outil

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

### Tester la connexion MCP manuellement

```bash
# Depuis le conteneur n8n ou un autre conteneur sur le même réseau
docker compose exec n8n sh -c "echo '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2024-11-05\",\"capabilities\":{},\"clientInfo\":{\"name\":\"test\",\"version\":\"1.0.0\"}}}' | nc whatsapp-mcp-server 9000"
```

---

## Configuration avancée

### Variables d'environnement n8n

Vous pouvez configurer l'URL du serveur MCP via des variables d'environnement :

```yaml
# Dans docker-compose.yml
environment:
  - N8N_MCP_WHATSAPP_HOST=whatsapp-mcp-server
  - N8N_MCP_WHATSAPP_PORT=9000
```

### Connexion persistante

Pour améliorer les performances, configurez n8n pour maintenir une connexion persistante au serveur MCP.

### Sécurité

Si vous exposez n8n publiquement, considérez :
- Ajouter une authentification au serveur MCP
- Utiliser TLS pour les connexions MCP
- Restreindre l'accès au réseau Docker

---

## Ressources supplémentaires

- **Documentation MCP** : https://modelcontextprotocol.io
- **Documentation n8n MCP** : https://docs.n8n.io/integrations/mcp/
- **Logs du serveur MCP** : `docker compose logs -f whatsapp-mcp-server`
- **Dashboard WhatsApp** : http://localhost:8000/ui

---

## Support

Pour plus d'aide :
1. Consultez les logs : `docker compose logs whatsapp-mcp-server`
2. Vérifiez le statut : `docker compose ps`
3. Testez la connexion TCP : `nc whatsapp-mcp-server 9000`

