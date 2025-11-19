# Analyse du workflow n8n pour le serveur MCP WhatsApp

## ❌ Problèmes identifiés dans votre workflow

### 1. **URL du serveur MCP incorrecte**
```json
"value": "http://localhost:3000"
```
❌ **Problème** : 
- Port incorrect (3000 au lieu de 8000)
- Utilise `localhost` au lieu du nom du service Docker
- Depuis n8n dans Docker, `localhost` ne fonctionne pas

✅ **Correction** :
```json
"value": "http://whatsapp-mcp-server:8000/run_tool"
```

### 2. **Configuration MCP Client incorrecte**
```json
"endpointUrl": "<__PLACEHOLDER_VALUE__Path to your MCP WhatsApp server executable or command__>",
"serverTransport": "stdio"
```
❌ **Problèmes** :
- `endpointUrl` est un placeholder
- `serverTransport: "stdio"` ne fonctionne pas avec notre serveur
- Notre serveur expose HTTP Streamable, pas stdio

✅ **Correction** :
```json
"connection": {
  "endpoint": "http://whatsapp-mcp-server:8000/run_tool",
  "serverTransport": "http-streamable",
  "authentication": "none"
}
```

### 3. **Structure des paramètres**
Le nœud MCP Client doit utiliser la structure `connection` et non `endpointUrl` directement.

## ✅ Workflow corrigé

J'ai créé un fichier `workflow-mcp-corrige.json` avec toutes les corrections nécessaires.

## 📋 Corrections à appliquer

### Correction 1 : Workflow Configuration - MCP

**Avant :**
```json
{
  "name": "mcpServerUrl",
  "value": "http://localhost:3000"
}
```

**Après :**
```json
{
  "name": "mcpServerUrl",
  "value": "http://whatsapp-mcp-server:8000/run_tool"
}
```

### Correction 2 : MCP WhatsApp Server

**Avant :**
```json
{
  "parameters": {
    "endpointUrl": "<__PLACEHOLDER_VALUE__...>",
    "serverTransport": "stdio",
    "options": {}
  }
}
```

**Après :**
```json
{
  "parameters": {
    "connection": {
      "endpoint": "http://whatsapp-mcp-server:8000/run_tool",
      "serverTransport": "http-streamable",
      "authentication": "none"
    },
    "options": {}
  }
}
```

### Correction 3 : System Message (optionnel)

**Avant :**
```json
"Phone: {{ $json.from }}"
```

**Après :**
```json
"Phone: {{ $json.from || $json.body.from }}"
```
(Pour gérer différents formats de données webhook)

## 🚀 Comment utiliser le workflow corrigé

### Option 1 : Importer le workflow corrigé

1. **Dans n8n**, allez dans **Workflows**
2. **Cliquez sur "Import from File"**
3. **Sélectionnez** `workflow-mcp-corrige.json`
4. **Vérifiez** que tous les nœuds sont correctement connectés

### Option 2 : Corriger manuellement

1. **Ouvrez votre workflow** dans n8n
2. **Cliquez sur "Workflow Configuration - MCP"**
   - Changez `http://localhost:3000` → `http://whatsapp-mcp-server:8000/run_tool`
3. **Cliquez sur "MCP WhatsApp Server"**
   - Remplacez `endpointUrl` par la structure `connection` ci-dessus
   - Changez `serverTransport` de `stdio` à `http-streamable`
   - Définissez `authentication` à `none`

## 🔍 Vérification

### 1. Vérifier que le serveur MCP est actif
```bash
docker compose ps whatsapp-mcp-server
docker compose logs whatsapp-mcp-server | grep "Dashboard server"
```

### 2. Tester la connexion depuis n8n
1. **Activez le workflow**
2. **Déclenchez le webhook** avec un message de test
3. **Vérifiez les logs** :
   ```bash
   docker compose logs whatsapp-mcp-server | tail -20
   ```

### 3. Vérifier les outils disponibles
Dans le nœud "MCP WhatsApp Server", vous devriez voir les outils disponibles :
- `send_message`
- `list_chats`
- `list_messages`
- `search_contacts`
- `get_chat`
- `send_file`
- etc.

## ⚠️ Points importants

1. **Nom du service Docker** : Utilisez toujours `whatsapp-mcp-server` (pas `localhost`)
2. **Port** : Utilisez `8000` pour HTTP Streamable (pas `9000` qui est pour TCP)
3. **Transport** : Utilisez `http-streamable` (pas `stdio`)
4. **Authentification** : `none` pour l'instant

## 📚 Documentation complémentaire

- `GUIDE_MCP_CLIENT_NATIF.md` - Guide complet pour le nœud MCP Client
- `CONFIGURATION_RAPIDE_MCP.md` - Configuration rapide en 3 étapes
- `GUIDE_CONFIGURER_MCP_NODES.md` - Guide détaillé de configuration

## ✅ Résumé

Votre workflow est **presque bon**, mais nécessite ces corrections :
1. ✅ URL du serveur : `http://whatsapp-mcp-server:8000/run_tool`
2. ✅ Transport : `http-streamable` (pas `stdio`)
3. ✅ Structure : Utiliser `connection` au lieu de `endpointUrl`

Une fois ces corrections appliquées, votre workflow devrait fonctionner parfaitement avec le serveur MCP WhatsApp !


