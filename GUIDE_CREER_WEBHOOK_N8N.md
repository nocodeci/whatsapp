# Guide pas à pas : Créer le webhook dans n8n

Ce guide vous montre étape par étape comment créer un webhook dans n8n pour recevoir automatiquement les messages WhatsApp.

## 📋 Prérequis

- n8n est démarré et accessible : http://localhost:5678
- Vous avez les identifiants de connexion (admin/admin par défaut)

## 🚀 Étapes détaillées

### Étape 1 : Accéder à n8n

1. **Ouvrez votre navigateur** et allez sur :
   ```
   http://localhost:5678
   ```

2. **Connectez-vous** :
   - Utilisateur : `admin`
   - Mot de passe : `admin`
   (ou vos identifiants personnalisés)

### Étape 2 : Créer un nouveau workflow

1. **Cliquez sur "Workflows"** dans le menu de gauche
2. **Cliquez sur le bouton "+"** (ou "Add Workflow") en haut à droite
3. **Donnez un nom à votre workflow** :
   - Exemple : `WhatsApp Message Handler`
   - Cliquez sur "Save" ou appuyez sur `Ctrl+S` / `Cmd+S`

### Étape 3 : Ajouter le nœud Webhook

1. **Dans le canvas du workflow**, cliquez sur le **"+"** au centre
2. **Tapez "webhook"** dans la barre de recherche
3. **Sélectionnez "Webhook"** (icône avec un globe et une flèche)
4. **Cliquez sur le nœud** pour l'ouvrir et le configurer

### Étape 4 : Configurer le nœud Webhook

Dans la configuration du nœud Webhook :

#### Configuration de base

1. **HTTP Method** :
   - Sélectionnez : `POST`
   - (C'est la méthode utilisée par le bridge WhatsApp)

2. **Path** :
   - Entrez : `mcp-whatsapp`
   - ⚠️ **Notez ce chemin**, vous en aurez besoin pour la configuration Docker
   - Vous pouvez utiliser n'importe quel nom, par exemple : `whatsapp`, `messages`, etc.

3. **Response Mode** :
   - Sélectionnez : `Last Node` ou `When Last Node Finishes`
   - Cela permet à n8n de répondre après l'exécution complète du workflow

#### Options avancées (optionnel)

- **Response Data** : Laissez par défaut
- **Options** : Vous pouvez cocher "Respond with All Data" si vous voulez voir toutes les données

### Étape 5 : Activer le workflow

1. **Cliquez sur le bouton ON/OFF** en haut à droite du workflow
   - Il doit passer de gris (OFF) à vert (ON)
   - ⚠️ **Important** : Le webhook ne fonctionne que si le workflow est activé !

2. **Vérifiez que le workflow est actif** :
   - Le bouton doit être vert
   - Vous devriez voir "Active" à côté du nom du workflow

### Étape 6 : Obtenir l'URL du webhook

1. **Cliquez sur le nœud Webhook** dans votre workflow
2. **Regardez la section "Webhook URL"** en bas du panneau de configuration
3. **Copiez l'URL complète** :
   ```
   http://localhost:5678/webhook/mcp-whatsapp
   ```
   ⚠️ **Notez cette URL**, vous en aurez besoin pour la configuration Docker !

### Étape 7 : Configurer Docker avec l'URL du webhook

Maintenant que vous avez l'URL du webhook, configurez Docker :

1. **Créez un fichier `.env`** à la racine du projet :
   ```bash
   cd /Users/koffiyohanerickouakou/whatsapp-mcp-n8n
   touch .env
   ```

2. **Ajoutez la configuration** dans le fichier `.env` :
   ```bash
   # URL du webhook n8n
   # ⚠️ IMPORTANT : Remplacez 'localhost' par 'n8n' (nom du service Docker)
   N8N_WEBHOOK_URL=http://n8n:5678/webhook/mcp-whatsapp
   ```
   
   ⚠️ **Important** : 
   - Utilisez `n8n` (nom du service Docker) et non `localhost`
   - Utilisez le même `Path` que celui configuré dans n8n (`mcp-whatsapp`)

3. **Redémarrez le bridge WhatsApp** :
   ```bash
   docker compose down
   docker compose up -d --build whatsapp-bridge
   ```

### Étape 8 : Vérifier la configuration

1. **Vérifiez les logs du bridge** :
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

## 🎯 Exemple de workflow complet

Voici un exemple de workflow simple qui affiche le message reçu :

```
[Webhook] → [Set] → [MCP WhatsApp Server (send_message)]
```

### Configuration du nœud Set (optionnel)

Si vous voulez extraire des informations du message :

1. **Ajoutez un nœud "Set"** après le Webhook
2. **Configurez les champs** :
   - `from` : `={{ $json.from }}`
   - `message` : `={{ $json.message }}`
   - `timestamp` : `={{ $json.timestamp }}`

## 📦 Format des données reçues

Quand un message WhatsApp arrive, le nœud Webhook recevra ces données :

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

### Utiliser les données dans votre workflow

- **Numéro de téléphone** : `{{ $json.from.split('@')[0] }}`
- **Message texte** : `{{ $json.message }}`
- **Nom du contact** : `{{ $json.chat_name }}`
- **Timestamp** : `{{ $json.timestamp }}`

## 🐛 Dépannage

### Le webhook ne se déclenche pas

1. **Vérifiez que le workflow est activé** (bouton vert)
2. **Vérifiez l'URL dans les logs** :
   ```bash
   docker compose logs whatsapp-bridge | grep webhook
   ```
3. **Vérifiez que le Path correspond** :
   - Dans n8n : `mcp-whatsapp`
   - Dans `.env` : `/webhook/mcp-whatsapp`

### Erreur "Connection refused"

- Vérifiez que n8n est démarré : `docker compose ps n8n`
- Vérifiez que vous utilisez `n8n` (nom du service) et non `localhost`
- Vérifiez que le port est correct : `5678`

### Le workflow se déclenche mais les données sont vides

- Vérifiez que le message contient du texte ou un média
- Les messages vides sont ignorés automatiquement
- Vérifiez les logs du bridge pour voir si le message a été traité

## ✅ Checklist de configuration

- [ ] n8n est accessible sur http://localhost:5678
- [ ] Workflow créé dans n8n
- [ ] Nœud Webhook ajouté et configuré (POST, Path: `mcp-whatsapp`)
- [ ] Workflow activé (bouton vert)
- [ ] URL du webhook copiée
- [ ] Fichier `.env` créé avec `N8N_WEBHOOK_URL=http://n8n:5678/webhook/mcp-whatsapp`
- [ ] Bridge WhatsApp redémarré avec `docker compose up -d --build whatsapp-bridge`
- [ ] Logs vérifiés : `docker compose logs whatsapp-bridge | grep webhook`
- [ ] Test effectué en envoyant un message WhatsApp

## 🎉 C'est prêt !

Une fois toutes ces étapes complétées, chaque message WhatsApp reçu déclenchera automatiquement votre workflow n8n !

Pour tester :
1. Envoyez un message WhatsApp à votre numéro
2. Vérifiez que le workflow se déclenche dans n8n
3. Les données du message devraient apparaître dans le nœud Webhook

