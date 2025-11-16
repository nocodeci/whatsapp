# Vérification et mise à jour de whatsmeow

## Dépôt source

**URL** : https://github.com/tulir/whatsmeow.git

**Documentation** : https://pkg.go.dev/go.mau.fi/whatsmeow

## Version actuelle

**Version dans le projet** : `v0.0.0-20250318233852-06705625cf82` (mars 2025)

## Comment vérifier la dernière version

### Méthode 1 : Via l'API GitHub

```bash
curl -s https://api.github.com/repos/tulir/whatsmeow/commits?per_page=1 | grep '"sha"'
```

### Méthode 2 : Via Go

```bash
cd whatsapp-mcp/whatsapp-bridge
go list -m -versions go.mau.fi/whatsmeow
go list -m -u go.mau.fi/whatsmeow
```

### Méthode 3 : Via le site Go

Visiter : https://pkg.go.dev/go.mau.fi/whatsmeow?tab=versions

## Comment mettre à jour

### Option 1 : Mise à jour automatique (recommandée)

Le Dockerfile a déjà été configuré pour mettre à jour automatiquement :

```bash
docker compose build --no-cache whatsapp-bridge
docker compose up -d whatsapp-bridge
```

### Option 2 : Mise à jour manuelle dans go.mod

1. Vérifier la dernière version disponible
2. Modifier `whatsapp-mcp/whatsapp-bridge/go.mod` :
   ```go
   go.mau.fi/whatsmeow v0.0.0-YYYYMMDDHHMMSS-xxxxxxxxxxxxx
   ```
3. Reconstruire :
   ```bash
   docker compose build --no-cache whatsapp-bridge
   ```

### Option 3 : Utiliser le script

```bash
./update-whatsmeow.sh
docker compose build --no-cache whatsapp-bridge
docker compose up -d whatsapp-bridge
```

## Vérifier si la mise à jour a résolu le problème

Après la mise à jour, vérifier les logs :

```bash
docker compose logs -f whatsapp-bridge
```

Rechercher :
- ✅ `Connected to WhatsApp` - Succès !
- ❌ `Client outdated (405)` - Version toujours obsolète
- ❌ `connect failure` - Autre problème

## Suivre les mises à jour

### GitHub
- **Dépôt** : https://github.com/tulir/whatsmeow
- **Issues** : https://github.com/tulir/whatsmeow/issues
- **Releases** : https://github.com/tulir/whatsmeow/releases (généralement vide, utilisez les commits)

### Matrix (Discussion)
- **Room** : #whatsmeow:maunium.net

### GitHub Discussions
- **Q&A Protocol** : https://github.com/tulir/whatsmeow/discussions

## Notes importantes

1. **Pas de releases taguées** : whatsmeow n'utilise pas de tags de version, utilisez les commits
2. **Mises à jour fréquentes** : WhatsApp change souvent, whatsmeow est mis à jour régulièrement
3. **Version actuelle** : La version `20250318233852` date de mars 2025, vérifiez s'il y a des commits plus récents

## Commandes utiles

```bash
# Voir la version actuelle
cd whatsapp-mcp/whatsapp-bridge && cat go.mod | grep whatsmeow

# Vérifier les mises à jour disponibles
go list -m -u go.mau.fi/whatsmeow

# Mettre à jour manuellement
go get -u go.mau.fi/whatsmeow@latest
go mod tidy

# Vérifier les commits récents sur GitHub
curl -s https://api.github.com/repos/tulir/whatsmeow/commits?per_page=5 | grep -E '"sha"|"date"'
```

## Problème de version obsolète

Si vous voyez toujours `Client outdated (405)` après une mise à jour :

1. Vérifier que la mise à jour a bien été appliquée dans l'image Docker
2. Supprimer la session WhatsApp existante :
   ```bash
   docker run --rm -v whatsapp-mcp-n8n_whatsapp_store:/store alpine sh -c "rm -f /store/whatsapp.db"
   ```
3. Redémarrer le service
4. Attendre une nouvelle mise à jour de whatsmeow si le problème persiste

## Ressources

- **Dépôt GitHub** : https://github.com/tulir/whatsmeow
- **Documentation Go** : https://pkg.go.dev/go.mau.fi/whatsmeow
- **Matrix Room** : #whatsmeow:maunium.net
- **Issues GitHub** : https://github.com/tulir/whatsmeow/issues

