# Instructions d'installation et de démarrage

## Prérequis

1. **Docker** et **Docker Compose** doivent être installés
2. **Docker Desktop** (ou le daemon Docker) doit être en cours d'exécution

## Démarrage rapide

### Option 1: Utiliser le script de démarrage

```bash
./start.sh
```

### Option 2: Commandes manuelles

1. **Démarrer Docker** (si ce n'est pas déjà fait)
   - Sur macOS: Ouvrir Docker Desktop
   - Sur Linux: `sudo systemctl start docker`

2. **Construire les images Docker:**
   ```bash
   docker compose build
   ```

3. **Démarrer les services:**
   ```bash
   docker compose up -d
   ```

## Authentification WhatsApp

1. **Voir les logs du bridge WhatsApp pour obtenir le QR code:**
   ```bash
   docker compose logs whatsapp-bridge
   ```

2. **Scanner le QR code** avec votre application WhatsApp mobile

3. **Vérifier que l'authentification a réussi** en consultant à nouveau les logs

## Accès aux services

- **n8n**: http://localhost:5678
  - Utilisateur: `admin`
  - Mot de passe: `admin`
  
- **WhatsApp Bridge API**: http://localhost:8081
- **WhatsApp MCP Server**: localhost:9000 (pour n8n)

## Commandes utiles

### Vérifier le statut des services
```bash
docker compose ps
```

### Voir les logs
```bash
# Tous les services
docker compose logs -f

# Service spécifique
docker compose logs -f whatsapp-bridge
docker compose logs -f whatsapp-mcp-server
docker compose logs -f n8n
```

### Arrêter les services
```bash
docker compose down
```

### Redémarrer les services
```bash
docker compose restart
```

### Reconstruire après des modifications
```bash
docker compose up -d --build
```

## Configuration dans n8n

Pour utiliser le serveur MCP WhatsApp dans n8n:

1. Connectez-vous à n8n: http://localhost:5678
2. Configurez une connexion MCP vers `whatsapp-mcp-server:9000`
3. Utilisez les outils MCP disponibles pour envoyer/recevoir des messages WhatsApp

## Dépannage

### Docker n'est pas démarré
- Sur macOS: Ouvrir Docker Desktop
- Vérifier avec: `docker ps`

### Port déjà utilisé
- Modifier les ports dans `docker-compose.yml` si nécessaire
- Ports par défaut:
  - n8n: 5678
  - WhatsApp Bridge: 8081
  - WhatsApp MCP Server: 9000

### Erreurs de build
- Vérifier que Docker a assez d'espace disque
- Vérifier la connexion internet pour télécharger les images

### WhatsApp ne s'authentifie pas
- Vérifier les logs: `docker compose logs whatsapp-bridge`
- S'assurer que le QR code est scanné dans les 60 secondes
- Redémarrer le service si nécessaire: `docker compose restart whatsapp-bridge`

