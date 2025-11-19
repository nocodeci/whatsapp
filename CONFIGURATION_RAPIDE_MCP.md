# Configuration rapide : MCP Client dans n8n

## ⚡ Configuration en 3 étapes

### 1. Endpoint
```
http://whatsapp-mcp-server:8000/run_tool
```

### 2. Server Transport
```
HTTP Streamable
```
(C'est l'option par défaut)

### 3. Authentication
```
None
```
(Si "None" n'est pas disponible, utilisez "Bearer Auth" et laissez le credential vide)

## ✅ Configuration complète

Dans le nœud **MCP Client** :

| Champ | Valeur |
|-------|--------|
| **Endpoint** | `http://whatsapp-mcp-server:8000/run_tool` |
| **Server Transport** | `HTTP Streamable` |
| **Authentication** | `None` |
| **Credential for Bearer Auth** | (Laissez vide si Authentication = None) |
| **Tools to Include** | `All` (ou sélectionnez des outils spécifiques) |

## 🎯 Utilisation

Une fois configuré, vous pouvez utiliser tous les outils MCP dans votre workflow :

- `send_message` - Envoyer un message
- `list_chats` - Lister les conversations  
- `list_messages` - Lister les messages
- `search_contacts` - Rechercher des contacts
- Et tous les autres outils disponibles

## ⚠️ Important

- Utilisez **`whatsapp-mcp-server`** (nom du service Docker) et non `localhost`
- Le port est **8000** (interface HTTP du serveur MCP)
- Pas besoin d'authentification pour l'instant

## 🔍 Vérification

Vérifiez que le serveur est actif :
```bash
docker compose logs whatsapp-mcp-server | grep "Dashboard server"
```

Vous devriez voir :
```
Dashboard server running on http://0.0.0.0:8000/ui
```

## 📚 Guide complet

Pour plus de détails, consultez : `GUIDE_CONFIGURER_MCP_NODES.md`

