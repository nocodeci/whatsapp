# 📱 Guide QR Code pour Étudiants

Ce guide vous explique comment scanner le QR code pour connecter WhatsApp au système.

## 🎯 Objectif

Connecter votre compte WhatsApp au système pour pouvoir :
- Recevoir des messages WhatsApp
- Envoyer des messages WhatsApp
- Utiliser WhatsApp avec n8n et l'IA

## 📋 Prérequis

- ✅ Les services Docker sont démarrés (`docker compose up -d`)
- ✅ WhatsApp installé sur votre téléphone
- ✅ Votre téléphone a accès à Internet

## 🔍 Étape 1 : Afficher le QR Code

### Méthode 1 : Logs en temps réel (Recommandé)

```bash
docker compose logs -f whatsapp-bridge
```

Cette commande affiche les logs en temps réel. Le QR code apparaîtra automatiquement.

### Méthode 2 : Voir les derniers logs

```bash
docker compose logs whatsapp-bridge | tail -50
```

### Méthode 3 : Chercher spécifiquement le QR code

```bash
docker compose logs whatsapp-bridge | grep -A 20 "QR code"
```

## 📱 Étape 2 : Scanner le QR Code

### 2.1 Ouvrir WhatsApp sur votre téléphone

1. Ouvrez l'application **WhatsApp**
2. Assurez-vous d'être connecté à votre compte

### 2.2 Accéder aux Appareils liés

**Sur Android :**
1. Appuyez sur les **3 points** (⋮) en haut à droite
2. Allez dans **Appareils liés**

**Sur iPhone :**
1. Appuyez sur **Paramètres** (⚙️) en bas à droite
2. Allez dans **Appareils liés**

### 2.3 Lier un nouvel appareil

1. Appuyez sur **Lier un appareil** (ou **Link a Device**)
2. Vous verrez l'écran de scan QR code

### 2.4 Scanner le QR code

1. **Positionnez votre téléphone** pour que le QR code dans le terminal soit visible
2. **Scannez le QR code** avec l'application WhatsApp
3. **Attendez la confirmation** (quelques secondes)

## ✅ Étape 3 : Vérifier la Connexion

### 3.1 Dans les logs

Après avoir scanné, vous devriez voir dans les logs :

```
✅ WhatsApp connecté !
✅ Client connecté et prêt
```

### 3.2 Dans WhatsApp

Sur votre téléphone, vous devriez voir :
- Un nouvel appareil lié dans la liste des appareils
- Le nom sera quelque chose comme "whatsapp-bridge" ou "Go"

### 3.3 Tester la connexion

Envoyez un message WhatsApp depuis un autre téléphone à votre numéro.

Vous devriez voir le message apparaître dans :
- Les logs : `docker compose logs -f whatsapp-bridge`
- Le dashboard : http://localhost:8000

## 🐛 Problèmes Courants

### ❌ Le QR code n'apparaît pas

**Symptômes :**
- Les logs ne montrent pas de QR code
- Message d'erreur dans les logs

**Solutions :**

1. **Vérifier que le service est démarré :**
   ```bash
   docker compose ps
   ```
   Le service `whatsapp-bridge` doit être "Up"

2. **Redémarrer le service :**
   ```bash
   docker compose restart whatsapp-bridge
   docker compose logs -f whatsapp-bridge
   ```

3. **Vérifier les logs d'erreur :**
   ```bash
   docker compose logs whatsapp-bridge | grep -i error
   ```

4. **Supprimer l'ancienne session (si nécessaire) :**
   ```bash
   docker compose down
   docker volume rm whatsapp-mcp-n8n_whatsapp_store
   docker compose up -d
   ```

### ❌ Le QR code expire

**Symptômes :**
- Le QR code est affiché mais ne fonctionne pas
- Message "QR code expired" dans les logs

**Solutions :**

1. **Générer un nouveau QR code :**
   ```bash
   docker compose restart whatsapp-bridge
   docker compose logs -f whatsapp-bridge
   ```

2. **Scanner rapidement** : Le QR code expire après environ 60 secondes

### ❌ Impossible de scanner (QR code trop petit)

**Symptômes :**
- Le QR code est trop petit dans le terminal
- Impossible de le scanner avec le téléphone

**Solutions :**

1. **Agrandir la fenêtre du terminal**

2. **Augmenter la taille de la police du terminal**

3. **Utiliser un terminal avec zoom** :
   - Mac : `Cmd +` pour zoomer
   - Windows : `Ctrl +` pour zoomer
   - Linux : `Ctrl +` pour zoomer

