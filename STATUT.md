# Statut de l'installation WhatsApp MCP avec n8n

## ✅ Services opérationnels

1. **n8n** : ✅ Fonctionne
   - URL : http://localhost:5678
   - Identifiants : admin / admin
   - Statut : Opérationnel

2. **whatsapp-mcp-server** : ✅ Fonctionne
   - Port : 9000
   - Statut : Prêt pour les connexions n8n
   - Base de données : Connectée

3. **whatsapp-bridge** : ⚠️ Partiellement fonctionnel
   - Port : 8081
   - Statut : Service démarré mais erreur de version client
   - Erreur : `Client outdated (405) connect failure (client version: 2.3000.1021018791)`

## ⚠️ Problème connu

### Erreur de version obsolète

Le service `whatsapp-bridge` affiche une erreur indiquant que la version du client WhatsApp est obsolète. C'est un problème courant avec les intégrations WhatsApp non officielles.

**Cause** : WhatsApp change régulièrement ses protocoles et versions. La bibliothèque `go.mau.fi/whatsmeow` utilisée doit être mise à jour fréquemment.

**Impact** : 
- Le service démarre mais ne peut pas se connecter à WhatsApp
- L'API REST peut ne pas répondre correctement
- Impossible d'envoyer/recevoir des messages pour le moment

## 🔧 Solutions appliquées

1. ✅ Dockerfile modifié pour mettre à jour automatiquement `whatsmeow`
2. ✅ Image Docker reconstruite avec la dernière version
3. ✅ Session WhatsApp supprimée pour forcer une nouvelle authentification
4. ✅ Script de mise à jour créé : `update-whatsmeow.sh`

## 📋 Prochaines étapes recommandées

### Option 1 : Attendre une mise à jour de whatsmeow

1. Surveiller le dépôt : https://github.com/tulir/whatsmeow
2. Vérifier les nouvelles releases régulièrement
3. Quand une nouvelle version est disponible :
   ```bash
   ./update-whatsmeow.sh
   docker compose build --no-cache whatsapp-bridge
   docker compose up -d whatsapp-bridge
   ```

### Option 2 : Vérifier manuellement la dernière version

1. Visiter https://github.com/tulir/whatsmeow/releases
2. Noter la version la plus récente
3. Mettre à jour `whatsapp-mcp/whatsapp-bridge/go.mod`
4. Reconstruire l'image

### Option 3 : Utiliser une alternative

- Consulter le dépôt original : https://github.com/lharries/whatsapp-mcp
- Vérifier s'il y a des forks avec des mises à jour

## 📊 Commandes utiles

```bash
# Vérifier le statut des services
docker compose ps

# Voir les logs en temps réel
docker compose logs -f whatsapp-bridge

# Tester l'API (peut ne pas répondre à cause de l'erreur)
curl http://localhost:8081/api/health

# Reconstruire le bridge après mise à jour
docker compose build --no-cache whatsapp-bridge
docker compose up -d whatsapp-bridge

# Supprimer la session pour forcer une nouvelle auth
docker run --rm -v whatsapp-mcp-n8n_whatsapp_store:/store alpine sh -c "rm -f /store/whatsapp.db"
```

## 📝 Notes importantes

- **n8n fonctionne parfaitement** et peut être utilisé pour d'autres intégrations
- **Le serveur MCP est prêt** et attendra que le bridge soit fonctionnel
- **Le problème est temporaire** et sera résolu quand `whatsmeow` sera mis à jour
- **WhatsApp change fréquemment** ses protocoles, ce qui nécessite des mises à jour régulières

## 🔗 Liens utiles

- Dépôt whatsmeow : https://github.com/tulir/whatsmeow
- Dépôt original : https://github.com/lharries/whatsapp-mcp
- Dépôt actuel : https://github.com/Zie619/whatsapp-mcp-n8n
- Documentation n8n : https://docs.n8n.io

