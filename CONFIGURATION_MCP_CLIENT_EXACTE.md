# Configuration Exacte du Nœud MCP Client dans n8n

## 📋 Configuration Complète

Voici la configuration exacte pour le nœud **MCP Client** dans n8n pour votre serveur WhatsApp MCP :

### ✅ Configuration Recommandée

```
Endpoint: http://whatsapp-mcp-server:8000/run_tool

Server Transport: HTTP Streamable

Authentication: None

Tools to Include: All

Options: (Laissez par défaut)
```

## 🔍 Détails de Chaque Champ

### 1. **Endpoint**

**Valeur à mettre** :
```
http://whatsapp-mcp-server:8000/run_tool
```

**Explication** :
- `whatsapp-mcp-server` : Nom du service Docker (pas `localhost` !)
- `8000` : Port du serveur HTTP MCP
- `/run_tool` : Endpoint pour exécuter les outils MCP

⚠️ **Important** :
- Utilisez le **nom du service Docker** (`whatsapp-mcp-server`), pas `localhost`
- Si vous êtes **hors Docker**, utilisez : `http://localhost:8000/run_tool`
- Le port `8000` est celui du serveur HTTP (pas `9000` qui est pour TCP)

### 2. **Server Transport**

**Valeur à mettre** :
```
HTTP Streamable
```

**Explication** :
- C'est l'option par défaut dans n8n
- Permet la communication HTTP avec le serveur MCP
- Supporte les requêtes asynchrones

### 3. **Authentication**

**Valeur à mettre** :
```
None
```

**Explication** :
- Votre serveur MCP WhatsApp n'utilise pas d'authentification par défaut
- Si "None" n'est pas disponible, utilisez "Bearer Auth" et laissez le credential vide

### 4. **Tools to Include**

**Valeur à mettre** :
```
All
```

**Explication** :
- Inclut tous les outils MCP disponibles
- Vous pouvez aussi sélectionner des outils spécifiques si vous préférez :
  - `send_message`
  - `list_chats`
  - `list_messages`
  - `search_contacts`
  - `get_chat`
  - etc.

### 5. **Options**

**Valeur à mettre** :
```
(Laissez par défaut - aucune option supplémentaire)
```

## 📝 Configuration Visuelle

Dans l'interface n8n, vous devriez voir :

```
┌─────────────────────────────────────────┐
│ MCP Client                               │
├─────────────────────────────────────────┤
│ Connection                               │
│   Endpoint:                              │
│   [http://whatsapp-mcp-server:8000/run_tool]
│                                          │
│   Server Transport:                      │
│   [HTTP Streamable          ▼]          │
│                                          │
│   Authentication:                        │
│   [None                    ▼]           │
│                                          │
│ Tool                                     │
│   Tools to Include:                      │
│   [All                      ▼]          │
│                                          │
│ Options                                  │
│   (Par défaut)                           │
└─────────────────────────────────────────┘
```

## 🔧 Vérification

### 1. Vérifier que le serveur est actif

```bash
docker compose ps whatsapp-mcp-server
```

Vous devriez voir le service en cours d'exécution.

### 2. Tester la connexion

Dans n8n, après avoir configuré le nœud :
1. **Cliquez sur "Test"** ou **"Execute Node"**
2. **Vérifiez les outils disponibles** dans la sortie
3. **Vous devriez voir** la liste des outils MCP disponibles

### 3. Vérifier les logs

```bash
docker compose logs whatsapp-mcp-server | tail -20
```

Vous devriez voir des requêtes entrantes.

## ⚠️ Erreurs Courantes

### Erreur : "Connection refused"

**Cause** : Mauvaise URL ou service non démarré

**Solution** :
- Vérifiez que vous utilisez `whatsapp-mcp-server` (pas `localhost`)
- Vérifiez que le service est démarré : `docker compose ps`
- Vérifiez le port : `8000` (pas `9000`)

### Erreur : "404 Not Found"

**Cause** : Endpoint incorrect

**Solution** :
- Vérifiez que l'endpoint est : `http://whatsapp-mcp-server:8000/run_tool`
- Vérifiez que le chemin `/run_tool` est correct

### Erreur : "No tools available"

**Cause** : Serveur MCP non configuré correctement

**Solution** :
- Vérifiez les logs : `docker compose logs whatsapp-mcp-server`
- Vérifiez que le serveur expose bien les outils MCP

## 📚 Configuration Alternative

### Si vous êtes hors Docker

Si n8n n'est pas dans Docker, utilisez :

```
Endpoint: http://localhost:8000/run_tool
```

### Si vous utilisez un domaine personnalisé

```
Endpoint: https://votre-domaine.com/run_tool
```

## ✅ Checklist de Configuration

- [ ] Endpoint : `http://whatsapp-mcp-server:8000/run_tool`
- [ ] Server Transport : `HTTP Streamable`
- [ ] Authentication : `None`
- [ ] Tools to Include : `All`
- [ ] Serveur MCP actif et accessible
- [ ] Test effectué avec succès

## 🎯 Résumé

**Configuration minimale requise** :

```
Endpoint: http://whatsapp-mcp-server:8000/run_tool
Server Transport: HTTP Streamable
Authentication: None
Tools to Include: All
```

C'est tout ce dont vous avez besoin ! 🚀

