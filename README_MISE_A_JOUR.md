# 🔄 Guide rapide : Mises à jour

## 🚀 Mise à jour en une commande

```bash
./update-all.sh
```

C'est tout ! Le script fait tout automatiquement :
- ✅ Vérifie les mises à jour
- ✅ Crée une sauvegarde
- ✅ Met à jour le code
- ✅ Reconstruit l'image
- ✅ Redémarre le service
- ✅ Vérifie que tout fonctionne

## 📋 Vérifier les mises à jour (sans mettre à jour)

```bash
./check-update.sh
```

## 📚 Documentation complète

Pour plus de détails, consultez : [GUIDE_MISE_A_JOUR.md](GUIDE_MISE_A_JOUR.md)

## ⚠️ Quand mettre à jour ?

**Mise à jour immédiate si :**
- ❌ Erreur `Client outdated (405)`
- ❌ QR code n'apparaît pas
- ❌ Connexion refusée

**Mise à jour régulière :**
- ✅ Une fois par semaine
- ✅ Après chaque problème de connexion

## 🔍 Vérifier après mise à jour

```bash
# Voir les logs
docker compose logs -f whatsapp-bridge

# Vérifier l'API
curl http://localhost:8081/api/health
```

---

**💡 Astuce** : Ajoutez `./check-update.sh` à votre crontab pour vérifier automatiquement chaque semaine.

