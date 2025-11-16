# Problème de version obsolète WhatsApp

## Problème identifié

Le service `whatsapp-bridge` affiche l'erreur suivante :
```
Client outdated (405) connect failure (client version: 2.3000.1021018791)
```

## Cause

WhatsApp Web change régulièrement ses protocoles et versions. La bibliothèque `go.mau.fi/whatsmeow` utilisée dans le projet doit être mise à jour fréquemment pour rester compatible.

## Solutions tentées

1. ✅ **Mise à jour automatique dans le Dockerfile** : Le Dockerfile a été modifié pour mettre à jour `whatsmeow` à la dernière version lors du build
2. ⚠️ **Problème persistant** : Même après la mise à jour, l'erreur persiste

## Solutions possibles

### ✅ Solution 1 : Mise à jour automatique (DÉJÀ IMPLÉMENTÉE)

Le Dockerfile a été modifié pour mettre à jour automatiquement `whatsmeow` à la dernière version lors du build. Cependant, la version actuelle de `whatsmeow` sur GitHub peut encore être obsolète.

### Solution 2 : Vérifier et mettre à jour manuellement

1. **Vérifier la dernière version sur GitHub** :
   - Visitez : https://github.com/tulir/whatsmeow/releases
   - Notez la version la plus récente

2. **Mettre à jour go.mod** :
   ```bash
   cd whatsapp-mcp/whatsapp-bridge
   # Modifier go.mod avec la version la plus récente
   # Puis reconstruire
   docker compose build --no-cache whatsapp-bridge
   ```

3. **Utiliser le script de mise à jour** :
   ```bash
   ./update-whatsmeow.sh
   docker compose build --no-cache whatsapp-bridge
   docker compose up -d whatsapp-bridge
   ```

### Solution 3 : Utiliser le dépôt source original

Le projet original est basé sur : https://github.com/lharries/whatsapp-mcp

Vérifier s'il y a des mises à jour dans le dépôt original qui résolvent ce problème.

### Solution 4 : Attendre une mise à jour de whatsmeow

WhatsApp change fréquemment, et les bibliothèques comme `whatsmeow` doivent être mises à jour régulièrement. Il se peut qu'une nouvelle version de `whatsmeow` soit nécessaire.

**Suivre les mises à jour** :
- Dépôt whatsmeow : https://github.com/tulir/whatsmeow
- Issues GitHub : https://github.com/tulir/whatsmeow/issues
- Vérifier régulièrement les nouvelles releases

## État actuel

- ✅ Services Docker démarrés correctement
- ✅ n8n fonctionne : http://localhost:5678
- ✅ whatsapp-mcp-server fonctionne : port 9000
- ⚠️ whatsapp-bridge : erreur de version client (mais le service tourne)

## Impact

Même si le bridge affiche une erreur, il est possible que certaines fonctionnalités fonctionnent encore. Testez l'envoi de messages via l'API REST sur le port 8081.

## Commandes utiles

```bash
# Voir les logs en temps réel
docker compose logs -f whatsapp-bridge

# Tester l'API REST
curl http://localhost:8081/api/health

# Vérifier la version de whatsmeow utilisée
docker compose exec whatsapp-bridge ls -la /app
```

## Note importante

Ce problème est courant avec les intégrations WhatsApp car :
1. WhatsApp change régulièrement ses protocoles
2. Les bibliothèques tierces doivent être mises à jour fréquemment
3. WhatsApp peut bloquer les clients non officiels

Si le problème persiste, consultez :
- Le dépôt original : https://github.com/lharries/whatsapp-mcp
- Les issues GitHub du projet
- La documentation de whatsmeow : https://github.com/tulir/whatsmeow

