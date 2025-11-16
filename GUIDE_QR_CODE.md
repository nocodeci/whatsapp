# Guide complet : QR Code WhatsApp

## 🔴 Situation actuelle

Le QR code **n'apparaît pas** à cause de l'erreur :
```
Client outdated (405) connect failure (client version: 2.3000.1021018791)
```

## ❌ Pourquoi le QR code n'apparaît pas

1. Le client essaie de se connecter à WhatsApp
2. WhatsApp rejette la connexion (version obsolète)
3. L'erreur se produit **AVANT** la génération du QR code
4. **Pas de connexion = Pas de QR code**

## ✅ Quand le QR code apparaîtra

Le QR code apparaîtra automatiquement quand :
- ✅ Une nouvelle version compatible de `whatsmeow` sera disponible
- ✅ Vous reconstruirez l'image Docker
- ✅ Le service pourra se connecter à WhatsApp

## 📋 Comment voir les logs

### Option 1 : Script simple (recommandé)

```bash
./voir-logs.sh
```

Affiche simplement les logs sans fausses détections.

### Option 2 : Commande directe

```bash
docker compose logs -f whatsapp-bridge
```

### Option 3 : Voir les dernières lignes

```bash
docker compose logs whatsapp-bridge --tail 50
```

## 🔍 À quoi ressemblera le QR code

Quand il apparaîtra, vous verrez dans les logs :

```
Scan this QR code with your WhatsApp app:
[QR code en ASCII art - un carré avec des caractères]
```

**Exemple** :
```
Scan this QR code with your WhatsApp app:
█████████████████████████████████
█████████████████████████████████
████ ▄▄▄▄▄ █ ▄▄▄▄▄ █ ▄▄▄▄▄ █████
████ █   █ █ █   █ █ █   █ █████
...
```

## 📱 Comment scanner le QR code

1. **Ouvrez WhatsApp** sur votre téléphone
2. **Allez dans** : Paramètres → Appareils liés → Lier un appareil
3. **Scannez le QR code** affiché dans les logs
4. **La connexion sera établie** automatiquement

## 🔄 Processus complet

### Étape 1 : Vérifier les mises à jour

```bash
./check-update.sh
```

### Étape 2 : Si une nouvelle version est disponible

```bash
# Reconstruire l'image
docker compose build --no-cache whatsapp-bridge

# Redémarrer le service
docker compose up -d whatsapp-bridge

# Surveiller les logs
./voir-logs.sh
```

### Étape 3 : Quand le QR code apparaît

1. Ouvrez les logs : `./voir-logs.sh`
2. Cherchez la ligne : `Scan this QR code with your WhatsApp app:`
3. Le QR code apparaîtra juste après cette ligne
4. Scannez-le avec votre téléphone

## ⚠️ Messages à ignorer

Ces messages **ne sont PAS** des QR codes :
- ❌ `Timeout waiting for QR code scan` - C'est une erreur
- ❌ `Client outdated (405)` - C'est une erreur
- ❌ Toute ligne contenant "ERROR" - Ce sont des erreurs

Le **vrai QR code** commence par :
- ✅ `Scan this QR code with your WhatsApp app:`
- ✅ Suivi d'un carré ASCII avec des caractères

## 💡 Conseils

1. **Utilisez `./voir-logs.sh`** pour voir les logs simplement
2. **Ne vous fiez-vous qu'à la ligne** `Scan this QR code with your WhatsApp app:`
3. **Le QR code apparaîtra automatiquement** quand le problème sera résolu
4. **Surveillez régulièrement** avec `./check-update.sh`

## 🔗 Scripts disponibles

- `./voir-logs.sh` - Voir les logs simplement (recommandé)
- `./watch-qr.sh` - Surveiller avec détection (peut avoir des fausses détections)
- `./check-update.sh` - Vérifier les mises à jour

## 📝 Résumé

**Maintenant** : Le QR code n'apparaît pas à cause d'une version obsolète.

**Quand ça fonctionnera** : Le QR code apparaîtra automatiquement dans les logs après `Scan this QR code with your WhatsApp app:`

**Action** : Utilisez `./voir-logs.sh` pour surveiller les logs et attendre la mise à jour de whatsmeow.

---

**Dernière mise à jour** : 16 novembre 2025


