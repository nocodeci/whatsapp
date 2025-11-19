# Guide : Envoyer un message WhatsApp de test

## 🚀 Démarrage rapide

### 1. Démarrer Docker Desktop

Assurez-vous que Docker Desktop est démarré sur votre Mac.

### 2. Démarrer les services

```bash
cd /Users/koffiyohanerickouakou/whatsapp-mcp-n8n
docker compose up -d
```

### 3. Vérifier que les services sont démarrés

```bash
docker compose ps
```

Vous devriez voir :
- `whatsapp-bridge` (port 8081)
- `whatsapp-mcp-server` (port 8000, 9000)
- `n8n` (port 5678)

### 4. Vérifier que WhatsApp est connecté

```bash
docker compose logs whatsapp-bridge | grep -i "connected\|ready\|qr"
```

Si vous voyez un QR code, scannez-le avec votre téléphone WhatsApp.

## 📤 Envoyer un message de test

### Méthode 1 : Script Python (Recommandé)

```bash
# Envoyer un message avec le script
python3 test-envoi-message.py

# Ou avec des paramètres personnalisés
python3 test-envoi-message.py 2250703324674 "Votre message ici"
```

### Méthode 2 : curl (ligne de commande)

```bash
curl -X POST http://localhost:8081/api/send \
  -H "Content-Type: application/json" \
  -d '{
    "recipient": "2250703324674",
    "message": "Bonjour ! Ceci est un message de test. 🚀"
  }'
```

### Méthode 3 : Via le serveur MCP (HTTP)

```bash
curl -X POST http://localhost:8000/run_tool \
  -H "Content-Type: application/json" \
  -d '{
    "tool": "send_message",
    "params": {
      "recipient": "2250703324674",
      "message": "Bonjour ! Ceci est un message de test. 🚀"
    }
  }'
```

## 📝 Format du numéro de téléphone

**Important :** Le numéro doit être au format **sans le +** et **sans espaces** :

- ✅ `2250703324674` (correct)
- ❌ `+225 0703324674` (incorrect - contient + et espaces)
- ❌ `+2250703324674` (incorrect - contient +)

## 🔍 Vérifier l'envoi

### Voir les logs en temps réel

```bash
docker compose logs -f whatsapp-bridge
```

### Vérifier dans le dashboard

Ouvrez votre navigateur : http://localhost:8000

Vous devriez voir le message dans la conversation.

## ⚠️ Dépannage

### Erreur : "Cannot connect to the Docker daemon"

**Solution :** Démarrez Docker Desktop

### Erreur : "Connection refused" ou "Connection error"

**Solutions :**
1. Vérifiez que les services sont démarrés : `docker compose ps`
2. Vérifiez les logs : `docker compose logs whatsapp-bridge`
3. Vérifiez que WhatsApp est connecté (pas de QR code en attente)

### Erreur : "Client outdated (405)"

**Solution :** Mettez à jour whatsmeow :
```bash
./update-all.sh
```

### Le message n'arrive pas

**Vérifications :**
1. Le numéro est-il correct ? (format sans +)
2. Le destinataire a-t-il WhatsApp installé ?
3. Avez-vous déjà échangé avec ce numéro ? (première fois peut nécessiter une invitation)
4. Vérifiez les logs : `docker compose logs -f whatsapp-bridge`

## 📱 Numéro de test

Pour tester avec le numéro **+225 0703324674** :

```bash
python3 test-envoi-message.py 2250703324674 "Bonjour ! Test depuis MCP WhatsApp"
```

## 🎯 Exemple complet

```bash
# 1. Démarrer Docker Desktop (manuellement)

# 2. Démarrer les services
docker compose up -d

# 3. Attendre que WhatsApp soit connecté (vérifier les logs)
docker compose logs -f whatsapp-bridge

# 4. Envoyer le message de test
python3 test-envoi-message.py 2250703324674 "Bonjour ! Ceci est un test 🚀"

# 5. Vérifier les logs pour confirmer l'envoi
docker compose logs whatsapp-bridge | tail -20
```

