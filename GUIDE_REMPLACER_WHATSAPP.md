# Guide : Remplacer WhatsApp Business Cloud par le serveur MCP WhatsApp

Ce guide explique comment remplacer le nœud "WhatsApp Business Cloud" par le serveur MCP WhatsApp dans votre workflow n8n.

## 🔄 Remplacement du nœud

### Nœud actuel (WhatsApp Business Cloud)

```json
{
  "parameters": {
    "operation": "send",
    "phoneNumberId": "477115632141067",
    "recipientPhoneNumber": "44123456789",
    "textBody": "={{ $json.text }}",
    "additionalFields": {}
  },
  "name": "WhatsApp Business Cloud",
  "type": "n8n-nodes-base.whatsApp"
}
```

### Nouveau nœud (Serveur MCP WhatsApp)

**Option 1 : HTTP Request (Recommandé - fonctionne avec toutes les versions)**

1. **Supprimez** le nœud "WhatsApp Business Cloud"
2. **Ajoutez** un nœud "HTTP Request"
3. **Configurez** comme suit :

```
Méthode : POST
URL : http://whatsapp-mcp-server:8000/run_tool
Authentication : None
Send Body : Yes
Body Content Type : JSON
Body :
{
  "tool": "send_message",
  "params": {
    "recipient": "={{ $json.recipientPhoneNumber || $json.recipient }}",
    "message": "={{ $json.text || $json.textBody || $json.message }}"
  }
}
```

**Option 2 : MCP Client (si disponible dans votre version n8n)**

1. **Supprimez** le nœud "WhatsApp Business Cloud"
2. **Ajoutez** un nœud "MCP Client"
3. **Configurez** :
   - Endpoint : `http://whatsapp-mcp-server:8000/run_tool`
   - Server Transport : `HTTP Streamable`
   - Authentication : `None`
   - Tool : `send_message`
   - Parameters :
     - recipient : `={{ $json.recipientPhoneNumber || $json.recipient }}`
     - message : `={{ $json.text || $json.textBody || $json.message }}`

## 📝 Configuration détaillée (HTTP Request)

### Étape par étape

1. **Dans votre workflow, cliquez sur le nœud "WhatsApp Business Cloud"**

2. **Supprimez-le** (clic droit > Delete ou touche Suppr)

3. **Ajoutez un nouveau nœud "HTTP Request"** à la même position

4. **Configurez les paramètres suivants :**

   **Méthode :**
   ```
   POST
   ```

   **URL :**
   ```
   http://whatsapp-mcp-server:8000/run_tool
   ```
   ⚠️ **Important** : Utilisez le nom du service Docker (`whatsapp-mcp-server`), pas `localhost`

   **Authentication :**
   ```
   None
   ```

   **Send Body :**
   ```
   Yes
   ```

   **Body Content Type :**
   ```
   JSON
   ```

   **Body (JSON) :**
   ```json
   {
     "tool": "send_message",
     "params": {
       "recipient": "={{ $json.recipientPhoneNumber || $json.recipient }}",
       "message": "={{ $json.text || $json.textBody || $json.message }}"
     }
   }
   ```

5. **Connectez le nouveau nœud** aux mêmes connexions que l'ancien nœud

## 🔧 Adaptation pour votre workflow spécifique

Dans votre workflow, le nœud WhatsApp reçoit `$json.text` depuis "Attendee Research Agent". 

### Configuration adaptée :

**Body (JSON) :**
```json
{
  "tool": "send_message",
  "params": {
    "recipient": "={{ $json.recipientPhoneNumber || 'VOTRE_NUMERO_PAR_DEFAUT' }}",
    "message": "={{ $json.text }}"
  }
}
```

Ou si vous voulez extraire le numéro depuis les données du meeting :

```json
{
  "tool": "send_message",
  "params": {
    "recipient": "={{ $('Check For Upcoming Meetings').item.json.organizer.email.split('@')[0] || 'VOTRE_NUMERO' }}",
    "message": "={{ $json.text }}"
  }
}
```

## 📋 Format du numéro de téléphone

Le serveur MCP WhatsApp accepte les formats suivants :

- **Avec indicatif** : `+33612345678`
- **JID WhatsApp** : `33612345678@s.whatsapp.net`
- **Sans indicatif** : `33612345678` (si l'indicatif est déjà dans le numéro)

## ⚠️ Différences importantes

### WhatsApp Business Cloud vs MCP WhatsApp

| Aspect | WhatsApp Business Cloud | Serveur MCP WhatsApp |
|--------|------------------------|---------------------|
| **phoneNumberId** | Requis (ID Meta) | Non requis |
| **recipientPhoneNumber** | Format libre | Format avec indicatif (+XX) |
| **textBody** | Texte simple | Texte simple |
| **Authentification** | Via Meta API | Via connexion WhatsApp personnelle |
| **Coût** | Payant (Meta) | Gratuit (votre connexion) |

## 🔍 Vérification

Après le remplacement, testez votre workflow :

1. **Exécutez le workflow manuellement**
2. **Vérifiez les logs** :
   ```bash
   docker compose logs whatsapp-mcp-server | tail -20
   ```
3. **Vérifiez que le message est envoyé** sur WhatsApp

## 🐛 Dépannage

### Erreur : "Cannot connect to whatsapp-mcp-server"

**Solution :** Vérifiez que :
- Le serveur MCP est en cours d'exécution : `docker compose ps whatsapp-mcp-server`
- Vous utilisez le nom du service Docker (`whatsapp-mcp-server`) et non `localhost`

### Erreur : "Invalid recipient"

**Solution :** Assurez-vous que le numéro est au format :
- `+33612345678` (avec indicatif)
- Ou `33612345678@s.whatsapp.net` (JID complet)

### Le message n'est pas envoyé

**Solution :** Vérifiez que :
- WhatsApp est connecté : `docker compose logs whatsapp-bridge | grep "Connected"`
- Le numéro de téléphone est correct
- Le message n'est pas vide

## 📚 Ressources supplémentaires

- **Guide complet MCP HTTP** : `GUIDE_MCP_N8N_HTTP.md`
- **Configuration rapide** : `CONFIGURATION_RAPIDE_MCP.md`
- **Logs du serveur** : `docker compose logs -f whatsapp-mcp-server`

## ✅ Exemple de workflow modifié

Le fichier `workflow-remplacement-whatsapp.json` contient un exemple du nœud remplacé que vous pouvez importer dans n8n.

---

**Note** : Après le remplacement, vous n'aurez plus besoin de :
- `phoneNumberId` (ID Meta)
- Configuration Meta Business API
- Coûts associés à l'API Meta

Vous utiliserez directement votre connexion WhatsApp personnelle via le serveur MCP.

