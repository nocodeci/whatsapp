# Résumé : Pourquoi le QR code n'apparaît pas

## 🔴 Problème actuel

Le QR code **n'apparaît pas** car le service ne peut pas se connecter à WhatsApp à cause de l'erreur :

```
Client outdated (405) connect failure (client version: 2.3000.1021018791)
```

## ❌ Pourquoi ça ne fonctionne pas

1. Le client essaie de se connecter à WhatsApp
2. WhatsApp rejette la connexion (version obsolète)
3. L'erreur se produit **AVANT** que le QR code puisse être généré
4. Pas de connexion = Pas de QR code

## ✅ Solution : Attendre la mise à jour

Le QR code apparaîtra automatiquement quand :
- ✅ Une nouvelle version compatible de `whatsmeow` sera disponible
- ✅ Vous reconstruirez l'image Docker
- ✅ Le service pourra se connecter à WhatsApp

## 📋 Comment voir le QR code (quand il sera disponible)

### Méthode 1 : Script simple

```bash
./voir-logs.sh
```

### Méthode 2 : Script avec détection automatique

```bash
./watch-qr.sh
```

### Méthode 3 : Commande directe

```bash
docker compose logs -f whatsapp-bridge
```

## 🔍 À quoi ressemblera le QR code

Quand il apparaîtra, vous verrez dans les logs :

```
Scan this QR code with your WhatsApp app:
[QR code en ASCII art - un carré avec des caractères]
```

## 📱 Comment scanner le QR code

1. Ouvrez WhatsApp sur votre téléphone
2. Allez dans **Paramètres** → **Appareils liés** → **Lier un appareil**
3. Scannez le QR code affiché dans les logs
4. La connexion sera établie

## 🔄 Vérifier les mises à jour

```bash
# Vérifier s'il y a une nouvelle version
./check-update.sh

# Si une nouvelle version est disponible :
docker compose build --no-cache whatsapp-bridge
docker compose up -d whatsapp-bridge
./watch-qr.sh  # Surveiller l'apparition du QR code
```

## 💡 Note importante

Le QR code apparaît dans les **logs Docker**, pas dans une interface web. Vous devez utiliser `docker compose logs` pour le voir.

## 📝 Scripts disponibles

- `./voir-logs.sh` - Voir les logs simplement
- `./watch-qr.sh` - Surveiller avec détection automatique
- `./check-update.sh` - Vérifier les mises à jour

---

**En résumé** : Le QR code n'apparaît pas maintenant à cause d'une version obsolète. Il apparaîtra automatiquement dans les logs dès que le problème sera résolu.


