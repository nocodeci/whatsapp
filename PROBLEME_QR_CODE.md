# Pourquoi le code QR n'apparaît pas ?

## 🔍 Problème identifié

Le code QR pour connecter WhatsApp **n'apparaît pas** car le service `whatsapp-bridge` ne peut pas se connecter à WhatsApp à cause de l'erreur de version obsolète.

## ❌ Erreur actuelle

```
Client outdated (405) connect failure (client version: 2.3000.1021018791)
```

Cette erreur se produit **AVANT** que le QR code puisse être généré. Le client ne peut même pas établir la connexion initiale avec WhatsApp.

## 🔄 Comment ça devrait fonctionner

1. Le client se connecte à WhatsApp
2. WhatsApp demande l'authentification
3. Un QR code est généré
4. Vous scannez le QR code avec votre téléphone
5. La connexion est établie

**Problème** : L'étape 1 échoue immédiatement à cause de la version obsolète.

## 📋 Comment voir les logs (pour quand ça fonctionnera)

### Voir les logs en temps réel

```bash
# Voir tous les logs
docker compose logs -f whatsapp-bridge

# Voir seulement les dernières lignes
docker compose logs whatsapp-bridge --tail 50

# Filtrer pour voir le QR code (quand il apparaîtra)
docker compose logs -f whatsapp-bridge | grep -A 10 -i "qr\|code\|scan"
```

### Format du QR code

Quand le QR code fonctionnera, il apparaîtra dans les logs comme ceci :

```
Scan this QR code with your WhatsApp app:
[QR code en ASCII art]
```

## ✅ Solution : Attendre la mise à jour de whatsmeow

Le QR code n'apparaîtra que quand :

1. ✅ Une nouvelle version de `whatsmeow` compatible avec WhatsApp sera disponible
2. ✅ Vous reconstruirez l'image Docker
3. ✅ Le service pourra se connecter à WhatsApp
4. ✅ Le QR code sera généré automatiquement

## 🔄 Vérifier quand c'est prêt

### Méthode 1 : Vérifier les logs

```bash
# Vérifier si la connexion fonctionne
docker compose logs whatsapp-bridge --tail 20 | grep -E "Connected|QR|outdated"
```

Si vous voyez :
- ✅ `Connected to WhatsApp` → Le QR code devrait apparaître
- ❌ `Client outdated` → Encore en attente de mise à jour

### Méthode 2 : Surveiller en temps réel

```bash
# Surveiller les logs en temps réel
docker compose logs -f whatsapp-bridge
```

Quand le problème sera résolu, vous verrez :
```
[Client INFO] Starting WhatsApp client...
Scan this QR code with your WhatsApp app:
[QR code ASCII]
```

## 🛠️ Actions à faire maintenant

1. **Surveiller les mises à jour** :
   ```bash
   ./check-update.sh
   ```

2. **Vérifier les logs régulièrement** :
   ```bash
   docker compose logs whatsapp-bridge --tail 30
   ```

3. **Reconstruire quand une nouvelle version est disponible** :
   ```bash
   docker compose build --no-cache whatsapp-bridge
   docker compose up -d whatsapp-bridge
   docker compose logs -f whatsapp-bridge
   ```

## 📱 Quand le QR code apparaîtra

Une fois que le problème de version sera résolu :

1. Le service se connectera à WhatsApp
2. Un QR code apparaîtra dans les logs
3. Ouvrez WhatsApp sur votre téléphone
4. Allez dans Paramètres → Appareils liés → Lier un appareil
5. Scannez le QR code affiché dans les logs
6. La connexion sera établie

## 💡 Note importante

Le QR code est généré dans les **logs du conteneur Docker**, pas dans une interface web. Vous devez regarder les logs avec `docker compose logs` pour le voir.

## 🔗 Ressources

- **Vérifier les mises à jour** : `./check-update.sh`
- **Voir les logs** : `docker compose logs -f whatsapp-bridge`
- **Dépôt whatsmeow** : https://github.com/tulir/whatsmeow

