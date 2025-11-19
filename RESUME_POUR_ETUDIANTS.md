# 🎓 Résumé pour les Étudiants

Bienvenue dans le projet **WhatsApp MCP Server avec n8n** !

## 🚀 Démarrage Rapide

### 1. Cloner le Repository

```bash
git clone <URL_DU_REPO>
cd whatsapp-mcp-n8n
```

### 2. Installer et Démarrer

```bash
# Copier le fichier d'environnement
cp .env.example .env

# Démarrer les services
docker compose up -d

# Voir le QR code
docker compose logs -f whatsapp-bridge
```

### 3. Scanner le QR Code

1. Ouvrez WhatsApp sur votre téléphone
2. Allez dans **Paramètres** → **Appareils liés** → **Lier un appareil**
3. Scannez le QR code affiché dans le terminal

### 4. Accéder aux Interfaces

- **Dashboard WhatsApp** : http://localhost:8000
- **n8n** : http://localhost:5678 (admin/admin)

## 📚 Guides Complets

Pour plus de détails, consultez :

1. **[GUIDE_INSTALLATION_ETUDIANTS.md](GUIDE_INSTALLATION_ETUDIANTS.md)** - Installation détaillée
2. **[GUIDE_QR_CODE_ETUDIANTS.md](GUIDE_QR_CODE_ETUDIANTS.md)** - Scanner le QR code
3. **[GUIDE_MCP_NATIF_N8N.md](GUIDE_MCP_NATIF_N8N.md)** - Utiliser avec n8n

## ✅ Checklist

- [ ] Docker installé et démarré
- [ ] Repository cloné
- [ ] Services démarrés
- [ ] QR code scanné
- [ ] WhatsApp connecté
- [ ] Dashboard accessible
- [ ] n8n accessible

## 🆘 Besoin d'Aide ?

1. Consultez les guides dans le repository
2. Vérifiez les logs : `docker compose logs`
3. Contactez votre professeur

---

**Bon développement ! 🚀**

