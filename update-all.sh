#!/bin/bash

# Script automatisé pour mettre à jour WhatsApp MCP avec n8n
# Ce script vérifie et applique toutes les mises à jour nécessaires

set -e  # Arrêter en cas d'erreur

echo "🔄 Script de mise à jour automatique WhatsApp MCP"
echo "=================================================="
echo ""

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier que Docker est en cours d'exécution
if ! docker ps > /dev/null 2>&1; then
    error "Docker n'est pas en cours d'exécution."
    echo "📝 Veuillez démarrer Docker Desktop, puis réessayez."
    exit 1
fi

info "Docker est en cours d'exécution"
echo ""

# Étape 1 : Vérifier les mises à jour de whatsmeow
echo "📋 Étape 1 : Vérification des mises à jour de whatsmeow..."
echo ""

LATEST_COMMIT=$(curl -s "https://api.github.com/repos/tulir/whatsmeow/commits/main" 2>/dev/null | \
  grep '"sha"' | head -1 | cut -d'"' -f4 | cut -c1-12)

LATEST_DATE=$(curl -s "https://api.github.com/repos/tulir/whatsmeow/commits/main" 2>/dev/null | \
  grep '"date"' | head -1 | cut -d'"' -f4 | cut -d'T' -f1)

CURRENT_VERSION=$(cat whatsapp-mcp/whatsapp-bridge/go.mod 2>/dev/null | grep whatsmeow | awk '{print $2}' || echo "")

if [ -z "$LATEST_COMMIT" ]; then
    error "Impossible de récupérer les informations depuis GitHub"
    exit 1
fi

echo "📅 Dernier commit whatsmeow :"
echo "   SHA: $LATEST_COMMIT"
echo "   Date: $LATEST_DATE"
echo ""
echo "📦 Version actuelle :"
echo "   $CURRENT_VERSION"
echo ""

# Vérifier si une mise à jour est nécessaire
NEEDS_UPDATE=false
if [[ -z "$CURRENT_VERSION" ]] || [[ "$CURRENT_VERSION" != *"$LATEST_COMMIT"* ]]; then
    warn "Une nouvelle version est disponible !"
    NEEDS_UPDATE=true
else
    info "Vous avez déjà la dernière version de whatsmeow"
fi

echo ""

# Demander confirmation si mise à jour nécessaire
if [ "$NEEDS_UPDATE" = true ]; then
    echo "🔨 Mise à jour disponible. Voulez-vous continuer ? (o/n)"
    read -r response
    if [[ ! "$response" =~ ^[OoYy]$ ]]; then
        info "Mise à jour annulée par l'utilisateur"
        exit 0
    fi
    echo ""
fi

# Étape 2 : Sauvegarder l'état actuel
echo "📋 Étape 2 : Sauvegarde de l'état actuel..."
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
info "Création d'une sauvegarde dans $BACKUP_DIR"

# Sauvegarder go.mod et go.sum
cp whatsapp-mcp/whatsapp-bridge/go.mod "$BACKUP_DIR/go.mod.bak" 2>/dev/null || true
cp whatsapp-mcp/whatsapp-bridge/go.sum "$BACKUP_DIR/go.sum.bak" 2>/dev/null || true

info "Sauvegarde créée"
echo ""

# Étape 3 : Mettre à jour go.mod si nécessaire
if [ "$NEEDS_UPDATE" = true ]; then
    echo "📋 Étape 3 : Mise à jour de go.mod..."
    
    # Extraire la date du commit pour la version
    COMMIT_FULL=$(curl -s "https://api.github.com/repos/tulir/whatsmeow/commits/main" 2>/dev/null | \
      grep '"sha"' | head -1 | cut -d'"' -f4)
    
    COMMIT_DATE=$(curl -s "https://api.github.com/repos/tulir/whatsmeow/commits/main" 2>/dev/null | \
      grep '"date"' | head -1 | cut -d'"' -f4 | sed 's/T/ /' | cut -d'.' -f1 | \
      sed 's/-//g' | sed 's/://g' | sed 's/ //' | cut -c1-14)
    
    NEW_VERSION="v0.0.0-${COMMIT_DATE}-${LATEST_COMMIT}"
    
    # Mettre à jour go.mod
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|go.mau.fi/whatsmeow.*|go.mau.fi/whatsmeow $NEW_VERSION|" whatsapp-mcp/whatsapp-bridge/go.mod
    else
        # Linux
        sed -i "s|go.mau.fi/whatsmeow.*|go.mau.fi/whatsmeow $NEW_VERSION|" whatsapp-mcp/whatsapp-bridge/go.mod
    fi
    
    info "go.mod mis à jour vers $NEW_VERSION"
    echo ""
fi

# Étape 4 : Reconstruire l'image Docker
echo "📋 Étape 4 : Reconstruction de l'image Docker..."
info "Cela peut prendre plusieurs minutes..."
echo ""

if docker compose build --no-cache whatsapp-bridge; then
    info "Image Docker reconstruite avec succès"
else
    error "Erreur lors de la reconstruction de l'image"
    echo ""
    warn "Restauration de la sauvegarde..."
    cp "$BACKUP_DIR/go.mod.bak" whatsapp-mcp/whatsapp-bridge/go.mod 2>/dev/null || true
    cp "$BACKUP_DIR/go.sum.bak" whatsapp-mcp/whatsapp-bridge/go.sum 2>/dev/null || true
    exit 1
fi

echo ""

# Étape 5 : Redémarrer le service
echo "📋 Étape 5 : Redémarrage du service..."
if docker compose up -d whatsapp-bridge; then
    info "Service redémarré avec succès"
else
    error "Erreur lors du redémarrage du service"
    exit 1
fi

echo ""

# Étape 6 : Vérifier le statut
echo "📋 Étape 6 : Vérification du statut..."
echo ""
info "Attente de 10 secondes pour que le service démarre..."
sleep 10

# Vérifier les logs pour les erreurs
echo ""
echo "📊 Derniers logs du service :"
echo "----------------------------------------"
docker compose logs --tail 30 whatsapp-bridge | grep -E "(ERROR|ERROR|Connected|QR code|outdated)" || true
echo "----------------------------------------"
echo ""

# Vérifier l'API
if curl -s http://localhost:8081/api/health > /dev/null 2>&1; then
    info "✅ API REST répond correctement"
else
    warn "⚠️  L'API REST ne répond pas encore (peut être normal au démarrage)"
fi

echo ""
echo "=================================================="
info "Mise à jour terminée !"
echo ""
echo "📱 Pour voir les logs en temps réel :"
echo "   docker compose logs -f whatsapp-bridge"
echo ""
echo "📋 Pour vérifier le statut :"
echo "   docker compose ps"
echo ""
echo "🔍 Pour vérifier les mises à jour futures :"
echo "   ./check-update.sh"
echo ""

