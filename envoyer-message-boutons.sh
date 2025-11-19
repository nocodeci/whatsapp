#!/bin/bash

# Script pour envoyer un message WhatsApp avec boutons

RECIPIENT="${1:-2250703324674}"
MESSAGE="${2:-Choisissez une option :}"

# Nettoyer le numéro
RECIPIENT=$(echo "$RECIPIENT" | tr -d '+ -')

echo "📤 Envoi d'un message avec boutons à +$RECIPIENT..."
echo "💬 Message: $MESSAGE"
echo ""

curl -X POST http://localhost:8081/api/send \
  -H "Content-Type: application/json" \
  -d "{
    \"recipient\": \"$RECIPIENT\",
    \"message\": \"$MESSAGE\",
    \"buttons\": [
      {\"id\": \"option1\", \"title\": \"✅ Oui\"},
      {\"id\": \"option2\", \"title\": \"❌ Non\"},
      {\"id\": \"option3\", \"title\": \"ℹ️ Plus d'infos\"}
    ]
  }" | python3 -m json.tool 2>/dev/null || echo ""

