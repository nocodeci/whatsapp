#!/bin/bash

# Script pour démarrer WhatsApp MCP avec n8n

echo "🚀 Démarrage de WhatsApp MCP avec n8n..."

# Vérifier si Docker est en cours d'exécution
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Docker n'est pas en cours d'exécution."
    echo "📝 Veuillez démarrer Docker Desktop ou le daemon Docker, puis réessayez."
    exit 1
fi

echo "✅ Docker est en cours d'exécution"

# Construire les images
echo "🔨 Construction des images Docker..."
docker compose build

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la construction des images"
    exit 1
fi

# Démarrer les services
echo "🚀 Démarrage des services..."
docker compose up -d

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors du démarrage des services"
    exit 1
fi

echo ""
echo "✅ Services démarrés avec succès!"
echo ""
echo "📋 Services disponibles:"
echo "   - n8n: http://localhost:5678"
echo "   - WhatsApp Bridge: http://localhost:8081"
echo "   - WhatsApp MCP Server: localhost:9000"
echo ""
echo "📱 Pour authentifier WhatsApp:"
echo "   docker compose logs whatsapp-bridge"
echo ""
echo "📊 Vérifier le statut des services:"
echo "   docker compose ps"
echo ""
echo "📝 Voir les logs:"
echo "   docker compose logs -f"

