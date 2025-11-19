# Guide : Workflow WhatsApp MCP Complet

Ce guide explique comment utiliser le workflow complet pour gérer automatiquement les messages WhatsApp avec un assistant IA.

## 📋 Vue d'ensemble

Le workflow `workflow-whatsapp-complet.json` est un assistant WhatsApp intelligent qui :

1. ✅ **Reçoit automatiquement** les messages WhatsApp via webhook
2. ✅ **Filtre** les messages entrants (ignore vos propres messages)
3. ✅ **Extrait** les informations importantes (numéro, message, etc.)
4. ✅ **Utilise un agent IA** pour comprendre et répondre
5. ✅ **Envoie automatiquement** une réponse via WhatsApp
6. ✅ **Gère la mémoire** de conversation pour un contexte cohérent

## 🚀 Installation

### Étape 1 : Importer le workflow

1. **Ouvrez n8n** : http://localhost:5678
2. **Cliquez sur "Workflows"** dans le menu de gauche
3. **Cliquez sur le menu "..."** (trois points) en haut à droite
4. **Sélectionnez "Import from File"**
5. **Choisissez le fichier** : `workflow-whatsapp-complet.json`
6. **Le workflow sera importé** avec tous ses nœuds

### Étape 2 : Configurer les nœuds

#### 1. Webhook - Messages WhatsApp

Le webhook est déjà configuré avec :
- **HTTP Method** : `POST`
- **Path** : `mcp-whatsapp`
- **Response Mode** : `Last Node`

⚠️ **Important** : Notez l'URL du webhook affichée dans n8n (ex: `http://localhost:5678/webhook/mcp-whatsapp`)

#### 2. OpenAI Chat Model

1. **Cliquez sur le nœud "OpenAI Chat Model"**
2. **Configurez votre credential OpenAI** :
   - Si vous n'avez pas de credential, créez-en une :
     - Cliquez sur "Create New Credential"
     - Entrez votre clé API OpenAI
     - Sauvegardez
3. **Sélectionnez le modèle** : `gpt-4o-mini` (ou un autre modèle OpenAI)

#### 3. MCP WhatsApp Tools

Le nœud est déjà configuré avec :
- **Endpoint** : `http://whatsapp-mcp-server:8000/run_tool`
- **Server Transport** : `HTTP Streamable`
- **Authentication** : `None`

✅ **Aucune configuration supplémentaire nécessaire** si le serveur MCP est actif.

### Étape 3 : Configurer le webhook dans Docker

1. **Créez un fichier `.env`** à la racine du projet :
   ```bash
   cd /Users/koffiyohanerickouakou/whatsapp-mcp-n8n
   ```

2. **Ajoutez la configuration** :
   ```bash
   # URL du webhook n8n
   N8N_WEBHOOK_URL=http://n8n:5678/webhook/mcp-whatsapp
   ```
   ⚠️ **Important** : Utilisez `n8n` (nom du service Docker) et non `localhost` !

3. **Redémarrez le bridge WhatsApp** :
   ```bash
   docker compose up -d --build whatsapp-bridge
   ```

### Étape 4 : Activer le workflow

1. **Cliquez sur le bouton ON/OFF** en haut à droite du workflow
2. **Le bouton doit être vert** (workflow actif)
3. **Vérifiez que tous les nœuds sont correctement connectés**

## 🔄 Fonctionnement du workflow

### Flux d'exécution

```
1. Message WhatsApp reçu
   ↓
2. Webhook déclenché
   ↓
3. Extraction des données (numéro, message, etc.)
   ↓
4. Filtrage (ignore vos propres messages)
   ↓
5. Agent IA traite le message
   ↓
6. Vérification de la réponse
   ↓
7. Envoi de la réponse via WhatsApp
   ↓
8. Réponse au webhook
```

### Nœuds détaillés

#### 1. Webhook - Messages WhatsApp
- **Rôle** : Reçoit les messages depuis le bridge WhatsApp
- **Données reçues** : Payload JSON avec toutes les informations du message

#### 2. Extraire Données Message
- **Rôle** : Extrait et structure les données importantes
- **Données extraites** :
  - `phone` : Numéro de téléphone (sans @s.whatsapp.net)
  - `sender_jid` : JID complet de l'expéditeur
  - `user_message` : Contenu du message
  - `chat_name` : Nom du contact/chat
  - `timestamp` : Date/heure du message
  - `is_from_me` : Si le message vient de vous

#### 3. Filtrer Messages Entrants
- **Rôle** : Ignore vos propres messages
- **Condition** : `is_from_me === false`

#### 4. AI Agent - WhatsApp Assistant
- **Rôle** : Agent IA qui comprend et répond aux messages
- **Capacités** :
  - Comprend le contexte
  - Utilise les outils MCP disponibles
  - Génère des réponses appropriées
- **Outils disponibles** :
  - `send_message` : Envoyer un message
  - `list_chats` : Lister les conversations
  - `list_messages` : Lister les messages
  - `search_contacts` : Rechercher des contacts
  - `get_chat` : Obtenir les détails d'un chat

#### 5. Vérifier Réponse
- **Rôle** : Vérifie si l'agent a généré une réponse
- **Si oui** : Continue vers l'envoi
- **Si non** : Log l'événement

