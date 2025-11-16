# Guide de mise à jour - WhatsApp MCP avec n8n

## 📋 Vue d'ensemble

Ce guide explique comment gérer les mises à jour de votre installation WhatsApp MCP avec n8n.

## 🔄 Processus de mise à jour

### Méthode 1 : Script automatisé (Recommandé)

Le script `update-all.sh` automatise tout le processus :

```bash
./update-all.sh
```

**Ce que fait le script :**
1. ✅ Vérifie que Docker est en cours d'exécution
2. ✅ Vérifie les mises à jour disponibles de whatsmeow
3. ✅ Crée une sauvegarde de l'état actuel
4. ✅ Met à jour `go.mod` avec la dernière version
5. ✅ Reconstruit l'image Docker
6. ✅ Redémarre le service
7. ✅ Vérifie que tout fonctionne correctement

### Méthode 2 : Vérification manuelle puis mise à jour

#### Étape 1 : Vérifier les mises à jour

```bash
./check-update.sh
```

Ce script affiche :
- Le dernier commit disponible sur GitHub
- La version actuellement installée
- Si une mise à jour est nécessaire

#### Étape 2 : Mettre à jour si nécessaire

Si une mise à jour est disponible :

```bash
# Option A : Script automatisé
./update-all.sh

# Option B : Mise à jour manuelle
docker compose build --no-cache whatsapp-bridge
docker compose up -d whatsapp-bridge
docker compose logs -f whatsapp-bridge
```

### Méthode 3 : Mise à jour automatique via Dockerfile

Le Dockerfile est configuré pour mettre à jour automatiquement whatsmeow lors de chaque build :

```dockerfile
# Update whatsmeow to latest version to fix outdated client issue
RUN go get -u go.mau.fi/whatsmeow@latest
RUN go mod tidy
```

Donc, même sans modifier `go.mod`, une reconstruction force la mise à jour :

```bash
docker compose build --no-cache whatsapp-bridge
docker compose up -d whatsapp-bridge
```

## 📅 Fréquence recommandée

### Vérification hebdomadaire

```bash
# Ajouter à votre crontab pour vérifier chaque semaine
0 9 * * 1 cd /chemin/vers/whatsapp-mcp-n8n && ./check-update.sh
```

### Quand mettre à jour ?

**Mise à jour immédiate si :**
- ❌ Vous voyez l'erreur `Client outdated (405)`
- ❌ Le QR code n'apparaît pas
- ❌ La connexion WhatsApp est refusée
- ⚠️ Des problèmes de compatibilité sont signalés

**Mise à jour régulière :**
- ✅ Une fois par semaine pour rester à jour
- ✅ Après chaque problème de connexion
- ✅ Quand whatsmeow publie un nouveau commit

## 🔍 Vérification après mise à jour

### 1. Vérifier les logs

```bash
docker compose logs -f whatsapp-bridge
```

**Recherchez :**
- ✅ `Connected to WhatsApp` - Succès !
- ✅ `Scan this QR code` - QR code disponible
- ❌ `Client outdated (405)` - Version toujours obsolète
- ❌ `connect failure` - Autre problème

### 2. Vérifier l'API REST

```bash
curl http://localhost:8081/api/health
```

**Réponse attendue :**
```json
{"status":"healthy","service":"whatsapp-bridge"}
```

### 3. Vérifier le statut des services

```bash
docker compose ps
```

Tous les services doivent être `Up` et en bonne santé.

## 🔧 Dépannage après mise à jour

### Problème : Erreur de build

**Solution :**
```bash
# Vérifier les erreurs de compilation
docker compose build whatsapp-bridge 2>&1 | grep ERROR

# Si le problème persiste, restaurer la sauvegarde
cp backups/YYYYMMDD_HHMMSS/go.mod.bak whatsapp-mcp/whatsapp-bridge/go.mod
```

### Problème : Service ne démarre pas

**Solution :**
```bash
# Voir les logs d'erreur
docker compose logs whatsapp-bridge --tail 50

# Redémarrer proprement
docker compose down whatsapp-bridge
docker compose up -d whatsapp-bridge
```

### Problème : Version toujours obsolète

**Solution :**
1. Vérifier que le build a bien utilisé la nouvelle version :
   ```bash
   docker compose exec whatsapp-bridge sh -c "cat /app/whatsapp-bridge 2>/dev/null | strings | grep -i whatsmeow || echo 'Version non détectable'"
   ```

2. Forcer la suppression du cache Docker :
   ```bash
   docker compose build --no-cache --pull whatsapp-bridge
   ```

3. Supprimer l'ancienne session si nécessaire :
   ```bash
   docker compose stop whatsapp-bridge
   docker volume rm whatsapp-mcp-n8n_whatsapp_store
   docker compose up -d whatsapp-bridge
   ```

## 📝 Scripts disponibles

| Script | Description | Usage |
|--------|-------------|-------|
| `check-update.sh` | Vérifie les mises à jour disponibles | `./check-update.sh` |
| `update-all.sh` | Mise à jour complète automatisée | `./update-all.sh` |
| `update-whatsmeow.sh` | Met à jour go.mod localement | `./update-whatsmeow.sh` |
| `voir-logs.sh` | Affiche les logs en temps réel | `./voir-logs.sh` |

## 🔗 Ressources utiles

### Suivre les mises à jour

- **GitHub** : https://github.com/tulir/whatsmeow
- **Commits récents** : https://github.com/tulir/whatsmeow/commits/main
- **Issues** : https://github.com/tulir/whatsmeow/issues

### Communauté

- **Matrix Room** : #whatsmeow:maunium.net
- **GitHub Discussions** : https://github.com/tulir/whatsmeow/discussions

## 💡 Conseils

1. **Sauvegardes automatiques** : Le script `update-all.sh` crée automatiquement des sauvegardes dans `backups/`

2. **Vérification avant mise à jour** : Toujours vérifier les issues GitHub pour voir si d'autres utilisateurs ont des problèmes avec la nouvelle version

3. **Tests après mise à jour** : Toujours tester l'envoi/réception de messages après une mise à jour

4. **Surveillance** : Configurer une alerte si le service s'arrête ou si l'erreur 405 réapparaît

## 📊 Historique des mises à jour

Gardez une trace des mises à jour effectuées :

```bash
# Créer un fichier de log
echo "$(date): Mise à jour vers $(cat whatsapp-mcp/whatsapp-bridge/go.mod | grep whatsmeow)" >> updates.log
```

---

**Dernière mise à jour de ce guide** : 16 novembre 2025

