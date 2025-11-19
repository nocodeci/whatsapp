# Diagnostic : Webhook ne se déclenche pas

## 🔍 Vérifications à effectuer

### 1. Vérifier que le fichier `.env` existe et est configuré

```bash
cd /Users/koffiyohanerickouakou/whatsapp-mcp-n8n
cat .env
```

Vous devriez voir :
```
N8N_WEBHOOK_URL=https://floroo.app.n8n.cloud/webhook/mcp-whatsapp
```

**Si le fichier n'existe pas ou n'a pas cette ligne** :
```bash
echo "N8N_WEBHOOK_URL=https://floroo.app.n8n.cloud/webhook/mcp-whatsapp" > .env
docker compose up -d --build whatsapp-bridge
```

### 2. Vérifier que la variable est chargée dans le conteneur

```bash
docker compose exec whatsapp-bridge env | grep N8N_WEBHOOK_URL
```

**Si rien n'apparaît** :
- Le fichier `.env` n'est pas lu
- Redémarrez le conteneur : `docker compose restart whatsapp-bridge`

### 3. Vérifier les logs du bridge

```bash
docker compose logs whatsapp-bridge | grep -i webhook
```

Vous devriez voir :
```
Webhook configured: https://floroo.app.n8n.cloud/webhook/mcp-whatsapp
```

**Si vous voyez** :
```
No webhook configured (set N8N_WEBHOOK_URL to enable)
```
→ La variable d'environnement n'est pas chargée

### 4. Vérifier que le bridge reçoit des messages

```bash
docker compose logs whatsapp-bridge --tail 50 | grep -E "←|Message"
```

**Si aucun message n'apparaît** :
- Le bridge n'est peut-être pas connecté à WhatsApp
- Vérifiez la connexion : `docker compose logs whatsapp-bridge | grep -i "connected\|QR"`
- Vous devrez peut-être scanner le QR code à nouveau

### 5. Tester la connectivité vers n8n

```bash
docker compose exec whatsapp-bridge curl -v https://floroo.app.n8n.cloud/webhook/mcp-whatsapp
```

**Si erreur de connexion** :
- Le serveur n'a peut-être pas accès à Internet
- Vérifiez le firewall
- Testez depuis l'hôte : `curl -I https://floroo.app.n8n.cloud/webhook/mcp-whatsapp`

### 6. Vérifier que le workflow n8n est activé

1. Allez sur https://floroo.app.n8n.cloud
2. Vérifiez que le workflow est **activé** (bouton vert)
3. Vérifiez que le webhook a le path `mcp-whatsapp`

### 7. Tester le webhook manuellement

```bash
curl -X POST https://floroo.app.n8n.cloud/webhook/mcp-whatsapp \
  -H "Content-Type: application/json" \
  -d '{
    "from": "2250703324674@s.whatsapp.net",
    "message": "Test",
    "timestamp": "2024-01-15T10:30:00Z"
  }'
```

**Si ça fonctionne** : Le webhook n8n fonctionne, le problème vient du bridge
**Si ça ne fonctionne pas** : Le problème vient de n8n ou du workflow

## 🐛 Solutions aux problèmes courants

### Problème 1 : Variable d'environnement non chargée

**Symptôme** : `No webhook configured` dans les logs

**Solution** :
```bash
# Créer/mettre à jour .env
echo "N8N_WEBHOOK_URL=https://floroo.app.n8n.cloud/webhook/mcp-whatsapp" > .env

# Reconstruire et redémarrer
docker compose down
docker compose up -d --build whatsapp-bridge

# Vérifier
docker compose logs whatsapp-bridge | grep webhook
```

### Problème 2 : Bridge non connecté à WhatsApp

**Symptôme** : Aucun message reçu, pas de logs de messages

**Solution** :
```bash
# Vérifier les logs
docker compose logs whatsapp-bridge | tail -50

# Si besoin de scanner le QR code
docker compose logs whatsapp-bridge | grep -A 20 "QR code"
```

### Problème 3 : Erreur de connexion HTTPS

**Symptôme** : `Error sending webhook: ...` dans les logs

**Solution** :
```bash
# Tester la connectivité
docker compose exec whatsapp-bridge curl -I https://floroo.app.n8n.cloud

# Vérifier les certificats SSL
docker compose exec whatsapp-bridge curl -v https://floroo.app.n8n.cloud/webhook/mcp-whatsapp
```

### Problème 4 : Workflow n8n non activé

**Symptôme** : Le webhook est envoyé mais rien ne se passe dans n8n

**Solution** :
1. Allez sur https://floroo.app.n8n.cloud
2. Ouvrez votre workflow
3. Activez-le (bouton ON/OFF)
4. Vérifiez que le webhook est configuré avec le bon path

### Problème 5 : Messages envoyés par vous-même

**Symptôme** : Les messages que vous envoyez ne déclenchent pas le webhook

**C'est normal !** Le webhook ne se déclenche que pour les **messages entrants** (pas ceux que vous envoyez).

**Solution** : Testez en envoyant un message depuis un autre numéro WhatsApp.

## ✅ Checklist de diagnostic

- [ ] Fichier `.env` existe avec `N8N_WEBHOOK_URL`
- [ ] Variable chargée dans le conteneur (`docker compose exec whatsapp-bridge env | grep N8N`)
- [ ] Logs montrent "Webhook configured"
- [ ] Bridge reçoit des messages (logs avec "←")
- [ ] Connectivité HTTPS vers n8n fonctionne
- [ ] Workflow n8n est activé
- [ ] Webhook n8n a le bon path (`mcp-whatsapp`)
- [ ] Test manuel du webhook fonctionne

## 🔧 Script de diagnostic automatique

Exécutez ce script pour diagnostiquer automatiquement :

```bash
#!/bin/bash
echo "🔍 Diagnostic du webhook WhatsApp → n8n"
echo ""

echo "1. Vérification des services Docker:"
docker compose ps
echo ""

echo "2. Vérification du fichier .env:"
if [ -f .env ]; then
  echo "✅ Fichier .env existe"
  if grep -q "N8N_WEBHOOK_URL" .env; then
    echo "✅ N8N_WEBHOOK_URL configuré:"
    grep "N8N_WEBHOOK_URL" .env
  else
    echo "❌ N8N_WEBHOOK_URL non trouvé dans .env"
  fi
else
  echo "❌ Fichier .env n'existe pas"
fi
echo ""

echo "3. Vérification dans le conteneur:"
docker compose exec whatsapp-bridge env | grep N8N_WEBHOOK_URL || echo "❌ Variable non trouvée"
echo ""

echo "4. Vérification des logs (webhook):"
docker compose logs whatsapp-bridge 2>&1 | grep -i webhook | tail -5
echo ""

echo "5. Vérification des messages reçus:"
docker compose logs whatsapp-bridge --tail 50 | grep -E "←|Message received" | tail -5 || echo "Aucun message récent"
echo ""

echo "6. Test de connectivité vers n8n:"
docker compose exec whatsapp-bridge curl -I -s https://floroo.app.n8n.cloud/webhook/mcp-whatsapp 2>&1 | head -1
echo ""

echo "✅ Diagnostic terminé"
```

## 📞 Prochaines étapes

1. **Exécutez le diagnostic** ci-dessus
2. **Identifiez le problème** dans la checklist
3. **Appliquez la solution** correspondante
4. **Testez à nouveau** en envoyant un message WhatsApp

Si le problème persiste, partagez les résultats du diagnostic pour une aide plus ciblée.

