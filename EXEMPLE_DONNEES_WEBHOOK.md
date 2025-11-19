# Exemple de Données Reçues par le Webhook

## ✅ Confirmation : Le webhook fonctionne !

Les données suivantes sont un exemple réel de ce que votre workflow n8n reçoit quand un message WhatsApp arrive.

## 📦 Structure des Données

```json
{
  "headers": {
    "host": "floroo.app.n8n.cloud",
    "user-agent": "Go-http-client/2.0",
    "content-type": "application/json",
    ...
  },
  "params": {},
  "query": {},
  "body": {
    "from": "2250703324674@s.whatsapp.net",
    "to": "22554038858:1@s.whatsapp.net",
    "message": "Bonjour",
    "text": "Bonjour",
    "body": "Bonjour",
    "timestamp": "2025-11-17T19:28:19Z",
    "chat_jid": "2250703324674@s.whatsapp.net",
    "chat_name": "2250703324674",
    "is_from_me": false,
    "message_id": "2A410899D39FBAA8FD74"
  },
  "webhookUrl": "https://floroo.app.n8n.cloud/webhook-test/mcp-whatsapp",
  "executionMode": "test"
}
```

## 📋 Explication des Champs

### Headers (En-têtes HTTP)
- `user-agent: "Go-http-client/2.0"` : Confirme que la requête vient du bridge Go
- `content-type: "application/json"` : Format des données (JSON)
- `cf-ipcountry: "CI"` : Pays d'origine (Côte d'Ivoire dans cet exemple)

### Body (Corps de la Requête) - Données Principales

| Champ | Valeur | Description |
|-------|--------|-------------|
| `from` | `2250703324674@s.whatsapp.net` | Expéditeur (JID complet) |
| `to` | `22554038858:1@s.whatsapp.net` | Destinataire (votre numéro) |
| `message` | `"Bonjour"` | Contenu du message texte |
| `text` | `"Bonjour"` | Alias pour `message` |
| `body` | `"Bonjour"` | Alias pour `message` |
| `timestamp` | `"2025-11-17T19:28:19Z"` | Date/heure du message (UTC) |
| `chat_jid` | `2250703324674@s.whatsapp.net` | JID de la conversation |
| `chat_name` | `"2250703324674"` | Nom du contact/chat |
| `is_from_me` | `false` | `false` = message entrant, `true` = message envoyé |
| `message_id` | `"2A410899D39FBAA8FD74"` | ID unique du message |

### Métadonnées

| Champ | Valeur | Description |
|-------|--------|-------------|
| `webhookUrl` | `https://floroo.app.n8n.cloud/webhook-test/mcp-whatsapp` | URL du webhook qui a reçu la requête |
| `executionMode` | `"test"` | Mode d'exécution (`test` ou `production`) |

## 🎯 Utilisation dans votre Workflow

### Accéder aux Données

Dans votre workflow n8n, vous pouvez accéder aux données ainsi :

#### Message reçu
```javascript
{{ $json.body.message }}
// ou
{{ $json.body.text }}
// ou
{{ $json.body.body }}
```

#### Numéro de téléphone de l'expéditeur
```javascript
{{ $json.body.from.split('@')[0] }}
// Résultat: "2250703324674"
```

#### Nom du contact
```javascript
{{ $json.body.chat_name }}
// Résultat: "2250703324674"
```

#### Timestamp
```javascript
{{ $json.body.timestamp }}
// Résultat: "2025-11-17T19:28:19Z"
```

#### Vérifier si c'est un message entrant
```javascript
{{ $json.body.is_from_me === false }}
// Résultat: true (c'est un message entrant)
```

## 📝 Exemple d'Utilisation dans un Nœud Set

Pour extraire les données importantes dans un nœud "Set" :

```json
{
  "assignments": {
    "assignments": [
      {
        "name": "phone",
        "value": "={{ $json.body.from.split('@')[0] }}"
      },
      {
        "name": "sender_jid",
        "value": "={{ $json.body.from }}"
      },
      {
        "name": "user_message",
        "value": "={{ $json.body.message }}"
      },
      {
        "name": "chat_name",
        "value": "={{ $json.body.chat_name }}"
      },
      {
        "name": "timestamp",
        "value": "={{ $json.body.timestamp }}"
      },
      {
        "name": "is_from_me",
        "value": "={{ $json.body.is_from_me }}"
      }
    ]
  }
}
```

## ✅ Vérification

Le webhook fonctionne correctement car :
1. ✅ Les données sont bien reçues dans n8n
2. ✅ Toutes les informations du message sont présentes
3. ✅ Le format est correct (JSON)
4. ✅ Le timestamp est correct
5. ✅ `is_from_me: false` confirme que c'est un message entrant

## 🎉 Prochaines Étapes

Maintenant que le webhook fonctionne, vous pouvez :

1. **Tester votre workflow complet** en envoyant un message WhatsApp
2. **Vérifier que l'agent IA répond** correctement
3. **Vérifier que les messages sont envoyés** via WhatsApp

## 🔍 Dépannage

Si vous ne recevez pas de données :
- Vérifiez que le workflow est activé dans n8n
- Vérifiez les logs du bridge : `docker compose logs whatsapp-bridge | grep webhook`
- Vérifiez que vous envoyez depuis un autre numéro (pas le vôtre)

## 📊 Format Complet

Pour référence, voici tous les champs possibles :

```json
{
  "from": "NUMBER@s.whatsapp.net",
  "to": "YOUR_NUMBER@s.whatsapp.net",
  "message": "Texte du message",
  "text": "Texte du message",
  "body": "Texte du message",
  "timestamp": "2025-11-17T19:28:19Z",
  "chat_jid": "NUMBER@s.whatsapp.net",
  "chat_name": "Nom du contact",
  "is_from_me": false,
  "media_type": "",  // "image", "video", "audio", etc. si média
  "filename": "",    // Nom du fichier si média
  "message_id": "2A410899D39FBAA8FD74"
}
```

Le webhook est opérationnel ! 🎉




