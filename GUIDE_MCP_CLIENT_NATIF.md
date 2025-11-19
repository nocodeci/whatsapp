# Guide : Utiliser le nœud MCP Client natif pour WhatsApp

Ce guide explique comment configurer le nœud **MCP Client** natif (`@n8n/n8n-nodes-langchain.mcpClientTool`) pour utiliser le serveur MCP WhatsApp.

## ✅ Oui, vous pouvez utiliser le nœud MCP Client !

Le nœud MCP Client natif est **parfait** pour remplacer WhatsApp Business Cloud. C'est même la méthode recommandée si disponible dans votre version de n8n.

## 🚀 Configuration du nœud MCP Client

### Étape 1 : Ajouter le nœud

1. **Ajoutez un nœud "MCP Client"** dans votre workflow
2. **Remplacez** le nœud "WhatsApp Business Cloud" par ce nœud

### Étape 2 : Configurer la connexion

Dans les paramètres du nœud MCP Client :

#### Connection

**Endpoint :**
```
http://whatsapp-mcp-server:8000/run_tool
```
⚠️ **Important** : Utilisez le nom du service Docker (`whatsapp-mcp-server`), pas `localhost`

**Server Transport :**
```
HTTP Streamable
```
(C'est l'option par défaut)

**Authentication :**
```
None
```
(Le serveur MCP WhatsApp n'utilise pas d'authentification par défaut)

#### Tool

**Tool to Use :**
```
send_message
```

#### Arguments

**recipient :**
```
={{ $json.recipientPhoneNumber || $json.recipient || '+33612345678' }}
```

**message :**
```
={{ $json.text || $json.textBody || $json.message }}
```

## 📝 Configuration complète pour votre workflow

Dans votre workflow spécifique, où "Attendee Research Agent" génère `$json.text`, configurez ainsi :

### Configuration du nœud MCP Client

```
Connection:
  Endpoint: http://whatsapp-mcp-server:8000/run_tool
  Server Transport: HTTP Streamable
  Authentication: None

Tool:
  send_message

Arguments:
  recipient: ={{ $json.recipientPhoneNumber || '+33612345678' }}
  message: ={{ $json.text }}
```

## 🎯 Exemple complet dans votre workflow

Remplacez le nœud "WhatsApp Business Cloud" par :

```json
{
  "parameters": {
    "connection": {
      "endpoint": "http://whatsapp-mcp-server:8000/run_tool",
      "serverTransport": "http-streamable",
      "authentication": "none"
    },
    "tool": "send_message",
    "arguments": {
      "recipient": "={{ $json.recipientPhoneNumber || '+33612345678' }}",
      "message": "={{ $json.text }}"
    },
    "options": {}
  },
  "type": "@n8n/n8n-nodes-langchain.mcpClientTool",
  "typeVersion": 1.2,
  "name": "WhatsApp MCP - Send Message",
  "position": [4016, 464]
}
```

## 🔧 Configuration avancée

### Si vous voulez extraire le numéro depuis le meeting

```json
{
  "arguments": {
    "recipient": "={{ $('Check For Upcoming Meetings').item.json.organizer.email.split('@')[0] || '+33612345678' }}",
    "message": "={{ $json.text }}"
  }
}
```

### Si vous avez plusieurs destinataires

Vous pouvez utiliser un nœud "Split In Batches" ou "Loop Over Items" avant le nœud MCP Client pour envoyer à plusieurs destinataires.

## 📋 Tous les outils disponibles

Le nœud MCP Client peut utiliser tous les outils MCP :

| Outil | Arguments | Description |
|-------|-----------|-------------|
| `send_message` | `recipient`, `message` | Envoyer un message |
| `list_chats` | `limit`, `page`, `query` | Lister les conversations |
| `list_messages` | `chat_jid`, `limit`, `query` | Lister les messages |
| `search_contacts` | `query` | Rechercher des contacts |
| `get_chat` | `chat_jid` | Obtenir les détails d'un chat |
| `send_file` | `recipient`, `file_path`, `file_type` | Envoyer un fichier |
| `send_audio_message` | `recipient`, `audio_path` | Envoyer un message audio |
| `download_media` | `message_id`, `chat_jid` | Télécharger un média |

## ⚠️ Points importants

### 1. Endpoint
- ✅ Utilisez : `http://whatsapp-mcp-server:8000/run_tool`
- ❌ N'utilisez pas : `http://localhost:8000/run_tool` (ne fonctionnera pas depuis n8n)

### 2. Format du numéro
- ✅ Format correct : `+33612345678` (avec indicatif)
- ✅ Format JID : `33612345678@s.whatsapp.net`
- ❌ Format incorrect : `33612345678` (sans indicatif)

### 3. Variables d'expression
Utilisez les expressions n8n pour extraire les données :
- `={{ $json.text }}` - Pour le message
- `={{ $json.recipientPhoneNumber }}` - Pour le destinataire
- `={{ $('Node Name').item.json.field }}` - Pour accéder à d'autres nœuds

## 🔍 Dépannage

### Erreur : "Cannot connect to MCP server"

**Vérifications :**
1. Le serveur MCP est-il actif ?
   ```bash
   docker compose ps whatsapp-mcp-server
   ```

2. L'endpoint est-il correct ?
   - Utilisez `whatsapp-mcp-server` (nom du service Docker)
   - Pas `localhost`

3. Le port 8000 est-il accessible ?
   ```bash
   docker compose logs whatsapp-mcp-server | grep "Dashboard server"
   ```

### Erreur : "Tool not found"

**Solution :** Vérifiez que le nom de l'outil est exactement `send_message` (avec underscore, pas de tiret).

### Erreur : "Invalid recipient"

**Solution :** Assurez-vous que le numéro est au format :
- `+33612345678` (avec indicatif)
- Ou `33612345678@s.whatsapp.net` (JID complet)

### Le message n'est pas envoyé

**Vérifications :**
1. WhatsApp est-il connecté ?
   ```bash
   docker compose logs whatsapp-bridge | grep "Connected"
   ```

2. Le numéro de téléphone est-il correct ?
3. Le message n'est pas vide ?

## ✅ Avantages du nœud MCP Client

- ✅ Interface native n8n
- ✅ Validation automatique des paramètres
- ✅ Meilleure gestion des erreurs
- ✅ Support des types de données complexes
- ✅ Plus facile à déboguer
- ✅ Intégration avec les autres nœuds LangChain

## 📚 Comparaison : HTTP Request vs MCP Client

| Aspect | HTTP Request | MCP Client |
|--------|-------------|------------|
| **Simplicité** | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Validation** | Manuelle | Automatique |
| **Gestion erreurs** | Basique | Avancée |
| **Intégration LangChain** | ❌ | ✅ |
| **Disponibilité** | Toutes versions | n8n 1.118+ |

## 🎯 Recommandation

**Utilisez le nœud MCP Client** si disponible dans votre version de n8n. C'est la méthode la plus élégante et la mieux intégrée.

Si le nœud MCP Client n'est pas disponible ou ne fonctionne pas, utilisez le nœud HTTP Request comme solution de secours (voir `GUIDE_REMPLACER_WHATSAPP.md`).

---

## 📖 Ressources supplémentaires

- **Guide configuration MCP** : `GUIDE_CONFIGURER_MCP_NODES.md`
- **Guide remplacement HTTP** : `GUIDE_REMPLACER_WHATSAPP.md`
- **Exemple workflow** : `workflow-mcp-client-config.json`
- **Logs du serveur** : `docker compose logs -f whatsapp-mcp-server`