#### 6. Préparer Envoi
- **Rôle** : Prépare les données pour l'envoi
- **Données préparées** :
  - `recipient` : JID du destinataire
  - `message` : Message à envoyer

#### 7. Envoyer Réponse WhatsApp
- **Rôle** : Envoie la réponse via WhatsApp
- **Outil utilisé** : `send_message` du serveur MCP

#### 8. Répondre au Webhook
- **Rôle** : Répond au webhook avec un statut
- **Réponse** : JSON avec succès et informations

## 🎯 Exemples d'utilisation

### Exemple 1 : Réponse simple

**Message reçu** : "Bonjour, comment ça va ?"

**Réponse générée** : "Bonjour ! Ça va très bien, merci. Et vous ?"

### Exemple 2 : Demande d'action

**Message reçu** : "Peux-tu m'envoyer un message de test ?"

**Réponse générée** : L'agent utilise l'outil `send_message` pour envoyer un message de test.

### Exemple 3 : Demande d'information

**Message reçu** : "Quels sont mes derniers chats ?"

**Réponse générée** : L'agent utilise `list_chats` pour lister les conversations et répond avec les informations.

## 🔧 Personnalisation

### Modifier le prompt système

1. **Cliquez sur le nœud "AI Agent - WhatsApp Assistant"**
2. **Modifiez le "System Message"** dans les options
3. **Personnalisez le comportement** de l'agent

Exemple de personnalisation :
```
You are a customer service assistant for a company.
- Be professional and friendly
- Always greet customers politely
- Provide helpful information
- If you don't know something, say so
```

### Modifier le modèle IA

1. **Cliquez sur le nœud "OpenAI Chat Model"**
2. **Changez le modèle** (ex: `gpt-4`, `gpt-4-turbo`, etc.)
3. **Ajustez les options** si nécessaire

### Ajouter des conditions

Vous pouvez ajouter des conditions pour :
- Filtrer certains numéros
- Répondre différemment selon le contenu
- Ignorer certains types de messages

Exemple : Ajouter un nœud "IF" après "Extraire Données Message" pour filtrer par numéro.

## 🐛 Dépannage

### Le workflow ne se déclenche pas

1. **Vérifiez que le workflow est activé** (bouton vert)
2. **Vérifiez le webhook** :
   ```bash
   docker compose logs whatsapp-bridge | grep webhook
   ```
3. **Testez le webhook manuellement** :
   ```bash
   curl -X POST http://localhost:5678/webhook/mcp-whatsapp \
     -H "Content-Type: application/json" \
     -d '{"from": "2250703324674@s.whatsapp.net", "message": "Test"}'
   ```

### L'agent IA ne répond pas

1. **Vérifiez les credentials OpenAI** dans le nœud "OpenAI Chat Model"
2. **Vérifiez les logs** :
   ```bash
   docker compose logs n8n | tail -50
   ```
3. **Vérifiez que le serveur MCP est actif** :
   ```bash
   docker compose ps whatsapp-mcp-server
   ```

### Les messages ne sont pas envoyés

1. **Vérifiez la connexion WhatsApp** :
   ```bash
   docker compose logs whatsapp-bridge | tail -20
   ```
2. **Vérifiez que le destinataire est correct** (format JID)
3. **Vérifiez les logs du serveur MCP** :
   ```bash
   docker compose logs whatsapp-mcp-server | tail -20
   ```

## 📊 Monitoring

### Vérifier les exécutions

1. **Dans n8n**, cliquez sur "Executions" dans le menu de gauche
2. **Voyez toutes les exécutions** du workflow
3. **Cliquez sur une exécution** pour voir les détails

### Logs Docker

```bash
# Logs du bridge WhatsApp
docker compose logs -f whatsapp-bridge

# Logs du serveur MCP
docker compose logs -f whatsapp-mcp-server

# Logs de n8n
docker compose logs -f n8n
```

## ✅ Checklist de configuration

- [ ] Workflow importé dans n8n
- [ ] Credential OpenAI configuré
- [ ] Modèle OpenAI sélectionné (gpt-4o-mini ou autre)
- [ ] Serveur MCP actif (`docker compose ps whatsapp-mcp-server`)
- [ ] Fichier `.env` créé avec `N8N_WEBHOOK_URL`
- [ ] Bridge WhatsApp redémarré
- [ ] Workflow activé (bouton vert)
- [ ] Test effectué en envoyant un message WhatsApp

## 🎉 C'est prêt !

Une fois toutes ces étapes complétées, votre assistant WhatsApp est opérationnel !

**Pour tester** :
1. Envoyez un message WhatsApp à votre numéro
2. Le workflow se déclenche automatiquement
3. L'agent IA génère une réponse
4. La réponse est envoyée automatiquement via WhatsApp

**Exemple de test** :
- Envoyez : "Bonjour, peux-tu me dire l'heure ?"
- Réponse attendue : L'agent répond avec l'heure actuelle

## 📚 Ressources supplémentaires

- `GUIDE_WEBHOOK_MESSAGES.md` - Guide détaillé sur les webhooks
- `GUIDE_CREER_WEBHOOK_N8N.md` - Guide pour créer un webhook
- `ANALYSE_WORKFLOW_MCP.md` - Analyse du workflow MCP