4. **Copier les logs dans un fichier et l'ouvrir :**
   ```bash
   docker compose logs whatsapp-bridge > qr-code.txt
   # Ouvrir qr-code.txt avec un éditeur de texte
   ```

### ❌ "Already logged in" ou "Session exists"

**Symptômes :**
- Message indiquant qu'une session existe déjà
- Pas de QR code affiché

**Solutions :**

1. **Vérifier si WhatsApp est déjà connecté :**
   ```bash
   docker compose logs whatsapp-bridge | grep -i "connected\|ready"
   ```

2. **Si déjà connecté, c'est normal !** Vous n'avez pas besoin de scanner à nouveau.

3. **Si vous voulez reconnecter :**
   ```bash
   # Arrêter les services
   docker compose down
   
   # Supprimer la session (ATTENTION : vous devrez scanner à nouveau)
   docker volume rm whatsapp-mcp-n8n_whatsapp_store
   
   # Redémarrer
   docker compose up -d
   docker compose logs -f whatsapp-bridge
   ```

### ❌ "Connection timeout" ou "Network error"

**Symptômes :**
- Impossible de se connecter après avoir scanné
- Erreurs réseau dans les logs

**Solutions :**

1. **Vérifier votre connexion Internet :**
   ```bash
   ping google.com
   ```

2. **Vérifier que le port 8081 n'est pas bloqué :**
   ```bash
   # Sur Mac/Linux
   lsof -i :8081
   ```

3. **Redémarrer le service :**
   ```bash
   docker compose restart whatsapp-bridge
   ```

4. **Vérifier le firewall** : Assurez-vous que le firewall n'bloque pas Docker

### ❌ Le QR code est scanné mais rien ne se passe

**Symptômes :**
- QR code scanné avec succès
- Mais pas de confirmation dans les logs

**Solutions :**

1. **Attendre quelques secondes** : La connexion peut prendre 10-30 secondes

2. **Vérifier les logs en temps réel :**
   ```bash
   docker compose logs -f whatsapp-bridge
   ```

3. **Vérifier sur votre téléphone** : Allez dans Appareils liés et vérifiez si l'appareil apparaît

4. **Réessayer** : Parfois, il faut scanner plusieurs fois

## 🔄 Reconnecter WhatsApp

Si vous devez reconnecter WhatsApp (par exemple, après avoir changé de téléphone) :

### Méthode 1 : Supprimer la session

```bash
# Arrêter les services
docker compose down

# Supprimer le volume de session
docker volume rm whatsapp-mcp-n8n_whatsapp_store

# Redémarrer
docker compose up -d
docker compose logs -f whatsapp-bridge
```

**⚠️ Attention :** Vous devrez scanner le QR code à nouveau.

### Méthode 2 : Déconnecter depuis WhatsApp

1. Ouvrez WhatsApp sur votre téléphone
2. Allez dans **Appareils liés**
3. Trouvez l'appareil "whatsapp-bridge" ou "Go"
4. Appuyez sur **Déconnecter**
5. Redémarrez le service :
   ```bash
   docker compose restart whatsapp-bridge
   docker compose logs -f whatsapp-bridge
   ```

## ✅ Checklist de Connexion

- [ ] Services Docker démarrés
- [ ] QR code affiché dans les logs
- [ ] WhatsApp ouvert sur le téléphone
- [ ] Écran "Lier un appareil" ouvert
- [ ] QR code scanné avec succès
- [ ] Confirmation "✅ WhatsApp connecté !" dans les logs
- [ ] Appareil visible dans WhatsApp (Appareils liés)
- [ ] Test d'envoi/réception de message réussi

## 💡 Conseils

1. **Scannez rapidement** : Le QR code expire après ~60 secondes
2. **Bonne luminosité** : Assurez-vous que l'écran est bien éclairé
3. **Distance** : Gardez une distance raisonnable (30-50 cm)
4. **Stabilité** : Évitez de bouger pendant le scan
5. **Connexion Internet** : Assurez-vous que votre téléphone et votre ordinateur ont Internet

## 📞 Besoin d'Aide ?

Si vous rencontrez toujours des problèmes :

1. **Consultez les logs complets :**
   ```bash
   docker compose logs whatsapp-bridge > logs.txt
   ```

2. **Vérifiez la documentation :**
   - [GUIDE_INSTALLATION_ETUDIANTS.md](GUIDE_INSTALLATION_ETUDIANTS.md)
   - [PROBLEME_QR_CODE.md](PROBLEME_QR_CODE.md)

3. **Demandez à votre professeur** ou ouvrez une issue sur GitHub

---

**Une fois connecté, vous pouvez commencer à utiliser WhatsApp avec n8n ! 🎉**

