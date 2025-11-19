#!/bin/bash

# Script pour envoyer un message WhatsApp de test

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Numéro par défaut
RECIPIENT="${1:-2250703324674}"
MESSAGE="${2:-Bonjour ! Ceci est un message de test depuis le serveur MCP WhatsApp. 🚀}"

# Nettoyer le numéro (enlever +, espaces, tirets)
RECIPIENT=$(echo "$RECIPIENT" | tr -d '+ -')

echo "============================================================"
echo "📤 ENVOI DE MESSAGE WHATSAPP"
echo "============================================================"
echo ""
echo "📱 Destinataire: +$RECIPIENT"
echo "💬 Message: $MESSAGE"
echo ""

# Vérifier que Docker est démarré
if ! docker ps > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker n'est pas démarré${NC}"
    echo ""
    echo "💡 Veuillez démarrer Docker Desktop, puis réessayez."
    exit 1
fi

# Vérifier que le service est démarré
if ! docker ps | grep -q whatsapp-bridge; then
    echo -e "${YELLOW}⚠️  Le service whatsapp-bridge n'est pas démarré${NC}"
    echo ""
    echo "🔨 Démarrage des services..."
    docker compose up -d whatsapp-bridge
    echo ""
    echo "⏳ Attente de 5 secondes pour le démarrage..."
    sleep 5
fi

# Envoyer le message
echo "📤 Envoi en cours..."
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8081/api/send \
  -H "Content-Type: application/json" \
  -d "{
    \"recipient\": \"$RECIPIENT\",
    \"message\": \"$MESSAGE\"
  }")

# Vérifier le résultat
if echo "$RESPONSE" | grep -q '"success":true'; then
    echo -e "${GREEN}✅ Message envoyé avec succès !${NC}"
    echo ""
    echo "📝 Réponse:"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
    exit 0
else
    echo -e "${RED}❌ Échec de l'envoi${NC}"
    echo ""
    echo "📝 Réponse:"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
    echo ""
    echo "💡 Vérifiez les logs :"
    echo "   docker compose logs whatsapp-bridge | tail -20"
    exit 1
fi

