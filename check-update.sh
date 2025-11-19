#!/bin/bash

# Script pour vérifier les mises à jour de whatsmeow

echo "🔍 Vérification des mises à jour de whatsmeow..."
echo ""

# Récupérer le dernier commit
LATEST_COMMIT=$(curl -s "https://api.github.com/repos/tulir/whatsmeow/commits/main" 2>/dev/null | \
  grep '"sha"' | head -1 | cut -d'"' -f4 | cut -c1-12)

LATEST_DATE=$(curl -s "https://api.github.com/repos/tulir/whatsmeow/commits/main" 2>/dev/null | \
  grep '"date"' | head -1 | cut -d'"' -f4)

# Récupérer la version actuelle
CURRENT_VERSION=$(cat whatsapp-mcp/whatsapp-bridge/go.mod 2>/dev/null | grep whatsmeow | awk '{print $2}')

if [ -z "$LATEST_COMMIT" ]; then
  echo "❌ Impossible de récupérer les informations depuis GitHub"
  exit 1
fi

echo "📅 Dernier commit whatsmeow :"
echo "   SHA: $LATEST_COMMIT"
echo "   Date: $LATEST_DATE"
echo ""
echo "📦 Version actuelle dans le projet :"
echo "   $CURRENT_VERSION"
echo ""

# Vérifier si une mise à jour est nécessaire
if [[ "$CURRENT_VERSION" == *"$LATEST_COMMIT"* ]]; then
  echo "✅ Vous avez la dernière version disponible !"
  echo ""
  echo "💡 Pour vérifier le statut du service :"
  echo "   docker compose logs whatsapp-bridge --tail 20"
else
  echo "⚠️  Une nouvelle version est disponible !"
  echo ""
    echo "🔨 Pour mettre à jour automatiquement, exécutez :"
    echo "   ./update-all.sh"
    echo ""
    echo "🔨 Ou manuellement :"
  echo "   docker compose build --no-cache whatsapp-bridge"
  echo "   docker compose up -d whatsapp-bridge"
  echo "   docker compose logs -f whatsapp-bridge"
fi

echo ""
echo "🔗 Dépôt GitHub : https://github.com/tulir/whatsmeow"
echo "📋 Issues : https://github.com/tulir/whatsmeow/issues"

